//! WebRTC Module for Guardyn Desktop
//!
//! Provides WebRTC peer connection management for voice/video calls.

pub mod peer_connection;
pub mod sframe;

pub use peer_connection::{IceServerConfig, WebRtcConfig, WebRtcManager, WebRtcEvent};
pub use sframe::SFrameEncryptor;
