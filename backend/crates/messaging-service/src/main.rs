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
        _request: Request<ReceiveMessagesRequest>,
    ) -> Result<Response<Self::ReceiveMessagesStream>, Status> {
        // TODO: Implement streaming message delivery
        Err(Status::unimplemented("ReceiveMessages not yet implemented"))
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
        _request: Request<CreateGroupRequest>,
    ) -> Result<Response<CreateGroupResponse>, Status> {
        Err(Status::unimplemented("CreateGroup not yet implemented"))
    }

    async fn add_group_member(
        &self,
        _request: Request<AddGroupMemberRequest>,
    ) -> Result<Response<AddGroupMemberResponse>, Status> {
        Err(Status::unimplemented("AddGroupMember not yet implemented"))
    }

    async fn remove_group_member(
        &self,
        _request: Request<RemoveGroupMemberRequest>,
    ) -> Result<Response<RemoveGroupMemberResponse>, Status> {
        Err(Status::unimplemented("RemoveGroupMember not yet implemented"))
    }

    async fn send_group_message(
        &self,
        _request: Request<SendGroupMessageRequest>,
    ) -> Result<Response<SendGroupMessageResponse>, Status> {
        Err(Status::unimplemented("SendGroupMessage not yet implemented"))
    }

    async fn get_group_messages(
        &self,
        _request: Request<GetGroupMessagesRequest>,
    ) -> Result<Response<GetGroupMessagesResponse>, Status> {
        Err(Status::unimplemented("GetGroupMessages not yet implemented"))
    }

    async fn health(
        &self,
        _request: Request<HealthRequest>,
    ) -> Result<Response<HealthStatus>, Status> {
        Ok(Response::new(HealthStatus {
            status: "healthy".to_string(),
            checks: vec![],
        }))
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let config = ServiceConfig::load()?;
    observability::init_tracing(&config.service_name, &config.observability.log_level);

    tracing::info!("Starting messaging service on {}:{}", config.host, config.port);

    // Initialize database connections
    let tikv_endpoints = vec![config.database.tikv_pd_endpoints.clone()];
    let scylla_nodes = vec![config.database.scylladb_nodes.clone()];

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
