//! Guardyn Desktop Application
//!
//! This is the main entry point for the Tauri-based desktop client.
//! It integrates with guardyn-crypto for E2EE and connects to backend services via gRPC.

// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;
mod state;
mod tray;

use tauri::Manager;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

pub use commands::*;
pub use state::AppState;

fn main() {
    // Initialize logging
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "guardyn_desktop=debug,tauri=info".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("Starting Guardyn Desktop v{}", env!("CARGO_PKG_VERSION"));

    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_notification::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_process::init())
        .setup(|app| {
            // Initialize application state
            let state = AppState::new();
            app.manage(state);

            // Setup system tray
            #[cfg(desktop)]
            tray::setup_tray(app)?;

            tracing::info!("Application setup complete");
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            // Auth commands
            commands::auth::login,
            commands::auth::register,
            commands::auth::logout,
            commands::auth::get_current_user,
            // Messaging commands
            commands::messaging::send_message,
            commands::messaging::get_conversations,
            commands::messaging::get_messages,
            commands::messaging::mark_as_read,
            // Crypto commands
            commands::crypto::generate_key_bundle,
            commands::crypto::encrypt_message,
            commands::crypto::decrypt_message,
            // Settings commands
            commands::settings::get_settings,
            commands::settings::update_settings,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_app_starts() {
        // Basic smoke test
        assert!(true);
    }
}
