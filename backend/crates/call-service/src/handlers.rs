//! Request handlers for Call Service

use anyhow::Result;
use chrono::Utc;
use tracing::{debug, info, warn};

use crate::auth_client::AuthClient;
use crate::db::{CallDb, CallParticipantRecord, CallRecord, UserCallHistoryEntry};
use crate::generated::guardyn::calls::*;
use crate::nats::{CallEventEnvelope, CallEventType, CallNatsClient, IncomingCallEnvelope};
use crate::session::{CallSessionManager, SessionParticipant};
use crate::IceServerConfig;

/// Validate JWT token and extract user ID
pub fn validate_token(token: &str, jwt_secret: &str) -> Result<String, i32> {
    use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
    use serde::Deserialize;

    #[derive(Debug, Deserialize)]
    struct Claims {
        sub: String,
        exp: i64,
    }

    let token_data = decode::<Claims>(
        token,
        &DecodingKey::from_secret(jwt_secret.as_bytes()),
        &Validation::new(Algorithm::HS256),
    )
    .map_err(|_| 2)?; // Unauthorized

    Ok(token_data.claims.sub)
}

/// Create error response
fn error_response(code: i32, message: &str) -> crate::generated::guardyn::common::ErrorResponse {
    crate::generated::guardyn::common::ErrorResponse {
        code,
        message: message.to_string(),
        details: std::collections::HashMap::new(),
    }
}

/// Convert IceServerConfig to proto IceServer
fn to_proto_ice_servers(configs: &[IceServerConfig]) -> Vec<IceServer> {
    configs
        .iter()
        .map(|c| IceServer {
            urls: c.urls.clone(),
            username: c.username.clone().unwrap_or_default(),
            credential: c.credential.clone().unwrap_or_default(),
        })
        .collect()
}

/// Convert SessionParticipant to proto CallParticipant
fn to_proto_participant(p: &SessionParticipant) -> CallParticipant {
    CallParticipant {
        user_id: p.user_id.clone(),
        display_name: p.display_name.clone(),
        is_muted: p.is_muted,
        has_video: p.has_video,
        is_screen_sharing: p.is_screen_sharing,
        is_speaking: p.is_speaking,
        joined_at: Some(crate::generated::guardyn::common::Timestamp {
            seconds: p.joined_at.timestamp(),
            nanos: 0,
        }),
    }
}

