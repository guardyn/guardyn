//! Settings Commands
//!
//! Manages user preferences and application settings.

use crate::state::AppState;
use serde::{Deserialize, Serialize};
use tauri::State;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserSettings {
    pub theme: Theme,
    pub notifications_enabled: bool,
    pub sound_enabled: bool,
    pub show_message_preview: bool,
    pub language: String,
    pub disappearing_messages_default: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Theme {
    Light,
    Dark,
    System,
}

impl Default for UserSettings {
    fn default() -> Self {
        Self {
            theme: Theme::System,
            notifications_enabled: true,
            sound_enabled: true,
            show_message_preview: true,
            language: "en".to_string(),
            disappearing_messages_default: None,
        }
    }
}

/// Get current user settings
#[tauri::command]
pub async fn get_settings(state: State<'_, AppState>) -> Result<UserSettings, String> {
    Ok(state.get_settings())
}

/// Update user settings
#[tauri::command]
pub async fn update_settings(
    settings: UserSettings,
    state: State<'_, AppState>,
) -> Result<(), String> {
    tracing::info!("Updating user settings");
    state.set_settings(settings);
    // TODO: Persist settings to disk
    Ok(())
}
