/// E2EE-enabled message receiving handler (migration version)
///
/// This handler integrates Double Ratchet decryption for incoming encrypted messages.
///
/// TODO: Replace existing receive_messages.rs with this implementation after testing

use crate::db::DatabaseClient;
use crate::nats::{NatsClient, MessageEnvelope};
use crate::models::RatchetSession;
use crate::crypto::SessionManager;
use futures::StreamExt; // For async iterator on NATS Batch
use crate::proto::messaging::{Message, MessageType, DeliveryStatus, ReceiveMessagesRequest};
use crate::proto::common::Timestamp;
use std::sync::Arc;
use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use tonic::{Response, Status};

const BATCH_SIZE: usize = 10;
const POLL_INTERVAL_MS: u64 = 500;

/// Handle ReceiveMessages streaming RPC with E2EE decryption
pub async fn receive_messages_e2ee(
    request: ReceiveMessagesRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
) -> Result<Response<ReceiverStream<Result<Message, Status>>>, Status> {
    // Validate access token and extract user_id + device_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (user_id, device_id, _username) = crate::jwt::validate_and_extract(&request.access_token, &jwt_secret)?;

    tracing::info!("User {} ({}) connected to E2EE message stream", user_id, device_id);

    let (tx, rx) = mpsc::channel::<Result<Message, Status>>(32);

    tokio::spawn(async move {
        if let Err(e) = stream_messages_e2ee(
            user_id.clone(),
            device_id.clone(),
            request.include_history,
            db,
            nats,
            tx.clone(),
        )
        .await
        {
            tracing::error!("E2EE message streaming error for user {}: {}", user_id, e);
            let _ = tx.send(Err(Status::internal("Message streaming error"))).await;
        }
    });

    Ok(Response::new(ReceiverStream::new(rx)))
}

