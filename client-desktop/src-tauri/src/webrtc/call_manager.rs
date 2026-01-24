//! Call Manager - Manages Active Calls
//!
//! Provides a centralized manager for active voice/video calls,
//! coordinating WebRTC peer connections, SFrame encryption, and gRPC signaling.

use std::collections::HashMap;
use std::sync::Arc;

use parking_lot::RwLock;
use tokio::sync::mpsc;
use tracing::{debug, info, warn};

use crate::services::CallsClient;
use crate::webrtc::peer_connection::{WebRtcConfig, WebRtcManager, IceServerConfig};
use crate::webrtc::sframe::SFrameEncryptor;

/// Call type enumeration
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CallType {
    Voice,
    Video,
}

impl CallType {
    pub fn to_proto_value(self) -> i32 {
        match self {
            CallType::Voice => 1,
            CallType::Video => 2,
        }
    }

    pub fn from_string(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "video" => CallType::Video,
            _ => CallType::Voice,
        }
    }
}

/// Call state enumeration
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CallState {
    Initiating,
    Ringing,
    Connecting,
    Connected,
    OnHold,
    Ended,
    Failed,
}

impl CallState {
    pub fn from_proto_value(value: i32) -> Self {
        match value {
            1 => CallState::Initiating,
            2 => CallState::Ringing,
            3 => CallState::Connecting,
            4 => CallState::Connected,
            5 => CallState::OnHold,
            6 => CallState::Ended,
            7 => CallState::Failed,
            _ => CallState::Initiating,
        }
    }
}

/// Active call information
pub struct ActiveCall {
    pub call_id: String,
    pub call_type: CallType,
    pub remote_user_id: String,
    pub state: CallState,
    pub is_outgoing: bool,
    pub started_at: std::time::Instant,
    pub webrtc_manager: WebRtcManager,
    pub sframe_encryptor: SFrameEncryptor,
    pub audio_muted: bool,
    pub video_enabled: bool,
    pub screen_sharing: bool,
}

/// Events emitted by the call manager
#[derive(Debug, Clone)]
pub enum CallManagerEvent {
    /// New incoming call
    IncomingCall {
        call_id: String,
        caller_id: String,
        caller_name: String,
        call_type: CallType,
    },
    /// Call state changed
    StateChanged {
        call_id: String,
        state: CallState,
    },
    /// ICE candidate received from remote peer
    RemoteIceCandidate {
        call_id: String,
        candidate: String,
        sdp_mid: String,
        sdp_mline_index: u32,
    },
    /// Remote SDP received
    RemoteSdp {
        call_id: String,
        sdp_type: String,
        sdp: String,
    },
    /// Remote participant audio/video state changed
    RemoteMediaStateChanged {
        call_id: String,
        user_id: String,
        audio_muted: bool,
        video_enabled: bool,
    },
    /// Call ended
    CallEnded {
        call_id: String,
        reason: String,
    },
    /// Error occurred
    Error {
        call_id: Option<String>,
        message: String,
    },
}

/// Call Manager handles all active calls
pub struct CallManager {
    active_calls: Arc<RwLock<HashMap<String, ActiveCall>>>,
    calls_client: Arc<CallsClient>,
    event_sender: mpsc::UnboundedSender<CallManagerEvent>,
    event_receiver: RwLock<Option<mpsc::UnboundedReceiver<CallManagerEvent>>>,
}

impl CallManager {
    /// Create a new call manager
    pub fn new(calls_client: Arc<CallsClient>) -> Self {
        let (tx, rx) = mpsc::unbounded_channel();
        
        Self {
            active_calls: Arc::new(RwLock::new(HashMap::new())),
            calls_client,
            event_sender: tx,
            event_receiver: RwLock::new(Some(rx)),
        }
    }

    /// Subscribe to call manager events
    pub fn subscribe(&self) -> Option<mpsc::UnboundedReceiver<CallManagerEvent>> {
        self.event_receiver.write().take()
    }

