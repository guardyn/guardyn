//! gRPC client connection management for Guardyn Desktop

use std::sync::Arc;
use parking_lot::RwLock;
use tonic::transport::{Channel, Endpoint};
use tracing::{debug, error, info};

/// gRPC connection configuration
#[derive(Debug, Clone)]
pub struct GrpcConfig {
    /// Base URL for the API gateway (e.g., "https://api.guardyn.local")
    pub endpoint: String,
    /// Connection timeout in seconds
    pub timeout_secs: u64,
    /// Enable TLS
    pub use_tls: bool,
}

impl Default for GrpcConfig {
    fn default() -> Self {
        Self {
            endpoint: "http://localhost:8080".to_string(),
            timeout_secs: 30,
            use_tls: false,
        }
    }
}

/// Manages gRPC channel connections
pub struct GrpcClient {
    config: GrpcConfig,
    channel: RwLock<Option<Channel>>,
    auth_token: RwLock<Option<String>>,
}

impl GrpcClient {
    pub fn new(config: GrpcConfig) -> Self {
        Self {
            config,
            channel: RwLock::new(None),
            auth_token: RwLock::new(None),
        }
    }

    /// Connect to the gRPC server
    pub async fn connect(&self) -> Result<Channel, GrpcError> {
        info!("Connecting to gRPC endpoint: {}", self.config.endpoint);

        let endpoint = Endpoint::from_shared(self.config.endpoint.clone())
            .map_err(|e| GrpcError::InvalidEndpoint(e.to_string()))?
            .timeout(std::time::Duration::from_secs(self.config.timeout_secs))
            .connect_timeout(std::time::Duration::from_secs(10));

        let channel = endpoint
            .connect()
            .await
            .map_err(|e| GrpcError::ConnectionFailed(e.to_string()))?;

        debug!("Successfully connected to gRPC endpoint");
        *self.channel.write() = Some(channel.clone());

        Ok(channel)
    }

    /// Get an existing channel or create a new one
    pub async fn get_channel(&self) -> Result<Channel, GrpcError> {
        if let Some(channel) = self.channel.read().clone() {
            return Ok(channel);
        }
        self.connect().await
    }

    /// Set the authentication token for requests
    pub fn set_auth_token(&self, token: String) {
        *self.auth_token.write() = Some(token);
    }

    /// Get the current auth token
    pub fn get_auth_token(&self) -> Option<String> {
        self.auth_token.read().clone()
    }

    /// Clear the auth token (logout)
    pub fn clear_auth_token(&self) {
        *self.auth_token.write() = None;
    }

    /// Disconnect and clear the channel
    pub fn disconnect(&self) {
        *self.channel.write() = None;
        info!("Disconnected from gRPC endpoint");
    }
}

/// gRPC client errors
#[derive(Debug, thiserror::Error)]
pub enum GrpcError {
    #[error("Invalid endpoint: {0}")]
    InvalidEndpoint(String),

    #[error("Connection failed: {0}")]
    ConnectionFailed(String),

    #[error("Not connected")]
    NotConnected,

    #[error("Request failed: {0}")]
    RequestFailed(String),

    #[error("Authentication required")]
    AuthRequired,
}

// Make error serializable for Tauri
impl serde::Serialize for GrpcError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(&self.to_string())
    }
}
