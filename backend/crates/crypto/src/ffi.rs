//! FFI bindings for Flutter Rust Bridge
//!
//! This module exposes Guardyn crypto primitives to Flutter via FFI.
//! It uses flutter_rust_bridge for automatic Dart code generation.
//!
//! # Safety
//! All functions in this module are designed to be memory-safe when called
//! from Dart through flutter_rust_bridge.
//!
//! # Features
//! Enable the `ffi` feature to include this module:
//! ```toml
//! [dependencies]
//! guardyn-crypto = { version = "0.1", features = ["ffi"] }
//! ```

use std::sync::RwLock;

// Re-export types that will be available in Dart
pub use crate::padding::{pad_message, unpad_message};

/// Hybrid key bundle for PQXDH key exchange
#[derive(Debug, Clone)]
pub struct FfiHybridKeyBundle {
    /// X25519 public key (32 bytes)
    pub x25519_public: Vec<u8>,
    /// X25519 private key (32 bytes)
    pub x25519_private: Vec<u8>,
    /// ML-KEM-768 encapsulation key (1184 bytes)
    pub ml_kem_public: Vec<u8>,
    /// ML-KEM-768 decapsulation key (2400 bytes)
    pub ml_kem_private: Vec<u8>,
}

/// Encrypted data with ciphertext, nonce, and tag
#[derive(Debug, Clone)]
pub struct FfiEncryptedData {
    /// Ciphertext
    pub ciphertext: Vec<u8>,
    /// Nonce/IV (12 bytes for AES-GCM, 12 bytes for ChaCha20-Poly1305)
    pub nonce: Vec<u8>,
    /// Authentication tag (16 bytes)
    pub tag: Vec<u8>,
}

/// Key pair with public and private components
#[derive(Debug, Clone)]
pub struct FfiKeyPair {
    pub public_key: Vec<u8>,
    pub private_key: Vec<u8>,
    pub key_type: String,
}

/// Crypto library initialization state
static INITIALIZED: RwLock<bool> = RwLock::new(false);

/// Initialize the crypto library
///
/// This should be called once at application startup.
/// It initializes random number generators and validates crypto implementations.
pub fn init_crypto() -> Result<(), String> {
    let mut init = INITIALIZED.write().map_err(|e| e.to_string())?;
    if *init {
        return Ok(());
    }

    // Validate crypto implementations
    #[cfg(feature = "pq")]
    {
        // Test ML-KEM key generation
        use ml_kem::KemCore;
        use ml_kem::MlKem768;
        let mut rng = rand::thread_rng();
        let _ = MlKem768::generate(&mut rng);
    }

    *init = true;
    Ok(())
}

/// Check if post-quantum cryptography is available
pub fn is_pq_available() -> bool {
    cfg!(feature = "pq")
}

/// Generate a hybrid key bundle (X25519 + ML-KEM-768)
///
/// Returns None if post-quantum feature is not enabled.
#[cfg(feature = "pq")]
pub fn generate_hybrid_key_bundle() -> Result<FfiHybridKeyBundle, String> {
    use crate::pqxdh::generate_hybrid_key_bundle as gen_bundle;

    // Generate bundle with one-time prekey and post-quantum key
    let (bundle, private_keys) = gen_bundle(true, true).map_err(|e| e.to_string())?;

    // Extract PQ keys (they should be present since we passed include_pq_key=true)
    let ml_kem_public = bundle.pq_prekey.unwrap_or_default();
    let ml_kem_private = private_keys.pq_decapsulation_key().unwrap_or_default();

    Ok(FfiHybridKeyBundle {
        x25519_public: bundle.signed_prekey.to_vec(),
        x25519_private: private_keys.signed_prekey().to_vec(),
        ml_kem_public,
        ml_kem_private,
    })
}

#[cfg(not(feature = "pq"))]
pub fn generate_hybrid_key_bundle() -> Result<FfiHybridKeyBundle, String> {
    Err("Post-quantum feature not enabled".to_string())
}

/// Apply PADMÉ padding to a message
///
/// Pads the message to a size determined by the PADMÉ algorithm,
/// which provides protection against traffic analysis.
pub fn ffi_pad_message(message: Vec<u8>) -> Result<Vec<u8>, String> {
    pad_message(&message).map_err(|e| e.to_string())
}

