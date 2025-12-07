/// Get conversations list handler
use crate::{auth_client::AuthClient, db::DatabaseClient, proto::messaging::*, proto::common::*};
use std::sync::Arc;
use tonic::{Response, Status};
use tracing::{error, info, warn};

pub async fn get_conversations(
    request: GetConversationsRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetConversationsResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("JWT_SECRET")
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
                Ok(mut conversations) => {
                    info!("Successfully fetched {} conversations via fallback", conversations.len());
                    
                    // Enrich conversations with usernames from auth-service
                    let conversations = enrich_conversations_with_usernames(conversations).await;
                    
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

/// Enrich conversations with usernames fetched from auth-service
async fn enrich_conversations_with_usernames(
    mut conversations: Vec<Conversation>,
) -> Vec<Conversation> {
    // Collect unique user IDs that need username lookup
    let user_ids: Vec<String> = conversations
        .iter()
        .filter(|c| c.username == c.user_id) // Only fetch if username equals user_id (UUID)
        .map(|c| c.user_id.clone())
        .collect();
    
    if user_ids.is_empty() {
        return conversations;
    }

    info!("Fetching usernames for {} users from auth-service", user_ids.len());
    
    // Connect to auth-service
    let auth_url = std::env::var("AUTH_SERVICE_URL")
        .unwrap_or_else(|_| "http://auth-service:50051".to_string());
    
    let mut auth_client = match AuthClient::new(&auth_url).await {
        Ok(client) => client,
        Err(e) => {
            warn!("Failed to connect to auth-service for username lookup: {}", e);
            return conversations;
        }
    };

    // Fetch usernames
    let usernames = auth_client.get_usernames(&user_ids).await;
    
    info!("Fetched {} usernames from auth-service", usernames.len());

    // Update conversations with fetched usernames
    for conv in &mut conversations {
        if let Some(username) = usernames.get(&conv.user_id) {
            conv.username = username.clone();
        }
    }

    conversations
}
