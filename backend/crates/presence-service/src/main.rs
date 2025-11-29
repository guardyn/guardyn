/// Presence Service
///
/// Handles:
/// - Online/offline status tracking
/// - Last seen timestamps
/// - Typing indicators
/// - Presence subscriptions (real-time updates)

mod db;
mod handlers;
mod jwt;
mod nats;

use anyhow::Result;
use guardyn_common::observability;
use std::sync::Arc;
use tonic::{transport::Server, Request, Response, Status};

// Import generated protobuf code
pub mod proto {
    pub mod common {
        include!("generated/guardyn.common.rs");
    }
    pub mod presence {
        include!("generated/guardyn.presence.rs");
    }
}

use proto::common::HealthStatus;
use proto::presence::{
    presence_service_server::{PresenceService, PresenceServiceServer},
    GetBulkStatusRequest, GetBulkStatusResponse, GetStatusRequest, GetStatusResponse,
    HealthRequest, PresenceUpdate, SetTypingRequest, SetTypingResponse, SubscribeRequest,
    UpdateLastSeenRequest, UpdateLastSeenResponse, UpdateStatusRequest, UpdateStatusResponse,
};

/// Presence Service Implementation
pub struct PresenceServiceImpl {
    db: Arc<db::DatabaseClient>,
    nats: Arc<nats::NatsClient>,
    jwt_secret: String,
}

impl PresenceServiceImpl {
    pub fn new(db: db::DatabaseClient, nats: nats::NatsClient, jwt_secret: String) -> Self {
        Self {
            db: Arc::new(db),
            nats: Arc::new(nats),
            jwt_secret,
        }
    }
}

#[tonic::async_trait]
impl PresenceService for PresenceServiceImpl {
    async fn update_status(
        &self,
        request: Request<UpdateStatusRequest>,
    ) -> Result<Response<UpdateStatusResponse>, Status> {
        handlers::handle_update_status(
            request.into_inner(),
            self.db.clone(),
            self.nats.clone(),
            &self.jwt_secret,
        )
        .await
    }

    async fn get_status(
        &self,
        request: Request<GetStatusRequest>,
    ) -> Result<Response<GetStatusResponse>, Status> {
        handlers::handle_get_status(request.into_inner(), self.db.clone(), &self.jwt_secret).await
    }

    async fn get_bulk_status(
        &self,
        request: Request<GetBulkStatusRequest>,
    ) -> Result<Response<GetBulkStatusResponse>, Status> {
        handlers::handle_get_bulk_status(request.into_inner(), self.db.clone(), &self.jwt_secret)
            .await
    }

    type SubscribeStream = tokio_stream::wrappers::ReceiverStream<Result<PresenceUpdate, Status>>;

    async fn subscribe(
        &self,
        request: Request<SubscribeRequest>,
    ) -> Result<Response<Self::SubscribeStream>, Status> {
        handlers::handle_subscribe(request.into_inner(), self.db.clone(), &self.jwt_secret).await
    }

    async fn update_last_seen(
        &self,
        request: Request<UpdateLastSeenRequest>,
    ) -> Result<Response<UpdateLastSeenResponse>, Status> {
        handlers::handle_update_last_seen(request.into_inner(), self.db.clone(), &self.jwt_secret)
            .await
    }

    async fn set_typing(
        &self,
        request: Request<SetTypingRequest>,
    ) -> Result<Response<SetTypingResponse>, Status> {
        handlers::handle_set_typing(
            request.into_inner(),
            self.db.clone(),
            self.nats.clone(),
            &self.jwt_secret,
        )
        .await
    }

    async fn health(
        &self,
        _request: Request<HealthRequest>,
    ) -> Result<Response<HealthStatus>, Status> {
        use crate::proto::common::health_status::Status as HealthStatusEnum;

        let mut components = std::collections::HashMap::new();
        let mut overall_healthy = true;

        // Check TiKV connectivity
        match self.db.health_check().await {
            Ok(_) => {
                components.insert("tikv".to_string(), "healthy".to_string());
            }
            Err(e) => {
                tracing::warn!("TiKV health check failed: {}", e);
                components.insert("tikv".to_string(), "unhealthy".to_string());
                overall_healthy = false;
            }
        }

        // Check NATS connectivity
        match self.nats.health_check().await {
            Ok(_) => {
                components.insert("nats".to_string(), "healthy".to_string());
            }
            Err(e) => {
                tracing::warn!("NATS health check failed: {}", e);
                components.insert("nats".to_string(), "unhealthy".to_string());
                overall_healthy = false;
            }
        }

        let now = chrono::Utc::now();
        Ok(Response::new(HealthStatus {
            status: if overall_healthy {
                HealthStatusEnum::Healthy as i32
            } else {
                HealthStatusEnum::Unhealthy as i32
            },
            version: env!("CARGO_PKG_VERSION").to_string(),
            timestamp: Some(crate::proto::common::Timestamp {
                seconds: now.timestamp(),
                nanos: now.timestamp_subsec_nanos() as i32,
            }),
            components,
        }))
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize observability (tracing, logging, metrics)
    let log_level = std::env::var("LOG_LEVEL").unwrap_or_else(|_| "info".to_string());
    observability::init_tracing("presence-service", &log_level);

    tracing::info!("Starting Presence Service");

    // Load configuration from environment
    let jwt_secret =
        std::env::var("JWT_SECRET").unwrap_or_else(|_| "dev-jwt-secret-change-in-prod".to_string());

    let tikv_pd_endpoints = std::env::var("TIKV_PD_ENDPOINTS")
        .unwrap_or_else(|_| "tikv-pd.data.svc.cluster.local:2379".to_string());

    let nats_url =
        std::env::var("NATS_URL").unwrap_or_else(|_| "nats://nats.messaging.svc.cluster.local:4222".to_string());

    let grpc_port = std::env::var("GRPC_PORT").unwrap_or_else(|_| "50053".to_string());
    let grpc_addr = format!("0.0.0.0:{}", grpc_port).parse()?;

    tracing::info!(
        tikv_endpoints = %tikv_pd_endpoints,
        nats_url = %nats_url,
        grpc_port = %grpc_port,
        "Configuration loaded"
    );

    // Connect to TiKV
    let tikv_endpoints: Vec<String> = tikv_pd_endpoints.split(',').map(|s| s.to_string()).collect();
    let db = db::DatabaseClient::new(tikv_endpoints).await?;
    tracing::info!("Connected to TiKV");

    // Connect to NATS
    let nats = nats::NatsClient::new(&nats_url).await?;
    tracing::info!("Connected to NATS");

    // Create service implementation
    let presence_service = PresenceServiceImpl::new(db, nats, jwt_secret);

    // Start gRPC server
    tracing::info!(address = %grpc_addr, "Starting gRPC server");

    Server::builder()
        .add_service(PresenceServiceServer::new(presence_service))
        .serve(grpc_addr)
        .await?;

    Ok(())
}
