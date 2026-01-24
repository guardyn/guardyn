//! Settings Commands
//!
//! Manages user preferences and application settings.
//! Settings are persisted to a JSON file in the app data directory.

use crate::state::AppState;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tauri::State;

const SETTINGS_FILE_NAME: &str = "settings.json";

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

// =============================================================================
// Settings Persistence
// =============================================================================

/// Get the path to the settings file
fn get_settings_file_path() -> Option<PathBuf> {
    dirs::data_local_dir().map(|dir| dir.join("guardyn").join(SETTINGS_FILE_NAME))
}

/// Load settings from disk
/// 
/// Returns default settings if file doesn't exist or can't be read
pub fn load_settings_from_disk() -> UserSettings {
    let Some(path) = get_settings_file_path() else {
        tracing::debug!("No data directory available, using default settings");
        return UserSettings::default();
    };

    if !path.exists() {
        tracing::debug!("Settings file not found, using default settings");
        return UserSettings::default();
    }

    match std::fs::read_to_string(&path) {
        Ok(contents) => {
            match serde_json::from_str(&contents) {
                Ok(settings) => {
                    tracing::info!("Loaded settings from {}", path.display());
                    settings
                }
                Err(e) => {
                    tracing::warn!("Failed to parse settings file: {:?}. Using defaults.", e);
                    UserSettings::default()
                }
            }
        }
        Err(e) => {
            tracing::warn!("Failed to read settings file: {:?}. Using defaults.", e);
            UserSettings::default()
        }
    }
}

/// Save settings to disk
fn save_settings_to_disk(settings: &UserSettings) -> Result<(), String> {
    let path = get_settings_file_path()
        .ok_or_else(|| "No data directory available".to_string())?;

    // Ensure parent directory exists
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)
            .map_err(|e| format!("Failed to create settings directory: {}", e))?;
    }

    let json = serde_json::to_string_pretty(settings)
        .map_err(|e| format!("Failed to serialize settings: {}", e))?;

    std::fs::write(&path, json)
        .map_err(|e| format!("Failed to write settings file: {}", e))?;

    tracing::info!("Settings saved to {}", path.display());
    Ok(())
}

// =============================================================================
// Tauri Commands
// =============================================================================

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
    
    // Save to disk first
    save_settings_to_disk(&settings)?;
    
    // Then update in-memory state
    state.set_settings(settings);
    
    Ok(())
}

/// Reset settings to default values
#[tauri::command]
pub async fn reset_settings(state: State<'_, AppState>) -> Result<UserSettings, String> {
    tracing::info!("Resetting settings to defaults");
    
    let default_settings = UserSettings::default();
    
    // Save to disk
    save_settings_to_disk(&default_settings)?;
    
    // Update in-memory state
    state.set_settings(default_settings.clone());
    
    Ok(default_settings)
}

/// Get the path where settings are stored (for debugging)
#[tauri::command]
pub async fn get_settings_path() -> Result<Option<String>, String> {
    Ok(get_settings_file_path().map(|p| p.to_string_lossy().to_string()))
}

