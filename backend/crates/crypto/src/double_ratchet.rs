/// Double Ratchet algorithm for forward-secret E2EE messaging
///
/// Based on Signal Protocol specification
use crate::{CryptoError, Result};
use aes_gcm::{
    aead::{Aead, KeyInit},
    Aes256Gcm, Nonce,
};
use hkdf::Hkdf;
use rand::rngs::OsRng;
use rand::RngCore;
use sha2::Sha256;
use std::collections::HashMap;
use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret};

// Constants for key derivation
const CHAIN_KEY_INFO: &[u8] = b"guardyn-chain-key";
const MESSAGE_KEY_INFO: &[u8] = b"guardyn-message-key";
const ROOT_KEY_INFO: &[u8] = b"guardyn-root-key";
const MAX_SKIP: usize = 1000; // Maximum number of skipped messages to store

/// Wire format version for [`EncryptedMessage`].
///
/// Version 1 binds the header into the AEAD associated data. The previous, unversioned
/// format did not, and began with the high byte of a big-endian `u32` header length -
/// always `0x00` for the 40-byte header. A leading `0x01` is therefore unambiguous
/// against every message the old format could produce, so a peer that has not upgraded
/// fails with a clear version error instead of an opaque authentication failure.
const WIRE_VERSION: u8 = 1;

/// Chain key for symmetric ratchet
#[derive(Clone)]
struct ChainKey {
    key: [u8; 32],
}

impl ChainKey {
    /// Create new chain key from bytes
    fn new(key: [u8; 32]) -> Self {
        Self { key }
    }

    /// Derive next chain key using HKDF
    fn next(&self) -> Result<Self> {
        let hkdf = Hkdf::<Sha256>::new(None, &self.key);
        let mut next_key = [0u8; 32];
        hkdf.expand(CHAIN_KEY_INFO, &mut next_key).map_err(|e| {
            CryptoError::KeyGeneration(format!("Chain key derivation failed: {}", e))
        })?;
        Ok(Self::new(next_key))
    }

    /// Derive message key from current chain key
    fn message_key(&self) -> Result<MessageKey> {
        let hkdf = Hkdf::<Sha256>::new(None, &self.key);
        let mut msg_key = [0u8; 32];
        hkdf.expand(MESSAGE_KEY_INFO, &mut msg_key).map_err(|e| {
            CryptoError::KeyGeneration(format!("Message key derivation failed: {}", e))
        })?;
        Ok(MessageKey::new(msg_key))
    }
}

/// Message key for encrypting/decrypting individual messages
#[derive(Clone)]
struct MessageKey {
    key: [u8; 32],
}

impl MessageKey {
    fn new(key: [u8; 32]) -> Self {
        Self { key }
    }

    /// Encrypt plaintext with AES-256-GCM
    fn encrypt(&self, plaintext: &[u8], associated_data: &[u8]) -> Result<Vec<u8>> {
        let cipher = Aes256Gcm::new((&self.key).into());

        // Generate cryptographically secure random nonce (12 bytes)
        let mut nonce_bytes = [0u8; 12];
        OsRng.fill_bytes(&mut nonce_bytes);
        let nonce: Nonce<_> = nonce_bytes.into();

        let mut ciphertext = cipher
            .encrypt(
                &nonce,
                aes_gcm::aead::Payload {
                    msg: plaintext,
                    aad: associated_data,
                },
            )
            .map_err(|e| CryptoError::Encryption(format!("AES-GCM encryption failed: {}", e)))?;

        // Prepend nonce to ciphertext
        let mut result = nonce.to_vec();
        result.append(&mut ciphertext);
        Ok(result)
    }

    /// Decrypt ciphertext with AES-256-GCM
    fn decrypt(&self, ciphertext: &[u8], associated_data: &[u8]) -> Result<Vec<u8>> {
        if ciphertext.len() < 12 {
            return Err(CryptoError::Decryption("Ciphertext too short".to_string()));
        }

        let (nonce_bytes, actual_ciphertext) = ciphertext.split_at(12);
        let nonce_arr: [u8; 12] = nonce_bytes
            .try_into()
            .map_err(|_| CryptoError::Decryption("Invalid nonce length".to_string()))?;
        let nonce: Nonce<_> = nonce_arr.into();
        let cipher = Aes256Gcm::new((&self.key).into());

        cipher
            .decrypt(
                &nonce,
                aes_gcm::aead::Payload {
                    msg: actual_ciphertext,
                    aad: associated_data,
                },
            )
            .map_err(|e| CryptoError::Decryption(format!("AES-GCM decryption failed: {}", e)))
    }
}

/// Root key for DH ratchet
#[derive(Clone)]
struct RootKey {
    key: [u8; 32],
}

impl RootKey {
    fn new(key: [u8; 32]) -> Self {
        Self { key }
    }

    /// Perform DH ratchet step: derive new root key and chain key
    fn dh_ratchet(&self, dh_output: &[u8]) -> Result<(Self, ChainKey)> {
        let hkdf = Hkdf::<Sha256>::new(Some(&self.key), dh_output);

        let mut new_root_key = [0u8; 32];
        let mut new_chain_key = [0u8; 32];
        let mut output = [0u8; 64];

        hkdf.expand(ROOT_KEY_INFO, &mut output).map_err(|e| {
            CryptoError::KeyGeneration(format!("Root key derivation failed: {}", e))
        })?;

        new_root_key.copy_from_slice(&output[..32]);
        new_chain_key.copy_from_slice(&output[32..]);

        Ok((RootKey::new(new_root_key), ChainKey::new(new_chain_key)))
    }
}

