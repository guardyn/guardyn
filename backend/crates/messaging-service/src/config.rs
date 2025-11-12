/// Configuration management for messaging service
///
/// Provides runtime configuration from environment variables including:
/// - Feature flags (MLS, E2EE)
/// - Service endpoints
/// - Database settings
/// - Performance tuning

use std::env;

/// MLS (Messaging Layer Security) configuration
#[derive(Debug, Clone)]
pub struct MlsConfig {
    /// Enable MLS group encryption (default: false for gradual rollout)
    pub enabled: bool,
    
    /// Maximum group size for MLS (performance tuning)
    pub max_group_size: usize,
    
    /// Key package time-to-live in days
    pub key_package_ttl_days: u32,
    
    /// MLS ciphersuite (default: MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519)
    pub ciphersuite: String,
}

impl MlsConfig {
    /// Load MLS configuration from environment variables
    ///
    /// Environment variables:
    /// - ENABLE_MLS: Enable MLS group encryption (default: false)
    /// - MLS_MAX_GROUP_SIZE: Maximum group size (default: 256)
    /// - MLS_KEY_PACKAGE_TTL_DAYS: Key package TTL (default: 30)
    /// - MLS_CIPHERSUITE: Ciphersuite identifier (default: MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519)
    pub fn from_env() -> Self {
        let enabled = env::var("ENABLE_MLS")
            .unwrap_or_else(|_| "false".to_string())
            .parse::<bool>()
            .unwrap_or(false);
        
        let max_group_size = env::var("MLS_MAX_GROUP_SIZE")
            .unwrap_or_else(|_| "256".to_string())
            .parse::<usize>()
            .unwrap_or(256);
        
        let key_package_ttl_days = env::var("MLS_KEY_PACKAGE_TTL_DAYS")
            .unwrap_or_else(|_| "30".to_string())
            .parse::<u32>()
            .unwrap_or(30);
        
        let ciphersuite = env::var("MLS_CIPHERSUITE")
            .unwrap_or_else(|_| "MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519".to_string());
        
        Self {
            enabled,
            max_group_size,
            key_package_ttl_days,
            ciphersuite,
        }
    }
    
    /// Check if MLS is enabled for a specific group
    ///
    /// Future: Can add per-group or per-user rollout logic here
    pub fn is_enabled_for_group(&self, _group_id: &str) -> bool {
        self.enabled
    }
}

/// E2EE (End-to-End Encryption) configuration for 1-on-1 chats
#[derive(Debug, Clone)]
pub struct E2eeConfig {
    /// Enable E2EE for 1-on-1 messages (default: false for gradual rollout)
    pub enabled: bool,
    
    /// Enable X3DH key agreement (default: true when E2EE enabled)
    pub x3dh_enabled: bool,
    
    /// Enable Double Ratchet encryption (default: true when E2EE enabled)
    pub double_ratchet_enabled: bool,
    
    /// Maximum skipped message keys to store (default: 1000)
    pub max_skipped_message_keys: usize,
}

impl E2eeConfig {
    /// Load E2EE configuration from environment variables
    ///
    /// Environment variables:
    /// - ENABLE_E2EE: Enable E2EE for 1-on-1 chats (default: false)
    /// - E2EE_X3DH_ENABLED: Enable X3DH (default: true)
    /// - E2EE_DOUBLE_RATCHET_ENABLED: Enable Double Ratchet (default: true)
    /// - E2EE_MAX_SKIPPED_KEYS: Max skipped message keys (default: 1000)
    pub fn from_env() -> Self {
        let enabled = env::var("ENABLE_E2EE")
            .unwrap_or_else(|_| "false".to_string())
            .parse::<bool>()
            .unwrap_or(false);
        
        let x3dh_enabled = env::var("E2EE_X3DH_ENABLED")
            .unwrap_or_else(|_| "true".to_string())
            .parse::<bool>()
            .unwrap_or(true);
        
        let double_ratchet_enabled = env::var("E2EE_DOUBLE_RATCHET_ENABLED")
            .unwrap_or_else(|_| "true".to_string())
            .parse::<bool>()
            .unwrap_or(true);
        
        let max_skipped_message_keys = env::var("E2EE_MAX_SKIPPED_KEYS")
            .unwrap_or_else(|_| "1000".to_string())
            .parse::<usize>()
            .unwrap_or(1000);
        
        Self {
            enabled,
            x3dh_enabled,
            double_ratchet_enabled,
            max_skipped_message_keys,
        }
    }
}

/// Main messaging service configuration
#[derive(Debug, Clone)]
pub struct MessagingConfig {
    /// MLS configuration
    pub mls: MlsConfig,
    
