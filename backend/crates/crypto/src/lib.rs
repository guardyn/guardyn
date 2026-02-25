pub mod double_ratchet;
pub mod key_storage;
pub mod mls;
pub mod sealed_sender;
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

// Post-quantum and privacy enhancements
pub mod padding;
pub mod pqxdh;

// FFI bindings for Flutter (feature-gated)
#[cfg(feature = "ffi")]
pub mod ffi;

#[cfg(test)]
mod mls_tests;

#[cfg(test)]
mod x3dh_conversion_tests;

// Re-exports for convenience
pub use double_ratchet::DoubleRatchet;
pub use key_storage::{create_test_storage, KeyMetadata, KeyStorage, KeyType};
pub use mls::{create_test_credential, MlsGroupManager};
pub use padding::{next_padme_length, pad_message, unpad_message};
pub use pqxdh::{generate_hybrid_key_bundle, HybridKeyBundle, HybridSharedSecret};
pub use sealed_sender::{SealedSender, SealedSenderEnvelope, SenderCertificate};
pub use x3dh::{
    IdentityKeyPair, OneTimePreKey, SignedPreKey, X3DHKeyBundle, X3DHKeyMaterial,
    X3DHPrekeyMessage, X3DHProtocol,
};

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
