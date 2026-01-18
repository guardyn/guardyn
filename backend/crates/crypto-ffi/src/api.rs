//! Flutter Rust Bridge API
//!
//! This module exposes cryptographic functions to Flutter via flutter_rust_bridge.
//! All public functions here will be automatically available in Dart.
//!
//! # Naming Convention
//!
//! Flutter Rust Bridge automatically converts:
//! - `snake_case` Rust functions → `camelCase` Dart methods
//! - Rust structs → Dart classes
//! - `Result<T, E>` → throws Dart exceptions

use flutter_rust_bridge::frb;
use rand::RngCore;
use std::sync::atomic::{AtomicBool, Ordering};
use subtle::ConstantTimeEq;

// Re-export from guardyn-crypto FFI module
use guardyn_crypto::ffi::{
    decrypt_aes256_gcm, decrypt_chacha20_poly1305, ed25519_public_to_x25519,
    ed25519_secret_to_x25519, encrypt_aes256_gcm, encrypt_chacha20_poly1305, ffi_pad_message,
    ffi_unpad_message, generate_ed25519_keypair, generate_ed25519_keypair_from_seed,
    generate_x25519_keypair, hkdf_sha256, init_crypto, is_pq_available, sign_ed25519,
    verify_ed25519, x25519_diffie_hellman, FfiEncryptedData, FfiKeyPair,
};

#[cfg(feature = "pq")]
use guardyn_crypto::ffi::{generate_hybrid_key_bundle, FfiHybridKeyBundle};

/// Track initialization state
static INITIALIZED: AtomicBool = AtomicBool::new(false);

// ============================================================================
// Data Types (exposed to Dart)
// ============================================================================

/// Key pair with public and private components
#[frb(dart_metadata = ("freezed"))]
#[derive(Debug, Clone)]
pub struct KeyPair {
    pub public_key: Vec<u8>,
    pub private_key: Vec<u8>,
    pub key_type: String,
}

impl From<FfiKeyPair> for KeyPair {
    fn from(kp: FfiKeyPair) -> Self {
        Self {
            public_key: kp.public_key,
            private_key: kp.private_key,
            key_type: kp.key_type,
        }
    }
}

/// Encrypted data container
#[frb(dart_metadata = ("freezed"))]
#[derive(Debug, Clone)]
pub struct EncryptedData {
    pub ciphertext: Vec<u8>,
    pub nonce: Vec<u8>,
    pub tag: Vec<u8>,
}

impl From<FfiEncryptedData> for EncryptedData {
    fn from(ed: FfiEncryptedData) -> Self {
        Self {
            ciphertext: ed.ciphertext,
            nonce: ed.nonce,
            tag: ed.tag,
        }
    }
}

impl From<EncryptedData> for FfiEncryptedData {
    fn from(ed: EncryptedData) -> Self {
        Self {
            ciphertext: ed.ciphertext,
            nonce: ed.nonce,
            tag: ed.tag,
        }
    }
}

/// Hybrid key bundle for PQXDH (Post-Quantum Extended Diffie-Hellman)
#[frb(dart_metadata = ("freezed"))]
#[derive(Debug, Clone)]
pub struct HybridKeyBundle {
    /// X25519 public key (32 bytes)
    pub x25519_public: Vec<u8>,
    /// X25519 private key (32 bytes)
    pub x25519_private: Vec<u8>,
    /// ML-KEM-768 encapsulation key (1184 bytes)
    pub ml_kem_public: Vec<u8>,
    /// ML-KEM-768 decapsulation key (2400 bytes)
    pub ml_kem_private: Vec<u8>,
}

#[cfg(feature = "pq")]
impl From<FfiHybridKeyBundle> for HybridKeyBundle {
    fn from(hkb: FfiHybridKeyBundle) -> Self {
        Self {
            x25519_public: hkb.x25519_public,
            x25519_private: hkb.x25519_private,
            ml_kem_public: hkb.ml_kem_public,
            ml_kem_private: hkb.ml_kem_private,
        }
    }
}

/// Crypto library status information
#[frb(dart_metadata = ("freezed"))]
#[derive(Debug, Clone)]
pub struct CryptoStatus {
    /// Whether the library is initialized
    pub initialized: bool,
    /// Whether post-quantum cryptography is available
    pub post_quantum_available: bool,
    /// Library version
    pub version: String,
}

// ============================================================================
// Initialization Functions
// ============================================================================

