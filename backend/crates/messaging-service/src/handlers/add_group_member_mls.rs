/// Handler for adding members to MLS-encrypted group chats
///
/// Uses MLS protocol to securely add new members to the group.
/// Creates Welcome messages for new members and Commit messages for existing members.

use crate::db::DatabaseClient;
use crate::mls_manager::MlsManager;
use crate::models::{GroupMember, GroupRole};
use crate::nats::NatsClient;
use crate::proto::messaging::{
    add_group_member_response, AddGroupMemberRequest, AddGroupMemberResponse,
    AddGroupMemberSuccess,
};
use crate::proto::common::ErrorResponse;
use guardyn_crypto::mls::MlsGroupManager;
use std::sync::Arc;
use tonic::{Response, Status};
use tracing::{error, info};

pub async fn add_group_member_mls(
    request: AddGroupMemberRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
    auth_service_url: String,
) -> Result<Response<AddGroupMemberResponse>, Status> {
    // Validate JWT token and extract user_id (requester)
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (requester_user_id, requester_device_id) =
        match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
            Ok(ids) => ids,
            Err(_) => {
                return Ok(Response::new(AddGroupMemberResponse {
                    result: Some(add_group_member_response::Result::Error(ErrorResponse {
                        code: crate::proto::common::error_response::ErrorCode::Unauthorized as i32,
                        message: "Invalid or expired access token".to_string(),
                        details: None,
                    })),
                }));
            }
        };

    // Validate group ID
    if request.group_id.is_empty() {
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InvalidRequest as i32,
                message: "Group ID required".to_string(),
                details: None,
            })),
        }));
    }

    // Validate member user ID
    if request.member_user_id.is_empty() {
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InvalidRequest as i32,
                message: "Member user ID required".to_string(),
                details: None,
            })),
        }));
    }

    // Validate member device ID
    if request.member_device_id.is_empty() {
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InvalidRequest as i32,
                message: "Member device ID required for MLS".to_string(),
                details: None,
            })),
        }));
    }

    info!(
        "Adding member {}:{} to MLS group {}",
        request.member_user_id, request.member_device_id, request.group_id
    );

    // Initialize MLS manager
    let mls_manager = MlsManager::new(db.clone());

    // Verify group exists
    match mls_manager.get_metadata(&request.group_id).await {
        Ok(Some(_metadata)) => {
            // Group exists, continue
        }
        Ok(None) => {
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::NotFound as i32,
                    message: "Group not found".to_string(),
                    details: None,
                })),
            }));
        }
        Err(e) => {
            error!("Failed to fetch group metadata: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to verify group".to_string(),
                    details: Some(e.to_string()),
                })),
            }));
        }
    }

    // Verify requester is a member (has permission to add)
    match mls_manager
        .is_member(&request.group_id, &requester_user_id, &requester_device_id)
        .await
    {
        Ok(true) => {
            // Requester is a member, continue
        }
        Ok(false) => {
            error!(
                "User {} is not a member of group {}",
                requester_user_id, request.group_id
            );
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::Unauthorized as i32,
                    message: "Not authorized to add members".to_string(),
                    details: None,
                })),
            }));
        }
        Err(e) => {
            error!("Failed to verify group membership: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to verify membership".to_string(),
                    details: Some(e.to_string()),
                })),
            }));
        }
    }

    // Check if member is already in group
    match mls_manager
        .is_member(&request.group_id, &request.member_user_id, &request.member_device_id)
        .await
    {
        Ok(true) => {
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::Conflict as i32,
                    message: "User is already a member of this group".to_string(),
                    details: None,
                })),
            }));
        }
        Ok(false) => {
            // Not a member, proceed with adding
        }
        Err(e) => {
            error!("Failed to check member existence: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to check membership".to_string(),
                    details: Some(e.to_string()),
                })),
            }));
        }
    }

    // Fetch member's MLS key package from auth-service
    info!(
        "Fetching MLS key package for {}:{}",
        request.member_user_id, request.member_device_id
    );

    // TODO: Call auth-service gRPC to get MLS key package
    // For MVP, we return an error indicating this needs implementation
    error!("MLS key package fetch not yet implemented");
    return Ok(Response::new(AddGroupMemberResponse {
        result: Some(add_group_member_response::Result::Error(ErrorResponse {
            code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
            message: "MLS key package fetch not implemented".to_string(),
            details: Some(
                "Need to implement gRPC call to auth-service GetMlsKeyPackage".to_string(),
            ),
        })),
    }));

    // TODO: Implement MLS add member protocol
    // 1. Load group state from TiKV
    // 2. Reconstruct MlsGroupManager
    // 3. Call group_manager.add_member(member_key_package_bytes)
    // 4. Store updated group state
    // 5. Send Welcome message to new member via NATS
    // 6. Send Commit message to all existing members via NATS
    // 7. Add member to group members list in ScyllaDB

    // For now, fall back to non-MLS implementation
    // (This is handled by the existing add_group_member.rs)
}
