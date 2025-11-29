//! Download Handler
//!
//! Handles streaming file downloads

use crate::{
    db::DatabaseClient,
    jwt,
    proto::media::{
        download_media_response::Content,
        DownloadMediaRequest, DownloadMediaResponse, MediaMetadata, UploadStatus,
    },
    storage::StorageClient,
};
use futures::stream::BoxStream;
use std::sync::Arc;
use tonic::{Request, Response, Status};

/// Handle download request
pub async fn handle(
    request: Request<DownloadMediaRequest>,
    db: Arc<DatabaseClient>,
    storage: Arc<StorageClient>,
    jwt_secret: &str,
) -> Result<Response<BoxStream<'static, Result<DownloadMediaResponse, Status>>>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let req = request.into_inner();
    let media_id = req.media_id;
    let offset = req.offset;
    let length = req.length;

    // Get metadata
    let metadata = db
        .get_media_metadata(&media_id)
        .await
        .map_err(|e| Status::internal(format!("Database error: {}", e)))?
        .ok_or_else(|| Status::not_found("Media not found"))?;

    // Check ownership (or allow if in same conversation - simplified for now)
    if metadata.owner_user_id != user_id {
        tracing::warn!(
            media_id = %media_id,
            owner = %metadata.owner_user_id,
            requester = %user_id,
            "Access denied to media"
        );
        return Err(Status::permission_denied("Not authorized to access this media"));
    }

    tracing::info!(
        media_id = %media_id,
        storage_path = %metadata.storage_path,
        offset = offset,
        length = length,
        "Starting download"
    );

    let storage_path = metadata.storage_path.clone();
    let storage_clone = storage.clone();
    let chunk_size: usize = 64 * 1024; // 64KB chunks

    // Stream response
    let output_stream = async_stream::try_stream! {
        // First message: metadata
        let meta_response = DownloadMediaResponse {
            content: Some(Content::Metadata(MediaMetadata {
                media_id: metadata.media_id.clone(),
                owner_user_id: metadata.owner_user_id.clone(),
                filename: metadata.filename.clone(),
                media_type: metadata.media_type,
                mime_type: metadata.mime_type.clone(),
                size_bytes: metadata.size_bytes,
                checksum_sha256: metadata.checksum_sha256.clone(),
                created_at: metadata.created_at,
                updated_at: metadata.updated_at,
                status: UploadStatus::Completed as i32,
                width: metadata.width.unwrap_or(0),
                height: metadata.height.unwrap_or(0),
                duration_ms: metadata.duration_ms.unwrap_or(0),
                thumbnail_id: metadata.thumbnail_id.clone().unwrap_or_default(),
                is_encrypted: metadata.is_encrypted,
                encryption_key_id: metadata.encryption_key_id.clone().unwrap_or_default(),
                iv: metadata.iv.clone().unwrap_or_default(),
                conversation_id: metadata.conversation_id.clone().unwrap_or_default(),
                message_id: metadata.message_id.clone().unwrap_or_default(),
                storage_path: metadata.storage_path.clone(),
            })),
        };
        yield meta_response;

        // Download file data
        let data = if length > 0 {
            storage_clone
                .download_range(&storage_path, offset, length)
                .await
                .map_err(|e| Status::internal(format!("Storage error: {}", e)))?
        } else if offset > 0 {
            storage_clone
                .download_range(&storage_path, offset, 0)
                .await
                .map_err(|e| Status::internal(format!("Storage error: {}", e)))?
        } else {
            storage_clone
                .download_file(&storage_path)
                .await
                .map_err(|e| Status::internal(format!("Storage error: {}", e)))?
        };

        // Stream chunks
        for chunk in data.chunks(chunk_size) {
            yield DownloadMediaResponse {
                content: Some(Content::Chunk(chunk.to_vec())),
            };
        }

        tracing::info!(
            media_id = %metadata.media_id,
            bytes_sent = data.len(),
            "Download complete"
        );
    };

    Ok(Response::new(Box::pin(output_stream) as BoxStream<'static, Result<DownloadMediaResponse, Status>>))
}
