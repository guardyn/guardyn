/// Handler for retrieving message history
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_messages_response, GetMessagesRequest, GetMessagesResponse, GetMessagesSuccess, Message,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_messages(
    request: GetMessagesRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetMessagesResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (_user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(GetMessagesResponse {
                result: Some(get_messages_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate conversation ID
    if request.conversation_id.is_empty() {
        return Ok(Response::new(GetMessagesResponse {
            result: Some(get_messages_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Conversation ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Set default limit
    let limit = if request.limit > 0 && request.limit <= 100 {
        request.limit
    } else {
        50
    };

    // Fetch messages from ScyllaDB
    let stored_messages = match db.get_messages(&request.conversation_id, limit).await {
        Ok(msgs) => msgs,
        Err(e) => {
            tracing::error!("Failed to fetch messages: {}", e);
            return Ok(Response::new(GetMessagesResponse {
                result: Some(get_messages_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch messages".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Convert to proto messages
    let messages: Vec<Message> = stored_messages
        .into_iter()
        .filter(|m| !m.is_deleted) // Filter out deleted messages
        .map(|m| Message {
            message_id: m.message_id,
            sender_user_id: m.sender_user_id,
            sender_device_id: m.sender_device_id,
            recipient_user_id: m.recipient_user_id,
            recipient_device_id: m.recipient_device_id.unwrap_or_default(),
            encrypted_content: m.encrypted_content,
            message_type: m.message_type,
            client_message_id: String::new(), // Not stored in current schema
            server_timestamp: Some(Timestamp {
                seconds: m.server_timestamp,
                nanos: 0,
            }),
            client_timestamp: Some(Timestamp {
                seconds: m.client_timestamp,
                nanos: 0,
            }),
            delivery_status: m.delivery_status,
            is_deleted: m.is_deleted,
            media_id: String::new(), // TODO: Implement media references
        })
        .collect();

    Ok(Response::new(GetMessagesResponse {
        result: Some(get_messages_response::Result::Success(
            GetMessagesSuccess {
                messages,
                pagination: None, // TODO: Implement pagination
                has_more: false, // TODO: Implement pagination
            },
        )),
    }))
}
