/// Common utilities and shared types for Guardyn backend services
pub mod config;
pub mod error;
pub mod events;
pub mod observability;
pub mod rate_limit;
pub mod rate_limit_middleware;

/// Kafka/Redpanda messaging client (feature-gated)
#[cfg(feature = "kafka")]
pub mod kafka;

pub use error::{Error, Result};
pub use rate_limit::{RateLimitConfig, RateLimitError, RateLimiter, RateLimiters};
pub use rate_limit_middleware::{RateLimitLayer, RateLimitService};
