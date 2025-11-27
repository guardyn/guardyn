/// User login handler
///
/// Flow:
/// 1. Validate credentials (username + password)
/// 2. Verify password hash
/// 3. Check/create device entry
/// 4. Generate JWT tokens
/// 5. Create session
/// 6. Return tokens + device list

use crate::{AuthServiceImpl, proto::auth::*, proto::common::*};
use tonic::{Request, Response, Status};
use argon2::{
    password_hash::{PasswordHash, PasswordVerifier},
    Argon2,
};
use crate::db::{Device, Session};
use crate::jwt;

pub async fn handle(
    service: &AuthServiceImpl,
    request: Request<LoginRequest>,
) -> Result<Response<LoginResponse>, Status> {
    let req = request.into_inner();
    
    // Get user by username
    let user = match service.db.get_user_by_username(&req.username).await {
        Ok(Some(u)) => u,
        Ok(None) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::NotFound as i32,
                message: "Invalid username or password".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(LoginResponse {
                result: Some(login_response::Result::Error(error)),
            }));
        }
        Err(e) => {
            tracing::error!("Database error: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Internal server error".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(LoginResponse {
                result: Some(login_response::Result::Error(error)),
            }));
        }
    };
    
    // Verify password
    if !verify_password(&req.password, &user.password_hash) {
        let error = ErrorResponse {
            code: error_response::ErrorCode::Unauthorized as i32,
            message: "Invalid username or password".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(LoginResponse {
            result: Some(login_response::Result::Error(error)),
        }));
    }
    
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;
    
    // Check if device exists, create if new
    let device_id = req.device_id.clone();
    if let Ok(None) = service.db.get_device(&user.user_id, &device_id).await {
        let device = Device {
            device_id: device_id.clone(),
            user_id: user.user_id.clone(),
            device_name: req.device_name.clone(),
            device_type: req.device_type.clone(),
            created_at: now,
            last_seen: now,
        };
        
        if let Err(e) = service.db.create_device(&device).await {
            tracing::error!("Failed to create device: {}", e);
        }
        
        // Store key bundle if provided
        if let Some(key_bundle) = req.key_bundle {
            let db_key_bundle = crate::db::KeyBundle {
                identity_key: key_bundle.identity_key,
                signed_pre_key: key_bundle.signed_pre_key,
                signed_pre_key_signature: key_bundle.signed_pre_key_signature,
                one_time_pre_keys: key_bundle.one_time_pre_keys,
                created_at: now,
            };
            
            if let Err(e) = service.db.store_key_bundle(&user.user_id, &device_id, &db_key_bundle).await {
                tracing::error!("Failed to store key bundle: {}", e);
            }
        }
    }
    
    // Generate JWT tokens
    let access_token = match jwt::generate_access_token(&user.user_id, &device_id, &user.username, &service.jwt_secret) {
        Ok(token) => token,
        Err(e) => {
            tracing::error!("Failed to generate access token: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to generate tokens".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(LoginResponse {
                result: Some(login_response::Result::Error(error)),
            }));
        }
    };
    
    let refresh_token = match jwt::generate_refresh_token(&user.user_id, &device_id, &user.username, &service.jwt_secret) {
        Ok(token) => token,
        Err(e) => {
            tracing::error!("Failed to generate refresh token: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to generate tokens".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(LoginResponse {
                result: Some(login_response::Result::Error(error)),
            }));
        }
    };
    
    // Create session
    let session = Session {
        session_token: refresh_token.clone(),
        user_id: user.user_id.clone(),
        device_id: device_id.clone(),
        created_at: now,
        expires_at: now + 30 * 24 * 60 * 60, // 30 days
    };
    
    if let Err(e) = service.db.create_session(&session).await {
        tracing::error!("Failed to create session: {}", e);
    }
    
    // TODO: Get list of user's devices
    let devices = vec![
        DeviceInfo {
            device_id: device_id.clone(),
            device_name: req.device_name.clone(),
            device_type: req.device_type.clone(),
            created_at: Some(Timestamp {
                seconds: now,
                nanos: 0,
            }),
            last_seen: Some(Timestamp {
                seconds: now,
                nanos: 0,
            }),
            is_current: true,
        }
    ];
    
    // User profile
    let profile = Some(UserProfile {
        user_id: user.user_id.clone(),
        username: user.username.clone(),
        email: user.email.clone().unwrap_or_default(),
        created_at: Some(Timestamp {
            seconds: now,
            nanos: 0,
        }),
        last_seen: Some(Timestamp {
            seconds: now,
            nanos: 0,
        }),
    });
    
    // Return success response
    let success = LoginSuccess {
        user_id: user.user_id,
        device_id,
        access_token,
        access_token_expires_in: 15 * 60, // 15 minutes in seconds
        refresh_token,
        refresh_token_expires_in: 30 * 24 * 60 * 60, // 30 days in seconds
        profile,
        devices,
    };
    
    Ok(Response::new(LoginResponse {
        result: Some(login_response::Result::Success(success)),
    }))
}

/// Verify password against hash
fn verify_password(password: &str, hash: &str) -> bool {
    let parsed_hash = match PasswordHash::new(hash) {
        Ok(h) => h,
        Err(_) => return false,
    };
    
    Argon2::default()
        .verify_password(password.as_bytes(), &parsed_hash)
        .is_ok()
}
