//! Sealed Sender Protocol Implementation
//!
//! Sealed Sender provides metadata protection by hiding the sender's identity
//! from the server. Only the recipient can decrypt the sender's identity.
//!
//! # Protocol Overview
//!
//! 1. Sender creates a "Sender Certificate" signed by their identity key
//! 2. Sender encrypts message + certificate using recipient's public key
//! 3. Server only sees recipient ID - sender is hidden
//! 4. Recipient decrypts envelope, verifies sender certificate, decrypts message
//!
//! # Security Properties
//!
//! - **Sender Anonymity**: Server cannot determine message sender
//! - **Recipient Authentication**: Only intended recipient can decrypt
//! - **Sender Authentication**: Recipient verifies sender via certificate
//! - **Forward Secrecy**: Each envelope uses ephemeral keys
//!
//! # References
//!
//! Based on Signal's Sealed Sender:
//! <https://signal.org/blog/sealed-sender/>

use crate::{CryptoError, Result};
use aes_gcm::{
    aead::{Aead, KeyInit},
    Aes256Gcm, Nonce,
};
use ed25519_dalek::{Signature, Signer, SigningKey, VerifyingKey};
use hkdf::Hkdf;
use rand::rngs::OsRng;
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use sha2::Sha256;
use x25519_dalek::{EphemeralSecret, PublicKey as X25519PublicKey, StaticSecret};
use zeroize::Zeroize;

/// Label for HKDF derivation
const SEALED_SENDER_HKDF_LABEL: &[u8] = b"Guardyn-SealedSender-v1";

/// Helper for serializing [u8; 64] as hex string
mod signature_serde {
    use super::*;

    pub fn serialize<S>(bytes: &[u8; 64], serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_bytes(bytes)
    }

    pub fn deserialize<'de, D>(deserializer: D) -> std::result::Result<[u8; 64], D::Error>
    where
        D: Deserializer<'de>,
    {
        use serde::de::Error;
        let bytes: Vec<u8> = Vec::deserialize(deserializer)?;
        if bytes.len() != 64 {
            return Err(D::Error::custom(format!(
                "expected 64 bytes, got {}",
                bytes.len()
            )));
        }
        let mut arr = [0u8; 64];
        arr.copy_from_slice(&bytes);
        Ok(arr)
    }
}

/// Sender Certificate - proves sender identity to recipient
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SenderCertificate {
    /// Sender's user ID (UUID)
    pub sender_user_id: String,

    /// Sender's device ID (UUID)
    pub sender_device_id: String,

    /// Sender's identity public key (Ed25519 verifying key)
    pub sender_identity_key: [u8; 32],

    /// Certificate expiration timestamp (Unix epoch seconds)
    pub expires_at: i64,

    /// Signature over (sender_user_id || sender_device_id || sender_identity_key || expires_at)
    #[serde(with = "signature_serde")]
    pub signature: [u8; 64],
}

impl SenderCertificate {
    /// Create a new sender certificate
    pub fn new(
        sender_user_id: String,
        sender_device_id: String,
        signing_key: &SigningKey,
        expires_at: i64,
    ) -> Result<Self> {
        let identity_key = signing_key.verifying_key().to_bytes();

        // Create message to sign
        let message = Self::certificate_message(
            &sender_user_id,
            &sender_device_id,
            &identity_key,
            expires_at,
        );

        // Sign the certificate
        let signature = signing_key.sign(&message);

        Ok(Self {
            sender_user_id,
            sender_device_id,
            sender_identity_key: identity_key,
            expires_at,
            signature: signature.to_bytes(),
        })
    }

    /// Verify the certificate signature
    pub fn verify(&self) -> Result<bool> {
        let verifying_key = VerifyingKey::from_bytes(&self.sender_identity_key)
            .map_err(|e| CryptoError::InvalidKey(e.to_string()))?;

        let message = Self::certificate_message(
            &self.sender_user_id,
            &self.sender_device_id,
            &self.sender_identity_key,
            self.expires_at,
        );

        let signature = Signature::from_bytes(&self.signature);

        verifying_key
            .verify_strict(&message, &signature)
            .map(|_| true)
            .map_err(|e| CryptoError::InvalidSignature(e.to_string()))
    }

