/// X3DH (Extended Triple Diffie-Hellman) key agreement protocol
///
/// Used for initial key exchange in 1-on-1 messaging
///
/// Key conversion: Ed25519 identity keys are converted to X25519 for DH operations
/// using the birational equivalence between twisted Edwards curve (Ed25519) and
/// Montgomery curve (Curve25519/X25519). This is the same approach used by Signal Protocol.
use std::fmt;

use crate::{CryptoError, Result};
use curve25519_dalek::scalar::clamp_integer;
use ed25519_dalek::{Signature, Signer, SigningKey, Verifier, VerifyingKey};
use guardyn_common::redact::Redacted;
use hkdf::Hkdf;
use rand::rngs::OsRng;
use serde::{Deserialize, Serialize};
use sha2::Sha256;
use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret};

/// Identity key pair (Ed25519 for signing)
#[derive(Clone)]
pub struct IdentityKeyPair {
    pub public: VerifyingKey,
    secret: SigningKey,
}

/// Redacts the Ed25519 private half. The public half is safe to print.
impl fmt::Debug for IdentityKeyPair {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("IdentityKeyPair")
            .field("public", &self.public)
            .field("secret", &Redacted::new(&self.secret))
            .finish()
    }
}

impl IdentityKeyPair {
    /// Generate a new identity key pair
    pub fn generate() -> Result<Self> {
        let secret = SigningKey::from_bytes(&rand::random::<[u8; 32]>());
        let public = secret.verifying_key();

        Ok(Self { public, secret })
    }

    /// Sign data with identity key
    pub fn sign(&self, data: &[u8]) -> Result<Vec<u8>> {
        let signature = self.secret.sign(data);
        Ok(signature.to_bytes().to_vec())
    }

    /// Verify signature
    pub fn verify(public_key: &[u8], data: &[u8], signature: &[u8]) -> Result<()> {
        let public =
            VerifyingKey::from_bytes(public_key.try_into().map_err(|_| {
                CryptoError::InvalidKey("Invalid Ed25519 public key length".into())
            })?)
            .map_err(|e| CryptoError::InvalidKey(format!("Invalid Ed25519 public key: {}", e)))?;

        let sig = Signature::from_bytes(
            signature
                .try_into()
                .map_err(|_| CryptoError::InvalidSignature("Invalid signature length".into()))?,
        );

        public.verify(data, &sig).map_err(|e| {
            CryptoError::InvalidSignature(format!("Signature verification failed: {}", e))
        })?;

        Ok(())
    }

    /// Export public key bytes (Ed25519 format for signatures)
    pub fn public_bytes(&self) -> Vec<u8> {
        self.public.to_bytes().to_vec()
    }

    /// Export private key bytes for secure storage
    ///
    /// Returns the 32-byte seed that can be used to reconstruct the key pair.
    pub fn private_key_bytes(&self) -> Vec<u8> {
        self.secret.to_bytes().to_vec()
    }

    /// Reconstruct identity key pair from private key bytes
    ///
    /// Accepts the 32-byte seed returned by `private_key_bytes()`.
    pub fn from_private_bytes(bytes: &[u8]) -> Result<Self> {
        let seed: [u8; 32] = bytes
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Private key must be 32 bytes".into()))?;

        let secret = SigningKey::from_bytes(&seed);
        let public = secret.verifying_key();

        Ok(Self { public, secret })
    }

    /// Convert Ed25519 public key to X25519 for Diffie-Hellman operations.
    ///
    /// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
    /// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
    pub fn to_x25519_public(&self) -> X25519PublicKey {
        let montgomery = self.public.to_montgomery();
        X25519PublicKey::from(montgomery.to_bytes())
    }

    /// Convert Ed25519 signing key to X25519 StaticSecret for Diffie-Hellman operations.
    ///
    /// The conversion process (matching TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk):
    /// 1. Compute SHA512(seed)[0:32] via to_scalar_bytes()
    /// 2. Apply X25519 clamping:
    ///    - Clear bottom 3 bits of byte 0 (divisible by 8)
    ///    - Clear top bit of byte 31 (< 2^255)
    ///    - Set second-to-top bit of byte 31 (>= 2^254)
    ///
    /// Note: We use clamp_integer() which applies ONLY clamping without mod l reduction.
    /// This matches TweetNaCl exactly, unlike to_scalar() which also reduces mod l.
    pub fn to_x25519_secret(&self) -> StaticSecret {
        signing_key_to_x25519_secret(&self.secret)
    }
}

/// Signed pre-key (X25519 for DH, signed with Ed25519)
#[derive(Clone)]
pub struct SignedPreKey {
    pub key_id: u32,
    pub public: X25519PublicKey,
    secret: StaticSecret,
    pub signature: Vec<u8>,
    pub timestamp: i64,
}

impl SignedPreKey {
    /// Generate a new signed pre-key
    pub fn generate(key_id: u32, identity_key: &IdentityKeyPair) -> Result<Self> {
        let secret = StaticSecret::random_from_rng(OsRng);
        let public = X25519PublicKey::from(&secret);

        // Sign the public key with identity key
        let signature = identity_key.sign(public.as_bytes())?;

        let timestamp = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;

        Ok(Self {
            key_id,
            public,
            secret,
            signature,
            timestamp,
        })
    }

    /// Export public key bytes
    pub fn public_bytes(&self) -> Vec<u8> {
        self.public.as_bytes().to_vec()
    }

    /// Perform Diffie-Hellman with another X25519 public key
    pub fn dh(&self, other_public: &X25519PublicKey) -> Vec<u8> {
        let shared = self.secret.diffie_hellman(other_public);
        shared.as_bytes().to_vec()
    }

    /// The X25519 secret backing this pre-key, for use as the initial Double Ratchet key.
    ///
    /// The responder's signed pre-key is his initial ratchet key: it is the public half the
    /// initiator ran X3DH against, so both sides must derive the first root key from it.
    /// This is the only reason to take the secret out of the struct - do not use it to
    /// re-implement `dh`, and never log or serialize the returned value.
    pub fn ratchet_secret(&self) -> StaticSecret {
        self.secret.clone()
    }

    /// Rebuild a signed pre-key from a secret held in client storage.
    ///
    /// A client that publishes a bundle must be able to answer an X3DH run against it later,
    /// which means restoring the exact key it published - not generating a new one under the
    /// same `key_id`. Regenerating produces a fresh random secret, so the responder derives a
    /// different shared secret and every message fails to decrypt with no signal about why.
    ///
    /// The signature is supplied rather than recomputed: it was made over this public key by
    /// the identity key at publication time, and the peer verifies against the copy the server
    /// serves. Re-signing here would work only while the identity key is unchanged and would
    /// hide the case where it is not.
    pub fn from_secret_bytes(
        key_id: u32,
        secret: [u8; 32],
        signature: Vec<u8>,
        timestamp: i64,
    ) -> Self {
        let secret = StaticSecret::from(secret);
        let public = X25519PublicKey::from(&secret);
        Self {
            key_id,
            public,
            secret,
            signature,
            timestamp,
        }
    }
}

