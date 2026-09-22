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
use std::sync::atomic::{AtomicBool, Ordering};

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
// Hybrid PQXDH Key Agreement
// ============================================================================

/// A peer's published key bundle, as fetched from `auth-service`.
///
/// Every field here is public material - this is what a peer advertises. `pq_prekey` and
/// `pq_prekey_signature` are `common.KeyBundle` tags 6 and 7, and they are carried as two
/// independent `Option`s **on purpose**: a bundle holding one without the other must be
/// rejected in whole rather than degraded to a classical exchange, and coupling them here
/// would make the orphan unrepresentable and therefore silently discarded instead.
#[frb(dart_metadata = ("freezed"))]
#[derive(Debug, Clone)]
pub struct HybridPeerBundle {
    /// Ed25519 identity public key (32 bytes)
    pub identity_key: Vec<u8>,
    /// X25519 signed pre-key (32 bytes)
    pub signed_prekey: Vec<u8>,
    /// Ed25519 signature over `signed_prekey` (64 bytes)
    pub signed_prekey_signature: Vec<u8>,
    /// X25519 one-time pre-key (32 bytes), when the peer had one to serve
    pub one_time_prekey: Option<Vec<u8>>,
    /// ML-KEM-768 encapsulation key (1184 bytes) - `common.KeyBundle` tag 6
    pub pq_prekey: Option<Vec<u8>>,
    /// Ed25519 signature over `pq_prekey` (64 bytes) - `common.KeyBundle` tag 7
    pub pq_prekey_signature: Option<Vec<u8>>,
}

/// What an initiator holds after agreeing a hybrid secret.
///
/// Deliberately **not** `freezed`. Freezed generates a `toString()` that interpolates every
/// field, and `shared_secret` is key material - `.claude/rules/30-zk-logging.md` forbids it
/// reaching a log, a span or stdout, and a Dart `toString()` reaches all three. Plain
/// flutter_rust_bridge renders `Instance of 'HybridSenderAgreement'` instead. See #348 for the
/// three existing types that already have this problem.
#[derive(Clone)]
pub struct HybridSenderAgreement {
    /// The 32-byte shared secret. Feed it straight to the Double Ratchet; do not log it.
    pub shared_secret: Vec<u8>,
    /// The initiator's ephemeral X25519 public key (32 bytes), for the prekey message.
    pub ephemeral_public: Vec<u8>,
    /// ML-KEM-768 ciphertext (1088 bytes), present exactly when the peer published an ML-KEM
    /// pre-key. Its presence is what sets the prekey message's `0x02` flag.
    pub pq_ciphertext: Option<Vec<u8>>,
}

/// Decode a fixed-width key field, naming the field when it is the wrong length.
///
/// No `unwrap`/`expect`: `RS-UNWRAP` in `.claude/rules/20-code-style.md` is a ratchet frozen at
/// its measured count, and every one of these lengths is attacker-influenced anyway - the bytes
/// arrive from a peer's bundle or a relayed prekey message.
#[cfg(feature = "pq")]
fn fixed_key<const N: usize>(bytes: &[u8], field: &str) -> Result<[u8; N], String> {
    bytes
        .try_into()
        .map_err(|_| format!("{} must be {} bytes, got {}", field, N, bytes.len()))
}

#[cfg(feature = "pq")]
impl HybridPeerBundle {
    /// Map onto the crate's bundle type, preserving a half pair rather than dropping it.
    fn to_pqxdh(&self) -> Result<guardyn_crypto::pqxdh::HybridKeyBundle, String> {
        use guardyn_crypto::pqxdh::{HybridKeyBundle as Bundle, SignatureBytes};

        Ok(Bundle {
            identity_key: fixed_key(&self.identity_key, "identity key")?,
            signed_prekey: fixed_key(&self.signed_prekey, "signed pre-key")?,
            signed_prekey_signature: SignatureBytes(fixed_key(
                &self.signed_prekey_signature,
                "signed pre-key signature",
            )?),
            one_time_prekey: self
                .one_time_prekey
                .as_deref()
                .map(|k| fixed_key(k, "one-time pre-key"))
                .transpose()?,
            pq_prekey: self.pq_prekey.clone(),
            pq_prekey_signature: self
                .pq_prekey_signature
                .as_deref()
                .map(|s| fixed_key(s, "ML-KEM pre-key signature").map(SignatureBytes))
                .transpose()?,
        })
    }
}

