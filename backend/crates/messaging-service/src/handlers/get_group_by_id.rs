/// Handler for getting a group by ID
use crate::auth_client::AuthClient;
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_group_by_id_response, GetGroupByIdRequest, GetGroupByIdResponse, GetGroupByIdSuccess,
    GroupInfo, GroupMemberInfo, GroupMessage as ProtoGroupMessage,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_group_by_id(
    request: GetGroupByIdRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetGroupByIdResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(GetGroupByIdResponse {
                result: Some(get_group_by_id_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate group_id
    if request.group_id.is_empty() {
        return Ok(Response::new(GetGroupByIdResponse {
            result: Some(get_group_by_id_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "group_id is required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Fetch group metadata
    let group = match db.get_group(&request.group_id).await {
        Ok(Some(group)) => group,
        Ok(None) => {
            return Ok(Response::new(GetGroupByIdResponse {
                result: Some(get_group_by_id_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group {}: {}", request.group_id, e);
            return Ok(Response::new(GetGroupByIdResponse {
                result: Some(get_group_by_id_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Fetch group members
    let members = match db.get_group_members(&request.group_id).await {
        Ok(m) => m,
        Err(e) => {
            tracing::error!("Failed to fetch members for group {}: {}", request.group_id, e);
            Vec::new()
        }
    };

    // Check if user is a member
    let is_member = members.iter().any(|m| m.user_id == user_id);
    if !is_member {
        return Ok(Response::new(GetGroupByIdResponse {
            result: Some(get_group_by_id_response::Result::Error(ErrorResponse {
                code: 7, // PERMISSION_DENIED
                message: "You are not a member of this group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Collect unique user IDs for batch username lookup
    let user_ids: Vec<String> = members.iter().map(|m| m.user_id.clone()).collect();

    // Fetch usernames from auth service
    let auth_url = std::env::var("AUTH_SERVICE_URL")
        .unwrap_or_else(|_| "http://auth-service:50051".to_string());
    let user_profiles = match AuthClient::new(&auth_url).await {
        Ok(mut client) => client.get_usernames(&user_ids).await,
        Err(e) => {
            tracing::warn!("Failed to connect to auth service for username lookup: {}", e);
            std::collections::HashMap::new()
        }
    };

    // Convert members to GroupMemberInfo
    let member_infos: Vec<GroupMemberInfo> = members
        .iter()
        .map(|m| {
            let username = user_profiles
                .get(&m.user_id)
                .cloned()
                .unwrap_or_else(|| m.user_id.clone());

            GroupMemberInfo {
                user_id: m.user_id.clone(),
                username,
                device_id: m.device_id.clone(),
                role: m.role.to_string(),
                joined_at: Some(Timestamp {
                    seconds: m.joined_at,
                    nanos: 0,
                }),
                avatar_media_id: String::new(), // TODO: Add to auth service profile response
                display_name: String::new(),    // TODO: Add to auth service profile response
            }
        })
        .collect();

    // Fetch last message for this group from ScyllaDB
    let last_message = match db.get_last_group_message(&request.group_id).await {
        Ok(Some(msg)) => {
            // Extract sender_username from metadata or use fetched profile
            let sender_username = msg.metadata
                .get("sender_username")
                .cloned()
                .or_else(|| user_profiles.get(&msg.sender_user_id).cloned())
                .unwrap_or_else(|| msg.sender_user_id.clone());

            // Extract message_type from metadata (default to 0)
            let message_type = msg.metadata
                .get("message_type")
                .and_then(|s| s.parse::<i32>().ok())
                .unwrap_or(0);

            Some(ProtoGroupMessage {
                message_id: msg.message_id,
                group_id: msg.group_id,
                sender_user_id: msg.sender_user_id,
                sender_device_id: msg.sender_device_id,
                sender_username,
                encrypted_content: msg.encrypted_content,
                message_type,
                client_message_id: String::new(),
                server_timestamp: Some(Timestamp {
                    seconds: msg.sent_at / 1000,
                    nanos: ((msg.sent_at % 1000) * 1_000_000) as i32,
                }),
                client_timestamp: Some(Timestamp {
                    seconds: msg.sent_at / 1000,
                    nanos: 0,
                }),
                media_id: String::new(),
                is_deleted: false,
                thread_reference: None,
                forward_info: None,
                edit_version: 0,
                last_edited_at: None,
                voice_metadata: None,
                reaction_summaries: Vec::new(),
            })
        }
        Ok(None) => None,
        Err(e) => {
            tracing::warn!("Failed to fetch last message for group {}: {}", request.group_id, e);
            None
        }
    };

    let group_info = GroupInfo {
        group_id: group.group_id,
        name: group.group_name,
        creator_user_id: group.creator_user_id,
        members: member_infos,
        created_at: Some(Timestamp {
            seconds: group.created_at,
            nanos: 0,
        }),
        member_count: members.len() as i32,
        last_message,
        icon_media_id: group.icon_media_id.unwrap_or_default(),
        description: group.description.unwrap_or_default(),
    };

    tracing::info!("Fetched group {} for user {}", request.group_id, user_id);

    Ok(Response::new(GetGroupByIdResponse {
        result: Some(get_group_by_id_response::Result::Success(GetGroupByIdSuccess {
            group: Some(group_info),
        })),
    }))
}
