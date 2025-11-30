/// WebSocket Connection Manager
///
/// Manages active WebSocket connections, routing messages to the correct
/// recipients, and handling connection lifecycle events.

use dashmap::DashMap;
use std::sync::Arc;
use tokio::sync::mpsc;
use tracing::{debug, info, warn};

use super::messages::WsMessage;

/// Unique identifier for a WebSocket connection
pub type ConnectionId = String;

/// User ID type
pub type UserId = String;

/// Device ID type
pub type DeviceId = String;

/// Information about an active connection
#[derive(Debug, Clone)]
pub struct ConnectionInfo {
    /// User ID (set after authentication)
    pub user_id: Option<UserId>,
    /// Device ID for multi-device support
    pub device_id: Option<DeviceId>,
    /// Channel to send messages to this connection
    pub sender: mpsc::Sender<WsMessage>,
    /// Timestamp when connection was established
    pub connected_at: chrono::DateTime<chrono::Utc>,
    /// Timestamp of last activity
    pub last_activity: chrono::DateTime<chrono::Utc>,
    /// Subscribed conversation IDs
    pub subscribed_conversations: Vec<String>,
    /// Subscribed user IDs for presence
    pub subscribed_presence: Vec<String>,
}

/// Manages all active WebSocket connections
#[derive(Clone)]
pub struct ConnectionManager {
    /// Map of connection ID to connection info
    connections: Arc<DashMap<ConnectionId, ConnectionInfo>>,
    /// Map of user ID to connection IDs (for routing)
    user_connections: Arc<DashMap<UserId, Vec<ConnectionId>>>,
    /// Maximum connections per user
    max_connections_per_user: usize,
}

impl Default for ConnectionManager {
    fn default() -> Self {
        Self::new(5)
    }
}

impl ConnectionManager {
    /// Create a new connection manager
    pub fn new(max_connections_per_user: usize) -> Self {
        Self {
            connections: Arc::new(DashMap::new()),
            user_connections: Arc::new(DashMap::new()),
            max_connections_per_user,
        }
    }

    /// Register a new connection (before authentication)
    pub fn register_connection(
        &self,
        connection_id: ConnectionId,
        sender: mpsc::Sender<WsMessage>,
    ) {
        let now = chrono::Utc::now();
        let info = ConnectionInfo {
            user_id: None,
            device_id: None,
            sender,
            connected_at: now,
            last_activity: now,
            subscribed_conversations: Vec::new(),
            subscribed_presence: Vec::new(),
        };
        self.connections.insert(connection_id.clone(), info);
        debug!(connection_id = %connection_id, "Registered new connection");
    }

    /// Authenticate a connection (after JWT validation)
    pub fn authenticate_connection(
        &self,
        connection_id: &str,
        user_id: UserId,
        device_id: Option<DeviceId>,
    ) -> Result<(), &'static str> {
        // Update connection info with user ID
        if let Some(mut conn) = self.connections.get_mut(connection_id) {
            conn.user_id = Some(user_id.clone());
            conn.device_id = device_id;
            conn.last_activity = chrono::Utc::now();
        } else {
            return Err("Connection not found");
        }

        // Add to user connections mapping
        let mut user_conns = self
            .user_connections
            .entry(user_id.clone())
            .or_insert_with(Vec::new);

        // Check max connections per user
        if user_conns.len() >= self.max_connections_per_user {
            // Remove oldest connection
            if let Some(oldest_conn_id) = user_conns.first().cloned() {
                warn!(
                    user_id = %user_id,
                    oldest_connection = %oldest_conn_id,
                    "Max connections reached, disconnecting oldest"
                );
                self.remove_connection(&oldest_conn_id);
            }
        }

        user_conns.push(connection_id.to_string());

        info!(
            connection_id = %connection_id,
            user_id = %user_id,
            "Connection authenticated"
        );