    /// Initiate a new call
    pub async fn initiate_call(
        &self,
        callee_user_id: String,
        call_type: CallType,
    ) -> Result<String, CallManagerError> {
        info!(
            "Initiating {:?} call to user: {}",
            call_type, callee_user_id
        );

        // Call the backend to initiate the call
        let call_response = self
            .calls_client
            .initiate_call(callee_user_id.clone(), call_type.to_proto_value())
            .await
            .map_err(|e| CallManagerError::GrpcError(e.to_string()))?;

        let call_id = call_response.call_id;
        let state = CallState::from_proto_value(call_response.state);

        // Configure WebRTC with ICE servers from backend
        let ice_servers: Vec<IceServerConfig> = call_response
            .ice_servers
            .into_iter()
            .map(|s| IceServerConfig {
                urls: s.urls,
                username: s.username,
                credential: s.credential,
            })
            .collect();

        let webrtc_config = WebRtcConfig {
            ice_servers: if ice_servers.is_empty() {
                vec![IceServerConfig {
                    urls: vec!["stun:stun.l.google.com:19302".to_string()],
                    username: None,
                    credential: None,
                }]
            } else {
                ice_servers
            },
            audio_enabled: true,
            video_enabled: call_type == CallType::Video,
            data_channel_enabled: false,
        };

        // Create WebRTC manager
        let webrtc_manager = WebRtcManager::new(webrtc_config);

        // Create SFrame encryptor with key material from backend
        let sframe_key = if call_response.sframe_key_material.is_empty() {
            SFrameEncryptor::generate_key()
        } else {
            call_response.sframe_key_material
        };
        let sframe_encryptor = SFrameEncryptor::new(sframe_key, call_response.sframe_key_id);

        // Create SDP offer
        let sdp_offer = webrtc_manager
            .create_offer()
            .await
            .map_err(|e| CallManagerError::WebRtcError(e.to_string()))?;

        // Send SDP offer to backend for signaling
        self.calls_client
            .exchange_sdp(
                call_id.clone(),
                callee_user_id.clone(),
                1, // OFFER type
                sdp_offer.clone(),
            )
            .await
            .map_err(|e| CallManagerError::GrpcError(e.to_string()))?;

        // Store the active call
        let active_call = ActiveCall {
            call_id: call_id.clone(),
            call_type,
            remote_user_id: callee_user_id,
            state,
            is_outgoing: true,
            started_at: std::time::Instant::now(),
            webrtc_manager,
            sframe_encryptor,
            audio_muted: false,
            video_enabled: call_type == CallType::Video,
            screen_sharing: false,
        };

        self.active_calls.write().insert(call_id.clone(), active_call);

        // Emit state changed event
        let _ = self.event_sender.send(CallManagerEvent::StateChanged {
            call_id: call_id.clone(),
            state,
        });

        info!("Call initiated successfully: {}", call_id);
        Ok(call_id)
    }

    /// Accept an incoming call
    pub async fn accept_call(&self, call_id: String) -> Result<(), CallManagerError> {
        info!("Accepting call: {}", call_id);

        // Call the backend to accept
        let call_response = self
            .calls_client
            .accept_call(call_id.clone())
            .await
            .map_err(|e| CallManagerError::GrpcError(e.to_string()))?;

        // Configure WebRTC
        let ice_servers: Vec<IceServerConfig> = call_response
            .ice_servers
            .into_iter()
            .map(|s| IceServerConfig {
                urls: s.urls,
                username: s.username,
                credential: s.credential,
            })
            .collect();

        let webrtc_config = WebRtcConfig {
            ice_servers: if ice_servers.is_empty() {
                vec![IceServerConfig {
                    urls: vec!["stun:stun.l.google.com:19302".to_string()],
                    username: None,
                    credential: None,
                }]
            } else {
                ice_servers
            },
            audio_enabled: true,
            video_enabled: true, // Will be adjusted based on call type
            data_channel_enabled: false,
        };

        let webrtc_manager = WebRtcManager::new(webrtc_config);

        // Create SFrame encryptor
        let sframe_key = if call_response.sframe_key_material.is_empty() {
            SFrameEncryptor::generate_key()
        } else {
            call_response.sframe_key_material
        };
        let sframe_encryptor = SFrameEncryptor::new(sframe_key, call_response.sframe_key_id);

        // Store/update the active call
        let active_call = ActiveCall {
            call_id: call_id.clone(),
            call_type: CallType::Voice, // Will be set properly from call info
            remote_user_id: String::new(),
            state: CallState::Connecting,
            is_outgoing: false,
            started_at: std::time::Instant::now(),
            webrtc_manager,
            sframe_encryptor,
            audio_muted: false,
            video_enabled: false,
            screen_sharing: false,
        };

        self.active_calls.write().insert(call_id.clone(), active_call);

        // Emit state changed event
        let _ = self.event_sender.send(CallManagerEvent::StateChanged {
            call_id: call_id.clone(),
            state: CallState::Connecting,
        });

        info!("Call accepted: {}", call_id);
        Ok(())
    }

