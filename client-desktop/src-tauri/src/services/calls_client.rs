//! Call Service gRPC Client
//!
//! Handles voice/video calls with WebRTC signaling and SFrame E2EE.

use crate::grpc::{GrpcClient, GrpcError};
use crate::proto::calls::{
    call_service_client::CallServiceClient, AcceptCallRequest, EndCallRequest,
    ExchangeIceCandidateRequest, ExchangeSdpRequest, ExchangeSFrameKeyRequest,
    GetCallHistoryRequest, GetCallStateRequest, IceCandidate, InitiateCallRequest,
    ParticipantKeyPackage, RejectCallRequest, SdpMessage, SetMuteRequest, SetVideoRequest,
};
use std::sync::Arc;
use tonic::metadata::MetadataValue;
use tonic::transport::Channel;
use tonic::Request;
use tracing::{debug, info};

/// Call initiation result
#[derive(Debug, Clone)]
pub struct CallInitiated {
    pub call_id: String,
    pub state: i32,
    pub ice_servers: Vec<IceServerInfo>,
    pub sframe_key_material: Vec<u8>,
    pub sframe_key_id: u32,
}

/// ICE server configuration
#[derive(Debug, Clone)]
pub struct IceServerInfo {
    pub urls: Vec<String>,
    pub username: Option<String>,
    pub credential: Option<String>,
}

/// Call state info
#[derive(Debug, Clone)]
pub struct CallStateInfo {
    pub call_id: String,
    pub state: i32,
    pub call_type: i32,
    pub participants: Vec<CallParticipant>,
    pub started_at: i64,
}

/// Call participant
#[derive(Debug, Clone)]
pub struct CallParticipant {
    pub user_id: String,
    pub display_name: String,
    pub is_muted: bool,
    pub has_video: bool,
    pub is_screen_sharing: bool,
    pub is_speaking: bool,
}

/// Call history entry
#[derive(Debug, Clone)]
pub struct CallHistoryEntry {
    pub call_id: String,
    pub call_type: i32,
    pub is_group_call: bool,
    pub group_id: String,
    pub other_user_id: String,
    pub other_user_name: String,
    pub is_outgoing: bool,
    pub end_reason: i32,
    pub started_at: i64,
    pub duration_seconds: i32,
}

/// Call service client
pub struct CallsClient {
    grpc: Arc<GrpcClient>,
}

impl CallsClient {
    /// Create a new calls client
    pub fn new(grpc: Arc<GrpcClient>) -> Self {
        Self { grpc }
    }