/// Initialize the cryptographic library
///
/// This must be called once at application startup before using any
/// cryptographic functions. It validates implementations and initializes
/// random number generators.
///
/// Returns `Ok(())` if initialization succeeds.
#[frb(sync)]
pub fn crypto_init() -> Result<(), String> {
    if INITIALIZED.load(Ordering::SeqCst) {
        return Ok(());
    }

    init_crypto()?;
    INITIALIZED.store(true, Ordering::SeqCst);

    log::info!("guardyn-crypto-ffi initialized successfully");
    Ok(())
}

/// Get the current status of the crypto library
#[frb(sync)]
pub fn crypto_status() -> CryptoStatus {
    CryptoStatus {
        initialized: INITIALIZED.load(Ordering::SeqCst),
        post_quantum_available: is_pq_available(),
        version: env!("CARGO_PKG_VERSION").to_string(),
    }
}

/// Check if post-quantum cryptography is available
#[frb(sync)]
pub fn crypto_is_pq_available() -> bool {
    is_pq_available()
}

// ============================================================================
// Key Generation Functions
// ============================================================================

/// Generate an X25519 key pair for Diffie-Hellman key exchange
///
/// Returns a key pair with:
/// - `public_key`: 32 bytes
/// - `private_key`: 32 bytes
/// - `key_type`: "X25519"
#[frb(sync)]
pub fn crypto_generate_x25519_keypair() -> KeyPair {
    generate_x25519_keypair().into()
}

/// Generate an Ed25519 key pair for digital signatures
///
/// Returns a key pair with:
/// - `public_key`: 32 bytes (verifying key)
/// - `private_key`: 32 bytes (signing key)
/// - `key_type`: "Ed25519"
#[frb(sync)]
pub fn crypto_generate_ed25519_keypair() -> KeyPair {
    generate_ed25519_keypair().into()
}

/// Generate an Ed25519 key pair from a 32-byte seed (deterministic)
///
/// This is useful for testing with known test vectors to verify
/// cross-platform compatibility between Rust and Dart implementations.
///
/// Returns a key pair with:
/// - `public_key`: 32 bytes (verifying key)
/// - `private_key`: 32 bytes (signing key derived from seed)
/// - `key_type`: "Ed25519"
#[frb(sync)]
pub fn crypto_generate_ed25519_keypair_from_seed(seed: Vec<u8>) -> Result<KeyPair, String> {
    generate_ed25519_keypair_from_seed(seed).map(|kp| kp.into())
}

/// Generate a hybrid key bundle for PQXDH
///
/// This combines X25519 (classical) with ML-KEM-768 (post-quantum)
/// for hybrid key exchange that is secure against quantum attacks.
///
/// Returns `None` if post-quantum feature is not enabled.
#[frb(sync)]
pub fn crypto_generate_hybrid_key_bundle() -> Result<Option<HybridKeyBundle>, String> {
    #[cfg(feature = "pq")]
    {
        let bundle = generate_hybrid_key_bundle()?;
        Ok(Some(bundle.into()))
    }

    #[cfg(not(feature = "pq"))]
    {
        Ok(None)
    }
}

// ============================================================================
// Key Exchange Functions
// ============================================================================

/// Perform X25519 Diffie-Hellman key agreement
///
/// Derives a 32-byte shared secret from a private key and a remote public key.
///
/// # Arguments
/// - `private_key`: 32-byte X25519 private key
/// - `public_key`: 32-byte X25519 public key (from remote party)
///
/// # Returns
/// 32-byte shared secret
#[frb(sync)]
pub fn crypto_x25519_dh(private_key: Vec<u8>, public_key: Vec<u8>) -> Result<Vec<u8>, String> {
    x25519_diffie_hellman(private_key, public_key)
}

// ============================================================================
// Key Conversion Functions
// ============================================================================

/// Convert Ed25519 public key to X25519 public key
///
/// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
/// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
///
/// # Arguments
/// - `ed25519_public`: 32-byte Ed25519 public key
///
/// # Returns
/// 32-byte X25519 public key
#[frb(sync)]
pub fn crypto_ed25519_public_to_x25519(ed25519_public: Vec<u8>) -> Result<Vec<u8>, String> {
    ed25519_public_to_x25519(ed25519_public)
}

/// Convert Ed25519 secret key (seed) to X25519 secret key
///
/// The conversion process matches TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk.
///
/// # Arguments
/// - `ed25519_seed`: 32-byte Ed25519 seed/private key
///
/// # Returns
/// 32-byte X25519 secret key
#[frb(sync)]
pub fn crypto_ed25519_secret_to_x25519(ed25519_seed: Vec<u8>) -> Result<Vec<u8>, String> {
    ed25519_secret_to_x25519(ed25519_seed)
}

// ============================================================================
// Symmetric Encryption Functions
// ============================================================================

