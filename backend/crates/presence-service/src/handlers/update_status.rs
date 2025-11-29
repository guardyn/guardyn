/// Update Status Handler
///
/// Updates user's online/offline status

use crate::db::DatabaseClient;
use crate::jwt;
use crate::nats::{NatsClient, PresenceEvent};
use crate::proto::common::{error_response::ErrorCode, ErrorResponse, Timestamp};
use crate::proto::presence::{
    update_status_response::Result as UpdateStatusResult, UpdateStatusRequest,
    UpdateStatusResponse, UpdateStatusSuccess,
};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn handle_update_status(
    request: UpdateStatusRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
    jwt_secret: &str,
) -> Result<Response<UpdateStatusResponse>, Status> {
    // Validate JWT token
    let claims = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!("Token validation failed: {}", e);
            return Ok(Response::new(UpdateStatusResponse {
                result: Some(UpdateStatusResult::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    let user_id = claims.sub;
    let now = chrono::Utc::now().timestamp_millis();

    // Validate custom status text (max 100 chars)
    if request.custom_status_text.len() > 100 {
        return Ok(Response::new(UpdateStatusResponse {
            result: Some(UpdateStatusResult::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Custom status text exceeds 100 characters".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Create or update presence record
    let presence = crate::db::UserPresence {
        user_id: user_id.clone(),
        status: request.status,
        custom_status_text: request.custom_status_text.clone(),
        last_seen: now,
        updated_at: now,
    };

    // Store in TiKV
    if let Err(e) = db.update_presence(&presence).await {
        tracing::error!(user_id = %user_id, error = %e, "Failed to update presence in TiKV");
        return Ok(Response::new(UpdateStatusResponse {
            result: Some(UpdateStatusResult::Error(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to update status".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Publish to NATS for real-time updates
    let event = PresenceEvent {
        user_id: user_id.clone(),
        status: request.status,
        custom_status_text: request.custom_status_text.clone(),
        last_seen: now,
        updated_at: now,
    };

    if let Err(e) = nats.publish_presence_update(&event).await {
        // Log but don't fail - the status was already persisted
        tracing::warn!(user_id = %user_id, error = %e, "Failed to publish presence update to NATS");
    }

    tracing::info!(user_id = %user_id, status = request.status, "Status updated");

    Ok(Response::new(UpdateStatusResponse {
        result: Some(UpdateStatusResult::Success(UpdateStatusSuccess {
            status: request.status,
            updated_at: Some(Timestamp {
                seconds: now / 1000,
                nanos: ((now % 1000) * 1_000_000) as i32,
            }),
        })),
    }))
}
