/// Contacts management handlers
use crate::{
    db::{Contact as DbContact, DatabaseClient},
    jwt,
    proto::auth::*,
    proto::common::{error_response::ErrorCode, *},
};
use tracing::{error, info, warn};
use uuid::Uuid;

const DEFAULT_LIST_LIMIT: u32 = 50;
const MAX_LIST_LIMIT: u32 = 100;

/// Convert database Contact to proto Contact
fn db_contact_to_proto(
    db_contact: &DbContact,
    user_profile: Option<&crate::db::UserProfile>,
) -> Contact {
    Contact {
        contact_id: db_contact.contact_id.clone(),
        user_id: db_contact.contact_user_id.clone(),
        username: user_profile
            .map(|p| p.username.clone())
            .unwrap_or_default(),
        display_name: user_profile
            .and_then(|p| p.display_name.clone())
            .unwrap_or_default(),
        avatar_media_id: user_profile
            .and_then(|p| p.avatar_media_id.clone())
            .unwrap_or_default(),
        nickname: db_contact.nickname.clone().unwrap_or_default(),
        notes: db_contact.notes.clone().unwrap_or_default(),
        added_at: Some(Timestamp {
            seconds: db_contact.added_at,
            nanos: 0,
        }),
    }
}

/// Handle AddContact RPC
pub async fn handle_add_contact(
    request: AddContactRequest,
    db: DatabaseClient,
    jwt_secret: &str,
) -> AddContactResponse {
    // Validate access token
    let owner_user_id = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(claims) => claims.sub,
        Err(e) => {
            warn!("Invalid access token for add_contact: {}", e);
            return AddContactResponse {
                result: Some(add_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired access token".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    let contact_user_id = request.user_id.trim();

    // Validate contact user ID
    if contact_user_id.is_empty() {
        warn!("Empty contact user_id");
        return AddContactResponse {
            result: Some(add_contact_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "User ID cannot be empty".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    // Cannot add yourself as contact
    if contact_user_id == owner_user_id {
        warn!("User {} tried to add themselves as contact", owner_user_id);
        return AddContactResponse {
            result: Some(add_contact_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "Cannot add yourself as a contact".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    // Verify contact user exists
    let contact_profile = match db.get_user_by_id(contact_user_id).await {
        Ok(Some(profile)) => profile,
        Ok(None) => {
            warn!("Contact user not found: {}", contact_user_id);
            return AddContactResponse {
                result: Some(add_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "User not found".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
        Err(e) => {
            error!("Failed to lookup user: {}", e);
            return AddContactResponse {
                result: Some(add_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to verify user".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    // Create contact (use DbContact for database storage)
    let db_contact = DbContact {
        contact_id: Uuid::new_v4().to_string(),
        owner_user_id: owner_user_id.clone(),
        contact_user_id: contact_user_id.to_string(),
        nickname: if request.nickname.is_empty() {
            None
        } else {
            Some(request.nickname.clone())
        },
        notes: if request.notes.is_empty() {
            None
        } else {
            Some(request.notes.clone())
        },
        added_at: chrono::Utc::now().timestamp(),
    };

    match db.add_contact(&db_contact).await {
        Ok(()) => {
            info!(
                "User {} added contact {}",
                owner_user_id, contact_user_id
            );

            AddContactResponse {
                result: Some(add_contact_response::Result::Contact(db_contact_to_proto(
                    &db_contact,
                    Some(&contact_profile),
                ))),
            }
        }
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("already exists") {
                warn!(
                    "Contact {} already exists for user {}",
                    contact_user_id, owner_user_id
                );
                AddContactResponse {
                    result: Some(add_contact_response::Result::Error(ErrorResponse {
                        code: ErrorCode::Conflict as i32,
                        message: "Contact already exists".to_string(),
                        details: std::collections::HashMap::new(),
                    })),
                }
            } else {
                error!("Failed to add contact: {}", e);
                AddContactResponse {
                    result: Some(add_contact_response::Result::Error(ErrorResponse {
                        code: ErrorCode::InternalError as i32,
                        message: "Failed to add contact".to_string(),
                        details: std::collections::HashMap::new(),
                    })),
                }
            }
        }
    }
}

/// Handle RemoveContact RPC
pub async fn handle_remove_contact(
    request: RemoveContactRequest,
    db: DatabaseClient,
    jwt_secret: &str,
) -> RemoveContactResponse {
    // Validate access token
    let owner_user_id = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(claims) => claims.sub,
        Err(e) => {
            warn!("Invalid access token for remove_contact: {}", e);
            return RemoveContactResponse {
                result: Some(remove_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired access token".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    let contact_user_id = request.user_id.trim();

    if contact_user_id.is_empty() {
        warn!("Empty contact user_id for removal");
        return RemoveContactResponse {
            result: Some(remove_contact_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "User ID cannot be empty".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    match db.remove_contact(&owner_user_id, contact_user_id).await {
        Ok(()) => {
            info!(
                "User {} removed contact {}",
                owner_user_id, contact_user_id
            );

            RemoveContactResponse {
                result: Some(remove_contact_response::Result::Success(
                    RemoveContactSuccess {
                        user_id: contact_user_id.to_string(),
                        message: "Contact removed successfully".to_string(),
                    },
                )),
            }
        }
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("not found") {
                warn!(
                    "Contact {} not found for user {}",
                    contact_user_id, owner_user_id
                );
                RemoveContactResponse {
                    result: Some(remove_contact_response::Result::Error(ErrorResponse {
                        code: ErrorCode::NotFound as i32,
                        message: "Contact not found".to_string(),
                        details: std::collections::HashMap::new(),
                    })),
                }
            } else {
                error!("Failed to remove contact: {}", e);
                RemoveContactResponse {
                    result: Some(remove_contact_response::Result::Error(ErrorResponse {
                        code: ErrorCode::InternalError as i32,
                        message: "Failed to remove contact".to_string(),
                        details: std::collections::HashMap::new(),
                    })),
                }
            }
        }
    }
}

/// Handle ListContacts RPC
pub async fn handle_list_contacts(
    request: ListContactsRequest,
    db: DatabaseClient,
    jwt_secret: &str,
) -> ListContactsResponse {
    // Validate access token
    let owner_user_id = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(claims) => claims.sub,
        Err(e) => {
            warn!("Invalid access token for list_contacts: {}", e);
            return ListContactsResponse {
                result: Some(list_contacts_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired access token".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    let limit = if request.limit == 0 {
        DEFAULT_LIST_LIMIT
    } else {
        request.limit.min(MAX_LIST_LIMIT)
    };

    let cursor = if request.cursor.is_empty() {
        None
    } else {
        Some(request.cursor.as_str())
    };

    match db.list_contacts(&owner_user_id, limit, cursor).await {
        Ok((contacts, next_cursor, total_count)) => {
            info!(
                "Listed {} contacts for user {} (total: {})",
                contacts.len(),
                owner_user_id,
                total_count
            );

            // Enrich contacts with user profiles
            let mut proto_contacts = Vec::new();
            for contact in &contacts {
                let profile = db.get_user_by_id(&contact.contact_user_id).await.ok().flatten();
                proto_contacts.push(db_contact_to_proto(contact, profile.as_ref()));
            }

            ListContactsResponse {
                result: Some(list_contacts_response::Result::Success(
                    ListContactsSuccess {
                        contacts: proto_contacts,
                        next_cursor: next_cursor.unwrap_or_default(),
                        total_count,
                    },
                )),
            }
        }
        Err(e) => {
            error!("Failed to list contacts: {}", e);
            ListContactsResponse {
                result: Some(list_contacts_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to list contacts".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            }
        }
    }
}

/// Handle GetContact RPC
pub async fn handle_get_contact(
    request: GetContactRequest,
    db: DatabaseClient,
    jwt_secret: &str,
) -> GetContactResponse {
    // Validate access token
    let owner_user_id = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(claims) => claims.sub,
        Err(e) => {
            warn!("Invalid access token for get_contact: {}", e);
            return GetContactResponse {
                result: Some(get_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired access token".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    let contact_user_id = request.user_id.trim();

    if contact_user_id.is_empty() {
        warn!("Empty contact user_id for get");
        return GetContactResponse {
            result: Some(get_contact_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "User ID cannot be empty".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    match db.get_contact(&owner_user_id, contact_user_id).await {
        Ok(Some(contact)) => {
            // Get user profile for enrichment
            let profile = db.get_user_by_id(contact_user_id).await.ok().flatten();

            GetContactResponse {
                result: Some(get_contact_response::Result::Contact(db_contact_to_proto(
                    &contact,
                    profile.as_ref(),
                ))),
            }
        }
        Ok(None) => {
            warn!(
                "Contact {} not found for user {}",
                contact_user_id, owner_user_id
            );
            GetContactResponse {
                result: Some(get_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::NotFound as i32,
                    message: "Contact not found".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            }
        }
        Err(e) => {
            error!("Failed to get contact: {}", e);
            GetContactResponse {
                result: Some(get_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::InternalError as i32,
                    message: "Failed to get contact".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            }
        }
    }
}

/// Handle UpdateContact RPC
pub async fn handle_update_contact(
    request: UpdateContactRequest,
    db: DatabaseClient,
    jwt_secret: &str,
) -> UpdateContactResponse {
    // Validate access token
    let owner_user_id = match jwt::validate_token(&request.access_token, jwt_secret) {
        Ok(claims) => claims.sub,
        Err(e) => {
            warn!("Invalid access token for update_contact: {}", e);
            return UpdateContactResponse {
                result: Some(update_contact_response::Result::Error(ErrorResponse {
                    code: ErrorCode::Unauthorized as i32,
                    message: "Invalid or expired access token".to_string(),
                    details: std::collections::HashMap::new(),
                })),
            };
        }
    };

    let contact_user_id = request.user_id.trim();

    if contact_user_id.is_empty() {
        warn!("Empty contact user_id for update");
        return UpdateContactResponse {
            result: Some(update_contact_response::Result::Error(ErrorResponse {
                code: ErrorCode::InvalidRequest as i32,
                message: "User ID cannot be empty".to_string(),
                details: std::collections::HashMap::new(),
            })),
        };
    }

    let nickname = if request.nickname.is_empty() {
        None
    } else {
        Some(request.nickname.clone())
    };

    let notes = if request.notes.is_empty() {
        None
    } else {
        Some(request.notes.clone())
    };

    match db
        .update_contact(
            &owner_user_id,
            contact_user_id,
            nickname,
            notes,
            request.clear_nickname,
            request.clear_notes,
        )
        .await
    {
        Ok(contact) => {
            info!(
                "User {} updated contact {}",
                owner_user_id, contact_user_id
            );

            // Get user profile for enrichment
            let profile = db.get_user_by_id(contact_user_id).await.ok().flatten();

            UpdateContactResponse {
                result: Some(update_contact_response::Result::Contact(
                    db_contact_to_proto(&contact, profile.as_ref()),
                )),
            }
        }
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("not found") {
                warn!(
                    "Contact {} not found for user {}",
                    contact_user_id, owner_user_id
                );
                UpdateContactResponse {
                    result: Some(update_contact_response::Result::Error(ErrorResponse {
                        code: ErrorCode::NotFound as i32,
                        message: "Contact not found".to_string(),
                        details: std::collections::HashMap::new(),
                    })),
                }
            } else {
                error!("Failed to update contact: {}", e);
                UpdateContactResponse {
                    result: Some(update_contact_response::Result::Error(ErrorResponse {
                        code: ErrorCode::InternalError as i32,
                        message: "Failed to update contact".to_string(),
                        details: std::collections::HashMap::new(),
                    })),
                }
            }
        }
    }
}
