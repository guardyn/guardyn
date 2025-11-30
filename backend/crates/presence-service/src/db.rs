/// Database client for TiKV
///
/// Handles all database operations for the presence service:
/// - User presence status storage
/// - Last seen timestamps
/// - Typing indicators (ephemeral, stored in memory/NATS)

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tikv_client::RawClient;

/// User presence stored in TiKV
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserPresence {
    pub user_id: String,
    pub status: i32, // Maps to UserStatus enum
    pub custom_status_text: String,
    pub last_seen: i64,     // Unix timestamp in milliseconds
    pub updated_at: i64,    // Unix timestamp in milliseconds
}

impl Default for UserPresence {
    fn default() -> Self {
        Self {
            user_id: String::new(),
            status: 0, // OFFLINE
            custom_status_text: String::new(),
            last_seen: 0,
            updated_at: 0,
        }
    }
}

/// Typing indicator (ephemeral state)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TypingIndicator {
    pub user_id: String,
    pub conversation_user_id: String,
    pub is_typing: bool,
    pub started_at: i64,
}

/// Database client
#[derive(Clone)]
pub struct DatabaseClient {
    client: Arc<RawClient>,
}

impl DatabaseClient {
    /// Create new database client
    pub async fn new(pd_endpoints: Vec<String>) -> Result<Self> {
        let client = RawClient::new(pd_endpoints)
            .await
            .context("Failed to connect to TiKV")?;

        Ok(Self {
            client: Arc::new(client),
        })
    }

    /// Get user presence by user ID
    pub async fn get_presence(&self, user_id: &str) -> Result<Option<UserPresence>> {
        let key = format!("/presence/{}", user_id).into_bytes();

        let presence_data = match self.client.get(key).await? {
            Some(data) => data,
            None => return Ok(None),
        };

        let presence: UserPresence = serde_json::from_slice(&presence_data)?;
        Ok(Some(presence))
    }

    /// Update user presence
    pub async fn update_presence(&self, presence: &UserPresence) -> Result<()> {
        let key = format!("/presence/{}", presence.user_id).into_bytes();
        let value = serde_json::to_vec(presence)?;
        self.client.put(key, value).await?;
        Ok(())
    }

    /// Update only last_seen timestamp
    pub async fn update_last_seen(&self, user_id: &str, last_seen: i64) -> Result<()> {
        let key = format!("/presence/{}", user_id).into_bytes();

        // Get existing presence or create new
        let mut presence = match self.client.get(key.clone()).await? {
            Some(data) => serde_json::from_slice(&data)?,
            None => UserPresence {
                user_id: user_id.to_string(),
                status: 1, // ONLINE when we have activity
                ..Default::default()
            },
        };

        presence.last_seen = last_seen;
        presence.updated_at = last_seen;

        let value = serde_json::to_vec(&presence)?;
        self.client.put(key, value).await?;
        Ok(())
    }

    /// Get multiple user presences
    pub async fn get_bulk_presence(&self, user_ids: &[String]) -> Result<Vec<UserPresence>> {
        let mut presences = Vec::with_capacity(user_ids.len());

        for user_id in user_ids {
            if let Some(presence) = self.get_presence(user_id).await? {
                presences.push(presence);
            }
        }

        Ok(presences)
    }

    /// Set typing indicator (ephemeral - short TTL would be ideal, but TiKV doesn't have TTL)
    /// In production, this would use Redis or similar with TTL support
    pub async fn set_typing(&self, user_id: &str, conversation_user_id: &str, is_typing: bool) -> Result<()> {
        let key = format!("/typing/{}/{}", user_id, conversation_user_id).into_bytes();

        if is_typing {
            let indicator = TypingIndicator {
                user_id: user_id.to_string(),
                conversation_user_id: conversation_user_id.to_string(),
                is_typing: true,
                started_at: chrono::Utc::now().timestamp_millis(),
            };
            let value = serde_json::to_vec(&indicator)?;
            self.client.put(key, value).await?;
        } else {
            // Delete typing indicator when user stops typing
            self.client.delete(key).await?;
        }

        Ok(())
    }

    /// Get typing indicator
    pub async fn get_typing(&self, user_id: &str, conversation_user_id: &str) -> Result<Option<TypingIndicator>> {
        let key = format!("/typing/{}/{}", user_id, conversation_user_id).into_bytes();

        let indicator_data = match self.client.get(key).await? {
            Some(data) => data,
            None => return Ok(None),
        };

        let indicator: TypingIndicator = serde_json::from_slice(&indicator_data)?;


        // Check if typing indicator is stale (older than 10 seconds)
        let now = chrono::Utc::now().timestamp_millis();
        if now - indicator.started_at > 10_000 {
            // Typing indicator expired
            return Ok(None);
        }

        Ok(Some(indicator))
    }

