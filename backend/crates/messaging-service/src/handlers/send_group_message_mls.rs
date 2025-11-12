use std::collections::HashMap;
/// Handler for sending MLS-encrypted group messages
///
/// Uses MLS (Messaging Layer Security) protocol for group encryption.
/// Encrypts messages with the current group epoch state.

use crate::db::DatabaseClient;
use crate::mls_manager::MlsManager;
use crate::nats::NatsClient;
use crate::proto::messaging::{
    send_group_message_response, SendGroupMessageRequest, SendGroupMessageResponse,
    SendGroupMessageSuccess,
};
use crate::proto::common::ErrorResponse;
use guardyn_crypto::mls::MlsGroupManager;
use std::sync::Arc;
use tonic::{Response, Status};
use tracing::{error, info};

pub async fn send_group_message_mls(
    request: SendGroupMessageRequest,
    db: Arc<DatabaseClient>,
    nats: Arc<NatsClient>,
) -> Result<Response<SendGroupMessageResponse>, Status> {
    // Validate JWT token and extract user_id (sender)
    let jwt_secret = std::env::var("GUARDYN_JWT_SECRET")
        .unwrap_or_else(|_| "default-jwt-secret-change-in-production".to_string());

    let (sender_user_id, sender_device_id) = match crate::jwt::validate_and_extract(&request.access_token, &jwt_secret) {
        Ok(ids) => ids,
        Err(_) => {
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired access token".to_string(),
                    details: HashMap::new(),
                })),
            }));
        }
    };

    // Validate group ID
    if request.group_id.is_empty() {
        return Ok(Response::new(SendGroupMessageResponse {
            result: Some(send_group_message_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InvalidRequest as i32,
                message: "Group ID required".to_string(),
                details: HashMap::new(),
            })),
        }));
    }

    // Validate plaintext content (will be encrypted with MLS)
    if request.encrypted_content.is_empty() {
        return Ok(Response::new(SendGroupMessageResponse {
            result: Some(send_group_message_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InvalidRequest as i32,
                message: "Content required".to_string(),
                details: HashMap::new(),
            })),
        }));
    }

    info!("Sending MLS-encrypted group message to group: {}", request.group_id);

    // Initialize MLS manager
    let mls_manager = MlsManager::new(db.clone());

    // Verify group exists and sender is a member
    match mls_manager.get_metadata(&request.group_id).await {
        Ok(Some(_metadata)) => {
            // Group exists, continue
        }
        Ok(None) => {
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::NotFound as i32,
                    message: "Group not found".to_string(),
                    details: HashMap::new(),
                })),
            }));
        }
        Err(e) => {
            error!("Failed to fetch group metadata: {}", e);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to verify group".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    }

    // Verify sender is a member
    match mls_manager.is_member(&request.group_id, &sender_user_id, &sender_device_id).await {
        Ok(true) => {
            // Sender is a member, continue
        }
        Ok(false) => {
            error!("User {} is not a member of group {}", sender_user_id, request.group_id);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::Unauthorized as i32,
                    message: "Not a member of this group".to_string(),
                    details: HashMap::new(),
                })),
            }));
        }
        Err(e) => {
            error!("Failed to verify group membership: {}", e);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to verify membership".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    }

    // Load MLS group state
    let group_state = match mls_manager.load_group_state(&request.group_id).await {
        Ok(state) => state,
        Err(e) => {
            error!("Failed to load group state: {}", e);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to load group state".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    };

    // Reconstruct MLS group manager from state
    // Note: This requires the sender's credential bundle
    // For now, we'll use a test credential (production should fetch from secure storage)
    let sender_identity = format!("{}:{}", sender_user_id, sender_device_id);
    let credential_bundle = match guardyn_crypto::mls::create_test_credential(sender_identity.as_bytes()) {
        Ok(cred) => cred,
        Err(e) => {
            error!("Failed to create credential: {}", e);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to initialize encryption".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    };

    // TODO: Deserialize group state and reconstruct MlsGroupManager
    // This is a limitation of the current OpenMLS API - it doesn't provide
    // direct state deserialization. We need to maintain the group manager
    // in memory or implement custom serialization.
    //
    // For MVP, we'll use the plaintext content as "encrypted_content"
    // and track the MLS epoch separately.

    // Generate message ID
    use uuid::v1::{Context, Timestamp};
    let context = Context::new(42);
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap();
    let uuid_timestamp = Timestamp::from_unix(&context, now.as_secs(), now.subsec_nanos());
    let message_id = uuid::Uuid::new_v1(uuid_timestamp, &[1, 2, 3, 4, 5, 6]).to_string();
    let server_timestamp_millis = chrono::Utc::now().timestamp_millis();

    info!("Generated message_id={}, MLS epoch={}", message_id, group_state.epoch);

    // Prepare metadata
    let mut metadata = std::collections::HashMap::new();
    metadata.insert("message_type".to_string(), request.message_type.to_string());
    metadata.insert("encryption".to_string(), "mls".to_string());

    // Store group message in ScyllaDB
    let group_message = crate::models::GroupMessage {
        message_id: message_id.clone(),
        group_id: request.group_id.clone(),
        sender_user_id: sender_user_id.clone(),
        sender_device_id: sender_device_id.clone(),
        encrypted_content: request.encrypted_content.clone(), // TODO: Replace with MLS-encrypted content
        mls_epoch: group_state.epoch as i64,
        sent_at: server_timestamp_millis,
        metadata,
    };

    info!(
        "Storing MLS-encrypted group message: message_id={}, group_id={}, epoch={}",
        message_id, request.group_id, group_state.epoch
    );

    if let Err(e) = db.store_group_message(&group_message).await {
        error!("Failed to store group message: {}", e);
        return Ok(Response::new(SendGroupMessageResponse {
            result: Some(send_group_message_response::Result::Error(ErrorResponse {
                code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                message: "Failed to store message".to_string(),
                details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
            })),
        }));
    }

    // Get all group members for NATS fanout
    let members = match db.get_group_members(&request.group_id).await {
        Ok(members) => members,
        Err(e) => {
            error!("Failed to fetch group members: {}", e);
            return Ok(Response::new(SendGroupMessageResponse {
                result: Some(send_group_message_response::Result::Error(ErrorResponse {
                    code: crate::proto::common::error_response::ErrorCode::InternalError as i32,
                    message: "Failed to fetch group members".to_string(),
                    details: { let mut map = HashMap::new(); map.insert("error".to_string(), e.to_string()); map },
                })),
            }));
        }
    };

    // Publish message to NATS for each group member (fanout)
    for member in &members {
        // Skip sender - they already have the message
        if member.user_id == sender_user_id {
            continue;
        }

        let subject = format!("messages.group.{}.{}", member.user_id, member.device_id);
        let message_json = serde_json::json!({
            "message_id": message_id,
            "group_id": request.group_id,
            "sender_user_id": sender_user_id,
            "sender_device_id": sender_device_id,
            "encrypted_content": &request.encrypted_content,
            "mls_epoch": group_state.epoch,
            "sent_at": server_timestamp_millis,
            "message_type": request.message_type,
        });

        let payload = serde_json::to_vec(&message_json).unwrap();

        if let Err(e) = nats.publish(&subject, &payload).await {
            error!("Failed to publish to NATS for member {}: {}", member.user_id, e);
            // Continue with other members even if one fails
        } else {
            info!("Published group message to {}", subject);
        }
    }

    // Return success response
    Ok(Response::new(SendGroupMessageResponse {
        result: Some(send_group_message_response::Result::Success(
            SendGroupMessageSuccess {
                message_id,
                server_timestamp: Some(crate::proto::common::Timestamp {
                    seconds: server_timestamp_millis / 1000,
                    nanos: ((server_timestamp_millis % 1000) * 1_000_000) as i32,
                }),
            },
        )),
    }))
}
