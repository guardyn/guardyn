//! Rate Limiting Module
//!
//! Provides rate limiting functionality for protecting Guardyn services from abuse.
//! Uses a sliding window algorithm with configurable limits per endpoint.

use std::collections::HashMap;
use std::net::IpAddr;
use std::sync::Arc;
use std::time::{Duration, Instant};

use parking_lot::RwLock;
use thiserror::Error;

/// Rate limiting errors
#[derive(Debug, Clone, Error)]
pub enum RateLimitError {
    #[error("Rate limit exceeded: {limit} requests per {window:?}")]
    LimitExceeded {
        limit: u32,
        window: Duration,
        retry_after: Duration,
    },

    #[error("Blocked IP address: {ip}")]
    IpBlocked { ip: IpAddr },

    #[error("Blocked user: {user_id}")]
    UserBlocked { user_id: String },
}

/// Result type for rate limiting operations
pub type RateLimitResult<T> = std::result::Result<T, RateLimitError>;

/// Rate limit configuration for an endpoint
#[derive(Debug, Clone)]
pub struct RateLimitConfig {
    /// Maximum number of requests allowed
    pub max_requests: u32,

    /// Time window for the limit
    pub window: Duration,

    /// Whether to apply per-IP limiting
    pub per_ip: bool,

    /// Whether to apply per-user limiting
    pub per_user: bool,

    /// Burst allowance (additional requests above limit)
    pub burst_size: u32,
}

impl Default for RateLimitConfig {
    fn default() -> Self {
        Self {
            max_requests: 100,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: true,
            burst_size: 10,
        }
    }
}

impl RateLimitConfig {
    /// Create a strict rate limit (e.g., for auth endpoints)
    pub fn strict() -> Self {
        Self {
            max_requests: 5,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: false,
            burst_size: 2,
        }
    }

    /// Create a standard rate limit (e.g., for messaging)
    pub fn standard() -> Self {
        Self {
            max_requests: 60,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: true,
            burst_size: 10,
        }
    }

    /// Create a relaxed rate limit (e.g., for read operations)
    pub fn relaxed() -> Self {
        Self {
            max_requests: 300,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: true,
            burst_size: 50,
        }
    }
}

/// Request tracking entry
#[derive(Debug)]
struct RequestEntry {
    /// Timestamps of recent requests
    timestamps: Vec<Instant>,
    /// Whether this entity is temporarily blocked
    blocked_until: Option<Instant>,
}

impl RequestEntry {
    fn new() -> Self {
        Self {
            timestamps: Vec::new(),
            blocked_until: None,
        }
    }

    /// Clean up old timestamps outside the window
    fn cleanup(&mut self, window: Duration) {
        let cutoff = Instant::now() - window;
        self.timestamps.retain(|&t| t > cutoff);
    }

    /// Check if blocked
    fn is_blocked(&self) -> bool {
        self.blocked_until
            .map(|until| Instant::now() < until)
            .unwrap_or(false)
    }

    /// Get remaining block time
    fn block_remaining(&self) -> Option<Duration> {
        self.blocked_until.and_then(|until| {
            let now = Instant::now();
            if now < until {
                Some(until - now)
            } else {
                None
            }
        })
    }

    /// Record a new request
    fn record(&mut self) {
        self.timestamps.push(Instant::now());
    }

    /// Count requests in the current window
    fn count_in_window(&self, window: Duration) -> u32 {
        let cutoff = Instant::now() - window;
        self.timestamps.iter().filter(|&&t| t > cutoff).count() as u32
    }
}

/// Rate limiter state
pub struct RateLimiter {
    /// Configuration
    config: RateLimitConfig,

    /// Per-IP request tracking
    ip_entries: Arc<RwLock<HashMap<IpAddr, RequestEntry>>>,

    /// Per-user request tracking
    user_entries: Arc<RwLock<HashMap<String, RequestEntry>>>,

    /// Blocked IPs (persistent blocks)
    blocked_ips: Arc<RwLock<HashMap<IpAddr, Instant>>>,

    /// Blocked users (persistent blocks)
    blocked_users: Arc<RwLock<HashMap<String, Instant>>>,
}