/// Message header containing DH public key and message counter
#[derive(Clone)]
pub struct MessageHeader {
    pub dh_public_key: X25519PublicKey,
    pub previous_chain_length: u32,
    pub message_number: u32,
}

impl MessageHeader {
    fn to_bytes(&self) -> Vec<u8> {
        let mut bytes = Vec::new();
        bytes.extend_from_slice(self.dh_public_key.as_bytes());
        // Use Big-Endian (Network Byte Order) per RFC 1700
        bytes.extend_from_slice(&self.previous_chain_length.to_be_bytes());
        bytes.extend_from_slice(&self.message_number.to_be_bytes());
        bytes
    }

    fn from_bytes(bytes: &[u8]) -> Result<Self> {
        if bytes.len() < 40 {
            return Err(CryptoError::Protocol("Invalid header length".to_string()));
        }

        let mut dh_key_bytes = [0u8; 32];
        dh_key_bytes.copy_from_slice(&bytes[..32]);
        let dh_public_key = X25519PublicKey::from(dh_key_bytes);

        let mut prev_chain_bytes = [0u8; 4];
        prev_chain_bytes.copy_from_slice(&bytes[32..36]);
        // Use Big-Endian (Network Byte Order) per RFC 1700
        let previous_chain_length = u32::from_be_bytes(prev_chain_bytes);

        let mut msg_num_bytes = [0u8; 4];
        msg_num_bytes.copy_from_slice(&bytes[36..40]);
        let message_number = u32::from_be_bytes(msg_num_bytes);

        Ok(Self {
            dh_public_key,
            previous_chain_length,
            message_number,
        })
    }
}

/// Associated data for the AEAD: the caller's context, then the wire header.
///
/// The Signal Double Ratchet binds the header into the associated data
/// (`AD = AD_initial || header`) precisely so that an attacker who can modify a message in
/// flight cannot rewrite `dh_public_key`, `previous_chain_length` or `message_number`
/// without invalidating the tag. Those 40 bytes were previously unauthenticated, and
/// `message_number` in particular drives `skip_message_keys`.
fn aad_with_header(associated_data: &[u8], header: &MessageHeader) -> Vec<u8> {
    let header_bytes = header.to_bytes();
    let mut aad = Vec::with_capacity(associated_data.len() + header_bytes.len());
    aad.extend_from_slice(associated_data);
    aad.extend_from_slice(&header_bytes);
    aad
}

/// Encrypted message with header
pub struct EncryptedMessage {
    pub header: MessageHeader,
    pub ciphertext: Vec<u8>,
}

impl EncryptedMessage {
    pub fn to_bytes(&self) -> Vec<u8> {
        let header_bytes = self.header.to_bytes();
        let mut result = Vec::with_capacity(5 + header_bytes.len() + self.ciphertext.len());
        result.push(WIRE_VERSION);
        // Use Big-Endian (Network Byte Order) per RFC 1700
        result.extend_from_slice(&(header_bytes.len() as u32).to_be_bytes());
        result.extend_from_slice(&header_bytes);
        result.extend_from_slice(&self.ciphertext);
        result
    }

    pub fn from_bytes(bytes: &[u8]) -> Result<Self> {
        if bytes.len() < 5 {
            return Err(CryptoError::Protocol("Message too short".to_string()));
        }

        if bytes[0] != WIRE_VERSION {
            return Err(CryptoError::Protocol(format!(
                "Unsupported ratchet message version {} (expected {})",
                bytes[0], WIRE_VERSION
            )));
        }

        let mut header_len_bytes = [0u8; 4];
        header_len_bytes.copy_from_slice(&bytes[1..5]);
        // Use Big-Endian (Network Byte Order) per RFC 1700
        let header_len = u32::from_be_bytes(header_len_bytes) as usize;

        let body_start = 5usize
            .checked_add(header_len)
            .ok_or_else(|| CryptoError::Protocol("Invalid message format".to_string()))?;
        if bytes.len() < body_start {
            return Err(CryptoError::Protocol("Invalid message format".to_string()));
        }

        let header = MessageHeader::from_bytes(&bytes[5..body_start])?;
        let ciphertext = bytes[body_start..].to_vec();

        Ok(Self { header, ciphertext })
    }
}

/// Double Ratchet state
pub struct DoubleRatchet {
    // DH ratchet state
    dh_self: StaticSecret,
    dh_remote: Option<X25519PublicKey>,

    // Root key
    root_key: RootKey,

    // Sending chain
    sending_chain_key: Option<ChainKey>,
    sending_message_number: u32,

    // Receiving chain
    receiving_chain_key: Option<ChainKey>,
    receiving_message_number: u32,

    // Previous sending chain length
    previous_chain_length: u32,

    // Skipped message keys for out-of-order handling
    skipped_message_keys: HashMap<(X25519PublicKey, u32), MessageKey>,
}