/// One-time pre-key (X25519)
#[derive(Clone)]
pub struct OneTimePreKey {
    pub key_id: u32,
    pub public: X25519PublicKey,
    secret: StaticSecret,
}

impl OneTimePreKey {
    /// Generate a new one-time pre-key
    pub fn generate(key_id: u32) -> Self {
        let secret = StaticSecret::random_from_rng(OsRng);
        let public = X25519PublicKey::from(&secret);

        Self {
            key_id,
            public,
            secret,
        }
    }

    /// Export public key bytes
    pub fn public_bytes(&self) -> Vec<u8> {
        self.public.as_bytes().to_vec()
    }

    /// Perform Diffie-Hellman
    pub fn dh(&self, other_public: &X25519PublicKey) -> Vec<u8> {
        let shared = self.secret.diffie_hellman(other_public);
        shared.as_bytes().to_vec()
    }

    /// The X25519 secret backing this pre-key, for a client that must persist it.
    ///
    /// One-time pre-keys are published and then answered against much later - after an app
    /// restart, on a device that has forgotten everything not written down. Unlike `dh`, which
    /// serves a live key, this exists so the key can outlive the process that made it.
    ///
    /// Taking a secret out of its struct is the thing this module otherwise refuses to do, so:
    /// do not use it to re-implement `dh`, and never log or serialize the returned value in
    /// the clear. Its one legitimate destination is an OS keychain.
    pub fn secret(&self) -> StaticSecret {
        self.secret.clone()
    }

    /// Rebuild a one-time pre-key from a secret held in client storage.
    ///
    /// See [`SignedPreKey::from_secret_bytes`] for why restoring beats regenerating. The `key_id` is
    /// load-bearing in a way it is not elsewhere: `common.KeyBundle` carries no key ids, so an
    /// initiator reports the id as the index the key occupied in the published array, and DH4
    /// only matches if this key is the one that sat at that index.
    pub fn from_secret_bytes(key_id: u32, secret: [u8; 32]) -> Self {
        let secret = StaticSecret::from(secret);
        let public = X25519PublicKey::from(&secret);
        Self {
            key_id,
            public,
            secret,
        }
    }
}

/// Key bundle for publishing to server
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct X3DHKeyBundle {
    pub identity_key: Vec<u8>,   // Ed25519 public key
    pub signed_pre_key: Vec<u8>, // X25519 public key
    pub signed_pre_key_id: u32,
    pub signed_pre_key_signature: Vec<u8>,
    pub one_time_pre_keys: Vec<OneTimePreKeyPublic>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OneTimePreKeyPublic {
    pub key_id: u32,
    pub public_key: Vec<u8>,
}

/// Wire format version for [`X3DHPrekeyMessage`]. v1 is a hard break from the unversioned
/// v0 with no fallback path; `docs/spec/SRS.md` says why.
const PREKEY_MESSAGE_VERSION: u8 = 1;

/// `flags` bit 0: a big-endian `u32` one-time pre-key id follows.
const PREKEY_FLAG_ONE_TIME_KEY: u8 = 0x01;

/// `flags` bit 1: a length-prefixed ML-KEM ciphertext follows.
const PREKEY_FLAG_PQ_CIPHERTEXT: u8 = 0x02;

/// Every bit outside this mask is reserved and must be zero, so that a future field cannot
/// be silently ignored the way v0's `otk_flag != 1` was read as "no one-time key".
const PREKEY_FLAGS_KNOWN: u8 = PREKEY_FLAG_ONE_TIME_KEY | PREKEY_FLAG_PQ_CIPHERTEXT;

/// Smallest legal v1 frame: version, both keys, and the flags byte.
const PREKEY_MESSAGE_MIN_LEN: usize = 1 + 32 + 32 + 1;

/// X3DH prekey message sent with first message to establish session
///
/// This is included in the first encrypted message from Alice to Bob,
/// allowing Bob to complete the X3DH key agreement on his side.
#[derive(Clone, Serialize, Deserialize)]
pub struct X3DHPrekeyMessage {
    /// Sender's Ed25519 identity public key (32 bytes)
    pub sender_identity_key: Vec<u8>,
    /// Ephemeral X25519 public key generated for this exchange (32 bytes)
    pub ephemeral_key: Vec<u8>,
    /// ID of the one-time prekey used (if any)
    pub used_one_time_key_id: Option<u32>,
    /// ML-KEM ciphertext for the responder to decapsulate, when the handshake is hybrid.
    ///
    /// The second element of [`crate::pqxdh::derive_sender_shared_secret`]'s return value is
    /// `ephemeral_public(32) || ciphertext`; only the ciphertext belongs here, because the
    /// ephemeral public key is already in [`Self::ephemeral_key`] and two copies of one value
    /// are two things that can disagree.
    ///
    /// `None` is a classical X3DH handshake. Classical strength is the floor, so a peer
    /// bundle with no ML-KEM key still establishes a session.
    pub pq_ciphertext: Option<Vec<u8>>,
}

/// Redacts the ML-KEM ciphertext; the rest is public key material.
///
/// `AGENTS.md` §4 puts ciphertext on the never-emit list. The derive was correct while this
/// type held only public keys and an integer - `pq_ciphertext` is what makes it wrong, so it
/// is replaced in the same change that adds the field rather than left to a reviewer.
impl fmt::Debug for X3DHPrekeyMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("X3DHPrekeyMessage")
            .field("sender_identity_key", &self.sender_identity_key)
            .field("ephemeral_key", &self.ephemeral_key)
            .field("used_one_time_key_id", &self.used_one_time_key_id)
            .field(
                "pq_ciphertext",
                &self
                    .pq_ciphertext
                    .as_ref()
                    .map(|ct| format!("[REDACTED; {} bytes]", ct.len())),
            )
            .finish()
    }
}

impl X3DHPrekeyMessage {
    /// Create a new X3DH prekey message
    pub fn new(
        sender_identity_key: Vec<u8>,
        ephemeral_key: Vec<u8>,
        used_one_time_key_id: Option<u32>,
    ) -> Self {
        Self {
            sender_identity_key,
            ephemeral_key,
            used_one_time_key_id,
            pq_ciphertext: None,
        }
    }

    /// Attach the ML-KEM ciphertext from [`crate::pqxdh::derive_sender_shared_secret`],
    /// making this a hybrid handshake. That function returns
    /// `ephemeral_public(32) || ciphertext`, so pass `[32..]`.
    ///
    /// The ciphertext must be non-empty and at most [`u16::MAX`] bytes - far above
    /// ML-KEM-768's 1088 or ML-KEM-1024's 1568. See [`Self::to_bytes`] if it is not.
    pub fn with_pq_ciphertext(mut self, pq_ciphertext: Vec<u8>) -> Self {
        self.pq_ciphertext = Some(pq_ciphertext);
        self
    }

