/// WebSocket Server
///
/// Axum-based WebSocket server that runs alongside the gRPC server.
/// Handles WebSocket connections, authentication, and message routing.

use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::get,
    Router,
};
use futures::{sink::SinkExt, stream::StreamExt};
use std::sync::Arc;
use tokio::sync::mpsc;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;
use tracing::{debug, error, info, warn};
use uuid::Uuid;

use crate::db::DatabaseClient;
use crate::nats::NatsClient;

use super::connection::ConnectionManager;
use super::handlers::{handle_disconnect, handle_message, WsContext};
use super::messages::WsMessage;

/// Shared state for WebSocket server
#[derive(Clone)]
pub struct WsState {
    pub connection_manager: Arc<ConnectionManager>,
    pub db: Arc<DatabaseClient>,
    pub nats: Arc<NatsClient>,
    pub jwt_secret: String,
}

/// WebSocket server configuration
pub struct WebSocketServerConfig {
    /// Port to listen on
    pub port: u16,
    /// JWT secret for authentication
    pub jwt_secret: String,
    /// Maximum connections per user
    pub max_connections_per_user: usize,
    /// Heartbeat interval in seconds
    pub heartbeat_interval: u64,
    /// Connection timeout in seconds (no heartbeat)
    pub connection_timeout: u64,
}

impl Default for WebSocketServerConfig {
    fn default() -> Self {
        Self {
            port: 8081,
            jwt_secret: "dev-jwt-secret-change-in-prod".to_string(),
            max_connections_per_user: 5,
            heartbeat_interval: 30,
            connection_timeout: 90,
        }
    }
}

/// WebSocket server
pub struct WebSocketServer {
    config: WebSocketServerConfig,
    state: WsState,
}

impl WebSocketServer {
    /// Create a new WebSocket server
    pub fn new(
        config: WebSocketServerConfig,
        db: Arc<DatabaseClient>,
        nats: Arc<NatsClient>,
    ) -> Self {
        let connection_manager = Arc::new(ConnectionManager::new(config.max_connections_per_user));

        let state = WsState {
            connection_manager,
            db,
            nats,
            jwt_secret: config.jwt_secret.clone(),
        };

        Self { config, state }
    }

    /// Get the connection manager
    pub fn connection_manager(&self) -> Arc<ConnectionManager> {
        self.state.connection_manager.clone()
    }

    /// Start the WebSocket server
    pub async fn start(self) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let addr = format!("0.0.0.0:{}", self.config.port);

        // Configure CORS
        let cors = CorsLayer::new()
            .allow_origin(Any)
            .allow_methods(Any)
            .allow_headers(Any);

        // Build router
        let app = Router::new()
            .route("/ws", get(ws_handler))
            .route("/health", get(health_handler))
            .layer(cors)
            .layer(TraceLayer::new_for_http())
            .with_state(self.state.clone());

        // Start cleanup task for stale connections
        let cleanup_manager = self.state.connection_manager.clone();
        let cleanup_timeout = self.config.connection_timeout as i64;
        tokio::spawn(async move {
            let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(60));
            loop {
                interval.tick().await;
                let stale = cleanup_manager.cleanup_stale_connections(cleanup_timeout);
                if !stale.is_empty() {
                    info!(count = stale.len(), "Cleaned up stale connections");
                }
            }
        });

        // Start NATS message relay task - forwards messages from NATS to WebSocket clients
        let nats_state = self.state.clone();
        tokio::spawn(async move {
            if let Err(e) = start_nats_message_relay(nats_state).await {
                error!("NATS message relay failed: {}", e);
            }
        });

        info!(address = %addr, "Starting WebSocket server");

        let listener = tokio::net::TcpListener::bind(&addr).await?;
        axum::serve(listener, app).await?;

        Ok(())
    }

    /// Start the server in a background task
    pub fn spawn(self) -> tokio::task::JoinHandle<Result<(), Box<dyn std::error::Error + Send + Sync>>> {
        tokio::spawn(async move { self.start().await })
    }
}

/// Health check handler
async fn health_handler() -> impl IntoResponse {
    (StatusCode::OK, "OK")
}

/// WebSocket upgrade handler
async fn ws_handler(ws: WebSocketUpgrade, State(state): State<WsState>) -> Response {
    ws.on_upgrade(move |socket| handle_socket(socket, state))
}

