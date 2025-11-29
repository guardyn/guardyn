//! Pre-signed URL Handlers
//!
//! Generate pre-signed URLs for direct upload/download

use crate::{
    config::MediaConfig,
    db::{DatabaseClient, MediaMetadataRecord},
    jwt,
    proto::{
        common::{error_response::ErrorCode, ErrorResponse},
        media::{
            GetDownloadUrlRequest, GetDownloadUrlResponse,
            GetUploadUrlRequest, GetUploadUrlResponse,
            MediaMetadata, MediaType, UploadStatus,
        },
    },
    storage::StorageClient,
};
use std::collections::HashMap;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tonic::{Request, Response, Status};

/// Handle get upload URL request
pub async fn get_upload_url(
    request: Request<GetUploadUrlRequest>,
    db: Arc<DatabaseClient>,
    storage: Arc<StorageClient>,
    jwt_secret: &str,
    config: &MediaConfig,
) -> Result<Response<GetUploadUrlResponse>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let req = request.into_inner();
    
    if req.filename.is_empty() {
        return Ok(Response::new(GetUploadUrlResponse {
            upload_url: String::new(),
            media_id: String::new(),
            expires_at: 0,
            headers: HashMap::new(),
            error: Some(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "filename is required".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Generate media ID and storage path
    let media_id = DatabaseClient::generate_media_id();
    let extension = req.filename
        .rsplit('.')
        .next()
        .unwrap_or("bin");
    let storage_path = format!("{}/{}.{}", &user_id, &media_id, extension);

    // Determine content type
    let content_type = if req.mime_type.is_empty() {
        mime_guess::from_path(&req.filename)
            .first_or_octet_stream()
            .to_string()
    } else {
        req.mime_type.clone()
    };

    // Generate pre-signed URL
    let upload_url = match storage
        .generate_upload_url(&storage_path, &content_type, None)
        .await
    {
        Ok(url) => url,
        Err(e) => {
            tracing::error!(error = %e, "Failed to generate upload URL");
            return Ok(Response::new(GetUploadUrlResponse {
                upload_url: String::new(),
                media_id: String::new(),
                expires_at: 0,
                headers: HashMap::new(),
                error: Some(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to generate upload URL".to_string(),
                    details: Default::default(),
                }),
            }));
        }
    };

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;
    let expires_at = now + config.presigned_url_expiry_seconds as i64;

    // Create pending metadata record
    let metadata_record = MediaMetadataRecord {
        media_id: media_id.clone(),
        owner_user_id: user_id.clone(),
        filename: req.filename.clone(),
        media_type: detect_media_type(&content_type) as i32,
        mime_type: content_type.clone(),
        size_bytes: req.size_bytes,
        checksum_sha256: String::new(), // Will be set after upload
        created_at: now * 1000,
        updated_at: now * 1000,
        status: UploadStatus::Pending as i32,
        width: None,
        height: None,
        duration_ms: None,
        thumbnail_id: None,
        is_encrypted: false,
        encryption_key_id: None,
        iv: None,
        conversation_id: if req.conversation_id.is_empty() {
            None
        } else {
            Some(req.conversation_id)
        },
        message_id: None,
        storage_path: storage_path.clone(),
    };

    // Store pending metadata
    if let Err(e) = db.store_media_metadata(&metadata_record).await {
        tracing::error!(error = %e, "Failed to store pending metadata");
        return Ok(Response::new(GetUploadUrlResponse {
            upload_url: String::new(),
            media_id: String::new(),
            expires_at: 0,
            headers: HashMap::new(),
            error: Some(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to create upload record".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Headers required for the upload
    let mut headers = HashMap::new();
    headers.insert("Content-Type".to_string(), content_type);

    tracing::info!(
        media_id = %media_id,
        user_id = %user_id,
        expires_at = expires_at,
        "Upload URL generated"
    );

    Ok(Response::new(GetUploadUrlResponse {
        upload_url,
        media_id,
        expires_at,
        headers,
        error: None,
    }))
}

/// Handle get download URL request
pub async fn get_download_url(
    request: Request<GetDownloadUrlRequest>,
    db: Arc<DatabaseClient>,
    storage: Arc<StorageClient>,
    jwt_secret: &str,
) -> Result<Response<GetDownloadUrlResponse>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let req = request.into_inner();
    
    if req.media_id.is_empty() {
        return Ok(Response::new(GetDownloadUrlResponse {
            download_url: String::new(),
            expires_at: 0,
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "media_id is required".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Get metadata
    let metadata = match db.get_media_metadata(&req.media_id).await {
        Ok(Some(m)) => m,
        Ok(None) => {
            return Ok(Response::new(GetDownloadUrlResponse {
                download_url: String::new(),
                expires_at: 0,
                metadata: None,
                error: Some(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "Media not found".to_string(),
                    details: Default::default(),
                }),
            }));
        }
        Err(e) => {
            tracing::error!(error = %e, "Failed to get media metadata");
            return Ok(Response::new(GetDownloadUrlResponse {
                download_url: String::new(),
                expires_at: 0,
                metadata: None,
                error: Some(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Database error".to_string(),
                    details: Default::default(),
                }),
            }));
        }
    };

    // Check ownership
    if metadata.owner_user_id != user_id {
        return Ok(Response::new(GetDownloadUrlResponse {
            download_url: String::new(),
            expires_at: 0,
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::Unauthorized as i32,
                message: "Not authorized to access this media".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Generate pre-signed URL
    let download_url = match storage.generate_download_url(&metadata.storage_path, None).await {
        Ok(url) => url,
        Err(e) => {
            tracing::error!(error = %e, "Failed to generate download URL");
            return Ok(Response::new(GetDownloadUrlResponse {
                download_url: String::new(),
                expires_at: 0,
                metadata: None,
                error: Some(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to generate download URL".to_string(),
                    details: Default::default(),
                }),
            }));
        }
    };

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;
    let expires_at = now + 3600; // 1 hour default

    tracing::debug!(
        media_id = %req.media_id,
        user_id = %user_id,
        "Download URL generated"
    );

    Ok(Response::new(GetDownloadUrlResponse {
        download_url,
        expires_at,
        metadata: Some(MediaMetadata {
            media_id: metadata.media_id,
            owner_user_id: metadata.owner_user_id,
            filename: metadata.filename,
            media_type: metadata.media_type,
            mime_type: metadata.mime_type,
            size_bytes: metadata.size_bytes,
            checksum_sha256: metadata.checksum_sha256,
            created_at: metadata.created_at,
            updated_at: metadata.updated_at,
            status: metadata.status,
            width: metadata.width.unwrap_or(0),
            height: metadata.height.unwrap_or(0),
            duration_ms: metadata.duration_ms.unwrap_or(0),
            thumbnail_id: metadata.thumbnail_id.unwrap_or_default(),
            is_encrypted: metadata.is_encrypted,
            encryption_key_id: metadata.encryption_key_id.unwrap_or_default(),
            iv: metadata.iv.unwrap_or_default(),
            conversation_id: metadata.conversation_id.unwrap_or_default(),
            message_id: metadata.message_id.unwrap_or_default(),
            storage_path: metadata.storage_path,
        }),
        error: None,
    }))
}

/// Detect media type from MIME type
fn detect_media_type(mime_type: &str) -> MediaType {
    if mime_type.starts_with("image/") {
        MediaType::Image
    } else if mime_type.starts_with("video/") {
        MediaType::Video
    } else if mime_type.starts_with("audio/") {
        MediaType::Audio
    } else if mime_type.starts_with("application/pdf")
        || mime_type.starts_with("application/msword")
        || mime_type.starts_with("application/vnd.openxmlformats")
        || mime_type.starts_with("text/")
    {
        MediaType::Document
    } else {
        MediaType::Other
    }
}
