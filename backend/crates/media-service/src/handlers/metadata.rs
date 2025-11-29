//! Metadata Handler
//!
//! Get media metadata without downloading the file

use crate::{
    db::DatabaseClient,
    jwt,
    proto::{
        common::{error_response::ErrorCode, ErrorResponse},
        media::{GetMediaMetadataRequest, GetMediaMetadataResponse, MediaMetadata},
    },
};
use std::sync::Arc;
use tonic::{Request, Response, Status};

/// Handle get metadata request
pub async fn get(
    request: Request<GetMediaMetadataRequest>,
    db: Arc<DatabaseClient>,
    jwt_secret: &str,
) -> Result<Response<GetMediaMetadataResponse>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let req = request.into_inner();
    let media_id = req.media_id;

    if media_id.is_empty() {
        return Ok(Response::new(GetMediaMetadataResponse {
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "media_id is required".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Get metadata from database
    let metadata = match db.get_media_metadata(&media_id).await {
        Ok(Some(m)) => m,
        Ok(None) => {
            return Ok(Response::new(GetMediaMetadataResponse {
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
            return Ok(Response::new(GetMediaMetadataResponse {
                metadata: None,
                error: Some(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Database error".to_string(),
                    details: Default::default(),
                }),
            }));
        }
    };

    // Check access permission (owner or conversation participant)
    if metadata.owner_user_id != user_id {
        // TODO: Check if user is in the same conversation
        return Ok(Response::new(GetMediaMetadataResponse {
            metadata: None,
            error: Some(ErrorResponse {
                code: ErrorCode::Unauthorized as i32,
                message: "Not authorized to access this media".to_string(),
                details: Default::default(),
            }),
        }));
    }

    tracing::debug!(
        media_id = %media_id,
        user_id = %user_id,
        "Metadata retrieved"
    );

    Ok(Response::new(GetMediaMetadataResponse {
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