    /// Health check - verify TiKV connection
    pub async fn health_check(&self) -> Result<()> {
        // Try to get a known key to verify connectivity
        let key = b"/health_check".to_vec();
        let _ = self.client.get(key).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_presence_default() {
        let presence = UserPresence::default();
        
        assert_eq!(presence.user_id, "");
        assert_eq!(presence.status, 0); // OFFLINE
        assert_eq!(presence.custom_status_text, "");
        assert_eq!(presence.last_seen, 0);
        assert_eq!(presence.updated_at, 0);
    }

    #[test]
    fn test_user_presence_serialization() {
        let now = chrono::Utc::now().timestamp_millis();
        let presence = UserPresence {
            user_id: "user-123".to_string(),
            status: 1, // ONLINE
            custom_status_text: "Working from home".to_string(),
            last_seen: now,
            updated_at: now,
        };

        // Serialize to JSON
        let json = serde_json::to_string(&presence).unwrap();
        assert!(json.contains("user-123"));
        assert!(json.contains("Working from home"));

        // Deserialize back
        let deserialized: UserPresence = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.user_id, presence.user_id);
        assert_eq!(deserialized.status, presence.status);
        assert_eq!(deserialized.custom_status_text, presence.custom_status_text);
    }

    #[test]
    fn test_typing_indicator_serialization() {
        let now = chrono::Utc::now().timestamp_millis();
        let indicator = TypingIndicator {
            user_id: "user-a".to_string(),
            conversation_user_id: "user-b".to_string(),
            is_typing: true,
            started_at: now,
        };

        // Serialize to JSON
        let json = serde_json::to_string(&indicator).unwrap();
        assert!(json.contains("user-a"));
        assert!(json.contains("user-b"));
        assert!(json.contains("true"));

        // Deserialize back
        let deserialized: TypingIndicator = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.user_id, indicator.user_id);
        assert_eq!(deserialized.conversation_user_id, indicator.conversation_user_id);
        assert_eq!(deserialized.is_typing, indicator.is_typing);
    }

    #[test]
    fn test_presence_key_format() {
        let user_id = "user-test-123";
        let key = format!("/presence/{}", user_id);
        assert_eq!(key, "/presence/user-test-123");
    }

    #[test]
    fn test_typing_key_format() {
        let user_id = "user-a";
        let conversation_id = "user-b";
        let key = format!("/typing/{}/{}", user_id, conversation_id);
        assert_eq!(key, "/typing/user-a/user-b");
    }

    #[test]
    fn test_status_values() {
        // OFFLINE = 0
        // ONLINE = 1
        // AWAY = 2
        // DO_NOT_DISTURB = 3
        // INVISIBLE = 4
        
        let statuses = vec![
            (0, "OFFLINE"),
            (1, "ONLINE"),
            (2, "AWAY"),
            (3, "DO_NOT_DISTURB"),
            (4, "INVISIBLE"),
        ];

        for (value, _name) in &statuses {
            let presence = UserPresence {
                user_id: "test".to_string(),
                status: *value,
                ..Default::default()
            };
            assert_eq!(presence.status, *value);
        }
    }

    #[test]
    fn test_typing_indicator_stale_check_logic() {
        let now = chrono::Utc::now().timestamp_millis();
        
        // Fresh indicator (1 second ago)
        let fresh = TypingIndicator {
            user_id: "a".to_string(),
            conversation_user_id: "b".to_string(),
            is_typing: true,
            started_at: now - 1000,
        };
        assert!(now - fresh.started_at <= 10_000);
        
        // Stale indicator (15 seconds ago)
        let stale = TypingIndicator {
            user_id: "a".to_string(),
            conversation_user_id: "b".to_string(),
            is_typing: true,
            started_at: now - 15_000,
        };
        assert!(now - stale.started_at > 10_000);
    }

    #[test]
    fn test_custom_status_text_lengths() {
        // Empty status text
        let empty = UserPresence {
            custom_status_text: String::new(),
            ..Default::default()
        };
        assert_eq!(empty.custom_status_text.len(), 0);
        
        // Max allowed (100 chars)
        let max_text = "a".repeat(100);
        let max = UserPresence {
            custom_status_text: max_text.clone(),
            ..Default::default()
        };
        assert_eq!(max.custom_status_text.len(), 100);
        
        // Unicode status text
        let unicode = UserPresence {
            custom_status_text: "🎉 Celebrating! 🎊".to_string(),
            ..Default::default()
        };
        assert!(!unicode.custom_status_text.is_empty());
    }
}
