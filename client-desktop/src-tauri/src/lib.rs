//! Guardyn Desktop Library
//!
//! Re-exports for library usage.

pub mod commands;
pub mod grpc;
pub mod proto;
pub mod services;
pub mod state;
pub mod tray;
pub mod webrtc;
pub mod window_state;

pub use grpc::{GrpcClient, GrpcConfig, GrpcError};
pub use services::{AuthClient, CallsClient, MessagingClient};
pub use state::AppState;
pub use tray::{TrayManager, TrayState, UserStatus};
pub use webrtc::{SFrameEncryptor, WebRtcConfig, WebRtcEvent, WebRtcManager};
pub use window_state::WindowState;
