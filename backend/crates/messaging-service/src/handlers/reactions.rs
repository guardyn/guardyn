/// Message Reactions Handler (Phase 2)
///
/// Handles adding, removing, and retrieving reactions on messages.
/// Reactions are stored in ScyllaDB for efficient retrieval.

use crate::db::DatabaseClient;
use crate::jwt::validate_access_token;
use crate::proto::messaging::{
    AddReactionRequest, AddReactionResponse, AddReactionSuccess,
    RemoveReactionRequest, RemoveReactionResponse, RemoveReactionSuccess,
    GetReactionsRequest, GetReactionsResponse, GetReactionsSuccess,
    Reaction,
    add_reaction_response, remove_reaction_response, get_reactions_response,
};
use crate::proto::common::{ErrorResponse, Timestamp, error_response::ErrorCode};
use std::sync::Arc;
use tonic::{Request, Response, Status};
use tracing::{info, warn, error, instrument};
use uuid::Uuid;

/// Add a reaction to a message
#[instrument(skip(db, request), fields(user_id, message_id))]
pub async fn add_reaction(
    db: Arc<DatabaseClient>,
    request: Request<AddReactionRequest>,
) -> Result<Response<AddReactionResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(AddReactionResponse {
                result: Some(add_reaction_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    let user_id = claims.sub.clone();
    tracing::Span::current().record("user_id", &user_id);
    tracing::Span::current().record("message_id", &req.message_id);
    
    // Validate emoji (must be a valid Unicode emoji, max 32 bytes)
    if req.emoji.is_empty() || req.emoji.len() > 32 {
        return Ok(Response::new(AddReactionResponse {
            result: Some(add_reaction_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Invalid emoji: must be 1-32 bytes".to_string(),
                details: Default::default(),
            })),
        }));
    }
    
    // Generate reaction ID
    let reaction_id = Uuid::new_v4().to_string();
    let now = chrono::Utc::now();
    let timestamp = Timestamp {
        seconds: now.timestamp(),
        nanos: now.timestamp_subsec_nanos() as i32,
    };
    
    // Store reaction in database
    match db.add_reaction(
        &req.message_id,
        &req.conversation_id,
        &user_id,
        &req.emoji,
        &reaction_id,
        req.is_group,
    ).await {
        Ok(_) => {
            info!(
                user_id = %user_id,
                message_id = %req.message_id,
                emoji = %req.emoji,
                "Reaction added successfully"
            );
            
            Ok(Response::new(AddReactionResponse {
                result: Some(add_reaction_response::Result::Success(AddReactionSuccess {
                    reaction: Some(Reaction {
                        reaction_id,
                        message_id: req.message_id,
                        user_id,
                        emoji: req.emoji,
                        created_at: Some(timestamp),
                    }),
                })),
            }))
        }
        Err(e) => {
            error!("Failed to add reaction: {}", e);
            Ok(Response::new(AddReactionResponse {
                result: Some(add_reaction_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to add reaction: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}

/// Remove a reaction from a message
#[instrument(skip(db, request), fields(user_id, message_id))]
pub async fn remove_reaction(
    db: Arc<DatabaseClient>,
    request: Request<RemoveReactionRequest>,
) -> Result<Response<RemoveReactionResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(RemoveReactionResponse {
                result: Some(remove_reaction_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    let user_id = claims.sub.clone();
    tracing::Span::current().record("user_id", &user_id);
    tracing::Span::current().record("message_id", &req.message_id);
    
    // Remove reaction from database (user can only remove their own reactions)
    match db.remove_reaction(
        &req.message_id,
        &req.conversation_id,
        &user_id,
        &req.emoji,
        req.is_group,
    ).await {
        Ok(removed) => {
            if removed {
                info!(
                    user_id = %user_id,
                    message_id = %req.message_id,
                    emoji = %req.emoji,
                    "Reaction removed successfully"
                );
            } else {
                info!(
                    user_id = %user_id,
                    message_id = %req.message_id,
                    emoji = %req.emoji,
                    "Reaction not found (already removed or never existed)"
                );
            }
            
            Ok(Response::new(RemoveReactionResponse {
                result: Some(remove_reaction_response::Result::Success(RemoveReactionSuccess {
                    removed,
                })),
            }))
        }
        Err(e) => {
            error!("Failed to remove reaction: {}", e);
            Ok(Response::new(RemoveReactionResponse {
                result: Some(remove_reaction_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to remove reaction: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}

/// Get all reactions for a message
#[instrument(skip(db, request), fields(message_id))]
pub async fn get_reactions(
    db: Arc<DatabaseClient>,
    request: Request<GetReactionsRequest>,
) -> Result<Response<GetReactionsResponse>, Status> {
    let req = request.into_inner();
    
    // Validate token
    let claims = match validate_access_token(&req.access_token) {
        Ok(c) => c,
        Err(e) => {
            warn!("Invalid access token: {}", e);
            return Ok(Response::new(GetReactionsResponse {
                result: Some(get_reactions_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };
    
    tracing::Span::current().record("message_id", &req.message_id);
    
    // Get reactions from database
    match db.get_reactions(
        &req.message_id,
        &req.conversation_id,
        req.is_group,
    ).await {
        Ok(reactions) => {
            info!(
                message_id = %req.message_id,
                reaction_count = reactions.len(),
                "Retrieved reactions successfully"
            );
            
            Ok(Response::new(GetReactionsResponse {
                result: Some(get_reactions_response::Result::Success(GetReactionsSuccess {
                    reactions,
                })),
            }))
        }
        Err(e) => {
            error!("Failed to get reactions: {}", e);
            Ok(Response::new(GetReactionsResponse {
                result: Some(get_reactions_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to get reactions: {}", e),
                    details: Default::default(),
                })),
            }))
        }
    }
}
