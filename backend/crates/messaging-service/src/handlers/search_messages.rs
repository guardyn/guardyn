/// Message Search Handler (Phase 2)
///
/// Provides server-side message retrieval for client-side search.
/// Since content is E2EE, actual search happens on the client.
/// Server returns messages matching time/type filters for client to decrypt and search.

use crate::db::DatabaseClient;
use crate::jwt::validate_access_token;
use proto::messaging::{
    SearchMessagesRequest, SearchMessagesResponse, SearchMessagesSuccess,
    SearchResult, MessageType,
    search_messages_response,
};
use proto::common::{ErrorResponse, Timestamp, error_response::ErrorCode};
use std::sync::Arc;
use tonic::{Request, Response, Status};
use tracing::{info, warn, error, instrument};

/// Search messages (returns encrypted content for client-side search)
#[instrument(skip(db, request), fields(user_id, query))]
pub async fn search_messages(
    db: Arc<DatabaseClient>,
    request: Request<SearchMessagesRequest>,
) -> Result<Response<SearchMessagesResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(SearchMessagesResponse {
                result: Some(search_messages_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    let user_id = claims.sub.clone();
    tracing::Span::current().record("user_id", &user_id);
    tracing::Span::current().record("query", &req.query);
    
    // Validate limit
    let limit = if req.limit <= 0 || req.limit > 100 {
        50 // Default limit
    } else {
        req.limit
    };
    
    // Build search parameters
    let search_params = SearchParams {
        user_id: user_id.clone(),
        conversation_id: if req.conversation_id.is_empty() { None } else { Some(req.conversation_id.clone()) },
        is_group: req.is_group,
        start_time: req.start_time.clone(),
        end_time: req.end_time.clone(),
        message_types: req.message_types.clone(),
        limit,
        cursor: if req.cursor.is_empty() { None } else { Some(req.cursor.clone()) },
    };
    
    // Fetch messages from database
    // Note: Server cannot search encrypted content, so it returns messages for client-side search
    match db.fetch_messages_for_search(&search_params).await {
        Ok((results, next_cursor, total_count)) => {
            info!(
                user_id = %user_id,
                query = %req.query,
                result_count = results.len(),
                total_count = total_count,
                "Search results retrieved successfully"
            );
            
            Ok(Response::new(SearchMessagesResponse {
                result: Some(search_messages_response::Result::Success(SearchMessagesSuccess {
                    results,
                    next_cursor: next_cursor.unwrap_or_default(),
                    has_more: next_cursor.is_some(),
                    total_count: total_count as i32,
                })),
            }))
        }
        Err(e) => {
            error!("Failed to search messages: {}", e);
            Ok(Response::new(SearchMessagesResponse {
                result: Some(search_messages_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to search messages: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}

/// Parameters for message search
pub struct SearchParams {
    pub user_id: String,
    pub conversation_id: Option<String>,
    pub is_group: bool,
    pub start_time: Option<Timestamp>,
    pub end_time: Option<Timestamp>,
    pub message_types: Vec<i32>,
    pub limit: i32,
    pub cursor: Option<String>,
}
