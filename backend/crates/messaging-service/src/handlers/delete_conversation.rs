/// Handler for deleting conversations
use crate::db::DatabaseClient;
use crate::proto::common::ErrorResponse;
use crate::proto::messaging::{
    delete_conversation_response, DeleteConversationRequest, DeleteConversationResponse,
    DeleteConversationSuccess,
};
use std::sync::Arc;
use tonic::{Request, Response, Status};

/// Delete a conversation (removes from user's list, keeps for other party)
pub async fn delete_conversation(
    db: Arc<DatabaseClient>,
    request: Request<DeleteConversationRequest>,
) -> Result<Response<DeleteConversationResponse>, Status> {
    let req = request.into_inner();

    tracing::info!(
        conversation_id = %req.conversation_id,
        token_length = req.access_token.len(),
        "DeleteConversation handler invoked"
    );

    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let user_id = match crate::jwt::validate_and_extract(&req.access_token, &jwt_secret) {
        Ok((uid, _device_id, _username)) => uid,
        Err(_) => {
            tracing::warn!("DeleteConversation: JWT validation failed");
            return Ok(Response::new(DeleteConversationResponse {
                result: Some(delete_conversation_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate conversation_id
    if req.conversation_id.is_empty() {
        return Ok(Response::new(DeleteConversationResponse {
            result: Some(delete_conversation_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Conversation ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Delete the conversation for this user only
    match db.delete_conversation(&user_id, &req.conversation_id).await {
        Ok(()) => {
            tracing::info!(
                user_id = %user_id,
                conversation_id = %req.conversation_id,
                "Conversation deleted successfully"
            );

            Ok(Response::new(DeleteConversationResponse {
                result: Some(delete_conversation_response::Result::Success(
                    DeleteConversationSuccess {
                        conversation_id: req.conversation_id,
                    },
                )),
            }))
        }
        Err(e) => {
            tracing::error!("Failed to delete conversation: {}", e);
            Ok(Response::new(DeleteConversationResponse {
                result: Some(delete_conversation_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to delete conversation".to_string(),
                    details: Default::default(),
                })),
            }))
        }
    }
}
