//! Call Commands
//!
//! Handles voice and video calls with WebRTC.

use crate::state::AppState;
use crate::webrtc::{WebRtcConfig, WebRtcManager, SFrameEncryptor};
use serde::{Deserialize, Serialize};
use tauri::State;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CallInfo {
    pub call_id: String,
    pub call_type: String, // "voice" or "video"
    pub caller_id: String,
    pub caller_name: String,
    pub state: String,
    pub started_at: Option<i64>,
    pub duration_seconds: u32,
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

    // Map call type to proto enum
    let call_type = match request.call_type.as_str() {
        "video" => 2, // CALL_TYPE_VIDEO
        _ => 1,       // CALL_TYPE_VOICE
    };

    // Initiate call via gRPC
    let call_result = state.calls().initiate_call(
        request.callee_user_id.clone(),
        call_type,
    ).await
        .map_err(|e| format!("Failed to initiate call: {}", e))?;

    // Generate SFrame encryption key for E2EE
    let _sframe_key = SFrameEncryptor::generate_key();

    // Create WebRTC config with ICE servers from backend
    let webrtc_config = WebRtcConfig {
        ice_servers: call_result.ice_servers.iter().map(|s| {
            crate::webrtc::IceServerConfig {
                urls: s.urls.clone(),
                username: s.username.clone(),
                credential: s.credential.clone(),
            }
        }).collect(),
        audio_enabled: true,
        video_enabled: request.call_type == "video",
        data_channel_enabled: true,
    };

    // Create WebRTC manager
    let webrtc_manager = WebRtcManager::new(webrtc_config);

    // Create SDP offer
    let _sdp_offer = webrtc_manager.create_offer().await
        .map_err(|e| e.to_string())?;

    // TODO: Store webrtc_manager in state for later use
    // TODO: Exchange SDP with backend

    tracing::info!("Call initiated successfully: {}", call_result.call_id);

    Ok(CallResponse {
        success: true,
        call_id: Some(call_result.call_id),
        error: None,
    })
}

/// Accept an incoming call
#[tauri::command]
pub async fn accept_call(
    call_id: String,
    state: State<'_, AppState>,
) -> Result<CallResponse, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::info!("Accepting call: {}", call_id);

    // Accept call via gRPC
    let call_result = state.calls().accept_call(call_id.clone()).await
        .map_err(|e| format!("Failed to accept call: {}", e))?;

    // Create WebRTC config with ICE servers from backend
    let webrtc_config = WebRtcConfig {
        ice_servers: call_result.ice_servers.iter().map(|s| {
            crate::webrtc::IceServerConfig {
                urls: s.urls.clone(),
                username: s.username.clone(),
                credential: s.credential.clone(),
            }
        }).collect(),
        audio_enabled: true,
        video_enabled: true,
        data_channel_enabled: true,
    };

    // Create WebRTC manager
    let _webrtc_manager = WebRtcManager::new(webrtc_config);

    // TODO: Create SDP answer and exchange with backend
    // TODO: Store webrtc_manager in state

    Ok(CallResponse {
        success: true,
        call_id: Some(call_id),
        error: None,
    })
}

/// Reject an incoming call
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

    // Reject call via gRPC
    state.calls().reject_call(
        call_id,
        Some(reason.unwrap_or_else(|| "User declined".to_string())),
    ).await
        .map_err(|e| format!("Failed to reject call: {}", e))?;

    Ok(())
}

/// End an active call
#[tauri::command]
pub async fn end_call(
    call_id: String,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    tracing::info!("Ending call: {}", call_id);

    // End call via gRPC (reason 0 = NORMAL)
    state.calls().end_call(call_id, 0).await
        .map_err(|e| format!("Failed to end call: {}", e))?;

    // TODO: Close WebRTC connection
    Ok(())
}

/// Mute/unmute audio in active call
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

    // Update mute state via gRPC
    state.calls().set_mute(call_id, muted).await
        .map_err(|e| format!("Failed to set mute: {}", e))?;

    Ok(())
}

/// Enable/disable video in active call
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

    // Update video state via gRPC
    state.calls().set_video(call_id, enabled).await
        .map_err(|e| format!("Failed to set video: {}", e))?;

    Ok(())
}

/// Start/stop screen sharing in active call
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

    // TODO: Start/stop screen capture and replace video track
    // For now, just log - actual implementation requires platform-specific capture
    Ok(())
}

/// Get call history
#[tauri::command]
pub async fn get_call_history(
    limit: Option<u32>,
    state: State<'_, AppState>,
) -> Result<Vec<CallInfo>, String> {
    if !state.is_authenticated() {
        return Err("Not authenticated".to_string());
    }

    let limit = limit.unwrap_or(50);
    tracing::debug!("Fetching call history (limit: {})", limit);

    // Fetch from backend via gRPC
    let history = state.calls().get_call_history(limit as i32).await
        .map_err(|e| format!("Failed to get call history: {}", e))?;

    // Convert to CallInfo
    let calls = history.into_iter().map(|entry| {
        CallInfo {
            call_id: entry.call_id,
            call_type: match entry.call_type {
                2 => "video".to_string(),
                _ => "voice".to_string(),
            },
            caller_id: entry.other_user_id,
            caller_name: entry.other_user_name,
            state: "ended".to_string(),
            started_at: Some(entry.started_at),
            duration_seconds: entry.duration_seconds as u32,
        }
    }).collect();

    Ok(calls)
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

    // Get from backend via gRPC
    match state.calls().get_call_state(call_id.clone()).await {
        Ok(call_state) => {
            let state_str = match call_state.state {
                0 => "unknown",
                1 => "ringing",
                2 => "connecting",
                3 => "connected",
                4 => "on_hold",
                5 => "ended",
                _ => "unknown",
            };

            let call_info = CallInfo {
                call_id,
                call_type: match call_state.call_type {
                    2 => "video".to_string(),
                    _ => "voice".to_string(),
                },
                caller_id: call_state.participants.first()
                    .map(|p| p.user_id.clone())
                    .unwrap_or_default(),
                caller_name: call_state.participants.first()
                    .map(|p| p.display_name.clone())
                    .unwrap_or_default(),
                state: state_str.to_string(),
                started_at: Some(call_state.started_at),
                duration_seconds: 0,
            };

            Ok(Some(call_info))
        }
        Err(e) => {
            tracing::warn!("Failed to get call state: {}", e);
            Ok(None)
        }
    }
}
