/// Cryptographic protocols and primitives for Guardyn
///
/// This crate implements:
/// - X3DH key agreement protocol (classical)
/// - PQXDH hybrid key agreement (post-quantum + classical)
/// - Double Ratchet for 1-on-1 messaging
/// - MLS (Messaging Layer Security) for group chat
/// - Sealed Sender for metadata protection
/// - PADMÉ padding for traffic analysis protection
/// - Key derivation and storage

// Core protocols
pub mod x3dh;
pub mod double_ratchet;
pub mod mls;
pub mod key_storage;
pub mod sealed_sender;

// Post-quantum and privacy enhancements
pub mod pqxdh;
pub mod padding;

// FFI bindings for Flutter (feature-gated)
#[cfg(feature = "ffi")]
pub mod ffi;

#[cfg(test)]
mod mls_tests;

#[cfg(test)]
mod x3dh_conversion_tests;

// Re-exports for convenience
pub use x3dh::{X3DHKeyBundle, X3DHProtocol, X3DHKeyMaterial, X3DHPrekeyMessage, IdentityKeyPair, SignedPreKey, OneTimePreKey};
pub use double_ratchet::DoubleRatchet;
pub use mls::{MlsGroupManager, create_test_credential};
pub use pqxdh::{HybridKeyBundle, HybridSharedSecret, generate_hybrid_key_bundle};
pub use padding::{pad_message, unpad_message, next_padme_length};
pub use sealed_sender::{SealedSender, SealedSenderEnvelope, SenderCertificate};
pub use key_storage::{KeyStorage, KeyMetadata, KeyType, create_test_storage};

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