/// Encrypt data using AES-256-GCM
///
/// This is the primary encryption method for message content.
///
/// # Arguments
/// - `plaintext`: Data to encrypt
/// - `key`: 32-byte encryption key
/// - `nonce`: Optional 12-byte nonce (generated randomly if not provided)
/// - `associated_data`: Optional additional authenticated data (AAD)
///
/// # Returns
/// `EncryptedData` containing ciphertext, nonce, and authentication tag
pub fn crypto_encrypt_aes_gcm(
    plaintext: Vec<u8>,
    key: Vec<u8>,
    nonce: Option<Vec<u8>>,
    associated_data: Option<Vec<u8>>,
) -> Result<EncryptedData, String> {
    encrypt_aes256_gcm(plaintext, key, nonce, associated_data).map(Into::into)
}

/// Decrypt AES-256-GCM ciphertext
///
/// # Arguments
/// - `encrypted`: Encrypted data from `crypto_encrypt_aes_gcm`
/// - `key`: 32-byte encryption key (same as used for encryption)
/// - `associated_data`: Optional AAD (must match what was used for encryption)
///
/// # Returns
/// Decrypted plaintext
pub fn crypto_decrypt_aes_gcm(
    encrypted: EncryptedData,
    key: Vec<u8>,
    associated_data: Option<Vec<u8>>,
) -> Result<Vec<u8>, String> {
    decrypt_aes256_gcm(encrypted.into(), key, associated_data)
}

/// Encrypt data using ChaCha20-Poly1305
///
/// Alternative to AES-GCM, useful on platforms without AES hardware acceleration.
///
/// # Arguments
/// - `plaintext`: Data to encrypt
/// - `key`: 32-byte encryption key
/// - `nonce`: Optional 12-byte nonce (generated randomly if not provided)
/// - `associated_data`: Optional AAD
pub fn crypto_encrypt_chacha20(
    plaintext: Vec<u8>,
    key: Vec<u8>,
    nonce: Option<Vec<u8>>,
    associated_data: Option<Vec<u8>>,
) -> Result<EncryptedData, String> {
    encrypt_chacha20_poly1305(plaintext, key, nonce, associated_data).map(Into::into)
}

/// Decrypt ChaCha20-Poly1305 ciphertext
pub fn crypto_decrypt_chacha20(
    encrypted: EncryptedData,
    key: Vec<u8>,
    associated_data: Option<Vec<u8>>,
) -> Result<Vec<u8>, String> {
    decrypt_chacha20_poly1305(encrypted.into(), key, associated_data)
}

// ============================================================================
// Key Derivation Functions
// ============================================================================

/// Derive encryption key using HKDF-SHA256
///
/// Used for deriving multiple keys from a shared secret.
///
/// # Arguments
/// - `input_key_material`: Initial key material (e.g., DH shared secret)
/// - `salt`: Optional salt value
/// - `info`: Context-specific info string
/// - `output_length`: Desired output length (default 32 bytes)
///
/// # Returns
/// Derived key material
pub fn crypto_hkdf(
    input_key_material: Vec<u8>,
    salt: Option<Vec<u8>>,
    info: Vec<u8>,
    output_length: u32,
) -> Result<Vec<u8>, String> {
    hkdf_sha256(input_key_material, salt, info, output_length)
}

// ============================================================================
// Signature Functions
// ============================================================================

/// Sign a message using Ed25519
///
/// # Arguments
/// - `private_key`: 32-byte Ed25519 signing key
/// - `message`: Message to sign
///
/// # Returns
/// 64-byte Ed25519 signature
#[frb(sync)]
pub fn crypto_sign_ed25519(private_key: Vec<u8>, message: Vec<u8>) -> Result<Vec<u8>, String> {
    sign_ed25519(private_key, message)
}

/// Verify an Ed25519 signature
///
/// # Arguments
/// - `public_key`: 32-byte Ed25519 verifying key
/// - `message`: Original message
/// - `signature`: 64-byte signature to verify
///
/// # Returns
/// `true` if signature is valid, `false` otherwise
#[frb(sync)]
pub fn crypto_verify_ed25519(
    public_key: Vec<u8>,
    message: Vec<u8>,
    signature: Vec<u8>,
) -> Result<bool, String> {
    verify_ed25519(public_key, message, signature)
}

// ============================================================================
// PADMÉ Padding Functions
// ============================================================================

/// Apply PADMÉ padding to a message
///
/// PADMÉ (Padding for Anonymity and Message Equivalence) pads messages
/// to sizes that protect against traffic analysis attacks.
///
/// # Arguments
/// - `message`: Original message
///
/// # Returns
/// Padded message
pub fn crypto_pad_message(message: Vec<u8>) -> Result<Vec<u8>, String> {
    ffi_pad_message(message)
}

