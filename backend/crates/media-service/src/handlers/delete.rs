//! Delete Handler
//!
//! Delete media files and metadata

use crate::{
    db::DatabaseClient,
    jwt,
    proto::{
        common::{error_response::ErrorCode, ErrorResponse},
        media::{DeleteMediaRequest, DeleteMediaResponse},
    },
    storage::StorageClient,
};
use std::sync::Arc;
use tonic::{Request, Response, Status};

/// Handle delete request
pub async fn handle(
    request: Request<DeleteMediaRequest>,
    db: Arc<DatabaseClient>,
    storage: Arc<StorageClient>,
    jwt_secret: &str,
) -> Result<Response<DeleteMediaResponse>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let req = request.into_inner();
    let media_id = req.media_id;

    if media_id.is_empty() {
        return Ok(Response::new(DeleteMediaResponse {
            success: false,
            error: Some(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "media_id is required".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Get metadata to check ownership and get storage path
    let metadata = match db.get_media_metadata(&media_id).await {
        Ok(Some(m)) => m,
        Ok(None) => {
            return Ok(Response::new(DeleteMediaResponse {
                success: false,
                error: Some(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "Media not found".to_string(),
                    details: Default::default(),
                }),
            }));
        }
        Err(e) => {
            tracing::error!(error = %e, "Failed to get media metadata");
            return Ok(Response::new(DeleteMediaResponse {
                success: false,
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
        return Ok(Response::new(DeleteMediaResponse {
            success: false,
            error: Some(ErrorResponse {
                code: ErrorCode::Unauthorized as i32,
                message: "Not authorized to delete this media".to_string(),
                details: Default::default(),
            }),
        }));
    }

    // Delete from storage
    if let Err(e) = storage.delete_file(&metadata.storage_path).await {
        tracing::error!(
            error = %e,
            media_id = %media_id,
            storage_path = %metadata.storage_path,
            "Failed to delete file from storage"
        );
        // Continue to delete metadata even if storage deletion fails
    }

    // Delete thumbnail if exists
    if let Some(ref thumbnail_id) = metadata.thumbnail_id {
        if let Ok(Some(thumb_meta)) = db.get_media_metadata(thumbnail_id).await {
            if let Err(e) = storage.delete_file(&thumb_meta.storage_path).await {
                tracing::warn!(
                    error = %e,
                    thumbnail_id = %thumbnail_id,
                    "Failed to delete thumbnail from storage"
                );
            }
            if let Err(e) = db.delete_media_metadata(thumbnail_id).await {
                tracing::warn!(
                    error = %e,
                    thumbnail_id = %thumbnail_id,
                    "Failed to delete thumbnail metadata"
                );
            }
        }
    }

    // Delete metadata from database
    if let Err(e) = db.delete_media_metadata(&media_id).await {
        tracing::error!(
            error = %e,
            media_id = %media_id,
            "Failed to delete media metadata"
        );
        return Ok(Response::new(DeleteMediaResponse {
            success: false,
            error: Some(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to delete metadata".to_string(),
                details: Default::default(),
            }),
        }));
    }

    tracing::info!(
        media_id = %media_id,
        user_id = %user_id,
        "Media deleted successfully"
    );

    Ok(Response::new(DeleteMediaResponse {
        success: true,
        error: None,
    }))
}
