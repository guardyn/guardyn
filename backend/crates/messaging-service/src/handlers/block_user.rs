/// Handler for blocking/unblocking users and managing blocked users list
use crate::db::DatabaseClient;
use crate::proto::common::{ErrorResponse, Timestamp};
use crate::proto::messaging::{
    block_user_response, unblock_user_response, get_blocked_users_response,
    BlockUserRequest, BlockUserResponse, BlockUserSuccess,
    UnblockUserRequest, UnblockUserResponse, UnblockUserSuccess,
    GetBlockedUsersRequest, GetBlockedUsersResponse, GetBlockedUsersSuccess,
};
use std::sync::Arc;
use tonic::{Request, Response, Status};

/// Block a user from messaging you
pub async fn block_user(
    db: Arc<DatabaseClient>,
    request: Request<BlockUserRequest>,
) -> Result<Response<BlockUserResponse>, Status> {
    let req = request.into_inner();

    tracing::info!(
        blocked_user_id = %req.blocked_user_id,
        token_length = req.access_token.len(),
        "BlockUser handler invoked"
    );

    // Validate JWT token and extract user_id
    let jwt_secret = crate::config::get_jwt_secret();

    let user_id = match crate::jwt::validate_and_extract(&req.access_token, &jwt_secret) {
        Ok((uid, _device_id, _username)) => uid,
        Err(_) => {
            tracing::warn!("BlockUser: JWT validation failed");
            return Ok(Response::new(BlockUserResponse {
                result: Some(block_user_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate blocked_user_id
    if req.blocked_user_id.is_empty() {
        return Ok(Response::new(BlockUserResponse {
            result: Some(block_user_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Blocked user ID required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Cannot block yourself
    if user_id == req.blocked_user_id {
        return Ok(Response::new(BlockUserResponse {
            result: Some(block_user_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "Cannot block yourself".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Block the user (username can be empty if not known)
    match db.block_user(&user_id, &req.blocked_user_id, "").await {
        Ok(blocked_at) => {
            tracing::info!(
                user_id = %user_id,
                blocked_user_id = %req.blocked_user_id,
                "User blocked successfully"
            );

            Ok(Response::new(BlockUserResponse {
                result: Some(block_user_response::Result::Success(BlockUserSuccess {
                    blocked_user_id: req.blocked_user_id,
                    blocked_at: Some(Timestamp {
                        seconds: blocked_at / 1000,
                        nanos: ((blocked_at % 1000) * 1_000_000) as i32,
                    }),
                })),
            }))
        }
        Err(e) => {
            tracing::error!("Failed to block user: {}", e);
            Ok(Response::new(BlockUserResponse {
                result: Some(block_user_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to block user".to_string(),
                    details: Default::default(),
                })),
            }))
        }
    }
}

/// Unblock a previously blocked user
pub async fn unblock_user(
    db: Arc<DatabaseClient>,
    request: Request<UnblockUserRequest>,
) -> Result<Response<UnblockUserResponse>, Status> {
    let req = request.into_inner();

    tracing::info!(
        user_id_to_unblock = %req.user_id,
        token_length = req.access_token.len(),
        "UnblockUser handler invoked"
    );

    // Validate JWT token and extract user_id
    let jwt_secret = crate::config::get_jwt_secret();

    let user_id = match crate::jwt::validate_and_extract(&req.access_token, &jwt_secret) {
        Ok((uid, _device_id, _username)) => uid,
        Err(_) => {
            tracing::warn!("UnblockUser: JWT validation failed");
            return Ok(Response::new(UnblockUserResponse {
                result: Some(unblock_user_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Validate user_id to unblock
    if req.user_id.is_empty() {
        return Ok(Response::new(UnblockUserResponse {
            result: Some(unblock_user_response::Result::Error(ErrorResponse {
                code: 3, // INVALID_ARGUMENT
                message: "User ID to unblock required".to_string(),
                details: Default::default(),
            })),
        }));
    }

    // Unblock the user
    match db.unblock_user(&user_id, &req.user_id).await {
        Ok(()) => {
            tracing::info!(
                user_id = %user_id,
                unblocked_user_id = %req.user_id,
                "User unblocked successfully"
            );

            Ok(Response::new(UnblockUserResponse {
                result: Some(unblock_user_response::Result::Success(UnblockUserSuccess {
                    user_id: req.user_id,
                })),
            }))
        }
        Err(e) => {
            tracing::error!("Failed to unblock user: {}", e);
            Ok(Response::new(UnblockUserResponse {
                result: Some(unblock_user_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to unblock user".to_string(),
                    details: Default::default(),
                })),
            }))
        }
    }
}

/// Get list of blocked users
pub async fn get_blocked_users(
    db: Arc<DatabaseClient>,
    request: Request<GetBlockedUsersRequest>,
) -> Result<Response<GetBlockedUsersResponse>, Status> {
    let req = request.into_inner();

    tracing::info!(
        token_length = req.access_token.len(),
        "GetBlockedUsers handler invoked"
    );

    // Validate JWT token and extract user_id
    let jwt_secret = crate::config::get_jwt_secret();

    let user_id = match crate::jwt::validate_and_extract(&req.access_token, &jwt_secret) {
        Ok((uid, _device_id, _username)) => uid,
        Err(_) => {
            tracing::warn!("GetBlockedUsers: JWT validation failed");
            return Ok(Response::new(GetBlockedUsersResponse {
                result: Some(get_blocked_users_response::Result::Error(ErrorResponse {
                    code: 16, // UNAUTHENTICATED
                    message: "Invalid or expired access token".to_string(),
                    details: Default::default(),
                })),
            }));
        }
    };

    // Get blocked users
    match db.get_blocked_users(&user_id).await {
        Ok(blocked_users) => {
            tracing::info!(
                user_id = %user_id,
                count = blocked_users.len(),
                "Retrieved blocked users list"
            );

            Ok(Response::new(GetBlockedUsersResponse {
                result: Some(get_blocked_users_response::Result::Success(GetBlockedUsersSuccess {
                    blocked_users,
                })),
            }))
        }
        Err(e) => {
            tracing::error!("Failed to get blocked users: {}", e);
            Ok(Response::new(GetBlockedUsersResponse {
                result: Some(get_blocked_users_response::Result::Error(ErrorResponse {
                    code: 13, // INTERNAL
                    message: "Failed to get blocked users".to_string(),
                    details: Default::default(),
                })),
            }))
        }
    }
}
