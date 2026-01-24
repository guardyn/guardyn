/// Handler for getting all groups for a user
use crate::auth_client::{AuthClient, UserProfileInfo};
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_groups_response, GetGroupsRequest, GetGroupsResponse, GetGroupsSuccess,
    GroupInfo, GroupMemberInfo, GroupMessage as ProtoGroupMessage,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::collections::HashMap;
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_groups(
    request: GetGroupsRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetGroupsResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(GetGroupsResponse {
                result: Some(get_groups_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Get limit (default 50, max 100)
    let limit = if request.limit > 0 && request.limit <= 100 {
        request.limit as usize
    } else {
        50
    };

    // Fetch user's groups
    let user_groups = match db.get_user_groups(&user_id).await {
        Ok(groups) => groups,
        Err(e) => {
            tracing::error!("Failed to fetch groups for user {}: {}", user_id, e);
            return Ok(Response::new(GetGroupsResponse {
                result: Some(get_groups_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch groups".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Parse cursor (format: "offset:{number}" or empty for start)
    let offset: usize = if request.cursor.is_empty() {
        0
    } else if let Some(offset_str) = request.cursor.strip_prefix("offset:") {
        offset_str.parse().unwrap_or(0)
    } else {
        0
    };

    // Apply pagination: skip to offset, take limit+1 to check for more
    let groups_with_extra: Vec<_> = user_groups.into_iter().skip(offset).take(limit + 1).collect();
    let has_more = groups_with_extra.len() > limit;
    let groups_to_return: Vec<_> = groups_with_extra.into_iter().take(limit).collect();

    // Collect all unique user IDs from members for batch lookup
    let all_user_ids: Vec<String> = groups_to_return
        .iter()
        .flat_map(|(_, members)| members.iter().map(|m| m.user_id.clone()))
        .collect::<std::collections::HashSet<_>>()
        .into_iter()
        .collect();

    // Fetch full user profiles from auth service (batch lookup)
    let auth_url = std::env::var("AUTH_SERVICE_URL")
        .unwrap_or_else(|_| "http://auth-service:50051".to_string());
    let user_profiles: HashMap<String, UserProfileInfo> = match AuthClient::new(&auth_url).await {
        Ok(mut client) => client.get_user_profiles(&all_user_ids).await,
        Err(e) => {
            tracing::warn!("Failed to connect to auth service for profile lookup: {}", e);
            HashMap::new()
        }
    };

    // Convert to GroupInfo with members
    let mut groups_info = Vec::new();
    for (group, members) in groups_to_return {
        let member_infos: Vec<GroupMemberInfo> = members
            .iter()
            .map(|m| {
                // Get full profile or create default with user_id as fallback
                let profile = user_profiles.get(&m.user_id);
                
                let username = profile
                    .map(|p| p.username.clone())
                    .unwrap_or_else(|| m.user_id.clone());
                
                let display_name = profile
                    .map(|p| p.display_name.clone())
                    .unwrap_or_default();
                
                let avatar_media_id = profile
                    .map(|p| p.avatar_media_id.clone())
                    .unwrap_or_default();

                GroupMemberInfo {
                    user_id: m.user_id.clone(),
                    username,
                    device_id: m.device_id.clone(),
                    role: m.role.to_string(),
                    joined_at: Some(Timestamp {
                        seconds: m.joined_at,
                        nanos: 0,
                    }),
                    avatar_media_id,
                    display_name,
                }
            })
            .collect();

        // Fetch last message for this group from ScyllaDB
        let last_message = match db.get_last_group_message(&group.group_id).await {
            Ok(Some(msg)) => {
                // Extract sender_username from metadata, user profiles cache, or fall back to sender_user_id
                let sender_username = msg.metadata
                    .get("sender_username")
                    .cloned()
                    .or_else(|| user_profiles.get(&msg.sender_user_id).map(|p| p.username.clone()))
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
                tracing::warn!("Failed to fetch last message for group {}: {}", group.group_id, e);
                None
            }
        };

        groups_info.push(GroupInfo {
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
        });
    }

    // Generate next cursor
    let next_cursor = if has_more {
        format!("offset:{}", offset + limit)
    } else {
        String::new()
    };

    tracing::info!(
        user_id = %user_id,
        offset,
        limit,
        returned = groups_info.len(),
        has_more,
        "Fetched groups with pagination"
    );

    Ok(Response::new(GetGroupsResponse {
        result: Some(get_groups_response::Result::Success(GetGroupsSuccess {
            groups: groups_info,
            next_cursor,
            has_more,
        })),
    }))
}
