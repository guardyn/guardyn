//! SFrame Encryption for WebRTC Media
//!
//! Provides end-to-end encryption for voice and video streams using SFrame.
//! SFrame (Secure Frame) is a lightweight encryption format for real-time media.

use std::sync::atomic::{AtomicU32, Ordering};
use tracing::{debug, error};

/// SFrame encryption context for a single participant
pub struct SFrameEncryptor {
    /// Key ID for key rotation support
    key_id: AtomicU32,
    /// Current encryption key (AES-256-GCM)
    encryption_key: Vec<u8>,
    /// Salt for HKDF
    salt: Vec<u8>,
    /// Frame counter for nonce generation
    frame_counter: AtomicU32,
}

impl SFrameEncryptor {
    /// Create a new SFrame encryptor with the given key
    pub fn new(encryption_key: Vec<u8>, key_id: u32) -> Self {
        // Generate salt from key using first 12 bytes
        let salt = if encryption_key.len() >= 12 {
            encryption_key[..12].to_vec()
        } else {
            let mut s = encryption_key.clone();
            s.resize(12, 0);
            s
        };

        Self {
            key_id: AtomicU32::new(key_id),
            encryption_key,
            salt,
            frame_counter: AtomicU32::new(0),
        }
    }

    /// Generate a new random encryption key
    pub fn generate_key() -> Vec<u8> {
        use std::time::{SystemTime, UNIX_EPOCH};

        // In production, use a proper CSPRNG
        // This is a placeholder implementation
        let seed = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();

        let mut key = Vec::with_capacity(32);
        for i in 0..32 {
            key.push(((seed >> (i % 16)) & 0xFF) as u8 ^ (i as u8 * 17));
        }
        key
    }

    /// Encrypt a media frame
    ///
    /// Returns: (encrypted_payload, sframe_header)
    pub fn encrypt_frame(&self, plaintext: &[u8]) -> Result<Vec<u8>, SFrameError> {
        let frame_num = self.frame_counter.fetch_add(1, Ordering::SeqCst);
        let key_id = self.key_id.load(Ordering::SeqCst);

        debug!(
            "Encrypting frame {} with key_id {} ({} bytes)",
            frame_num,
            key_id,
            plaintext.len()
        );

        // Build SFrame header
        // Format: [header_byte][key_id bytes][frame_counter bytes]
        let header = Self::build_header(key_id, frame_num);

        // Generate nonce from salt and frame counter
        let nonce = self.generate_nonce(frame_num);

        // In production, use AES-256-GCM encryption here
        // For now, XOR with key as placeholder
        let mut ciphertext = Vec::with_capacity(plaintext.len() + 16); // +16 for auth tag

        // Placeholder encryption (XOR)
        for (i, byte) in plaintext.iter().enumerate() {
            ciphertext.push(byte ^ self.encryption_key[i % self.encryption_key.len()]);
        }

        // Append placeholder auth tag
        ciphertext.extend_from_slice(&[0u8; 16]);

        // Combine header and ciphertext
        let mut output = header;
        output.extend(ciphertext);

        Ok(output)
    }

    /// Decrypt a media frame
    pub fn decrypt_frame(&self, ciphertext: &[u8]) -> Result<Vec<u8>, SFrameError> {
        if ciphertext.len() < 2 {
            return Err(SFrameError::InvalidFrame("Frame too short".to_string()));
        }

        // Parse SFrame header
        let (header_len, key_id, frame_num) = Self::parse_header(ciphertext)?;

        debug!(
            "Decrypting frame {} with key_id {} ({} bytes)",
            frame_num,
            key_id,
            ciphertext.len() - header_len
        );

        // Verify key_id matches
        if key_id != self.key_id.load(Ordering::SeqCst) {
            return Err(SFrameError::KeyMismatch {
                expected: self.key_id.load(Ordering::SeqCst),
                actual: key_id,
            });
        }

        // Generate nonce
        let nonce = self.generate_nonce(frame_num);

        // Extract ciphertext (excluding header and auth tag)
        let encrypted_data = &ciphertext[header_len..];
        if encrypted_data.len() < 16 {
            return Err(SFrameError::InvalidFrame(
                "Missing auth tag".to_string(),
            ));
        }

        let payload = &encrypted_data[..encrypted_data.len() - 16];
        let _auth_tag = &encrypted_data[encrypted_data.len() - 16..];

        // In production, verify auth tag and use AES-256-GCM decryption
        // Placeholder decryption (XOR)
        let mut plaintext = Vec::with_capacity(payload.len());
        for (i, byte) in payload.iter().enumerate() {
            plaintext.push(byte ^ self.encryption_key[i % self.encryption_key.len()]);
        }

        Ok(plaintext)
    }

    /// Rotate to a new encryption key
    pub fn rotate_key(&self, new_key: Vec<u8>, new_key_id: u32) -> Self {
        debug!("Rotating SFrame key to key_id: {}", new_key_id);

        Self::new(new_key, new_key_id)
    }

    /// Get the current key ID
    pub fn key_id(&self) -> u32 {
        self.key_id.load(Ordering::SeqCst)
    }