impl DoubleRatchet {
    /// Initialize Double Ratchet as sender (Alice)
    pub fn init_alice(shared_secret: &[u8], bob_public_key: X25519PublicKey) -> Result<Self> {
        let dh_self = StaticSecret::random_from_rng(OsRng);
        let dh_output = dh_self.diffie_hellman(&bob_public_key);

        // Derive initial root key from X3DH shared secret
        let mut root_key_bytes = [0u8; 32];
        if shared_secret.len() != 32 {
            return Err(CryptoError::InvalidKey(
                "Shared secret must be 32 bytes".to_string(),
            ));
        }
        root_key_bytes.copy_from_slice(shared_secret);
        let root_key = RootKey::new(root_key_bytes);

        // Perform initial DH ratchet
        let (new_root_key, sending_chain_key) = root_key.dh_ratchet(dh_output.as_bytes())?;

        Ok(Self {
            dh_self,
            dh_remote: Some(bob_public_key),
            root_key: new_root_key,
            sending_chain_key: Some(sending_chain_key),
            sending_message_number: 0,
            receiving_chain_key: None,
            receiving_message_number: 0,
            previous_chain_length: 0,
            skipped_message_keys: HashMap::new(),
        })
    }

    /// Initialize Double Ratchet as receiver (Bob)
    ///
    /// `dh_key_pair` must be the X25519 secret whose public half the initiator ran X3DH
    /// against - in practice Bob's signed pre-key. The Double Ratchet specification makes
    /// Bob's signed pre-key his initial ratchet key; generating a fresh key here instead
    /// would leave both sides with different DH outputs, so no message would ever decrypt.
    pub fn init_bob(shared_secret: &[u8], dh_key_pair: StaticSecret) -> Result<Self> {
        let dh_self = dh_key_pair;

        let mut root_key_bytes = [0u8; 32];
        if shared_secret.len() != 32 {
            return Err(CryptoError::InvalidKey(
                "Shared secret must be 32 bytes".to_string(),
            ));
        }
        root_key_bytes.copy_from_slice(shared_secret);
        let root_key = RootKey::new(root_key_bytes);

        Ok(Self {
            dh_self,
            dh_remote: None,
            root_key,
            sending_chain_key: None,
            sending_message_number: 0,
            receiving_chain_key: None,
            receiving_message_number: 0,
            previous_chain_length: 0,
            skipped_message_keys: HashMap::new(),
        })
    }

    /// Get current DH public key
    pub fn public_key(&self) -> X25519PublicKey {
        X25519PublicKey::from(&self.dh_self)
    }

    /// Encrypt a message
    pub fn encrypt(
        &mut self,
        plaintext: &[u8],
        associated_data: &[u8],
    ) -> Result<EncryptedMessage> {
        let chain_key = self
            .sending_chain_key
            .as_ref()
            .ok_or_else(|| CryptoError::Protocol("No sending chain key".to_string()))?
            .clone();

        // The header is built before encryption now, because it is part of the associated
        // data the tag covers.
        let header = MessageHeader {
            dh_public_key: self.public_key(),
            previous_chain_length: self.previous_chain_length,
            message_number: self.sending_message_number,
        };

        let message_key = chain_key.message_key()?;
        let ciphertext =
            message_key.encrypt(plaintext, &aad_with_header(associated_data, &header))?;

        // Advance sending chain
        self.sending_chain_key = Some(chain_key.next()?);
        self.sending_message_number += 1;

        Ok(EncryptedMessage { header, ciphertext })
    }

    /// Decrypt a message
    pub fn decrypt(
        &mut self,
        message: &EncryptedMessage,
        associated_data: &[u8],
    ) -> Result<Vec<u8>> {
        let aad = aad_with_header(associated_data, &message.header);

        // Check if we have a skipped message key
        let key = (message.header.dh_public_key, message.header.message_number);
        if let Some(message_key) = self.skipped_message_keys.get(&key) {
            // Decrypt first: a failure must not consume the stored key, or one forged
            // message would destroy the ability to read the genuine one it names.
            let plaintext = message_key.decrypt(&message.ciphertext, &aad)?;
            self.skipped_message_keys.remove(&key);
            return Ok(plaintext);
        }

        // Everything below is staged. `self` is not touched until the tag verifies, so an
        // authentication failure - or a forged header that trips MAX_SKIP - leaves the
        // session exactly as it was.
        let mut staged = ReceiveStaging::from_ratchet(self);
        let mut newly_skipped = Vec::new();

        // Check if we need to perform DH ratchet
        match staged.dh_remote {
            Some(remote_key)
                if message.header.dh_public_key.as_bytes() == remote_key.as_bytes() => {}
            // Either the remote rotated its key, or this is the first message from it.
            _ => staged.dh_ratchet_receive(&message.header)?,
        }

        // Skip messages if needed
        staged.skip_message_keys(
            message.header.message_number,
            self.skipped_message_keys.len(),
            &mut newly_skipped,
        )?;

        // Decrypt the message
        let chain_key = staged
            .receiving_chain_key
            .as_ref()
            .ok_or_else(|| CryptoError::Protocol("No receiving chain key".to_string()))?
            .clone();

        let message_key = chain_key.message_key()?;

        // The gate. Nothing above this line has been committed.
        let plaintext = message_key.decrypt(&message.ciphertext, &aad)?;

        // Advance receiving chain, then commit.
        staged.receiving_chain_key = Some(chain_key.next()?);
        staged.receiving_message_number += 1;
        staged.commit_into(self);
        self.skipped_message_keys.extend(newly_skipped);

        Ok(plaintext)
    }

    /// Get number of skipped messages in cache
    pub fn skipped_messages_count(&self) -> usize {
        self.skipped_message_keys.len()
    }

