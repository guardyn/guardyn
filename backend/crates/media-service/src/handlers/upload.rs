//! Upload Handler
//!
//! Handles streaming file uploads with unary response

use crate::{
    config::MediaConfig,
    db::{DatabaseClient, MediaMetadataRecord},
    jwt,
    proto::media::{
        upload_media_request::Content,
        MediaMetadata, MediaType, UploadMediaRequest, UploadMediaResponse, UploadStatus,
    },
    storage::StorageClient,
};
use bytes::BytesMut;
use futures::StreamExt;
use sha2::{Digest, Sha256};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tonic::{Request, Response, Status, Streaming};

/// Handle streaming upload request - returns a single response after upload completes
pub async fn handle(
    request: Request<Streaming<UploadMediaRequest>>,
    db: Arc<DatabaseClient>,
    storage: Arc<StorageClient>,
    jwt_secret: &str,
    config: &MediaConfig,
) -> Result<Response<UploadMediaResponse>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let mut stream = request.into_inner();
    let max_size = config.max_file_size_bytes;

    // First message should be the header
    let first_msg = stream.next().await
        .ok_or_else(|| Status::invalid_argument("Empty upload stream"))?
        .map_err(|e| Status::internal(format!("Stream error: {}", e)))?;

    let header = match first_msg.content {
        Some(Content::Header(h)) => h,
        _ => return Err(Status::invalid_argument("First message must be upload header")),
    };

    // Validate size
    if header.size_bytes > max_size as i64 {
        return Err(Status::invalid_argument(format!(
            "File too large. Maximum size is {} bytes",
            max_size
        )));
    }

    // Generate media ID and storage path
    let media_id = DatabaseClient::generate_media_id();
    let extension = header.filename
        .rsplit('.')
        .next()
        .unwrap_or("bin");
    let storage_path = format!("{}/{}.{}", &user_id, &media_id, extension);

    tracing::info!(
        media_id = %media_id,
        filename = %header.filename,
        size = header.size_bytes,
        "Starting upload"
    );

    // Collect chunks and calculate checksum
    let mut data = BytesMut::with_capacity(header.size_bytes as usize);
    let mut hasher = Sha256::new();
    let mut bytes_received: i64 = 0;

    while let Some(msg) = stream.next().await {
        let msg = msg.map_err(|e| Status::internal(format!("Stream error: {}", e)))?;
        
        if let Some(Content::Chunk(chunk_data)) = msg.content {
            bytes_received += chunk_data.len() as i64;
            
            // Check max size
            if bytes_received > max_size as i64 {
                return Err(Status::invalid_argument("File exceeds maximum size"));
            }
            
            hasher.update(&chunk_data);
            data.extend_from_slice(&chunk_data);
        }
    }

    // Verify checksum if provided
    let calculated_checksum = hex::encode(hasher.finalize());
    if !header.checksum_sha256.is_empty() && header.checksum_sha256 != calculated_checksum {
        return Err(Status::invalid_argument(format!(
            "Checksum mismatch. Expected: {}, Got: {}",
            header.checksum_sha256, calculated_checksum
        )));
    }

    // Upload to storage
    storage.upload_file(
        &storage_path,
        data.freeze(),
        &header.mime_type,
    ).await.map_err(|e| {
        tracing::error!(error = %e, "Failed to upload to storage");
        Status::internal("Failed to store file")
    })?;

    // Determine media type from mime type
    let media_type = determine_media_type(&header.mime_type);

    // Create metadata record
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    let metadata = MediaMetadataRecord {
        media_id: media_id.clone(),
        owner_user_id: user_id.clone(),
        filename: header.filename.clone(),
        mime_type: header.mime_type.clone(),
        size_bytes: bytes_received,
        storage_path: storage_path.clone(),
        checksum_sha256: calculated_checksum.clone(),
        media_type: media_type as i32,
        status: UploadStatus::Completed as i32,
        conversation_id: if header.conversation_id.is_empty() {
            None
        } else {
            Some(header.conversation_id.clone())
        },
        message_id: if header.message_id.is_empty() {
            None
        } else {
            Some(header.message_id.clone())
        },
        is_encrypted: header.is_encrypted,
        encryption_key_id: if header.encryption_key_id.is_empty() {
            None
        } else {
            Some(header.encryption_key_id.clone())
        },
        iv: if header.iv.is_empty() {
            None
        } else {
            Some(header.iv.clone())
        },
        thumbnail_id: None,
        width: None,
        height: None,
        duration_ms: None,
        created_at: now,
        updated_at: now,
    };

    // Save to database
    db.store_media_metadata(&metadata).await.map_err(|e| {
        tracing::error!(error = %e, "Failed to save metadata");
        Status::internal("Failed to save metadata")
    })?;

    tracing::info!(
        media_id = %media_id,
        size = bytes_received,
        "Upload completed"
    );

    // Create MediaMetadata response
    let response_metadata = MediaMetadata {
        media_id: media_id.clone(),
        owner_user_id: user_id,
        filename: header.filename,
        media_type: media_type as i32,
        mime_type: header.mime_type,
        size_bytes: bytes_received,
        checksum_sha256: calculated_checksum,
        created_at: now,
        updated_at: now,
        status: UploadStatus::Completed as i32,
        width: 0,
        height: 0,
        duration_ms: 0,
        thumbnail_id: String::new(),
        is_encrypted: header.is_encrypted,
        encryption_key_id: header.encryption_key_id,
        iv: header.iv,
        conversation_id: header.conversation_id,
        message_id: header.message_id,
        storage_path,
    };

    Ok(Response::new(UploadMediaResponse {
        media_id,
        status: UploadStatus::Completed as i32,
        metadata: Some(response_metadata),
        error_message: String::new(),
    }))
}

/// Determine media type from MIME type
fn determine_media_type(mime_type: &str) -> MediaType {
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
