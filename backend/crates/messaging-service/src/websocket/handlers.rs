/// WebSocket Message Handlers
///
/// Handles incoming WebSocket messages and generates appropriate responses.
/// Integrates with the database and NATS for message persistence and fanout.

use std::sync::Arc;
use tracing::{debug, error, info, warn};
use uuid::Uuid;

use crate::db::DatabaseClient;
use crate::jwt;
use crate::nats::NatsClient;

use super::connection::ConnectionManager;
use super::messages::*;

/// Generate deterministic conversation ID from two user IDs
fn generate_conversation_id(user1: &str, user2: &str) -> String {
    let mut users = vec![user1, user2];
    users.sort();
    let namespace = Uuid::parse_str("00000000-0000-0000-0000-000000000000").unwrap();
    let data = format!("{}:{}", users[0], users[1]);
    Uuid::new_v5(&namespace, data.as_bytes()).to_string()
}

/// Context for handling WebSocket messages
pub struct WsContext {
    pub connection_id: String,
    pub connection_manager: Arc<ConnectionManager>,
    pub db: Arc<DatabaseClient>,
    pub nats: Arc<NatsClient>,
    pub jwt_secret: String,
}

impl WsContext {
    pub fn new(
        connection_id: String,
        connection_manager: Arc<ConnectionManager>,
        db: Arc<DatabaseClient>,
        nats: Arc<NatsClient>,
        jwt_secret: String,
    ) -> Self {
        Self {
            connection_id,
            connection_manager,
            db,
            nats,
            jwt_secret,
        }
    }
}

/// Handle an incoming WebSocket message
pub async fn handle_message(ctx: &WsContext, message: WsMessage) -> Option<WsMessage> {
    ctx.connection_manager.update_activity(&ctx.connection_id);

    match message {
        WsMessage::Auth(auth) => Some(handle_auth(ctx, auth).await),
        WsMessage::Ping(ping) => Some(WsMessage::pong_from_ping(&ping)),
        WsMessage::SendMessage(send) => handle_send_message(ctx, send).await,
        WsMessage::MarkRead(mark_read) => handle_mark_read(ctx, mark_read).await,
        WsMessage::Typing(typing) => handle_typing(ctx, typing).await,
        WsMessage::Subscribe(sub) => handle_subscribe(ctx, sub).await,
        WsMessage::Unsubscribe(unsub) => handle_unsubscribe(ctx, unsub).await,
        // Ignore messages that are server-to-client only
        WsMessage::AuthResponse(_)
        | WsMessage::Message(_)
        | WsMessage::MessageSent(_)
        | WsMessage::Presence(_)
        | WsMessage::ReadReceipt(_)
        | WsMessage::Pong(_)
        | WsMessage::Error(_) => {
            debug!(
                connection_id = %ctx.connection_id,
                "Ignoring server-to-client message type"
            );
            None
        }
    }
}

/// Handle authentication message
async fn handle_auth(ctx: &WsContext, auth: AuthMessage) -> WsMessage {
    // Validate JWT token
    match jwt::validate_token(&auth.token, &ctx.jwt_secret) {
        Ok(claims) => {
            let user_id = claims.sub;

            // Authenticate the connection
            if let Err(e) = ctx.connection_manager.authenticate_connection(
                &ctx.connection_id,
                user_id.clone(),
                auth.device_id,
            ) {
                error!(
                    connection_id = %ctx.connection_id,
                    error = %e,
                    "Failed to authenticate connection"
                );
                return WsMessage::AuthResponse(AuthResponse {
                    success: false,
                    user_id: None,
                    error: Some(e.to_string()),
                });
            }

            info!(
                connection_id = %ctx.connection_id,
                user_id = %user_id,
                "WebSocket connection authenticated"
            );

            // Publish presence update via NATS
            let presence_msg = PresencePayload {
                user_id: user_id.clone(),
                status: "online".to_string(),
                last_seen: None,
            };
            if let Ok(json) = serde_json::to_vec(&WsMessage::Presence(presence_msg)) {
                let subject = format!("presence.{}", user_id);
                if let Err(e) = ctx.nats.publish_raw(&subject, json.into()).await {
                    warn!(error = %e, "Failed to publish presence update");
                }
            }

            WsMessage::AuthResponse(AuthResponse {
                success: true,
                user_id: Some(user_id),
                error: None,
            })
        }
        Err(e) => {
            warn!(
                connection_id = %ctx.connection_id,
                error = %e,
                "JWT validation failed"
            );
            WsMessage::AuthResponse(AuthResponse {
                success: false,
                user_id: None,
                error: Some("Invalid or expired token".to_string()),
            })
        }
    }
}

