/// Authentication Service
///
/// Handles:
/// - User registration
/// - Login/logout
/// - Device management
/// - Session handling
/// - JWT token generation

use guardyn_common::{config::ServiceConfig, observability};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let config = ServiceConfig::load()?;
    observability::init_tracing(&config.service_name, &config.observability.log_level);

    tracing::info!("Starting authentication service on {}:{}", config.host, config.port);

    // TODO: Initialize database connections
    // TODO: Initialize gRPC server
    // TODO: Start health check endpoints

    tracing::info!("Authentication service ready");

    // Keep service running
    tokio::signal::ctrl_c().await?;
    tracing::info!("Shutting down authentication service");

    Ok(())
}