    /// Serialize to bytes (for transmission).
    ///
    /// Layout:
    ///
    /// ```text
    /// version(1)=0x01 || identity_key(32) || ephemeral_key(32) || flags(1)
    ///                 || [otk_id:u32 BE (4)]
    ///                 || [ct_len:u16 BE (2) || ct]
    /// ```
    ///
    /// 66 bytes minimum, 70 with a one-time key id, `+ 2 + ct_len` with an ML-KEM
    /// ciphertext; when both are present the id comes first. `flags` bit `0x01` marks the id,
    /// bit `0x02` the ciphertext, and every other bit is reserved.
    ///
    /// **Every multi-byte integer is big-endian**, as in every format crossing the Rust/Dart
    /// boundary. `docs/spec/SRS.md` carries the full contract - the length-prefix rationale,
    /// the byte-order rule, and why v1 is a hard break - and is the copy to keep correct.
    ///
    /// This method does not validate its fields, which has always been true: a
    /// `sender_identity_key` that is not 32 bytes shifts every later offset and yields a
    /// frame [`Self::from_bytes`] refuses. An over-long `pq_ciphertext` keeps that contract
    /// rather than breaking it - see the `ct_len` computation below.
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut flags = 0u8;
        if self.used_one_time_key_id.is_some() {
            flags |= PREKEY_FLAG_ONE_TIME_KEY;
        }
        if self.pq_ciphertext.is_some() {
            flags |= PREKEY_FLAG_PQ_CIPHERTEXT;
        }

        let capacity = PREKEY_MESSAGE_MIN_LEN
            + if self.used_one_time_key_id.is_some() {
                4
            } else {
                0
            }
            + self.pq_ciphertext.as_ref().map_or(0, |ct| 2 + ct.len());

        let mut bytes = Vec::with_capacity(capacity);
        bytes.push(PREKEY_MESSAGE_VERSION);
        bytes.extend_from_slice(&self.sender_identity_key);
        bytes.extend_from_slice(&self.ephemeral_key);
        bytes.push(flags);

        if let Some(id) = self.used_one_time_key_id {
            bytes.extend_from_slice(&id.to_be_bytes());
        }

        if let Some(ref ct) = self.pq_ciphertext {
            // A ciphertext longer than u16::MAX cannot be length-prefixed. Encode 0, which
            // `from_bytes` rejects outright, rather than a truncated length that would name
            // a prefix of the real ciphertext and could be mistaken for a valid frame.
            let ct_len = u16::try_from(ct.len()).unwrap_or(0);
            bytes.extend_from_slice(&ct_len.to_be_bytes());
            bytes.extend_from_slice(ct);
        }

        bytes
    }

    /// Deserialize from bytes.
    ///
    /// **Strict**: rejects an unsupported version, any reserved flag bit, a declared-but-empty
    /// ciphertext, and any trailing byte - which also makes the encoding canonical, so every
    /// accepted frame re-encodes to itself. Strictness is the point of v1, and `docs/spec/SRS.md`
    /// records the v0 defect it closes.
    ///
    /// Reachable from attacker-controlled bytes, since the server relays the prekey message
    /// without inspecting it, so it must refuse or parse and never panic. Every length is
    /// checked before it is used to slice.
    pub fn from_bytes(bytes: &[u8]) -> crate::Result<Self> {
        if bytes.len() < PREKEY_MESSAGE_MIN_LEN {
            return Err(crate::CryptoError::Protocol(
                "X3DH prekey message too short".into(),
            ));
        }

        if bytes[0] != PREKEY_MESSAGE_VERSION {
            return Err(crate::CryptoError::Protocol(format!(
                "Unsupported X3DH prekey message version {}",
                bytes[0]
            )));
        }

        let sender_identity_key = bytes[1..33].to_vec();
        let ephemeral_key = bytes[33..65].to_vec();
        let flags = bytes[65];

        let unknown = flags & !PREKEY_FLAGS_KNOWN;
        if unknown != 0 {
            return Err(crate::CryptoError::Protocol(format!(
                "Unknown X3DH prekey message flag bits {:#04x}",
                unknown
            )));
        }

        let mut offset = PREKEY_MESSAGE_MIN_LEN;

        let used_one_time_key_id = if flags & PREKEY_FLAG_ONE_TIME_KEY != 0 {
            let id_bytes: [u8; 4] = bytes
                .get(offset..offset + 4)
                .and_then(|slice| slice.try_into().ok())
                .ok_or_else(|| {
                    crate::CryptoError::Protocol("X3DH prekey message missing OTK ID".into())
                })?;
            offset += 4;
            Some(u32::from_be_bytes(id_bytes))
        } else {
            None
        };

        let pq_ciphertext = if flags & PREKEY_FLAG_PQ_CIPHERTEXT != 0 {
            let len_bytes: [u8; 2] = bytes
                .get(offset..offset + 2)
                .and_then(|slice| slice.try_into().ok())
                .ok_or_else(|| {
                    crate::CryptoError::Protocol(
                        "X3DH prekey message missing ML-KEM ciphertext length".into(),
                    )
                })?;
            offset += 2;

            let ct_len = usize::from(u16::from_be_bytes(len_bytes));
            if ct_len == 0 {
                // Otherwise "no ciphertext" would have two encodings - the flag clear, and
                // the flag set with a zero length - and the frame would not be canonical.
                return Err(crate::CryptoError::Protocol(
                    "X3DH prekey message declares an empty ML-KEM ciphertext".into(),
                ));
            }

            let ct = bytes
                .get(offset..offset + ct_len)
                .ok_or_else(|| {
                    crate::CryptoError::Protocol(
                        "X3DH prekey message ML-KEM ciphertext is truncated".into(),
                    )
                })?
                .to_vec();
            offset += ct_len;
            Some(ct)
        } else {
            None
        };

        if offset != bytes.len() {
            return Err(crate::CryptoError::Protocol(format!(
                "X3DH prekey message has {} trailing byte(s)",
                bytes.len() - offset
            )));
        }

        Ok(Self {
            sender_identity_key,
            ephemeral_key,
            used_one_time_key_id,
            pq_ciphertext,
        })
    }

    /// Encode to base64 for transmission in proto messages
    pub fn to_base64(&self) -> String {
        use base64::{engine::general_purpose::STANDARD, Engine as _};
        STANDARD.encode(self.to_bytes())
    }

    /// Decode from base64
    pub fn from_base64(s: &str) -> crate::Result<Self> {
        use base64::{engine::general_purpose::STANDARD, Engine as _};
        let bytes = STANDARD
            .decode(s)
            .map_err(|e| crate::CryptoError::Protocol(format!("Invalid base64: {}", e)))?;
        Self::from_bytes(&bytes)
    }
}

/// Complete key material for a device
pub struct X3DHKeyMaterial {
    pub identity_key: IdentityKeyPair,
    pub signed_pre_key: SignedPreKey,
    pub one_time_pre_keys: Vec<OneTimePreKey>,
}

