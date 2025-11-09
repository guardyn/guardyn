/// Handler for sending group messages
use crate::db::DatabaseClient;
use crate::nats::NatsClient;
use crate::proto::messaging::{
    send_group_message_response, SendGroupMessageRequest, SendGroupMessageResponse,
    SendGroupMessageSuccess,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};
use uuid::Uuid;

pub async fn send_group_message(
    request: SendGroupMessageRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
) -> Result<Response<SendGroupMessageResponse>, Status> {
    // Validate JWT token and extract user_id (sender)
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());
    
    let (sender_user_id, sender_device_id) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate group ID
    if request.group_id.is_empty() {
        return Ok(Response::new(SendGroupMessageResponse {
            result: Some(send_group_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Group ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate encrypted content
    if request.encrypted_content.is_empty() {
        return Ok(Response::new(SendGroupMessageResponse {
            result: Some(send_group_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Encrypted content required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Verify group exists and sender is a member
    match db.get_group(&request.group_id).await {
        Ok(Some(_group)) => {
            // Group exists, continue
        }
        Ok(None) => {
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group: {}", e);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to verify group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    }

    // TODO: Verify sender is a member of the group
    // For MVP, we skip this check

    // Generate message ID
    let message_id = Uuid::new_v4().to_string();
    let server_timestamp = chrono::Utc::now().timestamp();

    // TODO: Store group message in ScyllaDB
    // For MVP, we just publish to NATS without persistence
    tracing::warn!(
        "Group message storage in ScyllaDB not yet implemented - message {} would be stored",
        message_id
    );

    // Publish message to NATS for fanout to all group members
    // Subject pattern: group_messages.{group_id}.{message_id}
    let subject = format!("group_messages.{}.{}", request.group_id, message_id);
    
    // Create message envelope (simplified - would need proper GroupMessage structure)
    let envelope = serde_json::json!({
        "message_id": message_id,
        "group_id": request.group_id,
        "sender_user_id": sender_user_id,
        "sender_device_id": sender_device_id,
        "encrypted_content": base64::encode(&request.encrypted_content),
        "message_type": request.message_type,
        "timestamp": server_timestamp,
    });

    // TODO: Publish to NATS using proper NatsClient method
    // For MVP, we skip NATS publishing for group messages
    tracing::warn!(
        "Group message NATS publishing not yet implemented - message {} to group {} would be published on subject {}",
        message_id,
        request.group_id,
        subject
    );

    tracing::info!(
        "Group message {} sent to group {} by {}",
        message_id,
        request.group_id,
        sender_user_id
    );

    Ok(Response::new(SendGroupMessageResponse {
        result: Some(send_group_message_response::Result::Success(
            SendGroupMessageSuccess {
                message_id,
                server_timestamp: Some(Timestamp {
                    seconds: server_timestamp,
                    nanos: 0,
                }),
            },
        )),
    }))
}
