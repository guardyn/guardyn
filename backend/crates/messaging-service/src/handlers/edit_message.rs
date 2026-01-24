/// Edit Message Handler (Phase 2)
///
/// Allows users to edit their own messages after sending.
/// Maintains edit version history for audit.
/// RT-002: Broadcasts edit notifications to conversation participants via NATS.

use crate::db::DatabaseClient;
use crate::jwt::validate_access_token;
use crate::nats::NatsClient;
use crate::proto::messaging::{
    EditMessageRequest, EditMessageResponse, EditMessageSuccess,
    edit_message_response,
};
use crate::proto::common::{ErrorResponse, Timestamp, error_response::ErrorCode};
use std::sync::Arc;
use tonic::{Request, Response, Status};
use tracing::{info, warn, error, instrument};

/// Edit a previously sent message
/// RT-002: Broadcasts edit notification to conversation participants via NATS
#[instrument(skip(db, nats, request), fields(user_id, message_id))]
pub async fn edit_message(
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
    request: Request<EditMessageRequest>,
) -> Result<Response<EditMessageResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(EditMessageResponse {
                result: Some(edit_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    let user_id = claims.sub.clone();
    tracing::Span::current().record("user_id", &user_id);
    tracing::Span::current().record("message_id", &req.message_id);
    
    // Validate required fields
    if req.message_id.is_empty() || req.conversation_id.is_empty() {
        return Ok(Response::new(EditMessageResponse {
            result: Some(edit_message_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "message_id and conversation_id are required".to_string(),
                details: Default::default(),
            })),
        }));
    }
    
    if req.encrypted_content.is_empty() {
        return Ok(Response::new(EditMessageResponse {
            result: Some(edit_message_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "encrypted_content is required".to_string(),
                details: Default::default(),
            })),
        }));
    }
    
    // Verify user owns the message
    let message_owner = match db.get_message_owner(
        &req.message_id,
        &req.conversation_id,
        req.is_group,
    ).await {
        Ok(Some(owner)) => owner,
        Ok(None) => {
            return Ok(Response::new(EditMessageResponse {
                result: Some(edit_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "Message not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            error!("Failed to verify message ownership: {}", e);
            return Ok(Response::new(EditMessageResponse {
                result: Some(edit_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to verify message ownership".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    if message_owner != user_id {
        warn!(
            user_id = %user_id,
            message_owner = %message_owner,
            message_id = %req.message_id,
            "User attempted to edit another user's message"
        );
        return Ok(Response::new(EditMessageResponse {
            result: Some(edit_message_response::Result::Error(ErrorResponse {
                code: ErrorCode::Forbidden as i32,
                message: "Cannot edit another user's message".to_string(),
                details: Default::default(),
            })),
        }));
    }
    
    let now = chrono::Utc::now();
    let server_timestamp = Timestamp {
        seconds: now.timestamp(),
        nanos: now.timestamp_subsec_nanos() as i32,
    };
    
    // Update message content and increment edit version
    match db.edit_message(
        &req.message_id,
        &req.conversation_id,
        &user_id,
        &req.encrypted_content,
        req.is_group,
    ).await {
        Ok(new_version) => {
            info!(
                user_id = %user_id,
                message_id = %req.message_id,
                edit_version = new_version,
                "Message edited successfully"
            );
            
            // RT-002: Broadcast edit notification to conversation participants via NATS
            let topic = if req.is_group {
                format!("group.{}.message_edits", req.conversation_id)
            } else {
                format!("conversation.{}.message_edits", req.conversation_id)
            };
            
            let edit_event = serde_json::json!({
                "type": "message_edited",
                "conversation_id": req.conversation_id,
                "message_id": req.message_id,
                "editor_user_id": user_id,
                "edit_version": new_version,
                "is_group": req.is_group,
                "timestamp_seconds": now.timestamp(),
                "timestamp_nanos": now.timestamp_subsec_nanos(),
            });
            
            let payload = serde_json::to_vec(&edit_event).unwrap_or_default();
            if let Err(e) = nats.publish(&topic, &payload).await {
                // Log but don't fail - edit was saved successfully
                warn!(
                    "Failed to broadcast edit notification via NATS: {} (topic={})",
                    e, topic
                );
            } else {
                info!(
                    "Edit notification broadcast to topic: {} for message {}",
                    topic, req.message_id
                );
            }
            
            Ok(Response::new(EditMessageResponse {
                result: Some(edit_message_response::Result::Success(EditMessageSuccess {
                    message_id: req.message_id,
                    edit_version: new_version,
                    server_timestamp: Some(server_timestamp),
                })),
            }))
        }
        Err(e) => {
            error!("Failed to edit message: {}", e);
            Ok(Response::new(EditMessageResponse {
                result: Some(edit_message_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to edit message: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}
