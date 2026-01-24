/// Handler for deleting a group (owner only)
use crate::db::DatabaseClient;
use crate::proto::common::ErrorResponse;
use crate::proto::messaging::{
    delete_group_response, DeleteGroupRequest, DeleteGroupResponse, DeleteGroupSuccess,
};
use std::sync::Arc;
use tonic::{Response, Status};

/// Handle DeleteGroup RPC - only group owner can delete the group.
/// This permanently removes the group, all messages, and all member records.
pub async fn delete_group(
    request: DeleteGroupRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<DeleteGroupResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = crate::config::get_jwt_secret();

    let (user_id, _device_id, _username) =
        match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
            Ok(ids) => ids,
            Err(_) => {
                return Ok(Response::new(DeleteGroupResponse {
                    result: Some(delete_group_response::Result::Error(ErrorResponse {
                        code: 16, // UNAUTHENTICATED
                        message: "Invalid or expired access token".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        };

    // Validate group_id
    if request.group_id.is_empty() {
        return Ok(Response::new(DeleteGroupResponse {
            result: Some(delete_group_response::Result::Error(ErrorResponse {
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
            return Ok(Response::new(DeleteGroupResponse {
                result: Some(delete_group_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group {}: {}", request.group_id, e);
            return Ok(Response::new(DeleteGroupResponse {
                result: Some(delete_group_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch group".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Only owner can delete the group
    if group.creator_user_id != user_id {
        return Ok(Response::new(DeleteGroupResponse {
            result: Some(delete_group_response::Result::Error(ErrorResponse {
                code: 7, // PERMISSION_DENIED
                message: "Only the group owner can delete the group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Delete all group messages first
    if let Err(e) = db.delete_all_group_messages(&request.group_id).await {
        tracing::error!(
            "Failed to delete messages for group {}: {}",
            request.group_id,
            e
        );
        return Ok(Response::new(DeleteGroupResponse {
            result: Some(delete_group_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to delete group messages".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Delete all group members
    if let Err(e) = db.delete_all_group_members(&request.group_id).await {
        tracing::error!(
            "Failed to delete members for group {}: {}",
            request.group_id,
            e
        );
        return Ok(Response::new(DeleteGroupResponse {
            result: Some(delete_group_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to delete group members".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Delete the group itself
    if let Err(e) = db.delete_group(&request.group_id).await {
        tracing::error!("Failed to delete group {}: {}", request.group_id, e);
        return Ok(Response::new(DeleteGroupResponse {
            result: Some(delete_group_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to delete group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    tracing::info!(
        "Group {} deleted by owner {}",
        request.group_id,
        user_id
    );

    Ok(Response::new(DeleteGroupResponse {
        result: Some(delete_group_response::Result::Success(DeleteGroupSuccess {
            deleted: true,
            group_id: request.group_id,
        })),
    }))
}
