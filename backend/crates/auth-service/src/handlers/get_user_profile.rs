/// Get user profile by user ID handler
use crate::{
    db::DatabaseClient,
    proto::auth::*,
    proto::common::{error_response::ErrorCode, *},
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
                    avatar_media_id: user.avatar_media_id.unwrap_or_default(),
                    display_name: user.display_name.unwrap_or_default(),
                    bio: user.bio.unwrap_or_default(),
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

/// Validate user_id format
/// Returns Ok(trimmed_user_id) if valid UUID, Err(error_message) otherwise
#[allow(dead_code)]
pub fn validate_user_id(user_id: &str) -> Result<&str, String> {
    let trimmed = user_id.trim();

    if trimmed.is_empty() {
        return Err("User ID cannot be empty".to_string());
    }

    if uuid::Uuid::parse_str(trimmed).is_err() {
        return Err("Invalid user ID format".to_string());
    }

    Ok(trimmed)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_user_id_empty() {
        let result = validate_user_id("");
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "User ID cannot be empty");
    }

    #[test]
    fn test_validate_user_id_whitespace_only() {
        let result = validate_user_id("   ");
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "User ID cannot be empty");
    }

    #[test]
    fn test_validate_user_id_invalid_format() {
        let result = validate_user_id("not-a-uuid");
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Invalid user ID format");
    }

    #[test]
    fn test_validate_user_id_valid_v4() {
        let uuid_str = "550e8400-e29b-41d4-a716-446655440000";
        let result = validate_user_id(uuid_str);
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), uuid_str);
    }

    #[test]
    fn test_validate_user_id_with_whitespace() {
        let uuid_str = "  550e8400-e29b-41d4-a716-446655440000  ";
        let result = validate_user_id(uuid_str);
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "550e8400-e29b-41d4-a716-446655440000");
    }

    #[test]
    fn test_validate_user_id_uppercase() {
        let uuid_str = "550E8400-E29B-41D4-A716-446655440000";
        let result = validate_user_id(uuid_str);
        assert!(result.is_ok());
    }

    #[test]
    fn test_validate_user_id_partial() {
        let result = validate_user_id("550e8400-e29b-41d4");
        assert!(result.is_err());
    }
}