impl X3DHKeyMaterial {
    /// Generate complete key material (identity + signed pre-key + one-time keys)
    pub fn generate(num_one_time_keys: usize) -> Result<Self> {
        let identity_key = IdentityKeyPair::generate()?;
        let signed_pre_key = SignedPreKey::generate(1, &identity_key)?;

        let mut one_time_pre_keys = Vec::with_capacity(num_one_time_keys);
        for i in 0..num_one_time_keys {
            one_time_pre_keys.push(OneTimePreKey::generate(i as u32));
        }

        Ok(Self {
            identity_key,
            signed_pre_key,
            one_time_pre_keys,
        })
    }

    /// Export public key bundle for publishing
    pub fn export_bundle(&self) -> X3DHKeyBundle {
        X3DHKeyBundle {
            identity_key: self.identity_key.public_bytes(),
            signed_pre_key: self.signed_pre_key.public_bytes(),
            signed_pre_key_id: self.signed_pre_key.key_id,
            signed_pre_key_signature: self.signed_pre_key.signature.clone(),
            one_time_pre_keys: self
                .one_time_pre_keys
                .iter()
                .map(|key| OneTimePreKeyPublic {
                    key_id: key.key_id,
                    public_key: key.public_bytes(),
                })
                .collect(),
        }
    }
}

/// X3DH Protocol implementation
pub struct X3DHProtocol;

impl X3DHProtocol {
    /// Generate a new key bundle for publishing
    pub fn generate_key_bundle() -> Result<X3DHKeyBundle> {
        let key_material = X3DHKeyMaterial::generate(100)?;
        Ok(key_material.export_bundle())
    }

    /// Perform 4-DH key agreement as initiator (Alice)
    ///
    /// Inputs:
    /// - local_identity: Alice's long-term identity key pair (Ed25519, converted to X25519 for DH)
    /// - peer_bundle: Bob's public key bundle
    /// - use_one_time_key: Whether to use a one-time pre-key (if available)
    ///
    /// Returns: (32-byte shared secret, ephemeral public key to send to peer)
    pub fn initiate_key_agreement(
        local_identity: &IdentityKeyPair,
        peer_bundle: &X3DHKeyBundle,
        use_one_time_key: bool,
    ) -> Result<(Vec<u8>, X25519PublicKey)> {
        // Convert peer's Ed25519 identity key to X25519 for DH
        let peer_identity = ed25519_public_to_x25519(&peer_bundle.identity_key)?;
        let peer_signed_pre_key = x25519_public_from_bytes(&peer_bundle.signed_pre_key)?;

        // Verify signed pre-key signature (using Ed25519)
        IdentityKeyPair::verify(
            &peer_bundle.identity_key,
            &peer_bundle.signed_pre_key,
            &peer_bundle.signed_pre_key_signature,
        )?;

        // Convert local Ed25519 identity key to X25519 for DH operations
        let local_identity_x25519 = local_identity.to_x25519_secret();

        // Generate ephemeral key for this exchange
        let ephemeral_secret = StaticSecret::random_from_rng(OsRng);
        let ephemeral_public = X25519PublicKey::from(&ephemeral_secret);

        // Perform 4-DH:
        // DH1 = DH(IK_A, SPK_B) - Alice's identity (converted to X25519) with Bob's signed prekey
        let dh1 = local_identity_x25519.diffie_hellman(&peer_signed_pre_key);

        // DH2 = DH(EK_A, IK_B) - Alice's ephemeral with Bob's identity (converted to X25519)
        let dh2 = ephemeral_secret.diffie_hellman(&peer_identity);

        // DH3 = DH(EK_A, SPK_B)
        let dh3 = ephemeral_secret.diffie_hellman(&peer_signed_pre_key);

        // Optional DH4 = DH(EK_A, OPK_B)
        let mut dh_outputs: Vec<Vec<u8>> = vec![
            dh1.as_bytes().to_vec(),
            dh2.as_bytes().to_vec(),
            dh3.as_bytes().to_vec(),
        ];

        if use_one_time_key && !peer_bundle.one_time_pre_keys.is_empty() {
            let peer_one_time_key =
                x25519_public_from_bytes(&peer_bundle.one_time_pre_keys[0].public_key)?;
            let dh4 = ephemeral_secret.diffie_hellman(&peer_one_time_key);
            dh_outputs.push(dh4.as_bytes().to_vec());
        }

        // Derive shared secret using HKDF-SHA256
        let shared_secret = derive_shared_secret(&dh_outputs)?;

        Ok((shared_secret, ephemeral_public))
    }

    /// Perform 4-DH key agreement as responder (Bob)
    ///
    /// Inputs:
    /// - key_material: Bob's key material (identity, signed pre-key, one-time keys)
    /// - peer_identity_bytes: Alice's identity public key (Ed25519 format)
    /// - peer_ephemeral_bytes: Alice's ephemeral public key (X25519 format)
    /// - one_time_key_id: Which one-time key was used (if any)
    ///
    /// Returns: 32-byte shared secret
    pub fn respond_key_agreement(
        key_material: &X3DHKeyMaterial,
        peer_identity_bytes: &[u8],
        peer_ephemeral_bytes: &[u8],
        one_time_key_id: Option<u32>,
    ) -> Result<Vec<u8>> {
        // Convert peer's Ed25519 identity key to X25519 for DH
        let peer_identity_x25519 = ed25519_public_to_x25519(peer_identity_bytes)?;
        let peer_ephemeral = x25519_public_from_bytes(peer_ephemeral_bytes)?;

        // Convert local Ed25519 identity key to X25519 for DH operations
        let local_identity_x25519 = key_material.identity_key.to_x25519_secret();

        // Perform 4-DH (symmetric with initiator):
        // DH1 = DH(SPK_B, IK_A) - Bob's signed prekey with Alice's identity (converted to X25519)
        let dh1 = key_material.signed_pre_key.dh(&peer_identity_x25519);

        // DH2 = DH(IK_B, EK_A) - Bob's identity (converted to X25519) with Alice's ephemeral
        let dh2_bytes = local_identity_x25519
            .diffie_hellman(&peer_ephemeral)
            .as_bytes()
            .to_vec();

        // DH3 = DH(SPK_B, EK_A)
        let dh3 = key_material.signed_pre_key.dh(&peer_ephemeral);

        let mut dh_outputs: Vec<Vec<u8>> = vec![dh1, dh2_bytes, dh3];

        // Optional DH4 with one-time key
        if let Some(key_id) = one_time_key_id {
            if let Some(otk) = key_material
                .one_time_pre_keys
                .iter()
                .find(|k| k.key_id == key_id)
            {
                let dh4 = otk.dh(&peer_ephemeral);
                dh_outputs.push(dh4);
            }
        }

        derive_shared_secret(&dh_outputs)
    }
}

