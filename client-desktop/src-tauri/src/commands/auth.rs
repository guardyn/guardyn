//! Authentication Commands
//!
//! Handles user authentication, registration, and session management.

use crate::proto::common::{KeyBundle, Timestamp};
use crate::state::AppState;
use guardyn_crypto::x3dh::X3DHProtocol;
use serde::{Deserialize, Serialize};
use tauri::State;

#[derive(Debug, Serialize, Deserialize)]
pub struct UserInfo {
    pub user_id: String,
    pub username: String,
    pub display_name: Option<String>,
    pub avatar_url: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RegisterRequest {
    pub username: String,
    pub password: String,
    pub display_name: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AuthResponse {
    pub success: bool,
    pub user: Option<UserInfo>,
    pub token: Option<String>,
    pub error: Option<String>,
}

/// Generate a key bundle for registration/login
fn generate_key_bundle() -> Result<KeyBundle, String> {
    tracing::debug!("Generating key bundle...");
    let bundle = X3DHProtocol::generate_key_bundle()
        .map_err(|e| {
            tracing::error!("Failed to generate key bundle: {}", e);
            format!("Failed to generate key bundle: {}", e)
        })?;
    
    tracing::debug!("Key bundle generated successfully");
    Ok(KeyBundle {
        identity_key: bundle.identity_key,
        signed_pre_key: bundle.signed_pre_key,
        signed_pre_key_signature: bundle.signed_pre_key_signature,
        one_time_pre_keys: bundle.one_time_pre_keys
            .into_iter()
            .map(|k| k.public_key)
            .collect(),
        created_at: Some(Timestamp {
            seconds: chrono::Utc::now().timestamp(),
            nanos: 0,
        }),
    })
}

/// Login with username and password
#[tauri::command]
pub async fn login(
    request: LoginRequest,
    state: State<'_, AppState>,
) -> Result<AuthResponse, String> {
    tracing::info!("Login attempt for user: {}", request.username);

    // Generate key bundle for device registration
    // Key bundle is REQUIRED for E2EE messaging - each device must have its own keys
    let key_bundle = match generate_key_bundle() {
        Ok(bundle) => {
            tracing::info!("Key bundle generated successfully for login");
            Some(bundle)
        }
        Err(e) => {
            tracing::error!("Failed to generate key bundle for login: {}", e);
            // Continue with login but warn that E2EE won't work
            tracing::warn!("Login will proceed but E2EE messaging may not work without key bundle");
            None
        }
    };

    // Call the auth service
    match state.auth().login(
        request.username.clone(),
        request.password,
        None, // device_id - will be assigned by server
        "Guardyn Desktop".to_string(),
        "desktop".to_string(),
        key_bundle,
    ).await {
        Ok(result) => {
            // Store session in state
            state.set_authenticated(true);
            state.set_user_id(Some(result.user_id.clone()));
            state.set_device_id(Some(result.device_id.clone()));
            state.set_access_token(Some(result.access_token.clone()));
            state.set_refresh_token(Some(result.refresh_token.clone()));
            
            // Set token expiration time
            let expires_at = std::time::Instant::now() 
                + std::time::Duration::from_secs(result.access_token_expires_in as u64);
            state.set_token_expires_at(Some(expires_at));

            // Update gRPC client with auth token
            state.grpc().set_auth_token(result.access_token.clone());

            // Start incoming calls subscription
            state.call_manager().clone().start_incoming_calls_subscription();

            tracing::info!(
                "Login successful for user: {}, device: {}",
                result.user_id,
                result.device_id
            );

            let user_info = UserInfo {
                user_id: result.user_id,
                username: result.profile.as_ref()
                    .map(|p| p.username.clone())
                    .unwrap_or(request.username),
                display_name: result.profile.as_ref()
                    .map(|p| p.username.clone()),
                avatar_url: None,
            };

            Ok(AuthResponse {
                success: true,
                user: Some(user_info),
                token: Some(result.access_token),
                error: None,
            })
        }
        Err(e) => {
            tracing::warn!("Login failed: {:?}", e);
            Ok(AuthResponse {
                success: false,
                user: None,
                token: None,
                error: Some(e.to_string()),
            })
        }
    }
}

/// Register a new user
#[tauri::command]
pub async fn register(
    request: RegisterRequest,
    state: State<'_, AppState>,
) -> Result<AuthResponse, String> {
    tracing::info!("Registration attempt for user: {}", request.username);

    // Generate crypto key bundle for E2EE
    tracing::debug!("Generating key bundle for registration...");
    let key_bundle = generate_key_bundle()
        .map_err(|e| {
            tracing::error!("Key bundle generation failed: {}", e);
            format!("Failed to generate key bundle: {}", e)
        })?;
    tracing::debug!("Key bundle generated, calling auth service...");

    // Call the auth service
    match state.auth().register(
        request.username.clone(),
        request.password,
        None, // email
        "Guardyn Desktop".to_string(),
        "desktop".to_string(),
        key_bundle,
    ).await {
        Ok(result) => {
            tracing::info!(
                "Registration successful for user: {}, device: {}",
                request.username,
                result.device_id
            );
            // Store session in state
            state.set_authenticated(true);
            state.set_user_id(Some(result.user_id.clone()));
            state.set_device_id(Some(result.device_id.clone()));
            state.set_access_token(Some(result.access_token.clone()));
            state.set_refresh_token(Some(result.refresh_token.clone()));
            
            // Set token expiration time
            let expires_at = std::time::Instant::now() 
                + std::time::Duration::from_secs(result.access_token_expires_in as u64);
            state.set_token_expires_at(Some(expires_at));

            // Update gRPC client with auth token
            state.grpc().set_auth_token(result.access_token.clone());

            // Start incoming calls subscription
            state.call_manager().clone().start_incoming_calls_subscription();

            let user_info = UserInfo {
                user_id: result.user_id,
                username: request.username,
                display_name: request.display_name,
                avatar_url: None,
            };

            Ok(AuthResponse {
                success: true,
                user: Some(user_info),
                token: Some(result.access_token),
                error: None,
            })
        }
        Err(e) => {
            tracing::warn!("Registration failed: {:?}", e);
            Ok(AuthResponse {
                success: false,
                user: None,
                token: None,
                error: Some(e.to_string()),
            })
        }
    }
}

/// Logout current user
#[tauri::command]
pub async fn logout(state: State<'_, AppState>) -> Result<(), String> {
    tracing::info!("User logging out");

    // Call the auth service to invalidate session
    if let Err(e) = state.auth().logout(false).await {
        tracing::warn!("Logout request failed (continuing anyway): {:?}", e);
    }

    // Clear local state
    state.set_authenticated(false);
    state.clear_session();
    state.grpc().clear_auth_token();

    Ok(())
}

/// Get current authenticated user
#[tauri::command]
pub async fn get_current_user(state: State<'_, AppState>) -> Result<Option<UserInfo>, String> {
    if !state.is_authenticated() {
        return Ok(None);
    }

    // Return cached user info from state
    if let Some(user_id) = state.user_id() {
        Ok(Some(UserInfo {
            user_id,
            username: "".to_string(), // Will be fetched from profile
            display_name: None,
            avatar_url: None,
        }))
    } else {
        Ok(None)
    }
}

/// WebSocket connection configuration
#[derive(Debug, Serialize, Deserialize)]
pub struct WebSocketConfig {
    pub url: String,
    pub token: Option<String>,
    pub device_id: Option<String>,
    pub user_id: Option<String>,
}

/// Refresh access token response
#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RefreshTokenResponse {
    pub success: bool,
    pub access_token: Option<String>,
    pub expires_in: Option<u32>,
    pub error: Option<String>,
}

/// Refresh the access token using the stored refresh token
#[tauri::command]
pub async fn refresh_token(state: State<'_, AppState>) -> Result<RefreshTokenResponse, String> {
    tracing::info!("Refreshing access token");

    let refresh_token = match state.refresh_token() {
        Some(token) => token,
        None => {
            tracing::warn!("No refresh token available");
            return Ok(RefreshTokenResponse {
                success: false,
                access_token: None,
                expires_in: None,
                error: Some("No refresh token available".to_string()),
            });
        }
    };

    match state.auth().refresh_token(refresh_token).await {
        Ok(tokens) => {
            // Update stored tokens
            state.set_access_token(Some(tokens.access_token.clone()));
            state.set_refresh_token(Some(tokens.refresh_token));
            
            // Set expiration time
            let expires_at = std::time::Instant::now() 
                + std::time::Duration::from_secs(tokens.access_token_expires_in as u64);
            state.set_token_expires_at(Some(expires_at));

            // Update gRPC client with new auth token
            state.grpc().set_auth_token(tokens.access_token.clone());

            tracing::info!("Token refreshed successfully");

            Ok(RefreshTokenResponse {
                success: true,
                access_token: Some(tokens.access_token),
                expires_in: Some(tokens.access_token_expires_in),
                error: None,
            })
        }
        Err(e) => {
            tracing::error!("Token refresh failed: {:?}", e);
            
            // Clear session on refresh failure
            state.set_authenticated(false);
            state.clear_session();
            state.grpc().clear_auth_token();

            Ok(RefreshTokenResponse {
                success: false,
                access_token: None,
                expires_in: None,
                error: Some(e.to_string()),
            })
        }
    }
}

/// Get WebSocket connection configuration
/// Returns the token and device ID needed for WebSocket authentication
/// Automatically refreshes token if expired
#[tauri::command]
pub async fn get_ws_config(state: State<'_, AppState>) -> Result<WebSocketConfig, String> {
    // Check if token needs refresh
    if state.is_token_expired() {
        tracing::info!("Token expired, attempting refresh before WebSocket connection");
        if let Some(refresh_token) = state.refresh_token() {
            match state.auth().refresh_token(refresh_token).await {
                Ok(tokens) => {
                    state.set_access_token(Some(tokens.access_token.clone()));
                    state.set_refresh_token(Some(tokens.refresh_token));
                    let expires_at = std::time::Instant::now() 
                        + std::time::Duration::from_secs(tokens.access_token_expires_in as u64);
                    state.set_token_expires_at(Some(expires_at));
                    state.grpc().set_auth_token(tokens.access_token);
                    tracing::info!("Token refreshed for WebSocket connection");
                }
                Err(e) => {
                    tracing::error!("Failed to refresh token for WebSocket: {:?}", e);
                    // Continue with expired token - WebSocket will fail and client can handle
                }
            }
        }
    }

    // Get WebSocket URL from environment or use default for local development
    let ws_host = std::env::var("WS_HOST").unwrap_or_else(|_| "localhost".to_string());
    let ws_port = std::env::var("WS_PORT").unwrap_or_else(|_| "8081".to_string());
    let ws_secure = std::env::var("WS_SECURE").unwrap_or_else(|_| "false".to_string());
    
    let protocol = if ws_secure == "true" { "wss" } else { "ws" };
    let url = format!("{}://{}:{}/ws", protocol, ws_host, ws_port);
    
    Ok(WebSocketConfig {
        url,
        token: state.access_token(),
        device_id: state.device_id(),
        user_id: state.user_id(),
    })
}
