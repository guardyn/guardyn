/// Handler for retrieving message history
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_messages_response, GetMessagesRequest, GetMessagesResponse, GetMessagesSuccess, Message,
};
use crate::proto::common::{ErrorResponse, PaginationResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_messages(
    request: GetMessagesRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetMessagesResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("JWT_SECRET")
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

    // Set default limit (fetch one extra to check for has_more)
    let limit = if request.limit > 0 && request.limit <= 100 {
        request.limit
    } else {
        50
    };

    // Fetch messages from ScyllaDB (request limit + 1 to check for more)
    let stored_messages = match db.get_messages(&request.conversation_id, limit + 1).await {
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

    // Filter out deleted messages and convert to proto
    let filtered_messages: Vec<_> = stored_messages
        .into_iter()
        .filter(|m| !m.is_deleted)
        .collect();

    // Check if there are more messages (we fetched limit + 1)
    let has_more = filtered_messages.len() > limit as usize;

    // Trim to the requested limit
    let messages: Vec<Message> = filtered_messages
        .into_iter()
        .take(limit as usize)
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
            x3dh_prekey: m.x3dh_prekey.unwrap_or_default(), // Return stored X3DH prekey
            // Phase 2 fields (not yet stored in DB)
            thread_reference: None,
            forward_info: None,
            edit_version: 0,
            last_edited_at: None,
            voice_metadata: None,
            reaction_summaries: Vec::new(),
        })
        .collect();

    // Build pagination response
    let page_size = limit as u32;
    let current_page = 1u32; // Currently we only support fetching latest messages
    let total_items = messages.len() as u32; // Approximate - full count would require separate query

    let pagination = Some(PaginationResponse {
        total_items,
        total_pages: 1,
        current_page,
        page_size,
    });

    Ok(Response::new(GetMessagesResponse {
        result: Some(get_messages_response::Result::Success(
            GetMessagesSuccess {
                messages,
                pagination,
                has_more,
            },
        )),
    }))
}