    /// E2EE configuration
    pub e2ee: E2eeConfig,
    
    /// Service bind address (default: 0.0.0.0:50052)
    pub bind_address: String,
    
    /// TiKV endpoints
    pub tikv_endpoints: Vec<String>,
    
    /// ScyllaDB endpoints
    pub scylladb_endpoints: Vec<String>,
    
    /// NATS endpoint
    pub nats_endpoint: String,
    
    /// Auth service endpoint (for gRPC client)
    pub auth_service_endpoint: String,
}

impl MessagingConfig {
    /// Load full messaging service configuration from environment
    pub fn from_env() -> Self {
        let bind_address = env::var("BIND_ADDRESS")
            .unwrap_or_else(|_| "0.0.0.0:50052".to_string());
        
        let tikv_endpoints = env::var("TIKV_ENDPOINTS")
            .unwrap_or_else(|_| "tikv-pd.data.svc.cluster.local:2379".to_string())
            .split(',')
            .map(|s| s.to_string())
            .collect();
        
        let scylladb_endpoints = env::var("SCYLLADB_ENDPOINTS")
            .unwrap_or_else(|_| "scylladb-client.data.svc.cluster.local:9042".to_string())
            .split(',')
            .map(|s| s.to_string())
            .collect();
        
        let nats_endpoint = env::var("NATS_ENDPOINT")
            .unwrap_or_else(|_| "nats://nats.messaging.svc.cluster.local:4222".to_string());
        
        let auth_service_endpoint = env::var("AUTH_SERVICE_ENDPOINT")
            .unwrap_or_else(|_| "http://auth-service.apps.svc.cluster.local:50051".to_string());
        
        Self {
            mls: MlsConfig::from_env(),
            e2ee: E2eeConfig::from_env(),
            bind_address,
            tikv_endpoints,
            scylladb_endpoints,
            nats_endpoint,
            auth_service_endpoint,
        }
    }
    
    /// Print configuration summary (for startup logs)
    pub fn print_summary(&self) {
        println!("📋 Messaging Service Configuration:");
        println!("  - Bind Address: {}", self.bind_address);
        println!("  - TiKV Endpoints: {:?}", self.tikv_endpoints);
        println!("  - ScyllaDB Endpoints: {:?}", self.scylladb_endpoints);
        println!("  - NATS Endpoint: {}", self.nats_endpoint);
        println!("  - Auth Service Endpoint: {}", self.auth_service_endpoint);
        println!("🔐 MLS Configuration:");
        println!("  - Enabled: {}", self.mls.enabled);
        if self.mls.enabled {
            println!("  - Max Group Size: {}", self.mls.max_group_size);
            println!("  - Key Package TTL: {} days", self.mls.key_package_ttl_days);
            println!("  - Ciphersuite: {}", self.mls.ciphersuite);
        }
        println!("🔐 E2EE Configuration:");
        println!("  - Enabled: {}", self.e2ee.enabled);
        if self.e2ee.enabled {
            println!("  - X3DH: {}", self.e2ee.x3dh_enabled);
            println!("  - Double Ratchet: {}", self.e2ee.double_ratchet_enabled);
            println!("  - Max Skipped Keys: {}", self.e2ee.max_skipped_message_keys);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_mls_config_defaults() {
        // Clear environment variables for test
        env::remove_var("ENABLE_MLS");
        env::remove_var("MLS_MAX_GROUP_SIZE");
        
        let config = MlsConfig::from_env();
        
        assert_eq!(config.enabled, false);
        assert_eq!(config.max_group_size, 256);
        assert_eq!(config.key_package_ttl_days, 30);
    }
    
    #[test]
    fn test_mls_config_from_env() {
        env::set_var("ENABLE_MLS", "true");
        env::set_var("MLS_MAX_GROUP_SIZE", "512");
        env::set_var("MLS_KEY_PACKAGE_TTL_DAYS", "60");
        
        let config = MlsConfig::from_env();
        
        assert_eq!(config.enabled, true);
        assert_eq!(config.max_group_size, 512);
        assert_eq!(config.key_package_ttl_days, 60);
        
        // Cleanup
        env::remove_var("ENABLE_MLS");
        env::remove_var("MLS_MAX_GROUP_SIZE");
        env::remove_var("MLS_KEY_PACKAGE_TTL_DAYS");
    }
    
    #[test]
    fn test_e2ee_config_defaults() {
        env::remove_var("ENABLE_E2EE");
        
        let config = E2eeConfig::from_env();
        
        assert_eq!(config.enabled, false);
        assert_eq!(config.x3dh_enabled, true);
        assert_eq!(config.double_ratchet_enabled, true);
        assert_eq!(config.max_skipped_message_keys, 1000);
    }
}
