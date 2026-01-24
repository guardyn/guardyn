/// Authentication Service
///
/// Handles:
/// - User registration with E2EE key bundles
/// - Login/logout with JWT tokens
/// - Device management
/// - Session handling
/// - Token generation and validation

mod handlers;
mod models;
mod jwt;
mod db;

use guardyn_common::{config::ServiceConfig, observability, kafka::{KafkaProducer, KafkaConfig}};
use tonic::{transport::Server, Request, Response, Status};
use anyhow::Result;
use std::sync::Arc;

// Import generated protobuf code - pub to make available to handlers
pub mod proto {
    pub mod common {
        include!("generated/guardyn.common.rs");
    }
    pub mod auth {
        include!("generated/guardyn.auth.rs");
    }
}

use proto::auth::{
    auth_service_server::{AuthService, AuthServiceServer},
    RegisterRequest, RegisterResponse,
    LoginRequest, LoginResponse,
    LogoutRequest, LogoutResponse,
    RefreshTokenRequest, RefreshTokenResponse,
    ValidateTokenRequest, ValidateTokenResponse,
    GetKeyBundleRequest, GetKeyBundleResponse,
    UploadPreKeysRequest, UploadPreKeysResponse,
    UploadMlsKeyPackageRequest, UploadMlsKeyPackageResponse,
    GetMlsKeyPackageRequest, GetMlsKeyPackageResponse,
    SearchUsersRequest, SearchUsersResponse,
    GetUserProfileRequest, GetUserProfileResponse,
    UpdateProfileRequest, UpdateProfileResponse,
    DeleteAccountRequest, DeleteAccountResponse,
    AddContactRequest, AddContactResponse,
    RemoveContactRequest, RemoveContactResponse,
    ListContactsRequest, ListContactsResponse,
    GetContactRequest, GetContactResponse,
    UpdateContactRequest, UpdateContactResponse,
    HealthRequest,
};
use proto::common::HealthStatus;

/// Authentication Service Implementation
pub struct AuthServiceImpl {
    db: db::DatabaseClient,
    jwt_secret: String,
    event_producer: Option<Arc<KafkaProducer>>,
}

impl AuthServiceImpl {
    pub fn new(db: db::DatabaseClient, jwt_secret: String) -> Self {
        Self { db, jwt_secret, event_producer: None }
    }

    pub fn with_events(db: db::DatabaseClient, jwt_secret: String, producer: KafkaProducer) -> Self {
        Self {
            db,
            jwt_secret,
            event_producer: Some(Arc::new(producer)),
        }
    }
}

#[tonic::async_trait]
impl AuthService for AuthServiceImpl {
    async fn register(
        &self,
        request: Request<RegisterRequest>,
    ) -> Result<Response<RegisterResponse>, Status> {
        handlers::register::handle(self, request).await
    }

    async fn login(
        &self,
        request: Request<LoginRequest>,
    ) -> Result<Response<LoginResponse>, Status> {
        handlers::login::handle(self, request).await
    }

    async fn logout(
        &self,
        request: Request<LogoutRequest>,
    ) -> Result<Response<LogoutResponse>, Status> {
        handlers::logout::handle(self, request).await
    }

    async fn refresh_token(
        &self,
        request: Request<RefreshTokenRequest>,
    ) -> Result<Response<RefreshTokenResponse>, Status> {
        handlers::refresh_token::handle(self, request).await
    }

    async fn validate_token(
        &self,
        request: Request<ValidateTokenRequest>,
    ) -> Result<Response<ValidateTokenResponse>, Status> {
        handlers::validate_token::handle(self, request).await
    }

    async fn get_key_bundle(
        &self,
        request: Request<GetKeyBundleRequest>,
    ) -> Result<Response<GetKeyBundleResponse>, Status> {
        handlers::key_bundle::get(self, request).await
    }

    async fn upload_pre_keys(
        &self,
        request: Request<UploadPreKeysRequest>,
    ) -> Result<Response<UploadPreKeysResponse>, Status> {
        handlers::key_bundle::upload(self, request).await
    }

    async fn upload_mls_key_package(
        &self,
        request: Request<UploadMlsKeyPackageRequest>,
    ) -> Result<Response<UploadMlsKeyPackageResponse>, Status> {
        let db = std::sync::Arc::new(self.db.clone());
        handlers::mls_key_package::upload_mls_key_package(request, db, &self.jwt_secret).await
    }

    async fn get_mls_key_package(
        &self,
        request: Request<GetMlsKeyPackageRequest>,
    ) -> Result<Response<GetMlsKeyPackageResponse>, Status> {
        let db = std::sync::Arc::new(self.db.clone());
        handlers::mls_key_package::get_mls_key_package(request, db).await
    }

