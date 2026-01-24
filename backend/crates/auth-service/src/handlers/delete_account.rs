/// Delete account handler - permanently deletes user and all associated data
///
/// Flow:
/// 1. Validate access token
/// 2. Get user profile
/// 3. Verify password for security
/// 4. Delete all user data from auth-service (TiKV)
/// 5. TODO: Notify other services to delete user data (messaging, media, presence)
/// 6. Return success confirmation

use crate::{AuthServiceImpl, proto::auth::*, proto::common::*};
use tonic::{Request, Response, Status};
use argon2::{
    password_hash::{PasswordHash, PasswordVerifier},
    Argon2,
};

/// Verify password against stored hash
fn verify_password(password: &str, hash: &str) -> bool {
    let parsed_hash = match PasswordHash::new(hash) {
        Ok(h) => h,
        Err(_) => return false,
    };
    Argon2::default()
        .verify_password(password.as_bytes(), &parsed_hash)
        .is_ok()
}

pub async fn handle(
    service: &AuthServiceImpl,
    request: Request<DeleteAccountRequest>,
) -> Result<Response<DeleteAccountResponse>, Status> {
    let req = request.into_inner();

    // 1. Validate access token
    let claims = match crate::jwt::validate_token(&req.access_token, &service.jwt_secret) {
        Ok(c) => c,
        Err(_) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Unauthorized as i32,
                message: "Invalid or expired token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(DeleteAccountResponse {
                result: Some(delete_account_response::Result::Error(error)),
            }));
        }
    };

    let user_id = claims.sub.clone();

    // 2. Get user profile to verify password
    let user = match service.db.get_user_by_id(&user_id).await {
        Ok(Some(u)) => u,
        Ok(None) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::NotFound as i32,
                message: "User not found".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(DeleteAccountResponse {
                result: Some(delete_account_response::Result::Error(error)),
            }));
        }
        Err(e) => {
            tracing::error!("Database error: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Internal server error".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(DeleteAccountResponse {
                result: Some(delete_account_response::Result::Error(error)),
            }));
        }
    };

    // 3. Verify password for security
    if !verify_password(&req.password, &user.password_hash) {
        let error = ErrorResponse {
            code: error_response::ErrorCode::Unauthorized as i32,
            message: "Incorrect password".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(DeleteAccountResponse {
            result: Some(delete_account_response::Result::Error(error)),
        }));
    }

    // 4. Delete all user data from auth-service
    tracing::info!("Deleting user account: {} ({})", user.username, user_id);
    if let Err(e) = service.db.delete_user(&user_id, &user.username).await {
        tracing::error!("Failed to delete user data: {}", e);
        let error = ErrorResponse {
            code: error_response::ErrorCode::InternalError as i32,
            message: "Failed to delete account data".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(DeleteAccountResponse {
            result: Some(delete_account_response::Result::Error(error)),
        }));
    }

    // 5. Publish user.deleted event for cross-service data deletion
    // Other services (messaging, media, presence) consume this event
    // and delete their data asynchronously (eventual consistency)
    if let Some(ref producer) = service.event_producer {
        use guardyn_common::events::{EventEnvelope, topics, user};

        let payload = user::UserDeletedPayload {
            user_id: user_id.clone(),
            username: user.username.clone(),
            reason: Some("User requested account deletion".to_string()),
            cascade: true,
            delete_data: user::DeleteDataScope::default(),
        };

        let event = EventEnvelope::new(user::TYPE_DELETED, "auth-service", payload);

        match producer.send_json(topics::USER_EVENTS, &user_id, &event).await {
            Ok(_) => {
                tracing::info!(
                    user_id = %user_id,
                    event_id = %event.event_id,
                    "Published user.deleted event for cross-service cleanup"
                );
            }
            Err(e) => {
                // Log error but don't fail the deletion - auth data is already gone
                // Other services will eventually detect orphaned data
                tracing::error!(
                    user_id = %user_id,
                    error = %e,
                    "Failed to publish user.deleted event - manual cleanup may be required"
                );
            }
        }
    } else {
        tracing::warn!(
            user_id = %user_id,
            "No event producer configured - cross-service cleanup skipped"
        );
    }

    tracing::info!("Account deleted for user: {} ({})", user.username, user_id);

    Ok(Response::new(DeleteAccountResponse {
        result: Some(delete_account_response::Result::Success(DeleteAccountSuccess {
            user_id: user_id.clone(),
            message: format!("Account '{}' has been permanently deleted", user.username),
        })),
    }))
}
