/// ReceiveMessages handler - Server-side streaming for real-time message delivery
use crate::db::DatabaseClient;
use crate::nats::{NatsClient, MessageEnvelope};
use crate::proto::messaging::{Message, MessageType, DeliveryStatus, ReceiveMessagesRequest};
use crate::proto::common::Timestamp;
use std::sync::Arc;
use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use tonic::{Response, Status};
use async_nats::jetstream::consumer::PullConsumer;

/// Maximum messages to fetch per batch from NATS
const BATCH_SIZE: usize = 10;

/// Poll interval for new messages (in milliseconds)
const POLL_INTERVAL_MS: u64 = 500;

/// Handle ReceiveMessages streaming RPC
///
/// This handler:
/// 1. Validates the access token
/// 2. Optionally sends offline/pending messages first
/// 3. Creates a NATS consumer for the user
/// 4. Continuously polls NATS for new messages
/// 5. Streams messages to the client in real-time
pub async fn receive_messages(
    request: ReceiveMessagesRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
) -> Result<Response<ReceiverStream<Result<Message, Status>>>, Status> {
    // Validate access token and extract user_id + device_id
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (user_id, device_id, _username) = crate::jwt::validate_and_extract(&request.access_token, &jwt_secret)?;

    tracing::info!("User {} ({}) connected to message stream", user_id, device_id);

    // Create channel for streaming messages
    let (tx, rx) = mpsc::channel::<Result<Message, Status>>(32);

    // Spawn background task to handle message streaming
    tokio::spawn(async move {
        if let Err(e) = stream_messages(
            user_id.clone(),
            device_id.clone(),
            request.include_history,
            db,
            nats,
            tx.clone(),
        )
        .await
        {
            tracing::error!("Message streaming error for user {}: {}", user_id, e);
            let _ = tx.send(Err(Status::internal("Message streaming error"))).await;
        }
    });

    Ok(Response::new(ReceiverStream::new(rx)))
}

/// Main message streaming logic
async fn stream_messages(
    user_id: String,
    device_id: String,
    include_history: bool,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
    tx: mpsc::Sender<Result<Message, Status>>,
) -> anyhow::Result<()> {
    // Step 1: Send offline/pending messages first if requested
    if include_history {
        tracing::info!("Fetching pending messages for user {}", user_id);

        match db.get_pending_messages(&user_id).await {
            Ok(pending_messages) => {
                tracing::info!("Found {} pending messages", pending_messages.len());

                for delivery_state in pending_messages {
                    // Convert delivery state to Message
                    let message = Message {
                        message_id: delivery_state.message_id.clone(),
                        sender_user_id: delivery_state.sender_user_id.clone(),
                        sender_device_id: delivery_state.sender_device_id.clone(),
                        recipient_user_id: user_id.clone(),
                        recipient_device_id: device_id.clone(),
                        encrypted_content: vec![], // TODO: Fetch from ScyllaDB
                        message_type: MessageType::Text as i32,
                        client_message_id: "".to_string(),
                        client_timestamp: None,
                        server_timestamp: Some(Timestamp {
                            seconds: delivery_state.created_at / 1000,
                            nanos: ((delivery_state.created_at % 1000) * 1_000_000) as i32,
                        }),
                        delivery_status: convert_delivery_status(&delivery_state.status),
                        is_deleted: false,
                        media_id: "".to_string(),
                        x3dh_prekey: "".to_string(), // TODO: Fetch from ScyllaDB with message content
                    };

                    // Send to client
                    if tx.send(Ok(message)).await.is_err() {
                        tracing::warn!("Client disconnected while sending pending messages");
                        return Ok(());
                    }

                    // Update delivery status to "Sent"
                    let _ = db
                        .update_delivery_status(
                            &delivery_state.message_id,
                            crate::models::DeliveryStatus::Sent,
                        )
                        .await;
                }
            }
            Err(e) => {
                tracing::error!("Failed to fetch pending messages: {}", e);
            }
        }
    }

    // Step 2: Create NATS consumer for real-time messages
    let consumer = nats
        .subscribe_to_messages(&user_id)
        .await
        .map_err(|e| anyhow::anyhow!("Failed to create NATS consumer: {}", e))?;

    tracing::info!("Subscribed to NATS messages for user {}", user_id);

    // Step 3: Continuously poll NATS for new messages
    loop {
        match poll_nats_messages(&consumer, &nats, &db, &user_id, &device_id, &tx).await {
            Ok(true) => {
                // Client disconnected
                tracing::info!("Client {} disconnected from stream", user_id);
                break;
            }
            Ok(false) => {
                // Continue polling
            }
            Err(e) => {
                tracing::error!("Error polling NATS messages: {}", e);
                // Wait before retrying
                tokio::time::sleep(tokio::time::Duration::from_millis(POLL_INTERVAL_MS)).await;
            }
        }

        // Wait before next poll
        tokio::time::sleep(tokio::time::Duration::from_millis(POLL_INTERVAL_MS)).await;
    }

    Ok(())
}

/// Poll NATS consumer for new messages
///
/// Returns:
/// - Ok(true) if client disconnected
/// - Ok(false) if successful poll
/// - Err if error occurred
async fn poll_nats_messages(
    consumer: &PullConsumer,
    nats: &NatsClient,
    db: &DatabaseClient,
    user_id: &str,
    device_id: &str,
    tx: &mpsc::Sender<Result<Message, Status>>,
) -> anyhow::Result<bool> {
    let envelopes = nats.fetch_messages(consumer, BATCH_SIZE).await?;

    if envelopes.is_empty() {
        return Ok(false);
    }

    tracing::debug!("Received {} messages from NATS", envelopes.len());

    for envelope in envelopes {
        // Convert NATS envelope to protobuf Message
        let message = Message {
            message_id: envelope.message_id.clone(),
            sender_user_id: envelope.sender_user_id.clone(),
            sender_device_id: envelope.sender_device_id.clone(),
            recipient_user_id: user_id.to_string(),
            recipient_device_id: device_id.to_string(),
            encrypted_content: envelope.encrypted_content.clone(),
            message_type: MessageType::Text as i32,
            client_message_id: "".to_string(),
            client_timestamp: None,
            server_timestamp: Some(Timestamp {
                seconds: envelope.timestamp / 1000,
                nanos: ((envelope.timestamp % 1000) * 1_000_000) as i32,
            }),
            delivery_status: DeliveryStatus::Delivered as i32,
            is_deleted: false,
            media_id: "".to_string(),
            x3dh_prekey: envelope.x3dh_prekey.clone().unwrap_or_default(),
        };

        // Send message to client
        if tx.send(Ok(message)).await.is_err() {
            tracing::warn!("Client disconnected during streaming");
            return Ok(true); // Client disconnected
        }

        // Update delivery status in TiKV
        let _ = db
            .update_delivery_status(&envelope.message_id, crate::models::DeliveryStatus::Delivered)
            .await;

        tracing::debug!("Delivered message {} to client {}", envelope.message_id, user_id);
    }

    Ok(false)
}
fn convert_delivery_status(status: &crate::models::DeliveryStatus) -> i32 {
    match status {
        crate::models::DeliveryStatus::Pending => DeliveryStatus::Pending as i32,
        crate::models::DeliveryStatus::Sent => DeliveryStatus::Sent as i32,
        crate::models::DeliveryStatus::Delivered => DeliveryStatus::Delivered as i32,
        crate::models::DeliveryStatus::Read => DeliveryStatus::Read as i32,
        crate::models::DeliveryStatus::Failed => DeliveryStatus::Failed as i32,
    }
}