    /// Check if certificate has expired
    pub fn is_expired(&self) -> bool {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_secs() as i64)
            .unwrap_or(0);
        now > self.expires_at
    }

    /// Generate the message to sign/verify
    fn certificate_message(
        sender_user_id: &str,
        sender_device_id: &str,
        identity_key: &[u8; 32],
        expires_at: i64,
    ) -> Vec<u8> {
        let mut message = Vec::new();
        message.extend_from_slice(sender_user_id.as_bytes());
        message.push(0); // Null separator
        message.extend_from_slice(sender_device_id.as_bytes());
        message.push(0);
        message.extend_from_slice(identity_key);
        message.extend_from_slice(&expires_at.to_be_bytes());
        message
    }

    /// Serialize to bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut bytes = Vec::new();

        // sender_user_id (length-prefixed)
        let user_id_bytes = self.sender_user_id.as_bytes();
        bytes.extend_from_slice(&(user_id_bytes.len() as u16).to_be_bytes());
        bytes.extend_from_slice(user_id_bytes);

        // sender_device_id (length-prefixed)
        let device_id_bytes = self.sender_device_id.as_bytes();
        bytes.extend_from_slice(&(device_id_bytes.len() as u16).to_be_bytes());
        bytes.extend_from_slice(device_id_bytes);

        // sender_identity_key (32 bytes)
        bytes.extend_from_slice(&self.sender_identity_key);

        // expires_at (8 bytes)
        bytes.extend_from_slice(&self.expires_at.to_be_bytes());

        // signature (64 bytes)
        bytes.extend_from_slice(&self.signature);

        bytes
    }

    /// Deserialize from bytes
    pub fn from_bytes(bytes: &[u8]) -> Result<Self> {
        if bytes.len() < 2 {
            return Err(CryptoError::Protocol("Certificate too short".into()));
        }

        let mut offset = 0;

        // sender_user_id
        let user_id_len = u16::from_be_bytes([bytes[offset], bytes[offset + 1]]) as usize;
        offset += 2;
        if bytes.len() < offset + user_id_len {
            return Err(CryptoError::Protocol("Invalid user_id length".into()));
        }
        let sender_user_id = String::from_utf8(bytes[offset..offset + user_id_len].to_vec())
            .map_err(|e| CryptoError::Protocol(e.to_string()))?;
        offset += user_id_len;

        // sender_device_id
        if bytes.len() < offset + 2 {
            return Err(CryptoError::Protocol("Missing device_id length".into()));
        }
        let device_id_len = u16::from_be_bytes([bytes[offset], bytes[offset + 1]]) as usize;
        offset += 2;
        if bytes.len() < offset + device_id_len {
            return Err(CryptoError::Protocol("Invalid device_id length".into()));
        }
        let sender_device_id = String::from_utf8(bytes[offset..offset + device_id_len].to_vec())
            .map_err(|e| CryptoError::Protocol(e.to_string()))?;
        offset += device_id_len;

        // sender_identity_key (32 bytes)
        if bytes.len() < offset + 32 {
            return Err(CryptoError::Protocol("Missing identity key".into()));
        }
        let mut sender_identity_key = [0u8; 32];
        sender_identity_key.copy_from_slice(&bytes[offset..offset + 32]);
        offset += 32;

        // expires_at (8 bytes)
        if bytes.len() < offset + 8 {
            return Err(CryptoError::Protocol("Missing expires_at".into()));
        }
        let expires_at = i64::from_be_bytes(bytes[offset..offset + 8].try_into().unwrap());
        offset += 8;

        // signature (64 bytes)
        if bytes.len() < offset + 64 {
            return Err(CryptoError::Protocol("Missing signature".into()));
        }
        let mut signature = [0u8; 64];
        signature.copy_from_slice(&bytes[offset..offset + 64]);

        Ok(Self {
            sender_user_id,
            sender_device_id,
            sender_identity_key,
            expires_at,
            signature,
        })
    }
}

/// Sealed Sender Envelope - encrypted message with hidden sender identity
#[derive(Clone, Debug)]
pub struct SealedSenderEnvelope {
    /// Protocol version (currently 1)
    pub version: u8,

    /// Ephemeral public key for ECDH (X25519)
    pub ephemeral_public_key: [u8; 32],

    /// Encrypted payload: certificate + inner message
    pub encrypted_payload: Vec<u8>,
}

impl SealedSenderEnvelope {
    /// Serialize to bytes for transmission
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut bytes = Vec::new();

        // Version (1 byte)
        bytes.push(self.version);

        // Ephemeral public key (32 bytes)
        bytes.extend_from_slice(&self.ephemeral_public_key);

        // Encrypted payload (variable length)
        bytes.extend_from_slice(&self.encrypted_payload);

