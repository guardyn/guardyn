//! gRPC Client Services for Guardyn Desktop
//!
//! This module contains typed gRPC clients for all backend services.

pub mod auth_client;
pub mod calls_client;
pub mod media_client;
pub mod messaging_client;
pub mod secure_storage;

pub use auth_client::AuthClient;
pub use calls_client::CallsClient;
pub use media_client::{MediaClient, MediaMetadata, MediaType, UploadStatus};
pub use messaging_client::MessagingClient;
pub use secure_storage::SecureStorage;
