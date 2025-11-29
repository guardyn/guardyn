//! Thumbnail Generation Handler
//!
//! Generate thumbnails for images

use crate::{
    config::MediaConfig,
    db::{DatabaseClient, MediaMetadataRecord},
    jwt,
    proto::{
        common::{error_response::ErrorCode, ErrorResponse},
        media::{
            GenerateThumbnailRequest, GenerateThumbnailResponse,
            MediaMetadata, MediaType, UploadStatus,
        },
    },
    storage::StorageClient,
    thumbnail::{ThumbnailGenerator, get_image_dimensions},
};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tonic::{Request, Response, Status};

/// Handle thumbnail generation request
pub async fn handle(
    request: Request<GenerateThumbnailRequest>,
    db: Arc<DatabaseClient>,
    storage: Arc<StorageClient>,
    jwt_secret: &str,
    config: &MediaConfig,
) -> Result<Response<GenerateThumbnailResponse>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let req = request.into_inner();
    
    if req.media_id.is_empty() {
        return Ok(Response::new(GenerateThumbnailResponse {
            thumbnail_id: String::new(),
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "media_id is required".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Check if thumbnails are enabled
    if !config.thumbnails_enabled {
        return Ok(Response::new(GenerateThumbnailResponse {
            thumbnail_id: String::new(),
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Thumbnail generation is disabled".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Get source media metadata
    let source_metadata = match db.get_media_metadata(&req.media_id).await {
        Ok(Some(m)) => m,
        Ok(None) => {
            return Ok(Response::new(GenerateThumbnailResponse {
                thumbnail_id: String::new(),
                metadata: None,
                error: Some(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "Source media not found".to_string(),
                    details: Default::default(),
                }),
            }));
        }
        Err(e) => {
            tracing::error!(error = %e, "Failed to get source media metadata");
            return Ok(Response::new(GenerateThumbnailResponse {
                thumbnail_id: String::new(),
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
    if source_metadata.owner_user_id != user_id {
        return Ok(Response::new(GenerateThumbnailResponse {
            thumbnail_id: String::new(),
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::Unauthorized as i32,
                message: "Not authorized to generate thumbnail".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Check if source is an image
    if !ThumbnailGenerator::is_supported_mime(&source_metadata.mime_type) {
        return Ok(Response::new(GenerateThumbnailResponse {
            thumbnail_id: String::new(),
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Source media type not supported for thumbnail generation".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Check if thumbnail already exists
    if let Some(ref existing_thumb_id) = source_metadata.thumbnail_id {
        if let Ok(Some(existing_thumb)) = db.get_media_metadata(existing_thumb_id).await {
            tracing::info!(
                media_id = %req.media_id,
                thumbnail_id = %existing_thumb_id,
                "Returning existing thumbnail"
            );
            return Ok(Response::new(GenerateThumbnailResponse {
                thumbnail_id: existing_thumb_id.clone(),
                metadata: Some(to_proto_metadata(&existing_thumb)),
                error: None,
            }));
        }
    }

    // Download source image
    let source_data = match storage.download_file(&source_metadata.storage_path).await {
        Ok(data) => data,
        Err(e) => {
            tracing::error!(error = %e, "Failed to download source image");
            return Ok(Response::new(GenerateThumbnailResponse {
                thumbnail_id: String::new(),
                metadata: None,
                error: Some(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to download source image".to_string(),
                    details: Default::default(),
                }),
            }));
        }
    };

    // Determine thumbnail parameters
    let max_width = if req.max_width > 0 {
        req.max_width as u32
    } else {
        config.thumbnail_max_width
    };
    let max_height = if req.max_height > 0 {
        req.max_height as u32
    } else {
        config.thumbnail_max_height
    };
    let quality = if req.quality > 0 && req.quality <= 100 {
        req.quality as u8
    } else {
        config.thumbnail_quality
    };
    let format = if req.format.is_empty() {
        "jpeg"
    } else {
        &req.format
    };

    // Generate thumbnail
    let generator = ThumbnailGenerator::with_dimensions(max_width, max_height, quality);
    let thumbnail_data = match generator.generate(&source_data, format) {
        Ok(data) => data,
        Err(e) => {
            tracing::error!(error = %e, "Failed to generate thumbnail");
            return Ok(Response::new(GenerateThumbnailResponse {
                thumbnail_id: String::new(),
                metadata: None,
                error: Some(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to generate thumbnail: {}", e),
                    details: Default::default(),
                }),
            }));
        }
    };

    // Get thumbnail dimensions
    let (thumb_width, thumb_height) = get_image_dimensions(&thumbnail_data)
        .unwrap_or((max_width, max_height));

    // Generate thumbnail ID and storage path
    let thumbnail_id = DatabaseClient::generate_media_id();
    let storage_path = format!("{}/thumb_{}.{}", &user_id, &thumbnail_id, format);

    // Upload thumbnail
    let mime_type = ThumbnailGenerator::format_to_mime(format);
    if let Err(e) = storage
        .upload_file(&storage_path, thumbnail_data.clone(), mime_type)
        .await
    {
        tracing::error!(error = %e, "Failed to upload thumbnail");
        return Ok(Response::new(GenerateThumbnailResponse {
            thumbnail_id: String::new(),
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to upload thumbnail".to_string(),
                details: Default::default(),
            }),
        }));
    }

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_millis() as i64;

    // Create thumbnail metadata
    let thumb_metadata = MediaMetadataRecord {
        media_id: thumbnail_id.clone(),
        owner_user_id: user_id.clone(),
        filename: format!("thumb_{}.{}", req.media_id, format),
        media_type: MediaType::Image as i32,
        mime_type: mime_type.to_string(),
        size_bytes: thumbnail_data.len() as i64,
        checksum_sha256: String::new(), // Optional for thumbnails
        created_at: now,
        updated_at: now,
        status: UploadStatus::Completed as i32,
        width: Some(thumb_width as i32),
        height: Some(thumb_height as i32),
        duration_ms: None,
        thumbnail_id: None, // Thumbnails don't have thumbnails
        is_encrypted: false,
        encryption_key_id: None,
        iv: None,
        conversation_id: source_metadata.conversation_id.clone(),
        message_id: source_metadata.message_id.clone(),
        storage_path: storage_path.clone(),
    };

    // Store thumbnail metadata
    if let Err(e) = db.store_media_metadata(&thumb_metadata).await {
        tracing::error!(error = %e, "Failed to store thumbnail metadata");
        return Ok(Response::new(GenerateThumbnailResponse {
            thumbnail_id: String::new(),
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to store thumbnail metadata".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Update source media with thumbnail reference
    let mut updated_source = source_metadata.clone();
    updated_source.thumbnail_id = Some(thumbnail_id.clone());
    updated_source.updated_at = now;
    if let Err(e) = db.update_media_metadata(&updated_source).await {
        tracing::warn!(error = %e, "Failed to update source media with thumbnail reference");
        // Not a fatal error
    }

    tracing::info!(
        media_id = %req.media_id,
        thumbnail_id = %thumbnail_id,
        dimensions = %format!("{}x{}", thumb_width, thumb_height),
        "Thumbnail generated successfully"
    );

    Ok(Response::new(GenerateThumbnailResponse {
        thumbnail_id,
        metadata: Some(to_proto_metadata(&thumb_metadata)),
        error: None,
    }))
}

/// Convert database record to proto metadata
fn to_proto_metadata(record: &MediaMetadataRecord) -> MediaMetadata {
    MediaMetadata {
        media_id: record.media_id.clone(),
        owner_user_id: record.owner_user_id.clone(),
        filename: record.filename.clone(),
        media_type: record.media_type,
        mime_type: record.mime_type.clone(),
        size_bytes: record.size_bytes,
        checksum_sha256: record.checksum_sha256.clone(),
        created_at: record.created_at,
        updated_at: record.updated_at,
        status: record.status,
        width: record.width.unwrap_or(0),
        height: record.height.unwrap_or(0),
        duration_ms: record.duration_ms.unwrap_or(0),
        thumbnail_id: record.thumbnail_id.clone().unwrap_or_default(),
        is_encrypted: record.is_encrypted,
        encryption_key_id: record.encryption_key_id.clone().unwrap_or_default(),
        iv: record.iv.clone().unwrap_or_default(),
        conversation_id: record.conversation_id.clone().unwrap_or_default(),
        message_id: record.message_id.clone().unwrap_or_default(),
        storage_path: record.storage_path.clone(),
    }
}
