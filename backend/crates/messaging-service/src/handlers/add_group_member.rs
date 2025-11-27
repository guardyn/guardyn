/// Handler for adding members to group chats
use crate::db::DatabaseClient;
use crate::models::{GroupMember, GroupRole};
use crate::proto::messaging::{
    add_group_member_response, AddGroupMemberRequest, AddGroupMemberResponse,
    AddGroupMemberSuccess,
};
use crate::proto::common::ErrorResponse;
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn add_group_member(
    request: AddGroupMemberRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<AddGroupMemberResponse>, Status> {
    // Validate JWT token and extract user_id (requester)
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());
    
    let (requester_user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate group ID
    if request.group_id.is_empty() {
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Group ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate member user ID
    if request.member_user_id.is_empty() {
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Member user ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Check if group exists
    match db.get_group(&request.group_id).await {
        Ok(Some(_group)) => {
            // Group exists, continue
        }
        Ok(None) => {
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to verify group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    }

    // TODO: Verify requester has permission to add members (must be owner or admin)
    // For MVP, we skip this check
    tracing::debug!(
        "User {} adding member {} to group {}",
        requester_user_id,
        request.member_user_id,
        request.group_id
    );

    // Check if member is already in group
    match db.get_group_members(&request.group_id).await {
        Ok(existing_members) => {
            if existing_members.iter().any(|m| m.user_id == request.member_user_id) {
                return Ok(Response::new(AddGroupMemberResponse {
                    result: Some(add_group_member_response::Result::Error(ErrorResponse {
                        code: 6, // ALREADY_EXISTS
                        message: "User is already a member of this group".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        }
        Err(e) => {
            tracing::error!("Failed to fetch group members: {}", e);
            // Continue anyway
        }
    }

    // Add member to group
    let timestamp = chrono::Utc::now().timestamp();
    let new_member = GroupMember {
        group_id: request.group_id.clone(),
        user_id: request.member_user_id.clone(),
        device_id: "primary".to_string(),  // Default device for non-MLS group members
        role: GroupRole::Member,
        joined_at: timestamp,
    };

    if let Err(e) = db.add_group_member(&new_member).await {
        tracing::error!("Failed to add member to group: {}", e);
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to add member".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // TODO: Update MLS group state in TiKV
    // For MVP, we just store the provided state without validation

    tracing::info!(
        "Member {} added to group {} by {}",
        request.member_user_id,
        request.group_id,
        requester_user_id
    );

    Ok(Response::new(AddGroupMemberResponse {
        result: Some(add_group_member_response::Result::Success(
            AddGroupMemberSuccess { added: true },
        )),
    }))
}