    /// Reject an incoming call
    pub async fn reject_call(
        &self,
        call_id: String,
        reason: Option<String>,
    ) -> Result<(), CallManagerError> {
        info!("Rejecting call: {} (reason: {:?})", call_id, reason);

        self.calls_client
            .reject_call(call_id.clone(), reason)
            .await
            .map_err(|e| CallManagerError::GrpcError(e.to_string()))?;

        // Remove from active calls if present
        self.active_calls.write().remove(&call_id);

        // Emit call ended event
        let _ = self.event_sender.send(CallManagerEvent::CallEnded {
            call_id,
            reason: "rejected".to_string(),
        });

        Ok(())
    }

    /// End an active call
    pub async fn end_call(&self, call_id: String) -> Result<(), CallManagerError> {
        info!("Ending call: {}", call_id);

        // Close WebRTC connection
        if let Some(call) = self.active_calls.write().remove(&call_id) {
            call.webrtc_manager.close().await;
        }

        // Notify backend
        self.calls_client
            .end_call(call_id.clone(), 1) // COMPLETED reason
            .await
            .map_err(|e| CallManagerError::GrpcError(e.to_string()))?;

        // Emit call ended event
        let _ = self.event_sender.send(CallManagerEvent::CallEnded {
            call_id,
            reason: "completed".to_string(),
        });

        Ok(())
    }

    /// Toggle audio mute
    pub async fn toggle_mute(
        &self,
        call_id: String,
        muted: bool,
    ) -> Result<(), CallManagerError> {
        debug!("Setting mute state: {} for call: {}", muted, call_id);

        // Update local state
        {
            let mut calls = self.active_calls.write();
            if let Some(call) = calls.get_mut(&call_id) {
                call.audio_muted = muted;
                call.webrtc_manager.set_audio_muted(muted);
            }
        }

        // Notify backend
        self.calls_client
            .set_mute(call_id, muted)
            .await
            .map_err(|e| CallManagerError::GrpcError(e.to_string()))?;

        Ok(())
    }

    /// Toggle video
    pub async fn toggle_video(
        &self,
        call_id: String,
        enabled: bool,
    ) -> Result<(), CallManagerError> {
        debug!("Setting video state: {} for call: {}", enabled, call_id);

        // Update local state
        {
            let mut calls = self.active_calls.write();
            if let Some(call) = calls.get_mut(&call_id) {
                call.video_enabled = enabled;
                call.webrtc_manager.set_video_enabled(enabled);
            }
        }

        // Notify backend
        self.calls_client
            .set_video(call_id, enabled)
            .await
            .map_err(|e| CallManagerError::GrpcError(e.to_string()))?;

        Ok(())
    }

    /// Toggle screen sharing
    pub async fn toggle_screen_share(
        &self,
        call_id: String,
        enabled: bool,
    ) -> Result<(), CallManagerError> {
        debug!("Setting screen share: {} for call: {}", enabled, call_id);

        // Update local state and WebRTC
        {
            let mut calls = self.active_calls.write();
            if let Some(call) = calls.get_mut(&call_id) {
                call.screen_sharing = enabled;
                call.webrtc_manager
                    .set_screen_sharing(enabled)
                    .await
                    .map_err(|e| CallManagerError::WebRtcError(e.to_string()))?;
            }
        }

        Ok(())
    }

