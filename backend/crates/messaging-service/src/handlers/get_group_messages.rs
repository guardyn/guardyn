/// Handler for retrieving group message history
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_group_messages_response, GetGroupMessagesRequest, GetGroupMessagesResponse,
    GetGroupMessagesSuccess, GroupMessage,
};
use crate::proto::common::{ErrorResponse, PaginationResponse};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_group_messages(
    request: GetGroupMessagesRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetGroupMessagesResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (requester_user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
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

    // Determine limit (default 50, max 100) - fetch one extra for has_more check
    let limit = if request.limit > 0 && request.limit <= 100 {
        request.limit
    } else if request.limit > 100 {
        100
    } else {
        50
    };

    // Fetch group messages from ScyllaDB (request limit + 1 for has_more)
    let stored_messages = match db.get_group_messages(&request.group_id, limit + 1).await {
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

    // Check if there are more messages (we fetched limit + 1)
    let has_more = stored_messages.len() > limit as usize;

    // Convert to protobuf format (trim to requested limit)
    let messages: Vec<GroupMessage> = stored_messages
        .into_iter()
        .take(limit as usize)
        .map(|msg| {
            // Extract message_type from metadata (default to 0 if not found)
            let message_type = msg.metadata
                .get("message_type")
                .and_then(|s| s.parse::<i32>().ok())
                .unwrap_or(0);
            
            // Extract sender_username from metadata or use sender_user_id as fallback
            let sender_username = msg.metadata
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
                is_deleted: false, // New schema doesn't support soft delete
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
    let pagination = Some(PaginationResponse {
        total_items: messages.len() as u32,
        total_pages: if has_more { 2 } else { 1 }, // Approximate
        current_page: 1,
        page_size: limit as u32,
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
