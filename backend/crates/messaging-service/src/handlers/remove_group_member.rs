/// Handler for removing members from group chats
use crate::db::DatabaseClient;
use crate::mls_manager::MlsManager;
use crate::proto::messaging::{
    remove_group_member_response, RemoveGroupMemberRequest, RemoveGroupMemberResponse,
    RemoveGroupMemberSuccess,
};
use crate::proto::common::ErrorResponse;
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn remove_group_member(
    request: RemoveGroupMemberRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<RemoveGroupMemberResponse>, Status> {
    // Validate JWT token and extract user_id (requester)
    let jwt_secret = crate::config::get_jwt_secret();
    
    let (requester_user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(RemoveGroupMemberResponse {
                result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate group ID
    if request.group_id.is_empty() {
        return Ok(Response::new(RemoveGroupMemberResponse {
            result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Group ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate member user ID
    if request.member_user_id.is_empty() {
        return Ok(Response::new(RemoveGroupMemberResponse {
            result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Member user ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Check if group exists
    match db.get_group(&request.group_id).await {
        Ok(Some(group)) => {
            // Prevent removing the group owner
            if request.member_user_id == group.creator_user_id {
                return Ok(Response::new(RemoveGroupMemberResponse {
                    result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                        code: 7, // PERMISSION_DENIED
                        message: "Cannot remove group owner".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        }
        Ok(None) => {
            return Ok(Response::new(RemoveGroupMemberResponse {
                result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group: {}", e);
            return Ok(Response::new(RemoveGroupMemberResponse {
                result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to verify group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    }

    // Verify requester has permission to remove members
    // Must be owner/admin OR removing themselves
    let members = match db.get_group_members(&request.group_id).await {
        Ok(m) => m,
        Err(e) => {
            tracing::error!("Failed to fetch group members: {}", e);
            return Ok(Response::new(RemoveGroupMemberResponse {
                result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to verify membership".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Check requester's role
    let requester_member = members.iter().find(|m| m.user_id == requester_user_id);
    let is_self_removal = requester_user_id == request.member_user_id;

    match requester_member {
        None => {
            tracing::warn!(
                "User {} attempted to remove member from group {} without membership",
                requester_user_id,
                request.group_id
            );
            return Ok(Response::new(RemoveGroupMemberResponse {
                result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                    code: 7, // PERMISSION_DENIED
                    message: "Not a member of this group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Some(member) if is_self_removal => {
            // Users can always remove themselves (leave group)
            // But owners must transfer ownership first
            if member.role == crate::models::GroupRole::Owner {
                return Ok(Response::new(RemoveGroupMemberResponse {
                    result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                        code: 9, // FAILED_PRECONDITION
                        message: "Owner must transfer ownership before leaving".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        }
        Some(member) if member.role == crate::models::GroupRole::Owner || member.role == crate::models::GroupRole::Admin => {
            // Owners and admins can remove members
            // But check that target is not the owner
            let target_member = members.iter().find(|m| m.user_id == request.member_user_id);
            if let Some(target) = target_member {
                if target.role == crate::models::GroupRole::Owner {
                    return Ok(Response::new(RemoveGroupMemberResponse {
                        result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                            code: 7, // PERMISSION_DENIED
                            message: "Cannot remove the group owner".to_string(),
                            details: Default::default(),
                        })),
                    }));
                }
            }
        }
        Some(_) => {
            tracing::warn!(
                "User {} attempted to remove member from group {} without admin/owner permission",
                requester_user_id,
                request.group_id
            );
            return Ok(Response::new(RemoveGroupMemberResponse {
                result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                    code: 7, // PERMISSION_DENIED
                    message: "Only owners and admins can remove members".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    }

    tracing::debug!(
        "User {} removing member {} from group {}",
        requester_user_id,
        request.member_user_id,
        request.group_id
    );

    // Remove member from group in TiKV
    if let Err(e) = db.remove_group_member(&request.group_id, &request.member_user_id).await {
        tracing::error!("Failed to remove group member: {}", e);
        return Ok(Response::new(RemoveGroupMemberResponse {
            result: Some(remove_group_member_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to remove member".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // MLS-002: Update MLS group state in TiKV
    // Remove member from MLS members list for this group
    let mls_manager = MlsManager::new(db.clone());
    if let Err(e) = mls_manager.remove_member_from_list(
        &request.group_id,
        &request.member_user_id,
        "primary", // Default device
    ).await {
        tracing::warn!(
            "Failed to update MLS member list for group {}: {}",
            request.group_id,
            e
        );
        // Continue anyway - the group membership was successfully removed
    }

    tracing::info!(
        "Member {} removed from group {} by {}",
        request.member_user_id,
        request.group_id,
        requester_user_id
    );

    Ok(Response::new(RemoveGroupMemberResponse {
        result: Some(remove_group_member_response::Result::Success(
            RemoveGroupMemberSuccess { removed: true },
        )),
    }))
}
