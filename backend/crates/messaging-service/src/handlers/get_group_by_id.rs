/// Handler for getting a group by ID
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    get_group_by_id_response, GetGroupByIdRequest, GetGroupByIdResponse, GetGroupByIdSuccess,
    GroupInfo, GroupMemberInfo,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn get_group_by_id(
    request: GetGroupByIdRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<GetGroupByIdResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
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

    // Convert members to GroupMemberInfo
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
        last_message: None, // TODO: Fetch last message from ScyllaDB
    };

    tracing::info!("Fetched group {} for user {}", request.group_id, user_id);

    Ok(Response::new(GetGroupByIdResponse {
        result: Some(get_group_by_id_response::Result::Success(GetGroupByIdSuccess {
            group: Some(group_info),
        })),
    }))
}