    /// Whether this ratchet can send.
    ///
    /// A responder built by [`Self::init_bob`] deliberately has no sending chain key: it gains
    /// one only when its first `decrypt` performs the DH ratchet against the initiator's
    /// public key. So a ratchet can be well-formed, restorable, and still unable to send a
    /// single message.
    ///
    /// A client needs this on two paths. It must not persist a responder before its first
    /// successful decrypt, and it must discard a restored session that reports `false` here and
    /// run a fresh key agreement instead - because the alternative is a session the UI shows as
    /// active that refuses every send.
    pub fn can_send(&self) -> bool {
        self.sending_chain_key.is_some()
    }

    /// Serialize Double Ratchet state for persistent storage
    ///
    /// Format (all little-endian):
    /// - dh_self (32 bytes)
    /// - dh_remote_present (1 byte: 0 or 1)
    /// - dh_remote (32 bytes, if present)
    /// - root_key (32 bytes)
    /// - sending_chain_key_present (1 byte)
    /// - sending_chain_key (32 bytes, if present)
    /// - sending_message_number (4 bytes)
    /// - receiving_chain_key_present (1 byte)
    /// - receiving_chain_key (32 bytes, if present)
    /// - receiving_message_number (4 bytes)
    /// - previous_chain_length (4 bytes)
    /// - skipped_keys_count (4 bytes)
    /// - skipped_keys [(dh_key, msg_num, key) repeated]
    pub fn serialize(&self) -> Vec<u8> {
        let mut bytes = Vec::new();

        // Serialize DH self (secret key)
        bytes.extend_from_slice(&self.dh_self.to_bytes());

        // Serialize DH remote (optional public key)
        if let Some(remote) = self.dh_remote {
            bytes.push(1); // present
            bytes.extend_from_slice(remote.as_bytes());
        } else {
            bytes.push(0); // not present
            bytes.extend_from_slice(&[0u8; 32]); // padding
        }

        // Serialize root key
        bytes.extend_from_slice(&self.root_key.key);

        // Serialize sending chain
        if let Some(ref chain_key) = self.sending_chain_key {
            bytes.push(1);
            bytes.extend_from_slice(&chain_key.key);
        } else {
            bytes.push(0);
            bytes.extend_from_slice(&[0u8; 32]);
        }
        bytes.extend_from_slice(&self.sending_message_number.to_le_bytes());

        // Serialize receiving chain
        if let Some(ref chain_key) = self.receiving_chain_key {
            bytes.push(1);
            bytes.extend_from_slice(&chain_key.key);
        } else {
            bytes.push(0);
            bytes.extend_from_slice(&[0u8; 32]);
        }
        bytes.extend_from_slice(&self.receiving_message_number.to_le_bytes());

        // Serialize previous chain length
        bytes.extend_from_slice(&self.previous_chain_length.to_le_bytes());

        // Serialize skipped message keys
        let skipped_count = self.skipped_message_keys.len() as u32;
        bytes.extend_from_slice(&skipped_count.to_le_bytes());

        for ((dh_key, msg_num), message_key) in &self.skipped_message_keys {
            bytes.extend_from_slice(dh_key.as_bytes()); // 32 bytes
            bytes.extend_from_slice(&msg_num.to_le_bytes()); // 4 bytes
            bytes.extend_from_slice(&message_key.key); // 32 bytes
        }

        bytes
    }