/// Handle send message request
async fn handle_send_message(ctx: &WsContext, send: SendMessagePayload) -> Option<WsMessage> {
    // Ensure connection is authenticated
    let sender_id = match ctx.connection_manager.get_user_id(&ctx.connection_id) {
        Some(id) => id,
        None => {
            return Some(WsMessage::error("UNAUTHORIZED", "Not authenticated"));
        }
    };

    let message_id = Uuid::new_v4().to_string();
    let timestamp = chrono::Utc::now();
    let timestamp_str = timestamp.to_rfc3339();

    // Generate deterministic conversation ID
    let conversation_id = generate_conversation_id(&sender_id, &send.recipient_id);

    // Store message in database
    // Note: In production, this would call the existing send_message handler
    // For now, we'll create a simplified version
    let message = MessagePayload {
        message_id: message_id.clone(),
        conversation_id: Some(conversation_id),
        sender_id: sender_id.clone(),
        sender_device_id: String::new(), // TODO: Get from authentication context
        recipient_id: send.recipient_id.clone(),
        content: send.content.clone(),
        encrypted: send.encrypted,
        content_type: send.content_type.clone(),
        timestamp: timestamp_str.clone(),
        client_message_id: send.client_message_id.clone(),
        x3dh_prekey: None, // WebSocket messages don't include X3DH prekey directly
    };

    // Store in ScyllaDB via the database client
    if let Err(e) = store_message_in_db(ctx, &message).await {
        error!(
            message_id = %message_id,
            error = %e,
            "Failed to store message in database"
        );
        return Some(WsMessage::error_with_context(
            "STORAGE_ERROR",
            "Failed to store message",
            message_id,
        ));
    }

    // Publish to NATS for delivery to recipient
    let ws_message = WsMessage::Message(message.clone());
    if let Ok(json) = serde_json::to_vec(&ws_message) {
        let subject = format!("messages.user.{}", send.recipient_id);
        if let Err(e) = ctx.nats.publish_raw(&subject, json.into()).await {
            warn!(
                recipient_id = %send.recipient_id,
                error = %e,
                "Failed to publish message to NATS"
            );
        }
    }

    // Also send to recipient's WebSocket connections directly
    ctx.connection_manager
        .send_to_user(&send.recipient_id, ws_message)
        .await;

    // Send confirmation to sender
    Some(WsMessage::MessageSent(MessageSentPayload {
        message_id,
        client_message_id: send.client_message_id,
        timestamp: timestamp_str,
    }))
}

/// Store message in database
async fn store_message_in_db(ctx: &WsContext, message: &MessagePayload) -> Result<(), String> {
    // This integrates with the existing DatabaseClient
    // In production, you would use the proper ORM/query methods
    let query = r#"
        INSERT INTO guardyn.messages (
            message_id, sender_id, recipient_id, content,
            content_type, is_encrypted, created_at, read_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, null)
    "#;

    let timestamp = chrono::DateTime::parse_from_rfc3339(&message.timestamp)
        .map_err(|e| format!("Invalid timestamp: {}", e))?
        .with_timezone(&chrono::Utc);

    ctx.db
        .execute_message_insert(
            &message.message_id,
            &message.sender_id,
            &message.recipient_id,
            &message.content,
            &message.content_type,
            message.encrypted,
            timestamp,
        )
        .await
        .map_err(|e| format!("Database error: {}", e))
}

/// Handle mark as read request
async fn handle_mark_read(ctx: &WsContext, mark_read: MarkReadPayload) -> Option<WsMessage> {
    // Ensure connection is authenticated
    let user_id = match ctx.connection_manager.get_user_id(&ctx.connection_id) {
        Some(id) => id,
        None => {
            return Some(WsMessage::error("UNAUTHORIZED", "Not authenticated"));
        }
    };

    let read_at = chrono::Utc::now().to_rfc3339();

    // Update messages in database
    for message_id in &mark_read.message_ids {
        if let Err(e) = ctx.db.mark_message_read(message_id, &user_id).await {
            warn!(
                message_id = %message_id,
                error = %e,
                "Failed to mark message as read"
            );
        }
    }

    // Send read receipt to conversation partner
    // For 1-on-1, conversation_id is the other user's ID
    let read_receipt = ReadReceiptPayload {
        user_id: user_id.clone(),
        conversation_id: mark_read.conversation_id.clone(),
        message_ids: mark_read.message_ids.clone(),
        read_at,
    };

    // Publish via NATS
    let ws_message = WsMessage::ReadReceipt(read_receipt.clone());
    if let Ok(json) = serde_json::to_vec(&ws_message) {
        let subject = format!("read_receipts.{}", mark_read.conversation_id);
        if let Err(e) = ctx.nats.publish_raw(&subject, json.into()).await {
            warn!(error = %e, "Failed to publish read receipt");
        }
    }

    // Also send to WebSocket connections directly
    ctx.connection_manager
        .send_to_user(&mark_read.conversation_id, ws_message)
        .await;

    None // No response needed for mark_read
}

