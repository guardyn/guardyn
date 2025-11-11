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

use guardyn_common::{config::ServiceConfig, observability};
use tonic::{transport::Server, Request, Response, Status};
use anyhow::Result;

// Import generated protobuf code
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
    HealthRequest,
};
use proto::common::HealthStatus;

/// Authentication Service Implementation
pub struct AuthServiceImpl {
    db: db::DatabaseClient,
    jwt_secret: String,
}

impl AuthServiceImpl {
    pub fn new(db: db::DatabaseClient, jwt_secret: String) -> Self {
        Self { db, jwt_secret }
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
    observability::init_tracing(&config.service_name, &config.observability.log_level);

    tracing::info!(
        service = "auth-service",
        version = env!("CARGO_PKG_VERSION"),
        "Starting authentication service"
    );

    // Initialize database connection
    let db = db::DatabaseClient::new(config.database.tikv_pd_endpoints.clone()).await?;

    // Load JWT secret from environment or config
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "development-secret-change-in-production".to_string());

    if jwt_secret == "development-secret-change-in-production" {
        tracing::warn!("Using default JWT secret - DO NOT USE IN PRODUCTION");
    }

    // Create service instance
    let auth_service = AuthServiceImpl::new(db, jwt_secret);

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
