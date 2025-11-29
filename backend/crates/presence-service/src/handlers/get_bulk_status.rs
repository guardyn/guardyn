/// Get Bulk Status Handler
///
/// Gets multiple users' presence statuses in a single request

use crate::db::DatabaseClient;
use crate::jwt;
use crate::proto::common::{error_response::ErrorCode, ErrorResponse, Timestamp};
use crate::proto::presence::{
    get_bulk_status_response::Result as GetBulkStatusResult, GetBulkStatusRequest,
    GetBulkStatusResponse, GetBulkStatusSuccess, UserPresence,
};
use std::sync::Arc;
use tonic::{Response, Status};

const MAX_BULK_USERS: usize = 100;

pub async fn handle_get_bulk_status(
    request: GetBulkStatusRequest,
    db: Arc<DatabaseClient>,
    jwt_secret: &str,
) -> Result<Response<GetBulkStatusResponse>, Status> {
    // Validate JWT token
    if let Err(e) = jwt::validate_token(&request.access_token, jwt_secret) {
        tracing::warn!("Token validation failed: {}", e);
        return Ok(Response::new(GetBulkStatusResponse {
            result: Some(GetBulkStatusResult::Error(ErrorResponse {
                code: ErrorCode::Unauthorized as i32,
                message: "Invalid or expired token".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate request
    if request.user_ids.is_empty() {
        return Ok(Response::new(GetBulkStatusResponse {
            result: Some(GetBulkStatusResult::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "No user IDs provided".to_string(),
                details: Default::default(),
            })),
        }));
    }

    if request.user_ids.len() > MAX_BULK_USERS {
        return Ok(Response::new(GetBulkStatusResponse {
            result: Some(GetBulkStatusResult::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: format!("Too many user IDs (max {})", MAX_BULK_USERS),
                details: Default::default(),
            })),
        }));
    }

    // Get presences from TiKV
    let presences = match db.get_bulk_presence(&request.user_ids).await {
        Ok(p) => p,
        Err(e) => {
            tracing::error!(error = %e, "Failed to get bulk presence from TiKV");
            return Ok(Response::new(GetBulkStatusResponse {
                result: Some(GetBulkStatusResult::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to get user statuses".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Track which user IDs we found
    let mut found_ids: std::collections::HashSet<String> = std::collections::HashSet::new();
    
    // Convert to proto UserPresence
    let mut result_presences = Vec::with_capacity(request.user_ids.len());

    // First, add presences we found
    for presence in presences {
        found_ids.insert(presence.user_id.clone());
        
        // Handle INVISIBLE status - appear offline to others
        let (status, custom_status) = if presence.status == 4 {
            (0, String::new())
        } else {
            (presence.status, presence.custom_status_text.clone())
        };

        result_presences.push(UserPresence {
            user_id: presence.user_id.clone(),
            status,
            custom_status_text: custom_status,
            last_seen: Some(Timestamp {
                seconds: presence.last_seen / 1000,
                nanos: ((presence.last_seen % 1000) * 1_000_000) as i32,
            }),
        });
    }

    // For users not found, add them as offline
    for user_id in &request.user_ids {
        if !found_ids.contains(user_id) {
            result_presences.push(UserPresence {
                user_id: user_id.clone(),
                status: 0, // OFFLINE
                custom_status_text: String::new(),
                last_seen: None,
            });
        }
    }

    tracing::debug!(
        requested = request.user_ids.len(),
        found = result_presences.len(),
        "Got bulk user statuses"
    );

    Ok(Response::new(GetBulkStatusResponse {
        result: Some(GetBulkStatusResult::Success(GetBulkStatusSuccess {
            presences: result_presences,
        })),
    }))
}