/// Remove PADMÉ padding from a message
///
/// Returns the original message without padding.
pub fn ffi_unpad_message(padded_message: Vec<u8>) -> Result<Vec<u8>, String> {
    unpad_message(&padded_message).map_err(|e| e.to_string())
}

/// Encrypt data using AES-256-GCM
///
/// If nonce is not provided, a random 12-byte nonce is generated.
pub fn encrypt_aes256_gcm(
    plaintext: Vec<u8>,
    key: Vec<u8>,
    nonce: Option<Vec<u8>>,
    associated_data: Option<Vec<u8>>,
) -> Result<FfiEncryptedData, String> {
    use aes_gcm::{
        aead::{Aead, KeyInit, Payload},
        Aes256Gcm, Nonce,
    };

    if key.len() != 32 {
        return Err("Key must be 32 bytes".to_string());
    }

    let cipher = Aes256Gcm::new_from_slice(&key).map_err(|e| e.to_string())?;

    let nonce_bytes = if let Some(n) = nonce {
        if n.len() != 12 {
            return Err("Nonce must be 12 bytes".to_string());
        }
        n
    } else {
        use rand::RngCore;
        let mut n = vec![0u8; 12];
        rand::thread_rng().fill_bytes(&mut n);
        n
    };

    let nonce = Nonce::from_slice(&nonce_bytes);

    let ciphertext = if let Some(aad) = associated_data {
        let payload = Payload {
            msg: &plaintext,
            aad: &aad,
        };
        cipher.encrypt(nonce, payload).map_err(|e| e.to_string())?
    } else {
        cipher.encrypt(nonce, plaintext.as_slice()).map_err(|e| e.to_string())?
    };

    // AES-GCM appends the tag to the ciphertext
    let tag_start = ciphertext.len() - 16;
    let (ct, tag) = ciphertext.split_at(tag_start);

    Ok(FfiEncryptedData {
        ciphertext: ct.to_vec(),
        nonce: nonce_bytes,
        tag: tag.to_vec(),
    })
}

/// Decrypt data using AES-256-GCM
pub fn decrypt_aes256_gcm(
    encrypted: FfiEncryptedData,
    key: Vec<u8>,
    associated_data: Option<Vec<u8>>,
) -> Result<Vec<u8>, String> {
    use aes_gcm::{
        aead::{Aead, KeyInit, Payload},
        Aes256Gcm, Nonce,
    };

    if key.len() != 32 {
        return Err("Key must be 32 bytes".to_string());
    }

    let cipher = Aes256Gcm::new_from_slice(&key).map_err(|e| e.to_string())?;
    let nonce = Nonce::from_slice(&encrypted.nonce);

    // Reconstruct ciphertext with tag appended
    let mut ciphertext_with_tag = encrypted.ciphertext;
    ciphertext_with_tag.extend_from_slice(&encrypted.tag);

    let plaintext = if let Some(aad) = associated_data {
        let payload = Payload {
            msg: &ciphertext_with_tag,
            aad: &aad,
        };
        cipher.decrypt(nonce, payload).map_err(|e| e.to_string())?
    } else {
        cipher.decrypt(nonce, ciphertext_with_tag.as_slice()).map_err(|e| e.to_string())?
    };

    Ok(plaintext)
}

/// Encrypt data using ChaCha20-Poly1305
pub fn encrypt_chacha20_poly1305(
    plaintext: Vec<u8>,
    key: Vec<u8>,
    nonce: Option<Vec<u8>>,
    associated_data: Option<Vec<u8>>,
) -> Result<FfiEncryptedData, String> {
    use chacha20poly1305::{
        aead::{Aead, KeyInit, Payload},
        ChaCha20Poly1305, Nonce,
    };

    if key.len() != 32 {
        return Err("Key must be 32 bytes".to_string());
    }

    let cipher = ChaCha20Poly1305::new_from_slice(&key).map_err(|e| e.to_string())?;

    let nonce_bytes = if let Some(n) = nonce {
        if n.len() != 12 {
            return Err("Nonce must be 12 bytes".to_string());
        }
        n
    } else {
        use rand::RngCore;
        let mut n = vec![0u8; 12];
        rand::thread_rng().fill_bytes(&mut n);
        n
    };

    let nonce = Nonce::from_slice(&nonce_bytes);

    let ciphertext = if let Some(aad) = associated_data {
        let payload = Payload {
            msg: &plaintext,
            aad: &aad,
        };
        cipher.encrypt(nonce, payload).map_err(|e| e.to_string())?
    } else {
        cipher.encrypt(nonce, plaintext.as_slice()).map_err(|e| e.to_string())?
    };

    // ChaCha20-Poly1305 appends the tag to the ciphertext
    let tag_start = ciphertext.len() - 16;
    let (ct, tag) = ciphertext.split_at(tag_start);

    Ok(FfiEncryptedData {
        ciphertext: ct.to_vec(),
        nonce: nonce_bytes,
        tag: tag.to_vec(),
    })
}

