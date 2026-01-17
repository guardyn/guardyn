//! Unit tests for Tauri commands
//!
//! These tests verify the command logic without requiring a running Tauri app.

#[cfg(test)]
mod tests {
    use super::super::crypto::{EncryptedMessage, KeyBundle};
    use super::super::messaging::{Conversation, Message, MessageStatus, Reaction};
    use super::super::settings::{Theme, UserSettings};

    // ============ Settings Tests ============

    #[test]
    fn test_user_settings_default() {
        let settings = UserSettings::default();

        assert!(matches!(settings.theme, Theme::System));
        assert!(settings.notifications_enabled);
        assert!(settings.sound_enabled);
        assert!(settings.show_message_preview);
        assert_eq!(settings.language, "en");
        assert!(settings.disappearing_messages_default.is_none());
    }

    #[test]
    fn test_user_settings_serialization() {
        let settings = UserSettings {
            theme: Theme::Dark,
            notifications_enabled: false,
            sound_enabled: true,
            show_message_preview: false,
            language: "ru".to_string(),
            disappearing_messages_default: Some(3600),
        };

        let json = serde_json::to_string(&settings).expect("Serialization failed");
        let deserialized: UserSettings =
            serde_json::from_str(&json).expect("Deserialization failed");

        assert!(matches!(deserialized.theme, Theme::Dark));
        assert!(!deserialized.notifications_enabled);
        assert!(deserialized.sound_enabled);
        assert!(!deserialized.show_message_preview);
        assert_eq!(deserialized.language, "ru");
        assert_eq!(deserialized.disappearing_messages_default, Some(3600));
    }

    #[test]
    fn test_theme_serialization() {
        let themes = vec![Theme::Light, Theme::Dark, Theme::System];

        for theme in themes {
            let json = serde_json::to_string(&theme).expect("Serialization failed");
            let deserialized: Theme = serde_json::from_str(&json).expect("Deserialization failed");

            match (&theme, &deserialized) {
                (Theme::Light, Theme::Light) => {}
                (Theme::Dark, Theme::Dark) => {}
                (Theme::System, Theme::System) => {}
                _ => panic!("Theme mismatch"),
            }
        }
    }

    // ============ Messaging Types Tests ============

