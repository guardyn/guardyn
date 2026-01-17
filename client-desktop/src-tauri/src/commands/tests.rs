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
}