/// Main E2EE message streaming logic
async fn stream_messages_e2ee(
    user_id: String,
    device_id: String,
    include_history: bool,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
    tx: mpsc::Sender<Result<Message, Status>>,
) -> anyhow::Result<()> {
    let auth_service_url = std::env::var("AUTH_SERVICE_URL")
        .unwrap_or_else(|_| "http://auth-service:50051".to_string());

    let session_manager = SessionManager::new(db.clone(), auth_service_url);

    // Step 1: Send offline/pending messages first if requested
    if include_history {
        tracing::info!("Fetching pending E2EE messages for user {}", user_id);

        match db.get_pending_messages(&user_id).await {
            Ok(pending_messages) => {
                tracing::info!("Found {} pending messages to decrypt", pending_messages.len());

                for delivery_state in pending_messages {
                    // Get corresponding stored message with encrypted content
                    let stored_msg = match db.get_message(&delivery_state.message_id).await {
                        Ok(Some(msg)) => msg,
                        Ok(None) => {
                            tracing::warn!("Message {} not found in storage", delivery_state.message_id);
                            continue;
                        }
                        Err(e) => {
                            tracing::error!("Failed to fetch message {}: {}", delivery_state.message_id, e);
                            continue;
                        }
                    };

                    // =======================================================================
                    // E2EE: Decrypt message with Double Ratchet
                    // =======================================================================

                    let session_id = RatchetSession::session_id(
                        &user_id,
                        &device_id,
                        &stored_msg.sender_user_id,
                        &stored_msg.sender_device_id,
                    );

                    // Get ratchet session
                    let mut ratchet = match session_manager.get_or_create_session(
                        &user_id,
                        &device_id,
                        &stored_msg.sender_user_id,
                        &stored_msg.sender_device_id,
                    ).await {
                        Ok(r) => r,
                        Err(e) => {
                            tracing::error!("Failed to get ratchet session for message {}: {}",
                                delivery_state.message_id, e);
                            continue;
                        }
                    };

                    // Associated data must match sender's
                    let associated_data = format!(
                        "{}|{}|{}",
                        stored_msg.sender_user_id,
                        stored_msg.recipient_user_id,
                        stored_msg.server_timestamp
                    );

                    // Decrypt message
                    let decrypted_content = match session_manager.decrypt_and_save(
                        &session_id,
                        ratchet,
                        &stored_msg.encrypted_content,
                        associated_data.as_bytes(),
                    ).await {
                        Ok(plaintext) => plaintext,
                        Err(e) => {
                            tracing::error!("Failed to decrypt message {}: {}",
                                delivery_state.message_id, e);
                            // Send error indication or skip message
                            continue;
                        }
                    };

                    // Create message with decrypted content
                    let message = Message {
                        message_id: delivery_state.message_id.clone(),
                        sender_user_id: delivery_state.sender_user_id.clone(),
                        sender_device_id: delivery_state.sender_device_id.clone(),
                        recipient_user_id: user_id.clone(),
                        recipient_device_id: device_id.clone(),
                        encrypted_content: decrypted_content, // Now contains plaintext
                        message_type: stored_msg.message_type,
                        client_message_id: "".to_string(),
                        client_timestamp: Some(Timestamp {
                            seconds: stored_msg.client_timestamp,
                            nanos: 0,
                        }),
                        server_timestamp: Some(Timestamp {
                            seconds: stored_msg.server_timestamp,
                            nanos: 0,
                        }),
                        delivery_status: DeliveryStatus::Delivered as i32,
                        is_deleted: false,
                        media_id: "".to_string(),
                        x3dh_prekey: "".to_string(), // Empty for stored messages
                    };

                    // Send decrypted message to client
                    if tx.send(Ok(message)).await.is_err() {
                        tracing::warn!("Client disconnected during offline message delivery");
                        return Ok(());
                    }

                    // Update delivery status
                    if let Err(e) = db.update_delivery_status(
                        &delivery_state.message_id,
                        crate::models::DeliveryStatus::Delivered,
                    ).await {
                        tracing::error!("Failed to update delivery status: {}", e);
                    }
                }
            }
            Err(e) => {
                tracing::error!("Failed to fetch pending messages: {}", e);
            }
        }
    }

    // Step 2: Subscribe to NATS for real-time messages
    tracing::info!("Subscribing to real-time E2EE messages for user {}", user_id);

    let subject = format!("messages.{}", user_id);
    let consumer_name = format!("consumer_{}_{}", user_id, device_id);

    let consumer = match nats.create_consumer(&consumer_name, &subject).await {
        Ok(c) => c,
        Err(e) => {
            tracing::error!("Failed to create NATS consumer: {}", e);
            return Err(e);
        }
    };

    // Poll NATS for new messages
    loop {
        match consumer.fetch().max_messages(BATCH_SIZE).messages().await {
            Ok(mut messages) => {
                while let Some(Ok(msg)) = messages.next().await {
                    // Parse message envelope
                    let envelope: MessageEnvelope = match serde_json::from_slice(&msg.payload) {
                        Ok(e) => e,
                        Err(e) => {
                            tracing::error!("Failed to parse message envelope: {}", e);
                            let _ = msg.ack().await;
                            continue;
                        }
                    };

                    // =======================================================================
                    // E2EE: Decrypt real-time message
                    // =======================================================================

                    let session_id = RatchetSession::session_id(
                        &user_id,
                        &device_id,
                        &envelope.sender_user_id,
                        &envelope.sender_device_id,
                    );

                    let mut ratchet = match session_manager.get_or_create_session(
                        &user_id,
                        &device_id,
                        &envelope.sender_user_id,
                        &envelope.sender_device_id,
                    ).await {
                        Ok(r) => r,
                        Err(e) => {
                            tracing::error!("Failed to get ratchet session: {}", e);
                            let _ = msg.ack().await;
                            continue;
                        }
                    };

                    let associated_data = format!(
                        "{}|{}|{}",
                        envelope.sender_user_id,
                        user_id,
                        envelope.timestamp
                    );

                    let decrypted_content = match session_manager.decrypt_and_save(
                        &session_id,
                        ratchet,
                        &envelope.encrypted_content,
                        associated_data.as_bytes(),
                    ).await {
                        Ok(plaintext) => plaintext,
                        Err(e) => {
                            tracing::error!("Failed to decrypt real-time message: {}", e);
                            let _ = msg.ack().await;
                            continue;
                        }
                    };

                    // Send decrypted message to client
                    let message = Message {
                        message_id: envelope.message_id.clone(),
                        sender_user_id: envelope.sender_user_id,
                        sender_device_id: envelope.sender_device_id,
                        recipient_user_id: user_id.clone(),
                        recipient_device_id: device_id.clone(),
                        encrypted_content: decrypted_content,
                        message_type: MessageType::Text as i32,
                        client_message_id: "".to_string(),
                        client_timestamp: None,
                        server_timestamp: Some(Timestamp {
                            seconds: envelope.timestamp,
                            nanos: 0,
                        }),
                        delivery_status: DeliveryStatus::Delivered as i32,
                        is_deleted: false,
                        media_id: "".to_string(),
                        x3dh_prekey: envelope.x3dh_prekey.clone().unwrap_or_default(),
                    };

                    if tx.send(Ok(message)).await.is_err() {
                        tracing::info!("Client disconnected from E2EE stream");
                        return Ok(());
                    }

                    // Acknowledge message
                    let _ = msg.ack().await;
                }
            }
            Err(e) => {
                tracing::error!("NATS fetch error: {}", e);
                tokio::time::sleep(tokio::time::Duration::from_millis(POLL_INTERVAL_MS)).await;
            }
        }

        // Rate limiting
        tokio::time::sleep(tokio::time::Duration::from_millis(POLL_INTERVAL_MS)).await;
    }
}