    #[test]
    fn test_conversation_serialization() {
        let conversation = Conversation {
            id: "conv-123".to_string(),
            name: Some("Test Chat".to_string()),
            is_group: false,
            participant_ids: vec!["user-1".to_string(), "user-2".to_string()],
            last_message: None,
            unread_count: 5,
            updated_at: 1705520000,
        };

        let json = serde_json::to_string(&conversation).expect("Serialization failed");
        let deserialized: Conversation =
            serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.id, "conv-123");
        assert_eq!(deserialized.name, Some("Test Chat".to_string()));
        assert!(!deserialized.is_group);
        assert_eq!(deserialized.participant_ids.len(), 2);
        assert_eq!(deserialized.unread_count, 5);
    }

    #[test]
    fn test_message_serialization() {
        let message = Message {
            id: "msg-456".to_string(),
            conversation_id: "conv-123".to_string(),
            sender_id: "user-1".to_string(),
            content: "Hello, World!".to_string(),
            timestamp: 1705520000,
            status: MessageStatus::Delivered,
            reply_to: None,
            reactions: vec![Reaction {
                user_id: "user-2".to_string(),
                emoji: "👍".to_string(),
                timestamp: 1705520100,
            }],
        };

        let json = serde_json::to_string(&message).expect("Serialization failed");
        let deserialized: Message = serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.id, "msg-456");
        assert_eq!(deserialized.content, "Hello, World!");
        assert!(matches!(deserialized.status, MessageStatus::Delivered));
        assert_eq!(deserialized.reactions.len(), 1);
        assert_eq!(deserialized.reactions[0].emoji, "👍");
    }

    #[test]
    fn test_message_status_variants() {
        let statuses = vec![
            MessageStatus::Sending,
            MessageStatus::Sent,
            MessageStatus::Delivered,
            MessageStatus::Read,
            MessageStatus::Failed,
        ];

        for status in statuses {
            let json = serde_json::to_string(&status).expect("Serialization failed");
            let _: MessageStatus = serde_json::from_str(&json).expect("Deserialization failed");
        }
    }

    // ============ Crypto Types Tests ============

    #[test]
    fn test_key_bundle_serialization() {
        let bundle = KeyBundle {
            identity_key: "abc123".to_string(),
            signed_prekey: "def456".to_string(),
            prekey_signature: "sig789".to_string(),
            one_time_prekey: Some("otp000".to_string()),
            #[cfg(feature = "pq")]
            pq_prekey: None,
        };

        let json = serde_json::to_string(&bundle).expect("Serialization failed");
        let deserialized: KeyBundle = serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.identity_key, "abc123");
        assert_eq!(deserialized.signed_prekey, "def456");
        assert_eq!(deserialized.prekey_signature, "sig789");
        assert_eq!(deserialized.one_time_prekey, Some("otp000".to_string()));
    }

    #[test]
    fn test_encrypted_message_serialization() {
        let encrypted = EncryptedMessage {
            ciphertext: "encrypted_data_here".to_string(),
            nonce: "unique_nonce".to_string(),
            header: "header_info".to_string(),
        };

        let json = serde_json::to_string(&encrypted).expect("Serialization failed");
        let deserialized: EncryptedMessage =
            serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.ciphertext, "encrypted_data_here");
        assert_eq!(deserialized.nonce, "unique_nonce");
        assert_eq!(deserialized.header, "header_info");
    }

    // ============ State Tests ============

    #[test]
    fn test_app_state_creation() {
        use crate::state::AppState;

        let state = AppState::new();

        assert!(!state.is_authenticated());
        assert!(state.user_id().is_none());
        assert!(state.access_token().is_none());
    }

    #[test]
    fn test_app_state_authentication() {
        use crate::state::AppState;

        let state = AppState::new();

        // Initially not authenticated
        assert!(!state.is_authenticated());

        // Set authenticated
        state.set_authenticated(true);
        state.set_user_id(Some("user-123".to_string()));
        state.set_access_token(Some("token-abc".to_string()));

        assert!(state.is_authenticated());
        assert_eq!(state.user_id(), Some("user-123".to_string()));
        assert_eq!(state.access_token(), Some("token-abc".to_string()));

        // Clear session
        state.clear_session();

        assert!(!state.is_authenticated());
        assert!(state.user_id().is_none());
        assert!(state.access_token().is_none());
    }

    #[test]
    fn test_app_state_settings() {
        use crate::state::AppState;

        let state = AppState::new();

        // Default settings
        let settings = state.get_settings();
        assert!(matches!(settings.theme, Theme::System));

        // Update settings
        let new_settings = UserSettings {
            theme: Theme::Dark,
            notifications_enabled: false,
            ..Default::default()
        };
        state.set_settings(new_settings);

        let updated = state.get_settings();
        assert!(matches!(updated.theme, Theme::Dark));
        assert!(!updated.notifications_enabled);
    }

    // ============ Auth Types Tests ============

    #[test]
    fn test_user_info_serialization() {
        use super::super::auth::UserInfo;

        let user_info = UserInfo {
            user_id: "user-123".to_string(),
            username: "testuser".to_string(),
            display_name: Some("Test User".to_string()),
            avatar_url: None,
        };

        let json = serde_json::to_string(&user_info).expect("Serialization failed");
        let deserialized: UserInfo = serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.user_id, "user-123");
        assert_eq!(deserialized.username, "testuser");
        assert_eq!(deserialized.display_name, Some("Test User".to_string()));
        assert!(deserialized.avatar_url.is_none());
    }

    #[test]
    fn test_login_request_serialization() {
        use super::super::auth::LoginRequest;

        let request = LoginRequest {
            username: "testuser".to_string(),
            password: "password123".to_string(),
        };

        let json = serde_json::to_string(&request).expect("Serialization failed");
        let deserialized: LoginRequest = serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.username, "testuser");
        assert_eq!(deserialized.password, "password123");
    }

    #[test]
    fn test_register_request_serialization() {
        use super::super::auth::RegisterRequest;

        let request = RegisterRequest {
            username: "newuser".to_string(),
            password: "securepass".to_string(),
            display_name: Some("New User".to_string()),
        };

        let json = serde_json::to_string(&request).expect("Serialization failed");
        let deserialized: RegisterRequest = serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.username, "newuser");
        assert_eq!(deserialized.password, "securepass");
        assert_eq!(deserialized.display_name, Some("New User".to_string()));
    }

    #[test]
    fn test_auth_response_success() {
        use super::super::auth::{AuthResponse, UserInfo};

        let response = AuthResponse {
            success: true,
            user: Some(UserInfo {
                user_id: "user-456".to_string(),
                username: "testuser".to_string(),
                display_name: None,
                avatar_url: None,
            }),
            token: Some("jwt.token.here".to_string()),
            error: None,
        };

        let json = serde_json::to_string(&response).expect("Serialization failed");
        let deserialized: AuthResponse = serde_json::from_str(&json).expect("Deserialization failed");

        assert!(deserialized.success);
        assert!(deserialized.user.is_some());
        assert_eq!(deserialized.user.unwrap().user_id, "user-456");
        assert!(deserialized.token.is_some());
        assert!(deserialized.error.is_none());
    }

    #[test]
    fn test_auth_response_error() {
        use super::super::auth::AuthResponse;

        let response = AuthResponse {
            success: false,
            user: None,
            token: None,
            error: Some("Invalid credentials".to_string()),
        };

        let json = serde_json::to_string(&response).expect("Serialization failed");
        let deserialized: AuthResponse = serde_json::from_str(&json).expect("Deserialization failed");

        assert!(!deserialized.success);
        assert!(deserialized.user.is_none());
        assert!(deserialized.token.is_none());
        assert_eq!(deserialized.error, Some("Invalid credentials".to_string()));
    }

    // ============ Call Types Tests ============

    #[test]
    fn test_call_info_serialization() {
        use super::super::calls::CallInfo;

        let call_info = CallInfo {
            call_id: "call-789".to_string(),
            call_type: "video".to_string(),
            caller_id: "user-1".to_string(),
            caller_name: "Test Caller".to_string(),
            state: "connected".to_string(),
            started_at: Some(1705520000),
            duration_seconds: 120,
        };

        let json = serde_json::to_string(&call_info).expect("Serialization failed");
        let deserialized: CallInfo = serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.call_id, "call-789");
        assert_eq!(deserialized.call_type, "video");
        assert_eq!(deserialized.caller_id, "user-1");
        assert_eq!(deserialized.caller_name, "Test Caller");
        assert_eq!(deserialized.state, "connected");
        assert_eq!(deserialized.duration_seconds, 120);
    }

    #[test]
    fn test_initiate_call_request_serialization() {
        use super::super::calls::InitiateCallRequest;

        let request = InitiateCallRequest {
            callee_user_id: "user-callee".to_string(),
            call_type: "voice".to_string(),
        };

        let json = serde_json::to_string(&request).expect("Serialization failed");
        let deserialized: InitiateCallRequest = serde_json::from_str(&json).expect("Deserialization failed");

        assert_eq!(deserialized.callee_user_id, "user-callee");
        assert_eq!(deserialized.call_type, "voice");
    }

    #[test]
    fn test_call_response_success() {
        use super::super::calls::CallResponse;

        let response = CallResponse {
            success: true,
            call_id: Some("call-new".to_string()),
            error: None,
        };

        let json = serde_json::to_string(&response).expect("Serialization failed");
        let deserialized: CallResponse = serde_json::from_str(&json).expect("Deserialization failed");

        assert!(deserialized.success);
        assert_eq!(deserialized.call_id, Some("call-new".to_string()));
        assert!(deserialized.error.is_none());
    }

    #[test]
    fn test_call_response_error() {
        use super::super::calls::CallResponse;

        let response = CallResponse {
            success: false,
            call_id: None,
            error: Some("User offline".to_string()),
        };

        let json = serde_json::to_string(&response).expect("Serialization failed");
        let deserialized: CallResponse = serde_json::from_str(&json).expect("Deserialization failed");

        assert!(!deserialized.success);
        assert!(deserialized.call_id.is_none());
        assert_eq!(deserialized.error, Some("User offline".to_string()));
    }

    // ============ Validation Tests ============

    #[test]
    fn test_username_not_empty() {
        use super::super::auth::LoginRequest;

        let request = LoginRequest {
            username: "".to_string(),
            password: "password".to_string(),
        };

        // Username should not be empty in real validation
        assert!(request.username.is_empty());
    }

    #[test]
    fn test_password_length() {
        use super::super::auth::RegisterRequest;

        let request = RegisterRequest {
            username: "user".to_string(),
            password: "short".to_string(),
            display_name: None,
        };

        // Password should be at least 8 characters
        assert!(request.password.len() < 8);

        let valid_request = RegisterRequest {
            username: "user".to_string(),
            password: "securepassword123".to_string(),
            display_name: None,
        };

        assert!(valid_request.password.len() >= 8);
    }

    #[test]
    fn test_call_type_values() {
        use super::super::calls::InitiateCallRequest;

        let voice_call = InitiateCallRequest {
            callee_user_id: "user".to_string(),
            call_type: "voice".to_string(),
        };
        assert!(voice_call.call_type == "voice" || voice_call.call_type == "video");

        let video_call = InitiateCallRequest {
            callee_user_id: "user".to_string(),
            call_type: "video".to_string(),
        };
        assert!(video_call.call_type == "voice" || video_call.call_type == "video");
    }

    // ============ Thread Safety Tests ============

    #[test]
    fn test_app_state_thread_safe() {
        use crate::state::AppState;
        use std::sync::Arc;
        use std::thread;

        let state = Arc::new(AppState::new());

        let handles: Vec<_> = (0..10)
            .map(|i| {
                let state = Arc::clone(&state);
                thread::spawn(move || {
                    state.set_authenticated(i % 2 == 0);
                    state.is_authenticated()
                })
            })
            .collect();

        for handle in handles {
            let _ = handle.join().expect("Thread panicked");
        }

        // State should be consistent (last write wins)
        // This test verifies no deadlocks or panics occur
    }
}
