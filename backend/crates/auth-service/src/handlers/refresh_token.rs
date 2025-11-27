/// Refresh token handler - issues new access token

use crate::{AuthServiceImpl, proto::auth::*, proto::common::*};
use tonic::{Request, Response, Status};
use crate::jwt;

pub async fn handle(
    service: &AuthServiceImpl,
    request: Request<RefreshTokenRequest>,
) -> Result<Response<RefreshTokenResponse>, Status> {
    let req = request.into_inner();
    
    // Validate refresh token
    let claims = match jwt::validate_token(&req.refresh_token, &service.jwt_secret) {
        Ok(c) => c,
        Err(_) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Unauthorized as i32,
                message: "Invalid or expired refresh token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RefreshTokenResponse {
                result: Some(refresh_token_response::Result::Error(error)),
            }));
        }
    };
    
    // Check if token type is refresh
    if claims.token_type != Some("refresh".to_string()) {
        let error = ErrorResponse {
            code: error_response::ErrorCode::Unauthorized as i32,
            message: "Invalid token type".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(RefreshTokenResponse {
            result: Some(refresh_token_response::Result::Error(error)),
        }));
    }
    
    // Check if session exists in database
    match service.db.get_session(&req.refresh_token).await {
        Ok(Some(_)) => {},
        Ok(None) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Unauthorized as i32,
                message: "Session not found or expired".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RefreshTokenResponse {
                result: Some(refresh_token_response::Result::Error(error)),
            }));
        }
        Err(e) => {
            tracing::error!("Database error: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Internal server error".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RefreshTokenResponse {
                result: Some(refresh_token_response::Result::Error(error)),
            }));
        }
    }
    
    // Generate new access token
    let access_token = match jwt::generate_access_token(&claims.sub, &claims.device_id, &claims.username, &service.jwt_secret) {
        Ok(token) => token,
        Err(e) => {
            tracing::error!("Failed to generate access token: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to generate token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RefreshTokenResponse {
                result: Some(refresh_token_response::Result::Error(error)),
            }));
        }
    };
    
    // Generate new refresh token as well (rotation)
    let new_refresh_token = match jwt::generate_refresh_token(&claims.sub, &claims.device_id, &claims.username, &service.jwt_secret) {
        Ok(token) => token,
        Err(e) => {
            tracing::error!("Failed to generate new refresh token: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to generate refresh token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(RefreshTokenResponse {
                result: Some(refresh_token_response::Result::Error(error)),
            }));
        }
    };
    
    let success = RefreshTokenSuccess {
        access_token,
        access_token_expires_in: 15 * 60, // 15 minutes
        refresh_token: new_refresh_token,
    };
    
    Ok(Response::new(RefreshTokenResponse {
        result: Some(refresh_token_response::Result::Success(success)),
    }))
}
