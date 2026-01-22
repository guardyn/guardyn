//! Request handlers for notification service

use anyhow::Result;
use chrono::{Duration, Utc};
use tracing::{debug, warn};

use crate::db::{DeviceRegistration, NotificationDb, StoredNotificationSettings};
use crate::generated::guardyn::notifications::*;
use crate::push::{PushDevice, PushPayload, PushPlatform, PushPriority, PushService};

/// Validate JWT token and extract user ID
pub fn validate_token(token: &str, jwt_secret: &str) -> Result<String, ErrorCode> {
    use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
    use serde::Deserialize;

    #[derive(Debug, Deserialize)]
    struct Claims {
        sub: String,
        exp: i64,
    }

    let token_data = decode::<Claims>(
        token,
        &DecodingKey::from_secret(jwt_secret.as_bytes()),
        &Validation::new(Algorithm::HS256),
    )
    .map_err(|_| ErrorCode::Unauthorized)?;

    Ok(token_data.claims.sub)
}

/// Error codes for notification operations
#[derive(Debug, Clone, Copy)]
pub enum ErrorCode {
    Unknown = 0,
    InvalidRequest = 1,
    Unauthorized = 2,
    NotFound = 3,
    InternalError = 4,
}

/// Handle device registration
pub async fn register_device(
    db: &NotificationDb,
    request: RegisterDeviceRequest,
    jwt_secret: &str,
) -> RegisterDeviceResponse {
    // Validate token
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return RegisterDeviceResponse {
                result: Some(register_device_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 2, // Unauthorized
                        message: "Invalid or expired token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    // Validate request
    if request.device_id.is_empty() || request.push_token.is_empty() {
        return RegisterDeviceResponse {
            result: Some(register_device_response::Result::Error(
                crate::generated::guardyn::common::ErrorResponse {
                    code: 1, // InvalidRequest
                    message: "Device ID and push token are required".to_string(),
                    details: std::collections::HashMap::new(),
                },
            )),
        };
    }

    // Create registration
    let registration = DeviceRegistration {
        user_id,
        device_id: request.device_id,
        push_token: request.push_token,
        platform: request.platform,
        device_name: request.device_name,
        app_version: request.app_version,
        os_version: request.os_version,
        registered_at: Utc::now(),
        updated_at: Utc::now(),
    };

    match db.register_device(&registration).await {
        Ok(registration_id) => RegisterDeviceResponse {
            result: Some(register_device_response::Result::Success(
                RegisterDeviceSuccess {
                    registration_id,
                    registered_at: Some(crate::generated::guardyn::common::Timestamp {
                        seconds: Utc::now().timestamp(),
                        nanos: 0,
                    }),
                },
            )),
        },
        Err(e) => {
            warn!("Failed to register device: {}", e);
            RegisterDeviceResponse {
                result: Some(register_device_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4, // InternalError
                        message: "Failed to register device".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }
        }
    }
}

/// Handle device unregistration
pub async fn unregister_device(
    db: &NotificationDb,
    request: UnregisterDeviceRequest,
    jwt_secret: &str,
) -> UnregisterDeviceResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return UnregisterDeviceResponse {
                result: Some(unregister_device_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 2,
                        message: "Invalid or expired token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    match db.unregister_device(&user_id, &request.device_id).await {
        Ok(unregistered) => UnregisterDeviceResponse {
            result: Some(unregister_device_response::Result::Success(
                UnregisterDeviceSuccess { unregistered },
            )),
        },
        Err(e) => {
            warn!("Failed to unregister device: {}", e);
            UnregisterDeviceResponse {
                result: Some(unregister_device_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: "Failed to unregister device".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }
        }
    }
}

/// Handle push token update
pub async fn update_push_token(
    db: &NotificationDb,
    request: UpdatePushTokenRequest,
    jwt_secret: &str,
) -> UpdatePushTokenResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return UpdatePushTokenResponse {
                result: Some(update_push_token_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 2,
                        message: "Invalid or expired token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    match db
        .update_push_token(&user_id, &request.device_id, &request.new_push_token)
        .await
    {
        Ok(updated) => UpdatePushTokenResponse {
            result: Some(update_push_token_response::Result::Success(
                UpdatePushTokenSuccess { updated },
            )),
        },
        Err(e) => {
            warn!("Failed to update push token: {}", e);
            UpdatePushTokenResponse {
                result: Some(update_push_token_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: "Failed to update push token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }
        }
    }
}

/// Get notification settings
pub async fn get_notification_settings(
    db: &NotificationDb,
    request: GetNotificationSettingsRequest,
    jwt_secret: &str,
) -> GetNotificationSettingsResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return GetNotificationSettingsResponse {
                result: Some(get_notification_settings_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 2,
                        message: "Invalid or expired token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    match db.get_notification_settings(&user_id).await {
        Ok(stored) => {
            let settings = NotificationSettings {
                notifications_enabled: stored.notifications_enabled,
                sound_enabled: stored.sound_enabled,
                vibration_enabled: stored.vibration_enabled,
                show_preview: stored.show_preview,
                show_sender: stored.show_sender,
                quiet_hours_enabled: stored.quiet_hours_enabled,
                quiet_hours_start: stored.quiet_hours_start,
                quiet_hours_end: stored.quiet_hours_end,
                quiet_hours_timezone: stored.quiet_hours_timezone,
                notify_messages: stored.notify_messages,
                notify_reactions: stored.notify_reactions,
                notify_mentions: stored.notify_mentions,
                notify_calls: stored.notify_calls,
                notify_group_messages: stored.notify_group_messages,
            };

            GetNotificationSettingsResponse {
                result: Some(get_notification_settings_response::Result::Success(
                    GetNotificationSettingsSuccess {
                        settings: Some(settings),
                    },
                )),
            }
        }
        Err(e) => {
            warn!("Failed to get notification settings: {}", e);
            GetNotificationSettingsResponse {
                result: Some(get_notification_settings_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: "Failed to get notification settings".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }
        }
    }
}

/// Update notification settings
pub async fn update_notification_settings(
    db: &NotificationDb,
    request: UpdateNotificationSettingsRequest,
    jwt_secret: &str,
) -> UpdateNotificationSettingsResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return UpdateNotificationSettingsResponse {
                result: Some(update_notification_settings_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 2,
                        message: "Invalid or expired token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    let settings = match request.settings {
        Some(s) => StoredNotificationSettings {
            notifications_enabled: s.notifications_enabled,
            sound_enabled: s.sound_enabled,
            vibration_enabled: s.vibration_enabled,
            show_preview: s.show_preview,
            show_sender: s.show_sender,
            quiet_hours_enabled: s.quiet_hours_enabled,
            quiet_hours_start: s.quiet_hours_start,
            quiet_hours_end: s.quiet_hours_end,
            quiet_hours_timezone: s.quiet_hours_timezone,
            notify_messages: s.notify_messages,
            notify_reactions: s.notify_reactions,
            notify_mentions: s.notify_mentions,
            notify_calls: s.notify_calls,
            notify_group_messages: s.notify_group_messages,
        },
        None => {
            return UpdateNotificationSettingsResponse {
                result: Some(update_notification_settings_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 1,
                        message: "Settings are required".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    match db.update_notification_settings(&user_id, &settings).await {
        Ok(()) => UpdateNotificationSettingsResponse {
            result: Some(update_notification_settings_response::Result::Success(
                UpdateNotificationSettingsSuccess { updated: true },
            )),
        },
        Err(e) => {
            warn!("Failed to update notification settings: {}", e);
            UpdateNotificationSettingsResponse {
                result: Some(update_notification_settings_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: "Failed to update notification settings".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }
        }
    }
}

/// Mute/unmute a conversation
pub async fn mute_conversation(
    db: &NotificationDb,
    request: MuteConversationRequest,
    jwt_secret: &str,
) -> MuteConversationResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return MuteConversationResponse {
                result: Some(mute_conversation_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 2,
                        message: "Invalid or expired token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    // Calculate mute expiration
    let muted_until = match MuteDuration::try_from(request.duration) {
        Ok(MuteDuration::Unmute) => {
            // Unmute the conversation
            if let Err(e) = db
                .unmute_conversation(&user_id, &request.conversation_id)
                .await
            {
                warn!("Failed to unmute conversation: {}", e);
                return MuteConversationResponse {
                    result: Some(mute_conversation_response::Result::Error(
                        crate::generated::guardyn::common::ErrorResponse {
                            code: 4,
                            message: "Failed to unmute conversation".to_string(),
                            details: std::collections::HashMap::new(),
                        },
                    )),
                };
            }
            return MuteConversationResponse {
                result: Some(mute_conversation_response::Result::Success(
                    MuteConversationSuccess {
                        muted: false,
                        muted_until: None,
                    },
                )),
            };
        }
        Ok(MuteDuration::OneHour) => Some(Utc::now() + Duration::hours(1)),
        Ok(MuteDuration::EightHours) => Some(Utc::now() + Duration::hours(8)),
        Ok(MuteDuration::OneDay) => Some(Utc::now() + Duration::days(1)),
        Ok(MuteDuration::SevenDays) => Some(Utc::now() + Duration::days(7)),
        Ok(MuteDuration::Forever) => None,
        _ => {
            return MuteConversationResponse {
                result: Some(mute_conversation_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 1,
                        message: "Invalid mute duration".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    match db
        .mute_conversation(
            &user_id,
            &request.conversation_id,
            request.is_group,
            muted_until,
        )
        .await
    {
        Ok(()) => MuteConversationResponse {
            result: Some(mute_conversation_response::Result::Success(
                MuteConversationSuccess {
                    muted: true,
                    muted_until: muted_until.map(|t| {
                        crate::generated::guardyn::common::Timestamp {
                            seconds: t.timestamp(),
                            nanos: 0,
                        }
                    }),
                },
            )),
        },
        Err(e) => {
            warn!("Failed to mute conversation: {}", e);
            MuteConversationResponse {
                result: Some(mute_conversation_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: "Failed to mute conversation".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }
        }
    }
}

/// Send a test notification
pub async fn send_test_notification(
    db: &NotificationDb,
    push_service: &PushService,
    request: SendTestNotificationRequest,
    jwt_secret: &str,
) -> SendTestNotificationResponse {
    let user_id = match validate_token(&request.access_token, jwt_secret) {
        Ok(id) => id,
        Err(_) => {
            return SendTestNotificationResponse {
                result: Some(send_test_notification_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 2,
                        message: "Invalid or expired token".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    // Get user's devices
    let devices = match db.get_user_devices(&user_id).await {
        Ok(d) => d,
        Err(e) => {
            warn!("Failed to get user devices: {}", e);
            return SendTestNotificationResponse {
                result: Some(send_test_notification_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: "Failed to get user devices".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            };
        }
    };

    // Filter by device_id if specified
    let target_devices: Vec<_> = if request.device_id.is_empty() {
        devices
    } else {
        devices
            .into_iter()
            .filter(|d| d.device_id == request.device_id)
            .collect()
    };

    if target_devices.is_empty() {
        return SendTestNotificationResponse {
            result: Some(send_test_notification_response::Result::Error(
                crate::generated::guardyn::common::ErrorResponse {
                    code: 3, // NotFound
                    message: "No devices found".to_string(),
                    details: std::collections::HashMap::new(),
                },
            )),
        };
    }

    // Build test payload
    let payload = PushPayload {
        notification_id: uuid::Uuid::new_v4().to_string(),
        title: "Guardyn Test".to_string(),
        body: "This is a test notification from Guardyn".to_string(),
        image_url: None,
        conversation_id: String::new(),
        is_group: false,
        message_id: String::new(),
        notification_type: "test".to_string(),
        priority: PushPriority::Normal,
        ttl_seconds: 3600,
    };

    // Convert to push devices
    let push_devices: Vec<PushDevice> = target_devices
        .iter()
        .map(|d| PushDevice {
            push_token: d.push_token.clone(),
            platform: match PushPlatform::try_from(d.platform) {
                Ok(p) => p,
                _ => PushPlatform::Fcm,
            },
        })
        .collect();

    match push_service.send_to_devices(&push_devices, &payload).await {
        Ok(count) => {
            debug!("Sent test notifications to {} devices", count);
            SendTestNotificationResponse {
                result: Some(send_test_notification_response::Result::Success(
                    SendTestNotificationSuccess {
                        devices_notified: count,
                    },
                )),
            }
        }
        Err(e) => {
            warn!("Failed to send test notifications: {}", e);
            SendTestNotificationResponse {
                result: Some(send_test_notification_response::Result::Error(
                    crate::generated::guardyn::common::ErrorResponse {
                        code: 4,
                        message: "Failed to send test notifications".to_string(),
                        details: std::collections::HashMap::new(),
                    },
                )),
            }
        }
    }
}

impl TryFrom<i32> for PushPlatform {
    type Error = ();

    fn try_from(value: i32) -> Result<Self, Self::Error> {
        match value {
            1 => Ok(PushPlatform::Fcm),
            2 => Ok(PushPlatform::Apns),
            3 => Ok(PushPlatform::ApnsSandbox),
            4 => Ok(PushPlatform::WebPush),
            _ => Err(()),
        }
    }
}