        bytes
    }

    /// Deserialize from bytes
    pub fn from_bytes(bytes: &[u8]) -> Result<Self> {
        if bytes.len() < 1 + 32 + 12 + 16 {
            // version + pubkey + min nonce + tag
            return Err(CryptoError::Protocol("Envelope too short".into()));
        }

        let version = bytes[0];
        if version != 1 {
            return Err(CryptoError::Protocol(format!(
                "Unsupported envelope version: {}",
                version
            )));
        }

        let mut ephemeral_public_key = [0u8; 32];
        ephemeral_public_key.copy_from_slice(&bytes[1..33]);

        let encrypted_payload = bytes[33..].to_vec();

        Ok(Self {
            version,
            ephemeral_public_key,
            encrypted_payload,
        })
    }
}

/// Sealed Sender Protocol Implementation
pub struct SealedSender;

impl SealedSender {
    /// Seal a message with hidden sender identity
    ///
    /// # Arguments
    /// - `certificate`: Sender's certificate (proves identity to recipient)
    /// - `recipient_identity_key`: Recipient's X25519 public key
    /// - `inner_message`: The actual encrypted message (Double Ratchet ciphertext)
    ///
    /// # Returns
    /// Sealed envelope that hides sender from server
    pub fn seal(
        certificate: &SenderCertificate,
        recipient_identity_key: &X25519PublicKey,
        inner_message: &[u8],
    ) -> Result<SealedSenderEnvelope> {
        // 1. Generate ephemeral key pair
        let ephemeral_secret = EphemeralSecret::random_from_rng(OsRng);
        let ephemeral_public = X25519PublicKey::from(&ephemeral_secret);

        // 2. Compute shared secret: ECDH(ephemeral, recipient_identity)
        let shared_secret = ephemeral_secret.diffie_hellman(recipient_identity_key);

        // 3. Derive encryption key using HKDF
        let mut encryption_key = [0u8; 32];
        let hkdf = Hkdf::<Sha256>::new(None, shared_secret.as_bytes());
        hkdf.expand(SEALED_SENDER_HKDF_LABEL, &mut encryption_key)
            .map_err(|_| CryptoError::Encryption("HKDF expansion failed".into()))?;

        // 4. Create payload: certificate || inner_message
        let certificate_bytes = certificate.to_bytes();
        let mut payload = Vec::new();
        payload.extend_from_slice(&(certificate_bytes.len() as u32).to_be_bytes());
        payload.extend_from_slice(&certificate_bytes);
        payload.extend_from_slice(inner_message);

        // 5. Encrypt payload with AES-256-GCM
        let cipher = Aes256Gcm::new_from_slice(&encryption_key)
            .map_err(|e| CryptoError::Encryption(e.to_string()))?;

        let mut nonce_bytes = [0u8; 12];
        OsRng.fill(&mut nonce_bytes);
        let nonce: Nonce<_> = nonce_bytes.into();

        let ciphertext = cipher
            .encrypt(&nonce, payload.as_ref())
            .map_err(|e| CryptoError::Encryption(e.to_string()))?;

        // 6. Prepend nonce to ciphertext
        let mut encrypted_payload = Vec::new();
        encrypted_payload.extend_from_slice(&nonce_bytes);
        encrypted_payload.extend_from_slice(&ciphertext);

        // encryption_key will be dropped when it goes out of scope
        // zeroize will clear the memory

        Ok(SealedSenderEnvelope {
            version: 1,
            ephemeral_public_key: ephemeral_public.to_bytes(),
            encrypted_payload,
        })
    }