        Ok(())
    }

    /// Remove a connection
    pub fn remove_connection(&self, connection_id: &str) {
        if let Some((_, conn)) = self.connections.remove(connection_id) {
            if let Some(user_id) = conn.user_id {
                if let Some(mut user_conns) = self.user_connections.get_mut(&user_id) {
                    user_conns.retain(|id| id != connection_id);
                }
            }
            debug!(connection_id = %connection_id, "Connection removed");
        }
    }

    /// Update last activity timestamp
    pub fn update_activity(&self, connection_id: &str) {
        if let Some(mut conn) = self.connections.get_mut(connection_id) {
            conn.last_activity = chrono::Utc::now();
        }
    }

    /// Get user ID for a connection
    pub fn get_user_id(&self, connection_id: &str) -> Option<UserId> {
        self.connections
            .get(connection_id)
            .and_then(|c| c.user_id.clone())
    }

    /// Get connection info
    pub fn get_connection(&self, connection_id: &str) -> Option<ConnectionInfo> {
        self.connections.get(connection_id).map(|c| c.clone())
    }

    /// Send a message to a specific connection
    pub async fn send_to_connection(
        &self,
        connection_id: &str,
        message: WsMessage,
    ) -> Result<(), &'static str> {
        if let Some(conn) = self.connections.get(connection_id) {
            conn.sender.send(message).await.map_err(|_| "Send failed")?;
            Ok(())
        } else {
            Err("Connection not found")
        }
    }

    /// Send a message to all connections of a user
    pub async fn send_to_user(&self, user_id: &str, message: WsMessage) {
        if let Some(conn_ids) = self.user_connections.get(user_id) {
            for conn_id in conn_ids.iter() {
                if let Some(conn) = self.connections.get(conn_id) {
                    if let Err(e) = conn.sender.send(message.clone()).await {
                        warn!(
                            user_id = %user_id,
                            connection_id = %conn_id,
                            error = %e,
                            "Failed to send message to connection"
                        );
                    }
                }
            }
        }
    }

    /// Send a message to multiple users
    pub async fn send_to_users(&self, user_ids: &[String], message: WsMessage) {
        for user_id in user_ids {
            self.send_to_user(user_id, message.clone()).await;
        }
    }

    /// Get connection IDs for a user
    pub fn get_user_connection_ids(&self, user_id: &str) -> Vec<ConnectionId> {
        self.user_connections
            .get(user_id)
            .map(|ids| ids.clone())
            .unwrap_or_default()
    }

    /// Check if a user is online (has at least one connection)
    pub fn is_user_online(&self, user_id: &str) -> bool {
        self.user_connections
            .get(user_id)
            .map(|ids| !ids.is_empty())
            .unwrap_or(false)
    }

    /// Get all online user IDs
    pub fn get_online_users(&self) -> Vec<UserId> {
        self.user_connections
            .iter()
            .filter(|entry| !entry.value().is_empty())
            .map(|entry| entry.key().clone())
            .collect()
    }

    /// Get total connection count
    pub fn connection_count(&self) -> usize {
        self.connections.len()
    }

    /// Add subscription to a connection
    pub fn subscribe_conversation(&self, connection_id: &str, conversation_id: String) {
        if let Some(mut conn) = self.connections.get_mut(connection_id) {
            if !conn.subscribed_conversations.contains(&conversation_id) {
                conn.subscribed_conversations.push(conversation_id);
            }
        }
    }

    /// Remove subscription from a connection
    pub fn unsubscribe_conversation(&self, connection_id: &str, conversation_id: &str) {
        if let Some(mut conn) = self.connections.get_mut(connection_id) {
            conn.subscribed_conversations.retain(|id| id != conversation_id);
        }
    }

    /// Add presence subscription to a connection
    pub fn subscribe_presence(&self, connection_id: &str, user_id: String) {
        if let Some(mut conn) = self.connections.get_mut(connection_id) {
            if !conn.subscribed_presence.contains(&user_id) {
                conn.subscribed_presence.push(user_id);
            }
        }
    }

    /// Remove presence subscription from a connection
    pub fn unsubscribe_presence(&self, connection_id: &str, user_id: &str) {
        if let Some(mut conn) = self.connections.get_mut(connection_id) {
            conn.subscribed_presence.retain(|id| id != user_id);
        }
    }

    /// Get all connections subscribed to a conversation
    pub fn get_conversation_subscribers(&self, conversation_id: &str) -> Vec<ConnectionId> {
        self.connections
            .iter()
            .filter(|entry| entry.subscribed_conversations.contains(&conversation_id.to_string()))
            .map(|entry| entry.key().clone())
            .collect()
    }

    /// Get all connections subscribed to a user's presence
    pub fn get_presence_subscribers(&self, user_id: &str) -> Vec<ConnectionId> {
        self.connections
            .iter()
            .filter(|entry| entry.subscribed_presence.contains(&user_id.to_string()))
            .map(|entry| entry.key().clone())
            .collect()
    }

    /// Clean up stale connections (no activity for given duration)
    pub fn cleanup_stale_connections(&self, max_idle_seconds: i64) -> Vec<ConnectionId> {
        let now = chrono::Utc::now();
        let stale: Vec<ConnectionId> = self
            .connections
            .iter()
            .filter(|entry| {
                (now - entry.last_activity).num_seconds() > max_idle_seconds
            })
            .map(|entry| entry.key().clone())
            .collect();

        for conn_id in &stale {
            self.remove_connection(conn_id);
        }

        stale
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_connection_lifecycle() {
        let manager = ConnectionManager::new(5);
        let (tx, _rx) = mpsc::channel(32);

        // Register connection
        manager.register_connection("conn-1".to_string(), tx.clone());
        assert_eq!(manager.connection_count(), 1);

        // Authenticate
        manager
            .authenticate_connection("conn-1", "user-1".to_string(), None)
            .unwrap();
        assert!(manager.is_user_online("user-1"));
        assert_eq!(manager.get_user_id("conn-1"), Some("user-1".to_string()));

        // Remove connection
        manager.remove_connection("conn-1");
        assert_eq!(manager.connection_count(), 0);
        assert!(!manager.is_user_online("user-1"));
    }

    #[tokio::test]
    async fn test_max_connections_per_user() {
        let manager = ConnectionManager::new(2);

        for i in 0..3 {
            let (tx, _rx) = mpsc::channel(32);
            let conn_id = format!("conn-{}", i);
            manager.register_connection(conn_id.clone(), tx);
            manager
                .authenticate_connection(&conn_id, "user-1".to_string(), None)
                .unwrap();
        }

        // Should only have 2 connections (max per user)
        let conn_ids = manager.get_user_connection_ids("user-1");
        assert_eq!(conn_ids.len(), 2);
    }

    #[tokio::test]
    async fn test_subscriptions() {
        let manager = ConnectionManager::new(5);
        let (tx, _rx) = mpsc::channel(32);

        manager.register_connection("conn-1".to_string(), tx);
        manager
            .authenticate_connection("conn-1", "user-1".to_string(), None)
            .unwrap();

        // Subscribe to conversation
        manager.subscribe_conversation("conn-1", "conv-123".to_string());
        let subscribers = manager.get_conversation_subscribers("conv-123");
        assert_eq!(subscribers.len(), 1);

        // Unsubscribe
        manager.unsubscribe_conversation("conn-1", "conv-123");
        let subscribers = manager.get_conversation_subscribers("conv-123");
        assert_eq!(subscribers.len(), 0);
    }
}
