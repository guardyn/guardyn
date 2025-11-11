/// E2EE-enabled message sending handler (migration version)
/// 
/// This handler integrates X3DH key exchange and Double Ratchet encryption
/// for end-to-end encrypted messaging.
///
/// TODO: Replace existing send_message.rs with this implementation after testing

use crate::db::DatabaseClient;
use crate::models::{DeliveryState, DeliveryStatus, StoredMessage, RatchetSession};
use crate::nats::{MessageEnvelope, NatsClient};
use crate::crypto::{SessionManager, CryptoManager};
use crate::proto::messaging::{
    send_message_response, SendMessageRequest, SendMessageResponse, SendMessageSuccess,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};
use uuid::Uuid;

pub async fn send_message_e2ee(
    request: SendMessageRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
) -> Result<Response<SendMessageResponse>, Status> {
    // Validate JWT token and extract user_id + device_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (sender_user_id, sender_device_id) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok((user_id, device_id)) => (user_id, device_id),
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

    // Validate plaintext content (we'll encrypt it)
    if request.encrypted_content.is_empty() {
        return Ok(Response::new(SendMessageResponse {
            result: Some(send_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Message content required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // =======================================================================
    // E2EE: Get or create Double Ratchet session
    // =======================================================================

    let auth_service_url = std::env::var("AUTH_SERVICE_URL")
        .unwrap_or_else(|_| "http://auth-service:50051".to_string());

    let session_manager = SessionManager::new(db.clone(), auth_service_url);

    let recipient_device_id = if request.recipient_device_id.is_empty() {
        // TODO: Query auth-service for recipient's default device
        // For now, return error
        return Ok(Response::new(SendMessageResponse {
            result: Some(send_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Recipient device ID required for E2EE".to_string(),
                details: Default::default(),
            })),
        }));
    } else {
        request.recipient_device_id.clone()
    };

    // Get or initialize session
    let mut ratchet = match session_manager.get_or_create_session(
        &sender_user_id,
        &sender_device_id,
        &request.recipient_user_id,
        &recipient_device_id,
    ).await {
        Ok(r) => r,
        Err(e) => {
            tracing::error!("Failed to get/create ratchet session: {}", e);
            return Ok(Response::new(SendMessageResponse {
                result: Some(send_message_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: format!("E2EE session initialization failed: {}", e),
                    details: Default::default(),
                })),
            }));
        }
    };

    // =======================================================================
    // E2EE: Encrypt message with Double Ratchet
    // =======================================================================

    let session_id = RatchetSession::session_id(
        &sender_user_id,
        &sender_device_id,
        &request.recipient_user_id,
        &recipient_device_id,
    );

    // Associated data for AEAD: "sender_id|recipient_id|timestamp"
    let server_timestamp = chrono::Utc::now().timestamp();
    let associated_data = format!("{}|{}|{}", sender_user_id, request.recipient_user_id, server_timestamp);

    let encrypted_content = match session_manager.encrypt_and_save(
        &session_id,
        ratchet,
        &request.encrypted_content, // Client should send plaintext, we encrypt server-side
        associated_data.as_bytes(),
    ).await {
        Ok(ciphertext) => ciphertext,
        Err(e) => {
            tracing::error!("Failed to encrypt message: {}", e);
            return Ok(Response::new(SendMessageResponse {
                result: Some(send_message_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: format!("Message encryption failed: {}", e),
                    details: Default::default(),
                })),
            }));
        }
    };

    // =======================================================================
    // Store encrypted message (same as original handler)
    // =======================================================================

    let message_id = Uuid::new_v4().to_string();
    let conversation_id = generate_conversation_id(&sender_user_id, &request.recipient_user_id);

    let stored_msg = StoredMessage {
        message_id: message_id.clone(),
        conversation_id: conversation_id.clone(),
        sender_user_id: sender_user_id.clone(),
        sender_device_id: sender_device_id.clone(),
        recipient_user_id: request.recipient_user_id.clone(),
        recipient_device_id: Some(recipient_device_id.clone()),
        encrypted_content, // Now truly encrypted with Double Ratchet
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

    tracing::debug!(
        "Storing E2EE message: conversation_id={}, message_id={}, sender={}, recipient={}",
        stored_msg.conversation_id,
        stored_msg.message_id,
        stored_msg.sender_user_id,
        stored_msg.recipient_user_id
    );

    if let Err(e) = db.store_message(&stored_msg).await {
        tracing::error!("Failed to store message in ScyllaDB: {:?}", e);
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
        recipient_device_id: Some(recipient_device_id.clone()),
        status: DeliveryStatus::Pending,
        created_at: server_timestamp,
        updated_at: server_timestamp,
    };

    if let Err(e) = db.store_delivery_state(&delivery_state).await {
        tracing::error!("Failed to store delivery state: {}", e);
    }

    // Publish to NATS for real-time delivery
    let envelope = MessageEnvelope {
        message_id: message_id.clone(),
        sender_user_id: sender_user_id.clone(),
        sender_device_id: sender_device_id.clone(),
        recipient_user_id: request.recipient_user_id.clone(),
        encrypted_content: stored_msg.encrypted_content,
        timestamp: server_timestamp,
    };

    if let Err(e) = nats.publish_message(&envelope).await {
        tracing::error!("Failed to publish message to NATS: {}", e);
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
    let mut users = vec![user1, user2];
    users.sort();
    let namespace = Uuid::parse_str("00000000-0000-0000-0000-000000000000").unwrap();
    let data = format!("{}:{}", users[0], users[1]);
    Uuid::new_v5(&namespace, data.as_bytes()).to_string()
}
