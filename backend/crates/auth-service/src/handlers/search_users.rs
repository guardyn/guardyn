/// Search users by username handler
use crate::{
    db::DatabaseClient, 
    proto::auth::*, 
    proto::common::{error_response::ErrorCode, *}
};
use tracing::{error, info, warn};

const DEFAULT_SEARCH_LIMIT: u32 = 20;
const MAX_SEARCH_LIMIT: u32 = 100;

pub async fn handle_search_users(
    request: SearchUsersRequest,
    db: DatabaseClient,
) -> SearchUsersResponse {
    let query = request.query.trim();

    // Validate query
    if query.is_empty() {
        warn!("Empty search query");
        return SearchUsersResponse {
            result: Some(search_users_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Search query cannot be empty".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    if query.len() < 2 {
        warn!("Search query too short: {}", query);
        return SearchUsersResponse {
            result: Some(search_users_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Search query must be at least 2 characters".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    // Apply limit
    let limit = if request.limit == 0 {
        DEFAULT_SEARCH_LIMIT
    } else {
        request.limit.min(MAX_SEARCH_LIMIT)
    };

    info!("Searching users with query: '{}', limit: {}", query, limit);

    // Search for users by username prefix
    match db.search_users_by_username(query, limit).await {
        Ok(users) => {
            info!("Found {} users matching query '{}'", users.len(), query);

            let results = users
                .into_iter()
                .map(|user| UserSearchResult {
                    user_id: user.user_id,
                    username: user.username,
                    created_at: Some(Timestamp {
                        seconds: user.created_at,
                        nanos: 0,
                    }),
                })
                .collect();

            SearchUsersResponse {
                result: Some(search_users_response::Result::Success(
                    SearchUsersSuccess { users: results },
                )),
            }
        }
        Err(e) => {
            error!("Failed to search users: {}", e);
            SearchUsersResponse {
                result: Some(search_users_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: format!("Failed to search users: {}", e),
                    details: std::collections::HashMap::new(),
                })),
            }
        }
    }
}