/// Convert an Ed25519 signing key to the matching X25519 secret.
///
/// The conversion process (matching TweetNaCl's `crypto_sign_ed25519_sk_to_x25519_sk`):
/// 1. Compute `SHA512(seed)[0:32]` via `to_scalar_bytes()`
/// 2. Apply X25519 clamping via `clamp_integer`, which does not reduce mod l - unlike
///    `to_scalar()`, which does, and would not match TweetNaCl
pub(crate) fn signing_key_to_x25519_secret(signing_key: &SigningKey) -> StaticSecret {
    let raw_scalar_bytes = signing_key.to_scalar_bytes();
    let clamped_bytes = clamp_integer(raw_scalar_bytes);
    StaticSecret::from(clamped_bytes)
}

/// Convert Ed25519 signing key bytes (the 32-byte seed) to the matching X25519 secret.
///
/// Shared with `pqxdh`, whose bundles store the identity key as an Ed25519 seed.
pub(crate) fn ed25519_secret_to_x25519(seed: &[u8; 32]) -> StaticSecret {
    signing_key_to_x25519_secret(&SigningKey::from_bytes(seed))
}

/// Convert Ed25519 public key bytes to an X25519 public key.
///
/// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
/// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
///
/// Shared with `pqxdh`, which performs the same four Diffie-Hellman operations over the same
/// Ed25519 identity keys and must convert them identically.
pub(crate) fn ed25519_public_to_x25519(ed25519_bytes: &[u8]) -> Result<X25519PublicKey> {
    if ed25519_bytes.len() != 32 {
        return Err(CryptoError::InvalidKey(
            "Ed25519 public key must be 32 bytes".into(),
        ));
    }

    let verifying_key = VerifyingKey::from_bytes(
        ed25519_bytes
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid Ed25519 public key length".into()))?,
    )
    .map_err(|e| CryptoError::InvalidKey(format!("Invalid Ed25519 public key: {}", e)))?;

    let montgomery = verifying_key.to_montgomery();
    Ok(X25519PublicKey::from(montgomery.to_bytes()))
}

/// Helper: Convert bytes to X25519 public key (for already X25519 formatted keys)
fn x25519_public_from_bytes(bytes: &[u8]) -> Result<X25519PublicKey> {
    if bytes.len() != 32 {
        return Err(CryptoError::InvalidKey(
            "X25519 public key must be 32 bytes".into(),
        ));
    }
    let mut key_bytes = [0u8; 32];
    key_bytes.copy_from_slice(bytes);
    Ok(X25519PublicKey::from(key_bytes))
}