/// Remove PADMÉ padding from a message
///
/// # Arguments
/// - `padded_message`: Padded message from `crypto_pad_message`
///
/// # Returns
/// Original unpadded message
pub fn crypto_unpad_message(padded_message: Vec<u8>) -> Result<Vec<u8>, String> {
    ffi_unpad_message(padded_message)
}

// ============================================================================
// Utility Functions
// ============================================================================

/// Generate cryptographically secure random bytes
///
/// # Arguments
/// - `length`: Number of bytes to generate
///
/// # Returns
/// Random bytes
#[frb(sync)]
pub fn crypto_random_bytes(length: u32) -> Vec<u8> {
    use rand::RngCore;
    let mut bytes = vec![0u8; length as usize];
    rand::thread_rng().fill_bytes(&mut bytes);
    bytes
}

/// Constant-time comparison of two byte arrays
///
/// Prevents timing attacks when comparing secrets.
///
/// # Returns
/// `true` if arrays are equal
#[frb(sync)]
pub fn crypto_constant_time_eq(a: Vec<u8>, b: Vec<u8>) -> bool {
    use subtle::ConstantTimeEq;
    if a.len() != b.len() {
        return false;
    }
    a.ct_eq(&b).into()
}

// ============================================================================
// Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_init() {
        assert!(crypto_init().is_ok());
        let status = crypto_status();
        assert!(status.initialized);
    }

    #[test]
    fn test_x25519_keypair() {
        let kp = crypto_generate_x25519_keypair();
        assert_eq!(kp.public_key.len(), 32);
        assert_eq!(kp.private_key.len(), 32);
        assert_eq!(kp.key_type, "X25519");
    }

    #[test]
    fn test_ed25519_keypair() {
        let kp = crypto_generate_ed25519_keypair();
        assert_eq!(kp.public_key.len(), 32);
        assert_eq!(kp.private_key.len(), 32);
        assert_eq!(kp.key_type, "Ed25519");
    }

    #[test]
    fn test_x25519_dh() {
        let alice = crypto_generate_x25519_keypair();
        let bob = crypto_generate_x25519_keypair();

        let shared_alice = crypto_x25519_dh(alice.private_key, bob.public_key.clone()).unwrap();
        let shared_bob = crypto_x25519_dh(bob.private_key, alice.public_key.clone()).unwrap();

        assert_eq!(shared_alice, shared_bob);
    }

    #[test]
    fn test_aes_gcm_roundtrip() {
        let key = crypto_random_bytes(32);
        let plaintext = b"Hello, Guardyn!".to_vec();

        let encrypted = crypto_encrypt_aes_gcm(plaintext.clone(), key.clone(), None, None).unwrap();
        let decrypted = crypto_decrypt_aes_gcm(encrypted, key, None).unwrap();

        assert_eq!(plaintext, decrypted);
    }

    #[test]
    fn test_chacha20_roundtrip() {
        let key = crypto_random_bytes(32);
        let plaintext = b"Hello, Guardyn!".to_vec();

        let encrypted = crypto_encrypt_chacha20(plaintext.clone(), key.clone(), None, None).unwrap();
        let decrypted = crypto_decrypt_chacha20(encrypted, key, None).unwrap();

        assert_eq!(plaintext, decrypted);
    }

    #[test]
    fn test_ed25519_sign_verify() {
        let kp = crypto_generate_ed25519_keypair();
        let message = b"Test message".to_vec();

        let signature = crypto_sign_ed25519(kp.private_key, message.clone()).unwrap();
        let valid = crypto_verify_ed25519(kp.public_key, message, signature).unwrap();

        assert!(valid);
    }

    #[test]
    fn test_hkdf() {
        let ikm = crypto_random_bytes(32);
        let info = b"guardyn-test".to_vec();

        let derived = crypto_hkdf(ikm, None, info, 64).unwrap();
        assert_eq!(derived.len(), 64);
    }

    #[test]
    fn test_padding_roundtrip() {
        let message = b"Secret message".to_vec();

        let padded = crypto_pad_message(message.clone()).unwrap();
        let unpadded = crypto_unpad_message(padded).unwrap();

        assert_eq!(message, unpadded);
    }

    #[test]
    fn test_constant_time_eq() {
        let a = vec![1, 2, 3, 4];
        let b = vec![1, 2, 3, 4];
        let c = vec![1, 2, 3, 5];

        assert!(crypto_constant_time_eq(a.clone(), b));
        assert!(!crypto_constant_time_eq(a, c));
    }
}
