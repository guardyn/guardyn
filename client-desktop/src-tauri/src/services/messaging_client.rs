//! Messaging Service gRPC Client
//!
//! Handles 1-on-1 and group messaging with E2EE.

use crate::grpc::{GrpcClient, GrpcError};
use crate::proto::messaging::{
    messaging_service_client::MessagingServiceClient, AddReactionRequest, ChangeMemberRoleRequest,
    CreateGroupRequest, DeleteGroupRequest, DeleteMessageRequest, GetConversationsRequest, GetGroupByIdRequest,
    GetGroupMessagesRequest, GetGroupsRequest, GetMessagesRequest, LeaveGroupRequest,
    MarkAsReadRequest, RemoveGroupMemberRequest, SendGroupMessageRequest,
    SendMessageRequest, TypingIndicatorRequest, UpdateGroupRequest,
};
use std::sync::Arc;
use tonic::metadata::MetadataValue;
use tonic::transport::Channel;
use tonic::Request;
use tracing::{debug, info};

/// Message to send
#[derive(Debug, Clone)]
pub struct OutgoingMessage {
    pub recipient_user_id: String,
    pub encrypted_content: Vec<u8>,
    pub message_type: i32,
    pub client_message_id: String,
    pub media_id: Option<String>,
    pub x3dh_prekey: Option<String>,
}

/// Received message
#[derive(Debug, Clone)]
pub struct IncomingMessage {
    pub message_id: String,
    pub sender_user_id: String,
    pub recipient_user_id: String,
    pub encrypted_content: Vec<u8>,
    pub message_type: i32,
    pub client_message_id: String,
    pub server_timestamp: i64,
    pub delivery_status: i32,
    pub media_id: Option<String>,
    pub is_deleted: bool,
    pub x3dh_prekey: Option<String>,
}

/// Conversation summary
#[derive(Debug, Clone)]
pub struct ConversationSummary {
    pub conversation_id: String,
    pub user_id: String,
    pub username: String,
    pub unread_count: u32,
    pub last_message_id: Option<String>,
    pub last_message_preview: Option<String>,
}

/// Send message result
#[derive(Debug, Clone)]
pub struct SendMessageResult {
    pub message_id: String,
    pub server_timestamp: i64,
    pub delivery_status: i32,
}

/// Messaging client for Guardyn backend
pub struct MessagingClient {
    grpc: Arc<GrpcClient>,
}

impl MessagingClient {
    /// Create a new messaging client
    pub fn new(grpc: Arc<GrpcClient>) -> Self {
        Self { grpc }
    }

    /// Create a gRPC client
    async fn client(&self) -> Result<MessagingServiceClient<Channel>, GrpcError> {
        let channel = self.grpc.get_channel().await?;
        Ok(MessagingServiceClient::new(channel))
    }

    /// Add auth token to request
    fn with_auth<T>(&self, mut request: Request<T>) -> Result<Request<T>, GrpcError> {
        if let Some(token) = self.grpc.get_auth_token() {
            let value = MetadataValue::try_from(format!("Bearer {}", token))
                .map_err(|_| GrpcError::RequestFailed("Invalid auth token format".to_string()))?;
            request.metadata_mut().insert("authorization", value);
        }
        Ok(request)
    }

