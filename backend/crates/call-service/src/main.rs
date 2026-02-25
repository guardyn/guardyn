//! Call Service - Voice/Video Calls with WebRTC + SFrame E2EE
//!
//! Provides signaling for WebRTC calls with SFrame end-to-end encryption.

mod auth_client;
mod db;
mod generated;
mod handlers;
mod nats;
mod service;
mod session;

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::Result;
use tonic::transport::Server;
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

use crate::db::CallDb;
use crate::nats::CallNatsClient;
use crate::service::CallServiceImpl;
use crate::session::CallSessionManager;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)?;

    info!("Starting Guardyn Call Service");

    // Load configuration
    let config = load_config()?;

    // Initialize database
    let db = CallDb::new(&config.scylla_hosts).await?;

    // Initialize session manager
    let session_manager = CallSessionManager::new();

    // Connect to NATS for event distribution
    let nats_client = CallNatsClient::new(&config.nats_url).await?;

    // Create service implementation
    let call_service = CallServiceImpl::new(
        Arc::new(db),
        Arc::new(session_manager),
        Arc::new(nats_client),
        config.auth_service_url.clone(),
        config.jwt_secret.clone(),
        config.ice_servers.clone(),
    );

    // Start gRPC server
    let addr: SocketAddr = config.listen_addr.parse()?;
    info!("Call service listening on {}", addr);

    Server::builder()
        .add_service(
            generated::guardyn::calls::call_service_server::CallServiceServer::new(call_service),
        )
        .serve(addr)
        .await?;

    Ok(())
}

#[derive(Debug, Clone)]
pub struct Config {
    pub listen_addr: String,
    pub scylla_hosts: Vec<String>,
    pub nats_url: String,
    pub auth_service_url: String,
    pub jwt_secret: String,
    pub ice_servers: Vec<IceServerConfig>,
}

#[derive(Debug, Clone)]
pub struct IceServerConfig {
    pub urls: Vec<String>,
    pub username: Option<String>,
    pub credential: Option<String>,
}

fn load_config() -> Result<Config> {
    // Parse ICE servers from environment
    let ice_servers = parse_ice_servers();

    Ok(Config {
        listen_addr: std::env::var("LISTEN_ADDR").unwrap_or_else(|_| "0.0.0.0:50055".to_string()),
        scylla_hosts: std::env::var("SCYLLA_HOSTS")
            .unwrap_or_else(|_| "scylla.data.svc.cluster.local:9042".to_string())
            .split(',')
            .map(|s| s.to_string())
            .collect(),
        nats_url: std::env::var("NATS_URL")
            .unwrap_or_else(|_| "nats://nats.messaging.svc.cluster.local:4222".to_string()),
        auth_service_url: std::env::var("AUTH_SERVICE_URL")
            .unwrap_or_else(|_| "http://auth-service.apps.svc.cluster.local:50051".to_string()),
        jwt_secret: std::env::var("JWT_SECRET")
            .unwrap_or_else(|_| "development-secret-change-in-production".to_string()),
        ice_servers,
    })
}

fn parse_ice_servers() -> Vec<IceServerConfig> {
    // Default STUN servers
    let mut servers = vec![IceServerConfig {
        urls: vec!["stun:stun.l.google.com:19302".to_string()],
        username: None,
        credential: None,
    }];

    // Add TURN server if configured
    if let Ok(turn_url) = std::env::var("TURN_SERVER_URL") {
        servers.push(IceServerConfig {
            urls: vec![turn_url],
            username: std::env::var("TURN_USERNAME").ok(),
            credential: std::env::var("TURN_CREDENTIAL").ok(),
        });
    }

    servers
}
