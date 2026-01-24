//! Call Commands
//!
//! Handles voice and video calls with WebRTC and SFrame E2EE.

use crate::state::AppState;
use crate::webrtc::{CallInfo as WebRtcCallInfo, CallState, CallType};
use serde::{Deserialize, Serialize};
use tauri::State;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CallInfo {
    pub call_id: String,
    pub call_type: String, // "voice" or "video"
    pub remote_user_id: String,
    pub state: String,
    pub is_outgoing: bool,
    pub duration_seconds: u32,
    pub audio_muted: bool,
    pub video_enabled: bool,
    pub screen_sharing: bool,
}

impl From<WebRtcCallInfo> for CallInfo {
    fn from(info: WebRtcCallInfo) -> Self {
        Self {
            call_id: info.call_id,
            call_type: match info.call_type {
                CallType::Voice => "voice".to_string(),
                CallType::Video => "video".to_string(),
            },
            remote_user_id: info.remote_user_id,
            state: match info.state {
                CallState::Initiating => "initiating".to_string(),
                CallState::Ringing => "ringing".to_string(),
                CallState::Connecting => "connecting".to_string(),
                CallState::Connected => "connected".to_string(),
                CallState::OnHold => "on_hold".to_string(),
                CallState::Ended => "ended".to_string(),
                CallState::Failed => "failed".to_string(),
            },
            is_outgoing: info.is_outgoing,
            duration_seconds: info.duration_seconds,
            audio_muted: info.audio_muted,
            video_enabled: info.video_enabled,
            screen_sharing: info.screen_sharing,
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InitiateCallRequest {
    pub callee_user_id: String,
    pub call_type: String, // "voice" or "video"
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CallResponse {
    pub success: bool,
    pub call_id: Option<String>,
    pub error: Option<String>,
}

/// Initiate a voice or video call
///
/// Creates a WebRTC peer connection, generates SFrame keys for E2EE,
/// creates an SDP offer, and sends it to the backend for signaling.
#[tauri::command]
pub async fn initiate_call(
    request: InitiateCallRequest,
    state: State<'_, AppState>,
) -> Result<CallResponse, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::info!(
        "Initiating {} call to user: {}",
        request.call_type,
        request.callee_user_id
    );

    let call_type = CallType::from_string(&request.call_type);

    match state
        .call_manager()
        .initiate_call(request.callee_user_id, call_type)
        .await
    {
        Ok(call_id) => {
            tracing::info!("Call initiated successfully: {}", call_id);
            Ok(CallResponse {
                success: true,
                call_id: Some(call_id),
                error: None,
            })
        }
        Err(e) => {
            tracing::error!("Failed to initiate call: {}", e);
            Ok(CallResponse {
                success: false,
                call_id: None,
                error: Some(e.to_string()),
            })
        }
    }
}

/// Accept an incoming call
///
/// Sets up the local WebRTC peer connection, generates SFrame keys,
/// creates an SDP answer, and sends it back to the caller.
#[tauri::command]
pub async fn accept_call(
    call_id: String,
    state: State<'_, AppState>,
) -> Result<CallResponse, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::info!("Accepting call: {}", call_id);

    match state.call_manager().accept_call(call_id.clone()).await {
        Ok(()) => {
            tracing::info!("Call accepted successfully: {}", call_id);
            Ok(CallResponse {
                success: true,
                call_id: Some(call_id),
                error: None,
            })
        }
        Err(e) => {
            tracing::error!("Failed to accept call: {}", e);
            Ok(CallResponse {
                success: false,
                call_id: None,
                error: Some(e.to_string()),
            })
        }
    }
}

/// Reject an incoming call
///
/// Sends a rejection message to the caller via the backend.
#[tauri::command]
pub async fn reject_call(
    call_id: String,
    reason: Option<String>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::info!("Rejecting call: {} (reason: {:?})", call_id, reason);

    state
        .call_manager()
        .reject_call(call_id, reason)
        .await
        .map_err(|e| e.to_string())
}

/// End an active call
///
/// Closes the WebRTC connection and notifies the backend.
#[tauri::command]
pub async fn end_call(call_id: String, state: State<'_, AppState>) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::info!("Ending call: {}", call_id);

    state
        .call_manager()
        .end_call(call_id)
        .await
        .map_err(|e| e.to_string())
}

/// Mute/unmute audio in active call
///
/// Toggles the local audio track and notifies the backend.
#[tauri::command]
pub async fn toggle_mute(
    call_id: String,
    muted: bool,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Setting mute state: {} for call: {}", muted, call_id);

    state
        .call_manager()
        .toggle_mute(call_id, muted)
        .await
        .map_err(|e| e.to_string())
}

/// Enable/disable video in active call
///
/// Toggles the local video track and notifies the backend.
#[tauri::command]
pub async fn toggle_video(
    call_id: String,
    enabled: bool,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Setting video state: {} for call: {}", enabled, call_id);

    state
        .call_manager()
        .toggle_video(call_id, enabled)
        .await
        .map_err(|e| e.to_string())
}

/// Start/stop screen sharing in active call
///
/// Starts screen capture and replaces the video track with the screen share.
#[tauri::command]
pub async fn toggle_screen_share(
    call_id: String,
    enabled: bool,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Setting screen share: {} for call: {}", enabled, call_id);

    state
        .call_manager()
        .toggle_screen_share(call_id, enabled)
        .await
        .map_err(|e| e.to_string())
}

/// Get call history
#[tauri::command]
pub async fn get_call_history(
    limit: Option<u32>,
    state: State<'_, AppState>,
) -> Result<Vec<CallHistoryEntry>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    let limit = limit.unwrap_or(50);
    tracing::debug!("Fetching call history (limit: {})", limit);

    // Fetch from backend via gRPC
    match state.calls().get_call_history(limit as i32).await {
        Ok(entries) => Ok(entries
            .into_iter()
            .map(|e| CallHistoryEntry {
                call_id: e.call_id,
                call_type: if e.call_type == 2 { "video" } else { "voice" }.to_string(),
                is_group_call: e.is_group_call,
                group_id: e.group_id,
                other_user_id: e.other_user_id,
                other_user_name: e.other_user_name,
                is_outgoing: e.is_outgoing,
                end_reason: e.end_reason,
                started_at: e.started_at,
                duration_seconds: e.duration_seconds as u32,
            })
            .collect()),
        Err(e) => {
            tracing::error!("Failed to fetch call history: {}", e);
            Err(e.to_string())
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CallHistoryEntry {
    pub call_id: String,
    pub call_type: String,
    pub is_group_call: bool,
    pub group_id: String,
    pub other_user_id: String,
    pub other_user_name: String,
    pub is_outgoing: bool,
    pub end_reason: i32,
    pub started_at: i64,
    pub duration_seconds: u32,
}

/// Get current call state
#[tauri::command]
pub async fn get_call_state(
    call_id: String,
    state: State<'_, AppState>,
) -> Result<Option<CallInfo>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Getting state for call: {}", call_id);

    // First check local active calls
    if let Some(info) = state.call_manager().get_call(&call_id) {
        return Ok(Some(info.into()));
    }

    // Fall back to backend
    match state.calls().get_call_state(call_id).await {
        Ok(call_state) => Ok(Some(CallInfo {
            call_id: call_state.call_id,
            call_type: if call_state.call_type == 2 {
                "video"
            } else {
                "voice"
            }
            .to_string(),
            remote_user_id: call_state
                .participants
                .first()
                .map(|p| p.user_id.clone())
                .unwrap_or_default(),
            state: match call_state.state {
                1 => "initiating",
                2 => "ringing",
                3 => "connecting",
                4 => "connected",
                5 => "on_hold",
                6 => "ended",
                7 => "failed",
                _ => "unknown",
            }
            .to_string(),
            is_outgoing: false, // Not available from backend
            duration_seconds: 0,
            audio_muted: call_state
                .participants
                .first()
                .map(|p| p.is_muted)
                .unwrap_or(false),
            video_enabled: call_state
                .participants
                .first()
                .map(|p| p.has_video)
                .unwrap_or(false),
            screen_sharing: call_state
                .participants
                .first()
                .map(|p| p.is_screen_sharing)
                .unwrap_or(false),
        })),
        Err(e) => {
            tracing::warn!("Failed to get call state: {}", e);
            Ok(None)
        }
    }
}

/// Get all active calls
#[tauri::command]
pub async fn get_active_calls(state: State<'_, AppState>) -> Result<Vec<CallInfo>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    Ok(state
        .call_manager()
        .get_active_calls()
        .into_iter()
        .map(CallInfo::from)
        .collect())
}

/// Add ICE candidate from remote peer (for WebRTC signaling)
#[tauri::command]
pub async fn add_ice_candidate(
    call_id: String,
    candidate: String,
    sdp_mid: String,
    sdp_mline_index: u32,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Adding ICE candidate for call: {}", call_id);

    state
        .call_manager()
        .add_ice_candidate(call_id, candidate, sdp_mid, sdp_mline_index)
        .await
        .map_err(|e| e.to_string())
}

/// Set remote SDP (for WebRTC signaling)
#[tauri::command]
pub async fn set_remote_sdp(
    call_id: String,
    sdp: String,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::debug!("Setting remote SDP for call: {}", call_id);

    state
        .call_manager()
        .set_remote_sdp(call_id, sdp)
        .await
        .map_err(|e| e.to_string())
}
