/// Handler for deleting messages
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    delete_message_response, DeleteMessageRequest, DeleteMessageResponse, DeleteMessageSuccess,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn delete_message(
    request: DeleteMessageRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<DeleteMessageResponse>, Status> {
    // Validate JWT token
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    if crate::jwt::validate_and_extract(&request.access_token, &jwt_secret).is_err() {
        return Ok(Response::new(DeleteMessageResponse {
            result: Some(delete_message_response::Result::Error(ErrorResponse {
                code: 16, // UNAUTHENTICATED
                message: "Invalid or expired access token".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate message ID
    if request.message_id.is_empty() {
        return Ok(Response::new(DeleteMessageResponse {
            result: Some(delete_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Message ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate conversation ID
    if request.conversation_id.is_empty() {
        return Ok(Response::new(DeleteMessageResponse {
            result: Some(delete_message_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Conversation ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Mark message as deleted in ScyllaDB
    if let Err(e) = db
        .delete_message(&request.conversation_id, &request.message_id)
        .await
    {
        tracing::error!("Failed to delete message: {}", e);
        return Ok(Response::new(DeleteMessageResponse {
            result: Some(delete_message_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to delete message".to_string(),
                details: Default::default(),
            })),
        }));
    }

    let timestamp = chrono::Utc::now().timestamp();

    Ok(Response::new(DeleteMessageResponse {
        result: Some(delete_message_response::Result::Success(
            DeleteMessageSuccess {
                deleted: true,
                message_id: request.message_id,
                timestamp: Some(Timestamp {
                    seconds: timestamp,
                    nanos: 0,
                }),
            },
        )),
    }))
}
