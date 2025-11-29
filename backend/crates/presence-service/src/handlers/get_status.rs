/// Get Status Handler
///
/// Gets a single user's presence status

use crate::db::DatabaseClient;
use crate::jwt;
use crate::proto::common::{error_response::ErrorCode, ErrorResponse, Timestamp};
use crate::proto::presence::{
    get_status_response::Result as GetStatusResult, GetStatusRequest, GetStatusResponse,
    GetStatusSuccess,
};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn handle_get_status(
    request: GetStatusRequest,
    db: Arc<DatabaseClient>,
    jwt_secret: &str,
) -> Result<Response<GetStatusResponse>, Status> {
    // Validate JWT token
    let claims = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!("Token validation failed: {}", e);
            return Ok(Response::new(GetStatusResponse {
                result: Some(GetStatusResult::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    let requester_id = claims.sub;
    let target_user_id = &request.user_id;

    // Get presence from TiKV
    let presence = match db.get_presence(target_user_id).await {
        Ok(Some(p)) => p,
        Ok(None) => {
            // User exists but no presence record - return offline
            tracing::debug!(target_user_id = %target_user_id, "No presence record found, returning offline");
            return Ok(Response::new(GetStatusResponse {
                result: Some(GetStatusResult::Success(GetStatusSuccess {
                    user_id: target_user_id.clone(),
                    status: 0, // OFFLINE
                    custom_status_text: String::new(),
                    last_seen: None,
                    is_typing: false,
                })),
            }));
        }
        Err(e) => {
            tracing::error!(target_user_id = %target_user_id, error = %e, "Failed to get presence from TiKV");
            return Ok(Response::new(GetStatusResponse {
                result: Some(GetStatusResult::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to get user status".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Check if the target user is typing to the requester
    let is_typing = match db.get_typing(target_user_id, &requester_id).await {
        Ok(Some(_)) => true,
        Ok(None) => false,
        Err(e) => {
            tracing::warn!(error = %e, "Failed to get typing indicator, assuming not typing");
            false
        }
    };

    // Handle INVISIBLE status - appear offline to others
    let (status, custom_status) = if presence.status == 4 {
        // INVISIBLE
        (0, String::new()) // Return OFFLINE, hide custom status
    } else {
        (presence.status, presence.custom_status_text.clone())
    };

    tracing::debug!(
        requester_id = %requester_id,
        target_user_id = %target_user_id,
        status = status,
        "Got user status"
    );

    Ok(Response::new(GetStatusResponse {
        result: Some(GetStatusResult::Success(GetStatusSuccess {
            user_id: target_user_id.clone(),
            status,
            custom_status_text: custom_status,
            last_seen: Some(Timestamp {
                seconds: presence.last_seen / 1000,
                nanos: ((presence.last_seen % 1000) * 1_000_000) as i32,
            }),
            is_typing,
        })),
    }))
}
