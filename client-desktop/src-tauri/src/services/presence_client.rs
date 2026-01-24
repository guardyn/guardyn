//! Presence Service gRPC Client
//!
//! Handles user online status, typing indicators, and presence updates.

use crate::grpc::{GrpcClient, GrpcError};
use crate::proto::presence::{
    presence_service_client::PresenceServiceClient, 
    GetBulkStatusRequest, UserStatus,
};
use std::collections::HashMap;
use std::sync::Arc;
use tonic::transport::Channel;
use tonic::Request;
use tracing::{debug, warn};

/// User presence status with additional info
#[derive(Debug, Clone)]
pub struct UserPresenceInfo {
    pub user_id: String,
    pub is_online: bool,
    pub status: UserStatusType,
    pub custom_status_text: Option<String>,
    pub last_seen: Option<i64>,
}

/// User status type
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UserStatusType {
    Offline,
    Online,
    Away,
    DoNotDisturb,
    Invisible,
}

impl From<i32> for UserStatusType {
    fn from(value: i32) -> Self {
        match value {
            1 => UserStatusType::Online,
            2 => UserStatusType::Away,
            3 => UserStatusType::DoNotDisturb,
            4 => UserStatusType::Invisible,
            _ => UserStatusType::Offline,
        }
    }
}

impl UserStatusType {
    /// Check if user should be considered "online" (visible as online to others)
    pub fn is_online(&self) -> bool {
        matches!(self, UserStatusType::Online | UserStatusType::Away | UserStatusType::DoNotDisturb)
    }
}

/// Presence client for Guardyn backend
pub struct PresenceClient {
    grpc: Arc<GrpcClient>,
}

impl PresenceClient {
    /// Create a new presence client with the given gRPC connection manager
    pub fn new(grpc: Arc<GrpcClient>) -> Self {
        Self { grpc }
    }

    /// Create a gRPC client
    async fn client(&self) -> Result<PresenceServiceClient<Channel>, GrpcError> {
        let channel = self.grpc.get_channel().await?;
        Ok(PresenceServiceClient::new(channel))
    }

    /// Get online status for multiple users (bulk query)
    /// 
    /// Returns a HashMap mapping user_id to their online status (true/false)
    pub async fn get_bulk_status(&self, user_ids: Vec<String>) -> Result<HashMap<String, bool>, GrpcError> {
        if user_ids.is_empty() {
            return Ok(HashMap::new());
        }

        debug!("Fetching presence for {} users", user_ids.len());

        let access_token = self.grpc.get_auth_token().unwrap_or_default();
        
        let request = GetBulkStatusRequest {
            access_token,
            user_ids: user_ids.clone(),
        };

        let mut client = self.client().await?;
        let response = client
            .get_bulk_status(Request::new(request))
            .await
            .map_err(|e| {
                warn!("Failed to get bulk presence status: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::presence::get_bulk_status_response::Result::Success(success)) => {
                let mut status_map = HashMap::new();
                
                for presence in success.presences {
                    let status_type = UserStatusType::from(presence.status);
                    // User is online if status is Online, Away, or DoNotDisturb (not Offline or Invisible)
                    let is_online = status_type.is_online();
                    status_map.insert(presence.user_id, is_online);
                }
                
                // Set any users not in response as offline
                for user_id in user_ids {
                    status_map.entry(user_id).or_insert(false);
                }
                
                debug!("Got presence for {} users", status_map.len());
                Ok(status_map)
            }
            Some(crate::proto::presence::get_bulk_status_response::Result::Error(error)) => {
                warn!("Presence bulk status failed: {:?}", error);
                Err(GrpcError::RequestFailed(error.message))
            }
            None => {
                // Return all users as offline if empty response
                Ok(user_ids.into_iter().map(|id| (id, false)).collect())
            }
        }
    }

    /// Get detailed presence info for multiple users
    pub async fn get_bulk_presence_info(&self, user_ids: Vec<String>) -> Result<Vec<UserPresenceInfo>, GrpcError> {
        if user_ids.is_empty() {
            return Ok(Vec::new());
        }

        debug!("Fetching detailed presence for {} users", user_ids.len());

        let access_token = self.grpc.get_auth_token().unwrap_or_default();
        
        let request = GetBulkStatusRequest {
            access_token,
            user_ids: user_ids.clone(),
        };

        let mut client = self.client().await?;
        let response = client
            .get_bulk_status(Request::new(request))
            .await
            .map_err(|e| {
                warn!("Failed to get bulk presence info: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::presence::get_bulk_status_response::Result::Success(success)) => {
                let mut infos: Vec<UserPresenceInfo> = success.presences
                    .into_iter()
                    .map(|p| {
                        let status = UserStatusType::from(p.status);
                        UserPresenceInfo {
                            user_id: p.user_id,
                            is_online: status.is_online(),
                            status,
                            custom_status_text: if p.custom_status_text.is_empty() { 
                                None 
                            } else { 
                                Some(p.custom_status_text) 
                            },
                            last_seen: p.last_seen.map(|ts| ts.seconds),
                        }
                    })
                    .collect();
                
                // Add offline entries for users not in response
                let returned_ids: std::collections::HashSet<_> = 
                    infos.iter().map(|i| i.user_id.clone()).collect();
                
                for user_id in user_ids {
                    if !returned_ids.contains(&user_id) {
                        infos.push(UserPresenceInfo {
                            user_id,
                            is_online: false,
                            status: UserStatusType::Offline,
                            custom_status_text: None,
                            last_seen: None,
                        });
                    }
                }
                
                debug!("Got detailed presence for {} users", infos.len());
                Ok(infos)
            }
            Some(crate::proto::presence::get_bulk_status_response::Result::Error(error)) => {
                warn!("Presence bulk info failed: {:?}", error);
                Err(GrpcError::RequestFailed(error.message))
            }
            None => {
                // Return all users as offline if empty response
                Ok(user_ids.into_iter().map(|id| UserPresenceInfo {
                    user_id: id,
                    is_online: false,
                    status: UserStatusType::Offline,
                    custom_status_text: None,
                    last_seen: None,
                }).collect())
            }
        }
    }
}