/// Error returned by every hybrid entry point in a build compiled without `pq`.
#[cfg(not(feature = "pq"))]
const NO_PQ: &str = "refusing a hybrid handshake: this build has no post-quantum support";

/// Derive the ML-KEM-768 encapsulation key a stored seed stands for.
///
/// The counterpart to `ml_kem_seed` in [`crypto_derive_recipient_shared_secret`]: that function
/// answers handshakes addressed to this key, and this is how a device learns which key that is
/// without storing the 2400-byte decapsulation key it shares a seed with.
///
/// Returns the 1184-byte encapsulation key. The decapsulation key is derived, used and dropped
/// inside Rust and never crosses this boundary.
#[frb(sync)]
pub fn crypto_ml_kem_public_from_seed(seed: Vec<u8>) -> Result<Vec<u8>, String> {
    #[cfg(feature = "pq")]
    {
        use guardyn_crypto::pqxdh;

        let seed: [u8; pqxdh::MLKEM_SEED_SIZE] = fixed_key(&seed, "ML-KEM seed")?;
        pqxdh::ml_kem_keys_from_seed(&seed)
            .map(|(_dk, ek)| ek)
            .map_err(|e| e.to_string())
    }

    #[cfg(not(feature = "pq"))]
    {
        let _ = seed;
        Err(NO_PQ.to_string())
    }
}

/// Verify a peer's key bundle before using it.
///
/// Both pre-keys are signed by the same Ed25519 identity key. The signed pre-key is mandatory;
/// the ML-KEM pre-key is optional, but its two fields are present together or absent together,
/// and a bundle carrying one half is rejected **in whole**. Stripping one field is cheaper for
/// an attacker than breaking either primitive, so a silent fallback to the classical exchange is
/// the attack rather than a convenience.
///
/// `crypto_derive_sender_shared_secret` calls this itself; it is exported separately so a
/// freshly-fetched bundle can be checked at the point it arrives.
#[frb(sync)]
pub fn crypto_verify_hybrid_bundle(bundle: HybridPeerBundle) -> Result<(), String> {
    #[cfg(feature = "pq")]
    {
        let bundle = bundle.to_pqxdh()?;
        guardyn_crypto::pqxdh::verify_hybrid_bundle(&bundle).map_err(|e| e.to_string())
    }

    #[cfg(not(feature = "pq"))]
    {
        let _ = bundle;
        Err(NO_PQ.to_string())
    }
}

/// Agree a hybrid shared secret as the initiator.
///
/// Performs the four X3DH Diffie-Hellman operations and, when the peer published an ML-KEM
/// pre-key, an ML-KEM-768 encapsulation, mixing both into one HKDF with the `PQXDH_SharedSecret`
/// info string. A classical peer yields `pq_ciphertext: None` and the classical arm.
///
/// # What this does *not* take
///
/// The ephemeral keypair is minted here rather than passed in, so no ephemeral secret ever
/// crosses into Dart. Its public half comes back in [`HybridSenderAgreement::ephemeral_public`],
/// which is the only part a prekey message needs.
///
/// The peer's bundle is verified before any key agreement runs, and that is deliberate:
/// `derive_sender_shared_secret` is `pub` and does not verify, so every caller has had to
/// remember. A guarantee that holds because every caller remembers is not a guarantee.
///
/// # Arguments
/// - `sender_identity_seed`: the initiator's 32-byte **Ed25519 seed**. Not its X25519 form -
///   the conversion happens inside, and pre-converting silently derives a different secret.
/// - `recipient_bundle`: the peer's published bundle.
#[frb(sync)]
pub fn crypto_derive_sender_shared_secret(
    sender_identity_seed: Vec<u8>,
    recipient_bundle: HybridPeerBundle,
) -> Result<HybridSenderAgreement, String> {
    #[cfg(feature = "pq")]
    {
        use guardyn_crypto::{pqxdh, StaticSecret, X25519PublicKey};

        let identity_seed: [u8; 32] = fixed_key(&sender_identity_seed, "sender identity seed")?;
        let bundle = recipient_bundle.to_pqxdh()?;
        pqxdh::verify_hybrid_bundle(&bundle)
            .map_err(|e| format!("Peer key bundle failed verification: {}", e))?;

        let ephemeral = StaticSecret::random_from_rng(rand::rngs::OsRng);
        let ephemeral_public = X25519PublicKey::from(&ephemeral);

        let (secret, additional_data) =
            pqxdh::derive_sender_shared_secret(&identity_seed, &ephemeral.to_bytes(), &bundle)
                .map_err(|e| e.to_string())?;

        // `additional_data` is `ephemeral_public(32) || ciphertext`, and the ephemeral already
        // travels in its own field of the prekey message. Splitting here rather than in each
        // caller is the point: the same `[32..]` arithmetic is currently open-coded in the
        // desktop client, the crate's tests and the benchmark.
        let pq_ciphertext = additional_data
            .get(32..)
            .filter(|ct| !ct.is_empty())
            .map(<[u8]>::to_vec);

        Ok(HybridSenderAgreement {
            shared_secret: secret.as_bytes().to_vec(),
            ephemeral_public: ephemeral_public.as_bytes().to_vec(),
            pq_ciphertext,
        })
    }

    #[cfg(not(feature = "pq"))]
    {
        let _ = (sender_identity_seed, recipient_bundle);
        Err(NO_PQ.to_string())
    }
}

