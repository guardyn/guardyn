/// Database clients for Messaging Service
///
/// - TiKV: Delivery state, session tracking
/// - ScyllaDB: Message history, media metadata

use crate::models::*;
use anyhow::{Context, Result};
use serde_json;
use tikv_client::{RawClient, TransactionClient};
use scylla::{Session, SessionBuilder};
use std::sync::Arc;

/// Combined database client
pub struct DatabaseClient {
    tikv: Arc<RawClient>,
    scylla: Arc<Session>,
}

impl DatabaseClient {
    /// Initialize database connections
    pub async fn new(tikv_endpoints: Vec<String>, scylla_nodes: Vec<String>) -> Result<Self> {
        // Connect to TiKV
        let tikv = RawClient::new(tikv_endpoints)
            .await
            .context("Failed to connect to TiKV")?;

        // Connect to ScyllaDB
        let scylla = SessionBuilder::new()
            .known_nodes(&scylla_nodes)
            .build()
            .await
            .context("Failed to connect to ScyllaDB")?;

        // Initialize ScyllaDB schema
        Self::init_scylla_schema(&scylla).await?;

        Ok(Self {
            tikv: Arc::new(tikv),
            scylla: Arc::new(scylla),
        })
    }

    /// Initialize ScyllaDB keyspace and tables
    async fn init_scylla_schema(session: &Session) -> Result<()> {
        // Create keyspace if not exists
        session
            .query_unpaged(
                "CREATE KEYSPACE IF NOT EXISTS guardyn 
                 WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3}",
                &[],
            )
            .await
            .context("Failed to create keyspace")?;