/// Helper: Derive shared secret from DH outputs using HKDF
fn derive_shared_secret(dh_outputs: &[Vec<u8>]) -> Result<Vec<u8>> {
    // Concatenate all DH outputs
    let mut concat = Vec::new();
    for output in dh_outputs {
        concat.extend_from_slice(output);
    }

    // Use HKDF-SHA256 to derive 32-byte shared secret
    let hk = Hkdf::<Sha256>::new(None, &concat);
    let mut okm = [0u8; 32];
    hk.expand(b"X3DH", &mut okm)
        .map_err(|e| CryptoError::Protocol(format!("HKDF expansion failed: {}", e)))?;

    Ok(okm.to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_identity_key_generation() {
        let key = IdentityKeyPair::generate().expect("Failed to generate identity key");
        assert_eq!(key.public_bytes().len(), 32);
    }

    #[test]
    fn test_signed_pre_key_generation() {
        let identity = IdentityKeyPair::generate().unwrap();
        let spk = SignedPreKey::generate(1, &identity).unwrap();

        assert_eq!(spk.key_id, 1);
        assert_eq!(spk.public_bytes().len(), 32);
        assert!(!spk.signature.is_empty());
    }

    #[test]
    fn test_one_time_key_generation() {
        let otk = OneTimePreKey::generate(42);
        assert_eq!(otk.key_id, 42);
        assert_eq!(otk.public_bytes().len(), 32);
    }

    #[test]
    fn test_key_bundle_generation() {
        let bundle = X3DHProtocol::generate_key_bundle().unwrap();

        assert_eq!(bundle.identity_key.len(), 32);
        assert_eq!(bundle.signed_pre_key.len(), 32);
        assert!(!bundle.signed_pre_key_signature.is_empty());
        assert_eq!(bundle.one_time_pre_keys.len(), 100);
    }

    #[test]
    fn test_signature_verification() {
        let identity = IdentityKeyPair::generate().unwrap();
        let data = b"test data";

        let signature = identity.sign(data).unwrap();
        let result = IdentityKeyPair::verify(&identity.public_bytes(), data, &signature);

        assert!(result.is_ok());
    }

    #[test]
    fn test_x3dh_key_agreement() {
        // Alice and Bob generate key material
        let alice_material = X3DHKeyMaterial::generate(10).unwrap();
        let bob_material = X3DHKeyMaterial::generate(10).unwrap();
        let bob_bundle = bob_material.export_bundle();

        // Alice initiates key agreement with Bob's bundle
        let (alice_shared_secret, alice_ephemeral) =
            X3DHProtocol::initiate_key_agreement(&alice_material.identity_key, &bob_bundle, true)
                .unwrap();

        assert_eq!(alice_shared_secret.len(), 32);

        // Bob responds to complete the key agreement
        let bob_shared_secret = X3DHProtocol::respond_key_agreement(
            &bob_material,
            &alice_material.identity_key.public_bytes(),
            alice_ephemeral.as_bytes(),
            Some(0), // Using first one-time prekey
        )
        .unwrap();

        assert_eq!(bob_shared_secret.len(), 32);

        // Both sides should derive the same shared secret
        assert_eq!(
            alice_shared_secret, bob_shared_secret,
            "Alice and Bob should derive identical shared secrets"
        );
    }

    #[test]
    fn test_ed25519_to_x25519_conversion() {
        let identity = IdentityKeyPair::generate().unwrap();

        // Convert to X25519 keys
        let x25519_public = identity.to_x25519_public();
        let x25519_secret = identity.to_x25519_secret();

        // Verify the conversion is consistent
        let derived_public = X25519PublicKey::from(&x25519_secret);
        assert_eq!(
            x25519_public.as_bytes(),
            derived_public.as_bytes(),
            "X25519 public key derived from secret should match converted public key"
        );
    }

    #[test]
    fn test_x3dh_without_one_time_key() {
        let alice_material = X3DHKeyMaterial::generate(0).unwrap(); // No OTKs
        let bob_material = X3DHKeyMaterial::generate(0).unwrap();
        let bob_bundle = bob_material.export_bundle();

        // Alice initiates without one-time key
        let (alice_shared_secret, alice_ephemeral) = X3DHProtocol::initiate_key_agreement(
            &alice_material.identity_key,
            &bob_bundle,
            false, // No one-time key
        )
        .unwrap();

        // Bob responds
        let bob_shared_secret = X3DHProtocol::respond_key_agreement(
            &bob_material,
            &alice_material.identity_key.public_bytes(),
            alice_ephemeral.as_bytes(),
            None, // No one-time key
        )
        .unwrap();

        assert_eq!(alice_shared_secret, bob_shared_secret);
    }

    #[test]
    fn test_x3dh_prekey_message_serialization() {
        let sender_identity = vec![1u8; 32];
        let ephemeral_key = vec![2u8; 32];

        // Test without OTK
        let msg = X3DHPrekeyMessage::new(sender_identity.clone(), ephemeral_key.clone(), None);

        let bytes = msg.to_bytes();
        assert_eq!(bytes.len(), 66); // 1 + 32 + 32 + 1

        let decoded = X3DHPrekeyMessage::from_bytes(&bytes).unwrap();
        assert_eq!(decoded.sender_identity_key, sender_identity);
        assert_eq!(decoded.ephemeral_key, ephemeral_key);
        assert_eq!(decoded.used_one_time_key_id, None);
    }

    #[test]
    fn test_x3dh_prekey_message_with_otk() {
        let sender_identity = vec![3u8; 32];
        let ephemeral_key = vec![4u8; 32];

        // Test with OTK
        let msg = X3DHPrekeyMessage::new(sender_identity.clone(), ephemeral_key.clone(), Some(42));

        let bytes = msg.to_bytes();
        assert_eq!(bytes.len(), 70); // 1 + 32 + 32 + 1 + 4

        let decoded = X3DHPrekeyMessage::from_bytes(&bytes).unwrap();
        assert_eq!(decoded.sender_identity_key, sender_identity);
        assert_eq!(decoded.ephemeral_key, ephemeral_key);
        assert_eq!(decoded.used_one_time_key_id, Some(42));
    }

    #[test]
    fn test_x3dh_prekey_message_base64() {
        let sender_identity = vec![5u8; 32];
        let ephemeral_key = vec![6u8; 32];

        let msg = X3DHPrekeyMessage::new(sender_identity.clone(), ephemeral_key.clone(), Some(123));

        let base64 = msg.to_base64();
        let decoded = X3DHPrekeyMessage::from_base64(&base64).unwrap();

        assert_eq!(decoded.sender_identity_key, sender_identity);
        assert_eq!(decoded.ephemeral_key, ephemeral_key);
        assert_eq!(decoded.used_one_time_key_id, Some(123));
    }

    /// One known-answer vector: `(name, identity_key_fill, ephemeral_key_fill,
    /// used_one_time_key_id, pq_ciphertext)`, the ciphertext given as `(fill_byte, length)`.
    type PrekeyMessageVector = (&'static str, u8, u8, Option<u32>, Option<(u8, usize)>);

    /// The known-answer vectors for [`X3DHPrekeyMessage`], shared by the byte-exact test and
    /// the Dart emitter below so the two cannot drift apart.
    ///
    /// The fills are distinct per vector so a shifted offset cannot pass unnoticed.
    ///
    /// Ciphertext lengths are deliberately tiny rather than the real 1088: these are
    /// transcribed into a Dart source file, where 2176 hex characters per vector would be
    /// unreviewable. What they must pin is the *framing* - version byte, flag bits, field
    /// order, big-endian length prefix. `prekey_message_carries_a_real_ml_kem_ciphertext`
    /// covers the real size.
    const PREKEY_MESSAGE_VECTORS: &[PrekeyMessageVector] = &[
        ("no_otk", 0x01, 0x02, None, None),
        // The id every client sends today, and the reason #255 stayed invisible.
        ("otk_id_zero", 0x03, 0x04, Some(0), None),
        // The discriminating case: big-endian writes 00000001, little-endian 01000000.
        ("otk_id_one", 0x05, 0x06, Some(1), None),
        // Fully asymmetric, so any byte permutation fails rather than only a full reversal.
        ("otk_id_asymmetric", 0x07, 0x08, Some(0x0102_0304), None),
        ("otk_id_max", 0x09, 0x0a, Some(u32::MAX), None),
        // A hybrid handshake against a bundle with no one-time key: flag 0x02 alone, so the
        // ciphertext must sit immediately after the flags byte rather than at a fixed offset.
        ("pq_only", 0x0b, 0x0c, None, Some((0xaa, 4))),
        // Both optional fields present. This is the vector that pins their *order* - a reader
        // that took the ciphertext before the one-time key id would still satisfy every other
        // vector here.
        ("otk_and_pq", 0x0d, 0x0e, Some(7), Some((0xbb, 4))),
    ];

    fn prekey_message_vector(
        identity_fill: u8,
        ephemeral_fill: u8,
        id: Option<u32>,
        ct: Option<(u8, usize)>,
    ) -> X3DHPrekeyMessage {
        let msg = X3DHPrekeyMessage::new(vec![identity_fill; 32], vec![ephemeral_fill; 32], id);
        match ct {
            Some((fill, len)) => msg.with_pq_ciphertext(vec![fill; len]),
            None => msg,
        }
    }

    fn hex_of(bytes: &[u8]) -> String {
        bytes.iter().map(|b| format!("{:02x}", b)).collect()
    }

    /// A Rust-to-Rust round-trip passes just as happily when both ends share a bug, which is
    /// how `otk_id` stayed little-endian here while `client-mobile` read it big-endian until
    /// #255. These vectors and `wire_vectors_test.dart` assert the same constants, so the two
    /// implementations are pinned to one answer rather than to each other - the argument
    /// ADR-0011 makes about the ratchet frame.
    #[test]
    fn prekey_message_serializes_to_the_known_answer_vectors() {
        // Everything from the flags byte onward - the whole of what framing affects.
        let expected_tails = [
            "00",
            "0100000000",
            "0100000001",
            "0101020304",
            "01ffffffff",
            "020004aaaaaaaa",
            "03000000070004bbbbbbbb",
        ];

        for ((name, identity_fill, ephemeral_fill, id, ct), expected_tail) in
            PREKEY_MESSAGE_VECTORS.iter().zip(expected_tails)
        {
            let bytes = prekey_message_vector(*identity_fill, *ephemeral_fill, *id, *ct).to_bytes();

            assert_eq!(
                bytes[0], 1,
                "{name}: the version byte is not 0x01 at offset 0"
            );
            assert_eq!(
                hex_of(&bytes[1..33]),
                format!("{:02x}", identity_fill).repeat(32),
                "{name}: identity key is not at offset 1"
            );
            assert_eq!(
                hex_of(&bytes[33..65]),
                format!("{:02x}", ephemeral_fill).repeat(32),
                "{name}: ephemeral key is not at offset 33"
            );
            assert_eq!(
                hex_of(&bytes[65..]),
                expected_tail,
                "{name}: flags, one-time key id and ML-KEM ciphertext are not the known answer"
            );
        }
    }

    /// Every vector above must also survive a round-trip, so a future edit cannot satisfy the
    /// byte-exact test by breaking the parser instead.
    #[test]
    fn prekey_message_round_trips_every_known_answer_vector() {
        for (name, identity_fill, ephemeral_fill, id, ct) in PREKEY_MESSAGE_VECTORS {
            let msg = prekey_message_vector(*identity_fill, *ephemeral_fill, *id, *ct);
            let decoded = X3DHPrekeyMessage::from_bytes(&msg.to_bytes())
                .unwrap_or_else(|e| panic!("{name}: {e}"));

            assert_eq!(
                decoded.sender_identity_key, msg.sender_identity_key,
                "{name}"
            );
            assert_eq!(decoded.ephemeral_key, msg.ephemeral_key, "{name}");
            assert_eq!(decoded.used_one_time_key_id, *id, "{name}");
            assert_eq!(decoded.pq_ciphertext, msg.pq_ciphertext, "{name}");
        }
    }

    /// The vectors above use 4-byte ciphertexts for legibility; the real one is 1088 bytes.
    /// A `u16` holds it with room for ML-KEM-1024's 1568 too - the point of the prefix.
    #[test]
    fn prekey_message_carries_a_real_ml_kem_ciphertext() {
        let ct = vec![0x5au8; 1088];
        let msg = X3DHPrekeyMessage::new(vec![0x11; 32], vec![0x22; 32], Some(3))
            .with_pq_ciphertext(ct.clone());

        let bytes = msg.to_bytes();
        assert_eq!(bytes.len(), 70 + 2 + 1088);
        // The length prefix is big-endian: 1088 == 0x0440.
        assert_eq!(&bytes[70..72], &[0x04, 0x40]);

        let decoded = X3DHPrekeyMessage::from_bytes(&bytes).expect("decode");
        assert_eq!(decoded.pq_ciphertext, Some(ct));
        assert_eq!(decoded.used_one_time_key_id, Some(3));
    }

    /// v1's whole purpose is that a frame it cannot fully account for is refused rather than
    /// half-read; `docs/spec/SRS.md` records the v0 defect. Each case below is one way a
    /// half-read frame could otherwise reach key agreement.
    #[test]
    fn prekey_message_parser_rejects_every_malformed_frame() {
        let valid = prekey_message_vector(0x0d, 0x0e, Some(7), Some((0xbb, 4))).to_bytes();
        assert!(X3DHPrekeyMessage::from_bytes(&valid).is_ok(), "baseline");

        let reject = |label: &str, bytes: Vec<u8>| {
            assert!(
                X3DHPrekeyMessage::from_bytes(&bytes).is_err(),
                "{label}: accepted a frame it should refuse"
            );
        };

        reject("truncated below the minimum", valid[..65].to_vec());

        // A v0 frame. Its first byte is an Ed25519 key byte, so it is only ever 0x01 by
        // coincidence - which is exactly why v1 is a hard break with no fallback.
        let mut v0 = valid.clone();
        v0[0] = 0x00;
        reject("version 0", v0);

        let mut future = valid.clone();
        future[0] = 0x02;
        reject("a version from the future", future);

        // Reserved flag bits. Reading these as "absent" is the v0 defect that made the whole
        // format unextendable, so every one of them must be an error, not a shrug.
        for bit in [0x04u8, 0x08, 0x10, 0x20, 0x40, 0x80] {
            let mut unknown = valid.clone();
            unknown[65] |= bit;
            reject(&format!("reserved flag bit {bit:#04x}"), unknown);
        }

        // The flag claims a one-time key id that is not there.
        reject("one-time key id truncated", valid[..68].to_vec());

        // The flag claims a ciphertext; only one byte of its two-byte length is present.
        reject("ciphertext length truncated", valid[..71].to_vec());

        // ct_len declares more bytes than the frame holds.
        let mut overlong = valid.clone();
        overlong[70] = 0xff;
        overlong[71] = 0xff;
        reject("ciphertext length exceeds the frame", overlong);

        // A zero-length ciphertext would give "no ciphertext" a second encoding, so the frame
        // would no longer be canonical and the fuzz target's re-encode assertion would fire.
        let mut empty_ct = valid[..72].to_vec();
        empty_ct[70] = 0x00;
        empty_ct[71] = 0x00;
        reject("ciphertext declared empty", empty_ct);

        // The defect this version exists to close: extra bytes after a complete frame.
        let mut trailing = valid.clone();
        trailing.push(0x00);
        reject("one trailing byte", trailing);
    }

    /// `Debug` must not print the ML-KEM ciphertext: `AGENTS.md` §4 forbids payload in any log
    /// line, and a derived `Debug` reaching a `{:?}` is how that happens.
    #[test]
    fn prekey_message_debug_redacts_the_ml_kem_ciphertext() {
        let msg = X3DHPrekeyMessage::new(vec![0x11; 32], vec![0x22; 32], Some(3))
            .with_pq_ciphertext(vec![0x7fu8; 1088]);

        let rendered = format!("{:?}", msg);

        assert!(rendered.contains("[REDACTED"), "{rendered}");
        assert!(
            !rendered.contains("127, 127"),
            "the ciphertext reached Debug output: {rendered}"
        );
    }

    /// Emit the Dart half of the vectors above.
    ///
    /// Run with
    /// `cargo test -p guardyn-crypto emit_dart_prekey_message_vectors -- --nocapture`
    /// and paste the output into `client-mobile/test/core/crypto/wire_vectors_test.dart`.
    ///
    /// ADR-0011 requires these to be regenerated whenever a layout changes, but the ratchet
    /// vectors it introduced had no committed emitter, so "regenerate" had no procedure behind
    /// it. This is that procedure for the prekey message.
    ///
    /// The emitted map carries the whole frame under `'frame'`. The Dart side used to store a
    /// `'tail'` and rebuild `ik + ek + tail`, so the documented copy-paste never worked - and
    /// rebuilding a frame from parts hides layout changes, because the reconstruction encodes
    /// the very offsets under test.
    #[test]
    fn emit_dart_prekey_message_vectors() {
        println!("\n=== X3DHPrekeyMessage vectors for wire_vectors_test.dart ===\n");

        for (name, identity_fill, ephemeral_fill, id, ct) in PREKEY_MESSAGE_VECTORS {
            let msg = prekey_message_vector(*identity_fill, *ephemeral_fill, *id, *ct);
            let otk = match id {
                Some(value) => value.to_string(),
                None => "null".to_string(),
            };
            let pq = match ct {
                Some((fill, len)) => format!("'{}'", format!("{:02x}", fill).repeat(*len)),
                None => "null".to_string(),
            };

            println!("    '{name}': {{");
            println!("      'ik': '{:02x}',", identity_fill);
            println!("      'ek': '{:02x}',", ephemeral_fill);
            println!("      'otkId': {otk},");
            println!("      'pqCiphertext': {pq},");
            println!("      'frame': '{}',", hex_of(&msg.to_bytes()));
            println!("    }},");
        }

        println!("\n=== end ===\n");
    }

    #[test]
    fn test_x3dh_full_flow_with_prekey_message() {
        // Generate key material for both parties
        let alice_material = X3DHKeyMaterial::generate(10).unwrap();
        let bob_material = X3DHKeyMaterial::generate(10).unwrap();
        let bob_bundle = bob_material.export_bundle();

        // Alice initiates key agreement
        let (alice_shared_secret, alice_ephemeral) = X3DHProtocol::initiate_key_agreement(
            &alice_material.identity_key,
            &bob_bundle,
            true, // Use one-time key
        )
        .unwrap();

        // Alice creates prekey message to send with first encrypted message
        let prekey_msg = X3DHPrekeyMessage::new(
            alice_material.identity_key.public_bytes(),
            alice_ephemeral.as_bytes().to_vec(),
            Some(0), // First OTK
        );

        // Serialize for transmission
        let prekey_base64 = prekey_msg.to_base64();

        // --- Message transmitted over network ---

        // Bob receives and parses prekey message
        let received_prekey = X3DHPrekeyMessage::from_base64(&prekey_base64).unwrap();

        // Bob performs X3DH key agreement
        let bob_shared_secret = X3DHProtocol::respond_key_agreement(
            &bob_material,
            &received_prekey.sender_identity_key,
            &received_prekey.ephemeral_key,
            received_prekey.used_one_time_key_id,
        )
        .unwrap();

        // Both parties should have identical shared secrets
        assert_eq!(
            alice_shared_secret, bob_shared_secret,
            "X3DH key agreement should produce identical shared secrets"
        );
    }

    #[test]
    fn test_identity_key_pair_serialization() {
        // Generate a key pair
        let original = IdentityKeyPair::generate().unwrap();

        // Serialize private key
        let private_bytes = original.private_key_bytes();
        assert_eq!(private_bytes.len(), 32, "Private key should be 32 bytes");

        // Reconstruct from private bytes
        let restored = IdentityKeyPair::from_private_bytes(&private_bytes).unwrap();

        // Verify public keys match
        assert_eq!(
            original.public_bytes(),
            restored.public_bytes(),
            "Public keys should match after reconstruction"
        );

        // Verify signing works the same
        let test_data = b"test message for signing";
        let original_sig = original.sign(test_data).unwrap();
        let restored_sig = restored.sign(test_data).unwrap();
        assert_eq!(original_sig, restored_sig, "Signatures should match");

        // Verify signature is valid
        IdentityKeyPair::verify(&original.public_bytes(), test_data, &original_sig).unwrap();
    }

    #[test]
    fn test_identity_key_pair_from_invalid_bytes() {
        // Too short
        let result = IdentityKeyPair::from_private_bytes(&[0u8; 16]);
        assert!(result.is_err());

        // Too long
        let result = IdentityKeyPair::from_private_bytes(&[0u8; 64]);
        assert!(result.is_err());
    }

    /// A restored pre-key must be indistinguishable from the original, not merely
    /// well-formed. `client-desktop` used to "restore" by regenerating under the same
    /// `key_id`, which produced a fresh random secret - the public halves differed, so the
    /// responder derived a different shared secret and every message failed to decrypt with
    /// no signal about why. Asserting on the DH output is what catches that; asserting the
    /// key merely exists does not.
    #[test]
    fn test_restored_signed_pre_key_agrees_with_the_original() {
        let identity = IdentityKeyPair::generate().expect("identity");
        let original = SignedPreKey::generate(7, &identity).expect("signed pre-key");
        let peer = OneTimePreKey::generate(0);

        let restored = SignedPreKey::from_secret_bytes(
            original.key_id,
            original.ratchet_secret().to_bytes(),
            original.signature.clone(),
            original.timestamp,
        );

        assert_eq!(restored.key_id, original.key_id);
        assert_eq!(restored.public_bytes(), original.public_bytes());
        assert_eq!(restored.signature, original.signature);
        assert_eq!(restored.dh(&peer.public), original.dh(&peer.public));
    }

    #[test]
    fn test_restored_one_time_pre_key_agrees_with_the_original() {
        let original = OneTimePreKey::generate(3);
        let peer = OneTimePreKey::generate(0);

        let restored =
            OneTimePreKey::from_secret_bytes(original.key_id, original.secret().to_bytes());

        assert_eq!(restored.key_id, original.key_id);
        assert_eq!(restored.public_bytes(), original.public_bytes());
        assert_eq!(restored.dh(&peer.public), original.dh(&peer.public));
    }

    /// The failure mode the restore constructors exist to prevent, asserted directly: a key
    /// regenerated under the same id is a different key.
    #[test]
    fn test_regenerating_under_the_same_key_id_yields_a_different_key() {
        let identity = IdentityKeyPair::generate().expect("identity");
        let original = SignedPreKey::generate(7, &identity).expect("signed pre-key");
        let regenerated = SignedPreKey::generate(7, &identity).expect("signed pre-key");

        assert_eq!(regenerated.key_id, original.key_id, "same id");
        assert_ne!(
            regenerated.public_bytes(),
            original.public_bytes(),
            "a regenerated pre-key must not be mistaken for the published one"
        );
    }

    /// End to end: a responder that restores its published material derives the same secret
    /// the initiator did. This is the property PR-80 depends on.
    #[test]
    fn test_responder_restored_from_storage_agrees_with_initiator() {
        let bob_identity = IdentityKeyPair::generate().expect("bob identity");
        let bob_spk = SignedPreKey::generate(1, &bob_identity).expect("bob spk");
        let bob_otk = OneTimePreKey::generate(0);

        let bundle = X3DHKeyBundle {
            identity_key: bob_identity.public_bytes(),
            signed_pre_key: bob_spk.public_bytes(),
            signed_pre_key_id: bob_spk.key_id,
            signed_pre_key_signature: bob_spk.signature.clone(),
            one_time_pre_keys: vec![OneTimePreKeyPublic {
                key_id: bob_otk.key_id,
                public_key: bob_otk.public_bytes(),
            }],
        };

        let alice_identity = IdentityKeyPair::generate().expect("alice identity");
        let (alice_secret, alice_ephemeral) =
            X3DHProtocol::initiate_key_agreement(&alice_identity, &bundle, true).expect("initiate");

        // Bob comes back after a restart holding only what he persisted.
        let restored = X3DHKeyMaterial {
            identity_key: bob_identity,
            signed_pre_key: SignedPreKey::from_secret_bytes(
                bob_spk.key_id,
                bob_spk.ratchet_secret().to_bytes(),
                bob_spk.signature.clone(),
                bob_spk.timestamp,
            ),
            one_time_pre_keys: vec![OneTimePreKey::from_secret_bytes(
                bob_otk.key_id,
                bob_otk.secret().to_bytes(),
            )],
        };

        let bob_secret = X3DHProtocol::respond_key_agreement(
            &restored,
            &alice_identity.public_bytes(),
            alice_ephemeral.as_bytes(),
            Some(bob_otk.key_id),
        )
        .expect("respond");

        assert_eq!(alice_secret, bob_secret, "both ends must derive one secret");
    }
}
