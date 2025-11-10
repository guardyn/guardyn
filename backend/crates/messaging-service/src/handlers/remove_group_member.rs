/// Handler for removing members from group chats
use crate::db::DatabaseClient;
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
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());
    
    let (requester_user_id, _device_id) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
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

    // TODO: Verify requester has permission to remove members
    // Must be owner/admin OR removing themselves
    // For MVP, we allow self-removal and admin removal without strict checks

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

    // TODO: Update MLS group state in TiKV

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
