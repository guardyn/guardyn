//! Database Client for Media Service
//!
//! Uses TiKV for storing media metadata

use anyhow::Result;
use serde::{Deserialize, Serialize};
use tikv_client::RawClient;
use uuid::Uuid;

/// Database client for TiKV operations
#[derive(Clone)]
pub struct DatabaseClient {
    client: RawClient,
}

/// Media metadata stored in TiKV
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaMetadataRecord {
    pub media_id: String,
    pub owner_user_id: String,
    pub filename: String,
    pub media_type: i32,
    pub mime_type: String,
    pub size_bytes: i64,
    pub checksum_sha256: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub status: i32,
    pub width: Option<i32>,
    pub height: Option<i32>,
    pub duration_ms: Option<i32>,
    pub thumbnail_id: Option<String>,
    pub is_encrypted: bool,
    pub encryption_key_id: Option<Vec<u8>>,
    pub iv: Option<Vec<u8>>,
    pub conversation_id: Option<String>,
    pub message_id: Option<String>,
    pub storage_path: String,
}

impl DatabaseClient {
    /// Create a new database client
    pub async fn new(endpoints: &str) -> Result<Self> {
        let endpoints: Vec<&str> = endpoints.split(',').collect();
        let client = RawClient::new(endpoints).await?;
        Ok(Self { client })
    }

    /// Health check
    pub async fn health_check(&self) -> Result<()> {
        // Try to read a non-existent key to verify connectivity
        let _ = self.client.get("health_check".to_string()).await?;
        Ok(())
    }

    // Key format: /media/<media_id>
    fn media_key(media_id: &str) -> String {
        format!("/media/{}", media_id)
    }

    // Key format: /media/user/<user_id>/<media_id>
    fn user_media_key(user_id: &str, media_id: &str) -> String {
        format!("/media/user/{}/{}", user_id, media_id)
    }

    // Key format: /media/conversation/<conversation_id>/<media_id>
    fn conversation_media_key(conversation_id: &str, media_id: &str) -> String {
        format!("/media/conversation/{}/{}", conversation_id, media_id)
    }

    /// Store media metadata
    pub async fn store_media_metadata(&self, metadata: &MediaMetadataRecord) -> Result<()> {
        let data = serde_json::to_vec(metadata)?;
        
        // Store main record
        self.client
            .put(Self::media_key(&metadata.media_id), data.clone())
            .await?;

        // Index by user
        self.client
            .put(
                Self::user_media_key(&metadata.owner_user_id, &metadata.media_id),
                metadata.media_id.as_bytes().to_vec(),
            )
            .await?;

        // Index by conversation if present
        if let Some(ref conv_id) = metadata.conversation_id {
            self.client
                .put(
                    Self::conversation_media_key(conv_id, &metadata.media_id),
                    metadata.media_id.as_bytes().to_vec(),
                )
                .await?;
        }

        Ok(())
    }

    /// Get media metadata by ID
    pub async fn get_media_metadata(&self, media_id: &str) -> Result<Option<MediaMetadataRecord>> {
        let key = Self::media_key(media_id);
        if let Some(data) = self.client.get(key).await? {
            let metadata: MediaMetadataRecord = serde_json::from_slice(&data)?;
            Ok(Some(metadata))
        } else {
            Ok(None)
        }
    }

    /// Update media metadata
    pub async fn update_media_metadata(&self, metadata: &MediaMetadataRecord) -> Result<()> {
        self.store_media_metadata(metadata).await
    }

    /// Delete media metadata
    pub async fn delete_media_metadata(&self, media_id: &str) -> Result<Option<MediaMetadataRecord>> {
        // First get the metadata to clean up indexes
        if let Some(metadata) = self.get_media_metadata(media_id).await? {
            // Delete main record
            self.client.delete(Self::media_key(media_id)).await?;

            // Delete user index
            self.client
                .delete(Self::user_media_key(&metadata.owner_user_id, media_id))
                .await?;

            // Delete conversation index if present
            if let Some(ref conv_id) = metadata.conversation_id {
                self.client
                    .delete(Self::conversation_media_key(conv_id, media_id))
                    .await?;
            }

            Ok(Some(metadata))
        } else {
            Ok(None)
        }
    }

    /// List media by user
    pub async fn list_media_by_user(
        &self,
        user_id: &str,
        limit: usize,
        cursor: Option<&str>,
    ) -> Result<(Vec<MediaMetadataRecord>, Option<String>)> {
        let prefix = format!("/media/user/{}/", user_id);
        let start_key = cursor
            .map(|c| format!("{}{}", prefix, c))
            .unwrap_or_else(|| prefix.clone());
        let end_key = format!("{}{}", prefix, '\u{FFFF}');

        let keys = self.client
            .scan(start_key..end_key, (limit + 1) as u32)
            .await?;

        let mut records = Vec::with_capacity(limit);
        let mut next_cursor = None;

        for (i, kv) in keys.into_iter().enumerate() {
            if i >= limit {
                // Extract media_id from key for next cursor
                let key_str = String::from_utf8_lossy(kv.key().into());
                if let Some(media_id) = key_str.strip_prefix(&prefix) {
                    next_cursor = Some(media_id.to_string());
                }
                break;
            }

            let media_id = String::from_utf8_lossy(kv.value()).to_string();
            if let Some(metadata) = self.get_media_metadata(&media_id).await? {
                records.push(metadata);
            }
        }

        Ok((records, next_cursor))
    }

    /// List media by conversation
    pub async fn list_media_by_conversation(
        &self,
        conversation_id: &str,
        limit: usize,
        cursor: Option<&str>,
    ) -> Result<(Vec<MediaMetadataRecord>, Option<String>)> {
        let prefix = format!("/media/conversation/{}/", conversation_id);
        let start_key = cursor
            .map(|c| format!("{}{}", prefix, c))
            .unwrap_or_else(|| prefix.clone());
        let end_key = format!("{}{}", prefix, '\u{FFFF}');

        let keys = self.client
            .scan(start_key..end_key, (limit + 1) as u32)
            .await?;

        let mut records = Vec::with_capacity(limit);
        let mut next_cursor = None;

        for (i, kv) in keys.into_iter().enumerate() {
            if i >= limit {
                let key_str = String::from_utf8_lossy(kv.key().into());
                if let Some(media_id) = key_str.strip_prefix(&prefix) {
                    next_cursor = Some(media_id.to_string());
                }
                break;
            }

            let media_id = String::from_utf8_lossy(kv.value()).to_string();
            if let Some(metadata) = self.get_media_metadata(&media_id).await? {
                records.push(metadata);
            }
        }

        Ok((records, next_cursor))
    }

    /// Generate a new media ID
    pub fn generate_media_id() -> String {
        Uuid::new_v4().to_string()
    }
}