/// Decrypt data using ChaCha20-Poly1305
pub fn decrypt_chacha20_poly1305(
    encrypted: FfiEncryptedData,
    key: Vec<u8>,
    associated_data: Option<Vec<u8>>,
) -> Result<Vec<u8>, String> {
    use chacha20poly1305::{
        aead::{Aead, KeyInit, Payload},
        ChaCha20Poly1305, Nonce,
    };

    if key.len() != 32 {
        return Err("Key must be 32 bytes".to_string());
    }

    let cipher = ChaCha20Poly1305::new_from_slice(&key).map_err(|e| e.to_string())?;
    let nonce = Nonce::from_slice(&encrypted.nonce);

    let mut ciphertext_with_tag = encrypted.ciphertext;
    ciphertext_with_tag.extend_from_slice(&encrypted.tag);

    let plaintext = if let Some(aad) = associated_data {
        let payload = Payload {
            msg: &ciphertext_with_tag,
            aad: &aad,
        };
        cipher.decrypt(nonce, payload).map_err(|e| e.to_string())?
    } else {
        cipher.decrypt(nonce, ciphertext_with_tag.as_slice()).map_err(|e| e.to_string())?
    };

    Ok(plaintext)
}

/// Derive key using HKDF-SHA256
pub fn hkdf_sha256(
    ikm: Vec<u8>,
    salt: Option<Vec<u8>>,
    info: Vec<u8>,
    output_length: u32,
) -> Result<Vec<u8>, String> {
    use hkdf::Hkdf;
    use sha2::Sha256;

    let salt_bytes = salt.unwrap_or_default();
    let hkdf = Hkdf::<Sha256>::new(
        if salt_bytes.is_empty() { None } else { Some(&salt_bytes) },
        &ikm,
    );

    let mut output = vec![0u8; output_length as usize];
    hkdf.expand(&info, &mut output).map_err(|e| e.to_string())?;

    Ok(output)
}

/// Sign a message using Ed25519
pub fn sign_ed25519(private_key: Vec<u8>, message: Vec<u8>) -> Result<Vec<u8>, String> {
    use ed25519_dalek::{Signer, SigningKey};

    if private_key.len() != 32 {
        return Err("Private key must be 32 bytes".to_string());
    }

    let signing_key = SigningKey::from_bytes(
        private_key
            .as_slice()
            .try_into()
            .map_err(|_| "Invalid key length")?,
    );

    let signature = signing_key.sign(&message);
    Ok(signature.to_bytes().to_vec())
}

/// Verify an Ed25519 signature
pub fn verify_ed25519(
    public_key: Vec<u8>,
    message: Vec<u8>,
    signature: Vec<u8>,
) -> Result<bool, String> {
    use ed25519_dalek::{Signature, Verifier, VerifyingKey};

    if public_key.len() != 32 {
        return Err("Public key must be 32 bytes".to_string());
    }

    if signature.len() != 64 {
        return Err("Signature must be 64 bytes".to_string());
    }

    let verifying_key = VerifyingKey::from_bytes(
        public_key
            .as_slice()
            .try_into()
            .map_err(|_| "Invalid public key")?,
    )
    .map_err(|e| e.to_string())?;

    let sig = Signature::from_bytes(
        signature
            .as_slice()
            .try_into()
            .map_err(|_| "Invalid signature")?,
    );

    match verifying_key.verify(&message, &sig) {
        Ok(()) => Ok(true),
        Err(_) => Ok(false),
    }
}

