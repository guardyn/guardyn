//! Window State Persistence
//!
//! Saves and restores window position and size across sessions.

use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;
use tauri::{App, Manager, PhysicalPosition, PhysicalSize, Runtime, WebviewWindow};

/// Window state data
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct WindowState {
    /// Window X position
    pub x: Option<i32>,
    /// Window Y position  
    pub y: Option<i32>,
    /// Window width
    pub width: Option<u32>,
    /// Window height
    pub height: Option<u32>,
    /// Whether window was maximized
    pub maximized: bool,
    /// Whether window was fullscreen
    pub fullscreen: bool,
}

impl WindowState {
    /// Get the state file path
    fn state_file_path(app_data_dir: &PathBuf) -> PathBuf {
        app_data_dir.join("window-state.json")
    }

    /// Load window state from disk
    pub fn load(app_data_dir: &PathBuf) -> Option<Self> {
        let path = Self::state_file_path(app_data_dir);
        
        if !path.exists() {
            tracing::debug!("No window state file found at {:?}", path);
            return None;
        }

        match fs::read_to_string(&path) {
            Ok(content) => match serde_json::from_str(&content) {
                Ok(state) => {
                    tracing::debug!("Loaded window state: {:?}", state);
                    Some(state)
                }
                Err(e) => {
                    tracing::warn!("Failed to parse window state: {}", e);
                    None
                }
            },
            Err(e) => {
                tracing::warn!("Failed to read window state file: {}", e);
                None
            }
        }
    }

    /// Save window state to disk
    pub fn save(&self, app_data_dir: &PathBuf) -> Result<(), String> {
        let path = Self::state_file_path(app_data_dir);

        // Ensure parent directory exists
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }

        let content = serde_json::to_string_pretty(self).map_err(|e| e.to_string())?;
        fs::write(&path, content).map_err(|e| e.to_string())?;

        tracing::debug!("Saved window state to {:?}", path);
        Ok(())
    }

    /// Capture current window state
    pub fn capture_from_window<R: Runtime>(window: &WebviewWindow<R>) -> Self {
        let mut state = WindowState::default();

        // Get position
        if let Ok(position) = window.outer_position() {
            state.x = Some(position.x);
            state.y = Some(position.y);
        }

        // Get size
        if let Ok(size) = window.outer_size() {
            state.width = Some(size.width);
            state.height = Some(size.height);
        }

        // Get maximized state
        if let Ok(maximized) = window.is_maximized() {
            state.maximized = maximized;
        }

        // Get fullscreen state
        if let Ok(fullscreen) = window.is_fullscreen() {
            state.fullscreen = fullscreen;
        }

        state
    }

    /// Apply state to window
    pub fn apply_to_window<R: Runtime>(&self, window: &WebviewWindow<R>) -> Result<(), String> {
        // Apply fullscreen first if needed
        if self.fullscreen {
            window.set_fullscreen(true).map_err(|e| e.to_string())?;
            return Ok(());
        }

        // Apply maximized state
        if self.maximized {
            window.maximize().map_err(|e| e.to_string())?;
            return Ok(());
        }

        // Apply position if available
        if let (Some(x), Some(y)) = (self.x, self.y) {
            // Validate position is on screen
            if x >= 0 && y >= 0 {
                window
                    .set_position(PhysicalPosition { x, y })
                    .map_err(|e| e.to_string())?;
            }
        }

        // Apply size if available
        if let (Some(width), Some(height)) = (self.width, self.height) {
            // Validate reasonable size (minimum 400x300)
            if width >= 400 && height >= 300 {
                window
                    .set_size(PhysicalSize { width, height })
                    .map_err(|e| e.to_string())?;
            }
        }

        Ok(())
    }
}

/// Setup window state persistence
pub fn setup_window_state<R: Runtime>(app: &App<R>) -> Result<(), Box<dyn std::error::Error>> {
    let app_handle = app.app_handle().clone();

    // Get app data directory
    let app_data_dir = app
        .path()
        .app_data_dir()
        .expect("Failed to get app data directory");

    // Restore window state on startup
    if let Some(state) = WindowState::load(&app_data_dir) {
        if let Some(window) = app.get_webview_window("main") {
            if let Err(e) = state.apply_to_window(&window) {
                tracing::warn!("Failed to apply window state: {}", e);
            }
        }
    }

    // Listen for window close event to save state
    if let Some(window) = app.get_webview_window("main") {
        let window_clone = window.clone();
        let app_data_dir_clone = app_data_dir.clone();

        window.on_window_event(move |event| {
            use tauri::WindowEvent;
            
            match event {
                WindowEvent::CloseRequested { .. } | WindowEvent::Destroyed => {
                    // Save window state before closing
                    let state = WindowState::capture_from_window(&window_clone);
                    if let Err(e) = state.save(&app_data_dir_clone) {
                        tracing::error!("Failed to save window state: {}", e);
                    }
                }
                WindowEvent::Resized(_) | WindowEvent::Moved(_) => {
                    // Debounced save on resize/move would be ideal,
                    // but for simplicity we only save on close
                }
                _ => {}
            }
        });
    }

    tracing::info!("Window state persistence initialized");
    Ok(())
}

/// Tauri command to manually save window state
#[tauri::command]
pub async fn save_window_state(
    app: tauri::AppHandle,
    window: tauri::WebviewWindow,
) -> Result<(), String> {
    let app_data_dir = app
        .path()
        .app_data_dir()
        .map_err(|e| e.to_string())?;

    let state = WindowState::capture_from_window(&window);
    state.save(&app_data_dir)
}

/// Tauri command to get current window state
#[tauri::command]
pub async fn get_window_state(window: tauri::WebviewWindow) -> Result<WindowState, String> {
    Ok(WindowState::capture_from_window(&window))
}
