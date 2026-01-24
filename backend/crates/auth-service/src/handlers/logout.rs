/// Logout handler - invalidates session(s)

use crate::{AuthServiceImpl, proto::auth::*, proto::common::*};
use tonic::{Request, Response, Status};

pub async fn handle(
    service: &AuthServiceImpl,
    request: Request<LogoutRequest>,
) -> Result<Response<LogoutResponse>, Status> {
    let req = request.into_inner();
    
    // Validate access token
    let claims = match crate::jwt::validate_token(&req.access_token, &service.jwt_secret) {
        Ok(c) => c,
        Err(_) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Unauthorized as i32,
                message: "Invalid or expired token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(LogoutResponse {
                result: Some(logout_response::Result::Error(error)),
            }));
        }
    };
    
    let sessions_invalidated: u32;
    
    // Logout all devices or just current?
    if req.all_devices {
        // Delete all sessions for this user
        match service.db.delete_all_user_sessions(&claims.sub).await {
            Ok(count) => {
                tracing::info!(
                    user_id = %claims.sub,
                    device_id = %claims.device_id,
                    sessions = count,
                    "Logged out from all devices"
                );
                sessions_invalidated = count;
            }
            Err(e) => {
                tracing::error!(error = %e, "Failed to delete all user sessions");
                let error = ErrorResponse {
                    code: error_response::ErrorCode::InternalError as i32,
                    message: "Failed to logout from all devices".to_string(),
                    details: std::collections::HashMap::new(),
                };
                return Ok(Response::new(LogoutResponse {
                    result: Some(logout_response::Result::Error(error)),
                }));
            }
        }
    } else {
        // Delete current session only
        // The session is identified by device_id in production
        // For now, we'll delete session associated with current device
        match service.db.delete_session_by_device(&claims.sub, &claims.device_id).await {
            Ok(deleted) => {
                sessions_invalidated = if deleted { 1 } else { 0 };
                tracing::info!(
                    user_id = %claims.sub,
                    device_id = %claims.device_id,
                    "Logged out from current device"
                );
            }
            Err(e) => {
                tracing::error!(error = %e, "Failed to delete session");
                let error = ErrorResponse {
                    code: error_response::ErrorCode::InternalError as i32,
                    message: "Failed to logout".to_string(),
                    details: std::collections::HashMap::new(),
                };
                return Ok(Response::new(LogoutResponse {
                    result: Some(logout_response::Result::Error(error)),
                }));
            }
        }
    }
    
    Ok(Response::new(LogoutResponse {
        result: Some(logout_response::Result::Success(LogoutSuccess {
            sessions_invalidated,
        })),
    }))
}