        // Create messages table (1-on-1 conversations)
        session
            .query_unpaged(
                "CREATE TABLE IF NOT EXISTS guardyn.messages (
                    conversation_id UUID,
                    message_id UUID,
                    sender_user_id TEXT,
                    sender_device_id TEXT,
                    recipient_user_id TEXT,
                    recipient_device_id TEXT,
                    encrypted_content BLOB,
                    message_type INT,
                    server_timestamp BIGINT,
                    client_timestamp BIGINT,
                    delivery_status INT,
                    is_deleted BOOLEAN,
                    PRIMARY KEY (conversation_id, message_id)
                ) WITH CLUSTERING ORDER BY (message_id DESC)",
                &[],
            )
            .await
            .context("Failed to create messages table")?;

        // Create group_messages table (group conversations)
        session
            .query_unpaged(
                "CREATE TABLE IF NOT EXISTS guardyn.group_messages (
                    group_id UUID,
                    message_id UUID,
                    sender_user_id TEXT,
                    sender_device_id TEXT,
                    encrypted_content BLOB,
                    message_type INT,
                    server_timestamp BIGINT,
                    client_timestamp BIGINT,
                    is_deleted BOOLEAN,
                    PRIMARY KEY (group_id, message_id)
                ) WITH CLUSTERING ORDER BY (message_id DESC)",
                &[],
            )
            .await
            .context("Failed to create group_messages table")?;

        tracing::info!("ScyllaDB schema initialized (messages + group_messages)");
        Ok(())
    }

    // ========================================================================
    // Delivery State Operations (TiKV)
    // ========================================================================

    /// Store delivery state for a message
    pub async fn store_delivery_state(&self, state: &DeliveryState) -> Result<()> {
        let key = format!("/delivery/{}/{}", state.recipient_user_id, state.message_id);
        let value = serde_json::to_vec(state)?;
        self.tikv.put(key.into_bytes(), value).await?;

        // Also index by message_id for quick lookup
        let msg_key = format!("/delivery/msg/{}", state.message_id);
        let msg_value = serde_json::to_vec(state)?;
        self.tikv.put(msg_key.into_bytes(), msg_value).await?;

        Ok(())
    }

    /// Get delivery state for a message
    pub async fn get_delivery_state(&self, message_id: &str) -> Result<Option<DeliveryState>> {
        let key = format!("/delivery/msg/{}", message_id);
        let value = self.tikv.get(key.into_bytes()).await?;

        match value {
            Some(bytes) => {
                let state = serde_json::from_slice(&bytes)?;
                Ok(Some(state))
            }
            None => Ok(None),
        }
    }

    /// Update delivery status
    pub async fn update_delivery_status(
        &self,
        message_id: &str,
        status: DeliveryStatus,
    ) -> Result<()> {
        let mut state = self
            .get_delivery_state(message_id)
            .await?
            .context("Delivery state not found")?;

        state.status = status;
        state.updated_at = chrono::Utc::now().timestamp();

        self.store_delivery_state(&state).await?;
        Ok(())
    }

    /// Get pending messages for a recipient
    pub async fn get_pending_messages(&self, recipient_user_id: &str) -> Result<Vec<DeliveryState>> {
        let prefix = format!("/delivery/{}/", recipient_user_id);
        let keys = self.tikv.scan(prefix.into_bytes().., 1000).await?;

        let mut states = Vec::new();
        for kv_pair in keys {
            if let Ok(state) = serde_json::from_slice::<DeliveryState>(&kv_pair.1) {
                if state.status == DeliveryStatus::Pending {
                    states.push(state);
                }
            }
        }

        Ok(states)
    }

    // ========================================================================
    // Message History Operations (ScyllaDB)
    // ========================================================================

    /// Store message in ScyllaDB
    pub async fn store_message(&self, msg: &StoredMessage) -> Result<()> {
        let query = "INSERT INTO guardyn.messages (
            conversation_id, message_id, sender_user_id, sender_device_id,
            recipient_user_id, recipient_device_id, encrypted_content,
            message_type, server_timestamp, client_timestamp,
            delivery_status, is_deleted
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        tracing::debug!("Parsing conversation_id: {}", msg.conversation_id);
        let conversation_uuid = uuid::Uuid::parse_str(&msg.conversation_id)
            .map_err(|e| {
                tracing::error!("Failed to parse conversation_id '{}': {:?}", msg.conversation_id, e);
                e
            })?;

        tracing::debug!("Parsing message_id: {}", msg.message_id);
        let message_uuid = uuid::Uuid::parse_str(&msg.message_id)
            .map_err(|e| {
                tracing::error!("Failed to parse message_id '{}': {:?}", msg.message_id, e);
                e
            })?;

        tracing::debug!("Executing ScyllaDB query with {} params", 12);
        let result = self.scylla
            .query_unpaged(
                query,
                (
                    conversation_uuid,
                    message_uuid,
                    &msg.sender_user_id,
                    &msg.sender_device_id,
                    &msg.recipient_user_id,
                    &msg.recipient_device_id,
                    &msg.encrypted_content,
                    msg.message_type,
                    msg.server_timestamp,
                    msg.client_timestamp,
                    msg.delivery_status,
                    msg.is_deleted,
                ),
            )
            .await;

        match result {
            Ok(_) => {
                tracing::debug!("Message stored successfully");
                Ok(())
            }
            Err(e) => {
                tracing::error!("ScyllaDB query failed: {:?}", e);
                Err(anyhow::anyhow!("Failed to store message in ScyllaDB: {}", e))
            }
        }
    }

    /// Get message history for a conversation
    pub async fn get_messages(
        &self,
        conversation_id: &str,
        limit: i32,
    ) -> Result<Vec<StoredMessage>> {
        let query = "SELECT conversation_id, message_id, sender_user_id, sender_device_id, \
                            recipient_user_id, recipient_device_id, encrypted_content, \
                            message_type, server_timestamp, client_timestamp, \
                            delivery_status, is_deleted \
                     FROM guardyn.messages 
                     WHERE conversation_id = ? 
                     LIMIT ?";

        let conversation_uuid = uuid::Uuid::parse_str(conversation_id)?;

        let rows = self
            .scylla
            .query_unpaged(query, (conversation_uuid, limit))
            .await
            .context("Failed to fetch messages from ScyllaDB")?;

        let mut messages = Vec::new();
        if let Some(rows) = rows.rows {
            for row in rows {
                // Parse row into StoredMessage
                // Column order matches table definition:
                // 0: conversation_id, 1: message_id, 2: sender_user_id, 3: sender_device_id,
                // 4: recipient_user_id, 5: recipient_device_id (nullable), 6: encrypted_content,
                // 7: message_type, 8: server_timestamp, 9: client_timestamp,
                // 10: delivery_status, 11: is_deleted

                // Safe extraction with error context
                let conversation_id = row.columns.get(0)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_uuid())
                    .map(|u| u.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing conversation_id"))?;

                let message_id = row.columns.get(1)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_uuid())
                    .map(|u| u.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing message_id"))?;

                let sender_user_id = row.columns.get(2)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing sender_user_id"))?;

                let sender_device_id = row.columns.get(3)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing sender_device_id"))?;

                let recipient_user_id = row.columns.get(4)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing recipient_user_id"))?;

                let recipient_device_id = row.columns.get(5)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string()); // Nullable field - no error

                let encrypted_content = row.columns.get(6)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_blob())
                    .map(|b| b.to_vec())
                    .ok_or_else(|| anyhow::anyhow!("Missing encrypted_content"))?;

                let message_type = row.columns.get(7)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_int())
                    .ok_or_else(|| anyhow::anyhow!("Missing message_type"))?;

                let server_timestamp = row.columns.get(8)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_bigint())
                    .ok_or_else(|| anyhow::anyhow!("Missing server_timestamp"))?;

                let client_timestamp = row.columns.get(9)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_bigint())
                    .ok_or_else(|| anyhow::anyhow!("Missing client_timestamp"))?;

                let delivery_status = row.columns.get(10)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_int())
                    .ok_or_else(|| anyhow::anyhow!("Missing delivery_status"))?;

                let is_deleted = row.columns.get(11)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_boolean())
                    .ok_or_else(|| anyhow::anyhow!("Missing is_deleted"))?;

                let msg = StoredMessage {
                    conversation_id,
                    message_id,
                    sender_user_id,
                    sender_device_id,
                    recipient_user_id,
                    recipient_device_id,
                    encrypted_content,
                    message_type,
                    server_timestamp,
                    client_timestamp,
                    delivery_status,
                    is_deleted,
                };
                messages.push(msg);
            }
        }

        Ok(messages)
    }

    /// Mark message as deleted
    pub async fn delete_message(&self, conversation_id: &str, message_id: &str) -> Result<()> {
        let query = "UPDATE guardyn.messages 
                     SET is_deleted = true 
                     WHERE conversation_id = ? AND message_id = ?";

        let conversation_uuid = uuid::Uuid::parse_str(conversation_id)?;
        let message_uuid = uuid::Uuid::parse_str(message_id)?;

        self.scylla
            .query_unpaged(query, (conversation_uuid, message_uuid))
            .await
            .context("Failed to delete message")?;

        Ok(())
    }

    // ========================================================================
    // Group Chat Operations (TiKV + ScyllaDB)
    // ========================================================================

    /// Store group metadata in TiKV
    pub async fn create_group(&self, group: &GroupMetadata) -> Result<()> {
        let key = format!("/groups/{}", group.group_id);
        let value = serde_json::to_vec(group)?;
        self.tikv.put(key.into_bytes(), value).await?;
        Ok(())
    }

    /// Get group metadata
    pub async fn get_group(&self, group_id: &str) -> Result<Option<GroupMetadata>> {
        let key = format!("/groups/{}", group_id);
        let value = self.tikv.get(key.into_bytes()).await?;

        match value {
            Some(bytes) => {
                let group = serde_json::from_slice(&bytes)?;
                Ok(Some(group))
            }
            None => Ok(None),
        }
    }

    /// Add group member
    pub async fn add_group_member(&self, member: &GroupMember) -> Result<()> {
        let key = format!("/groups/{}/members/{}", member.group_id, member.user_id);
        let value = serde_json::to_vec(member)?;
        self.tikv.put(key.into_bytes(), value).await?;
        Ok(())
    }

    /// Get group members
    pub async fn get_group_members(&self, group_id: &str) -> Result<Vec<GroupMember>> {
        let prefix = format!("/groups/{}/members/", group_id);
        let keys = self.tikv.scan(prefix.into_bytes().., 1000).await?;

        let mut members = Vec::new();
        for kv_pair in keys {
            if let Ok(member) = serde_json::from_slice::<GroupMember>(&kv_pair.1) {
                members.push(member);
            }
        }

        Ok(members)
    }

    // ========================================================================
    // Group Message Operations (ScyllaDB)
    // ========================================================================

    /// Store group message in ScyllaDB
    pub async fn store_group_message(&self, msg: &GroupMessage) -> Result<()> {
        let query = "INSERT INTO guardyn.group_messages (
            group_id, message_id, sender_user_id, sender_device_id,
            encrypted_content, message_type, server_timestamp, 
            client_timestamp, is_deleted
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        let group_uuid = uuid::Uuid::parse_str(&msg.group_id)?;
        let message_uuid = uuid::Uuid::parse_str(&msg.message_id)?;

        self.scylla
            .query_unpaged(
                query,
                (
                    group_uuid,
                    message_uuid,
                    &msg.sender_user_id,
                    &msg.sender_device_id,
                    &msg.encrypted_content,
                    msg.message_type,
                    msg.server_timestamp,
                    msg.client_timestamp,
                    msg.is_deleted,
                ),
            )
            .await
            .context("Failed to store group message in ScyllaDB")?;

        Ok(())
    }

    /// Get group message history
    pub async fn get_group_messages(
        &self,
        group_id: &str,
        limit: i32,
    ) -> Result<Vec<GroupMessage>> {
        let query = "SELECT group_id, message_id, sender_user_id, sender_device_id, \
                            encrypted_content, message_type, server_timestamp, \
                            client_timestamp, is_deleted \
                     FROM guardyn.group_messages 
                     WHERE group_id = ? 
                     LIMIT ?";

        let group_uuid = uuid::Uuid::parse_str(group_id)?;

        let rows = self
            .scylla
            .query_unpaged(query, (group_uuid, limit))
            .await
            .context("Failed to fetch group messages from ScyllaDB")?;

        let mut messages = Vec::new();
        if let Some(rows) = rows.rows {
            for row in rows {
                // Parse row into GroupMessage
                // Column order: 0: group_id, 1: message_id, 2: sender_user_id, 3: sender_device_id,
                // 4: encrypted_content, 5: message_type, 6: server_timestamp, 7: client_timestamp,
                // 8: is_deleted

                let message_id = row.columns.get(1)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_uuid())
                    .map(|u| u.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing message_id"))?;

                let sender_user_id = row.columns.get(2)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing sender_user_id"))?;

                let sender_device_id = row.columns.get(3)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .ok_or_else(|| anyhow::anyhow!("Missing sender_device_id"))?;

                let encrypted_content = row.columns.get(4)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_blob())
                    .map(|b| b.to_vec())
                    .ok_or_else(|| anyhow::anyhow!("Missing encrypted_content"))?;

                let message_type = row.columns.get(5)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_int())
                    .ok_or_else(|| anyhow::anyhow!("Missing message_type"))?;

                let server_timestamp = row.columns.get(6)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_bigint())
                    .ok_or_else(|| anyhow::anyhow!("Missing server_timestamp"))?;

                let client_timestamp = row.columns.get(7)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_bigint())
                    .ok_or_else(|| anyhow::anyhow!("Missing client_timestamp"))?;

                let is_deleted = row.columns.get(8)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_boolean())
                    .ok_or_else(|| anyhow::anyhow!("Missing is_deleted"))?;

                let msg = GroupMessage {
                    message_id,
                    group_id: group_id.to_string(),
                    sender_user_id,
                    sender_device_id,
                    encrypted_content,
                    message_type,
                    server_timestamp,
                    client_timestamp,
                    is_deleted,
                };
                messages.push(msg);
            }
        }

        Ok(messages)
    }

    /// Mark group message as deleted
    pub async fn delete_group_message(&self, group_id: &str, message_id: &str) -> Result<()> {
        let query = "UPDATE guardyn.group_messages 
                     SET is_deleted = true 
                     WHERE group_id = ? AND message_id = ?";

        let group_uuid = uuid::Uuid::parse_str(group_id)?;
        let message_uuid = uuid::Uuid::parse_str(message_id)?;

        self.scylla
            .query_unpaged(query, (group_uuid, message_uuid))
            .await
            .context("Failed to delete group message")?;

        Ok(())
    }
}