    /// Deserialize Double Ratchet state from bytes
    pub fn deserialize(bytes: &[u8]) -> Result<Self> {
        let min_size = 32 + 1 + 32 + 32 + 1 + 32 + 4 + 1 + 32 + 4 + 4 + 4;
        if bytes.len() < min_size {
            return Err(CryptoError::Protocol(format!(
                "Serialized data too short: {} bytes (need at least {})",
                bytes.len(),
                min_size
            )));
        }

        let mut offset = 0;

        // Deserialize DH self
        let mut dh_self_bytes = [0u8; 32];
        dh_self_bytes.copy_from_slice(&bytes[offset..offset + 32]);
        let dh_self = StaticSecret::from(dh_self_bytes);
        offset += 32;

        // Deserialize DH remote
        let dh_remote_present = bytes[offset] != 0;
        offset += 1;
        let mut dh_remote_bytes = [0u8; 32];
        dh_remote_bytes.copy_from_slice(&bytes[offset..offset + 32]);
        let dh_remote = if dh_remote_present {
            Some(X25519PublicKey::from(dh_remote_bytes))
        } else {
            None
        };
        offset += 32;

        // Deserialize root key
        let mut root_key_bytes = [0u8; 32];
        root_key_bytes.copy_from_slice(&bytes[offset..offset + 32]);
        let root_key = RootKey::new(root_key_bytes);
        offset += 32;

        // Deserialize sending chain
        let sending_present = bytes[offset] != 0;
        offset += 1;
        let mut sending_key_bytes = [0u8; 32];
        sending_key_bytes.copy_from_slice(&bytes[offset..offset + 32]);
        let sending_chain_key = if sending_present {
            Some(ChainKey::new(sending_key_bytes))
        } else {
            None
        };
        offset += 32;

        let mut sending_num_bytes = [0u8; 4];
        sending_num_bytes.copy_from_slice(&bytes[offset..offset + 4]);
        let sending_message_number = u32::from_le_bytes(sending_num_bytes);
        offset += 4;

        // Deserialize receiving chain
        let receiving_present = bytes[offset] != 0;
        offset += 1;
        let mut receiving_key_bytes = [0u8; 32];
        receiving_key_bytes.copy_from_slice(&bytes[offset..offset + 32]);
        let receiving_chain_key = if receiving_present {
            Some(ChainKey::new(receiving_key_bytes))
        } else {
            None
        };
        offset += 32;

        let mut receiving_num_bytes = [0u8; 4];
        receiving_num_bytes.copy_from_slice(&bytes[offset..offset + 4]);
        let receiving_message_number = u32::from_le_bytes(receiving_num_bytes);
        offset += 4;

        // Deserialize previous chain length
        let mut prev_chain_bytes = [0u8; 4];
        prev_chain_bytes.copy_from_slice(&bytes[offset..offset + 4]);
        let previous_chain_length = u32::from_le_bytes(prev_chain_bytes);
        offset += 4;

        // Deserialize skipped message keys
        let mut skipped_count_bytes = [0u8; 4];
        skipped_count_bytes.copy_from_slice(&bytes[offset..offset + 4]);
        let skipped_count = u32::from_le_bytes(skipped_count_bytes);
        offset += 4;

        let mut skipped_message_keys = HashMap::new();
        for _ in 0..skipped_count {
            if offset + 68 > bytes.len() {
                return Err(CryptoError::Protocol(
                    "Truncated skipped keys data".to_string(),
                ));
            }

            let mut dh_key_bytes = [0u8; 32];
            dh_key_bytes.copy_from_slice(&bytes[offset..offset + 32]);
            let dh_key = X25519PublicKey::from(dh_key_bytes);
            offset += 32;

            let mut msg_num_bytes = [0u8; 4];
            msg_num_bytes.copy_from_slice(&bytes[offset..offset + 4]);
            let msg_num = u32::from_le_bytes(msg_num_bytes);
            offset += 4;

            let mut msg_key_bytes = [0u8; 32];
            msg_key_bytes.copy_from_slice(&bytes[offset..offset + 32]);
            let msg_key = MessageKey::new(msg_key_bytes);
            offset += 32;

            skipped_message_keys.insert((dh_key, msg_num), msg_key);
        }

        Ok(Self {
            dh_self,
            dh_remote,
            root_key,
            sending_chain_key,
            sending_message_number,
            receiving_chain_key,
            receiving_message_number,
            previous_chain_length,
            skipped_message_keys,
        })
    }
}

/// The receive-side state a single `decrypt` may advance.
///
/// `decrypt` used to mutate `DoubleRatchet` in place **before** the AEAD tag was verified:
/// `dh_ratchet_receive` rotated `dh_self`, `root_key` and both chain keys, and
/// `skip_message_keys` walked the receiving chain forward, inserting a key per skipped index.
/// None of it was rolled back when decryption then failed, so one forged message could advance
/// the chain past every genuine one and leave the session unrecoverable without a new handshake.
///
/// Staging the transition here and swapping it in only on success makes the operation atomic.
/// Cloning `DoubleRatchet` wholesale would have been simpler, but it carries
/// `skipped_message_keys` - up to `MAX_SKIP` (1000) entries - and allocating that on every
/// message to guard against a rare failure is the wrong trade. Every field below is fixed-size.
#[derive(Clone)]
struct ReceiveStaging {
    dh_self: StaticSecret,
    dh_remote: Option<X25519PublicKey>,
    root_key: RootKey,
    sending_chain_key: Option<ChainKey>,
    sending_message_number: u32,
    receiving_chain_key: Option<ChainKey>,
    receiving_message_number: u32,
    previous_chain_length: u32,
}

impl ReceiveStaging {
    fn from_ratchet(r: &DoubleRatchet) -> Self {
        Self {
            dh_self: r.dh_self.clone(),
            dh_remote: r.dh_remote,
            root_key: r.root_key.clone(),
            sending_chain_key: r.sending_chain_key.clone(),
            sending_message_number: r.sending_message_number,
            receiving_chain_key: r.receiving_chain_key.clone(),
            receiving_message_number: r.receiving_message_number,
            previous_chain_length: r.previous_chain_length,
        }
    }

    fn commit_into(self, r: &mut DoubleRatchet) {
        r.dh_self = self.dh_self;
        r.dh_remote = self.dh_remote;
        r.root_key = self.root_key;
        r.sending_chain_key = self.sending_chain_key;
        r.sending_message_number = self.sending_message_number;
        r.receiving_chain_key = self.receiving_chain_key;
        r.receiving_message_number = self.receiving_message_number;
        r.previous_chain_length = self.previous_chain_length;
    }

    /// Perform DH ratchet when receiving a new public key.
    fn dh_ratchet_receive(&mut self, header: &MessageHeader) -> Result<()> {
        // Store previous chain length
        self.previous_chain_length = self.sending_message_number;
        self.sending_message_number = 0;
        self.receiving_message_number = 0;

        // Update remote DH key
        self.dh_remote = Some(header.dh_public_key);

        // Perform DH and derive new receiving chain
        let dh_output = self.dh_self.diffie_hellman(&header.dh_public_key);
        let (new_root_key, receiving_chain_key) = self.root_key.dh_ratchet(dh_output.as_bytes())?;
        self.root_key = new_root_key;
        self.receiving_chain_key = Some(receiving_chain_key);

        // Generate new DH key pair and derive new sending chain
        self.dh_self = StaticSecret::random_from_rng(OsRng);
        let dh_output = self.dh_self.diffie_hellman(&header.dh_public_key);
        let (new_root_key, sending_chain_key) = self.root_key.dh_ratchet(dh_output.as_bytes())?;
        self.root_key = new_root_key;
        self.sending_chain_key = Some(sending_chain_key);

        Ok(())
    }

