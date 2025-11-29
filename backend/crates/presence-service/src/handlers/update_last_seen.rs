/// Update Last Seen Handler
///
/// Updates the user's last_seen timestamp (heartbeat)

use crate::db::DatabaseClient;
use crate::jwt;
use crate::proto::common::{error_response::ErrorCode, ErrorResponse, Timestamp};
use crate::proto::presence::{
    update_last_seen_response::Result as UpdateLastSeenResult, UpdateLastSeenRequest,
    UpdateLastSeenResponse, UpdateLastSeenSuccess,
};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn handle_update_last_seen(
    request: UpdateLastSeenRequest,
    db: Arc<DatabaseClient>,
    jwt_secret: &str,
) -> Result<Response<UpdateLastSeenResponse>, Status> {
    // Validate JWT token
    let claims = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!("Token validation failed: {}", e);
            return Ok(Response::new(UpdateLastSeenResponse {
                result: Some(UpdateLastSeenResult::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    let user_id = claims.sub;
    let now = chrono::Utc::now().timestamp_millis();

    // Update last_seen in TiKV
    if let Err(e) = db.update_last_seen(&user_id, now).await {
        tracing::error!(user_id = %user_id, error = %e, "Failed to update last_seen in TiKV");
        return Ok(Response::new(UpdateLastSeenResponse {
            result: Some(UpdateLastSeenResult::Error(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to update last seen".to_string(),
                details: Default::default(),
            })),
        }));
    }

    tracing::trace!(user_id = %user_id, "Last seen updated");

    Ok(Response::new(UpdateLastSeenResponse {
        result: Some(UpdateLastSeenResult::Success(UpdateLastSeenSuccess {
            last_seen: Some(Timestamp {
                seconds: now / 1000,
                nanos: ((now % 1000) * 1_000_000) as i32,
            }),
        })),
    }))
}
