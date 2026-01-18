//! System Tray Management
//!
//! Handles system tray icon, menu with quick actions, status, and unread badges.

use parking_lot::RwLock;
use std::sync::Arc;
use tauri::{
    image::Image,
    menu::{CheckMenuItem, Menu, MenuItem, PredefinedMenuItem, Submenu},
    tray::{MouseButton, MouseButtonState, TrayIcon, TrayIconBuilder, TrayIconEvent},
    App, AppHandle, Manager, Runtime,
};

/// User presence status
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum UserStatus {
    #[default]
    Online,
    Away,
    Busy,
    Invisible,
}

impl UserStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Online => "Online",
            Self::Away => "Away",
            Self::Busy => "Busy",
            Self::Invisible => "Invisible",
        }
    }
}

/// Recent chat entry for quick access
#[derive(Debug, Clone)]
pub struct RecentChat {
    pub conversation_id: String,
    pub display_name: String,
    pub has_unread: bool,
}

/// Tray state for dynamic updates
pub struct TrayState {
    pub muted: bool,
    pub status: UserStatus,
    pub unread_count: u32,
    pub recent_chats: Vec<RecentChat>,
}

impl Default for TrayState {
    fn default() -> Self {
        Self {
            muted: false,
            status: UserStatus::Online,
            unread_count: 0,
            recent_chats: Vec::new(),
        }
    }
}

/// Global tray state manager
pub struct TrayManager<R: Runtime> {
    tray_icon: Option<TrayIcon<R>>,
    state: Arc<RwLock<TrayState>>,
    default_icon: Image<'static>,
    badge_icons: Vec<(u32, Image<'static>)>, // (count_threshold, icon)
}

impl<R: Runtime> TrayManager<R> {
    pub fn new(default_icon: Image<'static>) -> Self {
        Self {
            tray_icon: None,
            state: Arc::new(RwLock::new(TrayState::default())),
            default_icon,
            badge_icons: Vec::new(),
        }
    }

    /// Update unread count and refresh badge
    pub fn set_unread_count(&self, count: u32, app: &AppHandle<R>) {
        {
            let mut state = self.state.write();
            state.unread_count = count;
        }
        self.update_tooltip(app, count);
    }

    /// Update mute status
    pub fn set_muted(&self, muted: bool) {
        self.state.write().muted = muted;
    }

    /// Update user status
    pub fn set_status(&self, status: UserStatus) {
        self.state.write().status = status;
    }

    /// Update recent chats list
    pub fn set_recent_chats(&self, chats: Vec<RecentChat>) {
        self.state.write().recent_chats = chats;
    }

    /// Get current unread count
    pub fn unread_count(&self) -> u32 {
        self.state.read().unread_count
    }

    /// Get current mute status
    pub fn is_muted(&self) -> bool {
        self.state.read().muted
    }

    /// Get current user status
    pub fn status(&self) -> UserStatus {
        self.state.read().status
    }

