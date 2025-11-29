//! List Media Handler
//!
//! List media files for a user or conversation

use crate::{
    db::DatabaseClient,
    jwt,
    proto::{
        common::{error_response::ErrorCode, ErrorResponse},
        media::{ListMediaRequest, ListMediaResponse, MediaMetadata},
    },
};
use std::sync::Arc;
use tonic::{Request, Response, Status};

/// Handle list media request
pub async fn handle(
    request: Request<ListMediaRequest>,
    db: Arc<DatabaseClient>,
    jwt_secret: &str,
) -> Result<Response<ListMediaResponse>, Status> {
    // Validate JWT token
    let claims = jwt::validate_request(&request, jwt_secret)?;
    let user_id = claims.sub;

    let req = request.into_inner();
    
    // Determine limit
    let limit = if req.limit > 0 && req.limit <= 100 {
        req.limit as usize
    } else {
        50
    };

    let cursor = if req.cursor.is_empty() {
        None
    } else {
        Some(req.cursor.as_str())
    };

    // Determine filter
    let (records, next_cursor) = if !req.conversation_id.is_empty() {
        // Filter by conversation
        // TODO: Verify user is part of the conversation
        db.list_media_by_conversation(&req.conversation_id, limit, cursor)
            .await
            .map_err(|e| Status::internal(format!("Database error: {}", e)))?
    } else if !req.user_id.is_empty() {
        // Filter by specific user (only allow listing own media)
        if req.user_id != user_id {
            return Ok(Response::new(ListMediaResponse {
                items: vec![],
                next_cursor: String::new(),
                total_count: 0,
                error: Some(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Not authorized to list other user's media".to_string(),
                    details: Default::default(),
                }),
            }));
        }
        db.list_media_by_user(&req.user_id, limit, cursor)
            .await
            .map_err(|e| Status::internal(format!("Database error: {}", e)))?
    } else {
        // Default: list current user's media
        db.list_media_by_user(&user_id, limit, cursor)
            .await
            .map_err(|e| Status::internal(format!("Database error: {}", e)))?
    };

    // Apply media type filter if specified
    let items: Vec<MediaMetadata> = records
        .into_iter()
        .filter(|r| {
            if req.media_types.is_empty() {
                true
            } else {
                req.media_types.iter().any(|t| *t == r.media_type)
            }
        })
        .map(|r| MediaMetadata {
            media_id: r.media_id,
            owner_user_id: r.owner_user_id,
            filename: r.filename,
            media_type: r.media_type,
            mime_type: r.mime_type,
            size_bytes: r.size_bytes,
            checksum_sha256: r.checksum_sha256,
            created_at: r.created_at,
            updated_at: r.updated_at,
            status: r.status,
            width: r.width.unwrap_or(0),
            height: r.height.unwrap_or(0),
            duration_ms: r.duration_ms.unwrap_or(0),
            thumbnail_id: r.thumbnail_id.unwrap_or_default(),
            is_encrypted: r.is_encrypted,
            encryption_key_id: r.encryption_key_id.unwrap_or_default(),
            iv: r.iv.unwrap_or_default(),
            conversation_id: r.conversation_id.unwrap_or_default(),
            message_id: r.message_id.unwrap_or_default(),
            storage_path: r.storage_path,
        })
        .collect();

    let total_count = items.len() as i32;

    tracing::debug!(
        user_id = %user_id,
        count = total_count,
        has_more = next_cursor.is_some(),
        "Listed media"
    );

    Ok(Response::new(ListMediaResponse {
        items,
        next_cursor: next_cursor.unwrap_or_default(),
        total_count,
        error: None,
    }))
}
