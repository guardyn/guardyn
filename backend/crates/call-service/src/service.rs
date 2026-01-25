//! gRPC service implementation for Call Service

use std::pin::Pin;
use std::sync::Arc;

use chrono::Utc;
use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use tokio_stream::Stream;
use tonic::{Request, Response, Status};
use tracing::{debug, warn};

use crate::db::CallDb;
use crate::generated::guardyn::calls::call_service_server::CallService;
use crate::generated::guardyn::calls::*;
use crate::handlers;
use crate::nats::{CallEventEnvelope, CallEventType, CallNatsClient, IceCandidateEnvelope, SdpEnvelope, SFrameKeyEnvelope};
use crate::session::CallSessionManager;
use crate::IceServerConfig;

/// Call service implementation
pub struct CallServiceImpl {
    db: Arc<CallDb>,
    session_mgr: Arc<CallSessionManager>,
    nats_client: Arc<CallNatsClient>,
    auth_service_url: String,
    jwt_secret: String,
    ice_servers: Vec<IceServerConfig>,
}

impl CallServiceImpl {
    /// Create a new call service
    pub fn new(
        db: Arc<CallDb>,
        session_mgr: Arc<CallSessionManager>,
        nats_client: Arc<CallNatsClient>,
        auth_service_url: String,
        jwt_secret: String,
        ice_servers: Vec<IceServerConfig>,
    ) -> Self {
        Self {
            db,
            session_mgr,
            nats_client,
            auth_service_url,
            jwt_secret,
            ice_servers,
        }
    }
}

