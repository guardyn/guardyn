/// Set Typing Handler
///
/// Sets typing indicator for a conversation

use crate::db::DatabaseClient;
use crate::jwt;
use crate::nats::{NatsClient, TypingEvent};
use crate::proto::common::{error_response::ErrorCode, ErrorResponse};
use crate::proto::presence::{
    set_typing_response::Result as SetTypingResult, SetTypingRequest, SetTypingResponse,
    SetTypingSuccess,
};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn handle_set_typing(
    request: SetTypingRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
    jwt_secret: &str,
) -> Result<Response<SetTypingResponse>, Status> {
    // Validate JWT token
    let claims = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!("Token validation failed: {}", e);
            return Ok(Response::new(SetTypingResponse {
                result: Some(SetTypingResult::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    let user_id = claims.sub;

    // Validate conversation_user_id
    if request.conversation_user_id.is_empty() {
        return Ok(Response::new(SetTypingResponse {
            result: Some(SetTypingResult::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Conversation user ID is required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Can't type to yourself
    if request.conversation_user_id == user_id {
        return Ok(Response::new(SetTypingResponse {
            result: Some(SetTypingResult::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Cannot send typing indicator to yourself".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Store typing indicator in TiKV
    if let Err(e) = db
        .set_typing(&user_id, &request.conversation_user_id, request.is_typing)
        .await
    {
        tracing::error!(
            user_id = %user_id,
            conversation_user_id = %request.conversation_user_id,
            error = %e,
            "Failed to set typing indicator in TiKV"
        );
        return Ok(Response::new(SetTypingResponse {
            result: Some(SetTypingResult::Error(ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to set typing indicator".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Publish to NATS for real-time delivery
    let event = TypingEvent {
        user_id: user_id.clone(),
        conversation_user_id: request.conversation_user_id.clone(),
        is_typing: request.is_typing,
        timestamp: chrono::Utc::now().timestamp_millis(),
    };

    if let Err(e) = nats.publish_typing_indicator(&event).await {
        // Log but don't fail - typing indicators are best-effort
        tracing::warn!(
            user_id = %user_id,
            conversation_user_id = %request.conversation_user_id,
            error = %e,
            "Failed to publish typing indicator to NATS"
        );
    }

    tracing::debug!(
        user_id = %user_id,
        conversation_user_id = %request.conversation_user_id,
        is_typing = request.is_typing,
        "Typing indicator set"
    );

    Ok(Response::new(SetTypingResponse {
        result: Some(SetTypingResult::Success(SetTypingSuccess {
            acknowledged: true,
        })),
    }))
}
