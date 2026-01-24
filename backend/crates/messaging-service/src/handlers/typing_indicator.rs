//! Typing indicator handler for 1-on-1 and group chats

use crate::db::DatabaseClient;
use crate::nats::NatsClient;
use crate::proto::common::ErrorResponse;
use crate::proto::messaging::{
    typing_indicator_response, TypingIndicatorRequest, TypingIndicatorResponse,
    TypingIndicatorSuccess,
};
use std::sync::Arc;
use tonic::{Response, Status};

/// Handle typing indicator requests for both 1-on-1 and group chats
pub async fn send_typing_indicator(
    request: TypingIndicatorRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
) -> Result<Response<TypingIndicatorResponse>, Status> {
    // Validate JWT token
    let jwt_secret = crate::config::get_jwt_secret();

    let (user_id, _device_id, username) =
        match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
            Ok(ids) => ids,
            Err(_) => {
                return Ok(Response::new(TypingIndicatorResponse {
                    result: Some(typing_indicator_response::Result::Error(ErrorResponse {
                        code: 16, // UNAUTHENTICATED
                        message: "Invalid or expired access token".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        };

    // Determine if this is for a group or 1-on-1 chat
    let is_group = !request.group_id.is_empty();

    if is_group {
        // Group typing indicator
        let group_id = &request.group_id;

        // Verify group exists
        match db.get_group(group_id).await {
            Ok(Some(_group)) => {
                // Group exists, continue
            }
            Ok(None) => {
                return Ok(Response::new(TypingIndicatorResponse {
                    result: Some(typing_indicator_response::Result::Error(ErrorResponse {
                        code: 5, // NOT_FOUND
                        message: "Group not found".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
            Err(e) => {
                tracing::error!("Failed to fetch group: {}", e);
                return Ok(Response::new(TypingIndicatorResponse {
                    result: Some(typing_indicator_response::Result::Error(ErrorResponse {
                        code: 13, // INTERNAL
                        message: "Failed to verify group".to_string(),
                        details: Default::default(),
                    })),
                }));
            }
        }

        // Publish typing indicator to group topic
        let event = serde_json::json!({
            "type": "typing_indicator",
            "group_id": group_id,
            "user_id": user_id,
            "username": username,
            "is_typing": request.is_typing,
            "timestamp": chrono::Utc::now().timestamp_millis(),
        });

        let topic = format!("group.{}.typing", group_id);
        tracing::debug!(
            "Publishing group typing indicator: user={}, group={}, is_typing={}",
            user_id,
            group_id,
            request.is_typing
        );

        let payload = serde_json::to_vec(&event).unwrap();
        if let Err(e) = nats.publish(&topic, &payload).await {
            tracing::error!("Failed to publish group typing indicator: {}", e);
            return Ok(Response::new(TypingIndicatorResponse {
                result: Some(typing_indicator_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to send typing indicator".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    } else {
        // 1-on-1 typing indicator
        if request.recipient_user_id.is_empty() {
            return Ok(Response::new(TypingIndicatorResponse {
                result: Some(typing_indicator_response::Result::Error(ErrorResponse {
                    code: 3, // INVALID_ARGUMENT
                    message: "Either group_id or recipient_user_id is required".to_string(),
                    details: Default::default(),
                })),
            }));
        }

        let event = serde_json::json!({
            "type": "typing_indicator",
            "sender_user_id": user_id,
            "sender_username": username,
            "recipient_user_id": request.recipient_user_id,
            "is_typing": request.is_typing,
            "timestamp": chrono::Utc::now().timestamp_millis(),
        });

        let topic = format!("user.{}.typing", request.recipient_user_id);
        tracing::debug!(
            "Publishing 1-on-1 typing indicator: sender={}, recipient={}, is_typing={}",
            user_id,
            request.recipient_user_id,
            request.is_typing
        );

        let payload = serde_json::to_vec(&event).unwrap();
        if let Err(e) = nats.publish(&topic, &payload).await {
            tracing::error!("Failed to publish 1-on-1 typing indicator: {}", e);
            return Ok(Response::new(TypingIndicatorResponse {
                result: Some(typing_indicator_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to send typing indicator".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    }

    Ok(Response::new(TypingIndicatorResponse {
        result: Some(typing_indicator_response::Result::Success(
            TypingIndicatorSuccess { sent: true },
        )),
    }))
}
