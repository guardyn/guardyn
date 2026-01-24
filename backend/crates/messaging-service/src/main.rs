/// Messaging Service
///
/// Handles:
/// - Message routing
/// - Message persistence
/// - Message history
/// - Delivery guarantees
/// - Group chat logic
/// - WebSocket real-time messaging

mod handlers;
mod models;
mod db;
mod nats;
mod jwt;
mod crypto;
mod mls_manager;
mod auth_client;
mod config;
mod websocket;
mod event_consumer;

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
    pub mod auth {
        tonic::include_proto!("guardyn.auth");
    }
}

use proto::messaging::{
    messaging_service_server::{MessagingService, MessagingServiceServer},
    SendMessageRequest, SendMessageResponse,
    ReceiveMessagesRequest, Message,
    GetMessagesRequest, GetMessagesResponse,
    GetConversationsRequest, GetConversationsResponse,
    MarkAsReadRequest, MarkAsReadResponse,
    DeleteMessageRequest, DeleteMessageResponse,
    ClearChatRequest, ClearChatResponse,
    TypingIndicatorRequest, TypingIndicatorResponse,
    CreateGroupRequest, CreateGroupResponse,
    AddGroupMemberRequest, AddGroupMemberResponse,
    RemoveGroupMemberRequest, RemoveGroupMemberResponse,
    ChangeMemberRoleRequest, ChangeMemberRoleResponse,
    SendGroupMessageRequest, SendGroupMessageResponse,
    GetGroupMessagesRequest, GetGroupMessagesResponse,
    GetGroupsRequest, GetGroupsResponse,
    GetGroupByIdRequest, GetGroupByIdResponse,
    UpdateGroupRequest, UpdateGroupResponse,
    LeaveGroupRequest, LeaveGroupResponse,
    DeleteGroupRequest, DeleteGroupResponse,
    HealthRequest,
    // Phase 2: Reactions
    AddReactionRequest, AddReactionResponse,
    RemoveReactionRequest, RemoveReactionResponse,
    GetReactionsRequest, GetReactionsResponse,
    // Phase 2: Read Receipts
    SendReadReceiptRequest, SendReadReceiptResponse,
    GetReadReceiptsRequest, GetReadReceiptsResponse,
    // Phase 2: Forward/Reply
    ForwardMessageRequest, ForwardMessageResponse,
    // Phase 2: Edit
    EditMessageRequest, EditMessageResponse,
    // Phase 2: Search
    SearchMessagesRequest, SearchMessagesResponse,
    // Phase 2: Disappearing Messages
    SetDisappearingMessagesRequest, SetDisappearingMessagesResponse,
    GetDisappearingConfigRequest, GetDisappearingConfigResponse,
    // Phase 3: Block User
    BlockUserRequest, BlockUserResponse,
    UnblockUserRequest, UnblockUserResponse,
    GetBlockedUsersRequest, GetBlockedUsersResponse,
    // Phase 3: Delete Conversation
    DeleteConversationRequest, DeleteConversationResponse,
};
use proto::common::HealthStatus;

pub struct MessagingServiceImpl {
    db: Arc<db::DatabaseClient>,
    nats: Arc<nats::NatsClient>,
    config: config::MessagingConfig,
}

#[tonic::async_trait]
impl MessagingService for MessagingServiceImpl {
    async fn send_message(
        &self,
        request: Request<SendMessageRequest>,
    ) -> Result<Response<SendMessageResponse>, Status> {
        // Use E2EE configuration from service config
        if self.config.e2ee.enabled {
            tracing::info!("E2EE enabled, using send_message_e2ee handler");
            handlers::send_message_e2ee(request.into_inner(), self.db.clone(), self.nats.clone()).await
        } else {
            tracing::debug!("E2EE disabled, using legacy send_message handler");
            handlers::send_message(request.into_inner(), self.db.clone(), self.nats.clone()).await
        }
    }

    type ReceiveMessagesStream = tokio_stream::wrappers::ReceiverStream<Result<Message, Status>>;

    async fn receive_messages(
        &self,
        request: Request<ReceiveMessagesRequest>,
    ) -> Result<Response<Self::ReceiveMessagesStream>, Status> {
        // Use E2EE configuration from service config
        if self.config.e2ee.enabled {
            tracing::info!("E2EE enabled, using receive_messages_e2ee handler");
            handlers::receive_messages_e2ee(request.into_inner(), self.db.clone(), self.nats.clone()).await
        } else {
            tracing::debug!("E2EE disabled, using legacy receive_messages handler");
            handlers::receive_messages(request.into_inner(), self.db.clone(), self.nats.clone()).await
        }
    }