    /// Get the encryption key (for key exchange)
    pub fn encryption_key(&self) -> &[u8] {
        &self.encryption_key
    }

    // Private helper methods

    fn build_header(key_id: u32, frame_counter: u32) -> Vec<u8> {
        // SFrame header format:
        // - 1 byte: config (key_id length in upper 4 bits, counter length in lower 4 bits)
        // - N bytes: key_id (variable length, 1-8 bytes)
        // - M bytes: frame_counter (variable length, 1-8 bytes)

        let key_id_len = Self::varint_length(key_id);
        let counter_len = Self::varint_length(frame_counter);

        let config_byte = (((key_id_len - 1) << 4) | (counter_len - 1)) as u8;

        let mut header: Vec<u8> = Vec::with_capacity(1 + key_id_len + counter_len);
        header.push(config_byte);
        header.extend(Self::encode_varint(key_id, key_id_len));
        header.extend(Self::encode_varint(frame_counter, counter_len));

        header
    }

    fn parse_header(data: &[u8]) -> Result<(usize, u32, u32), SFrameError> {
        if data.is_empty() {
            return Err(SFrameError::InvalidFrame("Empty frame".to_string()));
        }

        let config = data[0];
        let key_id_len = ((config >> 4) & 0x07) as usize + 1;
        let counter_len = (config & 0x07) as usize + 1;

        let header_len = 1 + key_id_len + counter_len;
        if data.len() < header_len {
            return Err(SFrameError::InvalidFrame(
                "Header extends past frame".to_string(),
            ));
        }

        let key_id = Self::decode_varint(&data[1..1 + key_id_len]);
        let frame_counter =
            Self::decode_varint(&data[1 + key_id_len..1 + key_id_len + counter_len]);

        Ok((header_len, key_id, frame_counter))
    }

    fn varint_length(value: u32) -> usize {
        if value == 0 {
            1
        } else {
            ((32 - value.leading_zeros() + 7) / 8) as usize
        }
    }

    fn encode_varint(value: u32, len: usize) -> Vec<u8> {
        let mut bytes = Vec::with_capacity(len);
        for i in (0..len).rev() {
            bytes.push(((value >> (i * 8)) & 0xFF) as u8);
        }
        bytes
    }

    fn decode_varint(data: &[u8]) -> u32 {
        let mut value = 0u32;
        for &byte in data {
            value = (value << 8) | (byte as u32);
        }
        value
    }

    fn generate_nonce(&self, frame_counter: u32) -> [u8; 12] {
        let mut nonce = [0u8; 12];

        // Copy salt
        for (i, byte) in self.salt.iter().enumerate().take(12) {
            nonce[i] = *byte;
        }

        // XOR with frame counter in last 4 bytes
        let counter_bytes = frame_counter.to_be_bytes();
        for (i, byte) in counter_bytes.iter().enumerate() {
            nonce[8 + i] ^= *byte;
        }

        nonce
    }
}

/// SFrame errors
#[derive(Debug, thiserror::Error)]
pub enum SFrameError {
    #[error("Invalid frame: {0}")]
    InvalidFrame(String),

    #[error("Encryption failed: {0}")]
    EncryptionFailed(String),

    #[error("Decryption failed: {0}")]
    DecryptionFailed(String),

    #[error("Key mismatch: expected {expected}, got {actual}")]
    KeyMismatch { expected: u32, actual: u32 },

    #[error("Authentication failed")]
    AuthenticationFailed,
}

impl serde::Serialize for SFrameError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(&self.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_decrypt_roundtrip() {
        let key = SFrameEncryptor::generate_key();
        let encryptor = SFrameEncryptor::new(key.clone(), 1);

        let plaintext = b"Hello, secure media!";
        let encrypted = encryptor.encrypt_frame(plaintext).unwrap();

        // Create new encryptor with same key for decryption
        let decryptor = SFrameEncryptor::new(key, 1);
        let decrypted = decryptor.decrypt_frame(&encrypted).unwrap();

        assert_eq!(plaintext.to_vec(), decrypted);
    }

    #[test]
    fn test_header_parsing() {
        let header = SFrameEncryptor::build_header(42, 1000);

        let (header_len, key_id, frame_counter) =
            SFrameEncryptor::parse_header(&header).unwrap();

        assert_eq!(key_id, 42);
        assert_eq!(frame_counter, 1000);
        assert_eq!(header_len, header.len());
    }

    #[test]
    fn test_key_rotation() {
        let key1 = SFrameEncryptor::generate_key();
        let encryptor1 = SFrameEncryptor::new(key1, 1);

        assert_eq!(encryptor1.key_id(), 1);

        let key2 = SFrameEncryptor::generate_key();
        let encryptor2 = encryptor1.rotate_key(key2, 2);

        assert_eq!(encryptor2.key_id(), 2);
    }

    #[test]
    fn test_varint_encoding() {
        assert_eq!(SFrameEncryptor::varint_length(0), 1);
        assert_eq!(SFrameEncryptor::varint_length(255), 1);
        assert_eq!(SFrameEncryptor::varint_length(256), 2);
        assert_eq!(SFrameEncryptor::varint_length(65535), 2);
        assert_eq!(SFrameEncryptor::varint_length(65536), 3);
    }
}
