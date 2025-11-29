/// Subscribe Handler
///
/// Streams presence updates for subscribed users

use crate::db::DatabaseClient;
use crate::jwt;
use crate::proto::common::Timestamp;
use crate::proto::presence::{PresenceUpdate, SubscribeRequest};
use std::sync::Arc;
use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use tonic::{Response, Status};

const MAX_SUBSCRIBED_USERS: usize = 100;

pub async fn handle_subscribe(
    request: SubscribeRequest,
    db: Arc<DatabaseClient>,
    jwt_secret: &str,
) -> Result<Response<ReceiverStream<Result<PresenceUpdate, Status>>>, Status> {
    // Validate JWT token
    let claims = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!("Token validation failed: {}", e);
            return Err(Status::unauthenticated("Invalid or expired token"));
        }
    };

    let requester_id = claims.sub.clone();

    // Validate request
    if request.user_ids.is_empty() {
        return Err(Status::invalid_argument("No user IDs provided"));
    }

    if request.user_ids.len() > MAX_SUBSCRIBED_USERS {
        return Err(Status::invalid_argument(format!(
            "Too many user IDs (max {})",
            MAX_SUBSCRIBED_USERS
        )));
    }

    let (tx, rx) = mpsc::channel(128);
    let user_ids = request.user_ids.clone();

    // Spawn task to send initial states and then periodic updates
    tokio::spawn(async move {
        tracing::info!(
            requester_id = %requester_id,
            subscribed_count = user_ids.len(),
            "Started presence subscription"
        );

        // Send initial states
        for user_id in &user_ids {
            let presence = match db.get_presence(user_id).await {
                Ok(Some(p)) => p,
                Ok(None) => {
                    // Send offline status for unknown users
                    let update = PresenceUpdate {
                        user_id: user_id.clone(),
                        status: 0, // OFFLINE
                        custom_status_text: String::new(),
                        last_seen: None,
                        updated_at: None,
                        is_typing: false,
                        typing_in_conversation_with: String::new(),
                    };
                    if tx.send(Ok(update)).await.is_err() {
                        tracing::debug!("Subscription channel closed");
                        return;
                    }
                    continue;
                }
                Err(e) => {
                    tracing::warn!(user_id = %user_id, error = %e, "Failed to get presence");
                    continue;
                }
            };

            // Handle INVISIBLE status
            let (status, custom_status) = if presence.status == 4 {
                (0, String::new())
            } else {
                (presence.status, presence.custom_status_text.clone())
            };

            // Check if user is typing to requester
            let is_typing = match db.get_typing(user_id, &requester_id).await {
                Ok(Some(_)) => true,
                _ => false,
            };

            let update = PresenceUpdate {
                user_id: user_id.clone(),
                status,
                custom_status_text: custom_status,
                last_seen: Some(Timestamp {
                    seconds: presence.last_seen / 1000,
                    nanos: ((presence.last_seen % 1000) * 1_000_000) as i32,
                }),
                updated_at: Some(Timestamp {
                    seconds: presence.updated_at / 1000,
                    nanos: ((presence.updated_at % 1000) * 1_000_000) as i32,
                }),
                is_typing,
                typing_in_conversation_with: if is_typing {
                    requester_id.clone()
                } else {
                    String::new()
                },
            };

            if tx.send(Ok(update)).await.is_err() {
                tracing::debug!("Subscription channel closed");
                return;
            }
        }

        // Polling loop for updates (in production, this would use NATS subscription)
        // For MVP, we poll every 5 seconds
        let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(5));

        loop {
            interval.tick().await;

            for user_id in &user_ids {
                let presence = match db.get_presence(user_id).await {
                    Ok(Some(p)) => p,
                    Ok(None) => continue,
                    Err(e) => {
                        tracing::warn!(user_id = %user_id, error = %e, "Failed to get presence");
                        continue;
                    }
                };

                // Handle INVISIBLE status
                let (status, custom_status) = if presence.status == 4 {
                    (0, String::new())
                } else {
                    (presence.status, presence.custom_status_text.clone())
                };

                // Check typing
                let is_typing = match db.get_typing(user_id, &requester_id).await {
                    Ok(Some(_)) => true,
                    _ => false,
                };

                let update = PresenceUpdate {
                    user_id: user_id.clone(),
                    status,
                    custom_status_text: custom_status,
                    last_seen: Some(Timestamp {
                        seconds: presence.last_seen / 1000,
                        nanos: ((presence.last_seen % 1000) * 1_000_000) as i32,
                    }),
                    updated_at: Some(Timestamp {
                        seconds: presence.updated_at / 1000,
                        nanos: ((presence.updated_at % 1000) * 1_000_000) as i32,
                    }),
                    is_typing,
                    typing_in_conversation_with: if is_typing {
                        requester_id.clone()
                    } else {
                        String::new()
                    },
                };

                if tx.send(Ok(update)).await.is_err() {
                    tracing::debug!("Subscription channel closed, ending subscription");
                    return;
                }
            }
        }
    });

    Ok(Response::new(ReceiverStream::new(rx)))
}
