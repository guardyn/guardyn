//! Notification Service - Push Notifications for Guardyn
//!
//! Handles device registration, notification settings, and push delivery
//! via FCM (Android) and APNs (iOS).

mod db;
mod generated;
mod handlers;
mod push;
mod service;

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::Result;
use tonic::transport::Server;
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

use crate::db::NotificationDb;
use crate::service::NotificationServiceImpl;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)?;

    info!("Starting Guardyn Notification Service");

    // Load configuration
    let config = load_config()?;

    // Initialize database
    let db = NotificationDb::new(&config.scylla_hosts).await?;

    // Initialize push providers
    let push_service = push::PushService::new(
        config.fcm_server_key.clone(),
        config.apns_config.clone(),
    );

    // Create service implementation
    let notification_service = NotificationServiceImpl::new(
        Arc::new(db),
        Arc::new(push_service),
        config.jwt_secret.clone(),
    );

    // Start gRPC server
    let addr: SocketAddr = config.listen_addr.parse()?;
    info!("Notification service listening on {}", addr);

    Server::builder()
        .add_service(generated::guardyn::notifications::notification_service_server::NotificationServiceServer::new(notification_service))
        .serve(addr)
        .await?;

    Ok(())
}

#[derive(Debug, Clone)]
pub struct Config {
    pub listen_addr: String,
    pub scylla_hosts: Vec<String>,
    pub jwt_secret: String,
    pub fcm_server_key: Option<String>,
    pub apns_config: Option<ApnsConfig>,
}

#[derive(Debug, Clone)]
pub struct ApnsConfig {
    pub key_id: String,
    pub team_id: String,
    pub private_key: String,
    pub bundle_id: String,
    pub production: bool,
}

fn load_config() -> Result<Config> {
    Ok(Config {
        listen_addr: std::env::var("LISTEN_ADDR").unwrap_or_else(|_| "0.0.0.0:50054".to_string()),
        scylla_hosts: std::env::var("SCYLLA_HOSTS")
            .unwrap_or_else(|_| "scylla.data.svc.cluster.local:9042".to_string())
            .split(',')
            .map(|s| s.to_string())
            .collect(),
        jwt_secret: std::env::var("JWT_SECRET").unwrap_or_else(|_| "development-secret-change-in-production".to_string()),
        fcm_server_key: std::env::var("FCM_SERVER_KEY").ok(),
        apns_config: std::env::var("APNS_KEY_ID").ok().map(|key_id| ApnsConfig {
            key_id,
            team_id: std::env::var("APNS_TEAM_ID").unwrap_or_default(),
            private_key: std::env::var("APNS_PRIVATE_KEY").unwrap_or_default(),
            bundle_id: std::env::var("APNS_BUNDLE_ID").unwrap_or_default(),
            production: std::env::var("APNS_PRODUCTION")
                .map(|v| v == "true")
                .unwrap_or(false),
        }),
    })
}
