//! WebSocket Commands
//!
//! Provides WebSocket configuration and URL management for the frontend.
//! The actual WebSocket connection is handled in the frontend, but the
//! backend provides configuration (URL, token injection, etc.).

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

/// WebSocket configuration for the frontend
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebSocketConfig {
    /// WebSocket server URL
    pub url: String,
    /// Whether to use stub mode (for development)
    pub stub_mode: bool,
    /// JWT token for authentication
    pub token: Option<String>,
    /// Device ID for multi-device support
    pub device_id: Option<String>,
    /// Heartbeat interval in milliseconds
    pub ping_interval_ms: u64,
    /// Connection timeout in milliseconds
    pub connection_timeout_ms: u64,
}

impl Default for WebSocketConfig {
    fn default() -> Self {
        Self {
            url: "wss://ws.guardyn.local/ws".to_string(),
            stub_mode: cfg!(debug_assertions), // Stub mode in debug builds
            token: None,
            device_id: None,
            ping_interval_ms: 30_000,
            connection_timeout_ms: 90_000,
        }
    }
}

/// Get the config directory path
fn get_config_dir() -> Option<PathBuf> {
    // Use platform-specific config directory
    #[cfg(target_os = "linux")]
    {
        std::env::var("XDG_CONFIG_HOME")
            .map(PathBuf::from)
            .ok()
            .or_else(|| {
                std::env::var("HOME")
                    .map(|h| PathBuf::from(h).join(".config"))
                    .ok()
            })
            .map(|p| p.join("guardyn"))
    }

    #[cfg(target_os = "macos")]
    {
        std::env::var("HOME")
            .map(|h| {
                PathBuf::from(h)
                    .join("Library")
                    .join("Application Support")
                    .join("guardyn")
            })
            .ok()
    }

    #[cfg(target_os = "windows")]
    {
        std::env::var("APPDATA")
            .map(|a| PathBuf::from(a).join("guardyn"))
            .ok()
    }

    #[cfg(not(any(target_os = "linux", target_os = "macos", target_os = "windows")))]
    {
        None
    }
}

/// Get WebSocket configuration
///
/// Returns the configuration needed to connect to the WebSocket server.
/// In development, this uses stub mode. In production, it connects to
/// the real backend.
#[tauri::command]
pub async fn get_websocket_config() -> Result<WebSocketConfig, String> {
    tracing::debug!("Getting WebSocket configuration");

    // Get environment-based configuration
    let ws_url = std::env::var("GUARDYN_WS_URL")
        .unwrap_or_else(|_| "wss://ws.guardyn.local/ws".to_string());

    let stub_mode = std::env::var("GUARDYN_WS_STUB")
        .map(|v| v == "true" || v == "1")
        .unwrap_or(cfg!(debug_assertions));

    // Get device ID from persistent storage or generate new one
    let device_id = get_or_create_device_id().await?;

    Ok(WebSocketConfig {
        url: ws_url,
        stub_mode,
        token: None, // Token should be fetched separately after auth
        device_id: Some(device_id),
        ping_interval_ms: 30_000,
        connection_timeout_ms: 90_000,
    })
}

/// Get WebSocket URL with authentication token
///
/// Returns the WebSocket URL with the current JWT token injected.
/// This is used when reconnecting or refreshing the connection.
#[tauri::command]
pub async fn get_websocket_url_with_token(token: String) -> Result<String, String> {
    tracing::debug!("Getting WebSocket URL with token");

    let ws_url = std::env::var("GUARDYN_WS_URL")
        .unwrap_or_else(|_| "wss://ws.guardyn.local/ws".to_string());

    // We don't embed the token in the URL for security reasons.
    // Instead, we return the URL and the frontend handles authentication
    // via the WebSocket protocol (sending auth message after connection).
    Ok(ws_url)
}

/// Get or create a persistent device ID
async fn get_or_create_device_id() -> Result<String, String> {
    // Try to read from persistent storage
    let config_dir = get_config_dir()
        .ok_or_else(|| "Could not determine config directory".to_string())?;

    let device_id_path = config_dir.join("device_id");

    // Check if device ID already exists
    if device_id_path.exists() {
        match tokio::fs::read_to_string(&device_id_path).await {
            Ok(content) => {
                let id: String = content.trim().to_string();
                if !id.is_empty() {
                    tracing::debug!("Using existing device ID");
                    return Ok(id);
                }
            }
            Err(e) => {
                tracing::warn!("Failed to read device ID: {}", e);
            }
        }
    }

    // Generate new device ID
    let device_id = uuid::Uuid::new_v4().to_string();

    // Save to persistent storage
    if let Err(e) = tokio::fs::create_dir_all(&config_dir).await {
        tracing::warn!("Failed to create config directory: {}", e);
    }

    if let Err(e) = tokio::fs::write(&device_id_path, &device_id).await {
        tracing::warn!("Failed to save device ID: {}", e);
    }

    tracing::debug!("Generated new device ID");
    Ok(device_id)
}

/// WebSocket connection status
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebSocketStatus {
    /// Current connection state
    pub state: String,
    /// Last error message if any
    pub last_error: Option<String>,
    /// Number of reconnection attempts
    pub reconnect_attempts: u32,
    /// Latency in milliseconds (if connected)
    pub latency_ms: Option<u32>,
}

/// Report WebSocket status from frontend
///
/// This command allows the frontend to report WebSocket connection status
/// back to the backend for logging and monitoring purposes.
#[tauri::command]
pub async fn report_websocket_status(status: WebSocketStatus) -> Result<(), String> {
    match status.state.as_str() {
        "connected" => {
            if let Some(latency) = status.latency_ms {
                tracing::info!("WebSocket connected (latency: {}ms)", latency);
            } else {
                tracing::info!("WebSocket connected");
            }
        }
        "disconnected" => {
            if let Some(error) = &status.last_error {
                tracing::warn!("WebSocket disconnected: {}", error);
            } else {
                tracing::info!("WebSocket disconnected");
            }
        }
        "reconnecting" => {
            tracing::info!(
                "WebSocket reconnecting (attempt {})",
                status.reconnect_attempts
            );
        }
        state => {
            tracing::debug!("WebSocket state: {}", state);
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_default_config() {
        let config = WebSocketConfig::default();
        assert!(!config.url.is_empty());
        assert!(config.ping_interval_ms > 0);
        assert!(config.connection_timeout_ms > 0);
    }

    #[tokio::test]
    async fn test_get_websocket_config() {
        let result = get_websocket_config().await;
        assert!(result.is_ok());
        let config = result.unwrap();
        assert!(!config.url.is_empty());
    }
}
