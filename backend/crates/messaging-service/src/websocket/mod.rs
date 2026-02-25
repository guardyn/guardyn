/// WebSocket Gateway Module
///
/// Provides real-time message delivery, presence updates, and typing indicators
/// over WebSocket connections. This provides better performance and lower latency
/// compared to polling approaches.
///
/// Architecture:
/// - WebSocket server runs on a separate port (default: 8081)
/// - Connections are authenticated via JWT token in the initial handshake
/// - Messages are fanout via NATS JetStream to all connected clients
pub mod connection;
pub mod handlers;
pub mod messages;
pub mod server;

#[allow(unused_imports)]
pub use connection::ConnectionManager;
pub use server::WebSocketServer;
