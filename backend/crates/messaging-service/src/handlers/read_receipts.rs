/// Enhanced Read Receipts Handler (Phase 2)
///
/// Provides detailed read receipt tracking for conversations.
/// Allows users to see who has read messages and when.

use crate::db::DatabaseClient;
use crate::jwt::validate_access_token;
use crate::proto::messaging::{
    SendReadReceiptRequest, SendReadReceiptResponse, SendReadReceiptSuccess,
    GetReadReceiptsRequest, GetReadReceiptsResponse, GetReadReceiptsSuccess,
    ReadReceipt,
    send_read_receipt_response, get_read_receipts_response,
};
use crate::proto::common::{ErrorResponse, Timestamp, error_response::ErrorCode};
use std::sync::Arc;
use tonic::{Request, Response, Status};
use tracing::{info, warn, error, instrument};

/// Send a read receipt for a conversation
#[instrument(skip(db, request), fields(user_id, conversation_id))]
pub async fn send_read_receipt(
    db: Arc<DatabaseClient>,
    request: Request<SendReadReceiptRequest>,
) -> Result<Response<SendReadReceiptResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(SendReadReceiptResponse {
                result: Some(send_read_receipt_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    let user_id = claims.sub.clone();
    tracing::Span::current().record("user_id", &user_id);
    tracing::Span::current().record("conversation_id", &req.conversation_id);
    
    // Validate required fields
    if req.conversation_id.is_empty() || req.last_read_message_id.is_empty() {
        return Ok(Response::new(SendReadReceiptResponse {
            result: Some(send_read_receipt_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "conversation_id and last_read_message_id are required".to_string(),
                details: Default::default(),
            })),
        }));
    }
    
    let now = chrono::Utc::now();
    let timestamp = Timestamp {
        seconds: now.timestamp(),
        nanos: now.timestamp_subsec_nanos() as i32,
    };
    
    // Store read receipt in database
    match db.save_read_receipt(
        &req.conversation_id,
        &user_id,
        &req.last_read_message_id,
        req.is_group,
    ).await {
        Ok(_) => {
            info!(
                user_id = %user_id,
                conversation_id = %req.conversation_id,
                last_read_message_id = %req.last_read_message_id,
                "Read receipt saved successfully"
            );
            
            // TODO: Broadcast read receipt to other participants via WebSocket/NATS
            
            Ok(Response::new(SendReadReceiptResponse {
                result: Some(send_read_receipt_response::Result::Success(SendReadReceiptSuccess {
                    timestamp: Some(timestamp),
                })),
            }))
        }
        Err(e) => {
            error!("Failed to save read receipt: {}", e);
            Ok(Response::new(SendReadReceiptResponse {
                result: Some(send_read_receipt_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to save read receipt: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}

/// Get all read receipts for a conversation
#[instrument(skip(db, request), fields(conversation_id))]
pub async fn get_read_receipts(
    db: Arc<DatabaseClient>,
    request: Request<GetReadReceiptsRequest>,
) -> Result<Response<GetReadReceiptsResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(GetReadReceiptsResponse {
                result: Some(get_read_receipts_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    tracing::Span::current().record("conversation_id", &req.conversation_id);
    
    // Validate required fields
    if req.conversation_id.is_empty() {
        return Ok(Response::new(GetReadReceiptsResponse {
            result: Some(get_read_receipts_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "conversation_id is required".to_string(),
                details: Default::default(),
            })),
        }));
    }
    
    // Get read receipts from database
    match db.get_read_receipts(
        &req.conversation_id,
        req.is_group,
    ).await {
        Ok(receipts) => {
            info!(
                conversation_id = %req.conversation_id,
                receipt_count = receipts.len(),
                "Retrieved read receipts successfully"
            );
            
            Ok(Response::new(GetReadReceiptsResponse {
                result: Some(get_read_receipts_response::Result::Success(GetReadReceiptsSuccess {
                    receipts,
                })),
            }))
        }
        Err(e) => {
            error!("Failed to get read receipts: {}", e);
            Ok(Response::new(GetReadReceiptsResponse {
                result: Some(get_read_receipts_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to get read receipts: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}
