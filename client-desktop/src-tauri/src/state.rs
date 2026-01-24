//! Application State Management
//!
//! Manages global application state using thread-safe primitives.

use crate::commands::settings::{load_settings_from_disk, UserSettings};
use crate::grpc::{GrpcClient, GrpcConfig};
use crate::services::{AuthClient, CallsClient, MediaClient, MessagingClient, PresenceClient};
use crate::webrtc::CallManager;
use parking_lot::RwLock;
use std::sync::Arc;

/// Global application state
pub struct AppState {
    inner: Arc<RwLock<AppStateInner>>,
    grpc: Arc<GrpcClient>,
    auth_client: Arc<AuthClient>,
    messaging_client: Arc<MessagingClient>,
    calls_client: Arc<CallsClient>,
    media_client: Arc<MediaClient>,
    presence_client: Arc<PresenceClient>,
    call_manager: Arc<CallManager>,
}

struct AppStateInner {
    authenticated: bool,
    user_id: Option<String>,
    access_token: Option<String>,
    settings: UserSettings,
}

impl AppState {
    pub fn new() -> Self {
        let config = GrpcConfig::default();
        let grpc = Arc::new(GrpcClient::new(config));
        let calls_client = Arc::new(CallsClient::new(Arc::clone(&grpc)));
        
        Self {
            inner: Arc::new(RwLock::new(AppStateInner {
                authenticated: false,
                user_id: None,
                access_token: None,
                settings: load_settings_from_disk(),
            })),
            auth_client: Arc::new(AuthClient::new(Arc::clone(&grpc))),
            messaging_client: Arc::new(MessagingClient::new(Arc::clone(&grpc))),
            presence_client: Arc::new(PresenceClient::new(Arc::clone(&grpc))),
            call_manager: Arc::new(CallManager::new(Arc::clone(&calls_client))),
            calls_client,
            media_client: Arc::new(MediaClient::new(Arc::clone(&grpc))),
            grpc,
        }
    }

    /// Get the gRPC client
    pub fn grpc(&self) -> &Arc<GrpcClient> {
        &self.grpc
    }

    /// Get the auth client
    pub fn auth(&self) -> &Arc<AuthClient> {
        &self.auth_client
    }

    /// Get the messaging client
    pub fn messaging(&self) -> &Arc<MessagingClient> {
        &self.messaging_client
    }

    /// Get the calls client
    pub fn calls(&self) -> &Arc<CallsClient> {
        &self.calls_client
    }

    /// Get the media client
    pub fn media(&self) -> &Arc<MediaClient> {
        &self.media_client
    }

    /// Get the presence client
    pub fn presence(&self) -> &Arc<PresenceClient> {
        &self.presence_client
    }

    /// Get the call manager
    pub fn call_manager(&self) -> &Arc<CallManager> {
        &self.call_manager
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
        let config = GrpcConfig::default();
        let grpc = Arc::new(GrpcClient::new(config));
        let calls_client = Arc::new(CallsClient::new(Arc::clone(&grpc)));
        
        Self {
            inner: Arc::clone(&self.inner),
            auth_client: Arc::new(AuthClient::new(Arc::clone(&grpc))),
            messaging_client: Arc::new(MessagingClient::new(Arc::clone(&grpc))),
            presence_client: Arc::new(PresenceClient::new(Arc::clone(&grpc))),
            call_manager: Arc::new(CallManager::new(Arc::clone(&calls_client))),
            calls_client,
            media_client: Arc::new(MediaClient::new(Arc::clone(&grpc))),
            grpc,
        }
    }
}