    /// Add ICE candidate from remote peer
    pub async fn add_ice_candidate(
        &self,
        call_id: String,
        candidate: String,
        sdp_mid: String,
        sdp_mline_index: u32,
    ) -> Result<(), CallManagerError> {
        let calls = self.active_calls.read();
        if let Some(call) = calls.get(&call_id) {
            call.webrtc_manager
                .add_ice_candidate(&candidate, &sdp_mid, sdp_mline_index)
                .await
                .map_err(|e| CallManagerError::WebRtcError(e.to_string()))?;
        }
        Ok(())
    }

    /// Set remote SDP
    pub async fn set_remote_sdp(
        &self,
        call_id: String,
        sdp: String,
    ) -> Result<(), CallManagerError> {
        let calls = self.active_calls.read();
        if let Some(call) = calls.get(&call_id) {
            call.webrtc_manager
                .set_remote_description(&sdp)
                .await
                .map_err(|e| CallManagerError::WebRtcError(e.to_string()))?;
        }
        Ok(())
    }

    /// Get active call by ID
    pub fn get_call(&self, call_id: &str) -> Option<CallInfo> {
        self.active_calls.read().get(call_id).map(|call| CallInfo {
            call_id: call.call_id.clone(),
            call_type: call.call_type,
            remote_user_id: call.remote_user_id.clone(),
            state: call.state,
            is_outgoing: call.is_outgoing,
            duration_seconds: call.started_at.elapsed().as_secs() as u32,
            audio_muted: call.audio_muted,
            video_enabled: call.video_enabled,
            screen_sharing: call.screen_sharing,
        })
    }

    /// Get all active calls
    pub fn get_active_calls(&self) -> Vec<CallInfo> {
        self.active_calls
            .read()
            .values()
            .map(|call| CallInfo {
                call_id: call.call_id.clone(),
                call_type: call.call_type,
                remote_user_id: call.remote_user_id.clone(),
                state: call.state,
                is_outgoing: call.is_outgoing,
                duration_seconds: call.started_at.elapsed().as_secs() as u32,
                audio_muted: call.audio_muted,
                video_enabled: call.video_enabled,
                screen_sharing: call.screen_sharing,
            })
            .collect()
    }

    /// Emit an event
    pub fn emit_event(&self, event: CallManagerEvent) {
        if let Err(e) = self.event_sender.send(event) {
            warn!("Failed to send call manager event: {}", e);
        }
    }
}

/// Call information (safe to share across threads)
#[derive(Debug, Clone)]
pub struct CallInfo {
    pub call_id: String,
    pub call_type: CallType,
    pub remote_user_id: String,
    pub state: CallState,
    pub is_outgoing: bool,
    pub duration_seconds: u32,
    pub audio_muted: bool,
    pub video_enabled: bool,
    pub screen_sharing: bool,
}

/// Call manager errors
#[derive(Debug, thiserror::Error)]
pub enum CallManagerError {
    #[error("gRPC error: {0}")]
    GrpcError(String),

    #[error("WebRTC error: {0}")]
    WebRtcError(String),

    #[error("Call not found: {0}")]
    CallNotFound(String),

    #[error("Invalid state: {0}")]
    InvalidState(String),
}

impl serde::Serialize for CallManagerError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(&self.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_call_type_conversion() {
        assert_eq!(CallType::Voice.to_proto_value(), 1);
        assert_eq!(CallType::Video.to_proto_value(), 2);

        assert_eq!(CallType::from_string("voice"), CallType::Voice);
        assert_eq!(CallType::from_string("video"), CallType::Video);
        assert_eq!(CallType::from_string("VIDEO"), CallType::Video);
    }

    #[test]
    fn test_call_state_conversion() {
        assert_eq!(CallState::from_proto_value(1), CallState::Initiating);
        assert_eq!(CallState::from_proto_value(4), CallState::Connected);
        assert_eq!(CallState::from_proto_value(6), CallState::Ended);
    }
}
