/// Disappearing Messages Handler (Phase 2)
///
/// Manages auto-delete configuration for conversations.
/// Messages will be automatically deleted after the configured TTL expires.
/// RT-003: Broadcasts config changes and schedules cleanup jobs.
use crate::db::DatabaseClient;
use crate::jwt::validate_access_token;
use crate::nats::NatsClient;
use crate::proto::common::{error_response::ErrorCode, ErrorResponse, Timestamp};
use crate::proto::messaging::{
    get_disappearing_config_response, set_disappearing_messages_response, DisappearingConfig,
    GetDisappearingConfigRequest, GetDisappearingConfigResponse, GetDisappearingConfigSuccess,
    SetDisappearingMessagesRequest, SetDisappearingMessagesResponse,
    SetDisappearingMessagesSuccess,
};
use std::sync::Arc;
use tonic::{Request, Response, Status};
use tracing::{error, info, instrument, warn};

/// Common TTL presets (in seconds)
#[allow(dead_code)]
pub mod ttl_presets {
    pub const OFF: i32 = 0;
    pub const ONE_HOUR: i32 = 3600;
    pub const ONE_DAY: i32 = 86400;
    pub const SEVEN_DAYS: i32 = 604800;
    pub const THIRTY_DAYS: i32 = 2592000;
    pub const NINETY_DAYS: i32 = 7776000;
}

/// Set disappearing messages configuration for a conversation
/// RT-003: Broadcasts config change and schedules cleanup job
#[instrument(skip(db, nats, request), fields(user_id, conversation_id, ttl_seconds))]
pub async fn set_disappearing_messages(
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
    request: Request<SetDisappearingMessagesRequest>,
) -> Result<Response<SetDisappearingMessagesResponse>, Status> {
    let req = request.into_inner();

    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(SetDisappearingMessagesResponse {
                result: Some(set_disappearing_messages_response::Result::Error(
                    ErrorResponse {
                        code: ErrorCode::Unauthorized as i32,
                        message: "Invalid access token".to_string(),
                        details: Default::default(),
                    },
                )),
            }));
        }
    };

    let user_id = claims.sub.clone();
    tracing::Span::current().record("user_id", &user_id);
    tracing::Span::current().record("conversation_id", &req.conversation_id);
    tracing::Span::current().record("ttl_seconds", req.ttl_seconds);

    // Validate required fields
    if req.conversation_id.is_empty() {
        return Ok(Response::new(SetDisappearingMessagesResponse {
            result: Some(set_disappearing_messages_response::Result::Error(
                ErrorResponse {
                    code: ErrorCode::InvalidRequest as i32,
                    message: "conversation_id is required".to_string(),
                    details: Default::default(),
                },
            )),
        }));
    }

    // Validate TTL (0 = disabled, otherwise must be positive)
    if req.ttl_seconds < 0 {
        return Ok(Response::new(SetDisappearingMessagesResponse {
            result: Some(set_disappearing_messages_response::Result::Error(
                ErrorResponse {
                    code: ErrorCode::InvalidRequest as i32,
                    message: "ttl_seconds must be 0 (disabled) or positive".to_string(),
                    details: Default::default(),
                },
            )),
        }));
    }

    // Verify user is a member of the conversation
    let is_member = match db
        .is_conversation_member(&req.conversation_id, &user_id, req.is_group)
        .await
    {
        Ok(result) => result,
        Err(e) => {
            error!("Failed to verify conversation membership: {}", e);
            return Ok(Response::new(SetDisappearingMessagesResponse {
                result: Some(set_disappearing_messages_response::Result::Error(
                    ErrorResponse {
                        code: ErrorCode::InternalError as i32,
                        message: "Failed to verify conversation membership".to_string(),
                        details: Default::default(),
                    },
                )),
            }));
        }
    };

    if !is_member {
        return Ok(Response::new(SetDisappearingMessagesResponse {
            result: Some(set_disappearing_messages_response::Result::Error(
                ErrorResponse {
                    code: ErrorCode::Forbidden as i32,
                    message: "User is not a member of this conversation".to_string(),
                    details: Default::default(),
                },
            )),
        }));
    }

    let now = chrono::Utc::now();
    let updated_at = Timestamp {
        seconds: now.timestamp(),
        nanos: now.timestamp_subsec_nanos() as i32,
    };

    // Save disappearing config
    match db
        .set_disappearing_config(
            &req.conversation_id,
            &user_id,
            req.ttl_seconds,
            req.is_group,
        )
        .await
    {
        Ok(_) => {
            let config = DisappearingConfig {
                conversation_id: req.conversation_id.clone(),
                ttl_seconds: req.ttl_seconds,
                set_by_user_id: user_id.clone(),
                updated_at: Some(updated_at),
            };

            info!(
                user_id = %user_id,
                conversation_id = %req.conversation_id,
                ttl_seconds = req.ttl_seconds,
                "Disappearing messages config updated"
            );

            // RT-003: Broadcast config change to other participants
            let topic = if req.is_group {
                format!("group.{}.disappearing_config", req.conversation_id)
            } else {
                format!("conversation.{}.disappearing_config", req.conversation_id)
            };

            let config_event = serde_json::json!({
                "type": "disappearing_config_changed",
                "conversation_id": req.conversation_id,
                "ttl_seconds": req.ttl_seconds,
                "set_by_user_id": user_id,
                "is_group": req.is_group,
                "enabled": req.ttl_seconds > 0,
                "timestamp_seconds": now.timestamp(),
            });

            let payload = serde_json::to_vec(&config_event).unwrap_or_default();
            if let Err(e) = nats.publish(&topic, &payload).await {
                warn!(
                    "Failed to broadcast disappearing config via NATS: {} (topic={})",
                    e, topic
                );
            } else {
                info!(
                    "Disappearing config broadcast to topic: {} (ttl={}s)",
                    topic, req.ttl_seconds
                );
            }

            // RT-003: Schedule background job for message cleanup
            // Publish to cleanup scheduler topic if TTL is enabled
            if req.ttl_seconds > 0 {
                let cleanup_job = serde_json::json!({
                    "type": "schedule_cleanup",
                    "conversation_id": req.conversation_id,
                    "ttl_seconds": req.ttl_seconds,
                    "is_group": req.is_group,
                    "scheduled_at": now.timestamp(),
                });

                let cleanup_payload = serde_json::to_vec(&cleanup_job).unwrap_or_default();
                if let Err(e) = nats
                    .publish("messaging.cleanup.schedule", &cleanup_payload)
                    .await
                {
                    warn!(
                        "Failed to schedule cleanup job via NATS: {} (conversation={})",
                        e, req.conversation_id
                    );
                } else {
                    info!(
                        "Cleanup job scheduled for conversation {} (ttl={}s)",
                        req.conversation_id, req.ttl_seconds
                    );
                }
            }

            Ok(Response::new(SetDisappearingMessagesResponse {
                result: Some(set_disappearing_messages_response::Result::Success(
                    SetDisappearingMessagesSuccess {
                        config: Some(config),
                    },
                )),
            }))
        }
        Err(e) => {
            error!("Failed to set disappearing config: {}", e);
            Ok(Response::new(SetDisappearingMessagesResponse {
                result: Some(set_disappearing_messages_response::Result::Error(
                    ErrorResponse {
                        code: ErrorCode::InternalError as i32,
                        message: format!("Failed to set disappearing config: {}", e),
                        details: Default::default(),
                    },
                )),
            }))
        }
    }
}

