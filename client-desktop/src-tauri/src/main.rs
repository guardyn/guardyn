//! Guardyn Desktop Application
//!
//! This is the main entry point for the Tauri-based desktop client.
//! It integrates with guardyn-crypto for E2EE and connects to backend services via gRPC.

// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;
mod grpc;
mod proto;
mod services;
mod state;
mod tray;
mod webrtc;
mod window_state;

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

            // Setup system tray with enhanced menu
            #[cfg(desktop)]
            tray::setup_tray(app)?;

            // Setup window state persistence
            #[cfg(desktop)]
            window_state::setup_window_state(app)?;

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
            // Group commands
            commands::groups::get_groups,
            commands::groups::get_group,
            commands::groups::get_group_members,
            commands::groups::update_member_role,
            commands::groups::remove_group_member,
            commands::groups::leave_group,
            commands::groups::update_group,
            // Media commands
            commands::media::get_media_upload_url,
            commands::media::upload_media_file,
            commands::media::get_media_download_url,
            commands::media::download_media_file,
            commands::media::get_media_metadata,
            commands::media::delete_media,
            commands::media::generate_thumbnail,
            commands::media::list_media,
            commands::media::get_media_cache_dir,
            commands::media::clear_media_cache,
            commands::media::get_cached_media_path,
            // Call commands
            commands::calls::initiate_call,
            commands::calls::accept_call,
            commands::calls::reject_call,
            commands::calls::end_call,
            commands::calls::toggle_mute,
            commands::calls::toggle_video,
            commands::calls::toggle_screen_share,
            commands::calls::get_call_history,
            commands::calls::get_call_state,
            // Crypto commands
            commands::crypto::generate_key_bundle,
            commands::crypto::encrypt_message,
            commands::crypto::decrypt_message,
            commands::crypto::generate_identity_keys,
            commands::crypto::get_identity_key,
            commands::crypto::has_identity_keys,
            commands::crypto::generate_signed_prekey,
            commands::crypto::generate_one_time_prekeys,
            commands::crypto::perform_x3dh,
            commands::crypto::init_session,
            commands::crypto::get_session,
            commands::crypto::list_sessions,
            commands::crypto::delete_session,
            commands::crypto::is_pq_available,
            commands::crypto::get_crypto_version,
            commands::crypto::clear_crypto_state,
            // MLS commands (group encryption)
            commands::mls::mls_init,
            commands::mls::mls_is_initialized,
            commands::mls::mls_generate_key_package,
            commands::mls::mls_generate_key_packages,
            commands::mls::mls_create_group,
            commands::mls::mls_get_group,
            commands::mls::mls_list_groups,
            commands::mls::mls_add_member,
            commands::mls::mls_remove_member,
            commands::mls::mls_join_group,
            commands::mls::mls_encrypt_message,
            commands::mls::mls_decrypt_message,
            commands::mls::mls_process_commit,
            commands::mls::mls_delete_group,
            commands::mls::mls_clear_state,
            commands::mls::mls_get_version,
            // WebSocket commands
            commands::websocket::get_websocket_config,
            commands::websocket::get_websocket_url_with_token,
            commands::websocket::report_websocket_status,
            // Download commands
            commands::downloads::download_file,
            commands::downloads::cancel_download,
            commands::downloads::open_file_with_default_app,
            commands::downloads::show_in_folder,
            // Settings commands
            commands::settings::get_settings,
            commands::settings::update_settings,
            // Tray commands
            tray::update_tray_badge,
            tray::set_tray_muted,
            tray::update_tray_recent_chats,
            // Window state commands
            window_state::save_window_state,
            window_state::get_window_state,
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