/// Agree a hybrid shared secret as the responder.
///
/// Mirrors [`crypto_derive_sender_shared_secret`]: the same four Diffie-Hellman operations from
/// the other side, plus ML-KEM decapsulation when the initiator sent a ciphertext.
///
/// Fails closed on either asymmetric shape - a ciphertext this device cannot open, or a device
/// holding an ML-KEM key asked to answer a handshake that carries none. Neither degrades to a
/// classical secret, because a silent degrade surfaces only as an AEAD tag rejection later, with
/// both ends looking healthy.
///
/// # Why a seed and not a decapsulation key
///
/// `ml_kem_seed` is the 64-byte FIPS 203 `(d || z)` seed, and the 2400-byte decapsulation key it
/// expands to never crosses this boundary. The seed is the specified compact private-key form,
/// it is what the desktop client already persists, and it is 64 bytes rather than 4800 hex
/// characters against a 2560-byte credential cap.
///
/// Pass `None` only for a genuinely classical session. A responder must **never** substitute a
/// freshly-minted seed for a missing one: ML-KEM uses implicit rejection, so the wrong
/// decapsulation key yields a pseudorandom secret rather than an error.
///
/// # Arguments
/// - `identity_seed`: this device's 32-byte **Ed25519 seed**.
/// - `signed_prekey_secret`: the X25519 secret for the signed pre-key the initiator used.
/// - `one_time_prekey_secret`: the X25519 secret for the one-time pre-key named by the prekey
///   message, or `None` when it named none.
/// - `ml_kem_seed`: this device's 64-byte ML-KEM seed, or `None` for a classical session.
/// - `sender_identity_key` / `sender_ephemeral_key`: 32 bytes each, from the prekey message.
/// - `pq_ciphertext`: the 1088-byte ML-KEM ciphertext, present exactly when the prekey message
///   carried the `0x02` flag.
#[frb(sync)]
pub fn crypto_derive_recipient_shared_secret(
    identity_seed: Vec<u8>,
    signed_prekey_secret: Vec<u8>,
    one_time_prekey_secret: Option<Vec<u8>>,
    ml_kem_seed: Option<Vec<u8>>,
    sender_identity_key: Vec<u8>,
    sender_ephemeral_key: Vec<u8>,
    pq_ciphertext: Option<Vec<u8>>,
) -> Result<Vec<u8>, String> {
    #[cfg(feature = "pq")]
    {
        use guardyn_crypto::pqxdh;

        let identity: [u8; 32] = fixed_key(&identity_seed, "identity seed")?;
        let signed_prekey: [u8; 32] = fixed_key(&signed_prekey_secret, "signed pre-key secret")?;
        let one_time_prekey = one_time_prekey_secret
            .as_deref()
            .map(|k| fixed_key(k, "one-time pre-key secret"))
            .transpose()?;

        let decapsulation_key = ml_kem_seed
            .as_deref()
            .map(|s| {
                let seed: [u8; pqxdh::MLKEM_SEED_SIZE] = fixed_key(s, "ML-KEM seed")?;
                pqxdh::ml_kem_keys_from_seed(&seed)
                    .map(|(dk, _ek)| dk)
                    .map_err(|e| e.to_string())
            })
            .transpose()?;

        let private_keys = pqxdh::HybridPrivateKeys::from_parts(
            identity,
            signed_prekey,
            one_time_prekey,
            decapsulation_key,
        );

        let secret = pqxdh::derive_recipient_shared_secret(
            &private_keys,
            &fixed_key(&sender_identity_key, "sender identity key")?,
            &fixed_key(&sender_ephemeral_key, "sender ephemeral key")?,
            pq_ciphertext.as_deref(),
        )
        .map_err(|e| e.to_string())?;

        Ok(secret.as_bytes().to_vec())
    }

    #[cfg(not(feature = "pq"))]
    {
        let _ = (
            identity_seed,
            signed_prekey_secret,
            one_time_prekey_secret,
            ml_kem_seed,
            sender_identity_key,
            sender_ephemeral_key,
            pq_ciphertext,
        );
        Err(NO_PQ.to_string())
    }
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

        let encrypted =
            crypto_encrypt_chacha20(plaintext.clone(), key.clone(), None, None).unwrap();
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

    // ------------------------------------------------------------------
    // Hybrid PQXDH
    // ------------------------------------------------------------------

    /// A responder as PR-98b will build one: an Ed25519 identity, an X25519 signed pre-key and a
    /// 64-byte ML-KEM seed, with the published bundle derived from them.
    #[cfg(feature = "pq")]
    struct Responder {
        identity_seed: Vec<u8>,
        signed_prekey_secret: Vec<u8>,
        ml_kem_seed: Vec<u8>,
        bundle: HybridPeerBundle,
    }

    #[cfg(feature = "pq")]
    fn responder(with_pq: bool) -> Responder {
        let identity_seed = crypto_random_bytes(32);
        let identity = crypto_generate_ed25519_keypair_from_seed(identity_seed.clone()).unwrap();
        let signed_prekey = crypto_generate_x25519_keypair();

        let ml_kem_seed = crypto_random_bytes(64);
        let (pq_prekey, pq_prekey_signature) = if with_pq {
            let public = crypto_ml_kem_public_from_seed(ml_kem_seed.clone()).unwrap();
            let signature =
                crypto_sign_ed25519(identity.private_key.clone(), public.clone()).unwrap();
            (Some(public), Some(signature))
        } else {
            (None, None)
        };

        Responder {
            bundle: HybridPeerBundle {
                identity_key: identity.public_key.clone(),
                signed_prekey: signed_prekey.public_key.clone(),
                signed_prekey_signature: crypto_sign_ed25519(
                    identity.private_key,
                    signed_prekey.public_key.clone(),
                )
                .unwrap(),
                one_time_prekey: None,
                pq_prekey,
                pq_prekey_signature,
            },
            identity_seed,
            signed_prekey_secret: signed_prekey.private_key,
            ml_kem_seed,
        }
    }

    /// The whole point of the step: both sides reach the same secret without either the ML-KEM
    /// decapsulation key or an ephemeral secret ever crossing the boundary.
    #[cfg(feature = "pq")]
    #[test]
    fn hybrid_agreement_round_trips_through_the_ffi_surface() {
        let bob = responder(true);
        let alice_identity_seed = crypto_random_bytes(32);
        let alice = crypto_generate_ed25519_keypair_from_seed(alice_identity_seed.clone()).unwrap();

        let agreement =
            crypto_derive_sender_shared_secret(alice_identity_seed, bob.bundle.clone()).unwrap();

        assert_eq!(agreement.shared_secret.len(), 32);
        assert_eq!(agreement.ephemeral_public.len(), 32);
        assert_eq!(
            agreement.pq_ciphertext.as_ref().map(Vec::len),
            Some(1088),
            "a peer with an ML-KEM pre-key must yield a ciphertext"
        );

        let recipient_secret = crypto_derive_recipient_shared_secret(
            bob.identity_seed,
            bob.signed_prekey_secret,
            None,
            Some(bob.ml_kem_seed),
            alice.public_key,
            agreement.ephemeral_public,
            agreement.pq_ciphertext,
        )
        .unwrap();

        assert_eq!(agreement.shared_secret, recipient_secret);
    }

    /// A classical peer takes the classical arm and emits no ciphertext, so the caller has
    /// nothing to set the prekey message's `0x02` flag from.
    #[cfg(feature = "pq")]
    #[test]
    fn a_classical_bundle_yields_no_ciphertext() {
        let bob = responder(false);
        let alice_identity_seed = crypto_random_bytes(32);
        let alice = crypto_generate_ed25519_keypair_from_seed(alice_identity_seed.clone()).unwrap();

        let agreement =
            crypto_derive_sender_shared_secret(alice_identity_seed, bob.bundle.clone()).unwrap();
        assert!(agreement.pq_ciphertext.is_none());

        let recipient_secret = crypto_derive_recipient_shared_secret(
            bob.identity_seed,
            bob.signed_prekey_secret,
            None,
            None,
            alice.public_key,
            agreement.ephemeral_public,
            None,
        )
        .unwrap();

        assert_eq!(agreement.shared_secret, recipient_secret);
    }

    /// Stripping one of the two ML-KEM fields is cheaper than breaking either primitive, so the
    /// bundle must be refused in whole rather than degraded to the classical exchange.
    #[cfg(feature = "pq")]
    #[test]
    fn a_half_pair_bundle_is_refused_in_whole() {
        for strip_signature in [true, false] {
            let bob = responder(true);
            let mut bundle = bob.bundle.clone();
            if strip_signature {
                bundle.pq_prekey_signature = None;
            } else {
                bundle.pq_prekey = None;
            }

            assert!(
                crypto_verify_hybrid_bundle(bundle.clone()).is_err(),
                "a half pair must not verify (signature stripped: {})",
                strip_signature
            );
            assert!(
                crypto_derive_sender_shared_secret(crypto_random_bytes(32), bundle).is_err(),
                "the sender path must not agree on a half pair (signature stripped: {})",
                strip_signature
            );
        }
    }

    /// A responder handed a ciphertext it holds no seed for must fail rather than derive a
    /// classical secret: ML-KEM's implicit rejection means the mistake would otherwise surface
    /// only as an AEAD tag rejection, with both ends looking healthy.
    #[cfg(feature = "pq")]
    #[test]
    fn a_responder_without_its_seed_fails_closed() {
        let bob = responder(true);
        let alice_identity_seed = crypto_random_bytes(32);
        let alice = crypto_generate_ed25519_keypair_from_seed(alice_identity_seed.clone()).unwrap();
        let agreement =
            crypto_derive_sender_shared_secret(alice_identity_seed, bob.bundle.clone()).unwrap();

        // Ciphertext present, seed withheld.
        assert!(crypto_derive_recipient_shared_secret(
            bob.identity_seed.clone(),
            bob.signed_prekey_secret.clone(),
            None,
            None,
            alice.public_key.clone(),
            agreement.ephemeral_public.clone(),
            agreement.pq_ciphertext.clone(),
        )
        .is_err());

        // The mirror: seed present, ciphertext stripped in relay.
        assert!(crypto_derive_recipient_shared_secret(
            bob.identity_seed,
            bob.signed_prekey_secret,
            None,
            Some(bob.ml_kem_seed),
            alice.public_key,
            agreement.ephemeral_public,
            None,
        )
        .is_err());
    }

    /// A wrong-length field is rejected and the error names it, because these bytes arrive from a
    /// peer's bundle or a relayed prekey message and a caller has to be able to say which.
    #[cfg(feature = "pq")]
    #[test]
    fn a_wrong_length_field_is_refused_and_named() {
        let bob = responder(true);

        let mut bundle = bob.bundle.clone();
        bundle.identity_key.truncate(31);
        let err = crypto_verify_hybrid_bundle(bundle).unwrap_err();
        assert!(err.contains("identity key"), "unhelpful error: {}", err);

        let err = crypto_ml_kem_public_from_seed(vec![0u8; 63]).unwrap_err();
        assert!(err.contains("ML-KEM seed"), "unhelpful error: {}", err);

        let mut ciphertext = vec![0u8; 1087];
        ciphertext[0] = 1;
        let err = crypto_derive_recipient_shared_secret(
            bob.identity_seed,
            bob.signed_prekey_secret,
            None,
            Some(bob.ml_kem_seed),
            bob.bundle.identity_key.clone(),
            vec![0u8; 32],
            Some(ciphertext),
        )
        .unwrap_err();
        assert!(err.contains("ciphertext"), "unhelpful error: {}", err);
    }
}
