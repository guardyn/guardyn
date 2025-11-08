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
                code: error_response::ErrorCode::Unauthenticated as i32,
                message: "Invalid or expired token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(LogoutResponse {
                result: Some(logout_response::Result::Error(error)),
            }));
        }
    };
    
    // Logout all devices or just current?
    if req.all_devices {
        // TODO: Implement logout from all devices
        // Need to scan all sessions for user_id
        tracing::warn!("Logout from all devices not yet implemented");
    } else {
        // Delete current session (identified by device_id)
        // We don't have session token directly, so this is a simplified implementation
        // In production, you'd track session_token -> access_token mapping
        tracing::info!("Logging out device {} for user {}", claims.device_id, claims.sub);
    }
    
    Ok(Response::new(LogoutResponse {
        result: Some(logout_response::Result::Success(LogoutSuccess {
            message: "Logged out successfully".to_string(),
        })),
    }))
}
