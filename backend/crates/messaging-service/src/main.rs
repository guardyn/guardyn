/// Messaging Service
///
/// Handles:
/// - Message routing
/// - Message persistence
/// - Message history
/// - Delivery guarantees
/// - Group chat logic

mod handlers;
mod models;
mod db;
mod nats;
mod jwt;
mod crypto;

use guardyn_common::{config::ServiceConfig, observability};
use tonic::{transport::Server, Request, Response, Status};
use anyhow::Result;
use std::sync::Arc;

// Import generated protobuf code
pub mod proto {
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
    pub mod messaging {
        tonic::include_proto!("guardyn.messaging");
    }
}

use proto::messaging::{
    messaging_service_server::{MessagingService, MessagingServiceServer},
    SendMessageRequest, SendMessageResponse,
    ReceiveMessagesRequest, Message,
    GetMessagesRequest, GetMessagesResponse,
    MarkAsReadRequest, MarkAsReadResponse,
    DeleteMessageRequest, DeleteMessageResponse,
    TypingIndicatorRequest, TypingIndicatorResponse,
    CreateGroupRequest, CreateGroupResponse,
    AddGroupMemberRequest, AddGroupMemberResponse,
    RemoveGroupMemberRequest, RemoveGroupMemberResponse,
    SendGroupMessageRequest, SendGroupMessageResponse,
    GetGroupMessagesRequest, GetGroupMessagesResponse,
    HealthRequest,
};
use proto::common::HealthStatus;

pub struct MessagingServiceImpl {
    db: Arc<db::DatabaseClient>,
    nats: Arc<nats::NatsClient>,
}

#[tonic::async_trait]
impl MessagingService for MessagingServiceImpl {
    async fn send_message(
        &self,
        request: Request<SendMessageRequest>,
    ) -> Result<Response<SendMessageResponse>, Status> {
        handlers::send_message(request.into_inner(), self.db.clone(), self.nats.clone()).await
    }

    type ReceiveMessagesStream = tokio_stream::wrappers::ReceiverStream<Result<Message, Status>>;

    async fn receive_messages(
        &self,
        request: Request<ReceiveMessagesRequest>,
    ) -> Result<Response<Self::ReceiveMessagesStream>, Status> {
        handlers::receive_messages(request.into_inner(), self.db.clone(), self.nats.clone()).await
    }

    async fn get_messages(
        &self,
        request: Request<GetMessagesRequest>,
    ) -> Result<Response<GetMessagesResponse>, Status> {
        handlers::get_messages(request.into_inner(), self.db.clone()).await
    }

    async fn mark_as_read(
        &self,
        request: Request<MarkAsReadRequest>,
    ) -> Result<Response<MarkAsReadResponse>, Status> {
        handlers::mark_as_read(request.into_inner(), self.db.clone()).await
    }

    async fn delete_message(
        &self,
        request: Request<DeleteMessageRequest>,
    ) -> Result<Response<DeleteMessageResponse>, Status> {
        handlers::delete_message(request.into_inner(), self.db.clone()).await
    }

    async fn send_typing_indicator(
        &self,
        _request: Request<TypingIndicatorRequest>,
    ) -> Result<Response<TypingIndicatorResponse>, Status> {
        Err(Status::unimplemented("SendTypingIndicator not yet implemented"))
    }

    async fn create_group(
        &self,
        request: Request<CreateGroupRequest>,
    ) -> Result<Response<CreateGroupResponse>, Status> {
        handlers::create_group(request.into_inner(), self.db.clone()).await
    }

    async fn add_group_member(
        &self,
        request: Request<AddGroupMemberRequest>,
    ) -> Result<Response<AddGroupMemberResponse>, Status> {
        handlers::add_group_member(request.into_inner(), self.db.clone()).await
    }

    async fn remove_group_member(
        &self,
        request: Request<RemoveGroupMemberRequest>,
    ) -> Result<Response<RemoveGroupMemberResponse>, Status> {
        handlers::remove_group_member(request.into_inner(), self.db.clone()).await
    }

    async fn send_group_message(
        &self,
        request: Request<SendGroupMessageRequest>,
    ) -> Result<Response<SendGroupMessageResponse>, Status> {
        tracing::info!("MAIN: Received SendGroupMessageRequest for group_id={}", request.get_ref().group_id);
        handlers::send_group_message(request.into_inner(), self.db.clone(), self.nats.clone()).await
    }

    async fn get_group_messages(
        &self,
        request: Request<GetGroupMessagesRequest>,
    ) -> Result<Response<GetGroupMessagesResponse>, Status> {
        handlers::get_group_messages(request.into_inner(), self.db.clone()).await
    }

    async fn health(
        &self,
        _request: Request<HealthRequest>,
    ) -> Result<Response<HealthStatus>, Status> {
        use crate::proto::common::health_status::Status as HealthStatusEnum;

        let mut components = std::collections::HashMap::new();
        let mut overall_healthy = true;

        // Check TiKV connectivity
        match self.db.tikv_health_check().await {
            Ok(_) => {
                components.insert("tikv".to_string(), "healthy".to_string());
            }
            Err(e) => {
                tracing::warn!("TiKV health check failed: {}", e);
                components.insert("tikv".to_string(), "unhealthy".to_string());
                overall_healthy = false;
            }
        }

        // Check ScyllaDB connectivity
        match self.db.scylladb_health_check().await {
            Ok(_) => {
                components.insert("scylladb".to_string(), "healthy".to_string());
            }
            Err(e) => {
                tracing::warn!("ScyllaDB health check failed: {}", e);
                components.insert("scylladb".to_string(), "unhealthy".to_string());
                overall_healthy = false;
            }
        }

        // Check NATS connectivity
        match self.nats_client.connection_state() {
            async_nats::connection::State::Connected => {
                components.insert("nats".to_string(), "healthy".to_string());
            }
            _ => {
                components.insert("nats".to_string(), "unhealthy".to_string());
                overall_healthy = false;
            }
        }

        let status = if overall_healthy {
            HealthStatusEnum::Healthy
        } else {
            HealthStatusEnum::Unhealthy
        };

        Ok(Response::new(HealthStatus {
            status: status as i32,
            version: env!("CARGO_PKG_VERSION").to_string(),
            timestamp: Some(crate::proto::common::Timestamp {
                seconds: chrono::Utc::now().timestamp(),
                nanos: 0,
            }),
            components,
        }))
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let config = ServiceConfig::load()?;
    observability::init_tracing(&config.service_name, &config.observability.log_level);

    tracing::info!("Starting messaging service on {}:{}", config.host, config.port);

    // Initialize database connections
    let tikv_endpoints = config.database.tikv_pd_endpoints.clone();
    let scylla_nodes = config.database.scylladb_nodes.clone();

    let db = db::DatabaseClient::new(tikv_endpoints, scylla_nodes)
        .await
        .expect("Failed to connect to databases");

    tracing::info!("Connected to TiKV and ScyllaDB");

    // Initialize NATS client
    let nats = nats::NatsClient::new(&config.messaging.nats_url)
        .await
        .expect("Failed to connect to NATS");

    tracing::info!("Connected to NATS JetStream");

    // Create gRPC service
    let service = MessagingServiceImpl {
        db: Arc::new(db),
        nats: Arc::new(nats),
    };

    // Start gRPC server
    let addr = format!("{}:{}", config.host, config.port).parse()?;

    tracing::info!("Messaging service listening on {}", addr);

    Server::builder()
        .add_service(MessagingServiceServer::new(service))
        .serve(addr)
        .await?;

    Ok(())
}