/// Generate an X25519 key pair for key exchange
pub fn generate_x25519_keypair() -> FfiKeyPair {
    use x25519_dalek::{PublicKey, StaticSecret};

    let secret = StaticSecret::random_from_rng(rand::thread_rng());
    let public = PublicKey::from(&secret);

    FfiKeyPair {
        public_key: public.as_bytes().to_vec(),
        private_key: secret.as_bytes().to_vec(),
        key_type: "X25519".to_string(),
    }
}

/// Generate an Ed25519 key pair for signing
pub fn generate_ed25519_keypair() -> FfiKeyPair {
    use ed25519_dalek::SigningKey;

    let signing_key = SigningKey::generate(&mut rand::thread_rng());
    let verifying_key = signing_key.verifying_key();

    FfiKeyPair {
        public_key: verifying_key.to_bytes().to_vec(),
        private_key: signing_key.to_bytes().to_vec(),
        key_type: "Ed25519".to_string(),
    }
}

/// Perform X25519 Diffie-Hellman key agreement
pub fn x25519_diffie_hellman(
    private_key: Vec<u8>,
    public_key: Vec<u8>,
) -> Result<Vec<u8>, String> {
    use x25519_dalek::{PublicKey, StaticSecret};

    if private_key.len() != 32 {
        return Err("Private key must be 32 bytes".to_string());
    }
    if public_key.len() != 32 {
        return Err("Public key must be 32 bytes".to_string());
    }

    let secret = StaticSecret::from(
        <[u8; 32]>::try_from(private_key.as_slice()).map_err(|_| "Invalid private key")?,
    );
    let public = PublicKey::from(
        <[u8; 32]>::try_from(public_key.as_slice()).map_err(|_| "Invalid public key")?,
    );

    let shared_secret = secret.diffie_hellman(&public);
    Ok(shared_secret.as_bytes().to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_init_crypto() {
        let result = init_crypto();
        assert!(result.is_ok());
    }

    #[test]
    fn test_aes_gcm_roundtrip() {
        let key = vec![0u8; 32];
        let plaintext = b"Hello, Guardyn!".to_vec();

        let encrypted = encrypt_aes256_gcm(plaintext.clone(), key.clone(), None, None).unwrap();
        let decrypted = decrypt_aes256_gcm(encrypted, key, None).unwrap();

        assert_eq!(plaintext, decrypted);
    }

    #[test]
    fn test_chacha20_poly1305_roundtrip() {
        let key = vec![0u8; 32];
        let plaintext = b"Hello, Guardyn!".to_vec();

        let encrypted =
            encrypt_chacha20_poly1305(plaintext.clone(), key.clone(), None, None).unwrap();
        let decrypted = decrypt_chacha20_poly1305(encrypted, key, None).unwrap();

        assert_eq!(plaintext, decrypted);
    }

    #[test]
    fn test_ed25519_sign_verify() {
        let keypair = generate_ed25519_keypair();
        let message = b"Test message".to_vec();

        let signature = sign_ed25519(keypair.private_key, message.clone()).unwrap();
        let valid = verify_ed25519(keypair.public_key, message, signature).unwrap();

        assert!(valid);
    }

    #[test]
    fn test_x25519_dh() {
        let alice = generate_x25519_keypair();
        let bob = generate_x25519_keypair();

        let shared_alice =
            x25519_diffie_hellman(alice.private_key, bob.public_key.clone()).unwrap();
        let shared_bob =
            x25519_diffie_hellman(bob.private_key, alice.public_key.clone()).unwrap();

        assert_eq!(shared_alice, shared_bob);
    }

    #[test]
    fn test_padme_roundtrip() {
        let message = b"Secret message".to_vec();

        let padded = ffi_pad_message(message.clone()).unwrap();
        let unpadded = ffi_unpad_message(padded).unwrap();

        assert_eq!(message, unpadded);
    }

    #[test]
    fn test_hkdf() {
        let ikm = vec![0u8; 32];
        let info = b"guardyn-key".to_vec();

        let derived = hkdf_sha256(ikm, None, info, 32).unwrap();
        assert_eq!(derived.len(), 32);
    }
}