    fn update_tooltip(&self, app: &AppHandle<R>, unread_count: u32) {
        if let Some(tray) = &self.tray_icon {
            let tooltip = if unread_count > 0 {
                format!("Guardyn ({} unread)", unread_count)
            } else {
                "Guardyn".to_string()
            };
            let _ = tray.set_tooltip(Some(&tooltip));
        }
    }
}

/// Setup the system tray with enhanced menu
pub fn setup_tray<R: Runtime>(app: &App<R>) -> Result<(), Box<dyn std::error::Error>> {
    // Create menu items
    let open = MenuItem::with_id(app, "open", "Open Guardyn", true, None::<&str>)?;
    
    // Mute toggle
    let mute = CheckMenuItem::with_id(app, "mute", "Mute All Notifications", true, false, None::<&str>)?;
    
    // Status submenu
    let status_online = CheckMenuItem::with_id(app, "status_online", "● Online", true, true, None::<&str>)?;
    let status_away = CheckMenuItem::with_id(app, "status_away", "◐ Away", true, false, None::<&str>)?;
    let status_busy = CheckMenuItem::with_id(app, "status_busy", "◉ Busy", true, false, None::<&str>)?;
    let status_invisible = CheckMenuItem::with_id(app, "status_invisible", "○ Invisible", true, false, None::<&str>)?;
    
    let status_menu = Submenu::with_items(
        app,
        "Status",
        true,
        &[&status_online, &status_away, &status_busy, &status_invisible],
    )?;

    // Recent chats submenu (initially empty, will be populated dynamically)
    let no_recent = MenuItem::with_id(app, "no_recent", "No recent chats", false, None::<&str>)?;
    let recent_menu = Submenu::with_items(app, "Recent Chats", true, &[&no_recent])?;

    // Separator and quit
    let separator = PredefinedMenuItem::separator(app)?;
    let quit = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;

    // Create menu
    let menu = Menu::with_items(
        app,
        &[
            &open,
            &separator,
            &mute,
            &status_menu,
            &recent_menu,
            &separator,
            &quit,
        ],
    )?;

    // Build tray icon
    let _tray = TrayIconBuilder::new()
        .icon(app.default_window_icon().unwrap().clone())
        .tooltip("Guardyn")
        .menu(&menu)
        .menu_on_left_click(false)
        .on_menu_event(move |app, event| {
            let event_id = event.id.as_ref();
            
            match event_id {
                "open" => {
                    if let Some(window) = app.get_webview_window("main") {
                        let _ = window.show();
                        let _ = window.set_focus();
                    }
                }
                "quit" => {
                    tracing::info!("Quit requested from tray");
                    app.exit(0);
                }
                "mute" => {
                    tracing::info!("Mute toggled from tray");
                    // Emit event to frontend
                    let _ = app.emit("tray:mute-toggled", ());
                }
                id if id.starts_with("status_") => {
                    let status = match id {
                        "status_online" => "online",
                        "status_away" => "away",
                        "status_busy" => "busy",
                        "status_invisible" => "invisible",
                        _ => return,
                    };
                    tracing::info!("Status changed to {} from tray", status);
                    let _ = app.emit("tray:status-changed", status);
                }
                id if id.starts_with("recent_") => {
                    // Extract conversation ID from menu item ID
                    let conversation_id = id.strip_prefix("recent_").unwrap_or("");
                    tracing::info!("Opening recent chat: {}", conversation_id);
                    let _ = app.emit("tray:open-chat", conversation_id);
                    
                    // Show and focus window
                    if let Some(window) = app.get_webview_window("main") {
                        let _ = window.show();
                        let _ = window.set_focus();
                    }
                }
                _ => {}
            }
        })
        .on_tray_icon_event(|tray, event| {
            if let TrayIconEvent::Click {
                button: MouseButton::Left,
                button_state: MouseButtonState::Up,
                ..
            } = event
            {
                let app = tray.app_handle();
                if let Some(window) = app.get_webview_window("main") {
                    let _ = window.show();
                    let _ = window.set_focus();
                }
            }
        })
        .build(app)?;

    tracing::debug!("System tray initialized with enhanced menu");
    Ok(())
}

/// Tauri command to update tray unread badge
#[tauri::command]
pub async fn update_tray_badge(count: u32, app: AppHandle) -> Result<(), String> {
    tracing::debug!("Updating tray badge: {} unread", count);
    
    // Update tooltip to show unread count
    if let Some(tray) = app.tray_by_id("main") {
        let tooltip = if count > 0 {
            format!("Guardyn ({} unread)", count)
        } else {
            "Guardyn".to_string()
        };
        tray.set_tooltip(Some(&tooltip)).map_err(|e| e.to_string())?;
    }
    
    Ok(())
}

/// Tauri command to set mute status
#[tauri::command]
pub async fn set_tray_muted(muted: bool, app: AppHandle) -> Result<(), String> {
    tracing::info!("Setting tray mute status: {}", muted);
    // The mute state is handled via menu checkbox
    Ok(())
}

/// Tauri command to update recent chats in tray menu
#[tauri::command]
pub async fn update_tray_recent_chats(
    chats: Vec<serde_json::Value>,
    app: AppHandle,
) -> Result<(), String> {
    tracing::debug!("Updating tray recent chats: {} items", chats.len());
    // Note: Dynamic menu updates require menu rebuild in Tauri 2.x
    // For now, emit an event that can be handled when menu is opened
    let _ = app.emit("tray:recent-chats-updated", &chats);
    Ok(())
}
