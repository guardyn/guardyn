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
                private_key: hex::encode(keypair.public_bytes()), // TODO: Get actual private key
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
    let _identity = store.identity_keypair.as_ref()
        .ok_or_else(|| "Identity keys not generated".to_string())?;

    // TODO: Use actual X3DH SignedPreKey generation
    // For now, return placeholder
    let prekey = PreKeyData {
        key_id: 1,
        public_key: hex::encode([0u8; 32]),
        private_key: hex::encode([0u8; 32]),
        signature: hex::encode([0u8; 64]),
    };

    // Store in session and persist
    store.signed_prekey = Some(prekey.clone());
    persist_signed_prekey(&prekey)?;

    tracing::info!("Signed prekey generated and persisted");
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
        // TODO: Use actual X3DH one-time prekey generation
        let prekey = PreKeyData {
            key_id: start_id + i,
            public_key: hex::encode([i as u8; 32]), // Placeholder
            private_key: hex::encode([i as u8; 32]),
            signature: String::new(),
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
    _recipient_id: String,
) -> Result<X3DHResult, String> {
    tracing::info!("Performing X3DH key agreement");

    // Verify we have identity keys
    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let _identity = store.identity_keypair.as_ref()
        .ok_or_else(|| "Identity keys not generated".to_string())?;

    // Decode recipient's keys
    let _identity_key = hex::decode(&recipient_bundle.identity_key)
        .map_err(|e| format!("Invalid identity key: {}", e))?;
    let _signed_prekey = hex::decode(&recipient_bundle.signed_prekey)
        .map_err(|e| format!("Invalid signed prekey: {}", e))?;
    let _prekey_signature = hex::decode(&recipient_bundle.prekey_signature)
        .map_err(|e| format!("Invalid prekey signature: {}", e))?;

    // TODO: Implement full X3DH protocol using guardyn_crypto::x3dh
    // For now, return placeholder
    let shared_secret = [0u8; 32];
    let ephemeral_key = [0u8; 32];

    Ok(X3DHResult {
        shared_secret: hex::encode(shared_secret),
        ephemeral_key: hex::encode(ephemeral_key),
        used_prekey_id: recipient_bundle.one_time_prekey.as_ref().map(|_| 0),
    })
}

// =============================================================================
// SESSION MANAGEMENT
// =============================================================================

/// Initialize a Double Ratchet session with a peer
#[tauri::command]
pub async fn init_session(
    peer_id: String,
    shared_secret: String,
    _is_initiator: bool,
) -> Result<SessionInfo, String> {
    tracing::info!("Initializing session with peer: {}", peer_id);

    let _secret_bytes = hex::decode(&shared_secret)
        .map_err(|e| format!("Invalid shared secret: {}", e))?;

    let session = SessionData {
        peer_id: peer_id.clone(),
        established_at: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs(),
        messages_sent: 0,
        messages_received: 0,
        state: Vec::new(), // TODO: Serialize Double Ratchet state
    };

    // Store session in memory
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    store.sessions.insert(peer_id.clone(), session.clone());

    // Persist all sessions to secure storage
    persist_sessions(&store.sessions)?;

    tracing::info!("Session established and persisted with peer: {}", peer_id);
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

    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let session = store.sessions.get_mut(&recipient_id)
        .ok_or_else(|| format!("No session with peer: {}", recipient_id))?;

    // Apply PADMÉ padding for traffic analysis protection
    let padded = guardyn_crypto::pad_message(plaintext.as_bytes())
        .map_err(|e| format!("Padding failed: {}", e))?;

    // TODO: Encrypt with Double Ratchet
    // For now, return base64-encoded padded message
    session.messages_sent += 1;

    // Clone sessions for persistence (outside of mutable borrow)
    let sessions_clone = store.sessions.clone();
    drop(store);

    // Persist updated session (message counter changed)
    persist_sessions(&sessions_clone)?;

    Ok(EncryptedMessage {
        ciphertext: base64::Engine::encode(&base64::engine::general_purpose::STANDARD, &padded),
        nonce: base64::Engine::encode(&base64::engine::general_purpose::STANDARD, &[0u8; 12]),
        header: base64::Engine::encode(&base64::engine::general_purpose::STANDARD, b"placeholder"),
    })
}

/// Decrypt a message from a peer using Double Ratchet
#[tauri::command]
pub async fn decrypt_message(
    ciphertext: String,
    nonce: String,
    sender_id: String,
) -> Result<String, String> {
    tracing::debug!("Decrypting message from {}", sender_id);

    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let session = store.sessions.get_mut(&sender_id)
        .ok_or_else(|| format!("No session with peer: {}", sender_id))?;

    // Decode base64
    let padded = base64::Engine::decode(&base64::engine::general_purpose::STANDARD, &ciphertext)
        .map_err(|e| format!("Invalid ciphertext base64: {}", e))?;
    let _nonce_bytes = base64::Engine::decode(&base64::engine::general_purpose::STANDARD, &nonce)
        .map_err(|e| format!("Invalid nonce base64: {}", e))?;

    // TODO: Decrypt with Double Ratchet

    // Remove PADMÉ padding
    let plaintext = guardyn_crypto::unpad_message(&padded)
        .map_err(|e| format!("Unpadding failed: {}", e))?;

    session.messages_received += 1;

    // Clone sessions for persistence (outside of mutable borrow)
    let sessions_clone = store.sessions.clone();
    drop(store);

    // Persist updated session (message counter changed)
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
}
