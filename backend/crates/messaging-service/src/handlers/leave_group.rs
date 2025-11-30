/// Handler for leaving a group
use crate::db::DatabaseClient;
use crate::proto::messaging::{
    leave_group_response, LeaveGroupRequest, LeaveGroupResponse, LeaveGroupSuccess,
};
use crate::proto::common::ErrorResponse;
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn leave_group(
    request: LeaveGroupRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<LeaveGroupResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (user_id, _device_id, _username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(LeaveGroupResponse {
                result: Some(leave_group_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate group_id
    if request.group_id.is_empty() {
        return Ok(Response::new(LeaveGroupResponse {
            result: Some(leave_group_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "group_id is required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Check if group exists
    let group = match db.get_group(&request.group_id).await {
        Ok(Some(group)) => group,
        Ok(None) => {
            return Ok(Response::new(LeaveGroupResponse {
                result: Some(leave_group_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group {}: {}", request.group_id, e);
            return Ok(Response::new(LeaveGroupResponse {
                result: Some(leave_group_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Check if user is the group owner
    if group.creator_user_id == user_id {
        return Ok(Response::new(LeaveGroupResponse {
            result: Some(leave_group_response::Result::Error(ErrorResponse {
                code: 9, // FAILED_PRECONDITION
                message: "Group owner cannot leave. Transfer ownership first or delete the group.".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Check if user is a member
    let members = match db.get_group_members(&request.group_id).await {
        Ok(m) => m,
        Err(e) => {
            tracing::error!("Failed to fetch members for group {}: {}", request.group_id, e);
            return Ok(Response::new(LeaveGroupResponse {
                result: Some(leave_group_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to check membership".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    let is_member = members.iter().any(|m| m.user_id == user_id);
    if !is_member {
        return Ok(Response::new(LeaveGroupResponse {
            result: Some(leave_group_response::Result::Error(ErrorResponse {
                code: 9, // FAILED_PRECONDITION
                message: "You are not a member of this group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Remove user from group
    if let Err(e) = db.remove_group_member(&request.group_id, &user_id).await {
        tracing::error!("Failed to remove user {} from group {}: {}", user_id, request.group_id, e);
        return Ok(Response::new(LeaveGroupResponse {
            result: Some(leave_group_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to leave group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    tracing::info!("User {} left group {}", user_id, request.group_id);

    Ok(Response::new(LeaveGroupResponse {
        result: Some(leave_group_response::Result::Success(LeaveGroupSuccess {
            left: true,
        })),
    }))
}