#[tonic::async_trait]
impl CallService for CallServiceImpl {
    async fn initiate_call(
        &self,
        request: Request<InitiateCallRequest>,
    ) -> Result<Response<InitiateCallResponse>, Status> {
        let response = handlers::initiate_call(
            &self.db,
            &self.session_mgr,
            &self.nats_client,
            request.into_inner(),
            &self.jwt_secret,
            &self.ice_servers,
            &self.auth_service_url,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn accept_call(
        &self,
        request: Request<AcceptCallRequest>,
    ) -> Result<Response<AcceptCallResponse>, Status> {
        let response = handlers::accept_call(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
            &self.ice_servers,
            &self.auth_service_url,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn reject_call(
        &self,
        request: Request<RejectCallRequest>,
    ) -> Result<Response<RejectCallResponse>, Status> {
        let response = handlers::reject_call(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn end_call(
        &self,
        request: Request<EndCallRequest>,
    ) -> Result<Response<EndCallResponse>, Status> {
        let response = handlers::end_call(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn join_call(
        &self,
        request: Request<JoinCallRequest>,
    ) -> Result<Response<JoinCallResponse>, Status> {
        let response = handlers::join_call(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
            &self.ice_servers,
            &self.auth_service_url,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn leave_call(
        &self,
        request: Request<LeaveCallRequest>,
    ) -> Result<Response<LeaveCallResponse>, Status> {
        let response = handlers::leave_call(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn set_mute(
        &self,
        request: Request<SetMuteRequest>,
    ) -> Result<Response<SetMuteResponse>, Status> {
        let response = handlers::set_mute(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn set_video(
        &self,
        request: Request<SetVideoRequest>,
    ) -> Result<Response<SetVideoResponse>, Status> {
        let response = handlers::set_video(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn set_screen_share(
        &self,
        request: Request<SetScreenShareRequest>,
    ) -> Result<Response<SetScreenShareResponse>, Status> {
        let response = handlers::set_screen_share(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn exchange_ice_candidate(
        &self,
        request: Request<ExchangeIceCandidateRequest>,
    ) -> Result<Response<ExchangeIceCandidateResponse>, Status> {
        // Validate token and extract user ID
        let req = request.into_inner();
        let from_user_id = match handlers::validate_token(&req.access_token, &self.jwt_secret) {
            Ok(id) => id,
            Err(_) => {
                return Ok(Response::new(ExchangeIceCandidateResponse {
                    result: Some(exchange_ice_candidate_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 2,
                            message: "Invalid or expired token".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                }));
            }
        };

        // Verify call exists
        if self.session_mgr.get_session(&req.call_id).is_none() {
            return Ok(Response::new(ExchangeIceCandidateResponse {
                result: Some(exchange_ice_candidate_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 3,
                        message: "Call not found".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }));
        }

        // Extract ICE candidate data
        let candidate = match &req.candidate {
            Some(c) => c,
            None => {
                return Ok(Response::new(ExchangeIceCandidateResponse {
                    result: Some(exchange_ice_candidate_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 1,
                            message: "ICE candidate is required".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                }));
            }
        };

        // Create envelope and distribute via NATS
        let envelope = IceCandidateEnvelope {
            call_id: req.call_id.clone(),
            from_user_id: from_user_id.clone(),
            target_user_id: req.target_user_id.clone(),
            candidate: candidate.candidate.clone(),
            sdp_mid: candidate.sdp_mid.clone(),
            sdp_mline_index: candidate.sdp_mline_index,
            username_fragment: candidate.username_fragment.clone(),
            timestamp: Utc::now().timestamp(),
        };

        if let Err(e) = self.nats_client.publish_ice_candidate(&envelope).await {
            warn!("Failed to distribute ICE candidate via NATS: {}", e);
            return Ok(Response::new(ExchangeIceCandidateResponse {
                result: Some(exchange_ice_candidate_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: format!("Failed to distribute ICE candidate: {}", e),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }));
        }

        debug!(
            "ICE candidate distributed from {} to {} in call {}",
            from_user_id, req.target_user_id, req.call_id
        );

        Ok(Response::new(ExchangeIceCandidateResponse {
            result: Some(exchange_ice_candidate_response::Result::Success(
                ExchangeIceCandidateSuccess { sent: true },
            )),
        }))
    }

    async fn exchange_sdp(
        &self,
        request: Request<ExchangeSdpRequest>,
    ) -> Result<Response<ExchangeSdpResponse>, Status> {
        // Validate token and extract user ID
        let req = request.into_inner();
        let from_user_id = match handlers::validate_token(&req.access_token, &self.jwt_secret) {
            Ok(id) => id,
            Err(_) => {
                return Ok(Response::new(ExchangeSdpResponse {
                    result: Some(exchange_sdp_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 2,
                            message: "Invalid or expired token".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                }));
            }
        };

        // Verify call exists
        if self.session_mgr.get_session(&req.call_id).is_none() {
            return Ok(Response::new(ExchangeSdpResponse {
                result: Some(exchange_sdp_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 3,
                        message: "Call not found".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }));
        }

        // Extract SDP data
        let sdp = match &req.sdp {
            Some(s) => s,
            None => {
                return Ok(Response::new(ExchangeSdpResponse {
                    result: Some(exchange_sdp_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 1,
                            message: "SDP is required".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                }));
            }
        };

        // Create envelope and distribute via NATS
        let envelope = SdpEnvelope {
            call_id: req.call_id.clone(),
            from_user_id: from_user_id.clone(),
            target_user_id: req.target_user_id.clone(),
            sdp_type: sdp.r#type,
            sdp: sdp.sdp.clone(),
            timestamp: Utc::now().timestamp(),
        };

        if let Err(e) = self.nats_client.publish_sdp(&envelope).await {
            warn!("Failed to distribute SDP via NATS: {}", e);
            return Ok(Response::new(ExchangeSdpResponse {
                result: Some(exchange_sdp_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: format!("Failed to distribute SDP: {}", e),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }));
        }

        debug!(
            "SDP type {} distributed from {} to {} in call {}",
            sdp.r#type, from_user_id, req.target_user_id, req.call_id
        );

        Ok(Response::new(ExchangeSdpResponse {
            result: Some(exchange_sdp_response::Result::Success(ExchangeSdpSuccess {
                sent: true,
            })),
        }))
    }

    async fn get_call_state(
        &self,
        request: Request<GetCallStateRequest>,
    ) -> Result<Response<GetCallStateResponse>, Status> {
        let response = handlers::get_call_state(
            &self.db,
            &self.session_mgr,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn get_call_history(
        &self,
        request: Request<GetCallHistoryRequest>,
    ) -> Result<Response<GetCallHistoryResponse>, Status> {
        let response =
            handlers::get_call_history(&self.db, request.into_inner(), &self.jwt_secret).await;
        Ok(Response::new(response))
    }

    type SubscribeToIncomingCallsStream =
        Pin<Box<dyn Stream<Item = Result<IncomingCallNotification, Status>> + Send + 'static>>;

    async fn subscribe_to_incoming_calls(
        &self,
        request: Request<SubscribeToIncomingCallsRequest>,
    ) -> Result<Response<Self::SubscribeToIncomingCallsStream>, Status> {
        let req = request.into_inner();

        // Validate token and get user ID
        let user_id = match handlers::validate_token(&req.access_token, &self.jwt_secret) {
            Ok(id) => id,
            Err(_) => return Err(Status::unauthenticated("Invalid or expired token")),
        };

        debug!("User {} subscribing to incoming calls", user_id);

        // Create channel for incoming call notifications
        let (tx, rx) = mpsc::channel::<Result<IncomingCallNotification, Status>>(100);

        // Subscribe to NATS for incoming call notifications
        let nats_client = Arc::clone(&self.nats_client);
        let user_id_clone = user_id.clone();
        let ice_servers = self.ice_servers.clone();

        tokio::spawn(async move {
            // Subscribe to incoming calls for this user
            let consumer = match nats_client.subscribe_incoming_calls(&user_id_clone).await {
                Ok(c) => c,
                Err(e) => {
                    warn!("Failed to subscribe to incoming calls: {}", e);
                    return;
                }
            };

            // Poll for incoming call notifications
            loop {
                if tx.is_closed() {
                    debug!("Incoming call stream closed for user {}", user_id_clone);
                    break;
                }

                // Fetch incoming call notifications
                if let Ok(notifications) = nats_client.fetch_incoming_calls(&consumer, 10).await {
                    for notification in notifications {
                        let proto_notification = IncomingCallNotification {
                            call_id: notification.call_id,
                            call_type: notification.call_type,
                            is_group_call: notification.is_group_call,
                            group_id: notification.group_id,
                            caller_id: notification.caller_id,
                            caller_display_name: notification.caller_display_name,
                            caller_avatar_url: notification.caller_avatar_url,
                            ice_servers: ice_servers.iter().map(|c| IceServer {
                                urls: c.urls.clone(),
                                username: c.username.clone().unwrap_or_default(),
                                credential: c.credential.clone().unwrap_or_default(),
                            }).collect(),
                            created_at: Some(crate::generated::guardyn::common::Timestamp {
                                seconds: notification.timestamp,
                                nanos: 0,
                            }),
                        };
                        if tx.send(Ok(proto_notification)).await.is_err() {
                            break;
                        }
                    }
                }

                // Small delay between polling
                tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
            }
        });

        let stream = ReceiverStream::new(rx);
        Ok(Response::new(Box::pin(stream)))
    }

    type StreamCallEventsStream =
        Pin<Box<dyn Stream<Item = Result<CallEvent, Status>> + Send + 'static>>;

    async fn stream_call_events(
        &self,
        request: Request<StreamCallEventsRequest>,
    ) -> Result<Response<Self::StreamCallEventsStream>, Status> {
        let req = request.into_inner();

        // Validate token and get user ID
        let user_id = match handlers::validate_token(&req.access_token, &self.jwt_secret) {
            Ok(id) => id,
            Err(_) => return Err(Status::unauthenticated("Invalid or expired token")),
        };

        // Check if call exists
        if self.session_mgr.get_session(&req.call_id).is_none() {
            return Err(Status::not_found("Call not found"));
        }

        // Create channel for events
        let (tx, rx) = mpsc::channel::<Result<CallEvent, Status>>(100);

        // Subscribe to NATS for call events and forward to stream
        let nats_client = Arc::clone(&self.nats_client);
        let call_id = req.call_id.clone();
        let user_id_clone = user_id.clone();

        tokio::spawn(async move {
            // Subscribe to ICE candidates for this user
            let ice_consumer = match nats_client.subscribe_ice_candidates(&call_id, &user_id_clone).await {
                Ok(c) => Some(c),
                Err(e) => {
                    warn!("Failed to subscribe to ICE candidates: {}", e);
                    None
                }
            };

            // Subscribe to SDP messages for this user
            let sdp_consumer = match nats_client.subscribe_sdp(&call_id, &user_id_clone).await {
                Ok(c) => Some(c),
                Err(e) => {
                    warn!("Failed to subscribe to SDP messages: {}", e);
                    None
                }
            };

            // Subscribe to general call events
            let events_consumer = match nats_client.subscribe_call_events(&call_id).await {
                Ok(c) => Some(c),
                Err(e) => {
                    warn!("Failed to subscribe to call events: {}", e);
                    None
                }
            };

            // Subscribe to SFrame keys for this user
            let sframe_consumer = match nats_client.subscribe_sframe_keys(&call_id, &user_id_clone).await {
                Ok(c) => Some(c),
                Err(e) => {
                    warn!("Failed to subscribe to SFrame keys: {}", e);
                    None
                }
            };

            // Poll for events
            loop {
                if tx.is_closed() {
                    debug!("Event stream closed for call {}", call_id);
                    break;
                }

                // Fetch ICE candidates
                if let Some(ref consumer) = ice_consumer {
                    if let Ok(candidates) = nats_client.fetch_ice_candidates(consumer, 10).await {
                        for candidate in candidates {
                            let event = CallEvent {
                                call_id: call_id.clone(),
                                timestamp: Some(crate::generated::guardyn::common::Timestamp {
                                    seconds: candidate.timestamp,
                                    nanos: 0,
                                }),
                                event: Some(call_event::Event::IceCandidateReceived(
                                    IceCandidateReceived {
                                        from_user_id: candidate.from_user_id,
                                        candidate: Some(IceCandidate {
                                            candidate: candidate.candidate,
                                            sdp_mid: candidate.sdp_mid,
                                            sdp_mline_index: candidate.sdp_mline_index,
                                            username_fragment: candidate.username_fragment,
                                        }),
                                    },
                                )),
                            };
                            if tx.send(Ok(event)).await.is_err() {
                                break;
                            }
                        }
                    }
                }

                // Fetch SDP messages
                if let Some(ref consumer) = sdp_consumer {
                    if let Ok(sdps) = nats_client.fetch_sdp_messages(consumer, 10).await {
                        for sdp_msg in sdps {
                            let event = CallEvent {
                                call_id: call_id.clone(),
                                timestamp: Some(crate::generated::guardyn::common::Timestamp {
                                    seconds: sdp_msg.timestamp,
                                    nanos: 0,
                                }),
                                event: Some(call_event::Event::SdpReceived(SdpReceived {
                                    from_user_id: sdp_msg.from_user_id,
                                    sdp: Some(SdpMessage {
                                        r#type: sdp_msg.sdp_type,
                                        sdp: sdp_msg.sdp,
                                    }),
                                })),
                            };
                            if tx.send(Ok(event)).await.is_err() {
                                break;
                            }
                        }
                    }
                }

                // Fetch call events
                if let Some(ref consumer) = events_consumer {
                    if let Ok(events) = nats_client.fetch_call_events(consumer, 10).await {
                        for event_envelope in events {
                            if let Some(call_event) = convert_call_event(&call_id, &event_envelope) {
                                if tx.send(Ok(call_event)).await.is_err() {
                                    break;
                                }
                            }
                        }
                    }
                }

                // Fetch SFrame keys
                if let Some(ref consumer) = sframe_consumer {
                    if let Ok(keys) = nats_client.fetch_sframe_keys(consumer, 10).await {
                        for key in keys {
                            let event = CallEvent {
                                call_id: call_id.clone(),
                                timestamp: Some(crate::generated::guardyn::common::Timestamp {
                                    seconds: key.timestamp,
                                    nanos: 0,
                                }),
                                event: Some(call_event::Event::SframeKeyRotated(SFrameKeyRotated {
                                    from_user_id: key.from_user_id,
                                    new_key_id: key.key_id,
                                    encrypted_key_material: key.encrypted_key_material,
                                })),
                            };
                            if tx.send(Ok(event)).await.is_err() {
                                break;
                            }
                        }
                    }
                }

                // Small delay between polling
                tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
            }
        });

        let stream = ReceiverStream::new(rx);
        Ok(Response::new(Box::pin(stream)))
    }

    async fn exchange_s_frame_key(
        &self,
        request: Request<ExchangeSFrameKeyRequest>,
    ) -> Result<Response<ExchangeSFrameKeyResponse>, Status> {
        let req = request.into_inner();

        // Validate token and extract user ID
        let from_user_id = match handlers::validate_token(&req.access_token, &self.jwt_secret) {
            Ok(id) => id,
            Err(_) => {
                return Ok(Response::new(ExchangeSFrameKeyResponse {
                    result: Some(exchange_s_frame_key_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 2,
                            message: "Invalid or expired token".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                }));
            }
        };

        // Verify call exists
        if self.session_mgr.get_session(&req.call_id).is_none() {
            return Ok(Response::new(ExchangeSFrameKeyResponse {
                result: Some(exchange_s_frame_key_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 3,
                        message: "Call not found".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }));
        }

        // Distribute encrypted key packages to participants via NATS
        let mut distributed_count = 0;
        for key_package in &req.key_packages {
            let envelope = SFrameKeyEnvelope {
                call_id: req.call_id.clone(),
                from_user_id: from_user_id.clone(),
                target_user_id: key_package.user_id.clone(),
                key_id: key_package.key_id,
                encrypted_key_material: key_package.encrypted_key_material.clone(),
                timestamp: Utc::now().timestamp(),
            };

            if let Err(e) = self.nats_client.publish_sframe_key(&envelope).await {
                warn!(
                    "Failed to distribute SFrame key to {}: {}",
                    key_package.user_id, e
                );
            } else {
                distributed_count += 1;
            }
        }

        debug!(
            "Distributed {} SFrame key packages from {} in call {}",
            distributed_count, from_user_id, req.call_id
        );

        Ok(Response::new(ExchangeSFrameKeyResponse {
            result: Some(exchange_s_frame_key_response::Result::Success(
                ExchangeSFrameKeySuccess {
                    distributed: true,
                    participants_count: distributed_count,
                },
            )),
        }))
    }

    async fn rotate_s_frame_key(
        &self,
        request: Request<RotateSFrameKeyRequest>,
    ) -> Result<Response<RotateSFrameKeyResponse>, Status> {
        let req = request.into_inner();

        // Validate token
        let user_id = match handlers::validate_token(&req.access_token, &self.jwt_secret) {
            Ok(id) => id,
            Err(_) => {
                return Ok(Response::new(RotateSFrameKeyResponse {
                    result: Some(rotate_s_frame_key_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 2,
                            message: "Invalid or expired token".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                }));
            }
        };

        // Rotate key in session manager
        let (new_key_id, _new_key) = match self.session_mgr.rotate_sframe_key(&req.call_id, &user_id)
        {
            Some(keys) => keys,
            None => {
                return Ok(Response::new(RotateSFrameKeyResponse {
                    result: Some(rotate_s_frame_key_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 3,
                            message: "Call not found".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                }));
            }
        };

        // Distribute new key packages to participants via NATS
        let mut distributed_count = 0;
        for key_package in &req.key_packages {
            let envelope = SFrameKeyEnvelope {
                call_id: req.call_id.clone(),
                from_user_id: user_id.clone(),
                target_user_id: key_package.user_id.clone(),
                key_id: key_package.key_id,
                encrypted_key_material: key_package.encrypted_key_material.clone(),
                timestamp: Utc::now().timestamp(),
            };

            if let Err(e) = self.nats_client.publish_sframe_key(&envelope).await {
                warn!(
                    "Failed to distribute rotated SFrame key to {}: {}",
                    key_package.user_id, e
                );
            } else {
                distributed_count += 1;
            }
        }

        debug!(
            "Distributed {} rotated SFrame key packages from {} in call {}",
            distributed_count, user_id, req.call_id
        );

        Ok(Response::new(RotateSFrameKeyResponse {
            result: Some(rotate_s_frame_key_response::Result::Success(
                RotateSFrameKeySuccess {
                    new_key_id,
                    distributed: distributed_count > 0 || req.key_packages.is_empty(),
                },
            )),
        }))
    }

    async fn health(
        &self,
        _request: Request<HealthRequest>,
    ) -> Result<Response<crate::generated::guardyn::common::HealthStatus>, Status> {
        use crate::generated::guardyn::common::{health_status::Status as HealthStatusEnum, Timestamp};
        
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;

        Ok(Response::new(
            crate::generated::guardyn::common::HealthStatus {
                status: HealthStatusEnum::Healthy as i32,
                version: env!("CARGO_PKG_VERSION").to_string(),
                timestamp: Some(Timestamp {
                    seconds: now,
                    nanos: 0,
                }),
                components: std::collections::HashMap::new(),
            },
        ))
    }
}

/// Convert CallEventEnvelope from NATS to proto CallEvent
fn convert_call_event(call_id: &str, envelope: &CallEventEnvelope) -> Option<CallEvent> {
    let timestamp = Some(crate::generated::guardyn::common::Timestamp {
        seconds: envelope.timestamp,
        nanos: 0,
    });

    let event = match envelope.event_type {
        CallEventType::StateChanged => {
            let old_state = envelope.payload.get("old_state")?.as_i64()? as i32;
            let new_state = envelope.payload.get("new_state")?.as_i64()? as i32;
            let end_reason = envelope.payload.get("end_reason").and_then(|v| v.as_i64()).unwrap_or(0) as i32;
            Some(call_event::Event::StateChanged(CallStateChanged {
                old_state,
                new_state,
                end_reason,
            }))
        }
        CallEventType::ParticipantJoined => {
            let user_id = envelope.payload.get("user_id")?.as_str()?.to_string();
            let display_name = envelope.payload.get("display_name")?.as_str()?.to_string();
            Some(call_event::Event::ParticipantJoined(ParticipantJoined {
                participant: Some(CallParticipant {
                    user_id,
                    display_name,
                    is_muted: false,
                    has_video: false,
                    is_screen_sharing: false,
                    is_speaking: false,
                    joined_at: timestamp.clone(),
                }),
            }))
        }
        CallEventType::ParticipantLeft => {
            let user_id = envelope.payload.get("user_id")?.as_str()?.to_string();
            let reason = envelope.payload.get("reason").and_then(|v| v.as_str()).unwrap_or("").to_string();
            Some(call_event::Event::ParticipantLeft(ParticipantLeft {
                user_id,
                reason,
            }))
        }
        CallEventType::ParticipantMuted => {
            let user_id = envelope.payload.get("user_id")?.as_str()?.to_string();
            let is_muted = envelope.payload.get("is_muted")?.as_bool()?;
            Some(call_event::Event::ParticipantMuted(ParticipantMuted {
                user_id,
                is_muted,
            }))
        }
        CallEventType::ParticipantVideoChanged => {
            let user_id = envelope.payload.get("user_id")?.as_str()?.to_string();
            let has_video = envelope.payload.get("has_video")?.as_bool()?;
            Some(call_event::Event::ParticipantVideoChanged(ParticipantVideoChanged {
                user_id,
                has_video,
            }))
        }
        CallEventType::ParticipantScreenShareChanged => {
            let user_id = envelope.payload.get("user_id")?.as_str()?.to_string();
            let is_screen_sharing = envelope.payload.get("is_screen_sharing")?.as_bool()?;
            Some(call_event::Event::ParticipantScreenShareChanged(
                ParticipantScreenShareChanged {
                    user_id,
                    is_screen_sharing,
                },
            ))
        }
        CallEventType::ParticipantSpeaking => {
            let user_id = envelope.payload.get("user_id")?.as_str()?.to_string();
            let is_speaking = envelope.payload.get("is_speaking")?.as_bool()?;
            let audio_level = envelope.payload.get("audio_level").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
            Some(call_event::Event::ParticipantSpeaking(ParticipantSpeaking {
                user_id,
                is_speaking,
                audio_level,
            }))
        }
        CallEventType::QualityChanged => {
            let quality = envelope.payload.get("quality")?.as_i64()? as i32;
            Some(call_event::Event::QualityChanged(CallQualityChanged {
                quality,
            }))
        }
        // These are handled directly from their respective consumers
        CallEventType::IceCandidateReceived |
        CallEventType::SdpReceived |
        CallEventType::SFrameKeyRotated => None,
    };

    event.map(|e| CallEvent {
        call_id: call_id.to_string(),
        timestamp,
        event: Some(e),
    })
}
