/// Handler for retrieving group message history
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_group_messages_response, GetGroupMessagesRequest, GetGroupMessagesResponse,
    GetGroupMessagesSuccess, GroupMessage,
};
use crate::proto::common::ErrorResponse;
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_group_messages(
    request: GetGroupMessagesRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetGroupMessagesResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());
    
    let (requester_user_id, _device_id) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
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

    // TODO: Verify requester is a member of the group
    // For MVP, we skip this check

    tracing::debug!(
        "User {} fetching messages for group {}",
        requester_user_id,
        request.group_id
    );

    // Determine limit (default 50, max 100)
    let limit = if request.limit > 0 && request.limit <= 100 {
        request.limit
    } else if request.limit > 100 {
        100
    } else {
        50
    };

    // Fetch group messages from ScyllaDB
    let stored_messages = match db.get_group_messages(&request.group_id, limit).await {
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

    // Convert to protobuf format
    let messages: Vec<GroupMessage> = stored_messages
        .into_iter()
        .map(|msg| GroupMessage {
            message_id: msg.message_id,
            group_id: msg.group_id,
            sender_user_id: msg.sender_user_id,
            sender_device_id: msg.sender_device_id,
            encrypted_content: msg.encrypted_content,
            message_type: msg.message_type,
            server_timestamp: Some(crate::proto::common::Timestamp {
                seconds: msg.server_timestamp,
                nanos: 0,
            }),
            client_timestamp: Some(crate::proto::common::Timestamp {
                seconds: msg.client_timestamp,
                nanos: 0,
            }),
            is_deleted: msg.is_deleted,
        })
        .collect();

    tracing::info!(
        "Retrieved {} group messages for group {} (requested by {})",
        messages.len(),
        request.group_id,
        requester_user_id
    );

    Ok(Response::new(GetGroupMessagesResponse {
        result: Some(get_group_messages_response::Result::Success(
            GetGroupMessagesSuccess {
                messages,
                pagination: None, // TODO: Implement pagination
            },
        )),
    }))
}