    /// Derive the message keys for indices skipped by an out-of-order message.
    ///
    /// Keys are collected into `out` rather than inserted, so the caller can discard them if
    /// the tag then fails. `already_stored` is the committed map's length, which the
    /// `MAX_SKIP` bound counts against - otherwise each forged message could stage up to the
    /// limit afresh and the bound would mean nothing.
    fn skip_message_keys(
        &mut self,
        until: u32,
        already_stored: usize,
        out: &mut Vec<((X25519PublicKey, u32), MessageKey)>,
    ) -> Result<()> {
        if let Some(chain_key) = &self.receiving_chain_key {
            let mut current_chain_key = chain_key.clone();

            while self.receiving_message_number < until {
                if already_stored + out.len() >= MAX_SKIP {
                    return Err(CryptoError::Protocol(format!(
                        "Too many skipped messages (max: {})",
                        MAX_SKIP
                    )));
                }

                let message_key = current_chain_key.message_key()?;
                let remote_key = self
                    .dh_remote
                    .ok_or_else(|| CryptoError::Protocol("No remote key".to_string()))?;

                out.push(((remote_key, self.receiving_message_number), message_key));

                current_chain_key = current_chain_key.next()?;
                self.receiving_message_number += 1;
            }

            self.receiving_chain_key = Some(current_chain_key);
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_chain_key_derivation() {
        let initial_key = [42u8; 32];
        let chain_key = ChainKey::new(initial_key);

        let next_key = chain_key.next().expect("Failed to derive next chain key");
        assert_ne!(chain_key.key, next_key.key);

        // Verify deterministic
        let next_key2 = chain_key.next().expect("Failed to derive next chain key");
        assert_eq!(next_key.key, next_key2.key);
    }

    #[test]
    fn test_message_key_encryption_decryption() {
        let key = [42u8; 32];
        let message_key = MessageKey::new(key);

        let plaintext = b"Hello, World!";
        let associated_data = b"metadata";

        let ciphertext = message_key
            .encrypt(plaintext, associated_data)
            .expect("Encryption failed");

        let decrypted = message_key
            .decrypt(&ciphertext, associated_data)
            .expect("Decryption failed");

        assert_eq!(plaintext, &decrypted[..]);
    }

    #[test]
    fn test_message_key_wrong_associated_data() {
        let key = [42u8; 32];
        let message_key = MessageKey::new(key);

        let plaintext = b"Hello, World!";
        let ciphertext = message_key
            .encrypt(plaintext, b"correct")
            .expect("Encryption failed");

        let result = message_key.decrypt(&ciphertext, b"wrong");
        assert!(result.is_err());
    }

    #[test]
    fn test_root_key_dh_ratchet() {
        let root_key = RootKey::new([42u8; 32]);
        let dh_output = [99u8; 32];

        let (new_root_key, chain_key) = root_key.dh_ratchet(&dh_output).expect("DH ratchet failed");

        assert_ne!(root_key.key, new_root_key.key);
        assert_ne!(root_key.key, chain_key.key);
    }

    #[test]
    fn test_message_header_serialization() {
        let dh_key = StaticSecret::random_from_rng(OsRng);
        let dh_public = X25519PublicKey::from(&dh_key);

        let header = MessageHeader {
            dh_public_key: dh_public,
            previous_chain_length: 42,
            message_number: 7,
        };

        let bytes = header.to_bytes();
        let decoded = MessageHeader::from_bytes(&bytes).expect("Deserialization failed");

        assert_eq!(
            header.dh_public_key.as_bytes(),
            decoded.dh_public_key.as_bytes()
        );
        assert_eq!(header.previous_chain_length, decoded.previous_chain_length);
        assert_eq!(header.message_number, decoded.message_number);
    }

    #[test]
    fn test_encrypted_message_serialization() {
        let dh_key = StaticSecret::random_from_rng(OsRng);
        let dh_public = X25519PublicKey::from(&dh_key);

        let message = EncryptedMessage {
            header: MessageHeader {
                dh_public_key: dh_public,
                previous_chain_length: 5,
                message_number: 10,
            },
            ciphertext: vec![1, 2, 3, 4, 5],
        };

        let bytes = message.to_bytes();
        let decoded = EncryptedMessage::from_bytes(&bytes).expect("Deserialization failed");

        assert_eq!(message.header.message_number, decoded.header.message_number);
        assert_eq!(message.ciphertext, decoded.ciphertext);
    }

    /// A message carrying the old, unversioned framing must be rejected by version, not by
    /// a tag failure. The point of the version byte is that an un-upgraded peer gets a
    /// diagnosable error instead of "decryption failed".
    #[test]
    fn old_wire_format_is_rejected_by_version() {
        let dh_key = StaticSecret::random_from_rng(OsRng);
        let header = MessageHeader {
            dh_public_key: X25519PublicKey::from(&dh_key),
            previous_chain_length: 0,
            message_number: 0,
        };

        // Exactly what the previous format produced: u32 BE header length, then the body.
        let header_bytes = header.to_bytes();
        let mut legacy = Vec::new();
        legacy.extend_from_slice(&(header_bytes.len() as u32).to_be_bytes());
        legacy.extend_from_slice(&header_bytes);
        legacy.extend_from_slice(&[9u8; 28]);

        // `expect_err` would require `Debug` on EncryptedMessage, and ZK-DEBUG forbids
        // deriving it on a type that holds ciphertext.
        match EncryptedMessage::from_bytes(&legacy) {
            Ok(_) => panic!("the unversioned format must not parse"),
            Err(e) => assert!(
                format!("{e}").contains("Unsupported ratchet message version"),
                "expected a version error, got: {e}"
            ),
        }
    }

    /// `previous_chain_length` is the one header field that does **not** feed key
    /// derivation - `dh_ratchet_receive` only stores it, and `skip_message_keys` keys off
    /// `message_number`. So the receiver derives the *same* message key whether or not it
    /// was tampered with, and the only thing that can reject it is the AEAD tag.
    ///
    /// That makes this the isolating test for #105. Tampering `dh_public_key` or
    /// `message_number` also fails without the fix, because both change which key is
    /// derived - asserting on those would pass vacuously and prove nothing.
    #[test]
    fn tampered_previous_chain_length_fails_to_decrypt() {
        let shared_secret = [7u8; 32];
        let bob_prekey = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_prekey);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).expect("init alice");
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_prekey).expect("init bob");

