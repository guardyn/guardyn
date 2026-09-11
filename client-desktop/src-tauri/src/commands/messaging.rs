//! Messaging Commands
//!
//! Handles sending, receiving, and managing encrypted messages.

use crate::services::messaging_client::OutgoingMessage;
use crate::state::AppState;
use serde::{Deserialize, Serialize};
use tauri::State;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Conversation {
    pub id: String,
    pub name: Option<String>,
    pub is_group: bool,
    pub participant_ids: Vec<String>,
    pub last_message: Option<MessagePreview>,
    pub unread_count: u32,
    pub updated_at: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MessagePreview {
    pub id: String,
    pub content: String,
    pub sender_id: String,
    pub timestamp: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Message {
    pub id: String,
    pub conversation_id: String,
    pub sender_id: String,
    pub content: String,
    /// Set when `content` could not be decrypted and is the placeholder rather than anything
    /// the sender wrote. The UI keys off this rather than matching the placeholder text.
    pub undecryptable: bool,
    pub timestamp: i64,
    pub status: MessageStatus,
    pub reply_to: Option<String>,
    pub reactions: Vec<Reaction>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum MessageStatus {
    Sending,
    Sent,
    Delivered,
    Read,
    Failed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Reaction {
    pub user_id: String,
    pub emoji: String,
    pub timestamp: i64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SendMessageRequest {
    pub conversation_id: String,
    pub recipient_id: String,
    pub content: String,
    pub reply_to: Option<String>,
}

/// Send an encrypted message
#[tauri::command]
pub async fn send_message(
    request: SendMessageRequest,
    state: State<'_, AppState>,
) -> Result<Message, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!(
        "Sending message to conversation: {}, recipient: {}",
        request.conversation_id,
        request.recipient_id
    );

    // Encrypt, or refuse to send.
    //
    // This previously assigned `request.content.as_bytes().to_vec()` - the plaintext, into a
    // field named `encrypted_content` (#163). That was survivable only while the server
    // encrypted on the client's behalf, and it stopped doing so when the E2EE handler fork was
    // removed: `messaging-service` now stores what it is handed byte-for-byte, so the plaintext
    // was reaching ScyllaDB in the clear.
    //
    // There is no fallback branch here on purpose. Invariant I-2 is that encryption cannot be
    // turned off, which means the only correct behaviour when it is unavailable is to refuse,
    // exactly as `client-mobile` now does (#226).
    let self_user_id = state
        .user_id()
        .ok_or_else(|| "Not authenticated: no local user id".to_string())?;
    let encrypted_content =
        crate::commands::crypto::encrypt_for_peer(&request.content, &request.recipient_id, &self_user_id)
            .map_err(|e| {
                tracing::warn!("Refusing to send: {}", e);
                format!("Failed to send message: {}", e)
            })?;

    // The first message of a session carries what the peer needs to answer it: our identity
    // key, the ephemeral key X3DH ran with, and the id of the one-time pre-key we consumed.
    // Without it the recipient holds ciphertext it can never derive a key for.
    let x3dh_prekey = crate::commands::crypto::peek_pending_prekey(&request.recipient_id);

    // Create outgoing message - use recipient_id (user ID), not conversation_id
    let outgoing = OutgoingMessage {
        recipient_user_id: request.recipient_id.clone(),
        encrypted_content,
        message_type: 0, // TEXT message
        client_message_id: uuid::Uuid::new_v4().to_string(),
        media_id: None,
        x3dh_prekey,
    };

    // Send via gRPC
    match state.messaging().send_message(outgoing).await {
        Ok(result) => {
            // Cleared only now. A send that failed leaves it parked, so the retry still carries
            // it; a peer that already has a session ignores a repeat (#258).
            crate::commands::crypto::clear_pending_prekey(&request.recipient_id);

            let message = Message {
                id: result.message_id,
                conversation_id: request.conversation_id,
                sender_id: self_user_id,
                // Our own outgoing text, never a decryption result.
                content: request.content,
                undecryptable: false,
                timestamp: result.server_timestamp,
                status: match result.delivery_status {
                    0 => MessageStatus::Sending,
                    1 => MessageStatus::Sent,
                    2 => MessageStatus::Delivered,
                    3 => MessageStatus::Read,
                    _ => MessageStatus::Failed,
                },
                reply_to: request.reply_to,
                reactions: vec![],
            };
            Ok(message)
        }
        Err(e) => {
            tracing::error!("Failed to send message: {:?}", e);
            Err(format!("Failed to send message: {}", e))
        }
    }
}

/// Get all conversations for the current user
#[tauri::command]
pub async fn get_conversations(state: State<'_, AppState>) -> Result<Vec<Conversation>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    match state.messaging().get_conversations().await {
        Ok(conversations) => {
            let result: Vec<Conversation> = conversations
                .into_iter()
                .map(|c| Conversation {
                    id: c.conversation_id,
                    name: Some(c.username),
                    is_group: false,
                    participant_ids: vec![c.user_id],
                    last_message: c.last_message_preview.map(|preview| MessagePreview {
                        id: c.last_message_id.unwrap_or_default(),
                        content: preview,
                        sender_id: String::new(),
                        timestamp: 0,
                    }),
                    unread_count: c.unread_count,
                    updated_at: 0,
                })
                .collect();
            Ok(result)
        }
        Err(e) => {
            tracing::error!("Failed to get conversations: {:?}", e);
            Err(format!("Failed to get conversations: {}", e))
        }
    }
}

/// Get messages for a specific conversation
#[tauri::command]
pub async fn get_messages(
    conversation_id: String,
    limit: Option<u32>,
    _before: Option<String>,
    state: State<'_, AppState>,
) -> Result<Vec<Message>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!(
        "Fetching messages for conversation: {} (limit: {:?})",
        conversation_id,
        limit
    );

    match state.messaging().get_messages(
        conversation_id.clone(),
        limit.unwrap_or(50) as i32,
    ).await {
        Ok(messages) => {
            let result: Vec<Message> = messages
                .into_iter()
                .map(|m| {
                    // Show that we could not decrypt, rather than showing what we could not
                    // decrypt. This was `String::from_utf8_lossy(&m.encrypted_content)`, which
                    // cannot fail - so ciphertext rendered as replacement characters instead of
                    // as an error, and anything that happened to be valid UTF-8 rendered as the
                    // message (#232).
                    //
                    // Every message is undecryptable today, because nothing on this client
                    // establishes a session yet (PR-79..PR-81). Saying so is the honest result.
                    let content = crate::commands::crypto::UNDECRYPTABLE_PLACEHOLDER.to_string();

                    Message {
                        id: m.message_id,
                        conversation_id: conversation_id.clone(),
                        sender_id: m.sender_user_id,
                        content,
                        undecryptable: true,
                        timestamp: m.server_timestamp,
                        status: match m.delivery_status {
                            0 => MessageStatus::Sending,
                            1 => MessageStatus::Sent,
                            2 => MessageStatus::Delivered,
                            3 => MessageStatus::Read,
                            _ => MessageStatus::Failed,
                        },
                        reply_to: None,
                        reactions: vec![],
                    }
                })
                .collect();
            Ok(result)
        }
        Err(e) => {
            tracing::error!("Failed to get messages: {:?}", e);
            Err(format!("Failed to get messages: {}", e))
        }
    }
}

/// Mark messages as read
#[tauri::command]
pub async fn mark_as_read(
    _conversation_id: String,
    message_id: String,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Marking message as read: {}", message_id);

    match state.messaging().mark_as_read(vec![message_id]).await {
        Ok(_) => Ok(()),
        Err(e) => {
            tracing::error!("Failed to mark as read: {:?}", e);
            Err(format!("Failed to mark as read: {}", e))
        }
    }
}
