//! Database layer for Notification Service
//!
//! Manages device registrations, notification settings, and muted conversations.

use anyhow::{Context, Result};
use chrono::{DateTime, Utc};
use scylla::{Session, SessionBuilder};
use std::sync::Arc;
use tracing::info;
use uuid::Uuid;

/// Device registration record
#[derive(Debug, Clone)]
pub struct DeviceRegistration {
    pub user_id: String,
    pub device_id: String,
    pub push_token: String,
    pub platform: i32,
    pub device_name: String,
    pub app_version: String,
    pub os_version: String,
    pub registered_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// Notification settings for a user
#[derive(Debug, Clone, Default)]
pub struct StoredNotificationSettings {
    pub notifications_enabled: bool,
    pub sound_enabled: bool,
    pub vibration_enabled: bool,
    pub show_preview: bool,
    pub show_sender: bool,
    pub quiet_hours_enabled: bool,
    pub quiet_hours_start: i32,
    pub quiet_hours_end: i32,
    pub quiet_hours_timezone: String,
    pub notify_messages: bool,
    pub notify_reactions: bool,
    pub notify_mentions: bool,
    pub notify_calls: bool,
    pub notify_group_messages: bool,
}

/// Muted conversation record
#[derive(Debug, Clone)]
#[allow(dead_code)]
pub struct MutedConversation {
    pub user_id: String,
    pub conversation_id: String,
    pub is_group: bool,
    pub muted_until: Option<DateTime<Utc>>,
}

/// Notification database operations
pub struct NotificationDb {
    session: Arc<Session>,
}

impl NotificationDb {
    /// Create a new database connection
    pub async fn new(hosts: &[String]) -> Result<Self> {
        let session = SessionBuilder::new()
            .known_nodes(hosts)
            .build()
            .await
            .context("Failed to connect to ScyllaDB")?;

        let db = Self {
            session: Arc::new(session),
        };

        db.init_schema().await?;
        Ok(db)
    }

    /// Initialize database schema
    async fn init_schema(&self) -> Result<()> {
        // Create keyspace
        self.session
            .query_unpaged(
                r#"
                CREATE KEYSPACE IF NOT EXISTS guardyn_notifications
                WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
                "#,
                &[],
            )
            .await
            .context("Failed to create keyspace")?;

        // Device registrations table
        self.session
            .query_unpaged(
                r#"
                CREATE TABLE IF NOT EXISTS guardyn_notifications.device_registrations (
                    user_id text,
                    device_id text,
                    push_token text,
                    platform int,
                    device_name text,
                    app_version text,
                    os_version text,
                    registered_at timestamp,
                    updated_at timestamp,
                    PRIMARY KEY (user_id, device_id)
                )
                "#,
                &[],
            )
            .await
            .context("Failed to create device_registrations table")?;

        // Notification settings table
        self.session
            .query_unpaged(
                r#"
                CREATE TABLE IF NOT EXISTS guardyn_notifications.notification_settings (
                    user_id text PRIMARY KEY,
                    notifications_enabled boolean,
                    sound_enabled boolean,
                    vibration_enabled boolean,
                    show_preview boolean,
                    show_sender boolean,
                    quiet_hours_enabled boolean,
                    quiet_hours_start int,
                    quiet_hours_end int,
                    quiet_hours_timezone text,
                    notify_messages boolean,
                    notify_reactions boolean,
                    notify_mentions boolean,
                    notify_calls boolean,
                    notify_group_messages boolean
                )
                "#,
                &[],
            )
            .await
            .context("Failed to create notification_settings table")?;

        // Muted conversations table
        self.session
            .query_unpaged(
                r#"
                CREATE TABLE IF NOT EXISTS guardyn_notifications.muted_conversations (
                    user_id text,
                    conversation_id text,
                    is_group boolean,
                    muted_until timestamp,
                    PRIMARY KEY (user_id, conversation_id)
                )
                "#,
                &[],
            )
            .await
            .context("Failed to create muted_conversations table")?;

        info!("Notification database schema initialized");
        Ok(())
    }

