//! Media Service
//!
//! Handles:
//! - File uploads to S3/MinIO storage
//! - File downloads with streaming
//! - Media metadata management in TiKV
//! - Thumbnail generation for images/videos
//! - Pre-signed URLs for direct upload/download
//! - Media encryption/decryption support

mod config;
mod db;
mod handlers;
mod jwt;
mod storage;
mod thumbnail;

use anyhow::Result;
use guardyn_common::{config::ServiceConfig, observability};
use std::sync::Arc;
use tonic::{transport::Server, Request, Response, Status, Streaming};

// Import generated protobuf code
pub mod proto {
    pub mod common {
        include!("generated/guardyn.common.rs");
    }
    #[allow(clippy::large_enum_variant)]
    pub mod media {
        include!("generated/guardyn.media.rs");
    }
}

use proto::media::{
    media_service_server::{MediaService, MediaServiceServer},
    DeleteMediaRequest, DeleteMediaResponse, DownloadMediaRequest, DownloadMediaResponse,
    GenerateThumbnailRequest, GenerateThumbnailResponse, GetDownloadUrlRequest,
    GetDownloadUrlResponse, GetMediaMetadataRequest, GetMediaMetadataResponse, GetUploadUrlRequest,
    GetUploadUrlResponse, ListMediaRequest, ListMediaResponse, UploadMediaRequest,
    UploadMediaResponse,
};

/// Media Service Implementation
pub struct MediaServiceImpl {
    db: Arc<db::DatabaseClient>,
    storage: Arc<storage::StorageClient>,
    jwt_secret: String,
    config: config::MediaConfig,
}

impl MediaServiceImpl {
    pub async fn new(
        db: db::DatabaseClient,
        storage: storage::StorageClient,
        jwt_secret: String,
        config: config::MediaConfig,
    ) -> Self {
        Self {
            db: Arc::new(db),
            storage: Arc::new(storage),
            jwt_secret,
            config,
        }
    }
}

#[tonic::async_trait]
impl MediaService for MediaServiceImpl {
    type DownloadMediaStream =
        futures::stream::BoxStream<'static, Result<DownloadMediaResponse, Status>>;

    async fn upload_media(
        &self,
        request: Request<Streaming<UploadMediaRequest>>,
    ) -> Result<Response<UploadMediaResponse>, Status> {
        handlers::upload::handle(
            request,
            self.db.clone(),
            self.storage.clone(),
            &self.jwt_secret,
            &self.config,
        )
        .await
    }

    async fn download_media(
        &self,
        request: Request<DownloadMediaRequest>,
    ) -> Result<Response<Self::DownloadMediaStream>, Status> {
        handlers::download::handle(
            request,
            self.db.clone(),
            self.storage.clone(),
            &self.jwt_secret,
        )
        .await
    }

    async fn get_media_metadata(
        &self,
        request: Request<GetMediaMetadataRequest>,
    ) -> Result<Response<GetMediaMetadataResponse>, Status> {
        handlers::metadata::get(request, self.db.clone(), &self.jwt_secret).await
    }

    async fn delete_media(
        &self,
        request: Request<DeleteMediaRequest>,
    ) -> Result<Response<DeleteMediaResponse>, Status> {
        handlers::delete::handle(
            request,
            self.db.clone(),
            self.storage.clone(),
            &self.jwt_secret,
        )
        .await
    }

    async fn get_upload_url(
        &self,
        request: Request<GetUploadUrlRequest>,
    ) -> Result<Response<GetUploadUrlResponse>, Status> {
        handlers::presigned::get_upload_url(
            request,
            self.db.clone(),
            self.storage.clone(),
            &self.jwt_secret,
            &self.config,
        )
        .await
    }

    async fn get_download_url(
        &self,
        request: Request<GetDownloadUrlRequest>,
    ) -> Result<Response<GetDownloadUrlResponse>, Status> {
        handlers::presigned::get_download_url(
            request,
            self.db.clone(),
            self.storage.clone(),
            &self.jwt_secret,
        )
        .await
    }

    async fn generate_thumbnail(
        &self,
        request: Request<GenerateThumbnailRequest>,
    ) -> Result<Response<GenerateThumbnailResponse>, Status> {
        handlers::thumbnail::handle(
            request,
            self.db.clone(),
            self.storage.clone(),
            &self.jwt_secret,
            &self.config,
        )
        .await
    }

    async fn list_media(
        &self,
        request: Request<ListMediaRequest>,
    ) -> Result<Response<ListMediaResponse>, Status> {
        handlers::list::handle(request, self.db.clone(), &self.jwt_secret).await
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let service_config = ServiceConfig::load()?;
    let otlp_endpoint = std::env::var("OTEL_EXPORTER_OTLP_ENDPOINT").ok();
    let _tracing_guard = observability::init_tracing(
        &service_config.service_name,
        &service_config.observability.log_level,
        otlp_endpoint.as_deref(),
    );

    tracing::info!(
        service = "media-service",
        version = env!("CARGO_PKG_VERSION"),
        "Starting media service"
    );

    // Load media-specific configuration
    let media_config = config::MediaConfig::from_env();
    tracing::info!(
        bucket = %media_config.bucket_name,
        max_file_size = media_config.max_file_size_bytes,
        "Media configuration loaded"
    );

    // Connect to TiKV
    let tikv_endpoints = std::env::var("TIKV_PD_ENDPOINTS")
        .unwrap_or_else(|_| "pd.data.svc.cluster.local:2379".to_string());

    tracing::info!(endpoints = %tikv_endpoints, "Connecting to TiKV");
    let db = db::DatabaseClient::new(&tikv_endpoints).await?;
    tracing::info!("TiKV connection established");

    // Initialize S3/MinIO storage client
    tracing::info!(endpoint = %media_config.s3_endpoint, "Connecting to S3/MinIO");
    let storage = storage::StorageClient::new(&media_config).await?;
    tracing::info!("S3/MinIO connection established");

    // Ensure bucket exists
    storage
        .ensure_bucket_exists(&media_config.bucket_name)
        .await?;
    tracing::info!(bucket = %media_config.bucket_name, "Storage bucket ready");

    // Load JWT secret from environment (GUARDYN_AUTH__JWT_SECRET)
    // Falls back to legacy JWT_SECRET, then to dev default
    // MUST match auth-service configuration for token validation
    let jwt_secret = std::env::var("GUARDYN_AUTH__JWT_SECRET")
        .or_else(|_| std::env::var("JWT_SECRET"))
        .unwrap_or_else(|_| "development-secret-change-in-production".to_string());

    if jwt_secret.len() < 32 {
        tracing::error!("JWT secret is too short (< 32 bytes) - this is insecure!");
    }

    if jwt_secret.contains("DEV")
        || jwt_secret.contains("development")
        || jwt_secret.contains("UNSAFE")
    {
        tracing::warn!("Using development JWT secret - DO NOT USE IN PRODUCTION");
    }

    // Create service
    let service = MediaServiceImpl::new(db, storage, jwt_secret, media_config).await;

    // Start gRPC server
    let addr = format!("{}:{}", service_config.host, service_config.port).parse()?;

    tracing::info!(%addr, "Media service listening");

    Server::builder()
        .add_service(MediaServiceServer::new(service))
        .serve(addr)
        .await?;

    Ok(())
}
