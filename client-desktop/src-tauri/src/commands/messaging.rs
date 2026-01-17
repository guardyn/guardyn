//! Messaging Commands
//!
//! Handles sending, receiving, and managing encrypted messages.

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
        "Sending message to conversation: {}",
        request.conversation_id
    );

    // TODO: Implement actual message encryption and sending
    // 1. Pad message with PADMÉ
    // 2. Encrypt with Double Ratchet (1-on-1) or MLS (group)
    // 3. Send via gRPC to messaging service

    let message = Message {
        id: uuid::Uuid::new_v4().to_string(),
        conversation_id: request.conversation_id,
        sender_id: "current-user-id".to_string(),
        content: request.content,
        timestamp: chrono::Utc::now().timestamp_millis(),
        status: MessageStatus::Sent,
        reply_to: request.reply_to,
        reactions: vec![],
    };

    Ok(message)
}

/// Get all conversations for the current user
#[tauri::command]
pub async fn get_conversations(state: State<'_, AppState>) -> Result<Vec<Conversation>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    // TODO: Implement actual conversation retrieval
    Ok(vec![])
}

/// Get messages for a specific conversation
#[tauri::command]
pub async fn get_messages(
    conversation_id: String,
    limit: Option<u32>,
    before: Option<String>,
    state: State<'_, AppState>,
) -> Result<Vec<Message>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!(
        "Fetching messages for conversation: {} (limit: {:?}, before: {:?})",
        conversation_id,
        limit,
        before
    );

    // TODO: Implement actual message retrieval and decryption
    Ok(vec![])
}

/// Mark messages as read
#[tauri::command]
pub async fn mark_as_read(
    conversation_id: String,
    message_id: String,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!(
        "Marking messages as read in {} up to {}",
        conversation_id,
        message_id
    );

    // TODO: Send read receipt to backend
    Ok(())
}
