/// Handler for sending 1-on-1 messages
use crate::db::DatabaseClient;
use crate::models::{DeliveryState, DeliveryStatus, StoredMessage};
use crate::nats::{MessageEnvelope, NatsClient};
use crate::proto::messaging::{
    send_message_response, SendMessageRequest, SendMessageResponse, SendMessageSuccess,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};
use uuid::Uuid;

pub async fn send_message(
    request: SendMessageRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
) -> Result<Response<SendMessageResponse>, Status> {
    // Validate JWT token and extract user_id + device_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (sender_user_id, sender_device_id, sender_username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok((user_id, device_id, username)) => (user_id, device_id, username),
        Err(_) => {
            return Ok(Response::new(SendMessageResponse {
                result: Some(send_message_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate recipient
    if request.recipient_user_id.is_empty() {
        return Ok(Response::new(SendMessageResponse {
            result: Some(send_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Recipient user ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate encrypted content
    if request.encrypted_content.is_empty() {
        return Ok(Response::new(SendMessageResponse {
            result: Some(send_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Encrypted content required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Generate message ID
    let message_id = Uuid::new_v4().to_string();
    let server_timestamp = chrono::Utc::now().timestamp();

    // Generate conversation ID (deterministic based on participants)
    let conversation_id = generate_conversation_id(
        &sender_user_id,
        &request.recipient_user_id,
    );

    // Create stored message
    let stored_msg = StoredMessage {
        message_id: message_id.clone(),
        conversation_id: conversation_id.clone(),
        sender_user_id: sender_user_id.clone(),
        sender_device_id: sender_device_id.clone(),
        recipient_user_id: request.recipient_user_id.clone(),
        recipient_device_id: if request.recipient_device_id.is_empty() {
            None
        } else {
            Some(request.recipient_device_id.clone())
        },
        encrypted_content: request.encrypted_content.clone(),
        message_type: request.message_type,
        server_timestamp,
        client_timestamp: request
            .client_timestamp
            .as_ref()
            .map(|ts| ts.seconds)
            .unwrap_or(server_timestamp),
        delivery_status: DeliveryStatus::Pending.to_i32(),
        is_deleted: false,
    };

    // Debug: log stored message before saving
    tracing::debug!("Attempting to store message: conversation_id={}, message_id={}, sender={}, recipient={}",
        stored_msg.conversation_id, stored_msg.message_id,
        stored_msg.sender_user_id, stored_msg.recipient_user_id);

    // Store message in ScyllaDB
    if let Err(e) = db.store_message(&stored_msg).await {
        tracing::error!("Failed to store message in ScyllaDB: {:?}", e);
        tracing::error!("Detailed error: {}", e);
        if let Some(source) = e.source() {
            tracing::error!("Error source: {:?}", source);
        }
        return Ok(Response::new(SendMessageResponse {
            result: Some(send_message_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: format!("Failed to store message: {}", e),
                details: Default::default(),
            })),
        }));
    }

    // Create delivery state in TiKV
    let delivery_state = DeliveryState {
        message_id: message_id.clone(),
        sender_user_id: sender_user_id.clone(),
        sender_device_id: sender_device_id.clone(),
        recipient_user_id: request.recipient_user_id.clone(),
        recipient_device_id: stored_msg.recipient_device_id.clone(),
        status: DeliveryStatus::Pending,
        created_at: server_timestamp,
        updated_at: server_timestamp,
    };

    if let Err(e) = db.store_delivery_state(&delivery_state).await {
        tracing::error!("Failed to store delivery state: {}", e);
        // Continue anyway - message is stored
    }

    // Update conversations table for both sender and recipient
    // This enables efficient conversation list queries
    let message_preview = if stored_msg.encrypted_content.len() > 100 {
        "[Encrypted message]".to_string()
    } else {
        "[Message]".to_string()
    };
    let server_timestamp_ms = server_timestamp * 1000; // Convert to milliseconds

    // Update sender's conversation view (unread_count = 0 for sender)
    if let Err(e) = db.upsert_conversation(
        &sender_user_id,
        &conversation_id,
        &request.recipient_user_id,
        &request.recipient_username, // Use recipient username from request
        &message_id,
        &message_preview,
        server_timestamp_ms,
        false, // sender doesn't increment unread
    ).await {
        tracing::warn!("Failed to update sender conversation: {}", e);
    }

    // Update recipient's conversation view (increment unread_count)
    if let Err(e) = db.upsert_conversation(
        &request.recipient_user_id,
        &conversation_id,
        &sender_user_id,
        &sender_username, // Use sender username from JWT
        &message_id,
        &message_preview,
        server_timestamp_ms,
        true, // recipient increments unread
    ).await {
        tracing::warn!("Failed to update recipient conversation: {}", e);
    }

    // Publish to NATS for real-time delivery
    let envelope = MessageEnvelope {
        message_id: message_id.clone(),
        sender_user_id: sender_user_id.clone(),
        sender_device_id: sender_device_id.clone(),
        recipient_user_id: request.recipient_user_id.clone(),
        encrypted_content: request.encrypted_content,
        timestamp: server_timestamp,
    };

    if let Err(e) = nats.publish_message(&envelope).await {
        tracing::error!("Failed to publish message to NATS: {}", e);
        // Continue anyway - message is stored and can be delivered later
    }

    // Return success
    Ok(Response::new(SendMessageResponse {
        result: Some(send_message_response::Result::Success(
            SendMessageSuccess {
                message_id,
                server_timestamp: Some(Timestamp {
                    seconds: server_timestamp,
                    nanos: 0,
                }),
                delivery_status: DeliveryStatus::Sent.to_i32(),
            },
        )),
    }))
}

/// Generate deterministic conversation ID from two user IDs
fn generate_conversation_id(user1: &str, user2: &str) -> String {
    // Sort user IDs to ensure consistency regardless of sender/recipient order
    let mut users = vec![user1, user2];
    users.sort();

    // Use namespace UUID v5 to generate deterministic conversation ID
    let namespace = Uuid::parse_str("00000000-0000-0000-0000-000000000000").unwrap();
    let data = format!("{}:{}", users[0], users[1]);
    Uuid::new_v5(&namespace, data.as_bytes()).to_string()
}