        let ad = b"alice|bob";
        let msg = alice.encrypt(b"hello", ad).expect("encrypt");

        let tampered = EncryptedMessage {
            header: MessageHeader {
                previous_chain_length: msg.header.previous_chain_length.wrapping_add(3),
                ..msg.header.clone()
            },
            ciphertext: msg.ciphertext.clone(),
        };

        assert!(
            bob.decrypt(&tampered, ad).is_err(),
            "a rewritten previous_chain_length must not authenticate"
        );
    }

    /// A forged message must leave the session able to read the next genuine one.
    ///
    /// This is the property #106 was filed for. `skip_message_keys` walked the receiving
    /// chain forward from an unauthenticated `message_number` *before* the tag was checked,
    /// and nothing rolled it back, so one forged header permanently desynchronised the
    /// session - the attacker did not need any key material to do it.
    #[test]
    fn forged_message_does_not_poison_the_session() {
        let shared_secret = [23u8; 32];
        let bob_prekey = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_prekey);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).expect("init alice");
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_prekey).expect("init bob");

        let ad = b"alice|bob";

        // A genuine message, rewritten to claim a counter far ahead.
        let genuine = alice.encrypt(b"first", ad).expect("encrypt");
        let forged = EncryptedMessage {
            header: MessageHeader {
                message_number: 500,
                ..genuine.header.clone()
            },
            ciphertext: genuine.ciphertext.clone(),
        };

        assert!(
            bob.decrypt(&forged, ad).is_err(),
            "the forged message must not decrypt"
        );
        assert_eq!(
            bob.skipped_messages_count(),
            0,
            "a rejected message must not leave skipped keys behind"
        );

        // The genuine message it was derived from must still arrive.
        let out = bob
            .decrypt(&genuine, ad)
            .expect("the session must still work");
        assert_eq!(out, b"first");

        // And the conversation continues.
        let second = alice.encrypt(b"second", ad).expect("encrypt");
        assert_eq!(bob.decrypt(&second, ad).expect("decrypt"), b"second");
    }

    /// A failed decrypt on the skipped-key path must not consume the stored key: otherwise
    /// one forged message destroys the ability to read the genuine message it names.
    #[test]
    fn failed_skipped_key_decrypt_keeps_the_key() {
        let shared_secret = [31u8; 32];
        let bob_prekey = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_prekey);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).expect("init alice");
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_prekey).expect("init bob");

        let ad = b"alice|bob";

        // Alice sends three; Bob receives the third first, so keys 0 and 1 are stored.
        let m0 = alice.encrypt(b"zero", ad).expect("encrypt");
        let _m1 = alice.encrypt(b"one", ad).expect("encrypt");
        let m2 = alice.encrypt(b"two", ad).expect("encrypt");

        bob.decrypt(&m2, ad).expect("out-of-order delivery");
        assert_eq!(bob.skipped_messages_count(), 2);

        // A corrupted copy of m0 targets a stored key and must fail without spending it.
        let mut broken_ct = m0.ciphertext.clone();
        let last = broken_ct.len() - 1;
        broken_ct[last] ^= 0xff;
        let corrupted = EncryptedMessage {
            header: m0.header.clone(),
            ciphertext: broken_ct,
        };

        assert!(
            bob.decrypt(&corrupted, ad).is_err(),
            "corrupted must not decrypt"
        );
        assert_eq!(
            bob.skipped_messages_count(),
            2,
            "a failed decrypt must not consume the skipped key"
        );

        // The genuine message still arrives.
        assert_eq!(bob.decrypt(&m0, ad).expect("decrypt"), b"zero");
        assert_eq!(bob.skipped_messages_count(), 1);
    }

    /// The honest path still round-trips with the header bound in.
    #[test]
    fn header_binding_preserves_round_trip() {
        let shared_secret = [11u8; 32];
        let bob_prekey = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_prekey);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).expect("init alice");
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_prekey).expect("init bob");

        let ad = b"alice|bob";
        let msg = alice
            .encrypt(b"the header is authenticated now", ad)
            .expect("encrypt");
        let out = bob.decrypt(&msg, ad).expect("decrypt");
        assert_eq!(out, b"the header is authenticated now");
    }

    #[test]
    fn test_double_ratchet_basic_exchange() {
        let shared_secret = [42u8; 32];

        // Bob generates his initial key
        let bob_dh = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_dh);

        // Alice initializes with Bob's public key
        let mut alice =
            DoubleRatchet::init_alice(&shared_secret, bob_public).expect("Alice init failed");

        // Bob initializes
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_dh).expect("Bob init failed");

        // Alice sends first message
        let plaintext1 = b"Hello from Alice!";
        let encrypted1 = alice
            .encrypt(plaintext1, b"msg1")
            .expect("Encryption failed");

        // Bob receives and decrypts
        let decrypted1 = bob
            .decrypt(&encrypted1, b"msg1")
            .expect("Decryption failed");
        assert_eq!(plaintext1, &decrypted1[..]);

        // Bob sends reply
        let plaintext2 = b"Hello from Bob!";
        let encrypted2 = bob.encrypt(plaintext2, b"msg2").expect("Encryption failed");

        // Alice receives
        let decrypted2 = alice
            .decrypt(&encrypted2, b"msg2")
            .expect("Decryption failed");
        assert_eq!(plaintext2, &decrypted2[..]);
    }

    #[test]
    fn test_double_ratchet_multiple_messages() {
        let shared_secret = [42u8; 32];
        let bob_dh = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_dh);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();

        // Send multiple messages in sequence
        for i in 0..5 {
            let msg = format!("Message {}", i);
            let encrypted = alice.encrypt(msg.as_bytes(), b"metadata").unwrap();
            let decrypted = bob.decrypt(&encrypted, b"metadata").unwrap();
            assert_eq!(msg.as_bytes(), &decrypted[..]);
        }
    }

    #[test]
    fn test_double_ratchet_out_of_order() {
        let shared_secret = [42u8; 32];
        let bob_dh = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_dh);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();

        // Alice sends 3 messages
        let msg1 = alice.encrypt(b"First", b"1").unwrap();
        let msg2 = alice.encrypt(b"Second", b"2").unwrap();
        let msg3 = alice.encrypt(b"Third", b"3").unwrap();

        // Bob receives out of order: 1, 3, 2
        let dec1 = bob.decrypt(&msg1, b"1").unwrap();
        assert_eq!(b"First", &dec1[..]);

        let dec3 = bob.decrypt(&msg3, b"3").unwrap();
        assert_eq!(b"Third", &dec3[..]);

        let dec2 = bob.decrypt(&msg2, b"2").unwrap();
        assert_eq!(b"Second", &dec2[..]);

        // Verify skipped message was cleaned up
        assert_eq!(bob.skipped_messages_count(), 0);
    }

    #[test]
    fn test_double_ratchet_key_rotation() {
        let shared_secret = [42u8; 32];
        let bob_dh = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_dh);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();

        // Send messages back and forth to trigger DH ratchet
        for i in 0..10 {
            let msg = format!("Alice message {}", i);
            let encrypted = alice.encrypt(msg.as_bytes(), b"ad").unwrap();
            let decrypted = bob.decrypt(&encrypted, b"ad").unwrap();
            assert_eq!(msg.as_bytes(), &decrypted[..]);

            let reply = format!("Bob reply {}", i);
            let encrypted_reply = bob.encrypt(reply.as_bytes(), b"ad").unwrap();
            let decrypted_reply = alice.decrypt(&encrypted_reply, b"ad").unwrap();
            assert_eq!(reply.as_bytes(), &decrypted_reply[..]);
        }
    }

    #[test]
    fn test_double_ratchet_serialization() {
        let shared_secret = [42u8; 32];
        let bob_dh = StaticSecret::random_from_rng(OsRng);
        let bob_public = X25519PublicKey::from(&bob_dh);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();
        let mut bob = DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();

        // Exchange some messages to build state
        let msg1 = alice.encrypt(b"Test message 1", b"ad1").unwrap();
        bob.decrypt(&msg1, b"ad1").unwrap();

        let msg2 = alice.encrypt(b"Test message 2", b"ad2").unwrap();
        let msg3 = alice.encrypt(b"Test message 3", b"ad3").unwrap();

        // Decrypt out of order to create skipped keys
        bob.decrypt(&msg3, b"ad3").unwrap();
        bob.decrypt(&msg2, b"ad2").unwrap();

        // Serialize Bob's state
        let serialized = bob.serialize();
        assert!(!serialized.is_empty());

        // Deserialize into new instance
        let mut bob_restored =
            DoubleRatchet::deserialize(&serialized).expect("Failed to deserialize ratchet");

        // Verify state by continuing conversation
        let msg4 = alice.encrypt(b"After restore", b"ad4").unwrap();
        let decrypted = bob_restored.decrypt(&msg4, b"ad4").unwrap();
        assert_eq!(b"After restore", &decrypted[..]);

        // Bob can also send
        let reply = bob_restored
            .encrypt(b"Reply after restore", b"ad5")
            .unwrap();
        let decrypted_reply = alice.decrypt(&reply, b"ad5").unwrap();
        assert_eq!(b"Reply after restore", &decrypted_reply[..]);
    }
}