/// Handle call initiation
pub async fn initiate_call(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    nats_client: &CallNatsClient,
    request: InitiateCallRequest,
    jwt_secret: &str,
    ice_servers: &[IceServerConfig],
    auth_service_url: &str,
) -> InitiateCallResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return InitiateCallResponse {
                result: Some(initiate_call_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    // Check if user is already in a call
    if session_mgr.is_user_in_call(&user_id) {
        return InitiateCallResponse {
            result: Some(initiate_call_response::Result::Error(error_response(
                1,
                "Already in a call",
            ))),
        };
    }

    // Get target user ID for 1-on-1 calls
    let target_user_id = match &request.target {
        Some(initiate_call_request::Target::UserId(uid)) => Some(uid.clone()),
        _ => None,
    };

    // Get display name from auth service
    let display_name = match AuthClient::new(auth_service_url).await {
        Ok(mut client) => client.get_display_name(&user_id).await,
        Err(e) => {
            warn!("Failed to connect to auth service: {}, using user_id as display name", e);
            user_id.clone()
        }
    };

    // Determine if this is a group call
    let (is_group, group_id) = match &request.target {
        Some(initiate_call_request::Target::GroupId(gid)) => (true, Some(gid.clone())),
        Some(initiate_call_request::Target::UserId(_)) => (false, None),
        None => {
            return InitiateCallResponse {
                result: Some(initiate_call_response::Result::Error(error_response(
                    1,
                    "Target user or group is required",
                ))),
            };
        }
    };

    // Create session
    let (call_id, sframe_key_id, sframe_key) = session_mgr.create_session(
        request.call_type,
        is_group,
        group_id.clone(),
        &user_id,
        &display_name,
    );

    // Persist to database
    let call_record = CallRecord {
        call_id: call_id.clone(),
        call_type: request.call_type,
        is_group_call: is_group,
        group_id: group_id.clone(),
        initiator_id: user_id.clone(),
        state: 1, // INITIATING
        end_reason: None,
        created_at: Utc::now(),
        started_at: None,
        ended_at: None,
        duration_seconds: 0,
    };

    if let Err(e) = db.create_call(&call_record).await {
        warn!("Failed to persist call: {}", e);
    }

    // Add initiator as participant
    let participant = CallParticipantRecord {
        call_id: call_id.clone(),
        user_id: user_id.clone(),
        display_name: display_name.clone(),
        is_muted: false,
        has_video: request.call_type == 2,
        is_screen_sharing: false,
        joined_at: Utc::now(),
        left_at: None,
    };

    if let Err(e) = db.add_participant(&participant).await {
        warn!("Failed to persist participant: {}", e);
    }

    // Notify callee about incoming call (for 1-on-1 calls)
    if let Some(ref target_uid) = target_user_id {
        let incoming_envelope = IncomingCallEnvelope {
            call_id: call_id.clone(),
            call_type: request.call_type,
            is_group_call: false,
            group_id: None,
            caller_id: user_id.clone(),
            caller_display_name: display_name.clone(),
            caller_avatar_url: None, // TODO: Get from auth service
            timestamp: Utc::now().timestamp(),
        };

        info!(
            "Publishing incoming call notification to NATS: call_id={}, caller={}, callee={}",
            call_id, user_id, target_uid
        );

        if let Err(e) = nats_client.publish_incoming_call(target_uid, &incoming_envelope).await {
            warn!("Failed to notify callee about incoming call: {}", e);
        } else {
            info!(
                "Successfully published incoming call notification: call_id={}, callee={}",
                call_id, target_uid
            );
            // Update state to RINGING after successfully notifying callee
            session_mgr.update_state(&call_id, 2); // RINGING = 2
            if let Err(e) = db.update_call_state(&call_id, 2).await {
                warn!("Failed to update call state to RINGING: {}", e);
            }
            info!("Call {} state updated to RINGING", call_id);
        }
    }

    // Get current state (may be RINGING if callee was notified)
    let current_state = session_mgr
        .get_session(&call_id)
        .map(|s| s.read().state)
        .unwrap_or(1); // Default to INITIATING

    debug!("Created call {} initiated by {} with state {}", call_id, user_id, current_state);

    InitiateCallResponse {
        result: Some(initiate_call_response::Result::Success(InitiateCallSuccess {
            call_id,
            state: current_state,
            created_at: Some(crate::generated::guardyn::common::Timestamp {
                seconds: Utc::now().timestamp(),
                nanos: 0,
            }),
            ice_servers: to_proto_ice_servers(ice_servers),
            sframe_key_material: sframe_key,
            sframe_key_id,
        })),
    }
}

/// Handle call accept
pub async fn accept_call(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    nats_client: &CallNatsClient,
    request: AcceptCallRequest,
    jwt_secret: &str,
    ice_servers: &[IceServerConfig],
    auth_service_url: &str,
) -> AcceptCallResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return AcceptCallResponse {
                result: Some(accept_call_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    // Get display name from auth service
    let display_name = match AuthClient::new(auth_service_url).await {
        Ok(mut client) => client.get_display_name(&user_id).await,
        Err(e) => {
            warn!("Failed to connect to auth service: {}, using user_id as display name", e);
            user_id.clone()
        }
    };

    // Check if call exists
    let session = match session_mgr.get_session(&request.call_id) {
        Some(s) => s,
        None => {
            return AcceptCallResponse {
                result: Some(accept_call_response::Result::Error(error_response(
                    3,
                    "Call not found",
                ))),
            };
        }
    };

    // Add participant to session
    let has_video = request
        .capabilities
        .as_ref()
        .map(|c| c.supports_video)
        .unwrap_or(false);

    let (sframe_key_id, sframe_key) = match session_mgr.add_participant(
        &request.call_id,
        &user_id,
        &display_name,
        has_video,
    ) {
        Some(keys) => keys,
        None => {
            return AcceptCallResponse {
                result: Some(accept_call_response::Result::Error(error_response(
                    4,
                    "Failed to join call",
                ))),
            };
        }
    };

    // Update call state to CONNECTING
    session_mgr.update_state(&request.call_id, 3);

    // Persist participant
    let participant = CallParticipantRecord {
        call_id: request.call_id.clone(),
        user_id: user_id.clone(),
        display_name: display_name.clone(),
        is_muted: false,
        has_video,
        is_screen_sharing: false,
        joined_at: Utc::now(),
        left_at: None,
    };

    if let Err(e) = db.add_participant(&participant).await {
        warn!("Failed to persist participant: {}", e);
    }

    if let Err(e) = db.update_call_state(&request.call_id, 3).await {
        warn!("Failed to update call state: {}", e);
    }

    // Notify caller that call was accepted
    let caller_id = {
        let session_guard = session.read();
        session_guard.participants.values()
            .find(|p| p.user_id != user_id)
            .map(|p| p.user_id.clone())
    };

    if let Some(caller) = caller_id {
        let event = CallEventEnvelope {
            call_id: request.call_id.clone(),
            event_type: CallEventType::CallAccepted,
            payload: serde_json::json!({
                "accepter_id": user_id,
                "accepter_display_name": display_name,
            }),
            timestamp: Utc::now().timestamp(),
        };

        if let Err(e) = nats_client.publish_call_event(&event).await {
            warn!("Failed to publish CallAccepted event: {}", e);
        } else {
            debug!("Published CallAccepted event for caller {}", caller);
        }
    }

    debug!("User {} accepted call {}", user_id, request.call_id);

    AcceptCallResponse {
        result: Some(accept_call_response::Result::Success(AcceptCallSuccess {
            call_id: request.call_id,
            state: CallState::Connecting as i32,
            ice_servers: to_proto_ice_servers(ice_servers),
            sframe_key_material: sframe_key,
            sframe_key_id,
        })),
    }
}

/// Handle call reject
pub async fn reject_call(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    nats_client: &CallNatsClient,
    request: RejectCallRequest,
    jwt_secret: &str,
) -> RejectCallResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return RejectCallResponse {
                result: Some(reject_call_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    // Get the session to find the caller user ID (initiator)
    let caller_id = session_mgr.get_session(&request.call_id)
        .map(|s| {
            let session = s.read();
            // Find another participant who is not the one rejecting
            session.participants.values()
                .find(|p| p.user_id != user_id)
                .map(|p| p.user_id.clone())
                .or_else(|| {
                    // If not found in participants, use initiator_id
                    if session.initiator_id != user_id {
                        Some(session.initiator_id.clone())
                    } else {
                        None
                    }
                })
        })
        .flatten();

    // End the session with DECLINED reason
    if let Some(_session) = session_mgr.end_session(&request.call_id) {
        if let Err(e) = db.end_call(&request.call_id, 2, 0).await {
            // DECLINED
            warn!("Failed to update call: {}", e);
        }
    }

    // Notify the caller that the call was rejected
    if let Some(caller) = caller_id {
        let event = crate::nats::CallEventEnvelope {
            call_id: request.call_id.clone(),
            event_type: crate::nats::CallEventType::CallRejected,
            payload: serde_json::json!({
                "rejected_by": user_id,
                "reason": if request.reason.is_empty() { "declined".to_string() } else { request.reason.clone() }
            }),
            timestamp: chrono::Utc::now().timestamp(),
        };
        if let Err(e) = nats_client.publish_call_event(&event).await {
            warn!("Failed to publish call rejected event: {}", e);
        }
        debug!("Published call rejected event to caller {}", caller);
    }

    debug!("User {} rejected call {}", user_id, request.call_id);

    RejectCallResponse {
        result: Some(reject_call_response::Result::Success(RejectCallSuccess {
            rejected: true,
        })),
    }
}

/// Handle call end
pub async fn end_call(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    nats_client: &CallNatsClient,
    request: EndCallRequest,
    jwt_secret: &str,
) -> EndCallResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return EndCallResponse {
                result: Some(end_call_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    let duration = session_mgr.get_duration(&request.call_id);

    // End the session
    if let Some(session) = session_mgr.end_session(&request.call_id) {
        // Persist to database
        if let Err(e) = db.end_call(&request.call_id, request.reason, duration).await {
            warn!("Failed to update call: {}", e);
        }

        // Collect participant IDs first to avoid borrow issues
        let participant_ids: Vec<String> = session.participants.keys().cloned().collect();

        // Publish CallEnded event to notify all participants
        let event = CallEventEnvelope {
            call_id: request.call_id.clone(),
            event_type: CallEventType::CallEnded,
            payload: serde_json::json!({
                "ended_by": user_id,
                "end_reason": request.reason,
                "duration_seconds": duration,
            }),
            timestamp: Utc::now().timestamp(),
        };

        if let Err(e) = nats_client.publish_call_event(&event).await {
            warn!("Failed to publish CallEnded event: {}", e);
        } else {
            info!("Published CallEnded event for call {}", request.call_id);
        }

        // Add to call history for all participants
        for participant_id in &participant_ids {
            let other_user_id = if session.is_group_call {
                None
            } else {
                Some(if participant_id == &session.initiator_id {
                    // Find the other participant
                    participant_ids
                        .iter()
                        .find(|&k| k != participant_id)
                        .cloned()
                        .unwrap_or_default()
                } else {
                    session.initiator_id.clone()
                })
            };

            let entry = UserCallHistoryEntry {
                user_id: participant_id.clone(),
                call_id: request.call_id.clone(),
                call_type: session.call_type,
                is_group_call: session.is_group_call,
                group_id: session.group_id.clone(),
                other_user_id,
                other_user_name: None,
                is_outgoing: participant_id == &session.initiator_id,
                end_reason: request.reason,
                started_at: session.started_at.unwrap_or(session.created_at),
                duration_seconds: duration,
            };

            if let Err(e) = db.add_to_call_history(&entry).await {
                warn!("Failed to add call history for {}: {}", participant_id, e);
            }
        }
    }

    debug!("User {} ended call {}", user_id, request.call_id);

    EndCallResponse {
        result: Some(end_call_response::Result::Success(EndCallSuccess {
            ended: true,
            duration_seconds: duration,
        })),
    }
}

/// Handle join call (for group calls)
pub async fn join_call(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    request: JoinCallRequest,
    jwt_secret: &str,
    ice_servers: &[IceServerConfig],
    auth_service_url: &str,
) -> JoinCallResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return JoinCallResponse {
                result: Some(join_call_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    // Get display name from auth service
    let display_name = match AuthClient::new(auth_service_url).await {
        Ok(mut client) => client.get_display_name(&user_id).await,
        Err(e) => {
            warn!("Failed to connect to auth service: {}, using user_id as display name", e);
            user_id.clone()
        }
    };

    // Check if call exists and is a group call
    let session = match session_mgr.get_session(&request.call_id) {
        Some(s) => s,
        None => {
            return JoinCallResponse {
                result: Some(join_call_response::Result::Error(error_response(
                    3,
                    "Call not found",
                ))),
            };
        }
    };

    let is_group = {
        let s = session.read();
        s.is_group_call
    };

    if !is_group {
        return JoinCallResponse {
            result: Some(join_call_response::Result::Error(error_response(
                1,
                "Cannot join 1-on-1 call",
            ))),
        };
    }

    // Add participant
    let has_video = request
        .capabilities
        .as_ref()
        .map(|c| c.supports_video)
        .unwrap_or(false);

    let (sframe_key_id, sframe_key) = match session_mgr.add_participant(
        &request.call_id,
        &user_id,
        &display_name,
        has_video,
    ) {
        Some(keys) => keys,
        None => {
            return JoinCallResponse {
                result: Some(join_call_response::Result::Error(error_response(
                    4,
                    "Failed to join call",
                ))),
            };
        }
    };

    // Get current participants
    let participants: Vec<CallParticipant> = session_mgr
        .get_participants(&request.call_id)
        .iter()
        .map(to_proto_participant)
        .collect();

    // Persist
    let participant = CallParticipantRecord {
        call_id: request.call_id.clone(),
        user_id: user_id.clone(),
        display_name: display_name.clone(),
        is_muted: false,
        has_video,
        is_screen_sharing: false,
        joined_at: Utc::now(),
        left_at: None,
    };

    if let Err(e) = db.add_participant(&participant).await {
        warn!("Failed to persist participant: {}", e);
    }

    debug!("User {} joined call {}", user_id, request.call_id);

    JoinCallResponse {
        result: Some(join_call_response::Result::Success(JoinCallSuccess {
            call_id: request.call_id,
            state: CallState::Connected as i32,
            participants,
            ice_servers: to_proto_ice_servers(ice_servers),
            sframe_key_material: sframe_key,
            sframe_key_id,
        })),
    }
}

/// Handle leave call
pub async fn leave_call(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    request: LeaveCallRequest,
    jwt_secret: &str,
) -> LeaveCallResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return LeaveCallResponse {
                result: Some(leave_call_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    // Remove from session
    session_mgr.remove_participant(&request.call_id, &user_id);

    // Persist
    if let Err(e) = db.participant_left(&request.call_id, &user_id).await {
        warn!("Failed to update participant: {}", e);
    }

    debug!("User {} left call {}", user_id, request.call_id);

    LeaveCallResponse {
        result: Some(leave_call_response::Result::Success(LeaveCallSuccess {
            left: true,
        })),
    }
}

/// Handle set mute
pub async fn set_mute(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    request: SetMuteRequest,
    jwt_secret: &str,
) -> SetMuteResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return SetMuteResponse {
                result: Some(set_mute_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    session_mgr.update_mute(&request.call_id, &user_id, request.muted);

    if let Err(e) = db
        .update_participant_mute(&request.call_id, &user_id, request.muted)
        .await
    {
        warn!("Failed to update mute: {}", e);
    }

    SetMuteResponse {
        result: Some(set_mute_response::Result::Success(SetMuteSuccess {
            muted: request.muted,
        })),
    }
}

/// Handle set video
pub async fn set_video(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    request: SetVideoRequest,
    jwt_secret: &str,
) -> SetVideoResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return SetVideoResponse {
                result: Some(set_video_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    session_mgr.update_video(&request.call_id, &user_id, request.video_enabled);

    if let Err(e) = db
        .update_participant_video(&request.call_id, &user_id, request.video_enabled)
        .await
    {
        warn!("Failed to update video: {}", e);
    }

    SetVideoResponse {
        result: Some(set_video_response::Result::Success(SetVideoSuccess {
            video_enabled: request.video_enabled,
        })),
    }
}

/// Handle set screen share
pub async fn set_screen_share(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    request: SetScreenShareRequest,
    jwt_secret: &str,
) -> SetScreenShareResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return SetScreenShareResponse {
                result: Some(set_screen_share_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    session_mgr.update_screen_share(&request.call_id, &user_id, request.screen_share_enabled);

    if let Err(e) = db
        .update_participant_screen_share(&request.call_id, &user_id, request.screen_share_enabled)
        .await
    {
        warn!("Failed to update screen share: {}", e);
    }

    SetScreenShareResponse {
        result: Some(set_screen_share_response::Result::Success(
            SetScreenShareSuccess {
                screen_share_enabled: request.screen_share_enabled,
            },
        )),
    }
}

/// Handle get call state
pub async fn get_call_state(
    db: &CallDb,
    session_mgr: &CallSessionManager,
    request: GetCallStateRequest,
    jwt_secret: &str,
) -> GetCallStateResponse {
    let _user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return GetCallStateResponse {
                result: Some(get_call_state_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    // Try to get from session manager first
    if let Some(session) = session_mgr.get_session(&request.call_id) {
        let session = session.read();
        let participants: Vec<CallParticipant> = session
            .participants
            .values()
            .map(to_proto_participant)
            .collect();

        let duration = session
            .started_at
            .map(|s| (Utc::now() - s).num_seconds() as i32)
            .unwrap_or(0);

        return GetCallStateResponse {
            result: Some(get_call_state_response::Result::Success(
                GetCallStateSuccess {
                    call_id: session.call_id.clone(),
                    call_type: session.call_type,
                    state: session.state,
                    is_group_call: session.is_group_call,
                    initiator_id: session.initiator_id.clone(),
                    participants,
                    started_at: session.started_at.map(|t| {
                        crate::generated::guardyn::common::Timestamp {
                            seconds: t.timestamp(),
                            nanos: 0,
                        }
                    }),
                    duration_seconds: duration,
                },
            )),
        };
    }

    // Fall back to database
    match db.get_call(&request.call_id).await {
        Ok(Some(call)) => {
            let participants = db
                .get_call_participants(&request.call_id)
                .await
                .unwrap_or_default();

            GetCallStateResponse {
                result: Some(get_call_state_response::Result::Success(
                    GetCallStateSuccess {
                        call_id: call.call_id,
                        call_type: call.call_type,
                        state: call.state,
                        is_group_call: call.is_group_call,
                        initiator_id: call.initiator_id,
                        participants: participants
                            .into_iter()
                            .map(|p| CallParticipant {
                                user_id: p.user_id,
                                display_name: p.display_name,
                                is_muted: p.is_muted,
                                has_video: p.has_video,
                                is_screen_sharing: p.is_screen_sharing,
                                is_speaking: false,
                                joined_at: Some(crate::generated::guardyn::common::Timestamp {
                                    seconds: p.joined_at.timestamp(),
                                    nanos: 0,
                                }),
                            })
                            .collect(),
                        started_at: call.started_at.map(|t| {
                            crate::generated::guardyn::common::Timestamp {
                                seconds: t.timestamp(),
                                nanos: 0,
                            }
                        }),
                        duration_seconds: call.duration_seconds,
                    },
                )),
            }
        }
        Ok(None) => GetCallStateResponse {
            result: Some(get_call_state_response::Result::Error(error_response(
                3,
                "Call not found",
            ))),
        },
        Err(e) => {
            warn!("Failed to get call state: {}", e);
            GetCallStateResponse {
                result: Some(get_call_state_response::Result::Error(error_response(
                    4,
                    "Failed to get call state",
                ))),
            }
        }
    }
}

/// Handle get call history
pub async fn get_call_history(
    db: &CallDb,
    request: GetCallHistoryRequest,
    jwt_secret: &str,
) -> GetCallHistoryResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return GetCallHistoryResponse {
                result: Some(get_call_history_response::Result::Error(error_response(
                    2,
                    "Invalid or expired token",
                ))),
            };
        }
    };

    let limit = if request.limit > 0 && request.limit <= 100 { 
        request.limit 
    } else { 
        50 
    };

    // Parse cursor - format: "ts:{timestamp_millis}"
    let before_timestamp: Option<i64> = if request.cursor.is_empty() {
        None
    } else if let Some(ts_str) = request.cursor.strip_prefix("ts:") {
        ts_str.parse().ok()
    } else {
        None
    };

    // Fetch limit + 1 to determine if there are more results
    match db.get_call_history(&user_id, limit + 1, before_timestamp).await {
        Ok(history) => {
            // Check if there are more results
            let has_more = history.len() > limit as usize;

            // Take only the requested limit
            let history_limited: Vec<_> = history.into_iter().take(limit as usize).collect();
            
            // Get the timestamp of the last entry for the cursor
            let last_timestamp = history_limited.last().map(|h| h.started_at.timestamp_millis());

            let calls: Vec<CallHistoryEntry> = history_limited
                .into_iter()
                .map(|h| CallHistoryEntry {
                    call_id: h.call_id,
                    call_type: h.call_type,
                    is_group_call: h.is_group_call,
                    group_id: h.group_id.unwrap_or_default(),
                    other_user_id: h.other_user_id.unwrap_or_default(),
                    other_user_name: h.other_user_name.unwrap_or_default(),
                    is_outgoing: h.is_outgoing,
                    end_reason: h.end_reason,
                    started_at: Some(crate::generated::guardyn::common::Timestamp {
                        seconds: h.started_at.timestamp(),
                        nanos: 0,
                    }),
                    duration_seconds: h.duration_seconds,
                })
                .collect();

            // Generate next cursor using the timestamp of the last entry
            let next_cursor = if has_more {
                last_timestamp
                    .map(|ts| format!("ts:{}", ts))
                    .unwrap_or_default()
            } else {
                String::new()
            };

            GetCallHistoryResponse {
                result: Some(get_call_history_response::Result::Success(
                    GetCallHistorySuccess {
                        calls,
                        next_cursor,
                    },
                )),
            }
        }
        Err(e) => {
            warn!("Failed to get call history: {}", e);
            GetCallHistoryResponse {
                result: Some(get_call_history_response::Result::Error(error_response(
                    4,
                    "Failed to get call history",
                ))),
            }
        }
    }
}