    async fn get_messages(
        &self,
        request: Request<GetMessagesRequest>,
    ) -> Result<Response<GetMessagesResponse>, Status> {
        handlers::get_messages(request.into_inner(), self.db.clone()).await
    }

    async fn get_conversations(
        &self,
        request: Request<GetConversationsRequest>,
    ) -> Result<Response<GetConversationsResponse>, Status> {
        handlers::get_conversations(request.into_inner(), self.db.clone()).await
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
        request: Request<TypingIndicatorRequest>,
    ) -> Result<Response<TypingIndicatorResponse>, Status> {
        handlers::send_typing_indicator(request.into_inner(), self.db.clone(), self.nats.clone())
            .await
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

    async fn change_member_role(
        &self,
        request: Request<ChangeMemberRoleRequest>,
    ) -> Result<Response<ChangeMemberRoleResponse>, Status> {
        handlers::change_member_role(request.into_inner(), self.db.clone()).await
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

    async fn get_groups(
        &self,
        request: Request<GetGroupsRequest>,
    ) -> Result<Response<GetGroupsResponse>, Status> {
        handlers::get_groups(request.into_inner(), self.db.clone()).await
    }

    async fn get_group_by_id(
        &self,
        request: Request<GetGroupByIdRequest>,
    ) -> Result<Response<GetGroupByIdResponse>, Status> {
        handlers::get_group_by_id(request.into_inner(), self.db.clone()).await
    }

    async fn update_group(
        &self,
        request: Request<UpdateGroupRequest>,
    ) -> Result<Response<UpdateGroupResponse>, Status> {
        handlers::update_group(request.into_inner(), self.db.clone()).await
    }

    async fn leave_group(
        &self,
        request: Request<LeaveGroupRequest>,
    ) -> Result<Response<LeaveGroupResponse>, Status> {
        handlers::leave_group(request.into_inner(), self.db.clone()).await
    }

    async fn delete_group(
        &self,
        request: Request<DeleteGroupRequest>,
    ) -> Result<Response<DeleteGroupResponse>, Status> {
        handlers::delete_group(request.into_inner(), self.db.clone()).await
    }

    async fn clear_chat(
        &self,
        request: Request<ClearChatRequest>,
    ) -> Result<Response<ClearChatResponse>, Status> {
        handlers::clear_chat(request.into_inner(), self.db.clone()).await
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
        match self.nats.connection_state() {
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

    // ========================================================================
    // Phase 2: Message Reactions
    // ========================================================================

    async fn add_reaction(
        &self,
        request: Request<AddReactionRequest>,
    ) -> Result<Response<AddReactionResponse>, Status> {
        handlers::add_reaction(self.db.clone(), request).await
    }

    async fn remove_reaction(
        &self,
        request: Request<RemoveReactionRequest>,
    ) -> Result<Response<RemoveReactionResponse>, Status> {
        handlers::remove_reaction(self.db.clone(), request).await
    }

    async fn get_reactions(
        &self,
        request: Request<GetReactionsRequest>,
    ) -> Result<Response<GetReactionsResponse>, Status> {
        handlers::get_reactions(self.db.clone(), request).await
    }

    // ========================================================================
    // Phase 2: Enhanced Read Receipts
    // ========================================================================

    async fn send_read_receipt(
        &self,
        request: Request<SendReadReceiptRequest>,
    ) -> Result<Response<SendReadReceiptResponse>, Status> {
        handlers::send_read_receipt(self.db.clone(), self.nats.clone(), request).await
    }

    async fn get_read_receipts(
        &self,
        request: Request<GetReadReceiptsRequest>,
    ) -> Result<Response<GetReadReceiptsResponse>, Status> {
        handlers::get_read_receipts(self.db.clone(), request).await
    }

    // ========================================================================
    // Phase 2: Reply/Quote/Forward
    // ========================================================================

    async fn forward_message(
        &self,
        request: Request<ForwardMessageRequest>,
    ) -> Result<Response<ForwardMessageResponse>, Status> {
        handlers::forward_message(self.db.clone(), request).await
    }

    // ========================================================================
    // Phase 2: Message Edit
    // ========================================================================

    async fn edit_message(
        &self,
        request: Request<EditMessageRequest>,
    ) -> Result<Response<EditMessageResponse>, Status> {
        handlers::edit_message(self.db.clone(), self.nats.clone(), request).await
    }

    // ========================================================================
    // Phase 2: Message Search
    // ========================================================================

    async fn search_messages(
        &self,
        request: Request<SearchMessagesRequest>,
    ) -> Result<Response<SearchMessagesResponse>, Status> {
        handlers::search_messages(self.db.clone(), request).await
    }

    // ========================================================================
    // Phase 2: Disappearing Messages
    // ========================================================================

    async fn set_disappearing_messages(
        &self,
        request: Request<SetDisappearingMessagesRequest>,
    ) -> Result<Response<SetDisappearingMessagesResponse>, Status> {
        handlers::set_disappearing_messages(self.db.clone(), self.nats.clone(), request).await
    }

    async fn get_disappearing_config(
        &self,
        request: Request<GetDisappearingConfigRequest>,
    ) -> Result<Response<GetDisappearingConfigResponse>, Status> {
        handlers::get_disappearing_config(self.db.clone(), request).await
    }

    // ========================================================================
    // Phase 3: User Blocking
    // ========================================================================

    async fn block_user(
        &self,
        request: Request<BlockUserRequest>,
    ) -> Result<Response<BlockUserResponse>, Status> {
        handlers::block_user(self.db.clone(), request).await
    }

    async fn unblock_user(
        &self,
        request: Request<UnblockUserRequest>,
    ) -> Result<Response<UnblockUserResponse>, Status> {
        handlers::unblock_user(self.db.clone(), request).await
    }

    async fn get_blocked_users(
        &self,
        request: Request<GetBlockedUsersRequest>,
    ) -> Result<Response<GetBlockedUsersResponse>, Status> {
        handlers::get_blocked_users(self.db.clone(), request).await
    }

    // ========================================================================
    // Phase 3: Delete Conversation
    // ========================================================================

    async fn delete_conversation(
        &self,
        request: Request<DeleteConversationRequest>,
    ) -> Result<Response<DeleteConversationResponse>, Status> {
        handlers::delete_conversation(self.db.clone(), request).await
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let config = ServiceConfig::load()?;
    // Initialize tracing with OpenTelemetry if endpoint is configured
    let otlp_endpoint = if config.observability.otlp_endpoint.is_empty() {
        None
    } else {
        Some(config.observability.otlp_endpoint.as_str())
    };
    let _tracing_guard = observability::init_tracing(
        &config.service_name,
        &config.observability.log_level,
        otlp_endpoint,
    );

    tracing::info!("Starting messaging service on {}:{}", config.host, config.port);

    // Load messaging-specific configuration (feature flags, etc.)
    let messaging_config = config::MessagingConfig::from_env();
    messaging_config.print_summary();

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

    let db = Arc::new(db);
    let nats = Arc::new(nats);

    // Start event consumer for cross-service events (user deletion, etc.)
    let event_consumer_enabled = std::env::var("ENABLE_EVENT_CONSUMER")
        .unwrap_or_else(|_| "true".to_string())
        .to_lowercase() == "true";

    if event_consumer_enabled {
        let (shutdown_tx, shutdown_rx) = tokio::sync::broadcast::channel::<()>(1);
        
        match event_consumer::EventConsumer::new(db.clone(), shutdown_rx) {
            Ok(consumer) => {
                tracing::info!("Starting event consumer for cross-service events");
                tokio::spawn(async move {
                    consumer.run().await;
                });
            }
            Err(e) => {
                tracing::warn!(
                    error = %e,
                    "Failed to create event consumer - cross-service events disabled"
                );
            }
        }
    }

    // Load service configuration
    let messaging_config = config::MessagingConfig::from_env();
    messaging_config.print_summary();

    // Create gRPC service
    let service = MessagingServiceImpl {
        db: db.clone(),
        nats: nats.clone(),
        config: messaging_config.clone(),
    };

    // Start WebSocket server if enabled
    let ws_enabled = std::env::var("ENABLE_WEBSOCKET")
        .unwrap_or_else(|_| "true".to_string())
        .to_lowercase() == "true";

    if ws_enabled {
        let ws_port: u16 = std::env::var("WEBSOCKET_PORT")
            .unwrap_or_else(|_| "8081".to_string())
            .parse()
            .unwrap_or(8081);

        let jwt_secret = config::get_jwt_secret();

        let ws_config = websocket::server::WebSocketServerConfig {
            port: ws_port,
            jwt_secret,
            max_connections_per_user: 5,
            heartbeat_interval: 30,
            connection_timeout: 90,
        };

        let ws_server = websocket::WebSocketServer::new(ws_config, db.clone(), nats.clone());

        tracing::info!(port = ws_port, "Starting WebSocket server");
        ws_server.spawn();
    }

    // Start gRPC server
    let addr = format!("{}:{}", config.host, config.port).parse()?;

    tracing::info!("Messaging service gRPC listening on {}", addr);

    Server::builder()
        .add_service(MessagingServiceServer::new(service))
        .serve(addr)
        .await?;

    Ok(())
}
