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

    tracing::info!("Generating message_id for group message");

    // TEMPORARY: Use UUID v4 instead of v1 for debugging
    // TODO: Switch back to v1 (timeuuid) for proper chronological ordering
    let message_id = uuid::Uuid::new_v4().to_string();
    let server_timestamp_millis = chrono::Utc::now().timestamp_millis();

    tracing::info!("Generated message_id={}, timestamp={}", message_id, server_timestamp_millis);

    // Prepare metadata (empty for MVP)
    let mut metadata = std::collections::HashMap::new();
    metadata.insert("message_type".to_string(), request.message_type.to_string());

    // Store group message in ScyllaDB
    let group_message = crate::models::GroupMessage {
        message_id: message_id.clone(),
        group_id: request.group_id.clone(),
        sender_user_id: sender_user_id.clone(),
        sender_device_id: sender_device_id.clone(),
        encrypted_content: request.encrypted_content.clone(),
        mls_epoch: 0, // TODO: Implement MLS epoch tracking
        sent_at: server_timestamp_millis,
        metadata,
    };

    tracing::info!(
        "HANDLER: About to store group message: message_id={}, group_id={}, sender={}",
        message_id, request.group_id, sender_user_id
    );

    if let Err(e) = db.store_group_message(&group_message).await {
        tracing::error!("Failed to store group message: {} (details: {:?})", e, e);
        return Ok(Response::new(SendGroupMessageResponse {
            result: Some(send_group_message_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to store message".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Get all group members for NATS fanout
    let members = match db.get_group_members(&request.group_id).await {
        Ok(members) => members,
        Err(e) => {
            tracing::error!("Failed to fetch group members: {}", e);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch group members".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Publish message to NATS for each group member (fanout)
    for member in &members {
        // Skip sender - they already have the message
        if member.user_id == sender_user_id {
            continue;
        }

        // Subject pattern: messages.{user_id}.{message_id}
        let subject = format!("messages.{}.{}", member.user_id, message_id);

        // Create message envelope
        let envelope = crate::nats::MessageEnvelope {
            message_id: message_id.clone(),
            sender_user_id: sender_user_id.clone(),
            sender_device_id: sender_device_id.clone(),
            recipient_user_id: member.user_id.clone(),
            encrypted_content: request.encrypted_content.clone(),
            timestamp: server_timestamp_millis / 1000, // Convert millis to seconds for NATS
        };

        // Publish to NATS
        if let Err(e) = nats.publish_message_to_subject(&subject, &envelope).await {
            tracing::error!(
                "Failed to publish group message {} to member {}: {}",
                message_id,
                member.user_id,
                e
            );
            // Don't fail the entire operation if one member's delivery fails
            continue;
        }

        tracing::debug!(
            "Published group message {} to member {}",
            message_id,
            member.user_id
        );
    }

    tracing::info!(
        "Group message {} sent to group {} by {} ({} members)",
        message_id,
        request.group_id,
        sender_user_id,
        members.len()
    );

    Ok(Response::new(SendGroupMessageResponse {
        result: Some(send_group_message_response::Result::Success(
            SendGroupMessageSuccess {
                message_id,
                server_timestamp: Some(Timestamp {
                    seconds: server_timestamp_millis / 1000,
                    nanos: ((server_timestamp_millis % 1000) * 1_000_000) as i32,
                }),
            },
        )),
    }))
}
