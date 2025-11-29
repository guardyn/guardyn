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