    /// Unseal a message and reveal sender identity
    ///
    /// # Arguments
    /// - `envelope`: The sealed envelope to decrypt
    /// - `recipient_identity_secret`: Recipient's X25519 private key
    ///
    /// # Returns
    /// Tuple of (sender_certificate, inner_message)
    pub fn unseal(
        envelope: &SealedSenderEnvelope,
        recipient_identity_secret: &StaticSecret,
    ) -> Result<(SenderCertificate, Vec<u8>)> {
        if envelope.version != 1 {
            return Err(CryptoError::Protocol(format!(
                "Unsupported envelope version: {}",
                envelope.version
            )));
        }

        // 1. Parse ephemeral public key
        let ephemeral_public = X25519PublicKey::from(envelope.ephemeral_public_key);

        // 2. Compute shared secret: ECDH(recipient_identity, ephemeral)
        let shared_secret = recipient_identity_secret.diffie_hellman(&ephemeral_public);

        // 3. Derive decryption key using HKDF
        let mut decryption_key = [0u8; 32];
        let hkdf = Hkdf::<Sha256>::new(None, shared_secret.as_bytes());
        hkdf.expand(SEALED_SENDER_HKDF_LABEL, &mut decryption_key)
            .map_err(|_| CryptoError::Decryption("HKDF expansion failed".into()))?;

        // 4. Extract nonce and ciphertext
        if envelope.encrypted_payload.len() < 12 + 16 {
            return Err(CryptoError::Decryption("Payload too short".into()));
        }
        let nonce_bytes = &envelope.encrypted_payload[..12];
        let ciphertext = &envelope.encrypted_payload[12..];

        // 5. Decrypt payload with AES-256-GCM
        let cipher = Aes256Gcm::new_from_slice(&decryption_key)
            .map_err(|e| CryptoError::Decryption(e.to_string()))?;

        let nonce_arr: [u8; 12] = nonce_bytes
            .try_into()
            .map_err(|_| CryptoError::Decryption("Invalid nonce length".to_string()))?;
        let nonce: Nonce<_> = nonce_arr.into();

        let payload = cipher
            .decrypt(&nonce, ciphertext)
            .map_err(|e| CryptoError::Decryption(e.to_string()))?;

        // Clean up sensitive data
        decryption_key.zeroize();

        // 6. Parse payload: certificate_length || certificate || inner_message
        if payload.len() < 4 {
            return Err(CryptoError::Protocol("Payload too short for header".into()));
        }

        let cert_len = u32::from_be_bytes(payload[..4].try_into().unwrap()) as usize;
        if payload.len() < 4 + cert_len {
            return Err(CryptoError::Protocol("Invalid certificate length".into()));
        }

        let certificate = SenderCertificate::from_bytes(&payload[4..4 + cert_len])?;
        let inner_message = payload[4 + cert_len..].to_vec();

        // 7. Verify certificate signature
        certificate.verify()?;

        // 8. Check certificate expiration
        if certificate.is_expired() {
            return Err(CryptoError::Protocol("Sender certificate expired".into()));
        }

        Ok((certificate, inner_message))
    }
}

/// Generate a random nonce using OsRng
trait FillRandom {
    fn fill(&mut self, dest: &mut [u8]);
}