/// Handle typing indicator
async fn handle_typing(ctx: &WsContext, mut typing: TypingPayload) -> Option<WsMessage> {
    // Ensure connection is authenticated
    let user_id = match ctx.connection_manager.get_user_id(&ctx.connection_id) {
        Some(id) => id,
        None => {
            return Some(WsMessage::error("UNAUTHORIZED", "Not authenticated"));
        }
    };

    // Override user_id with authenticated user
    typing.user_id = user_id;

    // Publish typing indicator via NATS
    let ws_message = WsMessage::Typing(typing.clone());
    if let Ok(json) = serde_json::to_vec(&ws_message) {
        let subject = format!("typing.{}", typing.conversation_id);
        if let Err(e) = ctx.nats.publish_raw(&subject, json.into()).await {
            warn!(error = %e, "Failed to publish typing indicator");
        }
    }

    // Send to conversation partner's WebSocket connections
    ctx.connection_manager
        .send_to_user(&typing.conversation_id, ws_message)
        .await;

    None // No response needed
}

/// Handle subscription request
async fn handle_subscribe(ctx: &WsContext, sub: SubscribePayload) -> Option<WsMessage> {
    // Ensure connection is authenticated
    if ctx.connection_manager.get_user_id(&ctx.connection_id).is_none() {
        return Some(WsMessage::error("UNAUTHORIZED", "Not authenticated"));
    }

    match sub.subscription_type.as_str() {
        "conversation" => {
            for conv_id in sub.target_ids {
                ctx.connection_manager
                    .subscribe_conversation(&ctx.connection_id, conv_id);
            }
        }
        "presence" => {
            for user_id in sub.target_ids {
                ctx.connection_manager
                    .subscribe_presence(&ctx.connection_id, user_id);
            }
        }
        "typing" => {
            // Typing uses same subscription as conversation
            for conv_id in sub.target_ids {
                ctx.connection_manager
                    .subscribe_conversation(&ctx.connection_id, conv_id);
            }
        }
        _ => {
            return Some(WsMessage::error(
                "INVALID_SUBSCRIPTION",
                format!("Unknown subscription type: {}", sub.subscription_type),
            ));
        }
    }

    None // No response needed
}

/// Handle unsubscription request
async fn handle_unsubscribe(ctx: &WsContext, unsub: UnsubscribePayload) -> Option<WsMessage> {
    // Ensure connection is authenticated
    if ctx.connection_manager.get_user_id(&ctx.connection_id).is_none() {
        return Some(WsMessage::error("UNAUTHORIZED", "Not authenticated"));
    }

    match unsub.subscription_type.as_str() {
        "conversation" | "typing" => {
            for conv_id in unsub.target_ids {
                ctx.connection_manager
                    .unsubscribe_conversation(&ctx.connection_id, &conv_id);
            }
        }
        "presence" => {
            for user_id in unsub.target_ids {
                ctx.connection_manager
                    .unsubscribe_presence(&ctx.connection_id, &user_id);
            }
        }
        _ => {
            return Some(WsMessage::error(
                "INVALID_SUBSCRIPTION",
                format!("Unknown subscription type: {}", unsub.subscription_type),
            ));
        }
    }

    None // No response needed
}

/// Handle user disconnect - publish offline presence
pub async fn handle_disconnect(ctx: &WsContext) {
    let user_id = ctx.connection_manager.get_user_id(&ctx.connection_id);

    // Remove connection
    ctx.connection_manager.remove_connection(&ctx.connection_id);

    // If user has no more connections, publish offline presence
    if let Some(user_id) = user_id {
        if !ctx.connection_manager.is_user_online(&user_id) {
            let presence_msg = PresencePayload {
                user_id: user_id.clone(),
                status: "offline".to_string(),
                last_seen: Some(chrono::Utc::now().to_rfc3339()),
            };

            if let Ok(json) = serde_json::to_vec(&WsMessage::Presence(presence_msg)) {
                let subject = format!("presence.{}", user_id);
                if let Err(e) = ctx.nats.publish_raw(&subject, json.into()).await {
                    warn!(error = %e, "Failed to publish offline presence");
                }
            }

            info!(user_id = %user_id, "User went offline");
        }
    }
}
