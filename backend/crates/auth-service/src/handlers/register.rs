/// User registration handler
///
/// Flow:
/// 1. Validate username (3-32 chars, alphanumeric + _)
/// 2. Check username availability
/// 3. Hash password with Argon2id
/// 4. Generate user_id (UUID)
/// 5. Store user profile in TiKV
/// 6. Store key bundle (X3DH)
/// 7. Create device entry
/// 8. Generate JWT tokens
/// 9. Return success with tokens

use crate::{AuthServiceImpl, proto::auth::*, proto::common::*};
use tonic::{Request, Response, Status};
use uuid::Uuid;
use argon2::{
    password_hash::{rand_core::OsRng, PasswordHasher, SaltString},
    Argon2,
};
use crate::db::{UserProfile, Device, Session, KeyBundle as DbKeyBundle};
use crate::jwt;

pub async fn handle(
    service: &AuthServiceImpl,
    request: Request<RegisterRequest>,
) -> Result<Response<RegisterResponse>, Status> {
    let req = request.into_inner();

    // Validate username
    if !validate_username(&req.username) {
        let error = ErrorResponse {
            code: error_response::ErrorCode::InvalidRequest as i32,
            message: "Username must be 3-32 characters, alphanumeric and underscore only".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(RegisterResponse {
            result: Some(register_response::Result::Error(error)),
        }));
    }

    // Validate password
    if req.password.len() < 12 {
        let error = ErrorResponse {
            code: error_response::ErrorCode::InvalidRequest as i32,
            message: "Password must be at least 12 characters".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(RegisterResponse {
            result: Some(register_response::Result::Error(error)),
        }));
    }

    // Check if username exists
    match service.db.username_exists(&req.username).await {
        Ok(true) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Conflict as i32,
                message: "Username already taken".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RegisterResponse {
                result: Some(register_response::Result::Error(error)),
            }));
        }
        Ok(false) => {},
        Err(e) => {
            tracing::error!("Database error checking username: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Internal server error".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RegisterResponse {
                result: Some(register_response::Result::Error(error)),
            }));
        }
    }

    // Hash password with Argon2id
    let password_hash = match hash_password(&req.password) {
        Ok(hash) => hash,
        Err(e) => {
            tracing::error!("Password hashing error: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Internal server error".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RegisterResponse {
                result: Some(register_response::Result::Error(error)),
            }));
        }
    };

    // Generate user_id
    let user_id = Uuid::new_v4().to_string();
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    // Create user profile
    let profile = UserProfile {
        user_id: user_id.clone(),
        username: req.username.clone(),
        email: if req.email.is_empty() { None } else { Some(req.email.clone()) },
        password_hash,
        created_at: now,
        last_seen: now,
    };

    // Store user in database
    if let Err(e) = service.db.create_user(&profile).await {
        tracing::error!("Failed to create user: {}", e);
        let error = ErrorResponse {
            code: error_response::ErrorCode::InternalError as i32,
            message: "Failed to create user".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(RegisterResponse {
            result: Some(register_response::Result::Error(error)),
        }));
    }

    // Generate device ID
    let device_id = uuid::Uuid::new_v4().to_string();
    
    // Create device entry
    let device = Device {
        device_id: device_id.clone(),
        user_id: user_id.clone(),
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
        let db_key_bundle = DbKeyBundle {
            identity_key: key_bundle.identity_key,
            signed_pre_key: key_bundle.signed_pre_key,
            signed_pre_key_signature: key_bundle.signed_pre_key_signature,
            one_time_pre_keys: key_bundle.one_time_pre_keys,
            created_at: now,
        };

        if let Err(e) = service.db.store_key_bundle(&user_id, &device_id, &db_key_bundle).await {
            tracing::error!("Failed to store key bundle: {}", e);
        }
    }

    // Generate JWT tokens
    let access_token = match jwt::generate_access_token(&user_id, &device_id, &service.jwt_secret) {
        Ok(token) => token,
        Err(e) => {
            tracing::error!("Failed to generate access token: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to generate tokens".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RegisterResponse {
                result: Some(register_response::Result::Error(error)),
            }));
        }
    };

    let refresh_token = match jwt::generate_refresh_token(&user_id, &device_id, &service.jwt_secret) {
        Ok(token) => token,
        Err(e) => {
            tracing::error!("Failed to generate refresh token: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to generate tokens".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RegisterResponse {
                result: Some(register_response::Result::Error(error)),
            }));
        }
    };

    // Create session
    let session = Session {
        session_token: refresh_token.clone(),
        user_id: user_id.clone(),
        device_id: device_id.clone(),
        created_at: now,
        expires_at: now + 30 * 24 * 60 * 60, // 30 days
    };

    if let Err(e) = service.db.create_session(&session).await {
        tracing::error!("Failed to create session: {}", e);
    }

    // Return success response
    let success = RegisterSuccess {
        user_id,
        device_id,
        access_token,
        access_token_expires_in: 15 * 60, // 15 minutes in seconds
        refresh_token,
        refresh_token_expires_in: 30 * 24 * 60 * 60, // 30 days in seconds
        created_at: Some(Timestamp {
            seconds: now,
            nanos: 0,
        }),
    };

    Ok(Response::new(RegisterResponse {
        result: Some(register_response::Result::Success(success)),
    }))
}

/// Validate username format
fn validate_username(username: &str) -> bool {
    if username.len() < 3 || username.len() > 32 {
        return false;
    }

    username.chars().all(|c| c.is_alphanumeric() || c == '_')
}

/// Hash password with Argon2id
fn hash_password(password: &str) -> Result<String, argon2::password_hash::Error> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let hash = argon2.hash_password(password.as_bytes(), &salt)?;
    Ok(hash.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_username() {
        assert!(validate_username("user123"));
        assert!(validate_username("john_doe"));
        assert!(validate_username("abc"));

        assert!(!validate_username("ab")); // too short
        assert!(!validate_username("a".repeat(33).as_str())); // too long
        assert!(!validate_username("user@domain")); // invalid chars
        assert!(!validate_username("user-name")); // invalid chars
    }
}
