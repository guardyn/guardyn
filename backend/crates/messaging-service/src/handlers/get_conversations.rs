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

    let (user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok((user_id, device_id, username)) => (user_id, device_id, username),
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

    // Try new optimized conversations table first
    match db.get_user_conversations(&user_id, limit as i32).await {
        Ok(conversations) if !conversations.is_empty() => {
            info!("Successfully fetched {} conversations from conversations table", conversations.len());
            Ok(Response::new(GetConversationsResponse {
                result: Some(get_conversations_response::Result::Success(
                    GetConversationsSuccess {
                        conversations,
                    },
                )),
            }))
        }
        Ok(_) => {
            // No conversations in new table, fall back to old method for backward compatibility
            info!("No conversations in optimized table, falling back to messages scan");
            match db.get_recent_conversations(&user_id, limit as i32).await {
                Ok(conversations) => {
                    info!("Successfully fetched {} conversations via fallback", conversations.len());
                    Ok(Response::new(GetConversationsResponse {
                        result: Some(get_conversations_response::Result::Success(
                            GetConversationsSuccess {
                                conversations,
                            },
                        )),
                    }))
                }
                Err(err) => {
                    error!("Failed to fetch conversations (fallback): {}", err);
                    // Return empty list instead of error for new users
                    Ok(Response::new(GetConversationsResponse {
                        result: Some(get_conversations_response::Result::Success(
                            GetConversationsSuccess {
                                conversations: vec![],
                            },
                        )),
                    }))
                }
            }
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
