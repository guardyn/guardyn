//! Group Management Commands
//!
//! Handles group chat operations: listing, viewing, updating, and member management.

use crate::state::AppState;
use serde::{Deserialize, Serialize};
use tauri::State;

// ============================================================================
// Data Types
// ============================================================================

/// Group summary for list view
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Group {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub member_count: u32,
    pub avatar_url: Option<String>,
    pub created_at: i64,
    pub updated_at: i64,
    pub created_by: String,
    pub is_muted: bool,
    pub unread_count: u32,
}

/// Group member information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupMember {
    pub user_id: String,
    pub username: String,
    pub display_name: Option<String>,
    pub role: String, // "owner", "admin", "member"
    pub avatar_url: Option<String>,
    pub is_online: bool,
}

// ============================================================================
// Commands
// ============================================================================

/// Get all groups for the current user
#[tauri::command]
pub async fn get_groups(state: State<'_, AppState>) -> Result<Vec<Group>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Fetching groups list");

    match state.messaging().get_groups(50).await {
        Ok(groups) => {
            let result: Vec<Group> = groups
                .into_iter()
                .map(|g| Group {
                    id: g.group_id,
                    name: g.name,
                    description: g.description,
                    member_count: g.member_count,
                    avatar_url: g.icon_media_id.map(|id| format!("/api/media/{}", id)),
                    created_at: 0,
                    updated_at: 0,
                    created_by: String::new(),
                    is_muted: false,
                    unread_count: 0,
                })
                .collect();
            Ok(result)
        }
        Err(e) => {
            tracing::error!("Failed to get groups: {:?}", e);
            Err(format!("Failed to get groups: {}", e))
        }
    }
}

/// Get a group by ID with full details
#[tauri::command]
pub async fn get_group(group_id: String, state: State<'_, AppState>) -> Result<Group, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Fetching group: {}", group_id);

    match state.messaging().get_group_by_id(group_id).await {
        Ok(group) => Ok(Group {
            id: group.group_id,
            name: group.name,
            description: group.description,
            member_count: group.member_count,
            avatar_url: group.icon_media_id.map(|id| format!("/api/media/{}", id)),
            created_at: group.created_at,
            updated_at: group.created_at,
            created_by: group.creator_user_id,
            is_muted: false,
            unread_count: 0,
        }),
        Err(e) => {
            tracing::error!("Failed to get group: {:?}", e);
            Err(format!("Failed to get group: {}", e))
        }
    }
}

/// Get members of a group
#[tauri::command]
pub async fn get_group_members(
    group_id: String,
    state: State<'_, AppState>,
) -> Result<Vec<GroupMember>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Fetching members for group: {}", group_id);

    match state.messaging().get_group_by_id(group_id).await {
        Ok(group) => {
            let members: Vec<GroupMember> = group
                .members
                .into_iter()
                .map(|m| GroupMember {
                    user_id: m.user_id,
                    username: m.username.clone(),
                    display_name: m.display_name.or(Some(m.username)),
                    role: m.role,
                    avatar_url: m.avatar_media_id.map(|id| format!("/api/media/{}", id)),
                    is_online: false, // TODO: Get from presence service
                })
                .collect();
            Ok(members)
        }
        Err(e) => {
            tracing::error!("Failed to get group members: {:?}", e);
            Err(format!("Failed to get group members: {}", e))
        }
    }
}

/// Update a member's role in the group (owner only)
#[tauri::command]
pub async fn update_member_role(
    group_id: String,
    user_id: String,
    role: String,
    state: State<'_, AppState>,
) -> Result<String, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    // Validate role
    if role != "admin" && role != "member" {
        return Err("Invalid role. Must be 'admin' or 'member'".to_string());
    }

    tracing::debug!(
        "Updating role of user {} to {} in group {}",
        user_id,
        role,
        group_id
    );

    match state
        .messaging()
        .change_member_role(group_id, user_id, role)
        .await
    {
        Ok(new_role) => {
            tracing::info!("Role updated to: {}", new_role);
            Ok(new_role)
        }
        Err(e) => {
            tracing::error!("Failed to update member role: {:?}", e);
            Err(format!("Failed to update member role: {}", e))
        }
    }
}

/// Remove a member from a group
#[tauri::command]
pub async fn remove_group_member(
    group_id: String,
    user_id: String,
    state: State<'_, AppState>,
) -> Result<bool, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Removing user {} from group {}", user_id, group_id);

    match state
        .messaging()
        .remove_group_member(group_id, user_id)
        .await
    {
        Ok(removed) => {
            tracing::info!("Member removed: {}", removed);
            Ok(removed)
        }
        Err(e) => {
            tracing::error!("Failed to remove member: {:?}", e);
            Err(format!("Failed to remove member: {}", e))
        }
    }
}

/// Leave a group
#[tauri::command]
pub async fn leave_group(group_id: String, state: State<'_, AppState>) -> Result<bool, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Leaving group: {}", group_id);

    match state.messaging().leave_group(group_id).await {
        Ok(left) => {
            tracing::info!("Left group: {}", left);
            Ok(left)
        }
        Err(e) => {
            tracing::error!("Failed to leave group: {:?}", e);
            Err(format!("Failed to leave group: {}", e))
        }
    }
}

/// Update group information
#[tauri::command]
pub async fn update_group(
    group_id: String,
    name: Option<String>,
    description: Option<String>,
    icon_media_id: Option<String>,
    state: State<'_, AppState>,
) -> Result<Group, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Updating group: {}", group_id);

    match state
        .messaging()
        .update_group(group_id, name, description, icon_media_id)
        .await
    {
        Ok(group) => Ok(Group {
            id: group.group_id,
            name: group.name,
            description: group.description,
            member_count: group.member_count,
            avatar_url: group.icon_media_id.map(|id| format!("/api/media/{}", id)),
            created_at: group.created_at,
            updated_at: group.created_at,
            created_by: group.creator_user_id,
            is_muted: false,
            unread_count: 0,
        }),
        Err(e) => {
            tracing::error!("Failed to update group: {:?}", e);
            Err(format!("Failed to update group: {}", e))
        }
    }
}
