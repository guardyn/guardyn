//! MLS membership index for the messaging service.
//!
//! The server keeps a membership list and a monotonic epoch counter, and
//! nothing else. Group state, epoch secrets and credentials live on the
//! clients; the server routes opaque `Welcome`, `Commit` and ciphertext blobs
//! and cannot read any of them.

use crate::db::DatabaseClient;
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::sync::Arc;

/// Group metadata storage paths in TiKV
const MLS_GROUP_METADATA_PREFIX: &str = "/mls/groups";
const MLS_GROUP_MEMBERS_PREFIX: &str = "/mls/group_members";

/// MLS membership index.
///
/// Tracks who is in a group and which epoch the group is on. Deliberately has
/// no group-state, encrypt or decrypt operations: holding those server-side is
/// what invariant I-1 forbids.
#[allow(dead_code)]
pub struct MlsManager {
    db: Arc<DatabaseClient>,
}

/// Persisted group metadata
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupMetadata {
    pub group_id: String,
    pub creator_user_id: String,
    pub creator_device_id: String,
    pub created_at: i64,
    pub current_epoch: u64,
    pub member_count: usize,
}

impl MlsManager {
    /// Create a new MLS manager instance
    pub fn new(db: Arc<DatabaseClient>) -> Self {
        Self { db }
    }

    /// Add member to group members list
    ///
    /// # Arguments
    /// * `group_id` - Group identifier
    /// * `user_id` - User to add
    /// * `device_id` - Device to add
    pub async fn add_member_to_list(
        &self,
        group_id: &str,
        user_id: &str,
        device_id: &str,
    ) -> Result<()> {
        let member_key = format!(
            "{}/{}/{}:{}",
            MLS_GROUP_MEMBERS_PREFIX, group_id, user_id, device_id
        );

        let member_data = serde_json::to_vec(&serde_json::json!({
            "user_id": user_id,
            "device_id": device_id,
            "added_at": chrono::Utc::now().timestamp(),
        }))?;

        self.db.put(member_key.as_bytes(), member_data).await?;

        // Increment member count
        self.increment_member_count(group_id).await?;

        Ok(())
    }

    /// Remove member from group members list
    ///
    /// # Arguments
    /// * `group_id` - Group identifier
    /// * `user_id` - User to remove
    /// * `device_id` - Device to remove
    pub async fn remove_member_from_list(
        &self,
        group_id: &str,
        user_id: &str,
        device_id: &str,
    ) -> Result<()> {
        let member_key = format!(
            "{}/{}/{}:{}",
            MLS_GROUP_MEMBERS_PREFIX, group_id, user_id, device_id
        );

        self.db.delete(member_key.as_bytes()).await?;

        // Decrement member count
        self.decrement_member_count(group_id).await?;

        Ok(())
    }

    /// Increment member count in metadata
    async fn increment_member_count(&self, group_id: &str) -> Result<()> {
        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_METADATA_PREFIX, group_id);

        if let Some(metadata_bytes) = self.db.get(metadata_key.as_bytes()).await? {
            let mut metadata: GroupMetadata = serde_json::from_slice(&metadata_bytes)
                .context("Failed to deserialize metadata")?;

            metadata.member_count += 1;

            let updated_json =
                serde_json::to_vec(&metadata).context("Failed to serialize metadata")?;
            self.db.put(metadata_key.as_bytes(), updated_json).await?;
        }

        Ok(())
    }

    /// Decrement member count in metadata
    async fn decrement_member_count(&self, group_id: &str) -> Result<()> {
        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_METADATA_PREFIX, group_id);

        if let Some(metadata_bytes) = self.db.get(metadata_key.as_bytes()).await? {
            let mut metadata: GroupMetadata = serde_json::from_slice(&metadata_bytes)
                .context("Failed to deserialize metadata")?;

            if metadata.member_count > 0 {
                metadata.member_count -= 1;
            }

            let updated_json =
                serde_json::to_vec(&metadata).context("Failed to serialize metadata")?;
            self.db.put(metadata_key.as_bytes(), updated_json).await?;
        }

        Ok(())
    }

    /// Get group metadata
    ///
    /// # Arguments
    /// * `group_id` - Group identifier
    ///
    /// # Returns
    /// Group metadata if exists
    pub async fn get_metadata(&self, group_id: &str) -> Result<Option<GroupMetadata>> {
        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_METADATA_PREFIX, group_id);

        match self.db.get(metadata_key.as_bytes()).await? {
            Some(metadata_bytes) => {
                let metadata: GroupMetadata = serde_json::from_slice(&metadata_bytes)
                    .context("Failed to deserialize metadata")?;
                Ok(Some(metadata))
            }
            None => Ok(None),
        }
    }

    /// Get the current MLS epoch for a group.
    ///
    /// Returns 0 for a group with no metadata: the epoch is a counter the
    /// clients advance, and a group the server has not seen a commit for is at
    /// its initial epoch.
    pub async fn get_current_epoch(&self, group_id: &str) -> Result<u64> {
        Ok(self
            .get_metadata(group_id)
            .await?
            .map_or(0, |metadata| metadata.current_epoch))
    }
}

#[cfg(test)]
mod tests {
    #[allow(unused_imports)]
    use super::*;

    #[tokio::test]
    async fn test_mls_manager_creation() {
        // This test requires a TiKV connection
        // For unit testing, we should mock the DatabaseClient
        // Integration tests should use a real TiKV instance
    }
}
