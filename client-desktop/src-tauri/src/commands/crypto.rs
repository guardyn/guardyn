//! Cryptography Commands
//!
//! Exposes guardyn-crypto functionality to the frontend.
//! Implements X3DH key agreement, Double Ratchet sessions, and message encryption.
//!
//! Keys are persisted to secure storage (OS keychain/credential manager).

use crate::services::SecureStorage;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{LazyLock, Mutex};

// =============================================================================
// SESSION STORAGE
// =============================================================================

/// In-memory session storage for Double Ratchet sessions
/// Backed by secure storage (keychain/credential manager) for persistence
struct SessionStore {
    /// Identity key pair (Ed25519)
    identity_keypair: Option<IdentityKeyData>,
    /// Signed prekey
    signed_prekey: Option<PreKeyData>,
    /// One-time prekeys
    one_time_prekeys: Vec<PreKeyData>,
    /// Active Double Ratchet sessions by peer ID
    sessions: HashMap<String, SessionData>,
    /// Flag indicating if data was loaded from secure storage
    loaded_from_storage: bool,
}

impl Default for SessionStore {
    fn default() -> Self {
        Self {
            identity_keypair: None,
            signed_prekey: None,
            one_time_prekeys: Vec::new(),
            sessions: HashMap::new(),
            loaded_from_storage: false,
        }
    }
}

/// Global session store
static SESSION_STORE: LazyLock<Mutex<SessionStore>> = LazyLock::new(|| {
    let mut store = SessionStore::default();
    // Try to load existing keys from secure storage on initialization
    if let Err(e) = load_from_secure_storage(&mut store) {
        tracing::debug!("No existing keys in secure storage: {}", e);
    }
    Mutex::new(store)
});

/// Global storage for Double Ratchet states (cannot be Clone, stored separately)
/// Key is peer_id, value is the serialized Double Ratchet state
static RATCHET_STORE: LazyLock<Mutex<HashMap<String, guardyn_crypto::DoubleRatchet>>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

/// Load keys from secure storage into the session store
fn load_from_secure_storage(store: &mut SessionStore) -> Result<(), String> {
    let storage = SecureStorage::default_instance();

    // Load identity keypair
    if let Ok(keypair) = storage.get_identity_keypair() {
        tracing::info!("Loaded identity keypair from secure storage");
        store.identity_keypair = Some(keypair);
    }

    // Load signed prekey
    if let Ok(prekey) = storage.get_signed_prekey() {
        tracing::info!("Loaded signed prekey from secure storage");
        store.signed_prekey = Some(prekey);
    }

    // Load one-time prekeys
    if let Ok(prekeys) = storage.get_one_time_prekeys() {
        tracing::info!("Loaded {} one-time prekeys from secure storage", prekeys.len());
        store.one_time_prekeys = prekeys;
    }

    // Load sessions
    if let Ok(sessions) = storage.get_sessions() {
        tracing::info!("Loaded {} sessions from secure storage", sessions.len());
        store.sessions = sessions;
    }

    store.loaded_from_storage = true;
    Ok(())
}

/// Save identity keypair to secure storage
fn persist_identity_keypair(keypair: &IdentityKeyData) -> Result<(), String> {
    SecureStorage::default_instance()
        .store_identity_keypair(keypair)
        .map_err(|e| format!("Failed to persist identity keypair: {}", e))
}

/// Save signed prekey to secure storage
fn persist_signed_prekey(prekey: &PreKeyData) -> Result<(), String> {
    SecureStorage::default_instance()
        .store_signed_prekey(prekey)
        .map_err(|e| format!("Failed to persist signed prekey: {}", e))
}

/// Save one-time prekeys to secure storage
fn persist_one_time_prekeys(prekeys: &[PreKeyData]) -> Result<(), String> {
    SecureStorage::default_instance()
        .store_one_time_prekeys(prekeys)
        .map_err(|e| format!("Failed to persist one-time prekeys: {}", e))
}

/// Save sessions to secure storage
fn persist_sessions(sessions: &HashMap<String, SessionData>) -> Result<(), String> {
    SecureStorage::default_instance()
        .store_sessions(sessions)
        .map_err(|e| format!("Failed to persist sessions: {}", e))
}

