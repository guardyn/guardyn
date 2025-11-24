/// Get conversations list handler
use crate::{db::DatabaseClient, proto::messaging::*, proto::common::*};
use std::sync::Arc;
use tonic::{Response, Status};
use tracing::{error, info};

pub async fn get_conversations(
    request: GetConversationsRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetConversationsResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (user_id, _device_id) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok((user_id, device_id)) => (user_id, device_id),
        Err(_) => {
            return Ok(Response::new(GetConversationsResponse {
                result: Some(get_conversations_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    let limit = if request.limit == 0 {
        50
    } else {
        request.limit.min(100)
    };

    info!(
        "Getting conversations for user: {}, limit: {}",
        user_id, limit
    );

    match db.get_recent_conversations(&user_id, limit as i32).await {
        Ok(conversations) => {
            info!("Successfully fetched {} conversations", conversations.len());
            Ok(Response::new(GetConversationsResponse {
                result: Some(get_conversations_response::Result::Success(
                    GetConversationsSuccess {
                        conversations,
                    },
                )),
            }))
        }
        Err(err) => {
            error!("Failed to fetch conversations: {}", err);
            Ok(Response::new(GetConversationsResponse {
                result: Some(get_conversations_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: format!("Failed to fetch conversations: {}", err),
                    details: Default::default(),
                })),
            }))
        }
    }
}
