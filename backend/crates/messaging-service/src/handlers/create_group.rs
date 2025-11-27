/// Handler for creating group chats
use crate::db::DatabaseClient;
use crate::models::{GroupMetadata, GroupMember, GroupRole};
use crate::proto::messaging::{
    create_group_response, CreateGroupRequest, CreateGroupResponse, CreateGroupSuccess,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};
use uuid::Uuid;

pub async fn create_group(
    request: CreateGroupRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<CreateGroupResponse>, Status> {
    // Validate JWT token and extract user_id (group creator)
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (creator_user_id, creator_device_id, _creator_username) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(CreateGroupResponse {
                result: Some(create_group_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate group name
    if request.group_name.is_empty() || request.group_name.len() > 100 {
        return Ok(Response::new(CreateGroupResponse {
            result: Some(create_group_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Group name must be between 1 and 100 characters".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate member list (max 100 members for MVP)
    if request.member_user_ids.len() > 100 {
        return Ok(Response::new(CreateGroupResponse {
            result: Some(create_group_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Maximum 100 members allowed per group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Generate group ID
    let group_id = uuid::Uuid::new_v4().to_string();
    let timestamp = chrono::Utc::now().timestamp();

    // Create group metadata
    let group_metadata = GroupMetadata {
        group_id: group_id.clone(),
        group_name: request.group_name.clone(),
        creator_user_id: creator_user_id.clone(),
        created_at: timestamp,
        mls_group_id: request.mls_group_state.clone(),
        mls_epoch: 0, // Initial epoch
    };

    // Store group in TiKV
    if let Err(e) = db.create_group(&group_metadata).await {
        tracing::error!("Failed to create group in TiKV: {}", e);
        return Ok(Response::new(CreateGroupResponse {
            result: Some(create_group_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to create group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Add creator as group owner
    let creator_member = GroupMember {
        group_id: group_id.clone(),
        user_id: creator_user_id.clone(),
        device_id: creator_device_id.clone(),
        role: GroupRole::Owner,
        joined_at: timestamp,
    };

    if let Err(e) = db.add_group_member(&creator_member).await {
        tracing::error!("Failed to add creator to group: {}", e);
        // Continue anyway - group is created
    }

    // Add initial members as regular members
    for member_user_id in &request.member_user_ids {
        if member_user_id == &creator_user_id {
            continue; // Skip creator (already added as owner)
        }

        let member = GroupMember {
            group_id: group_id.clone(),
            user_id: member_user_id.clone(),
            device_id: "primary".to_string(),  // Default device for initial members
            role: GroupRole::Member,
            joined_at: timestamp,
        };

        if let Err(e) = db.add_group_member(&member).await {
            tracing::warn!("Failed to add member {} to group: {}", member_user_id, e);
            // Continue with other members
        }
    }

    tracing::info!(
        "Group {} created by {} with {} members",
        group_id,
        creator_user_id,
        request.member_user_ids.len() + 1
    );

    Ok(Response::new(CreateGroupResponse {
        result: Some(create_group_response::Result::Success(
            CreateGroupSuccess {
                group_id,
                created_at: Some(Timestamp {
                    seconds: timestamp,
                    nanos: 0,
                }),
            },
        )),
    }))
}