impl FillRandom for OsRng {
    fn fill(&mut self, dest: &mut [u8]) {
        use rand::RngCore;
        self.fill_bytes(dest);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use ed25519_dalek::SigningKey;

    fn generate_test_keys() -> (SigningKey, StaticSecret) {
        let signing_key = SigningKey::generate(&mut OsRng);
        let static_secret = StaticSecret::random_from_rng(OsRng);
        (signing_key, static_secret)
    }

    #[test]
    fn test_sender_certificate_creation() {
        let (signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            + 86400; // 24 hours

        let cert = SenderCertificate::new(
            "user-123".to_string(),
            "device-456".to_string(),
            &signing_key,
            expires_at,
        )
        .unwrap();

        assert_eq!(cert.sender_user_id, "user-123");
        assert_eq!(cert.sender_device_id, "device-456");
        assert!(!cert.is_expired());
    }

    #[test]
    fn test_sender_certificate_verification() {
        let (signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            + 86400;

        let cert = SenderCertificate::new(
            "user-123".to_string(),
            "device-456".to_string(),
            &signing_key,
            expires_at,
        )
        .unwrap();

        assert!(cert.verify().unwrap());
    }

    #[test]
    fn test_sender_certificate_serialization() {
        let (signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            + 86400;

        let cert = SenderCertificate::new(
            "user-123".to_string(),
            "device-456".to_string(),
            &signing_key,
            expires_at,
        )
        .unwrap();

        let bytes = cert.to_bytes();
        let recovered = SenderCertificate::from_bytes(&bytes).unwrap();

        assert_eq!(recovered.sender_user_id, cert.sender_user_id);
        assert_eq!(recovered.sender_device_id, cert.sender_device_id);
        assert_eq!(recovered.sender_identity_key, cert.sender_identity_key);
        assert_eq!(recovered.expires_at, cert.expires_at);
        assert_eq!(recovered.signature, cert.signature);
    }

    #[test]
    fn test_sealed_sender_round_trip() {
        // Sender setup
        let (sender_signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            + 86400;

        let sender_cert = SenderCertificate::new(
            "sender-user".to_string(),
            "sender-device".to_string(),
            &sender_signing_key,
            expires_at,
        )
        .unwrap();

        // Recipient setup
        let recipient_secret = StaticSecret::random_from_rng(OsRng);
        let recipient_public = X25519PublicKey::from(&recipient_secret);

        // Seal message
        let inner_message = b"Hello, this is a secret message!";
        let envelope = SealedSender::seal(&sender_cert, &recipient_public, inner_message).unwrap();

        // Verify envelope structure
        assert_eq!(envelope.version, 1);
        assert!(!envelope.encrypted_payload.is_empty());

        // Unseal message
        let (recovered_cert, recovered_message) =
            SealedSender::unseal(&envelope, &recipient_secret).unwrap();

        assert_eq!(recovered_cert.sender_user_id, "sender-user");
        assert_eq!(recovered_cert.sender_device_id, "sender-device");
        assert_eq!(recovered_message, inner_message);
    }

    #[test]
    fn test_sealed_sender_envelope_serialization() {
        let (sender_signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            + 86400;

        let sender_cert = SenderCertificate::new(
            "sender-user".to_string(),
            "sender-device".to_string(),
            &sender_signing_key,
            expires_at,
        )
        .unwrap();

        let recipient_secret = StaticSecret::random_from_rng(OsRng);
        let recipient_public = X25519PublicKey::from(&recipient_secret);

        let envelope =
            SealedSender::seal(&sender_cert, &recipient_public, b"test message").unwrap();

        // Serialize and deserialize
        let bytes = envelope.to_bytes();
        let recovered_envelope = SealedSenderEnvelope::from_bytes(&bytes).unwrap();

        assert_eq!(recovered_envelope.version, envelope.version);
        assert_eq!(
            recovered_envelope.ephemeral_public_key,
            envelope.ephemeral_public_key
        );
        assert_eq!(
            recovered_envelope.encrypted_payload,
            envelope.encrypted_payload
        );

        // Full round trip
        let (_, recovered_message) =
            SealedSender::unseal(&recovered_envelope, &recipient_secret).unwrap();
        assert_eq!(recovered_message, b"test message");
    }

    #[test]
    fn test_expired_certificate_rejected() {
        let (sender_signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            - 3600; // Expired 1 hour ago

        let sender_cert = SenderCertificate::new(
            "sender-user".to_string(),
            "sender-device".to_string(),
            &sender_signing_key,
            expires_at,
        )
        .unwrap();

        assert!(sender_cert.is_expired());

        let recipient_secret = StaticSecret::random_from_rng(OsRng);
        let recipient_public = X25519PublicKey::from(&recipient_secret);

        let envelope = SealedSender::seal(&sender_cert, &recipient_public, b"test").unwrap();

        // Should fail due to expired certificate
        let result = SealedSender::unseal(&envelope, &recipient_secret);
        assert!(result.is_err());
        assert!(result
            .unwrap_err()
            .to_string()
            .contains("certificate expired"));
    }

    #[test]
    fn test_wrong_recipient_fails() {
        let (sender_signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            + 86400;

        let sender_cert = SenderCertificate::new(
            "sender-user".to_string(),
            "sender-device".to_string(),
            &sender_signing_key,
            expires_at,
        )
        .unwrap();

        // Correct recipient keys
        let recipient_secret = StaticSecret::random_from_rng(OsRng);
        let recipient_public = X25519PublicKey::from(&recipient_secret);

        // Wrong recipient keys
        let wrong_secret = StaticSecret::random_from_rng(OsRng);

        let envelope = SealedSender::seal(&sender_cert, &recipient_public, b"test").unwrap();

        // Should fail with wrong key
        let result = SealedSender::unseal(&envelope, &wrong_secret);
        assert!(result.is_err());
    }

    #[test]
    fn test_tampered_envelope_fails() {
        let (sender_signing_key, _) = generate_test_keys();
        let expires_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64
            + 86400;

        let sender_cert = SenderCertificate::new(
            "sender-user".to_string(),
            "sender-device".to_string(),
            &sender_signing_key,
            expires_at,
        )
        .unwrap();

        let recipient_secret = StaticSecret::random_from_rng(OsRng);
        let recipient_public = X25519PublicKey::from(&recipient_secret);

        let envelope = SealedSender::seal(&sender_cert, &recipient_public, b"test").unwrap();

        // Tamper with the envelope
        let mut tampered = envelope.clone();
        if let Some(byte) = tampered.encrypted_payload.last_mut() {
            *byte ^= 0xFF;
        }

        // Should fail due to authentication failure
        let result = SealedSender::unseal(&tampered, &recipient_secret);
        assert!(result.is_err());
    }
}
