/// Common utilities and shared types for Guardyn backend services
pub mod config;
pub mod error;
pub mod observability;

/// Kafka/Redpanda messaging client (feature-gated)
#[cfg(feature = "kafka")]
pub mod kafka;

pub use error::{Error, Result};
