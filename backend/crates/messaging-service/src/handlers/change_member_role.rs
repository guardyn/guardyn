//! Change member role handler
//!
//! Allows the group owner to change member roles (promote to admin or demote to member).

use std::sync::Arc;
use tonic::{Response, Status};

use crate::db::DatabaseClient;
use crate::models::GroupRole;
use crate::proto::common::error_response::ErrorCode;
use crate::proto::common::ErrorResponse;
use crate::proto::messaging::{
    change_member_role_response, ChangeMemberRoleRequest, ChangeMemberRoleResponse,
    ChangeMemberRoleSuccess,
};

/// Handle ChangeMemberRole RPC - only group owner can change member roles.
pub async fn change_member_role(
    request: ChangeMemberRoleRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<ChangeMemberRoleResponse>, Status> {
    // Validate token
    let jwt_secret = crate::config::get_jwt_secret();

    let (user_id, _device_id, _username) =
        match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
            Ok(ids) => ids,
            Err(_) => {
                return Ok(Response::new(ChangeMemberRoleResponse {
                    result: Some(change_member_role_response::Result::Error(ErrorResponse {
                        code: ErrorCode::Unauthorized as i32,
                        message: "Invalid token".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        };

    // Validate inputs
    if request.group_id.is_empty() || request.target_user_id.is_empty() {
        return Ok(Response::new(ChangeMemberRoleResponse {
            result: Some(change_member_role_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "group_id and target_user_id are required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Parse new role
    let new_role = match request.new_role.to_lowercase().as_str() {
        "admin" => GroupRole::Admin,
        "member" => GroupRole::Member,
        _ => {
            return Ok(Response::new(ChangeMemberRoleResponse {
                result: Some(change_member_role_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InvalidRequest as i32,
                    message: "new_role must be 'admin' or 'member'".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Get group members
    let members = match db.get_group_members(&request.group_id).await {
        Ok(m) => m,
        Err(e) => {
            tracing::error!("Failed to get group members: {}", e);
            return Ok(Response::new(ChangeMemberRoleResponse {
                result: Some(change_member_role_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to get group members".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Check if requester is owner
    let requester_is_owner = members
        .iter()
        .any(|m| m.user_id == user_id && m.role == GroupRole::Owner);

    if !requester_is_owner {
        return Ok(Response::new(ChangeMemberRoleResponse {
            result: Some(change_member_role_response::Result::Error(ErrorResponse {
                code: ErrorCode::Forbidden as i32,
                message: "Only the group owner can change member roles".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Check if target is a member
    let target_member = members.iter().find(|m| m.user_id == request.target_user_id);

    if target_member.is_none() {
        return Ok(Response::new(ChangeMemberRoleResponse {
            result: Some(change_member_role_response::Result::Error(ErrorResponse {
                code: ErrorCode::NotFound as i32,
                message: "Target user is not a member of this group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Cannot change owner's role
    if target_member.unwrap().role == GroupRole::Owner {
        return Ok(Response::new(ChangeMemberRoleResponse {
            result: Some(change_member_role_response::Result::Error(ErrorResponse {
                code: ErrorCode::Forbidden as i32,
                message: "Cannot change the owner's role".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Update role in database
    if let Err(e) = db
        .change_member_role(&request.group_id, &request.target_user_id, &new_role)
        .await
    {
        tracing::error!("Failed to change member role: {}", e);
        return Ok(Response::new(ChangeMemberRoleResponse {
            result: Some(change_member_role_response::Result::Error(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to change member role".to_string(),
                details: Default::default(),
            })),
        }));
    }

    tracing::info!(
        "User {} changed {} role to {:?} in group {}",
        user_id,
        request.target_user_id,
        new_role,
        request.group_id
    );

    Ok(Response::new(ChangeMemberRoleResponse {
        result: Some(change_member_role_response::Result::Success(
            ChangeMemberRoleSuccess {
                changed: true,
                new_role: request.new_role,
            },
        )),
    }))
}
