//! UpdateProfile handler - updates user avatar, display name, and bio

use crate::db::DatabaseClient;
use crate::proto::auth::{
    update_profile_response, UpdateProfileRequest, UpdateProfileResponse, UserProfile,
};
use crate::proto::common::{error_response::ErrorCode, ErrorResponse, Timestamp};
use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
use serde::Deserialize;
use std::sync::Arc;
use tracing::{error, info, warn};

/// Claims structure for JWT token
#[derive(Debug, Deserialize)]
struct Claims {
    sub: String,
    #[allow(dead_code)]
    exp: i64,
}

/// Update user profile (avatar, display name, bio)
pub async fn update_profile(
    request: UpdateProfileRequest,
    db: Arc<DatabaseClient>,
    jwt_secret: &str,
) -> UpdateProfileResponse {
    // Validate access token
    let token = &request.access_token;
    if token.is_empty() {
        return UpdateProfileResponse {
            result: Some(update_profile_response::Result::Error(ErrorResponse {
                code: ErrorCode::Unauthorized as i32,
                message: "Access token is required".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    // Decode and validate JWT
    let user_id = match decode::<Claims>(
        token,
        &DecodingKey::from_secret(jwt_secret.as_bytes()),
        &Validation::new(Algorithm::HS256),
    ) {
        Ok(token_data) => token_data.claims.sub,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return UpdateProfileResponse {
                result: Some(update_profile_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired access token".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    info!("Updating profile for user_id: {}", user_id);

    // Get current user profile
    let user = match db.get_user_by_id(&user_id).await {
        Ok(Some(u)) => u,
        Ok(None) => {
            warn!("User not found for user_id: {}", user_id);
            return UpdateProfileResponse {
                result: Some(update_profile_response::Result::Error(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "User not found".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
        Err(e) => {
            error!("Database error getting user: {}", e);
            return UpdateProfileResponse {
                result: Some(update_profile_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Database error".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    // Update fields if provided (empty string means no change)
    // clear_avatar = true means explicitly remove avatar
    let new_avatar = if request.clear_avatar {
        None
    } else if request.avatar_media_id.is_empty() {
        user.avatar_media_id.clone()
    } else {
        Some(request.avatar_media_id.clone())
    };

    let new_display_name = if request.display_name.is_empty() {
        user.display_name.clone()
    } else {
        Some(request.display_name.clone())
    };

    let new_bio = if request.bio.is_empty() {
        user.bio.clone()
    } else {
        Some(request.bio.clone())
    };

    // Update profile in database
    if let Err(e) = db
        .update_user_profile(
            &user_id,
            new_avatar.clone(),
            new_display_name.clone(),
            new_bio.clone(),
        )
        .await
    {
        error!("Failed to update user profile: {}", e);
        return UpdateProfileResponse {
            result: Some(update_profile_response::Result::Error(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to update profile".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    info!("Successfully updated profile for user_id: {}", user_id);

    // Return updated profile
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    UpdateProfileResponse {
        result: Some(update_profile_response::Result::Profile(UserProfile {
            user_id: user.user_id,
            username: user.username,
            email: user.email.unwrap_or_default(),
            created_at: Some(Timestamp {
                seconds: user.created_at,
                nanos: 0,
            }),
            last_seen: Some(Timestamp {
                seconds: now,
                nanos: 0,
            }),
            avatar_media_id: new_avatar.unwrap_or_default(),
            display_name: new_display_name.unwrap_or_default(),
            bio: new_bio.unwrap_or_default(),
        })),
    }
}

/// Validate JWT token and extract user_id
/// Returns Ok(user_id) on success, Err(error_message) on failure
pub fn validate_jwt_token(token: &str, jwt_secret: &str) -> Result<String, String> {
    if token.is_empty() {
        return Err("Access token is required".to_string());
    }

    match decode::<Claims>(
        token,
        &DecodingKey::from_secret(jwt_secret.as_bytes()),
        &Validation::new(Algorithm::HS256),
    ) {
        Ok(token_data) => Ok(token_data.claims.sub),
        Err(e) => Err(format!("Invalid or expired access token: {}", e)),
    }
}

/// Merge profile fields - returns new value if provided, otherwise keeps existing
pub fn merge_profile_field(new_value: &str, existing: Option<String>) -> Option<String> {
    if new_value.is_empty() {
        existing
    } else {
        Some(new_value.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use jsonwebtoken::{encode, Header, EncodingKey};
    use serde::Serialize;

    #[derive(Debug, Serialize)]
    struct TestClaims {
        sub: String,
        exp: i64,
    }

    fn create_test_token(user_id: &str, secret: &str, exp_seconds: i64) -> String {
        let claims = TestClaims {
            sub: user_id.to_string(),
            exp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs() as i64 + exp_seconds,
        };
        encode(&Header::default(), &claims, &EncodingKey::from_secret(secret.as_bytes())).unwrap()
    }

    #[test]
    fn test_validate_jwt_token_empty() {
        let result = validate_jwt_token("", "test_secret");
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Access token is required");
    }

    #[test]
    fn test_validate_jwt_token_invalid() {
        let result = validate_jwt_token("invalid_token", "test_secret");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Invalid or expired access token"));
    }

    #[test]
    fn test_validate_jwt_token_wrong_secret() {
        let token = create_test_token("user123", "correct_secret", 3600);
        let result = validate_jwt_token(&token, "wrong_secret");
        assert!(result.is_err());
    }

    #[test]
    fn test_validate_jwt_token_expired() {
        let token = create_test_token("user123", "test_secret", -3600); // expired 1 hour ago
        let result = validate_jwt_token(&token, "test_secret");
        assert!(result.is_err());
    }

    #[test]
    fn test_validate_jwt_token_success() {
        let secret = "test_secret_key_123";
        let user_id = "user-uuid-12345";
        let token = create_test_token(user_id, secret, 3600);
        
        let result = validate_jwt_token(&token, secret);
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), user_id);
    }

    #[test]
    fn test_merge_profile_field_new_value() {
        let result = merge_profile_field("new_avatar.jpg", Some("old_avatar.jpg".to_string()));
        assert_eq!(result, Some("new_avatar.jpg".to_string()));
    }

    #[test]
    fn test_merge_profile_field_empty_keeps_existing() {
        let result = merge_profile_field("", Some("old_avatar.jpg".to_string()));
        assert_eq!(result, Some("old_avatar.jpg".to_string()));
    }

    #[test]
    fn test_merge_profile_field_empty_keeps_none() {
        let result = merge_profile_field("", None);
        assert_eq!(result, None);
    }

    #[test]
    fn test_merge_profile_field_new_value_replaces_none() {
        let result = merge_profile_field("new_avatar.jpg", None);
        assert_eq!(result, Some("new_avatar.jpg".to_string()));
    }

    #[test]
    fn test_merge_display_name() {
        // Test display name with unicode characters
        let result = merge_profile_field("Иван Иванов", None);
        assert_eq!(result, Some("Иван Иванов".to_string()));
        
        let result = merge_profile_field("John Doe 日本語", Some("Old Name".to_string()));
        assert_eq!(result, Some("John Doe 日本語".to_string()));
    }

    #[test]
    fn test_merge_bio_long_text() {
        let long_bio = "A".repeat(500);
        let result = merge_profile_field(&long_bio, None);
        assert_eq!(result, Some(long_bio));
    }
}
