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

    // Extract pagination parameters from request
    // Priority: PaginationRequest > limit field
    let (page, page_size) = if let Some(ref pagination_req) = request.pagination {
        let page = pagination_req.page.max(0); // 0-indexed
        let size = if pagination_req.page_size > 0 && pagination_req.page_size <= 100 {
            pagination_req.page_size
        } else {
            50
        };
        (page, size)
    } else {
        let size = if request.limit > 0 && request.limit <= 100 {
            request.limit as u32
        } else {
            50
        };
        (0, size) // Default to first page
    };

    let offset = page * page_size;
    let limit = page_size as i32;

    // Fetch more messages than needed to calculate has_more and support offset
    // We fetch offset + limit + 1 to check for more pages
    let fetch_limit = (offset + page_size + 1) as i32;
    let stored_messages = match db.get_messages(&request.conversation_id, fetch_limit).await {
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

    // Filter out deleted messages
    let filtered_messages: Vec<_> = stored_messages
        .into_iter()
        .filter(|m| !m.is_deleted)
        .collect();

    // Apply offset and limit for pagination
    let offset_usize = offset as usize;
    let limit_usize = limit as usize;

    // Skip to the requested offset and take limit + 1 to check for more
    let page_messages: Vec<_> = filtered_messages
        .into_iter()
        .skip(offset_usize)
        .take(limit_usize + 1)
        .collect();

    // Check if there are more messages after this page
    let has_more = page_messages.len() > limit_usize;

    // Trim to the requested limit
    let messages: Vec<Message> = page_messages
        .into_iter()
        .take(limit_usize)
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
    // Note: Getting exact total_items requires a separate COUNT query
    // For now, we estimate based on what we fetched
    let estimated_total = if has_more {
        // If there are more pages, we have at least offset + fetched + 1 items
        offset + page_size + 1
    } else {
        // If this is the last page, total is offset + messages on this page
        offset + messages.len() as u32
    };
    let total_pages = if estimated_total == 0 {
        0
    } else {
        (estimated_total + page_size - 1) / page_size
    };

    let pagination = Some(PaginationResponse {
        total_items: estimated_total,
        total_pages,
        current_page: page,
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