    /// Register a device for push notifications
    pub async fn register_device(&self, registration: &DeviceRegistration) -> Result<String> {
        let registration_id = Uuid::new_v4().to_string();

        self.session
            .query_unpaged(
                r#"
                INSERT INTO guardyn_notifications.device_registrations 
                (user_id, device_id, push_token, platform, device_name, app_version, os_version, registered_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                "#,
                (
                    &registration.user_id,
                    &registration.device_id,
                    &registration.push_token,
                    registration.platform,
                    &registration.device_name,
                    &registration.app_version,
                    &registration.os_version,
                    registration.registered_at.timestamp_millis(),
                    registration.updated_at.timestamp_millis(),
                ),
            )
            .await
            .context("Failed to register device")?;

        Ok(registration_id)
    }

    /// Unregister a device
    pub async fn unregister_device(&self, user_id: &str, device_id: &str) -> Result<bool> {
        self.session
            .query_unpaged(
                "DELETE FROM guardyn_notifications.device_registrations WHERE user_id = ? AND device_id = ?",
                (user_id, device_id),
            )
            .await
            .context("Failed to unregister device")?;

        Ok(true)
    }

    /// Update push token for a device
    pub async fn update_push_token(
        &self,
        user_id: &str,
        device_id: &str,
        new_token: &str,
    ) -> Result<bool> {
        self.session
            .query_unpaged(
                r#"
                UPDATE guardyn_notifications.device_registrations 
                SET push_token = ?, updated_at = ?
                WHERE user_id = ? AND device_id = ?
                "#,
                (new_token, Utc::now().timestamp_millis(), user_id, device_id),
            )
            .await
            .context("Failed to update push token")?;

        Ok(true)
    }

    /// Get all devices for a user
    pub async fn get_user_devices(&self, user_id: &str) -> Result<Vec<DeviceRegistration>> {
        let result = self
            .session
            .query_unpaged(
                r#"
                SELECT user_id, device_id, push_token, platform, device_name, app_version, os_version, registered_at, updated_at
                FROM guardyn_notifications.device_registrations
                WHERE user_id = ?
                "#,
                (user_id,),
            )
            .await
            .context("Failed to get user devices")?;

        let mut devices = Vec::new();
        if let Some(rows) = result.rows {
            for row in rows {
                let (
                    user_id,
                    device_id,
                    push_token,
                    platform,
                    device_name,
                    app_version,
                    os_version,
                    registered_at,
                    updated_at,
                ): (
                    String,
                    String,
                    String,
                    i32,
                    String,
                    String,
                    String,
                    i64,
                    i64,
                ) = row.into_typed().context("Failed to parse device row")?;

                devices.push(DeviceRegistration {
                    user_id,
                    device_id,
                    push_token,
                    platform,
                    device_name,
                    app_version,
                    os_version,
                    registered_at: DateTime::from_timestamp_millis(registered_at)
                        .unwrap_or_default(),
                    updated_at: DateTime::from_timestamp_millis(updated_at).unwrap_or_default(),
                });
            }
        }

        Ok(devices)
    }

    /// Get notification settings for a user
    #[allow(clippy::type_complexity)]
    pub async fn get_notification_settings(
        &self,
        user_id: &str,
    ) -> Result<StoredNotificationSettings> {
        let result = self
            .session
            .query_unpaged(
                r#"
                SELECT notifications_enabled, sound_enabled, vibration_enabled, show_preview, show_sender,
                       quiet_hours_enabled, quiet_hours_start, quiet_hours_end, quiet_hours_timezone,
                       notify_messages, notify_reactions, notify_mentions, notify_calls, notify_group_messages
                FROM guardyn_notifications.notification_settings
                WHERE user_id = ?
                "#,
                (user_id,),
            )
            .await
            .context("Failed to get notification settings")?;

        if let Some(rows) = result.rows {
            if let Some(row) = rows.into_iter().next() {
                let (
                    notifications_enabled,
                    sound_enabled,
                    vibration_enabled,
                    show_preview,
                    show_sender,
                    quiet_hours_enabled,
                    quiet_hours_start,
                    quiet_hours_end,
                    quiet_hours_timezone,
                    notify_messages,
                    notify_reactions,
                    notify_mentions,
                    notify_calls,
                    notify_group_messages,
                ): (
                    Option<bool>,
                    Option<bool>,
                    Option<bool>,
                    Option<bool>,
                    Option<bool>,
                    Option<bool>,
                    Option<i32>,
                    Option<i32>,
                    Option<String>,
                    Option<bool>,
                    Option<bool>,
                    Option<bool>,
                    Option<bool>,
                    Option<bool>,
                ) = row.into_typed().context("Failed to parse settings row")?;

                return Ok(StoredNotificationSettings {
                    notifications_enabled: notifications_enabled.unwrap_or(true),
                    sound_enabled: sound_enabled.unwrap_or(true),
                    vibration_enabled: vibration_enabled.unwrap_or(true),
                    show_preview: show_preview.unwrap_or(true),
                    show_sender: show_sender.unwrap_or(true),
                    quiet_hours_enabled: quiet_hours_enabled.unwrap_or(false),
                    quiet_hours_start: quiet_hours_start.unwrap_or(22),
                    quiet_hours_end: quiet_hours_end.unwrap_or(7),
                    quiet_hours_timezone: quiet_hours_timezone.unwrap_or_else(|| "UTC".to_string()),
                    notify_messages: notify_messages.unwrap_or(true),
                    notify_reactions: notify_reactions.unwrap_or(true),
                    notify_mentions: notify_mentions.unwrap_or(true),
                    notify_calls: notify_calls.unwrap_or(true),
                    notify_group_messages: notify_group_messages.unwrap_or(true),
                });
            }
        }

        // Return default settings if none exist
        Ok(StoredNotificationSettings {
            notifications_enabled: true,
            sound_enabled: true,
            vibration_enabled: true,
            show_preview: true,
            show_sender: true,
            quiet_hours_enabled: false,
            quiet_hours_start: 22,
            quiet_hours_end: 7,
            quiet_hours_timezone: "UTC".to_string(),
            notify_messages: true,
            notify_reactions: true,
            notify_mentions: true,
            notify_calls: true,
            notify_group_messages: true,
        })
    }

    /// Update notification settings
    pub async fn update_notification_settings(
        &self,
        user_id: &str,
        settings: &StoredNotificationSettings,
    ) -> Result<()> {
        self.session
            .query_unpaged(
                r#"
                INSERT INTO guardyn_notifications.notification_settings 
                (user_id, notifications_enabled, sound_enabled, vibration_enabled, show_preview, show_sender,
                 quiet_hours_enabled, quiet_hours_start, quiet_hours_end, quiet_hours_timezone,
                 notify_messages, notify_reactions, notify_mentions, notify_calls, notify_group_messages)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                "#,
                (
                    user_id,
                    settings.notifications_enabled,
                    settings.sound_enabled,
                    settings.vibration_enabled,
                    settings.show_preview,
                    settings.show_sender,
                    settings.quiet_hours_enabled,
                    settings.quiet_hours_start,
                    settings.quiet_hours_end,
                    &settings.quiet_hours_timezone,
                    settings.notify_messages,
                    settings.notify_reactions,
                    settings.notify_mentions,
                    settings.notify_calls,
                    settings.notify_group_messages,
                ),
            )
            .await
            .context("Failed to update notification settings")?;

        Ok(())
    }

    /// Mute a conversation
    pub async fn mute_conversation(
        &self,
        user_id: &str,
        conversation_id: &str,
        is_group: bool,
        muted_until: Option<DateTime<Utc>>,
    ) -> Result<()> {
        self.session
            .query_unpaged(
                r#"
                INSERT INTO guardyn_notifications.muted_conversations 
                (user_id, conversation_id, is_group, muted_until)
                VALUES (?, ?, ?, ?)
                "#,
                (
                    user_id,
                    conversation_id,
                    is_group,
                    muted_until.map(|t| t.timestamp_millis()),
                ),
            )
            .await
            .context("Failed to mute conversation")?;

        Ok(())
    }

    /// Unmute a conversation
    pub async fn unmute_conversation(&self, user_id: &str, conversation_id: &str) -> Result<()> {
        self.session
            .query_unpaged(
                "DELETE FROM guardyn_notifications.muted_conversations WHERE user_id = ? AND conversation_id = ?",
                (user_id, conversation_id),
            )
            .await
            .context("Failed to unmute conversation")?;

        Ok(())
    }

    /// Check if a conversation is muted
    #[allow(dead_code)]
    pub async fn is_conversation_muted(
        &self,
        user_id: &str,
        conversation_id: &str,
    ) -> Result<bool> {
        let result = self
            .session
            .query_unpaged(
                "SELECT muted_until FROM guardyn_notifications.muted_conversations WHERE user_id = ? AND conversation_id = ?",
                (user_id, conversation_id),
            )
            .await
            .context("Failed to check muted status")?;

        if let Some(rows) = result.rows {
            if let Some(row) = rows.into_iter().next() {
                let (muted_until,): (Option<i64>,) =
                    row.into_typed().context("Failed to parse row")?;

                // Check if still muted
                if let Some(until) = muted_until {
                    let until_dt = DateTime::from_timestamp_millis(until).unwrap_or_default();
                    return Ok(until_dt > Utc::now());
                } else {
                    // muted_until is None means muted forever
                    return Ok(true);
                }
            }
        }

        Ok(false)
    }
}
