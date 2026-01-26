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

/// Information about a pending incoming call (before acceptance)
#[derive(Debug, Clone)]
pub struct PendingIncomingCall {
    pub call_id: String,
    pub caller_id: String,
    pub caller_name: String,
    pub call_type: CallType,
    pub received_at: std::time::Instant,
}

/// Call Manager handles all active calls
pub struct CallManager {
    active_calls: Arc<RwLock<HashMap<String, ActiveCall>>>,
    pending_incoming_calls: Arc<RwLock<HashMap<String, PendingIncomingCall>>>,
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
            pending_incoming_calls: Arc::new(RwLock::new(HashMap::new())),
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

        // Subscribe to call events from the server
        self.start_call_events_subscription(call_id.clone()).await;

        info!("Call initiated successfully: {}", call_id);
        Ok(call_id)
    }

    /// Accept an incoming call
    pub async fn accept_call(&self, call_id: String) -> Result<(), CallManagerError> {
        info!("Accepting call: {}", call_id);

        // Get the pending call info (caller_id, call_type, etc.)
        let pending_call = self.pending_incoming_calls.write().remove(&call_id);
        let (remote_user_id, call_type) = match &pending_call {
            Some(pending) => (pending.caller_id.clone(), pending.call_type),
            None => {
                warn!("No pending call info found for call_id: {} - using defaults", call_id);
                (String::new(), CallType::Voice)
            }
        };

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

        let is_video = call_type == CallType::Video;
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
            video_enabled: is_video,
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

        // Store/update the active call with proper caller info
        let active_call = ActiveCall {
            call_id: call_id.clone(),
            call_type,
            remote_user_id,
            state: CallState::Connecting,
            is_outgoing: false,
            started_at: std::time::Instant::now(),
            webrtc_manager,
            sframe_encryptor,
            audio_muted: false,
            video_enabled: is_video,
            screen_sharing: false,
        };

        self.active_calls.write().insert(call_id.clone(), active_call);

        // Emit state changed event
        let _ = self.event_sender.send(CallManagerEvent::StateChanged {
            call_id: call_id.clone(),
            state: CallState::Connecting,
        });

        // Subscribe to call events from the server to receive SDP offer and ICE candidates
        self.start_call_events_subscription(call_id.clone()).await;

        info!("Call accepted: {} - waiting for SDP offer from caller", call_id);
        Ok(())
    }

    /// Reject an incoming call
    pub async fn reject_call(
        &self,
        call_id: String,
        reason: Option<String>,
    ) -> Result<(), CallManagerError> {
        info!("Rejecting call: {} (reason: {:?})", call_id, reason);

        // Remove from pending calls
        self.pending_incoming_calls.write().remove(&call_id);

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

        // Close WebRTC connection (remove from map first to release lock before await)
        let call = self.active_calls.write().remove(&call_id);
        if let Some(active_call) = call {
            active_call.webrtc_manager.close().await;
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

        // Get the WebRTC manager from the call (clone to release lock before await)
        let webrtc_manager = {
            let mut calls = self.active_calls.write();
            if let Some(call) = calls.get_mut(&call_id) {
                call.screen_sharing = enabled;
                Some(call.webrtc_manager.clone())
            } else {
                None
            }
        };

        // Now perform async operation outside of lock
        if let Some(manager) = webrtc_manager {
            manager
                .set_screen_sharing(enabled)
                .await
                .map_err(|e| CallManagerError::WebRtcError(e.to_string()))?;
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

    /// Start listening for call events for an incoming call BEFORE accepting
    /// 
    /// This is specifically for pending incoming calls - it monitors for
    /// CallEnded or CallRejected events which indicate the caller has cancelled.
    fn start_incoming_call_events_subscription(&self, call_id: String) {
        let calls_client = Arc::clone(&self.calls_client);
        let event_sender = self.event_sender.clone();
        let pending_calls = Arc::clone(&self.pending_incoming_calls);

        tauri::async_runtime::spawn(async move {
            info!("Starting incoming call events subscription for pending call: {}", call_id);

            match calls_client.stream_call_events(call_id.clone()).await {
                Ok(mut receiver) => {
                    info!("Incoming call events subscription established for: {}", call_id);

                    while let Some(event) = receiver.recv().await {
                        match event {
                            crate::services::CallEventReceived::StateChanged {
                                call_id: cid,
                                old_state: _,
                                new_state,
                                end_reason,
                            } => {
                                info!(
                                    "Pending call {} state changed to: {} (end_reason: {})",
                                    cid, new_state, end_reason
                                );

                                // Check if call ended or failed (states 6 or 7)
                                if new_state == 6 || new_state == 7 {
                                    // ENDED or FAILED
                                    let reason = match end_reason {
                                        1 => "Normal".to_string(),
                                        2 => "Declined".to_string(),
                                        3 => "Missed".to_string(),
                                        4 => "Busy".to_string(),
                                        5 => "Failed".to_string(),
                                        6 => "Cancelled".to_string(),
                                        _ => "Unknown".to_string(),
                                    };

                                    // Remove from pending calls
                                    pending_calls.write().remove(&cid);

                                    // Emit call ended event to close incoming call dialog
                                    let _ = event_sender.send(CallManagerEvent::CallEnded {
                                        call_id: cid.clone(),
                                        reason,
                                    });

                                    info!("Pending call {} was cancelled by caller", cid);
                                    break;
                                }
                            }
                            crate::services::CallEventReceived::CallEnded { call_id: cid, reason } => {
                                info!("Pending call {} ended with reason: {}", cid, reason);

                                // Remove from pending calls
                                pending_calls.write().remove(&cid);

                                let reason_str = match reason {
                                    1 => "Normal".to_string(),
                                    2 => "Declined".to_string(),
                                    3 => "Missed".to_string(),
                                    4 => "Busy".to_string(),
                                    5 => "Failed".to_string(),
                                    6 => "Cancelled".to_string(),
                                    _ => "Unknown".to_string(),
                                };

                                let _ = event_sender.send(CallManagerEvent::CallEnded {
                                    call_id: cid,
                                    reason: reason_str,
                                });
                                break;
                            }
                            _ => {
                                // Ignore other events (ICE, SDP) for pending calls
                                // These will be handled after accepting
                            }
                        }
                    }

                    info!("Incoming call events subscription ended for: {}", call_id);
                }
                Err(e) => {
                    warn!("Failed to subscribe to call events for incoming call {}: {}", call_id, e);
                }
            }
        });
    }

    /// Start listening for incoming calls
    /// 
    /// This spawns a background task that subscribes to incoming call notifications
    /// from the backend and emits IncomingCall events.
    pub fn start_incoming_calls_subscription(self: Arc<Self>) {
        let manager = Arc::clone(&self);
        
        tauri::async_runtime::spawn(async move {
            info!("Starting incoming calls subscription...");
            
            match manager.calls_client.subscribe_to_incoming_calls().await {
                Ok(mut receiver) => {
                    info!("Incoming calls subscription established");
                    
                    while let Some(notification) = receiver.recv().await {
                        info!(
                            "Received incoming call: call_id={}, from={} ({})",
                            notification.call_id,
                            notification.caller_id,
                            notification.caller_display_name
                        );
                        
                        // Convert call type from proto value
                        let call_type = if notification.call_type == 2 {
                            CallType::Video
                        } else {
                            CallType::Voice
                        };
                        
                        // Store the pending incoming call info for later use when accepting
                        let pending_call = PendingIncomingCall {
                            call_id: notification.call_id.clone(),
                            caller_id: notification.caller_id.clone(),
                            caller_name: notification.caller_display_name.clone(),
                            call_type,
                            received_at: std::time::Instant::now(),
                        };
                        manager.pending_incoming_calls.write().insert(
                            notification.call_id.clone(),
                            pending_call,
                        );
                        
                        // Start listening for call events IMMEDIATELY
                        // This is crucial to detect if the caller cancels the call
                        // before we accept/reject
                        let call_id_for_events = notification.call_id.clone();
                        manager.start_incoming_call_events_subscription(call_id_for_events);
                        
                        // Emit the incoming call event
                        manager.emit_event(CallManagerEvent::IncomingCall {
                            call_id: notification.call_id,
                            caller_id: notification.caller_id,
                            caller_name: notification.caller_display_name,
                            call_type,
                        });
                    }
                    
                    warn!("Incoming calls subscription stream ended");
                }
                Err(e) => {
                    warn!("Failed to subscribe to incoming calls: {}", e);
                }
            }
        });
    }

    /// Start listening for call events for a specific call
    /// 
    /// This spawns a background task that subscribes to call events
    /// from the backend and emits appropriate CallManager events.
    /// 
    /// **Important**: This function processes incoming SDP and ICE candidates
    /// and applies them to the WebRTC peer connection to establish the call.
    async fn start_call_events_subscription(&self, call_id: String) {
        let calls_client = Arc::clone(&self.calls_client);
        let event_sender = self.event_sender.clone();
        let active_calls = Arc::clone(&self.active_calls);

        tauri::async_runtime::spawn(async move {
            info!("Starting call events subscription for call: {}", call_id);

            match calls_client.stream_call_events(call_id.clone()).await {
                Ok(mut receiver) => {
                    info!("Call events subscription established for call: {}", call_id);

                    while let Some(event) = receiver.recv().await {
                        match event {
                            crate::services::CallEventReceived::StateChanged {
                                call_id: cid,
                                old_state,
                                new_state,
                                end_reason,
                            } => {
                                info!(
                                    "Call {} state changed: {} -> {} (end_reason: {})",
                                    cid, old_state, new_state, end_reason
                                );

                                let new_call_state = CallState::from_proto_value(new_state);

                                // Update active call state
                                if let Some(call) = active_calls.write().get_mut(&cid) {
                                    call.state = new_call_state;
                                }

                                // Emit state changed event
                                let _ = event_sender.send(CallManagerEvent::StateChanged {
                                    call_id: cid.clone(),
                                    state: new_call_state,
                                });

                                // If call ended, emit call ended event
                                if new_state == 6 || new_state == 7 {
                                    // ENDED or FAILED
                                    let reason = match end_reason {
                                        1 => "Normal".to_string(),
                                        2 => "Declined".to_string(),
                                        3 => "Missed".to_string(),
                                        4 => "Busy".to_string(),
                                        5 => "Failed".to_string(),
                                        _ => "Unknown".to_string(),
                                    };

                                    // Remove from active calls
                                    active_calls.write().remove(&cid);

                                    let _ = event_sender.send(CallManagerEvent::CallEnded {
                                        call_id: cid,
                                        reason,
                                    });
                                    break;
                                }
                            }
                            crate::services::CallEventReceived::CallEnded { call_id: cid, reason } => {
                                info!("Call {} ended with reason: {}", cid, reason);

                                // Remove from active calls
                                active_calls.write().remove(&cid);

                                let reason_str = match reason {
                                    1 => "Normal".to_string(),
                                    2 => "Declined".to_string(),
                                    3 => "Missed".to_string(),
                                    4 => "Busy".to_string(),
                                    5 => "Failed".to_string(),
                                    _ => "Unknown".to_string(),
                                };

                                let _ = event_sender.send(CallManagerEvent::CallEnded {
                                    call_id: cid,
                                    reason: reason_str,
                                });
                                break;
                            }
                            crate::services::CallEventReceived::IceCandidateReceived {
                                call_id: cid,
                                from_user_id: _,
                                candidate,
                                sdp_mid,
                                sdp_mline_index,
                            } => {
                                debug!("Received ICE candidate for call {}", cid);
                                
                                // Get webrtc_manager clone to avoid holding lock during async
                                let webrtc_manager = active_calls.read().get(&cid)
                                    .map(|call| call.webrtc_manager.clone());
                                
                                // Apply ICE candidate to WebRTC peer connection
                                if let Some(manager) = webrtc_manager {
                                    if let Err(e) = manager.add_ice_candidate(
                                        &candidate,
                                        &sdp_mid,
                                        sdp_mline_index as u32,
                                    ).await {
                                        warn!("Failed to add ICE candidate: {:?}", e);
                                    } else {
                                        debug!("ICE candidate added successfully for call {}", cid);
                                    }
                                }
                                
                                // Also emit event for UI updates
                                let _ = event_sender.send(CallManagerEvent::RemoteIceCandidate {
                                    call_id: cid,
                                    candidate,
                                    sdp_mid,
                                    sdp_mline_index: sdp_mline_index as u32,
                                });
                            }
                            crate::services::CallEventReceived::SdpReceived {
                                call_id: cid,
                                from_user_id: _,
                                sdp_type,
                                sdp,
                            } => {
                                info!("Received SDP for call {} (type: {})", cid, sdp_type);
                                let sdp_type_str = if sdp_type == 1 { "offer" } else { "answer" };
                                
                                // Get call info - clone what we need to avoid holding lock
                                let call_info = active_calls.read().get(&cid).map(|call| {
                                    (call.webrtc_manager.clone(), call.remote_user_id.clone())
                                });
                                
                                if let Some((webrtc_manager, remote_user_id)) = call_info {
                                    if sdp_type == 1 {
                                        // Received OFFER - we are the callee
                                        // Set remote description (the offer)
                                        if let Err(e) = webrtc_manager.set_remote_description(&sdp).await {
                                            warn!("Failed to set remote description: {:?}", e);
                                        } else {
                                            info!("Remote SDP offer set successfully for call {}", cid);
                                            
                                            // Create and send answer
                                            match webrtc_manager.create_answer(&sdp).await {
                                                Ok(answer_sdp) => {
                                                    info!("Created SDP answer for call {}", cid);
                                                    
                                                    // Send answer to caller via backend
                                                    if let Err(e) = calls_client.exchange_sdp(
                                                        cid.clone(),
                                                        remote_user_id,
                                                        2, // ANSWER type
                                                        answer_sdp,
                                                    ).await {
                                                        warn!("Failed to send SDP answer: {:?}", e);
                                                    } else {
                                                        info!("SDP answer sent successfully for call {}", cid);
                                                    }
                                                }
                                                Err(e) => {
                                                    warn!("Failed to create SDP answer: {:?}", e);
                                                }
                                            }
                                        }
                                    } else {
                                        // Received ANSWER - we are the caller
                                        // Just set remote description
                                        if let Err(e) = webrtc_manager.set_remote_description(&sdp).await {
                                            warn!("Failed to set remote description (answer): {:?}", e);
                                        } else {
                                            info!("Remote SDP answer set successfully for call {}", cid);
                                        }
                                    }
                                }
                                
                                // Emit event for UI updates
                                let _ = event_sender.send(CallManagerEvent::RemoteSdp {
                                    call_id: cid,
                                    sdp_type: sdp_type_str.to_string(),
                                    sdp,
                                });
                            }
                        }
                    }

                    info!("Call events subscription ended for call: {}", call_id);
                }
                Err(e) => {
                    warn!("Failed to subscribe to call events for {}: {}", call_id, e);
                }
            }
        });
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
