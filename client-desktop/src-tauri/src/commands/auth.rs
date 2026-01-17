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
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize)]
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
    let bundle = X3DHProtocol::generate_key_bundle()
        .map_err(|e| format!("Failed to generate key bundle: {}", e))?;
    
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
    let key_bundle = generate_key_bundle().ok();

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
            state.set_access_token(Some(result.access_token.clone()));

            // Update gRPC client with auth token
            state.grpc().set_auth_token(result.access_token.clone());

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
    let key_bundle = generate_key_bundle()
        .map_err(|e| format!("Failed to generate key bundle: {}", e))?;

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
            // Store session in state
            state.set_authenticated(true);
            state.set_user_id(Some(result.user_id.clone()));
            state.set_access_token(Some(result.access_token.clone()));

            // Update gRPC client with auth token
            state.grpc().set_auth_token(result.access_token.clone());

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
