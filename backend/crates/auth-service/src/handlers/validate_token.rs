/// Token validation handler - internal use by other services

use crate::{AuthServiceImpl, proto::auth::*, proto::common::*};
use tonic::{Request, Response, Status};
use crate::jwt;

pub async fn handle(
    service: &AuthServiceImpl,
    request: Request<ValidateTokenRequest>,
) -> Result<Response<ValidateTokenResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match jwt::validate_token(&req.access_token, &service.jwt_secret) {
        Ok(c) => c,
        Err(_) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Unauthorized as i32,
                message: "Invalid or expired token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(ValidateTokenResponse {
                result: Some(validate_token_response::Result::Error(error)),
            }));
        }
    };
    
    // Check if it's an access token
    if claims.token_type != Some("access".to_string()) {
        let error = ErrorResponse {
            code: error_response::ErrorCode::Unauthorized as i32,
            message: "Invalid token type".to_string(),
            details: std::collections::HashMap::new(),
        };
        return Ok(Response::new(ValidateTokenResponse {
            result: Some(validate_token_response::Result::Error(error)),
        }));
    }
    
    // Return user info
    let success = ValidateTokenSuccess {
        user_id: claims.sub,
        device_id: claims.device_id,
        expires_at: Some(crate::proto::common::Timestamp {
            seconds: claims.exp,
            nanos: 0,
        }),
        permissions: claims.permissions,
    };
    
    Ok(Response::new(ValidateTokenResponse {
        result: Some(validate_token_response::Result::Success(success)),
    }))
}
