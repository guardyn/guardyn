/// WebSocket Messages
///
/// Defines the JSON message format for WebSocket communication.
/// Matches the protocol used by the Flutter client.

use serde::{Deserialize, Serialize};

/// Message types sent over WebSocket
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", content = "payload")]
pub enum WsMessage {
    /// Authentication request (client → server)
    #[serde(rename = "auth")]
    Auth(AuthMessage),

    /// Authentication response (server → client)
    #[serde(rename = "auth_response")]
    AuthResponse(AuthResponse),

    /// Send a new message (client → server)
    #[serde(rename = "send_message")]
    SendMessage(SendMessagePayload),

    /// Received message (server → client)
    #[serde(rename = "message")]
    Message(MessagePayload),

    /// Message sent confirmation (server → client)
    #[serde(rename = "message_sent")]
    MessageSent(MessageSentPayload),

    /// Typing indicator (bidirectional)
    #[serde(rename = "typing")]
    Typing(TypingPayload),

    /// Presence update (bidirectional)
    #[serde(rename = "presence")]
    Presence(PresencePayload),

    /// Mark messages as read (client → server)
    #[serde(rename = "mark_read")]
    MarkRead(MarkReadPayload),

    /// Read receipt (server → client)
    #[serde(rename = "read_receipt")]
    ReadReceipt(ReadReceiptPayload),

    /// Heartbeat ping (bidirectional)
    #[serde(rename = "ping")]
    Ping(PingPayload),

    /// Heartbeat pong (bidirectional)
    #[serde(rename = "pong")]
    Pong(PongPayload),

    /// Error response (server → client)
    #[serde(rename = "error")]
    Error(ErrorPayload),

    /// Subscribe to conversation/user presence (client → server)
    #[serde(rename = "subscribe")]
    Subscribe(SubscribePayload),

    /// Unsubscribe from conversation/user presence (client → server)
    #[serde(rename = "unsubscribe")]
    Unsubscribe(UnsubscribePayload),
}

/// Authentication message
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthMessage {
    /// JWT token for authentication
    pub token: String,
    /// Device ID for multi-device support
    #[serde(skip_serializing_if = "Option::is_none")]
    pub device_id: Option<String>,
}

/// Authentication response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthResponse {
    /// Whether authentication was successful
    pub success: bool,
    /// User ID if authenticated
    #[serde(skip_serializing_if = "Option::is_none")]
    pub user_id: Option<String>,
    /// Error message if authentication failed
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
}

/// Send message payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SendMessagePayload {
    /// Recipient user ID
    pub recipient_id: String,
    /// Message content (plaintext or encrypted)
    pub content: String,
    /// Whether content is E2EE encrypted
    #[serde(default)]
    pub encrypted: bool,
    /// Client-generated message ID for idempotency
    #[serde(skip_serializing_if = "Option::is_none")]
    pub client_message_id: Option<String>,
    /// Content type (text, image, file, etc.)
    #[serde(default = "default_content_type")]
    pub content_type: String,
}

fn default_content_type() -> String {
    "text".to_string()
}

/// Received message payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MessagePayload {
    /// Server-generated message ID
    pub message_id: String,
    /// Sender user ID
    pub sender_id: String,
    /// Sender device ID (required for E2EE session lookup)
    pub sender_device_id: String,
    /// Recipient user ID
    pub recipient_id: String,
    /// Message content
    pub content: String,
    /// Whether content is encrypted
    pub encrypted: bool,
    /// Content type
    pub content_type: String,
    /// Timestamp (ISO 8601)
    pub timestamp: String,
    /// Client message ID if provided
    #[serde(skip_serializing_if = "Option::is_none")]
    pub client_message_id: Option<String>,
    /// X3DH prekey data for first message in session (Base64 encoded)
    #[serde(skip_serializing_if = "Option::is_none")]
    pub x3dh_prekey: Option<String>,
}

/// Message sent confirmation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MessageSentPayload {
    /// Server-generated message ID
    pub message_id: String,
    /// Client message ID if provided
    #[serde(skip_serializing_if = "Option::is_none")]
    pub client_message_id: Option<String>,
    /// Timestamp (ISO 8601)
    pub timestamp: String,
}