/// Handle a WebSocket connection
async fn handle_socket(socket: WebSocket, state: WsState) {
    let connection_id = Uuid::new_v4().to_string();
    info!(connection_id = %connection_id, "New WebSocket connection");

    let (mut sender, mut receiver) = socket.split();

    // Create channel for sending messages to this connection
    let (tx, mut rx) = mpsc::channel::<WsMessage>(100);

    // Register connection
    state
        .connection_manager
        .register_connection(connection_id.clone(), tx);

    // Create context for message handling
    let ctx = WsContext::new(
        connection_id.clone(),
        state.connection_manager.clone(),
        state.db.clone(),
        state.nats.clone(),
        state.jwt_secret.clone(),
    );

    // Spawn task to forward messages from channel to WebSocket
    let send_connection_id = connection_id.clone();
    let send_task = tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            match serde_json::to_string(&msg) {
                Ok(json) => {
                    if sender.send(Message::Text(json.into())).await.is_err() {
                        debug!(connection_id = %send_connection_id, "WebSocket send failed");
                        break;
                    }
                }
                Err(e) => {
                    warn!(error = %e, "Failed to serialize WebSocket message");
                }
            }
        }
    });

    // Handle incoming messages
    let recv_ctx = ctx.clone();
    let recv_task = tokio::spawn(async move {
        while let Some(result) = receiver.next().await {
            match result {
                Ok(Message::Text(text)) => {
                    match serde_json::from_str::<WsMessage>(&text) {
                        Ok(msg) => {
                            if let Some(response) = handle_message(&recv_ctx, msg).await {
                                // Send response back to this connection
                                if let Err(e) = recv_ctx
                                    .connection_manager
                                    .send_to_connection(&recv_ctx.connection_id, response)
                                    .await
                                {
                                    warn!(error = %e, "Failed to send response");
                                }
                            }
                        }
                        Err(e) => {
                            warn!(error = %e, "Failed to parse WebSocket message");
                            let error_msg = WsMessage::error("PARSE_ERROR", "Invalid message format");
                            let _ = recv_ctx
                                .connection_manager
                                .send_to_connection(&recv_ctx.connection_id, error_msg)
                                .await;
                        }
                    }
                }
                Ok(Message::Binary(_)) => {
                    debug!("Received binary message (not supported)");
                }
                Ok(Message::Ping(data)) => {
                    debug!("Received ping, sending pong");
                    // Axum handles pong automatically
                }
                Ok(Message::Pong(_)) => {
                    debug!("Received pong");
                }
                Ok(Message::Close(_)) => {
                    info!(connection_id = %recv_ctx.connection_id, "WebSocket close received");
                    break;
                }
                Err(e) => {
                    error!(error = %e, "WebSocket error");
                    break;
                }
            }
        }
    });

    // Wait for either task to complete
    tokio::select! {
        _ = send_task => {
            debug!(connection_id = %connection_id, "Send task completed");
        }
        _ = recv_task => {
            debug!(connection_id = %connection_id, "Receive task completed");
        }
    }

    // Handle disconnect
    handle_disconnect(&ctx).await;
    info!(connection_id = %connection_id, "WebSocket connection closed");
}

/// Start NATS message relay - listens to all messages and forwards to WebSocket clients
async fn start_nats_message_relay(state: WsState) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    use async_nats::jetstream::consumer::pull::Config as ConsumerConfig;
    use futures::StreamExt;

    info!("Starting NATS message relay for WebSocket delivery");

    // Create a consumer that listens to all messages (messages.*.*)
    let consumer = state.nats.context
        .create_consumer_on_stream(
            ConsumerConfig {
                name: Some("websocket-relay".to_string()),
                durable_name: None, // Ephemeral consumer
                filter_subject: "messages.>".to_string(),
                ..Default::default()
            },
            "MESSAGES",
        )
        .await?;

    info!("NATS consumer created for WebSocket relay");

    // Process messages
    let mut messages = consumer.messages().await?;
    
    while let Some(msg_result) = messages.next().await {
        match msg_result {
            Ok(msg) => {
                // Parse the message envelope
                if let Ok(envelope) = serde_json::from_slice::<crate::nats::MessageEnvelope>(&msg.payload) {
                    let recipient_id = &envelope.recipient_user_id;
                    
                    debug!(
                        message_id = %envelope.message_id,
                        recipient_id = %recipient_id,
                        "Relaying message via WebSocket"
                    );

                    // Create WebSocket message
                    let ws_message = WsMessage::Message(super::messages::MessagePayload {
                        message_id: envelope.message_id.clone(),
                        sender_id: envelope.sender_user_id.clone(),
                        recipient_id: recipient_id.clone(),
                        content: String::from_utf8_lossy(&envelope.encrypted_content).to_string(),
                        encrypted: true,
                        content_type: "text".to_string(),
                        timestamp: chrono::Utc::now().to_rfc3339(),
                        client_message_id: None,
                    });

                    // Send to recipient's WebSocket connections
                    state.connection_manager.send_to_user(recipient_id, ws_message).await;
                    
                    // Acknowledge the message
                    if let Err(e) = msg.ack().await {
                        warn!("Failed to ack NATS message: {}", e);
                    }
                } else {
                    warn!("Failed to parse message envelope from NATS");
                    // Still ack to avoid blocking
                    let _ = msg.ack().await;
                }
            }
            Err(e) => {
                error!("Error receiving NATS message: {}", e);
            }
        }
    }

    Ok(())
}

impl Clone for WsContext {
    fn clone(&self) -> Self {
        Self {
            connection_id: self.connection_id.clone(),
            connection_manager: self.connection_manager.clone(),
            db: self.db.clone(),
            nats: self.nats.clone(),
            jwt_secret: self.jwt_secret.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_config_defaults() {
        let config = WebSocketServerConfig::default();
        assert_eq!(config.port, 8080);
        assert_eq!(config.max_connections_per_user, 5);
        assert_eq!(config.heartbeat_interval, 30);
        assert_eq!(config.connection_timeout, 90);
    }
}