impl RateLimiter {
    /// Create a new rate limiter with the given configuration
    pub fn new(config: RateLimitConfig) -> Self {
        Self {
            config,
            ip_entries: Arc::new(RwLock::new(HashMap::new())),
            user_entries: Arc::new(RwLock::new(HashMap::new())),
            blocked_ips: Arc::new(RwLock::new(HashMap::new())),
            blocked_users: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Check if a request is allowed
    pub fn check(&self, ip: Option<IpAddr>, user_id: Option<&str>) -> RateLimitResult<()> {
        // Check permanent blocks first
        if let Some(ip) = ip {
            self.check_ip_blocked(ip)?;
        }

        if let Some(user_id) = user_id {
            self.check_user_blocked(user_id)?;
        }

        // Check rate limits
        if self.config.per_ip {
            if let Some(ip) = ip {
                self.check_ip_limit(ip)?;
            }
        }

        if self.config.per_user {
            if let Some(user_id) = user_id {
                self.check_user_limit(user_id)?;
            }
        }

        Ok(())
    }

    /// Record a request (call after check passes)
    pub fn record(&self, ip: Option<IpAddr>, user_id: Option<&str>) {
        if self.config.per_ip {
            if let Some(ip) = ip {
                self.record_ip_request(ip);
            }
        }

        if self.config.per_user {
            if let Some(user_id) = user_id {
                self.record_user_request(user_id);
            }
        }
    }

    /// Check and record in one operation
    pub fn check_and_record(
        &self,
        ip: Option<IpAddr>,
        user_id: Option<&str>,
    ) -> RateLimitResult<()> {
        self.check(ip, user_id)?;
        self.record(ip, user_id);
        Ok(())
    }

    /// Block an IP address for a duration
    pub fn block_ip(&self, ip: IpAddr, duration: Duration) {
        let until = Instant::now() + duration;
        self.blocked_ips.write().insert(ip, until);
        tracing::warn!("Blocked IP {} for {:?}", ip, duration);
    }

    /// Block a user for a duration
    pub fn block_user(&self, user_id: &str, duration: Duration) {
        let until = Instant::now() + duration;
        self.blocked_users
            .write()
            .insert(user_id.to_string(), until);
        tracing::warn!("Blocked user {} for {:?}", user_id, duration);
    }

    /// Unblock an IP address
    pub fn unblock_ip(&self, ip: IpAddr) {
        self.blocked_ips.write().remove(&ip);
        tracing::info!("Unblocked IP {}", ip);
    }

    /// Unblock a user
    pub fn unblock_user(&self, user_id: &str) {
        self.blocked_users.write().remove(user_id);
        tracing::info!("Unblocked user {}", user_id);
    }

    /// Get remaining requests for an IP
    pub fn remaining_for_ip(&self, ip: IpAddr) -> u32 {
        let entries = self.ip_entries.read();
        let count = entries
            .get(&ip)
            .map(|e| e.count_in_window(self.config.window))
            .unwrap_or(0);

        let total_limit = self.config.max_requests + self.config.burst_size;
        total_limit.saturating_sub(count)
    }

    /// Clean up expired entries (call periodically)
    pub fn cleanup(&self) {
        let now = Instant::now();

        // Clean up IP entries
        {
            let mut entries = self.ip_entries.write();
            entries.retain(|_, entry| {
                entry.cleanup(self.config.window);
                !entry.timestamps.is_empty() || entry.is_blocked()
            });
        }

        // Clean up user entries
        {
            let mut entries = self.user_entries.write();
            entries.retain(|_, entry| {
                entry.cleanup(self.config.window);
                !entry.timestamps.is_empty() || entry.is_blocked()
            });
        }

        // Clean up expired blocks
        {
            let mut blocks = self.blocked_ips.write();
            blocks.retain(|_, until| *until > now);
        }

        {
            let mut blocks = self.blocked_users.write();
            blocks.retain(|_, until| *until > now);
        }
    }

    // Private methods

    fn check_ip_blocked(&self, ip: IpAddr) -> RateLimitResult<()> {
        let blocks = self.blocked_ips.read();
        if let Some(&until) = blocks.get(&ip) {
            if Instant::now() < until {
                return Err(RateLimitError::IpBlocked { ip });
            }
        }
        Ok(())
    }

    fn check_user_blocked(&self, user_id: &str) -> RateLimitResult<()> {
        let blocks = self.blocked_users.read();
        if let Some(&until) = blocks.get(user_id) {
            if Instant::now() < until {
                return Err(RateLimitError::UserBlocked {
                    user_id: user_id.to_string(),
                });
            }
        }
        Ok(())
    }

    fn check_ip_limit(&self, ip: IpAddr) -> RateLimitResult<()> {
        let entries = self.ip_entries.read();
        if let Some(entry) = entries.get(&ip) {
            // Check temporary block
            if let Some(remaining) = entry.block_remaining() {
                return Err(RateLimitError::LimitExceeded {
                    limit: self.config.max_requests,
                    window: self.config.window,
                    retry_after: remaining,
                });
            }

            // Check rate limit
            let count = entry.count_in_window(self.config.window);
            let total_limit = self.config.max_requests + self.config.burst_size;

            if count >= total_limit {
                return Err(RateLimitError::LimitExceeded {
                    limit: self.config.max_requests,
                    window: self.config.window,
                    retry_after: self.calculate_retry_after(entry),
                });
            }
        }
        Ok(())
    }

    fn check_user_limit(&self, user_id: &str) -> RateLimitResult<()> {
        let entries = self.user_entries.read();
        if let Some(entry) = entries.get(user_id) {
            // Check temporary block
            if let Some(remaining) = entry.block_remaining() {
                return Err(RateLimitError::LimitExceeded {
                    limit: self.config.max_requests,
                    window: self.config.window,
                    retry_after: remaining,
                });
            }

            // Check rate limit
            let count = entry.count_in_window(self.config.window);
            let total_limit = self.config.max_requests + self.config.burst_size;

            if count >= total_limit {
                return Err(RateLimitError::LimitExceeded {
                    limit: self.config.max_requests,
                    window: self.config.window,
                    retry_after: self.calculate_retry_after(entry),
                });
            }
        }
        Ok(())
    }

    fn record_ip_request(&self, ip: IpAddr) {
        let mut entries = self.ip_entries.write();
        let entry = entries.entry(ip).or_insert_with(RequestEntry::new);
        entry.record();
    }

    fn record_user_request(&self, user_id: &str) {
        let mut entries = self.user_entries.write();
        let entry = entries
            .entry(user_id.to_string())
            .or_insert_with(RequestEntry::new);
        entry.record();
    }

    fn calculate_retry_after(&self, entry: &RequestEntry) -> Duration {
        // Find the oldest timestamp in the window
        let cutoff = Instant::now() - self.config.window;
        if let Some(&oldest) = entry.timestamps.iter().find(|&&t| t > cutoff) {
            let wait_until = oldest + self.config.window;
            wait_until.saturating_duration_since(Instant::now())
        } else {
            Duration::from_secs(1)
        }
    }
}

impl Clone for RateLimiter {
    fn clone(&self) -> Self {
        Self {
            config: self.config.clone(),
            ip_entries: Arc::clone(&self.ip_entries),
            user_entries: Arc::clone(&self.user_entries),
            blocked_ips: Arc::clone(&self.blocked_ips),
            blocked_users: Arc::clone(&self.blocked_users),
        }
    }
}

/// Predefined rate limiters for different endpoints
pub struct RateLimiters {
    /// Authentication endpoints (login, register)
    pub auth: RateLimiter,

    /// Messaging endpoints (send message)
    pub messaging: RateLimiter,

    /// Media upload endpoints
    pub media: RateLimiter,

    /// Search endpoints
    pub search: RateLimiter,

    /// General API endpoints
    pub general: RateLimiter,
}

impl RateLimiters {
    /// Create a new set of rate limiters with default configurations
    pub fn new() -> Self {
        Self {
            auth: RateLimiter::new(RateLimitConfig::strict()),
            messaging: RateLimiter::new(RateLimitConfig::standard()),
            media: RateLimiter::new(RateLimitConfig {
                max_requests: 20,
                window: Duration::from_secs(60),
                per_ip: true,
                per_user: true,
                burst_size: 5,
            }),
            search: RateLimiter::new(RateLimitConfig {
                max_requests: 30,
                window: Duration::from_secs(60),
                per_ip: true,
                per_user: true,
                burst_size: 10,
            }),
            general: RateLimiter::new(RateLimitConfig::relaxed()),
        }
    }

    /// Clean up all rate limiters
    pub fn cleanup_all(&self) {
        self.auth.cleanup();
        self.messaging.cleanup();
        self.media.cleanup();
        self.search.cleanup();
        self.general.cleanup();
    }
}

impl Default for RateLimiters {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rate_limiter_allows_requests_under_limit() {
        let limiter = RateLimiter::new(RateLimitConfig {
            max_requests: 5,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: false,
            burst_size: 0,
        });

        let ip: IpAddr = "127.0.0.1".parse().unwrap();

        for _ in 0..5 {
            assert!(limiter.check_and_record(Some(ip), None).is_ok());
        }
    }

    #[test]
    fn test_rate_limiter_blocks_after_limit() {
        let limiter = RateLimiter::new(RateLimitConfig {
            max_requests: 3,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: false,
            burst_size: 0,
        });

        let ip: IpAddr = "127.0.0.1".parse().unwrap();

        // Should allow first 3 requests
        for _ in 0..3 {
            assert!(limiter.check_and_record(Some(ip), None).is_ok());
        }

        // Should block 4th request
        let result = limiter.check_and_record(Some(ip), None);
        assert!(result.is_err());
        assert!(matches!(result, Err(RateLimitError::LimitExceeded { .. })));
    }

    #[test]
    fn test_rate_limiter_burst() {
        let limiter = RateLimiter::new(RateLimitConfig {
            max_requests: 5,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: false,
            burst_size: 3,
        });

        let ip: IpAddr = "127.0.0.1".parse().unwrap();

        // Should allow 5 + 3 = 8 requests
        for _ in 0..8 {
            assert!(limiter.check_and_record(Some(ip), None).is_ok());
        }

        // Should block 9th request
        assert!(limiter.check_and_record(Some(ip), None).is_err());
    }

    #[test]
    fn test_ip_blocking() {
        let limiter = RateLimiter::new(RateLimitConfig::default());
        let ip: IpAddr = "192.168.1.1".parse().unwrap();

        // Block the IP
        limiter.block_ip(ip, Duration::from_secs(3600));

        // Should be blocked
        let result = limiter.check(Some(ip), None);
        assert!(matches!(result, Err(RateLimitError::IpBlocked { .. })));

        // Unblock
        limiter.unblock_ip(ip);

        // Should be allowed
        assert!(limiter.check(Some(ip), None).is_ok());
    }

    #[test]
    fn test_user_blocking() {
        let limiter = RateLimiter::new(RateLimitConfig::default());
        let user_id = "user-123";

        // Block the user
        limiter.block_user(user_id, Duration::from_secs(3600));

        // Should be blocked
        let result = limiter.check(None, Some(user_id));
        assert!(matches!(result, Err(RateLimitError::UserBlocked { .. })));

        // Unblock
        limiter.unblock_user(user_id);

        // Should be allowed
        assert!(limiter.check(None, Some(user_id)).is_ok());
    }

    #[test]
    fn test_remaining_requests() {
        let limiter = RateLimiter::new(RateLimitConfig {
            max_requests: 10,
            window: Duration::from_secs(60),
            per_ip: true,
            per_user: false,
            burst_size: 0,
        });

        let ip: IpAddr = "10.0.0.1".parse().unwrap();

        assert_eq!(limiter.remaining_for_ip(ip), 10);

        // Make 3 requests
        for _ in 0..3 {
            limiter.record(Some(ip), None);
        }

        assert_eq!(limiter.remaining_for_ip(ip), 7);
    }

    #[test]
    fn test_rate_limiters_preset() {
        let limiters = RateLimiters::new();

        let ip: IpAddr = "127.0.0.1".parse().unwrap();

        // Auth should be strict
        for _ in 0..7 {
            // 5 + 2 burst
            assert!(limiters.auth.check_and_record(Some(ip), None).is_ok());
        }
        assert!(limiters.auth.check_and_record(Some(ip), None).is_err());
    }
}
