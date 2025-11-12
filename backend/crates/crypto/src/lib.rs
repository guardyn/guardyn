/// Cryptographic protocols and primitives for Guardyn
///
/// This crate implements:
/// - X3DH key agreement protocol
/// - Double Ratchet for 1-on-1 messaging
/// - MLS (Messaging Layer Security) for group chat
/// - Key derivation and storage
pub mod x3dh;
pub mod double_ratchet;
pub mod mls;
pub mod key_storage;

#[cfg(test)]
mod mls_tests;

pub use x3dh::{X3DHKeyBundle, X3DHProtocol};
pub use double_ratchet::DoubleRatchet;
pub use mls::MlsGroupManager;

use thiserror::Error;

#[derive(Error, Debug)]
pub enum CryptoError {
    #[error("Key generation failed: {0}")]
    KeyGeneration(String),

    #[error("Encryption failed: {0}")]
    Encryption(String),

    #[error("Decryption failed: {0}")]
    Decryption(String),

    #[error("Invalid key: {0}")]
    InvalidKey(String),

    #[error("Invalid signature: {0}")]
    InvalidSignature(String),

    #[error("Protocol error: {0}")]
    Protocol(String),
}

pub type Result<T> = std::result::Result<T, CryptoError>;
