//! Event consumer for cross-service events
//!
//! Handles events from other services via Redpanda, such as:
//! - user.deleted: Clean up all user's messages and group memberships

use crate::db::DatabaseClient;
use guardyn_common::{
    events::{topics, user, EventEnvelope},
    kafka::{KafkaConfig, KafkaConsumer, ReceivedMessage},
};
use std::sync::Arc;
use tokio::sync::broadcast;
use tracing::{error, info, warn};

/// Event consumer that listens for cross-service events
pub struct EventConsumer {
    consumer: KafkaConsumer,
    db: Arc<DatabaseClient>,
}

impl EventConsumer {
    /// Create a new event consumer
    pub fn new(
        db: Arc<DatabaseClient>,
        _shutdown: broadcast::Receiver<()>,
    ) -> Result<Self, guardyn_common::kafka::KafkaError> {
        let mut config = KafkaConfig::from_env();
        config.group_id = "messaging-service-events".to_string();
        config.client_id = "messaging-service".to_string();

        let consumer = KafkaConsumer::new(&config)?;
        consumer.subscribe(&[topics::USER_EVENTS])?;

        Ok(Self { consumer, db })
    }

    /// Run the event consumer loop
    pub async fn run(self) {
        info!("Event consumer started, listening for cross-service events");

        let db = self.db.clone();

        // Use the consume method with a handler
        if let Err(e) = self
            .consumer
            .consume(|msg: ReceivedMessage| {
                let db = db.clone();
                async move {
                    if let Err(e) = handle_message(&db, &msg).await {
                        error!(error = %e, "Failed to handle event message");
                    }
                    Ok(())
                }
            })
            .await
        {
            error!(error = %e, "Event consumer error");
        }

        info!("Event consumer stopped");
    }
}

/// Handle a received message based on topic and event type
async fn handle_message(db: &DatabaseClient, msg: &ReceivedMessage) -> anyhow::Result<()> {
    let topic = &msg.topic;
    let payload = &msg.payload;

    if topic == topics::USER_EVENTS {
        handle_user_event(db, payload).await?;
    }

    Ok(())
}

/// Handle user lifecycle events
async fn handle_user_event(db: &DatabaseClient, payload: &[u8]) -> anyhow::Result<()> {
    // Try to parse as UserDeletedPayload first
    if let Ok(event) = serde_json::from_slice::<EventEnvelope<user::UserDeletedPayload>>(payload) {
        if event.event_type == user::TYPE_DELETED {
            handle_user_deleted(db, &event).await?;
        }
    }

    Ok(())
}

/// Handle user.deleted event - clean up all user data from messaging service
async fn handle_user_deleted(
    db: &DatabaseClient,
    event: &EventEnvelope<user::UserDeletedPayload>,
) -> anyhow::Result<()> {
    let user_id = &event.payload.user_id;
    let scope = &event.payload.delete_data;

    info!(
        user_id = %user_id,
        event_id = %event.event_id,
        "Processing user.deleted event"
    );

    let mut messages_deleted = 0u64;
    let mut groups_affected = 0u64;

    // 1. Delete all messages sent by user (if requested)
    if scope.messages {
        match delete_user_messages(db, user_id).await {
            Ok(count) => {
                messages_deleted = count;
                info!(user_id = %user_id, count, "Deleted user messages");
            }
            Err(e) => {
                error!(user_id = %user_id, error = %e, "Failed to delete user messages");
            }
        }
    }

    // 2. Remove user from all groups (if requested)
    if scope.group_memberships {
        match remove_user_from_groups(db, user_id).await {
            Ok(count) => {
                groups_affected = count;
                info!(user_id = %user_id, count, "Removed user from groups");
            }
            Err(e) => {
                error!(user_id = %user_id, error = %e, "Failed to remove user from groups");
            }
        }
    }

    info!(
        user_id = %user_id,
        messages_deleted,
        groups_affected,
        "Completed user data deletion from messaging service"
    );

    Ok(())
}

/// Delete all messages sent by a user
async fn delete_user_messages(db: &DatabaseClient, user_id: &str) -> anyhow::Result<u64> {
    // Delete from ScyllaDB messages table
    // Note: This is a tombstone-based deletion for eventual consistency
    let scylla = db.scylla();
    let query = "DELETE FROM guardyn.messages WHERE sender_user_id = ? ALLOW FILTERING";

    match scylla.query_unpaged(query, (user_id,)).await {
        Ok(_) => {
            // ScyllaDB doesn't return count from DELETE, log as success
            info!(user_id = %user_id, "Deleted user messages from ScyllaDB");
            Ok(0) // Count not available from DELETE
        }
        Err(e) => {
            warn!(user_id = %user_id, error = %e, "Failed to delete messages - table may not exist or different schema");
            // Return Ok with 0 - this is not a critical failure
            Ok(0)
        }
    }
}

/// Remove user from all groups they're a member of
async fn remove_user_from_groups(db: &DatabaseClient, user_id: &str) -> anyhow::Result<u64> {
    let tikv = db.tikv();

    // Scan TiKV for group memberships
    let prefix = format!("/groups/member/{}/", user_id);
    let start_key = prefix.as_bytes().to_vec();
    let end_key = format!("{}~", prefix).as_bytes().to_vec();

    let memberships = tikv.scan(start_key..end_key, 1000).await?;
    let mut removed = 0u64;

    for kv in memberships {
        // Extract group_id from membership key
        let key_bytes: Vec<u8> = kv.0.into();
        let key_str = String::from_utf8_lossy(&key_bytes);

        if let Some(group_id) = key_str.strip_prefix(&prefix) {
            // Delete the membership record
            let membership_key = format!("/groups/member/{}/{}", user_id, group_id);
            if let Err(e) = tikv.delete(membership_key.into_bytes()).await {
                warn!(
                    user_id = %user_id,
                    group_id = %group_id,
                    error = %e,
                    "Failed to delete group membership"
                );
            } else {
                // Also delete reverse index
                let reverse_key = format!("/groups/{}/members/{}", group_id, user_id);
                let _ = tikv.delete(reverse_key.into_bytes()).await;
                removed += 1;
            }
        }
    }

    Ok(removed)
}