/// Typing indicator payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TypingPayload {
    /// User ID who is typing
    pub user_id: String,
    /// Conversation ID (recipient for 1-on-1, group ID for groups)
    pub conversation_id: String,
    /// Whether user is typing (true) or stopped typing (false)
    pub is_typing: bool,
}

/// Presence update payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PresencePayload {
    /// User ID whose presence changed
    pub user_id: String,
    /// Online status: "online", "offline", "away", "do_not_disturb"
    pub status: String,
    /// Last seen timestamp (ISO 8601) for offline status
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_seen: Option<String>,
}

/// Mark messages as read payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MarkReadPayload {
    /// Conversation ID
    pub conversation_id: String,
    /// Message IDs to mark as read
    pub message_ids: Vec<String>,
}

/// Read receipt payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReadReceiptPayload {
    /// User who read the messages
    pub user_id: String,
    /// Conversation ID
    pub conversation_id: String,
    /// Message IDs that were read
    pub message_ids: Vec<String>,
    /// Timestamp when messages were read
    pub read_at: String,
}

/// Ping payload for heartbeat
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PingPayload {
    /// Timestamp for latency measurement
    pub timestamp: i64,
}

/// Pong payload for heartbeat response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PongPayload {
    /// Echo of the ping timestamp
    pub timestamp: i64,
    /// Server timestamp
    pub server_timestamp: i64,
}

/// Error payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorPayload {
    /// Error code
    pub code: String,
    /// Human-readable error message
    pub message: String,
    /// Optional context (e.g., which message failed)
    #[serde(skip_serializing_if = "Option::is_none")]
    pub context: Option<String>,
}

/// Subscribe to updates
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubscribePayload {
    /// Subscription type: "conversation", "presence", "typing"
    pub subscription_type: String,
    /// Target IDs (conversation IDs for messages, user IDs for presence)
    pub target_ids: Vec<String>,
}

/// Unsubscribe from updates
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UnsubscribePayload {
    /// Subscription type: "conversation", "presence", "typing"
    pub subscription_type: String,
    /// Target IDs to unsubscribe from
    pub target_ids: Vec<String>,
}

impl WsMessage {
    /// Create an error response
    pub fn error(code: impl Into<String>, message: impl Into<String>) -> Self {
        WsMessage::Error(ErrorPayload {
            code: code.into(),
            message: message.into(),
            context: None,
        })
    }

    /// Create an error response with context
    pub fn error_with_context(
        code: impl Into<String>,
        message: impl Into<String>,
        context: impl Into<String>,
    ) -> Self {
        WsMessage::Error(ErrorPayload {
            code: code.into(),
            message: message.into(),
            context: Some(context.into()),
        })
    }

    /// Create a pong response from a ping
    pub fn pong_from_ping(ping: &PingPayload) -> Self {
        WsMessage::Pong(PongPayload {
            timestamp: ping.timestamp,
            server_timestamp: chrono::Utc::now().timestamp_millis(),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_serialize_auth_message() {
        let msg = WsMessage::Auth(AuthMessage {
            token: "test-token".to_string(),
            device_id: Some("device-123".to_string()),
        });

        let json = serde_json::to_string(&msg).unwrap();
        assert!(json.contains("auth"));
        assert!(json.contains("test-token"));
    }

    #[test]
    fn test_deserialize_send_message() {
        let json = r#"{"type":"send_message","payload":{"recipient_id":"user-456","content":"Hello!","encrypted":false}}"#;
        let msg: WsMessage = serde_json::from_str(json).unwrap();

        match msg {
            WsMessage::SendMessage(payload) => {
                assert_eq!(payload.recipient_id, "user-456");
                assert_eq!(payload.content, "Hello!");
                assert!(!payload.encrypted);
            }
            _ => panic!("Expected SendMessage"),
        }
    }

    #[test]
    fn test_error_message() {
        let msg = WsMessage::error("AUTH_FAILED", "Invalid token");
        let json = serde_json::to_string(&msg).unwrap();

        assert!(json.contains("error"));
        assert!(json.contains("AUTH_FAILED"));
        assert!(json.contains("Invalid token"));
    }
}
