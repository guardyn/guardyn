/// Handler for getting all groups for a user
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_groups_response, GetGroupsRequest, GetGroupsResponse, GetGroupsSuccess,
    GroupInfo, GroupMemberInfo,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_groups(
    request: GetGroupsRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetGroupsResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
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

    // Convert to GroupInfo with members
    let mut groups_info = Vec::new();
    for (group, members) in user_groups.into_iter().take(limit) {
        let member_infos: Vec<GroupMemberInfo> = members
            .iter()
            .map(|m| GroupMemberInfo {
                user_id: m.user_id.clone(),
                username: m.user_id.clone(), // TODO: Fetch username from auth service
                device_id: m.device_id.clone(),
                role: m.role.to_string(),
                joined_at: Some(Timestamp {
                    seconds: m.joined_at,
                    nanos: 0,
                }),
            })
            .collect();

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
            last_message: None, // TODO: Fetch last message from ScyllaDB
        });
    }

    tracing::info!("Fetched {} groups for user {}", groups_info.len(), user_id);

    Ok(Response::new(GetGroupsResponse {
        result: Some(get_groups_response::Result::Success(GetGroupsSuccess {
            groups: groups_info,
            next_cursor: String::new(), // TODO: Implement pagination
            has_more: false,
        })),
    }))
}
