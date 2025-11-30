/// WebSocket Gateway Module
///
/// Provides real-time message delivery, presence updates, and typing indicators
/// over WebSocket connections. This replaces the HTTP polling approach used in
/// the gRPC-Web client for better performance and lower latency.
///
/// Architecture:
/// - WebSocket server runs on a separate port (default: 8080)
/// - Connections are authenticated via JWT token in the initial handshake
/// - Messages are fanout via NATS JetStream to all connected clients

pub mod connection;
pub mod handlers;
pub mod messages;
pub mod server;

pub use connection::ConnectionManager;
pub use server::WebSocketServer;
