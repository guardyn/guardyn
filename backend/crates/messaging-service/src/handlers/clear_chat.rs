/// Handler for clearing all messages in a conversation
use crate::db::DatabaseClient;
use crate::proto::common::{ErrorResponse, Timestamp};
use crate::proto::messaging::{
    clear_chat_response, ClearChatRequest, ClearChatResponse, ClearChatSuccess,
};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn clear_chat(
    request: ClearChatRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<ClearChatResponse>, Status> {
    tracing::info!(
        conversation_id = %request.conversation_id,
        token_length = request.access_token.len(),
        "ClearChat handler invoked"
    );

    // Validate JWT token
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    if crate::jwt::validate_and_extract(&request.access_token, &jwt_secret).is_err() {
        tracing::warn!(
            conversation_id = %request.conversation_id,
            "ClearChat: JWT validation failed"
        );
        return Ok(Response::new(ClearChatResponse {
            result: Some(clear_chat_response::Result::Error(ErrorResponse {
                code: 16, // UNAUTHENTICATED
                message: "Invalid or expired access token".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate conversation ID
    if request.conversation_id.is_empty() {
        return Ok(Response::new(ClearChatResponse {
            result: Some(clear_chat_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Conversation ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Clear all messages in the conversation
    match db.clear_chat(&request.conversation_id).await {
        Ok(deleted_count) => {
            tracing::info!(
                conversation_id = %request.conversation_id,
                deleted_count = deleted_count,
                "Cleared chat messages"
            );

            let timestamp = chrono::Utc::now().timestamp();

            Ok(Response::new(ClearChatResponse {
                result: Some(clear_chat_response::Result::Success(ClearChatSuccess {
                    deleted_count: deleted_count as u32,
                    timestamp: Some(Timestamp {
                        seconds: timestamp,
                        nanos: 0,
                    }),
                })),
            }))
        }
        Err(e) => {
            tracing::error!("Failed to clear chat: {}", e);
            Ok(Response::new(ClearChatResponse {
                result: Some(clear_chat_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to clear chat".to_string(),
                    details: Default::default(),
                })),
            }))
        }
    }
}
