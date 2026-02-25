//! Update group handler - updates group name, icon, and description

use std::collections::HashMap;
use std::sync::Arc;
use tonic::{Response, Status};

use crate::auth_client::{AuthClient, UserProfileInfo};
use crate::db::DatabaseClient;
use crate::proto::common::{ErrorResponse, Timestamp};
use crate::proto::messaging::{
    update_group_response, GroupInfo, GroupMemberInfo, UpdateGroupRequest, UpdateGroupResponse,
    UpdateGroupSuccess,
};

/// Update group information (name, icon, description)
/// Only group owner and admins can update group info
pub async fn update_group(
    request: UpdateGroupRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<UpdateGroupResponse>, Status> {
    // Validate JWT token and extract user_id
    let jwt_secret = crate::config::get_jwt_secret();

    let (user_id, _device_id, _username) =
        match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
            Ok(ids) => ids,
            Err(_) => {
                return Ok(Response::new(UpdateGroupResponse {
                    result: Some(update_group_response::Result::Error(ErrorResponse {
                        code: 16, // UNAUTHENTICATED
                        message: "Invalid or expired access token".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        };

    // Validate group_id
    if request.group_id.is_empty() {
        return Ok(Response::new(UpdateGroupResponse {
            result: Some(update_group_response::Result::Error(ErrorResponse {
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
            return Ok(Response::new(UpdateGroupResponse {
                result: Some(update_group_response::Result::Error(ErrorResponse {
                    code: 5, // NOT_FOUND
                    message: "Group not found".to_string(),
                    details: Default::default(),
                })),
            }));
        }
        Err(e) => {
            tracing::error!("Failed to fetch group {}: {}", request.group_id, e);
            return Ok(Response::new(UpdateGroupResponse {
                result: Some(update_group_response::Result::Error(ErrorResponse {
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
            tracing::error!("Failed to fetch group members: {}", e);
            return Ok(Response::new(UpdateGroupResponse {
                result: Some(update_group_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to fetch group members".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Check if user is a member with permission to update
    let user_member = members.iter().find(|m| m.user_id == user_id);
    let can_update = match user_member {
        Some(m) => {
            m.role == crate::models::GroupRole::Owner || m.role == crate::models::GroupRole::Admin
        }
        None => false,
    };

    if !can_update {
        return Ok(Response::new(UpdateGroupResponse {
            result: Some(update_group_response::Result::Error(ErrorResponse {
                code: 7, // PERMISSION_DENIED
                message: "Only owner and admins can update group info".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Update group fields
    let new_name = if request.name.is_empty() {
        group.group_name.clone()
    } else {
        request.name.clone()
    };

    let new_icon = if request.icon_media_id.is_empty() {
        group.icon_media_id.clone()
    } else {
        Some(request.icon_media_id.clone())
    };

    let new_description = if request.description.is_empty() {
        group.description.clone()
    } else {
        Some(request.description.clone())
    };

    // Save to database
    if let Err(e) = db
        .update_group_info(
            &request.group_id,
            &new_name,
            new_icon.as_deref(),
            new_description.as_deref(),
        )
        .await
    {
        tracing::error!("Failed to update group: {}", e);
        return Ok(Response::new(UpdateGroupResponse {
            result: Some(update_group_response::Result::Error(ErrorResponse {
                code: 13, // INTERNAL
                message: "Failed to update group".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Build response with updated group info
    // Collect unique user IDs for batch profile lookup
    let user_ids: Vec<String> = members.iter().map(|m| m.user_id.clone()).collect();

    // Fetch full user profiles from auth service
    let auth_url = std::env::var("AUTH_SERVICE_URL")
        .unwrap_or_else(|_| "http://auth-service:50051".to_string());
    let user_profiles: HashMap<String, UserProfileInfo> = match AuthClient::new(&auth_url).await {
        Ok(mut client) => client.get_user_profiles(&user_ids).await,
        Err(e) => {
            tracing::warn!(
                "Failed to connect to auth service for profile lookup: {}",
                e
            );
            HashMap::new()
        }
    };

    let member_infos: Vec<GroupMemberInfo> = members
        .iter()
        .map(|m| {
            // Get full profile or create default with user_id as fallback
            let profile = user_profiles.get(&m.user_id);

            let username = profile
                .map(|p| p.username.clone())
                .unwrap_or_else(|| m.user_id.clone());

            let display_name = profile.map(|p| p.display_name.clone()).unwrap_or_default();

            let avatar_media_id = profile
                .map(|p| p.avatar_media_id.clone())
                .unwrap_or_default();

            GroupMemberInfo {
                user_id: m.user_id.clone(),
                username,
                device_id: m.device_id.clone(),
                role: m.role.to_string(),
                joined_at: Some(Timestamp {
                    seconds: m.joined_at,
                    nanos: 0,
                }),
                avatar_media_id,
                display_name,
            }
        })
        .collect();

    let updated_group = GroupInfo {
        group_id: group.group_id.clone(),
        name: new_name,
        creator_user_id: group.creator_user_id.clone(),
        members: member_infos,
        created_at: Some(Timestamp {
            seconds: group.created_at,
            nanos: 0,
        }),
        member_count: members.len() as i32,
        last_message: None,
        icon_media_id: new_icon.unwrap_or_default(),
        description: new_description.unwrap_or_default(),
    };

    tracing::info!("User {} updated group {} info", user_id, request.group_id);

    Ok(Response::new(UpdateGroupResponse {
        result: Some(update_group_response::Result::Success(UpdateGroupSuccess {
            group: Some(updated_group),
        })),
    }))
}
