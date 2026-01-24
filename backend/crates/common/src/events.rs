//! Domain events for cross-service communication
//!
//! Events are published to Redpanda topics and consumed by interested services.
//! This enables eventual consistency across microservices.

use serde::{Deserialize, Serialize};
use std::time::{SystemTime, UNIX_EPOCH};

/// Event topics for Redpanda
pub mod topics {
    /// User lifecycle events (account creation, deletion, updates)
    pub const USER_EVENTS: &str = "guardyn.user.events";

    /// Message events (for audit, sync)
    pub const MESSAGE_EVENTS: &str = "guardyn.message.events";

    /// Group events (creation, member changes)
    pub const GROUP_EVENTS: &str = "guardyn.group.events";

    /// Presence events (online/offline, typing)
    pub const PRESENCE_EVENTS: &str = "guardyn.presence.events";

    /// Call events (started, ended, participant changes)
    pub const CALL_EVENTS: &str = "guardyn.call.events";
}

/// Base event envelope with common metadata
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventEnvelope<T> {
    /// Unique event ID (UUID v4)
    pub event_id: String,

    /// Event type (e.g., "user.deleted", "message.sent")
    pub event_type: String,

    /// Unix timestamp in milliseconds
    pub timestamp: u64,

    /// Source service that emitted the event
    pub source: String,

    /// Event payload
    pub payload: T,

    /// Optional correlation ID for tracing
    pub correlation_id: Option<String>,
}

impl<T> EventEnvelope<T> {
    /// Create a new event envelope
    pub fn new(event_type: impl Into<String>, source: impl Into<String>, payload: T) -> Self {
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as u64;

        Self {
            event_id: uuid::Uuid::new_v4().to_string(),
            event_type: event_type.into(),
            timestamp,
            source: source.into(),
            payload,
            correlation_id: None,
        }
    }

    /// Set correlation ID for tracing
    pub fn with_correlation_id(mut self, id: impl Into<String>) -> Self {
        self.correlation_id = Some(id.into());
        self
    }
}

/// User-related event types
pub mod user {
    use super::*;

    /// Event types for user lifecycle
    pub const TYPE_CREATED: &str = "user.created";
    pub const TYPE_UPDATED: &str = "user.updated";
    pub const TYPE_DELETED: &str = "user.deleted";
    pub const TYPE_PASSWORD_CHANGED: &str = "user.password_changed";
    pub const TYPE_DEACTIVATED: &str = "user.deactivated";
    pub const TYPE_REACTIVATED: &str = "user.reactivated";

    /// Payload for user.deleted event
    ///
    /// When a user deletes their account, this event is published
    /// so other services can clean up their data.
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct UserDeletedPayload {
        /// User ID being deleted
        pub user_id: String,

        /// Username (for logging purposes)
        pub username: String,

        /// Reason for deletion (optional)
        pub reason: Option<String>,

        /// Whether to cascade delete all data
        pub cascade: bool,

        /// List of data types to delete
        pub delete_data: DeleteDataScope,
    }

    /// Scope of data to delete when user account is removed
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct DeleteDataScope {
        /// Delete all messages sent by user
        pub messages: bool,

        /// Delete all media files uploaded by user
        pub media: bool,

        /// Remove user from all groups
        pub group_memberships: bool,

        /// Delete call history
        pub call_history: bool,

        /// Delete presence/status data
        pub presence: bool,

        /// Delete device registrations
        pub devices: bool,
    }

    impl Default for DeleteDataScope {
        fn default() -> Self {
            Self {
                messages: true,
                media: true,
                group_memberships: true,
                call_history: true,
                presence: true,
                devices: true,
            }
        }
    }

    /// Payload for user.created event
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct UserCreatedPayload {
        /// User ID
        pub user_id: String,

        /// Username
        pub username: String,

        /// Display name (optional)
        pub display_name: Option<String>,
    }
}

/// Group-related event types
pub mod group {
    use super::*;

    pub const TYPE_CREATED: &str = "group.created";
    pub const TYPE_DELETED: &str = "group.deleted";
    pub const TYPE_MEMBER_ADDED: &str = "group.member_added";
    pub const TYPE_MEMBER_REMOVED: &str = "group.member_removed";
    pub const TYPE_UPDATED: &str = "group.updated";

    /// Payload for member removal (used when user account is deleted)
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct MemberRemovedPayload {
        /// Group ID
        pub group_id: String,

        /// User ID being removed
        pub user_id: String,

        /// Reason for removal
        pub reason: String,

        /// Was this a cascade from user deletion?
        pub cascade: bool,
    }
}

/// Message-related event types
pub mod message {
    use super::*;

    pub const TYPE_SENT: &str = "message.sent";
    pub const TYPE_DELIVERED: &str = "message.delivered";
    pub const TYPE_READ: &str = "message.read";
    pub const TYPE_DELETED: &str = "message.deleted";
    pub const TYPE_USER_DATA_DELETED: &str = "message.user_data_deleted";

    /// Payload for bulk message deletion (user account deletion)
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct UserDataDeletedPayload {
        /// User ID whose messages were deleted
        pub user_id: String,

        /// Number of messages deleted
        pub messages_deleted: u64,

        /// Number of conversations affected
        pub conversations_affected: u64,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_event_envelope_creation() {
        let payload = user::UserDeletedPayload {
            user_id: "user123".to_string(),
            username: "testuser".to_string(),
            reason: Some("User requested".to_string()),
            cascade: true,
            delete_data: user::DeleteDataScope::default(),
        };

        let event = EventEnvelope::new(user::TYPE_DELETED, "auth-service", payload);

        assert!(!event.event_id.is_empty());
        assert_eq!(event.event_type, "user.deleted");
        assert_eq!(event.source, "auth-service");
        assert!(event.timestamp > 0);
        assert!(event.correlation_id.is_none());
    }

    #[test]
    fn test_event_with_correlation_id() {
        let payload = user::UserCreatedPayload {
            user_id: "user456".to_string(),
            username: "newuser".to_string(),
            display_name: Some("New User".to_string()),
        };

        let event = EventEnvelope::new(user::TYPE_CREATED, "auth-service", payload)
            .with_correlation_id("request-123");

        assert_eq!(event.correlation_id, Some("request-123".to_string()));
    }

    #[test]
    fn test_delete_data_scope_default() {
        let scope = user::DeleteDataScope::default();

        assert!(scope.messages);
        assert!(scope.media);
        assert!(scope.group_memberships);
        assert!(scope.call_history);
        assert!(scope.presence);
        assert!(scope.devices);
    }
}
