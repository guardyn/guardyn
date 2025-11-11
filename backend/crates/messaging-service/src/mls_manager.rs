/// MLS Group Manager Integration for Messaging Service
///
/// Provides a high-level interface to manage MLS group state,
/// including serialization, TiKV storage, and integration with
/// the crypto crate's MlsGroupManager.

use crate::db::DatabaseClient;
use anyhow::{Context, Result};
use guardyn_crypto::mls::{MlsGroupManager, MlsGroupState};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tracing::{error, info};

/// Group state storage paths in TiKV
const MLS_GROUP_STATE_PREFIX: &str = "/mls/groups";
const MLS_GROUP_MEMBERS_PREFIX: &str = "/mls/group_members";

/// MLS Manager for Messaging Service
///
/// Manages MLS group state persistence and provides helper methods
/// for group operations (create, add/remove members, encrypt/decrypt).
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

    /// Create a new MLS group
    ///
    /// # Arguments
    /// * `group_id` - Unique group identifier
    /// * `creator_identity` - Creator's identity (user_id:device_id)
    /// * `credential_bundle_bytes` - Serialized credential bundle
    ///
    /// # Returns
    /// Serialized group state for initial storage
    pub async fn create_group(
        &self,
        group_id: &str,
        creator_user_id: &str,
        creator_device_id: &str,
        creator_identity: &[u8],
    ) -> Result<MlsGroupState> {
        info!("Creating MLS group: {}", group_id);

        // Create MLS group using crypto crate
        // Note: In a real implementation, we need to pass the actual credential bundle
        // For now, we'll generate it on the fly (should be fetched from user's stored credentials)
        let credential_bundle = guardyn_crypto::mls::create_test_credential(
            &String::from_utf8_lossy(creator_identity)
        )?;

        let group_manager = MlsGroupManager::create_group(
            group_id,
            creator_identity,
            credential_bundle,
        )?;

        // Serialize group state
        let group_state = group_manager.serialize_state()?;

        // Store group state in TiKV
        let state_key = format!("{}/{}/state", MLS_GROUP_STATE_PREFIX, group_id);
        let state_json = serde_json::to_vec(&group_state)
            .context("Failed to serialize group state")?;
        self.db.put(state_key.as_bytes(), state_json).await?;

        // Store group metadata
        let metadata = GroupMetadata {
            group_id: group_id.to_string(),
            creator_user_id: creator_user_id.to_string(),
            creator_device_id: creator_device_id.to_string(),
            created_at: chrono::Utc::now().timestamp(),
            current_epoch: 0,
            member_count: 1,
        };

        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_STATE_PREFIX, group_id);
        let metadata_json = serde_json::to_vec(&metadata)
            .context("Failed to serialize metadata")?;
        self.db.put(metadata_key.as_bytes(), metadata_json).await?;

        // Add creator to members list
        self.add_member_to_list(group_id, creator_user_id, creator_device_id).await?;

        info!("MLS group created: {}", group_id);
        Ok(group_state)
    }

    /// Load MLS group state from TiKV
    ///
    /// # Arguments
    /// * `group_id` - Unique group identifier
    ///
    /// # Returns
    /// Deserialized MLS group state
    pub async fn load_group_state(&self, group_id: &str) -> Result<MlsGroupState> {
        let state_key = format!("{}/{}/state", MLS_GROUP_STATE_PREFIX, group_id);
        
        let state_bytes = self.db.get(state_key.as_bytes()).await?
            .ok_or_else(|| anyhow::anyhow!("Group state not found: {}", group_id))?;

        let group_state: MlsGroupState = serde_json::from_slice(&state_bytes)
            .context("Failed to deserialize group state")?;

        Ok(group_state)
    }

    /// Save MLS group state to TiKV
    ///
    /// # Arguments
    /// * `group_id` - Unique group identifier
    /// * `group_state` - Serialized group state to save
    pub async fn save_group_state(&self, group_id: &str, group_state: &MlsGroupState) -> Result<()> {
        let state_key = format!("{}/{}/state", MLS_GROUP_STATE_PREFIX, group_id);
        let state_json = serde_json::to_vec(group_state)
            .context("Failed to serialize group state")?;
        
        self.db.put(state_key.as_bytes(), state_json).await?;

        // Update epoch in metadata
        self.update_epoch(group_id, group_state.epoch).await?;

        Ok(())
    }

    /// Update group epoch in metadata
    async fn update_epoch(&self, group_id: &str, epoch: u64) -> Result<()> {
        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_STATE_PREFIX, group_id);
        
        if let Some(metadata_bytes) = self.db.get(metadata_key.as_bytes()).await? {
            let mut metadata: GroupMetadata = serde_json::from_slice(&metadata_bytes)
                .context("Failed to deserialize metadata")?;
            
            metadata.current_epoch = epoch;
            
            let updated_json = serde_json::to_vec(&metadata)
                .context("Failed to serialize metadata")?;
            self.db.put(metadata_key.as_bytes(), updated_json).await?;
        }

        Ok(())
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
            MLS_GROUP_MEMBERS_PREFIX,
            group_id,
            user_id,
            device_id
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
            MLS_GROUP_MEMBERS_PREFIX,
            group_id,
            user_id,
            device_id
        );

        self.db.delete(member_key.as_bytes()).await?;

        // Decrement member count
        self.decrement_member_count(group_id).await?;

        Ok(())
    }

    /// Increment member count in metadata
    async fn increment_member_count(&self, group_id: &str) -> Result<()> {
        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_STATE_PREFIX, group_id);
        
        if let Some(metadata_bytes) = self.db.get(metadata_key.as_bytes()).await? {
            let mut metadata: GroupMetadata = serde_json::from_slice(&metadata_bytes)
                .context("Failed to deserialize metadata")?;
            
            metadata.member_count += 1;
            
            let updated_json = serde_json::to_vec(&metadata)
                .context("Failed to serialize metadata")?;
            self.db.put(metadata_key.as_bytes(), updated_json).await?;
        }

        Ok(())
    }

    /// Decrement member count in metadata
    async fn decrement_member_count(&self, group_id: &str) -> Result<()> {
        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_STATE_PREFIX, group_id);
        
        if let Some(metadata_bytes) = self.db.get(metadata_key.as_bytes()).await? {
            let mut metadata: GroupMetadata = serde_json::from_slice(&metadata_bytes)
                .context("Failed to deserialize metadata")?;
            
            if metadata.member_count > 0 {
                metadata.member_count -= 1;
            }
            
            let updated_json = serde_json::to_vec(&metadata)
                .context("Failed to serialize metadata")?;
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
        let metadata_key = format!("{}/{}/metadata", MLS_GROUP_STATE_PREFIX, group_id);
        
        match self.db.get(metadata_key.as_bytes()).await? {
            Some(metadata_bytes) => {
                let metadata: GroupMetadata = serde_json::from_slice(&metadata_bytes)
                    .context("Failed to deserialize metadata")?;
                Ok(Some(metadata))
            }
            None => Ok(None),
        }
    }

    /// Check if user is a member of the group
    ///
    /// # Arguments
    /// * `group_id` - Group identifier
    /// * `user_id` - User to check
    /// * `device_id` - Device to check
    ///
    /// # Returns
    /// true if user/device is a member
    pub async fn is_member(
        &self,
        group_id: &str,
        user_id: &str,
        device_id: &str,
    ) -> Result<bool> {
        let member_key = format!(
            "{}/{}/{}:{}",
            MLS_GROUP_MEMBERS_PREFIX,
            group_id,
            user_id,
            device_id
        );

        Ok(self.db.get(member_key.as_bytes()).await?.is_some())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_mls_manager_creation() {
        // This test requires a TiKV connection
        // For unit testing, we should mock the DatabaseClient
        // Integration tests should use a real TiKV instance
    }
}