    /// Create a gRPC client
    async fn client(&self) -> Result<CallServiceClient<Channel>, GrpcError> {
        let channel = self.grpc.get_channel().await?;
        Ok(CallServiceClient::new(channel))
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

    /// Initiate a call to a user
    pub async fn initiate_call(
        &self,
        user_id: String,
        call_type: i32,
    ) -> Result<CallInitiated, GrpcError> {
        debug!("Initiating call to user: {}", user_id);

        let request = InitiateCallRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            target: Some(crate::proto::calls::initiate_call_request::Target::UserId(
                user_id,
            )),
            call_type,
            capabilities: Some(crate::proto::calls::ClientCapabilities {
                supports_video: true,
                supports_screen_share: true,
                supports_sframe: true,
                supported_codecs: vec!["opus".to_string(), "VP8".to_string()],
                max_video_width: 1920,
                max_video_height: 1080,
                max_video_fps: 30,
            }),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .initiate_call(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::calls::initiate_call_response::Result::Success(success)) => {
                info!("Call initiated: {}", success.call_id);
                Ok(CallInitiated {
                    call_id: success.call_id,
                    state: success.state,
                    ice_servers: success
                        .ice_servers
                        .into_iter()
                        .map(|s| IceServerInfo {
                            urls: s.urls,
                            username: if s.username.is_empty() {
                                None
                            } else {
                                Some(s.username)
                            },
                            credential: if s.credential.is_empty() {
                                None
                            } else {
                                Some(s.credential)
                            },
                        })
                        .collect(),
                    sframe_key_material: success.sframe_key_material,
                    sframe_key_id: success.sframe_key_id,
                })
            }
            Some(crate::proto::calls::initiate_call_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Accept an incoming call
    pub async fn accept_call(&self, call_id: String) -> Result<CallInitiated, GrpcError> {
        debug!("Accepting call: {}", call_id);

        let request = AcceptCallRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id: call_id.clone(),
            capabilities: Some(crate::proto::calls::ClientCapabilities {
                supports_video: true,
                supports_screen_share: true,
                supports_sframe: true,
                supported_codecs: vec!["opus".to_string(), "VP8".to_string()],
                max_video_width: 1920,
                max_video_height: 1080,
                max_video_fps: 30,
            }),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .accept_call(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::calls::accept_call_response::Result::Success(success)) => {
                info!("Call accepted: {}", success.call_id);
                Ok(CallInitiated {
                    call_id: success.call_id,
                    state: success.state,
                    ice_servers: success
                        .ice_servers
                        .into_iter()
                        .map(|s| IceServerInfo {
                            urls: s.urls,
                            username: if s.username.is_empty() {
                                None
                            } else {
                                Some(s.username)
                            },
                            credential: if s.credential.is_empty() {
                                None
                            } else {
                                Some(s.credential)
                            },
                        })
                        .collect(),
                    sframe_key_material: success.sframe_key_material,
                    sframe_key_id: success.sframe_key_id,
                })
            }
            Some(crate::proto::calls::accept_call_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Reject an incoming call
    pub async fn reject_call(&self, call_id: String, reason: Option<String>) -> Result<(), GrpcError> {
        debug!("Rejecting call: {}", call_id);

        let request = RejectCallRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            reason: reason.unwrap_or_default(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .reject_call(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("Call rejected");
        Ok(())
    }

    /// End an active call
    pub async fn end_call(&self, call_id: String, reason: i32) -> Result<(), GrpcError> {
        debug!("Ending call: {} with reason: {}", call_id, reason);

        let request = EndCallRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            reason,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .end_call(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("Call ended");
        Ok(())
    }

    /// Set mute state
    pub async fn set_mute(&self, call_id: String, muted: bool) -> Result<(), GrpcError> {
        debug!("Setting mute: {} for call: {}", muted, call_id);

        let request = SetMuteRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            muted,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .set_mute(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        Ok(())
    }

    /// Set video state
    pub async fn set_video(&self, call_id: String, video_enabled: bool) -> Result<(), GrpcError> {
        debug!("Setting video: {} for call: {}", video_enabled, call_id);

        let request = SetVideoRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            video_enabled,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .set_video(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        Ok(())
    }

    /// Toggle screen sharing state
    pub async fn toggle_screen_share(&self, call_id: String, screen_share_enabled: bool) -> Result<(), GrpcError> {
        debug!("Setting screen share: {} for call: {}", screen_share_enabled, call_id);

        // Screen sharing uses the video track replacement approach
        // The backend needs to know we're sharing screen so other participants can see the indicator
        // For now, we update via the video endpoint with a special flag
        // TODO: Add dedicated ScreenShare RPC when proto is updated

        let request = SetVideoRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            video_enabled: screen_share_enabled, // Screen share replaces video track
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .set_video(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("Screen share state changed: {}", screen_share_enabled);
        Ok(())
    }

    /// Exchange ICE candidate
    pub async fn exchange_ice_candidate(
        &self,
        call_id: String,
        target_user_id: String,
        candidate: String,
        sdp_mid: String,
        sdp_mline_index: i32,
        username_fragment: String,
    ) -> Result<(), GrpcError> {
        debug!("Exchanging ICE candidate for call: {}", call_id);

        let ice_candidate = IceCandidate {
            candidate,
            sdp_mid,
            sdp_mline_index,
            username_fragment,
        };

        let request = ExchangeIceCandidateRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            target_user_id,
            candidate: Some(ice_candidate),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .exchange_ice_candidate(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        Ok(())
    }

    /// Exchange SDP offer/answer
    pub async fn exchange_sdp(
        &self,
        call_id: String,
        target_user_id: String,
        sdp_type: i32,
        sdp: String,
    ) -> Result<(), GrpcError> {
        debug!("Exchanging SDP for call: {}", call_id);

        let sdp_message = SdpMessage {
            r#type: sdp_type,
            sdp,
        };

        let request = ExchangeSdpRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            target_user_id,
            sdp: Some(sdp_message),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .exchange_sdp(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        Ok(())
    }

    /// Exchange SFrame key for call encryption
    /// Sends encrypted key material to multiple participants
    pub async fn exchange_sframe_key(
        &self,
        call_id: String,
        key_packages: Vec<(String, Vec<u8>, u32)>, // (user_id, encrypted_key_material, key_id)
    ) -> Result<(), GrpcError> {
        debug!("Exchanging SFrame key for call: {} with {} participants", call_id, key_packages.len());

        let participant_packages: Vec<ParticipantKeyPackage> = key_packages
            .into_iter()
            .map(|(user_id, encrypted_key_material, key_id)| ParticipantKeyPackage {
                user_id,
                encrypted_key_material,
                key_id,
            })
            .collect();

        let request = ExchangeSFrameKeyRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id,
            key_packages: participant_packages,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .exchange_s_frame_key(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        Ok(())
    }

    /// Get call state
    pub async fn get_call_state(&self, call_id: String) -> Result<CallStateInfo, GrpcError> {
        debug!("Getting call state: {}", call_id);

        let request = GetCallStateRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            call_id: call_id.clone(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_call_state(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::calls::get_call_state_response::Result::Success(success)) => {
                Ok(CallStateInfo {
                    call_id,
                    state: success.state,
                    call_type: success.call_type,
                    participants: success
                        .participants
                        .into_iter()
                        .map(|p| CallParticipant {
                            user_id: p.user_id,
                            display_name: p.display_name,
                            is_muted: p.is_muted,
                            has_video: p.has_video,
                            is_screen_sharing: p.is_screen_sharing,
                            is_speaking: p.is_speaking,
                        })
                        .collect(),
                    started_at: success.started_at.map(|t| t.seconds).unwrap_or(0),
                })
            }
            Some(crate::proto::calls::get_call_state_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Get call history
    pub async fn get_call_history(&self, limit: i32) -> Result<Vec<CallHistoryEntry>, GrpcError> {
        debug!("Getting call history");

        let request = GetCallHistoryRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            limit,
            cursor: String::new(),
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_call_history(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::calls::get_call_history_response::Result::Success(success)) => {
                Ok(success
                    .calls
                    .into_iter()
                    .map(|c| CallHistoryEntry {
                        call_id: c.call_id,
                        call_type: c.call_type,
                        is_group_call: c.is_group_call,
                        group_id: c.group_id,
                        other_user_id: c.other_user_id,
                        other_user_name: c.other_user_name,
                        is_outgoing: c.is_outgoing,
                        end_reason: c.end_reason,
                        started_at: c.started_at.map(|t| t.seconds).unwrap_or(0),
                        duration_seconds: c.duration_seconds,
                    })
                    .collect())
            }
            Some(crate::proto::calls::get_call_history_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }
}
