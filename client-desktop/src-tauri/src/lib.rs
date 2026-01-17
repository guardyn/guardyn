//! Guardyn Desktop Library
//!
//! Re-exports for library usage.

pub mod commands;
pub mod grpc;
pub mod state;
pub mod tray;

pub use grpc::{GrpcClient, GrpcConfig, GrpcError};
pub use state::AppState;
