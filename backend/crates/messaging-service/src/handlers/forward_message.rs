/// Forward Message Handler (Phase 2)
///
/// Handles forwarding messages between conversations.
/// Preserves forward metadata (original sender, timestamp, forward count).
use crate::db::DatabaseClient;
use crate::jwt::validate_access_token;
use crate::proto::common::{error_response::ErrorCode, ErrorResponse, Timestamp};
use crate::proto::messaging::{
    forward_message_response, ForwardInfo, ForwardMessageRequest, ForwardMessageResponse,
    ForwardMessageSuccess,
};
use std::sync::Arc;
use tonic::{Request, Response, Status};
use tracing::{error, info, instrument, warn};
use uuid::Uuid;

/// Forward a message to another conversation
#[instrument(
    skip(db, request),
    fields(user_id, source_message_id, target_conversation_id)
)]
pub async fn forward_message(
    db: Arc<DatabaseClient>,
    request: Request<ForwardMessageRequest>,
) -> Result<Response<ForwardMessageResponse>, Status> {
    let req = request.into_inner();

    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(ForwardMessageResponse {
                result: Some(forward_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    let user_id = claims.sub.clone();
    let device_id = claims.device_id.clone();

    tracing::Span::current().record("user_id", &user_id);
    tracing::Span::current().record("source_message_id", &req.source_message_id);
    tracing::Span::current().record("target_conversation_id", &req.target_conversation_id);

    // Validate required fields
    if req.source_message_id.is_empty() || req.target_conversation_id.is_empty() {
        return Ok(Response::new(ForwardMessageResponse {
            result: Some(forward_message_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "source_message_id and target_conversation_id are required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    if req.encrypted_content.is_empty() {
        return Ok(Response::new(ForwardMessageResponse {
            result: Some(forward_message_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "encrypted_content is required (re-encrypted for target)".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Fetch original message metadata for forward info
    let original_message = match db
        .get_message_metadata(
            &req.source_message_id,
            &req.source_conversation_id,
            req.source_is_group,
        )
        .await
    {
        Ok(Some(msg)) => msg,
        Ok(None) => {
            return Ok(Response::new(ForwardMessageResponse {
                result: Some(forward_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "Source message not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            error!("Failed to fetch source message: {}", e);
            return Ok(Response::new(ForwardMessageResponse {
                result: Some(forward_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to fetch source message: {}", e),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Build forward info
    let forward_info = ForwardInfo {
        original_message_id: req.source_message_id.clone(),
        original_sender_id: original_message.sender_user_id.clone(),
        original_sender_name: original_message.sender_username.clone(),
        original_timestamp: original_message.server_timestamp,
        forward_count: original_message.forward_count + 1,
    };

    // Generate new message ID
    let new_message_id = Uuid::new_v4().to_string();
    let now = chrono::Utc::now();
    let server_timestamp = Timestamp {
        seconds: now.timestamp(),
        nanos: now.timestamp_subsec_nanos() as i32,
    };

    // Store forwarded message
    let result = if req.target_is_group {
        db.store_forwarded_group_message(
            &new_message_id,
            &req.target_conversation_id,
            &user_id,
            &device_id,
            &req.encrypted_content,
            original_message.message_type,
            &req.client_message_id,
            &forward_info,
        )
        .await
    } else {
        db.store_forwarded_message(
            &new_message_id,
            &req.target_conversation_id,
            &user_id,
            &device_id,
            &req.target_user_id,
            &req.encrypted_content,
            original_message.message_type,
            &req.client_message_id,
            &forward_info,
        )
        .await
    };

    match result {
        Ok(_) => {
            info!(
                user_id = %user_id,
                source_message_id = %req.source_message_id,
                new_message_id = %new_message_id,
                target_conversation_id = %req.target_conversation_id,
                forward_count = forward_info.forward_count,
                "Message forwarded successfully"
            );

            Ok(Response::new(ForwardMessageResponse {
                result: Some(forward_message_response::Result::Success(
                    ForwardMessageSuccess {
                        message_id: new_message_id,
                        server_timestamp: Some(server_timestamp),
                    },
                )),
            }))
        }
        Err(e) => {
            error!("Failed to store forwarded message: {}", e);
            Ok(Response::new(ForwardMessageResponse {
                result: Some(forward_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to forward message: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}
