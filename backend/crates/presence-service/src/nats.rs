/// NATS client for real-time presence updates
///
/// Publishes presence updates to NATS JetStream for real-time delivery

use anyhow::{Context, Result};
use async_nats::jetstream::{self, Context as JetStreamContext};
use bytes::Bytes;
use serde::{Deserialize, Serialize};
use std::sync::Arc;

const PRESENCE_STREAM: &str = "PRESENCE";
const PRESENCE_SUBJECT: &str = "presence.updates";
const TYPING_SUBJECT: &str = "presence.typing";

/// Presence update event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PresenceEvent {
    pub user_id: String,
    pub status: i32,
    pub custom_status_text: String,
    pub last_seen: i64,
    pub updated_at: i64,
}

/// Typing indicator event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TypingEvent {
    pub user_id: String,
    pub conversation_user_id: String,
    pub is_typing: bool,
    pub timestamp: i64,
}

/// NATS client for presence service
#[derive(Clone)]
pub struct NatsClient {
    jetstream: Arc<JetStreamContext>,
}

impl NatsClient {
    /// Create new NATS client and connect to server
    pub async fn new(nats_url: &str) -> Result<Self> {
        let client = async_nats::connect(nats_url)
            .await
            .context("Failed to connect to NATS")?;

        let jetstream = jetstream::new(client);

        // Ensure PRESENCE stream exists
        let stream_config = jetstream::stream::Config {
            name: PRESENCE_STREAM.to_string(),
            subjects: vec![
                format!("{}.*", PRESENCE_SUBJECT),
                format!("{}.*.*", TYPING_SUBJECT),
            ],
            retention: jetstream::stream::RetentionPolicy::Interest,
            max_age: std::time::Duration::from_secs(300), // 5 minute retention for presence
            ..Default::default()
        };

        // Create or update stream
        match jetstream.create_stream(stream_config.clone()).await {
            Ok(_) => tracing::info!("Created PRESENCE stream"),
            Err(e) => {
                // Try to update existing stream
                tracing::debug!("Stream may already exist, trying to get it: {}", e);
                match jetstream.get_stream(PRESENCE_STREAM).await {
                    Ok(_) => tracing::info!("Using existing PRESENCE stream"),
                    Err(e) => tracing::warn!("Could not get PRESENCE stream: {}", e),
                }
            }
        }

        Ok(Self {
            jetstream: Arc::new(jetstream),
        })
    }

    /// Publish presence update
    pub async fn publish_presence_update(&self, event: &PresenceEvent) -> Result<()> {
        let subject = format!("{}.{}", PRESENCE_SUBJECT, event.user_id);
        let payload = serde_json::to_vec(event)?;

        self.jetstream
            .publish(subject, Bytes::from(payload))
            .await
            .context("Failed to publish presence update")?
            .await
            .context("Failed to acknowledge presence update")?;

        tracing::debug!(
            user_id = %event.user_id,
            status = event.status,
            "Published presence update"
        );

        Ok(())
    }

    /// Publish typing indicator
    pub async fn publish_typing_indicator(&self, event: &TypingEvent) -> Result<()> {
        // Subject format: presence.typing.{target_user_id}.{from_user_id}
        // This allows subscribers to filter by who they want to receive typing from
        let subject = format!(
            "{}.{}.{}",
            TYPING_SUBJECT, event.conversation_user_id, event.user_id
        );
        let payload = serde_json::to_vec(event)?;

        self.jetstream
            .publish(subject, Bytes::from(payload))
            .await
            .context("Failed to publish typing indicator")?
            .await
            .context("Failed to acknowledge typing indicator")?;

        tracing::debug!(
            user_id = %event.user_id,
            conversation_user_id = %event.conversation_user_id,
            is_typing = event.is_typing,
            "Published typing indicator"
        );

        Ok(())
    }

    /// Health check - verify NATS connectivity
    pub async fn health_check(&self) -> Result<()> {
        // Check if we can access the stream
        self.jetstream
            .get_stream(PRESENCE_STREAM)
            .await
            .context("NATS health check failed")?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_presence_event_serialization() {
        let now = chrono::Utc::now().timestamp_millis();
        let event = PresenceEvent {
            user_id: "user-123".to_string(),
            status: 1, // ONLINE
            custom_status_text: "Available".to_string(),
            last_seen: now,
            updated_at: now,
        };

        // Serialize to JSON
        let json = serde_json::to_string(&event).unwrap();
        assert!(json.contains("user-123"));
        assert!(json.contains("Available"));
        assert!(json.contains("\"status\":1"));

        // Deserialize back
        let deserialized: PresenceEvent = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.user_id, event.user_id);
        assert_eq!(deserialized.status, event.status);
        assert_eq!(deserialized.custom_status_text, event.custom_status_text);
    }

    #[test]
    fn test_typing_event_serialization() {
        let now = chrono::Utc::now().timestamp_millis();
        let event = TypingEvent {
            user_id: "alice".to_string(),
            conversation_user_id: "bob".to_string(),
            is_typing: true,
            timestamp: now,
        };

        // Serialize to JSON
        let json = serde_json::to_string(&event).unwrap();
        assert!(json.contains("alice"));
        assert!(json.contains("bob"));
        assert!(json.contains("\"is_typing\":true"));

        // Deserialize back
        let deserialized: TypingEvent = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.user_id, event.user_id);
        assert_eq!(deserialized.conversation_user_id, event.conversation_user_id);
        assert_eq!(deserialized.is_typing, event.is_typing);
    }

    #[test]
    fn test_presence_subject_format() {
        let user_id = "user-xyz";
        let subject = format!("{}.{}", PRESENCE_SUBJECT, user_id);
        assert_eq!(subject, "presence.updates.user-xyz");
    }

    #[test]
    fn test_typing_subject_format() {
        let target_user_id = "bob";
        let from_user_id = "alice";
        let subject = format!("{}.{}.{}", TYPING_SUBJECT, target_user_id, from_user_id);
        assert_eq!(subject, "presence.typing.bob.alice");
    }

    #[test]
    fn test_stream_config_values() {
        assert_eq!(PRESENCE_STREAM, "PRESENCE");
        assert_eq!(PRESENCE_SUBJECT, "presence.updates");
        assert_eq!(TYPING_SUBJECT, "presence.typing");
    }

    #[test]
    fn test_presence_event_all_statuses() {
        let now = chrono::Utc::now().timestamp_millis();
        
        for status in 0..=4 {
            let event = PresenceEvent {
                user_id: format!("user-{}", status),
                status,
                custom_status_text: String::new(),
                last_seen: now,
                updated_at: now,
            };
            
            let json = serde_json::to_string(&event).unwrap();
            let deserialized: PresenceEvent = serde_json::from_str(&json).unwrap();
            assert_eq!(deserialized.status, status);
        }
    }

    #[test]
    fn test_typing_event_stop_typing() {
        let event = TypingEvent {
            user_id: "alice".to_string(),
            conversation_user_id: "bob".to_string(),
            is_typing: false,
            timestamp: chrono::Utc::now().timestamp_millis(),
        };

        let json = serde_json::to_string(&event).unwrap();
        assert!(json.contains("\"is_typing\":false"));
    }
}