    /// Send a 1-on-1 encrypted message
    pub async fn send_message(&self, msg: OutgoingMessage) -> Result<SendMessageResult, GrpcError> {
        debug!("Sending message to user: {}", msg.recipient_user_id);

        let request = SendMessageRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            recipient_user_id: msg.recipient_user_id,
            recipient_device_id: String::new(),
            encrypted_content: msg.encrypted_content,
            message_type: msg.message_type,
            client_message_id: msg.client_message_id,
            client_timestamp: None,
            media_id: msg.media_id.unwrap_or_default(),
            recipient_username: String::new(),
            x3dh_prekey: msg.x3dh_prekey.unwrap_or_default(),
            thread_reference: None,
            voice_metadata: None,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .send_message(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::send_message_response::Result::Success(success)) => {
                Ok(SendMessageResult {
                    message_id: success.message_id,
                    server_timestamp: success
                        .server_timestamp
                        .map(|t| t.seconds)
                        .unwrap_or(0),
                    delivery_status: success.delivery_status,
                })
            }
            Some(crate::proto::messaging::send_message_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Get message history for a conversation
    pub async fn get_messages(
        &self,
        conversation_id: String,
        limit: i32,
    ) -> Result<Vec<IncomingMessage>, GrpcError> {
        debug!(
            "Getting messages for conversation: {}",
            conversation_id
        );

        let request = GetMessagesRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            conversation_user_id: String::new(), // Not used when conversation_id is set
            conversation_id,
            pagination: None,
            limit,
            start_time: None,
            end_time: None,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_messages(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::get_messages_response::Result::Success(success)) => {
                Ok(success
                    .messages
                    .into_iter()
                    .map(|m| IncomingMessage {
                        message_id: m.message_id,
                        sender_user_id: m.sender_user_id,
                        recipient_user_id: m.recipient_user_id,
                        encrypted_content: m.encrypted_content,
                        message_type: m.message_type,
                        client_message_id: m.client_message_id,
                        server_timestamp: m.server_timestamp.map(|t| t.seconds).unwrap_or(0),
                        delivery_status: m.delivery_status,
                        media_id: if m.media_id.is_empty() {
                            None
                        } else {
                            Some(m.media_id)
                        },
                        is_deleted: m.is_deleted,
                        x3dh_prekey: if m.x3dh_prekey.is_empty() {
                            None
                        } else {
                            Some(m.x3dh_prekey)
                        },
                    })
                    .collect())
            }
            Some(crate::proto::messaging::get_messages_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Get list of conversations
    pub async fn get_conversations(&self) -> Result<Vec<ConversationSummary>, GrpcError> {
        debug!("Getting conversations list");

        let request = GetConversationsRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            limit: 50,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_conversations(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::get_conversations_response::Result::Success(success)) => {
                Ok(success
                    .conversations
                    .into_iter()
                    .map(|c| ConversationSummary {
                        conversation_id: c.conversation_id,
                        user_id: c.user_id,
                        username: c.username,
                        unread_count: c.unread_count,
                        last_message_id: c.last_message.as_ref().map(|m| m.message_id.clone()),
                        last_message_preview: None,
                    })
                    .collect())
            }
            Some(crate::proto::messaging::get_conversations_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Mark messages as read
    pub async fn mark_as_read(&self, message_ids: Vec<String>) -> Result<(), GrpcError> {
        debug!("Marking {} messages as read", message_ids.len());

        let request = MarkAsReadRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            message_ids,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .mark_as_read(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("Messages marked as read");
        Ok(())
    }

    /// Delete a message
    pub async fn delete_message(
        &self,
        message_id: String,
        conversation_id: String,
        delete_for_everyone: bool,
    ) -> Result<(), GrpcError> {
        debug!("Deleting message: {}", message_id);

        let request = DeleteMessageRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            message_id,
            conversation_id,
            delete_for_everyone,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .delete_message(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("Message deleted");
        Ok(())
    }

    /// Send typing indicator
    pub async fn send_typing_indicator(&self, recipient_user_id: String, is_typing: bool) -> Result<(), GrpcError> {
        debug!("Sending typing indicator to: {} (typing: {})", recipient_user_id, is_typing);

        let request = TypingIndicatorRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            recipient_user_id,
            is_typing,
            group_id: String::new(), // Empty for 1-on-1 chats
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .send_typing_indicator(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        Ok(())
    }

    /// Create a group
    pub async fn create_group(
        &self,
        group_name: String,
        member_user_ids: Vec<String>,
        mls_group_state: Vec<u8>,
    ) -> Result<String, GrpcError> {
        debug!("Creating group: {} with {} members", group_name, member_user_ids.len());

        let request = CreateGroupRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_name,
            member_user_ids,
            mls_group_state,
            description: String::new(),
            icon_media_id: String::new(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .create_group(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::create_group_response::Result::Success(success)) => {
                info!("Group created: {}", success.group_id);
                Ok(success.group_id)
            }
            Some(crate::proto::messaging::create_group_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Send a group message
    pub async fn send_group_message(
        &self,
        group_id: String,
        encrypted_content: Vec<u8>,
        message_type: i32,
        client_message_id: String,
    ) -> Result<SendMessageResult, GrpcError> {
        debug!("Sending message to group: {}", group_id);

        let request = SendGroupMessageRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id,
            encrypted_content,
            message_type,
            client_message_id,
            client_timestamp: None,
            media_id: String::new(),
            thread_reference: None,
            voice_metadata: None,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .send_group_message(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::send_group_message_response::Result::Success(success)) => {
                Ok(SendMessageResult {
                    message_id: success.message_id,
                    server_timestamp: success
                        .server_timestamp
                        .map(|t| t.seconds)
                        .unwrap_or(0),
                    delivery_status: 1, // Sent
                })
            }
            Some(crate::proto::messaging::send_group_message_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Add reaction to a message
    pub async fn add_reaction(
        &self,
        message_id: String,
        conversation_id: String,
        is_group: bool,
        emoji: String,
    ) -> Result<(), GrpcError> {
        debug!("Adding reaction {} to message {}", emoji, message_id);

        let request = AddReactionRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            message_id,
            conversation_id,
            is_group,
            emoji,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .add_reaction(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("Reaction added");
        Ok(())
    }

    // =========================================================================
    // Group Management Methods
    // =========================================================================

    /// Get all groups for the current user
    pub async fn get_groups(&self, limit: i32) -> Result<Vec<GroupSummary>, GrpcError> {
        debug!("Getting groups list");

        let request = GetGroupsRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            limit,
            cursor: String::new(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_groups(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::get_groups_response::Result::Success(success)) => {
                Ok(success
                    .groups
                    .into_iter()
                    .map(|g| GroupSummary {
                        group_id: g.group_id,
                        name: g.name,
                        member_count: g.member_count as u32,
                        icon_media_id: if g.icon_media_id.is_empty() {
                            None
                        } else {
                            Some(g.icon_media_id)
                        },
                        description: if g.description.is_empty() {
                            None
                        } else {
                            Some(g.description)
                        },
                    })
                    .collect())
            }
            Some(crate::proto::messaging::get_groups_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Get group by ID with full member information
    pub async fn get_group_by_id(&self, group_id: String) -> Result<GroupDetail, GrpcError> {
        debug!("Getting group by ID: {}", group_id);

        let request = GetGroupByIdRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id: group_id.clone(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_group_by_id(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::get_group_by_id_response::Result::Success(success)) => {
                let group = success.group.ok_or_else(|| {
                    GrpcError::RequestFailed("Group not found in response".to_string())
                })?;

                Ok(GroupDetail {
                    group_id: group.group_id,
                    name: group.name,
                    creator_user_id: group.creator_user_id,
                    member_count: group.member_count as u32,
                    icon_media_id: if group.icon_media_id.is_empty() {
                        None
                    } else {
                        Some(group.icon_media_id)
                    },
                    description: if group.description.is_empty() {
                        None
                    } else {
                        Some(group.description)
                    },
                    members: group
                        .members
                        .into_iter()
                        .map(|m| GroupMemberInfo {
                            user_id: m.user_id,
                            username: m.username,
                            display_name: if m.display_name.is_empty() {
                                None
                            } else {
                                Some(m.display_name)
                            },
                            role: m.role,
                            avatar_media_id: if m.avatar_media_id.is_empty() {
                                None
                            } else {
                                Some(m.avatar_media_id)
                            },
                        })
                        .collect(),
                    created_at: group.created_at.map(|t| t.seconds).unwrap_or(0),
                })
            }
            Some(crate::proto::messaging::get_group_by_id_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Get group messages
    pub async fn get_group_messages(
        &self,
        group_id: String,
        limit: i32,
    ) -> Result<Vec<IncomingMessage>, GrpcError> {
        debug!("Getting messages for group: {}", group_id);

        let request = GetGroupMessagesRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id: group_id.clone(),
            limit,
            pagination: None,
            start_time: None,
            end_time: None,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_group_messages(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::get_group_messages_response::Result::Success(success)) => {
                Ok(success
                    .messages
                    .into_iter()
                    .map(|m| IncomingMessage {
                        message_id: m.message_id,
                        sender_user_id: m.sender_user_id,
                        recipient_user_id: group_id.clone(),
                        encrypted_content: m.encrypted_content,
                        message_type: m.message_type,
                        client_message_id: m.client_message_id,
                        server_timestamp: m.server_timestamp.map(|t| t.seconds).unwrap_or(0),
                        delivery_status: 1, // Sent
                        media_id: if m.media_id.is_empty() {
                            None
                        } else {
                            Some(m.media_id)
                        },
                        is_deleted: false,
                        x3dh_prekey: None,
                    })
                    .collect())
            }
            Some(crate::proto::messaging::get_group_messages_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Change a member's role in a group (owner only)
    pub async fn change_member_role(
        &self,
        group_id: String,
        target_user_id: String,
        new_role: String,
    ) -> Result<String, GrpcError> {
        debug!(
            "Changing role of {} to {} in group {}",
            target_user_id, new_role, group_id
        );

        let request = ChangeMemberRoleRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id,
            target_user_id,
            new_role: new_role.clone(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .change_member_role(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::change_member_role_response::Result::Success(success)) => {
                info!("Member role changed to: {}", success.new_role);
                Ok(success.new_role)
            }
            Some(crate::proto::messaging::change_member_role_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Remove a member from a group
    pub async fn remove_group_member(
        &self,
        group_id: String,
        member_user_id: String,
    ) -> Result<bool, GrpcError> {
        debug!("Removing member {} from group {}", member_user_id, group_id);

        let request = RemoveGroupMemberRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id,
            member_user_id,
            mls_group_state: Vec::new(), // MLS state is managed separately
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .remove_group_member(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::remove_group_member_response::Result::Success(success)) => {
                info!("Member removed from group");
                Ok(success.removed)
            }
            Some(crate::proto::messaging::remove_group_member_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Leave a group
    pub async fn leave_group(&self, group_id: String) -> Result<bool, GrpcError> {
        debug!("Leaving group: {}", group_id);

        let request = LeaveGroupRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .leave_group(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::leave_group_response::Result::Success(success)) => {
                info!("Left group");
                Ok(success.left)
            }
            Some(crate::proto::messaging::leave_group_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Update group information
    pub async fn update_group(
        &self,
        group_id: String,
        name: Option<String>,
        description: Option<String>,
        icon_media_id: Option<String>,
    ) -> Result<GroupDetail, GrpcError> {
        debug!("Updating group: {}", group_id);

        let request = UpdateGroupRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id: group_id.clone(),
            name: name.unwrap_or_default(),
            description: description.unwrap_or_default(),
            icon_media_id: icon_media_id.unwrap_or_default(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .update_group(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::update_group_response::Result::Success(success)) => {
                let group = success.group.ok_or_else(|| {
                    GrpcError::RequestFailed("Group not found in response".to_string())
                })?;

                info!("Group updated: {}", group.name);
                Ok(GroupDetail {
                    group_id: group.group_id,
                    name: group.name,
                    creator_user_id: group.creator_user_id,
                    member_count: group.member_count as u32,
                    icon_media_id: if group.icon_media_id.is_empty() {
                        None
                    } else {
                        Some(group.icon_media_id)
                    },
                    description: if group.description.is_empty() {
                        None
                    } else {
                        Some(group.description)
                    },
                    members: group
                        .members
                        .into_iter()
                        .map(|m| GroupMemberInfo {
                            user_id: m.user_id,
                            username: m.username,
                            display_name: if m.display_name.is_empty() {
                                None
                            } else {
                                Some(m.display_name)
                            },
                            role: m.role,
                            avatar_media_id: if m.avatar_media_id.is_empty() {
                                None
                            } else {
                                Some(m.avatar_media_id)
                            },
                        })
                        .collect(),
                    created_at: group.created_at.map(|t| t.seconds).unwrap_or(0),
                })
            }
            Some(crate::proto::messaging::update_group_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Delete a group (owner only)
    pub async fn delete_group(&self, group_id: String) -> Result<bool, GrpcError> {
        debug!("Deleting group {}", group_id);

        let request = DeleteGroupRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            group_id,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .delete_group(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::messaging::delete_group_response::Result::Success(_)) => {
                info!("Group deleted successfully");
                Ok(true)
            }
            Some(crate::proto::messaging::delete_group_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }
}

// =========================================================================
// Group Data Types
// =========================================================================

/// Group summary for list view
#[derive(Debug, Clone)]
pub struct GroupSummary {
    pub group_id: String,
    pub name: String,
    pub member_count: u32,
    pub icon_media_id: Option<String>,
    pub description: Option<String>,
}

/// Group detail with members
#[derive(Debug, Clone)]
pub struct GroupDetail {
    pub group_id: String,
    pub name: String,
    pub creator_user_id: String,
    pub member_count: u32,
    pub icon_media_id: Option<String>,
    pub description: Option<String>,
    pub members: Vec<GroupMemberInfo>,
    pub created_at: i64,
}

/// Group member information
#[derive(Debug, Clone)]
pub struct GroupMemberInfo {
    pub user_id: String,
    pub username: String,
    pub display_name: Option<String>,
    pub role: String,
    pub avatar_media_id: Option<String>,
}
