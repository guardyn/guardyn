/// Get user profile by user ID handler
use crate::{
    db::DatabaseClient, 
    proto::auth::*, 
    proto::common::{error_response::ErrorCode, *}
};
use tracing::{error, info, warn};

pub async fn handle_get_user_profile(
    request: GetUserProfileRequest,
    db: DatabaseClient,
) -> GetUserProfileResponse {
    let user_id = request.user_id.trim();

    // Validate user_id
    if user_id.is_empty() {
        warn!("Empty user_id in get_user_profile request");
        return GetUserProfileResponse {
            result: Some(get_user_profile_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "User ID cannot be empty".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    // Validate UUID format
    if uuid::Uuid::parse_str(user_id).is_err() {
        warn!("Invalid UUID format for user_id: {}", user_id);
        return GetUserProfileResponse {
            result: Some(get_user_profile_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Invalid user ID format".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    info!("Getting user profile for user_id: {}", user_id);

    // Lookup user by ID
    match db.get_user_by_id(user_id).await {
        Ok(Some(user)) => {
            info!("Found user profile for user_id: {}", user_id);
            GetUserProfileResponse {
                result: Some(get_user_profile_response::Result::Success(UserProfile {
                    user_id: user.user_id,
                    username: user.username,
                    email: user.email.unwrap_or_default(),
                    created_at: Some(Timestamp {
                        seconds: user.created_at,
                        nanos: 0,
                    }),
                    last_seen: Some(Timestamp {
                        seconds: user.last_seen,
                        nanos: 0,
                    }),
                })),
            }
        }
        Ok(None) => {
            warn!("User not found for user_id: {}", user_id);
            GetUserProfileResponse {
                result: Some(get_user_profile_response::Result::Error(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "User not found".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            }
        }
        Err(e) => {
            error!("Failed to get user profile for user_id {}: {}", user_id, e);
            GetUserProfileResponse {
                result: Some(get_user_profile_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to get user profile: {}", e),
                    details: std::collections::HashMap::new(),
                })),
            }
        }
    }
}
