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
    let new_avatar = if request.avatar_media_id.is_empty() {
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
