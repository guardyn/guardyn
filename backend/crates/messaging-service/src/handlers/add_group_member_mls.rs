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
use std::collections::HashMap;
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
                        details: HashMap::new(),
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
                details: HashMap::new(),
            })),
        }));
    }

    // Validate member user ID
    if request.member_user_id.is_empty() {
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InvalidRequest as i32,
                message: "Member user ID required".to_string(),
                details: HashMap::new(),
            })),
        }));
    }

    // Validate member device ID
    if request.member_device_id.is_empty() {
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InvalidRequest as i32,
                message: "Member device ID required for MLS".to_string(),
                details: HashMap::new(),
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
                    details: HashMap::new(),
                })),
            }));
        }
        Err(e) => {
            error!("Failed to fetch group metadata: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to verify group".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
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
                    details: HashMap::new(),
                })),
            }));
        }
        Err(e) => {
            error!("Failed to verify group membership: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to verify membership".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
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
                    details: HashMap::new(),
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
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    }

    // Fetch member's MLS key package from auth-service
    info!(
        "Fetching MLS key package for {}:{}",
        request.member_user_id, request.member_device_id
    );

    // Create auth client and fetch key package
    let mut auth_client = match crate::auth_client::AuthClient::new(&auth_service_url).await {
        Ok(client) => client,
        Err(e) => {
            error!("Failed to connect to auth-service: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to connect to auth service".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    };

    let member_key_package_bytes = match auth_client
        .fetch_mls_key_package(&request.member_user_id, &request.member_device_id)
        .await
    {
        Ok(key_package) => key_package,
        Err(e) => {
            error!("Failed to fetch MLS key package: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::NotFound as i32,
                    message: "MLS key package not found for user".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    };

    info!(
        "Successfully fetched MLS key package ({} bytes)",
        member_key_package_bytes.len()
    );

    // Load group state from TiKV
    let group_state = match mls_manager.load_group_state(&request.group_id).await {
        Ok(Some(state)) => state,
        Ok(None) => {
            error!("Group state not found for group_id={}", request.group_id);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::NotFound as i32,
                    message: "Group state not found".to_string(),
                    details: Some("MLS group state missing in TiKV".to_string()),
                })),
            }));
        }
        Err(e) => {
            error!("Failed to load group state: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to load group state".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    };

    // Reconstruct MLS group manager (this is the OpenMLS limitation)
    // For MVP, we'll create a new group manager and rely on epoch tracking
    // TODO: Implement state caching or upgrade OpenMLS version with deserialization
    info!(
        "Reconstructing MLS group manager for group {} (epoch {})",
        request.group_id, group_state.epoch
    );

    // Create MLS group manager with identity from requester
    // NOTE: This is a workaround for OpenMLS deserialization limitation
    // In production, we need to maintain in-memory group managers or implement custom serialization
    let mut group_manager = match MlsGroupManager::create_group(
        &requester_user_id,
        &requester_device_id,
        &request.group_id,
    ) {
        Ok(manager) => manager,
        Err(e) => {
            error!("Failed to create MLS group manager: {}", e);
            return Ok(Response::new(AddGroupMemberResponse {
                result: Some(add_group_member_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to initialize MLS group manager".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    };

    // Add member to MLS group (generates Commit and Welcome messages)
    let (commit_message, welcome_message) =
        match group_manager.add_member(&member_key_package_bytes) {
            Ok(messages) => messages,
            Err(e) => {
                error!("Failed to add member to MLS group: {}", e);
                return Ok(Response::new(AddGroupMemberResponse {
                    result: Some(add_group_member_response::Result::Error(ErrorResponse {
                        code: crate::proto::common::error_response::ErrorCode::InternalError
                            as i32,
                        message: "Failed to add member to MLS group".to_string(),
                        details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                    })),
                }));
            }
        };

    info!("MLS member addition successful, saving group state");

    // Save updated group state (epoch incremented)
    if let Err(e) = mls_manager
        .save_group_state(&request.group_id, &group_manager)
        .await
    {
        error!("Failed to save group state: {}", e);
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                message: "Failed to save group state".to_string(),
                details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
            })),
        }));
    }

    // Add member to TiKV members list
    let new_member = GroupMember {
        user_id: request.member_user_id.clone(),
        device_id: request.member_device_id.clone(),
        role: GroupRole::Member,
        joined_at: chrono::Utc::now().timestamp(),
    };

    if let Err(e) = mls_manager
        .add_member_to_list(&request.group_id, &new_member)
        .await
    {
        error!("Failed to add member to members list: {}", e);
        return Ok(Response::new(AddGroupMemberResponse {
            result: Some(add_group_member_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                message: "Failed to update members list".to_string(),
                details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
            })),
        }));
    }

    // Send Welcome message to new member via NATS
    let welcome_subject = format!(
        "messaging.mls.welcome.{}.{}",
        request.member_user_id, request.member_device_id
    );
    if let Err(e) = nats.publish(&welcome_subject, &welcome_message).await {
        error!("Failed to send Welcome message via NATS: {}", e);
        // Don't fail the whole operation, member can re-sync
    } else {
        info!("Welcome message sent to new member via NATS");
    }

    // Send Commit message to all existing members via NATS
    let commit_subject = format!("messaging.mls.commit.{}", request.group_id);
    if let Err(e) = nats.publish(&commit_subject, &commit_message).await {
        error!("Failed to send Commit message via NATS: {}", e);
        // Don't fail the whole operation, members can re-sync
    } else {
        info!("Commit message broadcasted to existing members via NATS");
    }

    // Return success
    Ok(Response::new(AddGroupMemberResponse {
        result: Some(add_group_member_response::Result::Success(
            AddGroupMemberSuccess {
                added: true,
            },
        )),
    }))
}