/// Get disappearing messages configuration for a conversation
#[instrument(skip(db, request), fields(conversation_id))]
pub async fn get_disappearing_config(
    db: Arc<DatabaseClient>,
    request: Request<GetDisappearingConfigRequest>,
) -> Result<Response<GetDisappearingConfigResponse>, Status> {
    let req = request.into_inner();

    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(GetDisappearingConfigResponse {
                result: Some(get_disappearing_config_response::Result::Error(
                    ErrorResponse {
                        code: ErrorCode::Unauthorized as i32,
                        message: "Invalid access token".to_string(),
                        details: Default::default(),
                    },
                )),
            }));
        }
    };

    tracing::Span::current().record("conversation_id", &req.conversation_id);

    // Validate required fields
    if req.conversation_id.is_empty() {
        return Ok(Response::new(GetDisappearingConfigResponse {
            result: Some(get_disappearing_config_response::Result::Error(
                ErrorResponse {
                    code: ErrorCode::InvalidRequest as i32,
                    message: "conversation_id is required".to_string(),
                    details: Default::default(),
                },
            )),
        }));
    }

    // Get disappearing config
    match db
        .get_disappearing_config(&req.conversation_id, req.is_group)
        .await
    {
        Ok(config) => {
            info!(
                conversation_id = %req.conversation_id,
                ttl_seconds = config.ttl_seconds,
                "Retrieved disappearing config"
            );

            Ok(Response::new(GetDisappearingConfigResponse {
                result: Some(get_disappearing_config_response::Result::Success(
                    GetDisappearingConfigSuccess {
                        config: Some(config),
                    },
                )),
            }))
        }
        Err(e) => {
            error!("Failed to get disappearing config: {}", e);
            Ok(Response::new(GetDisappearingConfigResponse {
                result: Some(get_disappearing_config_response::Result::Error(
                    ErrorResponse {
                        code: ErrorCode::InternalError as i32,
                        message: format!("Failed to get disappearing config: {}", e),
                        details: Default::default(),
                    },
                )),
            }))
        }
    }
}
