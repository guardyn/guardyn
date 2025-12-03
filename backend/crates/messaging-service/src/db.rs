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
        // Uses TIMEUUID for message_id to enable time-based ordering
        session
            .query_unpaged(
                "CREATE TABLE IF NOT EXISTS guardyn.group_messages (
                    group_id UUID,
                    message_id TIMEUUID,
                    sender_user_id TEXT,
                    sender_device_id TEXT,
                    encrypted_content BLOB,
                    mls_epoch BIGINT,
                    sent_at TIMESTAMP,
                    metadata MAP<TEXT, TEXT>,
                    PRIMARY KEY (group_id, message_id)
                ) WITH CLUSTERING ORDER BY (message_id DESC)",
                &[],
            )
            .await
            .context("Failed to create group_messages table")?;

        // Migration: Add missing columns to existing group_messages table
        // This handles existing deployments that have the old schema
        let _ = session
            .query_unpaged(
                "ALTER TABLE guardyn.group_messages ADD mls_epoch BIGINT",
                &[],
            )
            .await;
        let _ = session
            .query_unpaged(
                "ALTER TABLE guardyn.group_messages ADD sent_at TIMESTAMP",
                &[],
            )
            .await;
        let _ = session
            .query_unpaged(
                "ALTER TABLE guardyn.group_messages ADD metadata MAP<TEXT, TEXT>",
                &[],
            )
            .await;

        // Create conversations table for efficient conversation list queries
        // Partition by user_id allows single-query retrieval of all conversations
        // Stores conversation metadata for both participants (denormalized for read performance)
        session
            .query_unpaged(
                "CREATE TABLE IF NOT EXISTS guardyn.conversations (
                    user_id TEXT,
                    conversation_id UUID,
                    other_user_id TEXT,
                    other_username TEXT,
                    last_message_id UUID,
                    last_message_preview TEXT,
                    last_message_time TIMESTAMP,
                    unread_count INT,
                    PRIMARY KEY (user_id, last_message_time, conversation_id)
                ) WITH CLUSTERING ORDER BY (last_message_time DESC, conversation_id ASC)",
                &[],
            )
            .await
            .context("Failed to create conversations table")?;

        tracing::info!("ScyllaDB schema initialized (messages + group_messages + conversations)");
        Ok(())
    }

    // ========================================================================
    // Low-level TiKV Operations
    // ========================================================================

    /// Put a key-value pair into TiKV
    pub async fn put(&self, key: &[u8], value: Vec<u8>) -> Result<()> {
        self.tikv
            .put(key.to_vec(), value)
            .await
            .context("TiKV put failed")?;
        Ok(())
    }

    /// Get a value from TiKV by key
    pub async fn get(&self, key: &[u8]) -> Result<Option<Vec<u8>>> {
        self.tikv
            .get(key.to_vec())
            .await
            .context("TiKV get failed")
    }

    /// Delete a key from TiKV
    pub async fn delete(&self, key: &[u8]) -> Result<()> {
        self.tikv
            .delete(key.to_vec())
            .await
            .context("TiKV delete failed")?;
        Ok(())
    }

    /// Get a message by ID from ScyllaDB (for E2EE decryption)
    pub async fn get_message(&self, message_id: &str) -> Result<Option<StoredMessage>> {
        // Note: This is inefficient as it requires scanning, but needed for E2EE
        // In production, consider maintaining a message_id -> conversation_id index
        let query = "SELECT * FROM guardyn.messages WHERE message_id = ? ALLOW FILTERING";
        let message_uuid = uuid::Uuid::parse_str(message_id)
            .context("Invalid message_id UUID")?;

        let rows = self.scylla
            .query_unpaged(query, (message_uuid,))
            .await
            .context("Failed to query message by ID")?;

        if let Some(row) = rows.rows.and_then(|r| r.into_iter().next()) {
            let conversation_id: uuid::Uuid = row.columns[0].as_ref()
                .and_then(|v| v.as_uuid())
                .context("Missing conversation_id")?;
            let message_id: uuid::Uuid = row.columns[1].as_ref()
                .and_then(|v| v.as_uuid())
                .context("Missing message_id")?;
            let sender_user_id: String = row.columns[2].as_ref()
                .and_then(|v| v.as_text())
                .context("Missing sender_user_id")?
                .to_string();
            let sender_device_id: String = row.columns[3].as_ref()
                .and_then(|v| v.as_text())
                .context("Missing sender_device_id")?
                .to_string();
            let recipient_user_id: String = row.columns[4].as_ref()
                .and_then(|v| v.as_text())
                .context("Missing recipient_user_id")?
                .to_string();
            let recipient_device_id: String = row.columns[5].as_ref()
                .and_then(|v| v.as_text())
                .context("Missing recipient_device_id")?
                .to_string();
            let encrypted_content: Vec<u8> = row.columns[6].as_ref()
                .and_then(|v| v.as_blob())
                .context("Missing encrypted_content")?
                .to_vec();
            let message_type: i32 = row.columns[7].as_ref()
                .and_then(|v| v.as_int())
                .context("Missing message_type")?;
            let server_timestamp: i64 = row.columns[8].as_ref()
                .and_then(|v| v.as_bigint())
                .context("Missing server_timestamp")?;
            let client_timestamp: i64 = row.columns[9].as_ref()
                .and_then(|v| v.as_bigint())
                .context("Missing client_timestamp")?;
            let delivery_status: i32 = row.columns[10].as_ref()
                .and_then(|v| v.as_int())
                .context("Missing delivery_status")?;
            let is_deleted: bool = row.columns[11].as_ref()
                .and_then(|v| v.as_boolean())
                .unwrap_or(false);

            let msg = StoredMessage {
                conversation_id: conversation_id.to_string(),
                message_id: message_id.to_string(),
                sender_user_id,
                sender_device_id,
                recipient_user_id,
                recipient_device_id: Some(recipient_device_id),
                encrypted_content,
                message_type,
                server_timestamp,
                client_timestamp,
                delivery_status,
                is_deleted,
            };
            Ok(Some(msg))
        } else {
            Ok(None)
        }
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

    /// Get recent conversations for a user
    /// Returns a list of conversations with the last message in each
    pub async fn get_recent_conversations(
        &self,
        user_id: &str,
        limit: i32,
    ) -> Result<Vec<crate::proto::messaging::Conversation>> {
        // For MVP, we'll query messages table and group by conversation_id
        // In production, this should use a materialized view or separate conversations table
        // ScyllaDB doesn't support OR in WHERE clause, so we run two separate queries

        let query_sender = "SELECT conversation_id, message_id, sender_user_id, sender_device_id, \
                            recipient_user_id, recipient_device_id, encrypted_content, \
                            message_type, server_timestamp, client_timestamp, \
                            delivery_status, is_deleted \
                     FROM guardyn.messages \
                     WHERE sender_user_id = ? \
                     LIMIT ? \
                     ALLOW FILTERING";

        let query_recipient = "SELECT conversation_id, message_id, sender_user_id, sender_device_id, \
                            recipient_user_id, recipient_device_id, encrypted_content, \
                            message_type, server_timestamp, client_timestamp, \
                            delivery_status, is_deleted \
                     FROM guardyn.messages \
                     WHERE recipient_user_id = ? \
                     LIMIT ? \
                     ALLOW FILTERING";

        // Run both queries concurrently
        let (sender_result, recipient_result) = tokio::join!(
            self.scylla.query_unpaged(query_sender, (user_id.to_string(), limit * 5)),
            self.scylla.query_unpaged(query_recipient, (user_id.to_string(), limit * 5))
        );

        let sender_rows = sender_result
            .context("Failed to fetch sender conversations from ScyllaDB")?;
        let recipient_rows = recipient_result
            .context("Failed to fetch recipient conversations from ScyllaDB")?;

        // Combine rows from both queries
        let mut all_rows = Vec::new();
        if let Some(rows) = sender_rows.rows {
            all_rows.extend(rows);
        }
        if let Some(rows) = recipient_rows.rows {
            all_rows.extend(rows);
        }

        use std::collections::HashMap;
        let mut conversations_map: HashMap<String, crate::proto::messaging::Conversation> = HashMap::new();

        for row in all_rows {
                let conversation_id = row.columns.get(0)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_uuid())
                    .map(|u| u.to_string())
                    .unwrap_or_default();

                let message_id = row.columns.get(1)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_uuid())
                    .map(|u| u.to_string())
                    .unwrap_or_default();

                let sender_user_id = row.columns.get(2)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .unwrap_or_default();

                let sender_device_id = row.columns.get(3)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .unwrap_or_default();

                let recipient_user_id = row.columns.get(4)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .unwrap_or_default();

                let recipient_device_id = row.columns.get(5)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .unwrap_or_default();

                let encrypted_content = row.columns.get(6)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_blob())
                    .map(|b| b.to_vec())
                    .unwrap_or_default();

                let message_type = row.columns.get(7)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_int())
                    .unwrap_or(0);

                let server_timestamp = row.columns.get(8)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_cql_timestamp())
                    .map(|ts| ts.0) // CqlTimestamp.0 is milliseconds
                    .unwrap_or(0);

                let client_timestamp = row.columns.get(9)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_bigint())
                    .unwrap_or(0);

                let delivery_status = row.columns.get(10)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_int())
                    .unwrap_or(0);

                let is_deleted = row.columns.get(11)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_boolean())
                    .unwrap_or(false);

                // Determine the other user in the conversation
                let other_user_id = if sender_user_id == user_id {
                    recipient_user_id.clone()
                } else {
                    sender_user_id.clone()
                };

                // Create message proto
                let message = crate::proto::messaging::Message {
                    message_id,
                    sender_user_id,
                    sender_device_id,
                    recipient_user_id,
                    recipient_device_id,
                    encrypted_content,
                    message_type,
                    client_message_id: String::new(), // Not stored in messages table
                    client_timestamp: Some(crate::proto::common::Timestamp {
                        seconds: client_timestamp / 1000,
                        nanos: ((client_timestamp % 1000) * 1_000_000) as i32,
                    }),
                    server_timestamp: Some(crate::proto::common::Timestamp {
                        seconds: server_timestamp / 1000,
                        nanos: ((server_timestamp % 1000) * 1_000_000) as i32,
                    }),
                    delivery_status,
                    media_id: String::new(),
                    is_deleted,
                    x3dh_prekey: String::new(), // Not stored in DB
                };

                // Update or create conversation
                conversations_map
                    .entry(conversation_id.clone())
                    .and_modify(|conv| {
                        // Update with more recent message
                        if let (Some(existing_ts), Some(new_ts)) = (
                            conv.last_message.as_ref().and_then(|m| m.server_timestamp.as_ref()),
                            message.server_timestamp.as_ref(),
                        ) {
                            if new_ts.seconds > existing_ts.seconds {
                                conv.last_message = Some(message.clone());
                                conv.updated_at = message.server_timestamp.clone();
                            }
                        }
                    })
                    .or_insert_with(|| crate::proto::messaging::Conversation {
                        conversation_id: conversation_id.clone(),
                        user_id: other_user_id.clone(),
                        username: other_user_id, // Will need to fetch actual username from auth service
                        last_message: Some(message.clone()),
                        unread_count: 0, // TODO: Calculate actual unread count
                        updated_at: message.server_timestamp,
                    });

                if conversations_map.len() >= limit as usize {
                    break;
                }
            }

        let mut conversations: Vec<_> = conversations_map.into_values().collect();

        // Sort by last activity
        conversations.sort_by(|a, b| {
            let a_ts = a.updated_at.as_ref().map(|t| t.seconds).unwrap_or(0);
            let b_ts = b.updated_at.as_ref().map(|t| t.seconds).unwrap_or(0);
            b_ts.cmp(&a_ts)
        });

        conversations.truncate(limit as usize);
        Ok(conversations)
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
    // Conversation Operations (ScyllaDB - conversations table)
    // ========================================================================

    /// Update conversation for a user (upsert)
    /// This is called for both sender and recipient when a message is sent
    pub async fn upsert_conversation(
        &self,
        user_id: &str,
        conversation_id: &str,
        other_user_id: &str,
        other_username: &str,
        last_message_id: &str,
        last_message_preview: &str,
        last_message_time_ms: i64,
        increment_unread: bool,
    ) -> Result<()> {
        let conversation_uuid = uuid::Uuid::parse_str(conversation_id)?;
        let message_uuid = uuid::Uuid::parse_str(last_message_id)?;

        // ScyllaDB timestamp is in milliseconds
        let timestamp = scylla::frame::value::CqlTimestamp(last_message_time_ms);

        // Truncate preview to 100 chars
        let preview: String = last_message_preview.chars().take(100).collect();

        // First, try to delete old entry for this conversation (if exists)
        // We need to do this because last_message_time is part of clustering key
        let delete_query = "DELETE FROM guardyn.conversations 
                           WHERE user_id = ? AND conversation_id = ?";

        // Note: This won't work as-is because conversation_id is not the partition key
        // We need a different approach - using a separate lookup or accepting duplicates
        // For MVP, we'll just insert and accept that old entries remain (they'll be filtered)

        // Insert new conversation entry
        let insert_query = if increment_unread {
            "INSERT INTO guardyn.conversations 
             (user_id, conversation_id, other_user_id, other_username, 
              last_message_id, last_message_preview, last_message_time, unread_count)
             VALUES (?, ?, ?, ?, ?, ?, ?, 1)"
        } else {
            "INSERT INTO guardyn.conversations 
             (user_id, conversation_id, other_user_id, other_username, 
              last_message_id, last_message_preview, last_message_time, unread_count)
             VALUES (?, ?, ?, ?, ?, ?, ?, 0)"
        };

        self.scylla
            .query_unpaged(
                insert_query,
                (
                    user_id.to_string(),
                    conversation_uuid,
                    other_user_id.to_string(),
                    other_username.to_string(),
                    message_uuid,
                    preview,
                    timestamp,
                ),
            )
            .await
            .context("Failed to upsert conversation")?;

        tracing::debug!(
            "Upserted conversation for user {} with {}",
            user_id, other_user_id
        );

        Ok(())
    }

    /// Get conversations for a user using the optimized conversations table
    /// Returns conversations sorted by last_message_time DESC
    pub async fn get_user_conversations(
        &self,
        user_id: &str,
        limit: i32,
    ) -> Result<Vec<crate::proto::messaging::Conversation>> {
        let query = "SELECT conversation_id, other_user_id, other_username, 
                            last_message_id, last_message_preview, last_message_time, unread_count
                     FROM guardyn.conversations 
                     WHERE user_id = ? 
                     LIMIT ?";

        let rows = self
            .scylla
            .query_unpaged(query, (user_id.to_string(), limit))
            .await
            .context("Failed to fetch conversations")?;

        let mut conversations = Vec::new();
        let mut seen_conversations = std::collections::HashSet::new();

        if let Some(rows) = rows.rows {
            for row in rows {
                let conversation_id = row.columns.get(0)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_uuid())
                    .map(|u| u.to_string())
                    .unwrap_or_default();

                // Skip duplicates (old entries for same conversation)
                if seen_conversations.contains(&conversation_id) {
                    continue;
                }
                seen_conversations.insert(conversation_id.clone());

                let other_user_id = row.columns.get(1)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .unwrap_or_default();

                let other_username = row.columns.get(2)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .unwrap_or_else(|| other_user_id.clone());

                let last_message_id = row.columns.get(3)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_uuid())
                    .map(|u| u.to_string())
                    .unwrap_or_default();

                let last_message_preview = row.columns.get(4)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_text())
                    .map(|s| s.to_string())
                    .unwrap_or_default();

                let last_message_time = row.columns.get(5)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_cql_timestamp())
                    .map(|ts| ts.0) // milliseconds
                    .unwrap_or(0);

                let unread_count = row.columns.get(6)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_int())
                    .unwrap_or(0) as u32;

                // Create a placeholder last_message with preview
                let last_message = crate::proto::messaging::Message {
                    message_id: last_message_id,
                    sender_user_id: String::new(),
                    sender_device_id: String::new(),
                    recipient_user_id: String::new(),
                    recipient_device_id: String::new(),
                    encrypted_content: last_message_preview.into_bytes(),
                    message_type: 0,
                    client_message_id: String::new(),
                    client_timestamp: None,
                    server_timestamp: Some(crate::proto::common::Timestamp {
                        seconds: last_message_time / 1000,
                        nanos: ((last_message_time % 1000) * 1_000_000) as i32,
                    }),
                    delivery_status: 0,
                    media_id: String::new(),
                    is_deleted: false,
                    x3dh_prekey: String::new(),
                };

                let conversation = crate::proto::messaging::Conversation {
                    conversation_id,
                    user_id: other_user_id,
                    username: other_username,
                    last_message: Some(last_message),
                    unread_count,
                    updated_at: Some(crate::proto::common::Timestamp {
                        seconds: last_message_time / 1000,
                        nanos: ((last_message_time % 1000) * 1_000_000) as i32,
                    }),
                };

                conversations.push(conversation);

                if conversations.len() >= limit as usize {
                    break;
                }
            }
        }

        Ok(conversations)
    }

    /// Reset unread count for a conversation
    pub async fn reset_unread_count(&self, user_id: &str, conversation_id: &str) -> Result<()> {
        // Since last_message_time is part of the clustering key, we can't just UPDATE
        // For MVP, we'll need to read and rewrite the row
        // In production, consider a separate table for unread counts

        tracing::debug!(
            "Reset unread count requested for user {} conversation {}",
            user_id, conversation_id
        );

        // TODO: Implement proper unread count reset
        // This requires finding the row by conversation_id and rewriting it

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

    /// Remove group member
    pub async fn remove_group_member(&self, group_id: &str, user_id: &str) -> Result<()> {
        let key = format!("/groups/{}/members/{}", group_id, user_id);
        self.tikv.delete(key.into_bytes()).await?;
        tracing::info!("Removed member {} from group {}", user_id, group_id);
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

    /// Get all groups for a user
    pub async fn get_user_groups(&self, user_id: &str) -> Result<Vec<(GroupMetadata, Vec<GroupMember>)>> {
        // Scan all groups to find where user is a member
        // This is not optimal for large number of groups, but works for MVP
        let groups_prefix = b"/groups/".to_vec();
        let groups_keys = self.tikv.scan(groups_prefix.., 1000).await?;

        let mut user_groups = Vec::new();

        for kv_pair in groups_keys {
            // Convert Key to Vec<u8> then to string
            let key_bytes: Vec<u8> = kv_pair.0.into();
            let key = String::from_utf8_lossy(&key_bytes);

            // Skip member keys (they contain /members/)
            if key.contains("/members/") {
                continue;
            }

            // Try to parse as GroupMetadata
            if let Ok(group) = serde_json::from_slice::<GroupMetadata>(&kv_pair.1) {
                // Check if user is a member
                let members = self.get_group_members(&group.group_id).await?;
                let is_member = members.iter().any(|m| m.user_id == user_id);

                if is_member {
                    user_groups.push((group, members));
                }
            }
        }

        Ok(user_groups)
    }

    // ========================================================================
    // Group Message Operations (ScyllaDB)
    // ========================================================================

    /// Store group message in ScyllaDB
    pub async fn store_group_message(&self, msg: &GroupMessage) -> Result<()> {
        // Schema: (group_id uuid, message_id timeuuid, sender_user_id text, sender_device_id text,
        //          encrypted_content blob, mls_epoch bigint, sent_at timestamp, metadata map<text,text>)
        let query = "INSERT INTO guardyn.group_messages (
            group_id, message_id, sender_user_id, sender_device_id,
            encrypted_content, mls_epoch, sent_at, metadata
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        let group_uuid = uuid::Uuid::parse_str(&msg.group_id)
            .context("Failed to parse group_id as UUID")?;
        let message_uuid = uuid::Uuid::parse_str(&msg.message_id)
            .context("Failed to parse message_id as UUID")?;

        // Convert message_id to CqlTimeuuid (required for TIMEUUID type in ScyllaDB)
        use scylla::frame::response::result::CqlValue;
        use scylla::frame::value::CqlTimeuuid;
        let message_timeuuid = CqlValue::Timeuuid(CqlTimeuuid::from(message_uuid));

        // Convert sent_at (millis) to CqlTimestamp
        let sent_at_timestamp = CqlValue::Timestamp(scylla::frame::value::CqlTimestamp(msg.sent_at));

        // Convert HashMap to CqlValue::Map
        let metadata_map: Vec<(CqlValue, CqlValue)> = msg.metadata
            .iter()
            .map(|(k, v)| (CqlValue::Text(k.clone()), CqlValue::Text(v.clone())))
            .collect();
        let metadata_cql = CqlValue::Map(metadata_map);

        tracing::info!(
            "STORE_GROUP_MESSAGE: group_id={}, message_id={}, sender={}, mls_epoch={}, metadata_size={}",
            group_uuid, message_uuid, msg.sender_user_id, msg.mls_epoch, msg.metadata.len()
        );

        let result = self.scylla
            .query_unpaged(
                query,
                (
                    group_uuid,
                    message_timeuuid,
                    &msg.sender_user_id,
                    &msg.sender_device_id,
                    &msg.encrypted_content,
                    msg.mls_epoch,
                    sent_at_timestamp,
                    metadata_cql,
                ),
            )
            .await;

        if let Err(ref e) = result {
            tracing::error!(
                "ScyllaDB error details: {:?}, query: {}, params: group_id={}, message_id={}",
                e, query, group_uuid, message_uuid
            );
        }

        result.context("Failed to store group message in ScyllaDB")?;

        Ok(())
    }    /// Get group message history
    pub async fn get_group_messages(
        &self,
        group_id: &str,
        limit: i32,
    ) -> Result<Vec<GroupMessage>> {
        // Explicit column order matching schema
        let query = "SELECT group_id, message_id, sender_user_id, sender_device_id, \
                            encrypted_content, mls_epoch, sent_at, metadata \
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
                // 4: encrypted_content, 5: mls_epoch, 6: sent_at, 7: metadata

                // message_id is TIMEUUID in ScyllaDB
                use scylla::frame::response::result::CqlValue;
                let message_id = row.columns.get(1)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| match c {
                        CqlValue::Timeuuid(tu) => {
                            let uuid: uuid::Uuid = (*tu).into();
                            Some(uuid.to_string())
                        },
                        _ => None,
                    })
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

                let mls_epoch = row.columns.get(5)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_bigint())
                    .ok_or_else(|| anyhow::anyhow!("Missing mls_epoch"))?;

                let sent_at_timestamp = row.columns.get(6)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_cql_timestamp())
                    .ok_or_else(|| anyhow::anyhow!("Missing sent_at"))?;

                // CqlTimestamp is in milliseconds
                let sent_at = sent_at_timestamp.0;

                let metadata = row.columns.get(7)
                    .and_then(|c| c.as_ref())
                    .and_then(|c| c.as_map())
                    .map(|map| {
                        let mut result = std::collections::HashMap::new();
                        for (k, v) in map.iter() {
                            if let (Some(key_str), Some(val_str)) = (k.as_text(), v.as_text()) {
                                result.insert(key_str.to_string(), val_str.to_string());
                            }
                        }
                        result
                    })
                    .unwrap_or_default();

                let msg = GroupMessage {
                    message_id,
                    group_id: group_id.to_string(),
                    sender_user_id,
                    sender_device_id,
                    encrypted_content,
                    mls_epoch,
                    sent_at,
                    metadata,
                };
                messages.push(msg);
            }
        }

        Ok(messages)
    }

    /// Health check - verify TiKV connectivity
    pub async fn tikv_health_check(&self) -> anyhow::Result<()> {
        let test_key = b"/__health_check__";
        self.tikv.get(test_key.to_vec()).await?;
        Ok(())
    }

    /// Health check - verify ScyllaDB connectivity
    pub async fn scylladb_health_check(&self) -> anyhow::Result<()> {
        // Execute a simple query to verify connectivity using query_unpaged
        let query = scylla::query::Query::new("SELECT now() FROM system.local");
        self.scylla.query_unpaged(query, ()).await?;
        Ok(())
    }

    // ========================================================================
    // Double Ratchet Session Management (TiKV)
    // ========================================================================

    /// Store Double Ratchet session state
    pub async fn store_ratchet_session(&self, session: &RatchetSession) -> Result<()> {
        let key = format!("/ratchet_sessions/{}", session.session_id);
        let value = serde_json::to_vec(session)?;
        self.tikv.put(key.into_bytes(), value).await?;

        // Also index by user+device for quick lookup
        let user_key = format!(
            "/ratchet_sessions/user/{}/{}/{}:{}",
            session.local_user_id,
            session.local_device_id,
            session.remote_user_id,
            session.remote_device_id
        );
        self.tikv.put(user_key.into_bytes(), session.session_id.as_bytes().to_vec()).await?;

        tracing::info!("Stored ratchet session: {}", session.session_id);
        Ok(())
    }

    /// Get Double Ratchet session by session ID
    pub async fn get_ratchet_session(&self, session_id: &str) -> Result<Option<RatchetSession>> {
        let key = format!("/ratchet_sessions/{}", session_id);
        let value = self.tikv.get(key.into_bytes()).await?;

        match value {
            Some(bytes) => {
                let session = serde_json::from_slice(&bytes)?;
                Ok(Some(session))
            }
            None => Ok(None),
        }
    }

    /// Get Double Ratchet session by device pair
    pub async fn get_ratchet_session_by_devices(
        &self,
        local_user_id: &str,
        local_device_id: &str,
        remote_user_id: &str,
        remote_device_id: &str,
    ) -> Result<Option<RatchetSession>> {
        let session_id = RatchetSession::session_id(
            local_user_id,
            local_device_id,
            remote_user_id,
            remote_device_id,
        );
        self.get_ratchet_session(&session_id).await
    }

    /// Update Double Ratchet session state (for message encryption/decryption)
    pub async fn update_ratchet_session_state(
        &self,
        session_id: &str,
        new_state: Vec<u8>,
    ) -> Result<()> {
        let mut session = self
            .get_ratchet_session(session_id)
            .await?
            .context("Ratchet session not found")?;

        session.ratchet_state = new_state;
        session.updated_at = chrono::Utc::now().timestamp();

        self.store_ratchet_session(&session).await?;
        Ok(())
    }

    /// Delete Double Ratchet session (e.g., user logout, session reset)
    pub async fn delete_ratchet_session(&self, session_id: &str) -> Result<()> {
        // Get session to find user index
        let session = self.get_ratchet_session(session_id).await?;

        // Delete main session
        let key = format!("/ratchet_sessions/{}", session_id);
        self.tikv.delete(key.into_bytes()).await?;

        // Delete user index if session exists
        if let Some(sess) = session {
            let user_key = format!(
                "/ratchet_sessions/user/{}/{}/{}:{}",
                sess.local_user_id,
                sess.local_device_id,
                sess.remote_user_id,
                sess.remote_device_id
            );
            self.tikv.delete(user_key.into_bytes()).await?;
        }

        tracing::info!("Deleted ratchet session: {}", session_id);
        Ok(())
    }

    /// List all sessions for a user+device
    pub async fn list_ratchet_sessions_for_device(
        &self,
        user_id: &str,
        device_id: &str,
    ) -> Result<Vec<RatchetSession>> {
        let prefix = format!("/ratchet_sessions/user/{}/{}/", user_id, device_id);
        let keys = self.tikv.scan(prefix.into_bytes().., 1000).await?;

        let mut sessions = Vec::new();
        for kv_pair in keys {
            // Value is session_id, need to fetch full session
            if let Ok(session_id) = String::from_utf8(kv_pair.1) {
                if let Ok(Some(session)) = self.get_ratchet_session(&session_id).await {
                    sessions.push(session);
                }
            }
        }

        Ok(sessions)
    }

    // ========================================================================
    // WebSocket Support Methods
    // ========================================================================

    /// Execute a message insert for WebSocket handler
    pub async fn execute_message_insert(
        &self,
        message_id: &str,
        sender_id: &str,
        recipient_id: &str,
        content: &str,
        content_type: &str,
        encrypted: bool,
        timestamp: chrono::DateTime<chrono::Utc>,
    ) -> Result<()> {
        // Generate conversation ID (deterministic for 1-on-1)
        let conversation_id = self.generate_conversation_id(sender_id, recipient_id);
        let message_uuid = uuid::Uuid::parse_str(message_id)
            .unwrap_or_else(|_| uuid::Uuid::new_v4());

        // Store message in ScyllaDB
        self.scylla
            .query_unpaged(
                "INSERT INTO guardyn.messages (
                    conversation_id, message_id, sender_user_id, recipient_user_id,
                    encrypted_content, message_type, server_timestamp, delivery_status, is_deleted
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    conversation_id,
                    message_uuid,
                    sender_id.to_string(),
                    recipient_id.to_string(),
                    content.as_bytes().to_vec(),
                    if content_type == "text" { 0i32 } else { 1i32 },
                    timestamp.timestamp_millis(),
                    0i32, // Sent
                    false,
                ),
            )
            .await
            .context("Failed to store message")?;

        // Update conversation metadata for both users
        let now = chrono::Utc::now();
        let time_ms = now.timestamp_millis();
        let preview = if content.len() > 100 {
            &content[..100]
        } else {
            content
        };

        self.upsert_conversation(
            sender_id,
            &conversation_id.to_string(),
            recipient_id,
            recipient_id, // other_username (use ID as fallback)
            message_id,
            preview,
            time_ms,
            false,
        ).await?;

        self.upsert_conversation(
            recipient_id,
            &conversation_id.to_string(),
            sender_id,
            sender_id, // other_username (use ID as fallback)
            message_id,
            preview,
            time_ms,
            true, // Increment unread for recipient
        ).await?;

        Ok(())
    }

    /// Generate deterministic conversation ID for 1-on-1 chats
    fn generate_conversation_id(&self, user_a: &str, user_b: &str) -> uuid::Uuid {
        // Sort user IDs to ensure same conversation ID regardless of who sends
        let (first, second) = if user_a < user_b {
            (user_a, user_b)
        } else {
            (user_b, user_a)
        };

        // Use UUID v5 with DNS namespace for deterministic generation
        uuid::Uuid::new_v5(
            &uuid::Uuid::NAMESPACE_DNS,
            format!("{}:{}", first, second).as_bytes(),
        )
    }

    /// Mark a message as read
    pub async fn mark_message_read(
        &self,
        message_id: &str,
        reader_user_id: &str,
    ) -> Result<()> {
        let message_uuid = uuid::Uuid::parse_str(message_id)
            .context("Invalid message ID")?;

        // Update delivery status to Read (2)
        self.scylla
            .query_unpaged(
                "UPDATE guardyn.messages SET delivery_status = 2 WHERE message_id = ? ALLOW FILTERING",
                (message_uuid,),
            )
            .await
            .context("Failed to mark message as read")?;

        tracing::debug!(message_id = %message_id, reader = %reader_user_id, "Message marked as read");
        Ok(())
    }
}