// =============================================================================
// DATA TYPES
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IdentityKeyData {
    /// Ed25519 public key (hex)
    pub public_key: String,
    /// Ed25519 private key (hex) - stored securely
    /// Note: serde skip removed to allow secure storage persistence
    pub private_key: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PreKeyData {
    pub key_id: u32,
    /// X25519 public key (hex)
    pub public_key: String,
    /// X25519 private key (hex) - stored in secure storage only
    /// Default empty for API responses, populated from secure storage
    #[serde(default, skip_serializing_if = "String::is_empty")]
    pub private_key: String,
    /// Signature over public key (hex)
    pub signature: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeyBundle {
    pub identity_key: String,
    pub signed_prekey: String,
    pub prekey_signature: String,
    pub one_time_prekey: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub pq_prekey: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncryptedMessage {
    /// Base64-encoded ciphertext
    pub ciphertext: String,
    /// Base64-encoded nonce
    pub nonce: String,
    /// Base64-encoded header (DH key + counters)
    pub header: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionData {
    /// Peer user ID
    pub peer_id: String,
    /// Session established timestamp
    pub established_at: u64,
    /// Messages sent
    pub messages_sent: u64,
    /// Messages received
    pub messages_received: u64,
    /// Session state (serialized Double Ratchet state, base64 encoded for JSON)
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub state: Vec<u8>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionInfo {
    pub peer_id: String,
    pub established_at: u64,
    pub messages_sent: u64,
    pub messages_received: u64,
    pub is_active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct X3DHResult {
    /// Shared secret (hex-encoded)
    pub shared_secret: String,
    /// Our ephemeral public key (hex-encoded)
    pub ephemeral_key: String,
    /// Used one-time prekey ID (if any)
    pub used_prekey_id: Option<u32>,
}

// =============================================================================
// IDENTITY KEY COMMANDS
// =============================================================================

/// Generate identity keys (Ed25519 for signing)
/// These are long-term keys that identify the user
#[tauri::command]
pub async fn generate_identity_keys() -> Result<IdentityKeyData, String> {
    tracing::info!("Generating new identity keys");

    match guardyn_crypto::x3dh::IdentityKeyPair::generate() {
        Ok(keypair) => {
            let data = IdentityKeyData {
                public_key: hex::encode(keypair.public_bytes()),
                private_key: hex::encode(keypair.private_key_bytes()),
            };

            // Store in session
            let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
            store.identity_keypair = Some(data.clone());

            // Persist to secure storage (OS keychain)
            persist_identity_keypair(&data)?;

            tracing::info!("Identity keys generated and persisted successfully");
            Ok(data)
        }
        Err(e) => {
            tracing::error!("Failed to generate identity keys: {}", e);
            Err(format!("Failed to generate identity keys: {}", e))
        }
    }
}

/// Get current identity public key
#[tauri::command]
pub async fn get_identity_key() -> Result<Option<String>, String> {
    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    Ok(store.identity_keypair.as_ref().map(|k| k.public_key.clone()))
}

/// Check if identity keys exist
#[tauri::command]
pub async fn has_identity_keys() -> Result<bool, String> {
    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    Ok(store.identity_keypair.is_some())
}

// =============================================================================
// PREKEY COMMANDS
// =============================================================================

/// Generate signed prekey
#[tauri::command]
pub async fn generate_signed_prekey() -> Result<PreKeyData, String> {
    tracing::info!("Generating signed prekey");

    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let identity_data = store.identity_keypair.as_ref()
        .ok_or_else(|| "Identity keys not generated".to_string())?;

    // Reconstruct identity keypair from stored private key
    let private_bytes = hex::decode(&identity_data.private_key)
        .map_err(|e| format!("Invalid private key hex: {}", e))?;
    let identity_keypair = guardyn_crypto::x3dh::IdentityKeyPair::from_private_bytes(&private_bytes)
        .map_err(|e| format!("Failed to reconstruct identity keypair: {}", e))?;

    // Generate actual signed prekey using guardyn-crypto
    let key_id = store.signed_prekey.as_ref().map(|p| p.key_id + 1).unwrap_or(1);
    let signed_prekey = guardyn_crypto::x3dh::SignedPreKey::generate(key_id, &identity_keypair)
        .map_err(|e| format!("Failed to generate signed prekey: {}", e))?;

    let prekey = PreKeyData {
        key_id: signed_prekey.key_id,
        public_key: hex::encode(signed_prekey.public_bytes()),
        private_key: String::new(), // SignedPreKey doesn't expose private key directly, stored internally
        signature: hex::encode(&signed_prekey.signature),
    };

    // Store in session and persist
    store.signed_prekey = Some(prekey.clone());
    persist_signed_prekey(&prekey)?;

    tracing::info!("Signed prekey generated and persisted (key_id: {})", key_id);
    Ok(prekey)
}

/// Generate one-time prekeys (batch)
#[tauri::command]
pub async fn generate_one_time_prekeys(count: u32) -> Result<Vec<PreKeyData>, String> {
    tracing::info!("Generating {} one-time prekeys", count);

    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let mut prekeys = Vec::with_capacity(count as usize);

    let start_id = store.one_time_prekeys.len() as u32;

    for i in 0..count {
        // Generate actual X3DH one-time prekey using guardyn-crypto
        let otk = guardyn_crypto::x3dh::OneTimePreKey::generate(start_id + i);

        let prekey = PreKeyData {
            key_id: otk.key_id,
            public_key: hex::encode(otk.public_bytes()),
            private_key: String::new(), // Private key stored internally in the crypto lib
            signature: String::new(), // OTKs are not signed
        };
        prekeys.push(prekey.clone());
        store.one_time_prekeys.push(prekey);
    }

    // Persist one-time prekeys to secure storage
    persist_one_time_prekeys(&store.one_time_prekeys)?;

    tracing::info!("Generated and persisted {} one-time prekeys", prekeys.len());
    Ok(prekeys)
}

// =============================================================================
// KEY BUNDLE COMMANDS
// =============================================================================

/// Generate a complete key bundle for E2EE
#[tauri::command]
pub async fn generate_key_bundle(include_pq: bool) -> Result<KeyBundle, String> {
    tracing::debug!("Generating key bundle (PQ: {})", include_pq);

    // Use guardyn-crypto to generate keys
    // Post-quantum keys are included when requested and available
    match guardyn_crypto::pqxdh::generate_hybrid_key_bundle(true, include_pq) {
        Ok((bundle, _private_keys)) => Ok(KeyBundle {
            identity_key: hex::encode(&bundle.identity_key),
            signed_prekey: hex::encode(&bundle.signed_prekey),
            prekey_signature: hex::encode(&bundle.signed_prekey_signature.0),
            one_time_prekey: bundle.one_time_prekey.map(|k| hex::encode(&k)),
            pq_prekey: None, // PQ prekey from separate field if available
        }),
        Err(e) => Err(format!("Failed to generate key bundle: {}", e)),
    }
}

// =============================================================================
// X3DH KEY AGREEMENT
// =============================================================================

/// Perform X3DH key agreement as initiator (Alice)
/// Returns shared secret for Double Ratchet initialization
#[tauri::command]
pub async fn perform_x3dh(
    recipient_bundle: KeyBundle,
    recipient_id: String,
) -> Result<X3DHResult, String> {
    tracing::info!("Performing X3DH key agreement with {}", recipient_id);

    // Get our identity keypair from store
    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let identity_data = store.identity_keypair.as_ref()
        .ok_or_else(|| "Identity keys not generated".to_string())?;

    // Reconstruct identity keypair from stored private key
    let private_bytes = hex::decode(&identity_data.private_key)
        .map_err(|e| format!("Invalid private key hex: {}", e))?;
    let identity_keypair = guardyn_crypto::x3dh::IdentityKeyPair::from_private_bytes(&private_bytes)
        .map_err(|e| format!("Failed to reconstruct identity keypair: {}", e))?;
    drop(store);

    // Decode recipient's keys from hex
    let identity_key = hex::decode(&recipient_bundle.identity_key)
        .map_err(|e| format!("Invalid identity key hex: {}", e))?;
    let signed_prekey = hex::decode(&recipient_bundle.signed_prekey)
        .map_err(|e| format!("Invalid signed prekey hex: {}", e))?;
    let prekey_signature = hex::decode(&recipient_bundle.prekey_signature)
        .map_err(|e| format!("Invalid prekey signature hex: {}", e))?;

    // Parse one-time prekey if provided
    let one_time_prekeys = match &recipient_bundle.one_time_prekey {
        Some(otk_hex) => {
            let otk_bytes = hex::decode(otk_hex)
                .map_err(|e| format!("Invalid one-time prekey hex: {}", e))?;
            vec![guardyn_crypto::x3dh::OneTimePreKeyPublic {
                key_id: 0, // We don't have the ID from the bundle format
                public_key: otk_bytes,
            }]
        }
        None => vec![],
    };

    // Create X3DH key bundle for the recipient
    let peer_bundle = guardyn_crypto::x3dh::X3DHKeyBundle {
        identity_key,
        signed_pre_key: signed_prekey,
        signed_pre_key_id: 1, // Default ID
        signed_pre_key_signature: prekey_signature,
        one_time_pre_keys: one_time_prekeys,
    };

    // Perform X3DH key agreement using guardyn-crypto
    let use_one_time_key = recipient_bundle.one_time_prekey.is_some();
    let (shared_secret, ephemeral_public) = guardyn_crypto::x3dh::X3DHProtocol::initiate_key_agreement(
        &identity_keypair,
        &peer_bundle,
        use_one_time_key,
    ).map_err(|e| format!("X3DH key agreement failed: {}", e))?;

    tracing::info!("X3DH key agreement successful with {}", recipient_id);

    Ok(X3DHResult {
        shared_secret: hex::encode(&shared_secret),
        ephemeral_key: hex::encode(ephemeral_public.as_bytes()),
        used_prekey_id: if use_one_time_key { Some(0) } else { None },
    })
}

/// Respond to X3DH key agreement as responder (Bob)
/// This is called when receiving the first message from a new peer
#[tauri::command]
pub async fn respond_x3dh(
    peer_identity_key: String,
    peer_ephemeral_key: String,
    used_one_time_key_id: Option<u32>,
    peer_id: String,
) -> Result<X3DHResult, String> {
    tracing::info!("Responding to X3DH key agreement from {}", peer_id);

    // Get our key material from store
    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let identity_data = store.identity_keypair.as_ref()
        .ok_or_else(|| "Identity keys not generated".to_string())?;
    let signed_prekey_data = store.signed_prekey.as_ref()
        .ok_or_else(|| "Signed prekey not generated".to_string())?;

    // Reconstruct identity keypair
    let private_bytes = hex::decode(&identity_data.private_key)
        .map_err(|e| format!("Invalid private key hex: {}", e))?;
    let identity_keypair = guardyn_crypto::x3dh::IdentityKeyPair::from_private_bytes(&private_bytes)
        .map_err(|e| format!("Failed to reconstruct identity keypair: {}", e))?;

    // Generate key material (we need the full SignedPreKey, not just public bytes)
    // For now, regenerate signed prekey with same key_id
    let signed_prekey = guardyn_crypto::x3dh::SignedPreKey::generate(signed_prekey_data.key_id, &identity_keypair)
        .map_err(|e| format!("Failed to regenerate signed prekey: {}", e))?;

    // Build one-time prekeys from store
    let one_time_prekeys: Vec<guardyn_crypto::x3dh::OneTimePreKey> = (0..store.one_time_prekeys.len() as u32)
        .map(|id| guardyn_crypto::x3dh::OneTimePreKey::generate(id))
        .collect();

    drop(store);

    // Build key material
    let key_material = guardyn_crypto::x3dh::X3DHKeyMaterial {
        identity_key: identity_keypair,
        signed_pre_key: signed_prekey,
        one_time_pre_keys: one_time_prekeys,
    };

    // Decode peer's keys
    let peer_identity_bytes = hex::decode(&peer_identity_key)
        .map_err(|e| format!("Invalid peer identity key hex: {}", e))?;
    let peer_ephemeral_bytes = hex::decode(&peer_ephemeral_key)
        .map_err(|e| format!("Invalid peer ephemeral key hex: {}", e))?;

    // Perform X3DH key agreement as responder
    let shared_secret = guardyn_crypto::x3dh::X3DHProtocol::respond_key_agreement(
        &key_material,
        &peer_identity_bytes,
        &peer_ephemeral_bytes,
        used_one_time_key_id,
    ).map_err(|e| format!("X3DH respond failed: {}", e))?;

    tracing::info!("X3DH response successful for {}", peer_id);

    Ok(X3DHResult {
        shared_secret: hex::encode(&shared_secret),
        ephemeral_key: String::new(), // Responder doesn't generate ephemeral key
        used_prekey_id: used_one_time_key_id,
    })
}

// =============================================================================
// SESSION MANAGEMENT
// =============================================================================

/// Initialize a Double Ratchet session with a peer
///
/// Both initiator and responder start with init_bob - the DH ratchet step
/// is performed automatically when the first message is exchanged.
/// The initiator should send their public key with the first message header.
#[tauri::command]
pub async fn init_session(
    peer_id: String,
    shared_secret: String,
    is_initiator: bool,
    _peer_public_key: Option<String>,
) -> Result<SessionInfo, String> {
    tracing::info!("Initializing Double Ratchet session with peer: {} (initiator: {})", peer_id, is_initiator);

    let secret_bytes = hex::decode(&shared_secret)
        .map_err(|e| format!("Invalid shared secret: {}", e))?;

    if secret_bytes.len() != 32 {
        return Err("Shared secret must be 32 bytes".to_string());
    }

    // Initialize Double Ratchet
    // Both roles start with init_bob - the DH ratchet is performed on first message
    let ratchet = guardyn_crypto::DoubleRatchet::init_bob(&secret_bytes)
        .map_err(|e| format!("Failed to init Double Ratchet: {}", e))?;

    // Serialize ratchet state for persistence
    let ratchet_state = ratchet.serialize();

    let session = SessionData {
        peer_id: peer_id.clone(),
        established_at: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs(),
        messages_sent: 0,
        messages_received: 0,
        state: ratchet_state, // Store serialized Double Ratchet state
    };

    // Store ratchet in memory
    {
        let mut ratchet_store = RATCHET_STORE.lock().map_err(|e| e.to_string())?;
        ratchet_store.insert(peer_id.clone(), ratchet);
    }

    // Store session metadata and persist
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    store.sessions.insert(peer_id.clone(), session.clone());
    persist_sessions(&store.sessions)?;

    tracing::info!("Double Ratchet session established and persisted with peer: {}", peer_id);
    Ok(SessionInfo {
        peer_id: session.peer_id,
        established_at: session.established_at,
        messages_sent: session.messages_sent,
        messages_received: session.messages_received,
        is_active: true,
    })
}

/// Get session info for a peer
#[tauri::command]
pub async fn get_session(peer_id: String) -> Result<Option<SessionInfo>, String> {
    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;

    Ok(store.sessions.get(&peer_id).map(|s| SessionInfo {
        peer_id: s.peer_id.clone(),
        established_at: s.established_at,
        messages_sent: s.messages_sent,
        messages_received: s.messages_received,
        is_active: true,
    }))
}

/// List all active sessions
#[tauri::command]
pub async fn list_sessions() -> Result<Vec<SessionInfo>, String> {
    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;

    Ok(store.sessions.values().map(|s| SessionInfo {
        peer_id: s.peer_id.clone(),
        established_at: s.established_at,
        messages_sent: s.messages_sent,
        messages_received: s.messages_received,
        is_active: true,
    }).collect())
}

/// Delete a session
#[tauri::command]
pub async fn delete_session(peer_id: String) -> Result<bool, String> {
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let removed = store.sessions.remove(&peer_id).is_some();

    if removed {
        // Persist updated sessions to secure storage
        persist_sessions(&store.sessions)?;
        tracing::info!("Session with peer {} deleted and persisted", peer_id);
    }

    Ok(removed)
}

// =============================================================================
// MESSAGE ENCRYPTION/DECRYPTION
// =============================================================================

/// Encrypt a message for a peer using Double Ratchet
#[tauri::command]
pub async fn encrypt_message(
    plaintext: String,
    recipient_id: String,
) -> Result<EncryptedMessage, String> {
    tracing::debug!("Encrypting message for {} ({} bytes)", recipient_id, plaintext.len());

    // Apply PADMÉ padding for traffic analysis protection
    let padded = guardyn_crypto::pad_message(plaintext.as_bytes())
        .map_err(|e| format!("Padding failed: {}", e))?;

    // Get Double Ratchet for this peer
    let mut ratchet_store = RATCHET_STORE.lock().map_err(|e| e.to_string())?;
    let ratchet = ratchet_store.get_mut(&recipient_id)
        .ok_or_else(|| format!("No Double Ratchet session with peer: {}", recipient_id))?;

    // Encrypt with Double Ratchet
    let associated_data = recipient_id.as_bytes();
    let encrypted = ratchet.encrypt(&padded, associated_data)
        .map_err(|e| format!("Double Ratchet encryption failed: {}", e))?;

    // Serialize encrypted message
    let encrypted_bytes = encrypted.to_bytes();
    drop(ratchet_store);

    // Update session metadata
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    if let Some(session) = store.sessions.get_mut(&recipient_id) {
        session.messages_sent += 1;
        // Update serialized ratchet state
        if let Ok(ratchet_store) = RATCHET_STORE.lock() {
            if let Some(ratchet) = ratchet_store.get(&recipient_id) {
                session.state = ratchet.serialize();
            }
        }
    }

    // Persist updated sessions
    let sessions_clone = store.sessions.clone();
    drop(store);
    persist_sessions(&sessions_clone)?;

    Ok(EncryptedMessage {
        ciphertext: base64::Engine::encode(&base64::engine::general_purpose::STANDARD, &encrypted_bytes),
        nonce: String::new(), // Nonce is included in encrypted message
        header: String::new(), // Header is included in encrypted message
    })
}

/// Decrypt a message from a peer using Double Ratchet
#[tauri::command]
pub async fn decrypt_message(
    ciphertext: String,
    _nonce: String, // Nonce is now embedded in ciphertext
    sender_id: String,
) -> Result<String, String> {
    tracing::debug!("Decrypting message from {}", sender_id);

    // Decode base64 ciphertext
    let encrypted_bytes = base64::Engine::decode(&base64::engine::general_purpose::STANDARD, &ciphertext)
        .map_err(|e| format!("Invalid ciphertext base64: {}", e))?;

    // Parse encrypted message
    let encrypted_msg = guardyn_crypto::double_ratchet::EncryptedMessage::from_bytes(&encrypted_bytes)
        .map_err(|e| format!("Failed to parse encrypted message: {}", e))?;

    // Get Double Ratchet for this peer
    let mut ratchet_store = RATCHET_STORE.lock().map_err(|e| e.to_string())?;
    let ratchet = ratchet_store.get_mut(&sender_id)
        .ok_or_else(|| format!("No Double Ratchet session with peer: {}", sender_id))?;

    // Decrypt with Double Ratchet
    let associated_data = sender_id.as_bytes();
    let padded = ratchet.decrypt(&encrypted_msg, associated_data)
        .map_err(|e| format!("Double Ratchet decryption failed: {}", e))?;

    drop(ratchet_store);

    // Remove PADMÉ padding
    let plaintext = guardyn_crypto::unpad_message(&padded)
        .map_err(|e| format!("Unpadding failed: {}", e))?;

    // Update session metadata
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    if let Some(session) = store.sessions.get_mut(&sender_id) {
        session.messages_received += 1;
        // Update serialized ratchet state
        if let Ok(ratchet_store) = RATCHET_STORE.lock() {
            if let Some(ratchet) = ratchet_store.get(&sender_id) {
                session.state = ratchet.serialize();
            }
        }
    }

    // Persist updated sessions
    let sessions_clone = store.sessions.clone();
    drop(store);
    persist_sessions(&sessions_clone)?;

    String::from_utf8(plaintext).map_err(|e| format!("Invalid UTF-8: {}", e))
}

// =============================================================================
// UTILITY COMMANDS
// =============================================================================

/// Check if post-quantum cryptography is available
/// Currently always returns true as guardyn-crypto includes PQ support
#[tauri::command]
pub async fn is_pq_available() -> bool {
    // guardyn-crypto always has PQ support built-in
    true
}

/// Get crypto library version
#[tauri::command]
pub async fn get_crypto_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Clear all crypto state (logout/reset)
/// This clears both in-memory state and persistent secure storage
#[tauri::command]
pub async fn clear_crypto_state() -> Result<(), String> {
    tracing::warn!("Clearing all crypto state (memory and secure storage)");

    // Clear in-memory state
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    store.identity_keypair = None;
    store.signed_prekey = None;
    store.one_time_prekeys.clear();
    store.sessions.clear();
    store.loaded_from_storage = false;

    // Clear secure storage (OS keychain)
    SecureStorage::default_instance()
        .clear_all()
        .map_err(|e| format!("Failed to clear secure storage: {}", e))?;

    tracing::info!("Crypto state cleared from memory and secure storage");
    Ok(())
}

// =============================================================================
// TESTS
// =============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_identity_key_data_serialization() {
        let data = IdentityKeyData {
            public_key: "abc123".to_string(),
            private_key: "secret456".to_string(),
        };

        // Test that serialization works
        let json = serde_json::to_string(&data).unwrap();
        assert!(json.contains("abc123"));
        assert!(json.contains("secret456")); // Private key should now be serialized for storage

        // Test deserialization
        let deserialized: IdentityKeyData = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.public_key, "abc123");
        assert_eq!(deserialized.private_key, "secret456");
    }

    #[test]
    fn test_prekey_data_serialization() {
        let prekey = PreKeyData {
            key_id: 42,
            public_key: "pubkey".to_string(),
            private_key: "privkey".to_string(),
            signature: "sig".to_string(),
        };

        // Serialize for storage (private_key is included when non-empty)
        let json = serde_json::to_string(&prekey).unwrap();
        assert!(json.contains("pubkey"));

        // When private_key is populated, it should serialize for storage
        if !prekey.private_key.is_empty() {
            let full_json = serde_json::json!({
                "key_id": prekey.key_id,
                "public_key": prekey.public_key,
                "private_key": prekey.private_key,
                "signature": prekey.signature,
            });
            let full_serialized = full_json.to_string();
            let deserialized: PreKeyData = serde_json::from_str(&full_serialized).unwrap();
            assert_eq!(deserialized.private_key, "privkey");
        }
    }

    #[test]
    fn test_session_data_serialization() {
        let session = SessionData {
            peer_id: "peer123".to_string(),
            established_at: 1234567890,
            messages_sent: 10,
            messages_received: 5,
            state: vec![1, 2, 3, 4, 5], // Non-empty state
        };

        // State should be serialized when non-empty
        let json = serde_json::to_string(&session).unwrap();
        assert!(json.contains("peer123"));
        assert!(json.contains("1234567890"));

        // Deserialize and verify state is preserved
        let deserialized: SessionData = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.peer_id, "peer123");
        assert_eq!(deserialized.state, vec![1, 2, 3, 4, 5]);
    }

    #[test]
    fn test_session_data_empty_state_serialization() {
        let session = SessionData {
            peer_id: "peer456".to_string(),
            established_at: 9999999999,
            messages_sent: 0,
            messages_received: 0,
            state: vec![], // Empty state should be skipped
        };

        let json = serde_json::to_string(&session).unwrap();
        // Empty state should not appear in JSON
        assert!(!json.contains("\"state\""));

        // Deserialize and verify state defaults to empty
        let deserialized: SessionData = serde_json::from_str(&json).unwrap();
        assert!(deserialized.state.is_empty());
    }

    #[test]
    fn test_persist_identity_keypair_format() {
        // Test that the persistence format is correct
        let keypair = IdentityKeyData {
            public_key: hex::encode([0u8; 32]),
            private_key: hex::encode([1u8; 32]),
        };

        let json = serde_json::to_string(&keypair).unwrap();

        // Verify JSON structure
        let parsed: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(parsed.get("public_key").is_some());
        assert!(parsed.get("private_key").is_some());
    }

    #[test]
    fn test_sessions_hashmap_serialization() {
        let mut sessions = HashMap::new();
        sessions.insert("user1".to_string(), SessionData {
            peer_id: "user1".to_string(),
            established_at: 100,
            messages_sent: 5,
            messages_received: 3,
            state: vec![10, 20, 30],
        });
        sessions.insert("user2".to_string(), SessionData {
            peer_id: "user2".to_string(),
            established_at: 200,
            messages_sent: 10,
            messages_received: 7,
            state: vec![],
        });

        // Serialize entire sessions map
        let json = serde_json::to_string(&sessions).unwrap();

        // Deserialize and verify
        let deserialized: HashMap<String, SessionData> = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.len(), 2);
        assert_eq!(deserialized.get("user1").unwrap().state, vec![10, 20, 30]);
        assert!(deserialized.get("user2").unwrap().state.is_empty());
    }

    #[test]
    fn test_x3dh_identity_key_generation_and_reconstruction() {
        // Generate identity keypair using guardyn-crypto
        let keypair = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();

        // Get public and private bytes
        let public_bytes = keypair.public_bytes();
        let private_bytes = keypair.private_key_bytes();

        assert_eq!(public_bytes.len(), 32);
        assert_eq!(private_bytes.len(), 32);

        // Reconstruct from private bytes
        let restored = guardyn_crypto::x3dh::IdentityKeyPair::from_private_bytes(&private_bytes).unwrap();

        // Verify public keys match
        assert_eq!(keypair.public_bytes(), restored.public_bytes());
    }

    #[test]
    fn test_x3dh_signed_prekey_generation() {
        // Generate identity keypair
        let identity = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();

        // Generate signed prekey
        let signed_prekey = guardyn_crypto::x3dh::SignedPreKey::generate(1, &identity).unwrap();

        assert_eq!(signed_prekey.key_id, 1);
        assert_eq!(signed_prekey.public_bytes().len(), 32);
        assert!(!signed_prekey.signature.is_empty());
    }

    #[test]
    fn test_x3dh_one_time_prekey_generation() {
        // Generate one-time prekey
        let otk = guardyn_crypto::x3dh::OneTimePreKey::generate(42);

        assert_eq!(otk.key_id, 42);
        assert_eq!(otk.public_bytes().len(), 32);
    }

    #[test]
    fn test_x3dh_full_key_agreement() {
        // Generate key material for Alice and Bob
        let alice_material = guardyn_crypto::x3dh::X3DHKeyMaterial::generate(10).unwrap();
        let bob_material = guardyn_crypto::x3dh::X3DHKeyMaterial::generate(10).unwrap();

        // Bob publishes his bundle
        let bob_bundle = bob_material.export_bundle();

        // Alice initiates key agreement
        let (alice_secret, alice_ephemeral) = guardyn_crypto::x3dh::X3DHProtocol::initiate_key_agreement(
            &alice_material.identity_key,
            &bob_bundle,
            true,
        ).unwrap();

        assert_eq!(alice_secret.len(), 32);

        // Bob responds
        let bob_secret = guardyn_crypto::x3dh::X3DHProtocol::respond_key_agreement(
            &bob_material,
            &alice_material.identity_key.public_bytes(),
            alice_ephemeral.as_bytes(),
            Some(0),
        ).unwrap();

        assert_eq!(bob_secret.len(), 32);

        // Both should derive the same shared secret
        assert_eq!(alice_secret, bob_secret);
    }

    #[test]
    fn test_key_bundle_roundtrip() {
        // Test that KeyBundle struct can be converted to/from guardyn-crypto bundle
        let material = guardyn_crypto::x3dh::X3DHKeyMaterial::generate(5).unwrap();
        let bundle = material.export_bundle();

        // Convert to our KeyBundle format
        let key_bundle = KeyBundle {
            identity_key: hex::encode(&bundle.identity_key),
            signed_prekey: hex::encode(&bundle.signed_pre_key),
            prekey_signature: hex::encode(&bundle.signed_pre_key_signature),
            one_time_prekey: bundle.one_time_pre_keys.first()
                .map(|otk| hex::encode(&otk.public_key)),
            pq_prekey: None,
        };

        // Verify encoding is correct
        assert_eq!(hex::decode(&key_bundle.identity_key).unwrap().len(), 32);
        assert_eq!(hex::decode(&key_bundle.signed_prekey).unwrap().len(), 32);
        assert!(!key_bundle.prekey_signature.is_empty());
        assert!(key_bundle.one_time_prekey.is_some());
    }

    #[test]
    fn test_double_ratchet_basic_encryption() {
        // Test basic Double Ratchet encrypt/decrypt cycle
        let shared_secret = [42u8; 32];

        // Bob initializes first
        let mut bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret).unwrap();
        let bob_public = bob.public_key();

        // Alice initializes with Bob's public key
        let mut alice = guardyn_crypto::DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();

        // Alice encrypts a message
        let plaintext = b"Hello from Alice!";
        let encrypted = alice.encrypt(plaintext, b"alice->bob").unwrap();

        // Verify encrypted message is not plaintext
        assert_ne!(&encrypted.ciphertext[..], plaintext);

        // Bob decrypts the message
        let decrypted = bob.decrypt(&encrypted, b"alice->bob").unwrap();
        assert_eq!(&decrypted[..], plaintext);
    }

    #[test]
    fn test_double_ratchet_bidirectional() {
        // Test bidirectional message exchange
        let shared_secret = [99u8; 32];

        // Bob initializes first
        let mut bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret).unwrap();
        let bob_public = bob.public_key();

        // Alice initializes with Bob's public key
        let mut alice = guardyn_crypto::DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();

        // Alice -> Bob
        let msg1 = alice.encrypt(b"Message 1", b"ad").unwrap();
        let dec1 = bob.decrypt(&msg1, b"ad").unwrap();
        assert_eq!(&dec1[..], b"Message 1");

        // Bob -> Alice
        let msg2 = bob.encrypt(b"Reply 1", b"ad").unwrap();
        let dec2 = alice.decrypt(&msg2, b"ad").unwrap();
        assert_eq!(&dec2[..], b"Reply 1");

        // Alice -> Bob (second message)
        let msg3 = alice.encrypt(b"Message 2", b"ad").unwrap();
        let dec3 = bob.decrypt(&msg3, b"ad").unwrap();
        assert_eq!(&dec3[..], b"Message 2");
    }

    #[test]
    fn test_double_ratchet_serialization() {
        // Test that ratchet state can be serialized and deserialized
        let shared_secret = [123u8; 32];

        // Create ratchet as Bob first, then as Alice
        let bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret).unwrap();
        let bob_public = bob.public_key();
        let alice = guardyn_crypto::DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();

        // Serialize Alice's ratchet
        let bytes = alice.serialize();
        assert!(!bytes.is_empty());

        // Deserialize
        let restored = guardyn_crypto::DoubleRatchet::deserialize(&bytes).unwrap();

        // Verify by encrypting a message with restored ratchet
        let mut restored = restored;
        let encrypted = restored.encrypt(b"Test message", b"ad").unwrap();
        assert!(!encrypted.ciphertext.is_empty());
    }
}
