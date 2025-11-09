/// Key bundle handlers - for E2EE key exchange

use crate::{AuthServiceImpl, proto::auth::*, proto::common::*};
use tonic::{Request, Response, Status};

/// Get key bundle for a user
pub async fn get(
    service: &AuthServiceImpl,
    request: Request<GetKeyBundleRequest>,
) -> Result<Response<GetKeyBundleResponse>, Status> {
    let req = request.into_inner();

    // Get key bundle from database
    match service.db.get_key_bundle(&req.user_id, &req.device_id).await {
        Ok(Some(kb)) => {
            let key_bundle = KeyBundle {
                identity_key: kb.identity_key,
                signed_pre_key: kb.signed_pre_key,
                signed_pre_key_signature: kb.signed_pre_key_signature,
                one_time_pre_keys: kb.one_time_pre_keys,
                created_at: Some(Timestamp {
                    seconds: kb.created_at,
                    nanos: 0,
                }),
            };

        let success = GetKeyBundleSuccess {
            user_id: req.user_id.clone(),
            device_id: req.device_id.clone(),
            key_bundle: Some(key_bundle),
        };            Ok(Response::new(GetKeyBundleResponse {
                result: Some(get_key_bundle_response::Result::Success(success)),
            }))
        }
        Ok(None) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::NotFound as i32,
                message: "Key bundle not found".to_string(),
                details: std::collections::HashMap::new(),
            };
            Ok(Response::new(GetKeyBundleResponse {
                result: Some(get_key_bundle_response::Result::Error(error)),
            }))
        }
        Err(e) => {
            tracing::error!("Database error: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Internal server error".to_string(),
                details: std::collections::HashMap::new(),
            };
            Ok(Response::new(GetKeyBundleResponse {
                result: Some(get_key_bundle_response::Result::Error(error)),
            }))
        }
    }
}

/// Upload pre-keys for key rotation
pub async fn upload(
    service: &AuthServiceImpl,
    request: Request<UploadPreKeysRequest>,
) -> Result<Response<UploadPreKeysResponse>, Status> {
    let req = request.into_inner();

    // Validate access token
    let claims = match crate::jwt::validate_token(&req.access_token, &service.jwt_secret) {
        Ok(c) => c,
        Err(_) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Unauthorized as i32,
                message: "Invalid or expired token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(UploadPreKeysResponse {
                result: Some(upload_pre_keys_response::Result::Error(error)),
            }));
        }
    };

    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    // Update key bundle in database
    let key_bundle = crate::db::KeyBundle {
        identity_key: vec![], // Keep existing identity key
        signed_pre_key: vec![], // Signed pre-key not provided in this request
        signed_pre_key_signature: vec![], // Signature not provided in this request
        one_time_pre_keys: req.one_time_pre_keys.clone(),
        created_at: now,
    };

    let keys_count = req.one_time_pre_keys.len() as u32;

    match service.db.store_key_bundle(&claims.sub, &claims.device_id, &key_bundle).await {
        Ok(_) => {
            let success = UploadPreKeysSuccess {
                keys_uploaded: keys_count,
                total_keys_available: keys_count, // TODO: Query actual total from DB
            };
            Ok(Response::new(UploadPreKeysResponse {
                result: Some(upload_pre_keys_response::Result::Success(success)),
            }))
        }
        Err(e) => {
            tracing::error!("Failed to store key bundle: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to upload keys".to_string(),
                details: std::collections::HashMap::new(),
            };
            Ok(Response::new(UploadPreKeysResponse {
                result: Some(upload_pre_keys_response::Result::Error(error)),
            }))
        }
    }
}
