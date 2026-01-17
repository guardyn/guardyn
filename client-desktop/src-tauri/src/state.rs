//! Application State Management
//!
//! Manages global application state using thread-safe primitives.

use crate::commands::settings::UserSettings;
use parking_lot::RwLock;
use std::sync::Arc;

/// Global application state
pub struct AppState {
    inner: Arc<RwLock<AppStateInner>>,
}

struct AppStateInner {
    authenticated: bool,
    user_id: Option<String>,
    access_token: Option<String>,
    settings: UserSettings,
}

impl AppState {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(RwLock::new(AppStateInner {
                authenticated: false,
                user_id: None,
                access_token: None,
                settings: UserSettings::default(),
            })),
        }
    }

    /// Check if user is authenticated
    pub fn is_authenticated(&self) -> bool {
        self.inner.read().authenticated
    }

    /// Set authentication status
    pub fn set_authenticated(&self, authenticated: bool) {
        self.inner.write().authenticated = authenticated;
    }

    /// Get current user ID
    pub fn user_id(&self) -> Option<String> {
        self.inner.read().user_id.clone()
    }

    /// Set user ID
    pub fn set_user_id(&self, user_id: Option<String>) {
        self.inner.write().user_id = user_id;
    }

    /// Get access token
    pub fn access_token(&self) -> Option<String> {
        self.inner.read().access_token.clone()
    }

    /// Set access token
    pub fn set_access_token(&self, token: Option<String>) {
        self.inner.write().access_token = token;
    }

    /// Clear session data (on logout)
    pub fn clear_session(&self) {
        let mut state = self.inner.write();
        state.authenticated = false;
        state.user_id = None;
        state.access_token = None;
    }

    /// Get user settings
    pub fn get_settings(&self) -> UserSettings {
        self.inner.read().settings.clone()
    }

    /// Set user settings
    pub fn set_settings(&self, settings: UserSettings) {
        self.inner.write().settings = settings;
    }
}

impl Default for AppState {
    fn default() -> Self {
        Self::new()
    }
}

impl Clone for AppState {
    fn clone(&self) -> Self {
        Self {
            inner: Arc::clone(&self.inner),
        }
    }
}
