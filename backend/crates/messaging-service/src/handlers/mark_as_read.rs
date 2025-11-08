/// Handler for marking messages as read
use crate::db::DatabaseClient;
use crate::models::DeliveryStatus;
use crate::proto::messaging::{
    mark_as_read_response, MarkAsReadRequest, MarkAsReadResponse, MarkAsReadSuccess,
};
use crate::proto::common::{ErrorResponse, Timestamp};
use std::sync::Arc;
use tonic::{Response, Status};

pub async fn mark_as_read(
    request: MarkAsReadRequest,
    db: Arc<DatabaseClient>,
) -> Result<Response<MarkAsReadResponse>, Status> {
    // Validate token
    if request.access_token.is_empty() {
        return Ok(Response::new(MarkAsReadResponse {
            result: Some(mark_as_read_response::Result::Error(ErrorResponse {
                code: 16, // UNAUTHENTICATED
                message: "Invalid access token".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Validate message IDs
    if request.message_ids.is_empty() {
        return Ok(Response::new(MarkAsReadResponse {
            result: Some(mark_as_read_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "At least one message ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    let timestamp = chrono::Utc::now().timestamp();

    // Update delivery status for each message
    for message_id in &request.message_ids {
        if let Err(e) = db
            .update_delivery_status(message_id, DeliveryStatus::Read)
            .await
        {
            tracing::error!("Failed to mark message {} as read: {}", message_id, e);
            // Continue with other messages
        }
    }

    Ok(Response::new(MarkAsReadResponse {
        result: Some(mark_as_read_response::Result::Success(
            MarkAsReadSuccess {
                marked_count: request.message_ids.len() as i32,
                timestamp: Some(Timestamp {
                    seconds: timestamp,
                    nanos: 0,
                }),
            },
        )),
    }))
}
