//! WebRTC Module for Guardyn Desktop
//!
//! Provides WebRTC peer connection management for voice/video calls.

pub mod call_manager;
pub mod peer_connection;
pub mod screen_capture;
pub mod sframe;

pub use call_manager::{CallManager, CallManagerEvent, CallInfo, CallType, CallState, CallManagerError};
pub use peer_connection::{WebRtcConfig, WebRtcManager, WebRtcEvent, IceServerConfig};
pub use sframe::SFrameEncryptor;