    async fn search_users(
        &self,
        request: Request<SearchUsersRequest>,
    ) -> Result<Response<SearchUsersResponse>, Status> {
        let response = handlers::search_users::handle_search_users(
            request.into_inner(),
            self.db.clone(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn get_user_profile(
        &self,
        request: Request<GetUserProfileRequest>,
    ) -> Result<Response<GetUserProfileResponse>, Status> {
        let response = handlers::get_user_profile::handle_get_user_profile(
            request.into_inner(),
            self.db.clone(),
        )
        .await;
        Ok(Response::new(response))
    }

    async fn update_profile(
        &self,
        request: Request<UpdateProfileRequest>,
    ) -> Result<Response<UpdateProfileResponse>, Status> {
        let db = std::sync::Arc::new(self.db.clone());
        let response = handlers::update_profile::update_profile(
            request.into_inner(),
            db,
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn delete_account(
        &self,
        request: Request<DeleteAccountRequest>,
    ) -> Result<Response<DeleteAccountResponse>, Status> {
        handlers::delete_account::handle(self, request).await
    }

    // ============================
    // Contacts Management
    // ============================

    async fn add_contact(
        &self,
        request: Request<AddContactRequest>,
    ) -> Result<Response<AddContactResponse>, Status> {
        let response = handlers::contacts::handle_add_contact(
            request.into_inner(),
            self.db.clone(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn remove_contact(
        &self,
        request: Request<RemoveContactRequest>,
    ) -> Result<Response<RemoveContactResponse>, Status> {
        let response = handlers::contacts::handle_remove_contact(
            request.into_inner(),
            self.db.clone(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn list_contacts(
        &self,
        request: Request<ListContactsRequest>,
    ) -> Result<Response<ListContactsResponse>, Status> {
        let response = handlers::contacts::handle_list_contacts(
            request.into_inner(),
            self.db.clone(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn get_contact(
        &self,
        request: Request<GetContactRequest>,
    ) -> Result<Response<GetContactResponse>, Status> {
        let response = handlers::contacts::handle_get_contact(
            request.into_inner(),
            self.db.clone(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn update_contact(
        &self,
        request: Request<UpdateContactRequest>,
    ) -> Result<Response<UpdateContactResponse>, Status> {
        let response = handlers::contacts::handle_update_contact(
            request.into_inner(),
            self.db.clone(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn health(
        &self,
        _request: Request<HealthRequest>,
    ) -> Result<Response<HealthStatus>, Status> {
        use proto::common::health_status::Status as HealthStatusEnum;

        // Check TiKV connectivity
        let db_status = match self.db.health_check().await {
            Ok(_) => "healthy",
            Err(e) => {
                tracing::warn!("TiKV health check failed: {}", e);
                "unhealthy"
            }
        };

        let overall_status = if db_status == "healthy" {
            HealthStatusEnum::Healthy
        } else {
            HealthStatusEnum::Unhealthy
        };

        let status = HealthStatus {
            status: overall_status as i32,
            version: env!("CARGO_PKG_VERSION").to_string(),
            timestamp: Some(proto::common::Timestamp {
                seconds: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs() as i64,
                nanos: 0,
            }),
            components: std::collections::HashMap::from([
                ("tikv".to_string(), db_status.to_string()),
                ("jwt".to_string(), "healthy".to_string()),
            ]),
        };

        Ok(Response::new(status))
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

    tracing::info!(
        service = "auth-service",
        version = env!("CARGO_PKG_VERSION"),
        "Starting authentication service"
    );

    // Initialize database connection
    let db = db::DatabaseClient::new(config.database.tikv_pd_endpoints.clone()).await?;

    // Load JWT secret from environment (GUARDYN_AUTH__JWT_SECRET)
    // Falls back to legacy JWT_SECRET, then to dev default
    let jwt_secret = std::env::var("GUARDYN_AUTH__JWT_SECRET")
        .or_else(|_| std::env::var("JWT_SECRET"))
        .unwrap_or_else(|_| config.auth.jwt_secret.clone());

    if jwt_secret.len() < 32 {
        tracing::error!("JWT secret is too short (< 32 bytes) - this is insecure!");
    }

    if jwt_secret.contains("DEV") || jwt_secret.contains("development") || jwt_secret.contains("UNSAFE") {
        tracing::warn!("Using development JWT secret - DO NOT USE IN PRODUCTION");
    }

    // Initialize Kafka producer for cross-service events
    let kafka_config = KafkaConfig::from_env();
    let auth_service = match KafkaProducer::new(&kafka_config) {
        Ok(producer) => {
            tracing::info!("Kafka producer initialized for cross-service events");
            AuthServiceImpl::with_events(db, jwt_secret, producer)
        }
        Err(e) => {
            tracing::warn!(
                error = %e,
                "Failed to create Kafka producer - cross-service events disabled"
            );
            AuthServiceImpl::new(db, jwt_secret)
        }
    };

    // Build gRPC server
    let addr = format!("{}:{}", config.host, config.port).parse()?;

    tracing::info!(
        address = %addr,
        "Auth service gRPC server starting"
    );

    Server::builder()
        .add_service(AuthServiceServer::new(auth_service))
        .serve(addr)
        .await?;

    Ok(())
}
