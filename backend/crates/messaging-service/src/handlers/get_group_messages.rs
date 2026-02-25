/// Handler for retrieving group message history
use crate::db::DatabaseClient;
use crate::proto::common::{ErrorResponse, PaginationResponse};
use crate::proto::messaging::{
    get_group_messages_response, GetGroupMessagesRequest, GetGroupMessagesResponse,
    GetGroupMessagesSuccess, GroupMessage,
};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_group_messages(
    request: GetGroupMessagesRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetGroupMessagesResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = crate::config::get_jwt_secret();

    let (requester_user_id, _device_id, _username) =
        match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
            Ok(ids) => ids,
            Err(_) => {
                return Ok(Response::new(GetGroupMessagesResponse {
                    result: Some(get_group_messages_response::Result::Error(ErrorResponse {
                        code: 16, // UNAUTHENTICATED
                        message: "Invalid or expired access token".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        };

    // Validate group ID
    if request.group_id.is_empty() {
        return Ok(Response::new(GetGroupMessagesResponse {
            result: Some(get_group_messages_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Group ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Verify group exists and requester is a member
    match db.get_group(&request.group_id).await {
        Ok(Some(_group)) => {
            // Group exists, continue
        }
        Ok(None) => {
            return Ok(Response::new(GetGroupMessagesResponse {
                result: Some(get_group_messages_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group: {}", e);
            return Ok(Response::new(GetGroupMessagesResponse {
                result: Some(get_group_messages_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to verify group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    }

    // Verify requester is a member of the group
    let members = match db.get_group_members(&request.group_id).await {
        Ok(members) => members,
        Err(e) => {
            tracing::error!("Failed to fetch group members: {}", e);
            return Ok(Response::new(GetGroupMessagesResponse {
                result: Some(get_group_messages_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to verify membership".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Check if requester is in the members list
    let is_member = members.iter().any(|m| m.user_id == requester_user_id);
    if !is_member {
        tracing::warn!(
            "User {} attempted to access group {} messages without membership",
            requester_user_id,
            request.group_id
        );
        return Ok(Response::new(GetGroupMessagesResponse {
            result: Some(get_group_messages_response::Result::Error(ErrorResponse {
                code: 7, // PERMISSION_DENIED
                message: "Not a member of this group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    tracing::debug!(
        "User {} fetching messages for group {}",
        requester_user_id,
        request.group_id
    );

    // Extract pagination parameters from request
    // Priority: PaginationRequest > limit field
    let (page, page_size) = if let Some(ref pagination_req) = request.pagination {
        let page = pagination_req.page; // 0-indexed
        let size = if pagination_req.page_size > 0 && pagination_req.page_size <= 100 {
            pagination_req.page_size
        } else {
            50
        };
        (page, size)
    } else {
        let size = if request.limit > 0 && request.limit <= 100 {
            request.limit as u32
        } else if request.limit > 100 {
            100
        } else {
            50
        };
        (0, size) // Default to first page
    };

    let offset = page * page_size;
    let limit = page_size as i32;

    // Fetch more messages than needed to support offset + has_more check
    let fetch_limit = (offset + page_size + 1) as i32;

    // Fetch group messages from ScyllaDB
    let stored_messages = match db.get_group_messages(&request.group_id, fetch_limit).await {
        Ok(msgs) => msgs,
        Err(e) => {
            tracing::error!("Failed to fetch group messages: {}", e);
            return Ok(Response::new(GetGroupMessagesResponse {
                result: Some(get_group_messages_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch messages".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Apply offset and limit for pagination
    let offset_usize = offset as usize;
    let limit_usize = limit as usize;

    // Skip to the requested offset and take limit + 1 to check for more
    let page_messages: Vec<_> = stored_messages
        .into_iter()
        .skip(offset_usize)
        .take(limit_usize + 1)
        .collect();

    // Check if there are more messages after this page
    let has_more = page_messages.len() > limit_usize;

    // Convert to protobuf format (trim to requested limit)
    let messages: Vec<GroupMessage> = page_messages
        .into_iter()
        .take(limit_usize)
        .map(|msg| {
            // Extract message_type from metadata (default to 0 if not found)
            let message_type = msg
                .metadata
                .get("message_type")
                .and_then(|s| s.parse::<i32>().ok())
                .unwrap_or(0);

            // Extract sender_username from metadata or use sender_user_id as fallback
            let sender_username = msg
                .metadata
                .get("sender_username")
                .cloned()
                .unwrap_or_else(|| msg.sender_user_id.clone());

            GroupMessage {
                message_id: msg.message_id,
                group_id: msg.group_id,
                sender_user_id: msg.sender_user_id,
                sender_device_id: msg.sender_device_id,
                sender_username,
                encrypted_content: msg.encrypted_content,
                message_type,
                client_message_id: String::new(), // Not stored in current schema
                server_timestamp: Some(crate::proto::common::Timestamp {
                    seconds: msg.sent_at / 1000,
                    nanos: ((msg.sent_at % 1000) * 1_000_000) as i32,
                }),
                client_timestamp: Some(crate::proto::common::Timestamp {
                    seconds: msg.sent_at / 1000, // Use sent_at for both (no separate client timestamp)
                    nanos: 0,
                }),
                media_id: String::new(), // Not stored in current schema
                is_deleted: false,       // New schema doesn't support soft delete
                // Phase 2 fields (not yet stored in DB)
                thread_reference: None,
                forward_info: None,
                edit_version: 0,
                last_edited_at: None,
                voice_metadata: None,
                reaction_summaries: Vec::new(),
            }
        })
        .collect();

    tracing::info!(
        "Retrieved {} group messages for group {} (requested by {})",
        messages.len(),
        request.group_id,
        requester_user_id
    );

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
        estimated_total.div_ceil(page_size)
    };

    let pagination = Some(PaginationResponse {
        total_items: estimated_total,
        total_pages,
        current_page: page,
        page_size,
    });

    Ok(Response::new(GetGroupMessagesResponse {
        result: Some(get_group_messages_response::Result::Success(
            GetGroupMessagesSuccess {
                messages,
                pagination,
            },
        )),
    }))
}
