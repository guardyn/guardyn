//! gRPC service implementation for Call Service

use std::pin::Pin;
use std::sync::Arc;

use async_nats::Client as NatsClient;
use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use tokio_stream::Stream;
use tonic::{Request, Response, Status};

use crate::db::CallDb;
use crate::generated::guardyn::calls::call_service_server::CallService;
use crate::generated::guardyn::calls::*;
use crate::handlers;
use crate::session::CallSessionManager;
use crate::IceServerConfig;

/// Call service implementation
pub struct CallServiceImpl {
    db: Arc<CallDb>,
    session_mgr: Arc<CallSessionManager>,
    _nats_client: NatsClient,
    jwt_secret: String,
    ice_servers: Vec<IceServerConfig>,
}

impl CallServiceImpl {
    /// Create a new call service
    pub fn new(
        db: Arc<CallDb>,
        session_mgr: Arc<CallSessionManager>,
        nats_client: NatsClient,
        jwt_secret: String,
        ice_servers: Vec<IceServerConfig>,
    ) -> Self {
        Self {
            db,
            session_mgr,
            _nats_client: nats_client,
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
            request.into_inner(),
            &self.jwt_secret,
            &self.ice_servers,
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
        // Validate token
        let req = request.into_inner();
        if handlers::validate_token(&req.access_token, &self.jwt_secret).is_err() {
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

        // TODO: Distribute ICE candidate to target participant via NATS
        // For now, just acknowledge receipt

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
        // Validate token
        let req = request.into_inner();
        if handlers::validate_token(&req.access_token, &self.jwt_secret).is_err() {
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

        // TODO: Distribute SDP to target participant via NATS
        // For now, just acknowledge receipt

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

    type StreamCallEventsStream =
        Pin<Box<dyn Stream<Item = Result<CallEvent, Status>> + Send + 'static>>;

    async fn stream_call_events(
        &self,
        request: Request<StreamCallEventsRequest>,
    ) -> Result<Response<Self::StreamCallEventsStream>, Status> {
        let req = request.into_inner();

        // Validate token
        if handlers::validate_token(&req.access_token, &self.jwt_secret).is_err() {
            return Err(Status::unauthenticated("Invalid or expired token"));
        }

        // Check if call exists
        if self.session_mgr.get_session(&req.call_id).is_none() {
            return Err(Status::not_found("Call not found"));
        }

        // Create channel for events
        let (tx, rx) = mpsc::channel::<Result<CallEvent, Status>>(100);

        // TODO: Subscribe to NATS for call events and forward to stream
        // For now, just keep the stream open

        let _call_id = req.call_id;
        tokio::spawn(async move {
            // Keep connection alive, events would be pushed via NATS subscription
            loop {
                tokio::time::sleep(tokio::time::Duration::from_secs(30)).await;
                if tx.is_closed() {
                    break;
                }
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

        // Validate token
        if handlers::validate_token(&req.access_token, &self.jwt_secret).is_err() {
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

        // TODO: Distribute encrypted key packages to participants via NATS
        let participants_count = req.key_packages.len() as i32;

        Ok(Response::new(ExchangeSFrameKeyResponse {
            result: Some(exchange_s_frame_key_response::Result::Success(
                ExchangeSFrameKeySuccess {
                    distributed: true,
                    participants_count,
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

        // TODO: Distribute new key packages to participants via NATS

        Ok(Response::new(RotateSFrameKeyResponse {
            result: Some(rotate_s_frame_key_response::Result::Success(
                RotateSFrameKeySuccess {
                    new_key_id,
                    distributed: true,
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
