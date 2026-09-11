//! Cryptography Commands
//!
//! Exposes guardyn-crypto functionality to the frontend.
//! Implements X3DH key agreement, Double Ratchet sessions, and message encryption.
//!
//! Keys are persisted to secure storage (OS keychain/credential manager).

use crate::services::SecureStorage;
use crate::state::AppState;
use serde::{Deserialize, Serialize};
use tauri::State;
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
/// Key is peer_id, value is the live Double Ratchet.
///
/// Rehydrated from `SessionData.state` by `load_from_secure_storage`. It used to start empty
/// and never be populated, while the metadata beside it *was* restored - so after a restart
/// `get_session` reported an active session and every send failed with "no Double Ratchet
/// session". A session the UI shows as present and that refuses every message is worse than no
/// session, which would at least trigger a fresh key agreement.
static RATCHET_STORE: LazyLock<Mutex<HashMap<String, guardyn_crypto::DoubleRatchet>>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

/// The X3DH prekey message an initiator owes its peer, keyed by peer id.
///
/// A responder cannot complete X3DH without the initiator's identity key, ephemeral key and the
/// id of the one-time pre-key it consumed. Those travel once, on the first message of a
/// session, in `SendMessageRequest.x3dh_prekey`.
///
/// In memory only, and deliberately so: it is derivable from a session that already exists, and
/// it is owed for exactly as long as it takes one message to send. If the process ends first
/// the peer never received anything to answer, so both sides start again from nothing.
static PENDING_PREKEY: LazyLock<Mutex<HashMap<String, String>>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

/// The prekey message owed to `peer_id`, if any. Does not consume it - see
/// [`clear_pending_prekey`].
pub(crate) fn peek_pending_prekey(peer_id: &str) -> Option<String> {
    PENDING_PREKEY.lock().ok()?.get(peer_id).cloned()
}

/// Drop the prekey message owed to `peer_id`, once a message carrying it has actually been
/// accepted by the server.
///
/// Clearing on send rather than on attach is what makes a failed send retryable. Re-sending it
/// is harmless: a responder that already has a session ignores the prekey message.
pub(crate) fn clear_pending_prekey(peer_id: &str) {
    if let Ok(mut pending) = PENDING_PREKEY.lock() {
        pending.remove(peer_id);
    }
}

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

    // Load sessions, and rehydrate the ratchet each one carries.
    if let Ok(sessions) = storage.get_sessions() {
        tracing::info!("Loaded {} sessions from secure storage", sessions.len());
        let (restored, ratchets) = rehydrate_ratchets(sessions);
        match RATCHET_STORE.lock() {
            Ok(mut guard) => {
                guard.extend(ratchets);
                store.sessions = restored;
            }
            Err(e) => {
                // Without the ratchets the metadata is the exact half-state this step removes.
                tracing::error!("Ratchet store is poisoned, starting with no sessions: {}", e);
            }
        }
    }

    store.loaded_from_storage = true;
    Ok(())
}

/// Restore every stored ratchet into `RATCHET_STORE`, returning the sessions worth keeping.
///
/// A session is dropped - rather than kept without its ratchet - in three cases: its state is
/// empty, it fails to deserialize, or it deserializes into a ratchet that cannot send. The
/// last is the subtle one. A responder has no sending chain key until its first `decrypt`
/// performs the DH ratchet, so a ratchet can be well-formed and still unable to send a single
/// message. `client-mobile` learned this and deletes such a session so a fresh X3DH runs
/// (`crypto_service.dart:508-513`); keeping it would resurrect a half-session that fails on
/// every send while looking established.
///
/// Dropping the metadata alongside the ratchet is the point: the two must agree, and it was
/// their disagreement that produced a session the UI reported as active and that refused
/// everything.
#[allow(clippy::type_complexity)]
fn rehydrate_ratchets(
    sessions: HashMap<String, SessionData>,
) -> (
    HashMap<String, SessionData>,
    HashMap<String, guardyn_crypto::DoubleRatchet>,
) {
    let mut restored = HashMap::with_capacity(sessions.len());
    let mut ratchets = HashMap::with_capacity(sessions.len());

    for (peer_id, session) in sessions {
        if session.state.is_empty() {
            tracing::warn!("Session has no stored ratchet state, dropping it");
            continue;
        }
        match guardyn_crypto::DoubleRatchet::deserialize(&session.state) {
            Ok(ratchet) if ratchet.can_send() => {
                ratchets.insert(peer_id.clone(), ratchet);
                restored.insert(peer_id, session);
            }
            Ok(_) => {
                tracing::warn!(
                    "Stored session cannot send - it was persisted before its first decrypt \
                     completed the ratchet. Dropping it so a fresh key agreement runs."
                );
            }
            Err(e) => {
                // No key material in the message: `CryptoError` reports shape, not content.
                tracing::warn!("Stored ratchet state could not be restored: {}", e);
            }
        }
    }

    tracing::info!("Restored {} ratchet session(s)", restored.len());
    (restored, ratchets)
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

/// The public half of a pre-key - everything the frontend is allowed to see.
///
/// [`PreKeyData`] serves two destinations with one serde impl: the OS credential manager,
/// which must receive `private_key`, and the frontend, which must not. It was safe only while
/// `private_key` was always empty and `skip_serializing_if` dropped it. Now that the secret is
/// retained, returning `PreKeyData` from a command would hand it to the renderer, where it
/// would sit in JS memory and reachable from a devtools console or a crash dump.
///
/// The shape is unchanged from the frontend's side: `src/api/crypto.ts` already declares
/// exactly these three fields.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublicPreKeyData {
    pub key_id: u32,
    pub public_key: String,
    pub signature: String,
}

impl From<&PreKeyData> for PublicPreKeyData {
    fn from(data: &PreKeyData) -> Self {
        Self {
            key_id: data.key_id,
            public_key: data.public_key.clone(),
            signature: data.signature.clone(),
        }
    }
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
pub async fn generate_signed_prekey() -> Result<PublicPreKeyData, String> {
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
        // Retained, not dropped. The comment here used to claim `SignedPreKey` kept the secret
        // internally; it does not - the struct is a value holding a `StaticSecret` that dies
        // with it. Publishing a pre-key whose private half no one kept means no peer can ever
        // be answered.
        private_key: hex::encode(signed_prekey.ratchet_secret().to_bytes()),
        signature: hex::encode(&signed_prekey.signature),
    };

    // Store in session and persist
    let public = PublicPreKeyData::from(&prekey);
    store.signed_prekey = Some(prekey.clone());
    persist_signed_prekey(&prekey)?;

    tracing::info!("Signed prekey generated and persisted (key_id: {})", key_id);
    Ok(public)
}

/// Generate one-time prekeys (batch)
#[tauri::command]
pub async fn generate_one_time_prekeys(count: u32) -> Result<Vec<PublicPreKeyData>, String> {
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
            private_key: hex::encode(otk.secret().to_bytes()),
            signature: String::new(), // OTKs are not signed
        };
        prekeys.push(PublicPreKeyData::from(&prekey));
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

/// How many one-time pre-keys a published bundle carries.
///
/// Ten, not the hundred `X3DHProtocol::generate_key_bundle` uses, because every private half
/// is now kept and the pool is stored as one blob in the OS credential manager. Windows caps a
/// credential at 2560 bytes, which a hundred retained keys clear several times over - and a
/// pool that cannot be persisted is worse than a small one, because the keys it names are
/// published and unanswerable.
///
/// Nothing is lost today: `GetKeyBundle` scans and returns the whole set without consuming
/// any, so every initiator is served index `0` for ever and the other ninety-nine were never
/// reachable. Growing the pool belongs with the step that makes the server consume a key, and
/// with `UploadPreKeys` replenishment - which is only safe to call as of #243.
const PUBLISHED_ONE_TIME_PREKEY_COUNT: usize = 10;

/// The one-time pre-key count a published bundle carries.
pub(crate) fn published_one_time_prekey_count() -> usize {
    PUBLISHED_ONE_TIME_PREKEY_COUNT
}

/// Build the key material for a bundle, and the storable records that carry its private
/// halves. Pure: no keychain, no global store, so the "what we published is what we kept"
/// property can be tested without an OS credential manager.
///
/// Returns the bundle to publish, the signed pre-key record, and the one-time pre-key records.
#[allow(clippy::type_complexity)]
fn build_key_material(
    identity_keypair: &guardyn_crypto::x3dh::IdentityKeyPair,
    signed_prekey_id: u32,
    one_time_count: usize,
) -> Result<
    (
        guardyn_crypto::x3dh::X3DHKeyBundle,
        PreKeyData,
        Vec<PreKeyData>,
    ),
    String,
> {
    let signed_prekey =
        guardyn_crypto::x3dh::SignedPreKey::generate(signed_prekey_id, identity_keypair)
            .map_err(|e| format!("Failed to generate signed prekey: {}", e))?;

    let signed_prekey_data = PreKeyData {
        key_id: signed_prekey.key_id,
        public_key: hex::encode(signed_prekey.public_bytes()),
        private_key: hex::encode(signed_prekey.ratchet_secret().to_bytes()),
        signature: hex::encode(&signed_prekey.signature),
    };

    // Ids are zero-based and contiguous because `common.KeyBundle` carries no key ids at all:
    // an initiator reports the id as the index the key occupied in the published array
    // (auth-service `db.rs` assigns them with `.enumerate()`), so index and id must agree or
    // DH4 is computed against the wrong key.
    let mut one_time_prekeys = Vec::with_capacity(one_time_count);
    let mut one_time_data = Vec::with_capacity(one_time_count);
    for id in 0..one_time_count as u32 {
        let otk = guardyn_crypto::x3dh::OneTimePreKey::generate(id);
        one_time_data.push(PreKeyData {
            key_id: otk.key_id,
            public_key: hex::encode(otk.public_bytes()),
            private_key: hex::encode(otk.secret().to_bytes()),
            signature: String::new(),
        });
        one_time_prekeys.push(otk);
    }

    let material = guardyn_crypto::x3dh::X3DHKeyMaterial {
        identity_key: identity_keypair.clone(),
        signed_pre_key: signed_prekey,
        one_time_pre_keys: one_time_prekeys,
    };

    Ok((material.export_bundle(), signed_prekey_data, one_time_data))
}

/// Generate a publishable key bundle and keep every private half.
///
/// This is the single generator for the material a peer will run X3DH against. It exists
/// because there were three, none wired to the others, and the one that published
/// (`commands::auth::generate_key_bundle`) called `X3DHProtocol::generate_key_bundle()` - which
/// mints a whole fresh key set, identity key included, and returns only the public bundle.
///
/// The consequence was worse than dropped pre-key secrets: the identity key the server served
/// for this user was not the identity key on the device. A peer verified the bundle against a
/// key this client had never held, and the client could not have answered even if it had kept
/// the pre-keys.
///
/// The identity keypair is loaded from secure storage and only generated when absent, so
/// re-publishing on a later login keeps the account's identity stable.
pub(crate) fn generate_and_persist_key_bundle(
    one_time_count: usize,
) -> Result<guardyn_crypto::x3dh::X3DHKeyBundle, String> {
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;

    let identity_keypair = match store.identity_keypair.as_ref() {
        Some(data) => {
            let private_bytes = hex::decode(&data.private_key)
                .map_err(|e| format!("Invalid stored identity private key: {}", e))?;
            guardyn_crypto::x3dh::IdentityKeyPair::from_private_bytes(&private_bytes)
                .map_err(|e| format!("Failed to restore identity keypair: {}", e))?
        }
        None => {
            let keypair = guardyn_crypto::x3dh::IdentityKeyPair::generate()
                .map_err(|e| format!("Failed to generate identity keys: {}", e))?;
            let data = IdentityKeyData {
                public_key: hex::encode(keypair.public_bytes()),
                private_key: hex::encode(keypair.private_key_bytes()),
            };
            store.identity_keypair = Some(data.clone());
            persist_identity_keypair(&data)?;
            keypair
        }
    };

    let key_id = store
        .signed_prekey
        .as_ref()
        .map(|p| p.key_id + 1)
        .unwrap_or(1);
    let (bundle, signed_prekey_data, one_time_data) =
        build_key_material(&identity_keypair, key_id, one_time_count)?;

    // Persist before returning. A bundle that reaches the server while its private halves are
    // still only in memory is exactly the unanswerable state this step exists to remove.
    store.signed_prekey = Some(signed_prekey_data.clone());
    store.one_time_prekeys = one_time_data.clone();
    persist_signed_prekey(&signed_prekey_data)?;
    persist_one_time_prekeys(&one_time_data)?;

    tracing::info!(
        "Key bundle generated and persisted: signed prekey id {}, {} one-time prekeys",
        key_id,
        one_time_data.len()
    );

    Ok(bundle)
}

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

/// Fetch a peer's published key bundle from auth-service.
///
/// `AuthClient::get_key_bundle` has existed since the desktop gained a gRPC client and had no
/// callers: it was not a command, so the frontend had no way to reach it and
/// `NewConversationModal` carried a TODO where the fetch belongs. Every other piece of the
/// initiator path was already in place and simply had nothing to act on.
///
/// **The key ids are reconstructed, not received.** `common.KeyBundle` carries none: the
/// server assigns a one-time pre-key's id implicitly by its position when it stores the array
/// (`auth-service/src/db.rs`, `.enumerate()`), and the initiator later names the key it used by
/// that same index. So the first one-time pre-key is id `0`, and the signed pre-key is id `1`,
/// matching `client-mobile`'s `key_exchange_datasource.dart` exactly. Diverging here would not
/// fail at agreement time - both ends would derive a secret, just not the same one, and the
/// first message would surface it as an AEAD tag rejection.
#[tauri::command]
pub async fn get_key_bundle_for_peer(
    state: State<'_, AppState>,
    user_id: String,
) -> Result<KeyBundle, String> {
    tracing::debug!("Fetching key bundle for peer");

    let bundle = state
        .auth()
        .get_key_bundle(user_id)
        .await
        .map_err(|e| format!("Failed to fetch key bundle: {}", e))?;

    key_bundle_from_proto(&bundle)
}

/// Convert a published `common.KeyBundle` into the form the X3DH initiator takes.
///
/// Pure, so the id convention can be asserted on without a server.
fn key_bundle_from_proto(bundle: &crate::proto::common::KeyBundle) -> Result<KeyBundle, String> {
    // An empty identity key is not an absent bundle: `get_key_bundle` returns `Some` for it,
    // and it is what a destroyed bundle looks like (#243). Refuse it here rather than let
    // signature verification fail later with a less useful message.
    if bundle.identity_key.is_empty() {
        return Err(
            "Peer key bundle has no identity key: the bundle cannot be verified and no session \
             can be established against it"
                .to_string(),
        );
    }
    if bundle.signed_pre_key.is_empty() || bundle.signed_pre_key_signature.is_empty() {
        return Err(
            "Peer key bundle has no signed pre-key or no signature: X3DH requires a signed \
             pre-key and never downgrades to an unsigned exchange"
                .to_string(),
        );
    }

    Ok(KeyBundle {
        identity_key: hex::encode(&bundle.identity_key),
        signed_prekey: hex::encode(&bundle.signed_pre_key),
        prekey_signature: hex::encode(&bundle.signed_pre_key_signature),
        // Index 0 by convention; see the note above. `GetKeyBundle` returns the whole pool and
        // consumes nothing (#246), so this is also the only key any initiator is ever served.
        one_time_prekey: bundle.one_time_pre_keys.first().map(hex::encode),
        pq_prekey: None,
    })
}

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

    // Park what the peer will need to answer. It rides the first message of this session.
    let used_prekey_id = if use_one_time_key { Some(0) } else { None };
    let prekey_message = guardyn_crypto::x3dh::X3DHPrekeyMessage::new(
        identity_keypair.public_bytes(),
        ephemeral_public.as_bytes().to_vec(),
        used_prekey_id,
    );
    PENDING_PREKEY
        .lock()
        .map_err(|e| e.to_string())?
        .insert(recipient_id.clone(), prekey_message.to_base64());

    tracing::info!("X3DH key agreement successful with {}", recipient_id);

    Ok(X3DHResult {
        shared_secret: hex::encode(&shared_secret),
        ephemeral_key: hex::encode(ephemeral_public.as_bytes()),
        used_prekey_id,
    })
}

/// Rebuild a signed pre-key from the secret kept in secure storage.
///
/// The stored record is the one published to the server (PR-79), so restoring it reproduces
/// exactly the key an initiator ran X3DH against. An empty `private_key` means the record
/// predates PR-79 and its secret was never kept - unrecoverable rather than transient, and it
/// must say so instead of silently regenerating.
fn restore_signed_prekey(data: &PreKeyData) -> Result<guardyn_crypto::x3dh::SignedPreKey, String> {
    let secret = decode_prekey_secret(&data.private_key, "signed pre-key", data.key_id)?;
    let signature = hex::decode(&data.signature)
        .map_err(|e| format!("Invalid stored signed pre-key signature: {}", e))?;

    // The timestamp is metadata on the published bundle and plays no part in key agreement.
    Ok(guardyn_crypto::x3dh::SignedPreKey::from_secret_bytes(
        data.key_id,
        secret,
        signature,
        0,
    ))
}

/// Rebuild a one-time pre-key from the secret kept in secure storage.
fn restore_one_time_prekey(
    data: &PreKeyData,
) -> Result<guardyn_crypto::x3dh::OneTimePreKey, String> {
    let secret = decode_prekey_secret(&data.private_key, "one-time pre-key", data.key_id)?;
    Ok(guardyn_crypto::x3dh::OneTimePreKey::from_secret_bytes(
        data.key_id,
        secret,
    ))
}

fn decode_prekey_secret(private_key: &str, kind: &str, key_id: u32) -> Result<[u8; 32], String> {
    if private_key.is_empty() {
        return Err(format!(
            "{} {} has no stored secret: it was published before the secret was retained, so no \
             session can be answered against it. Re-publish the key bundle.",
            kind, key_id
        ));
    }
    hex::decode(private_key)
        .map_err(|e| format!("Invalid stored {} secret: {}", kind, e))?
        .try_into()
        .map_err(|_| format!("Stored {} secret is not 32 bytes", kind))
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

    // Restore the published pre-keys. This used to call `SignedPreKey::generate` and
    // `OneTimePreKey::generate` with the stored key ids, which mints fresh random secrets
    // wearing those ids - so the secret derived here could never match the one the initiator
    // derived, and every message failed its tag check while both sides looked healthy.
    let signed_prekey = restore_signed_prekey(signed_prekey_data)?;
    let one_time_prekeys = store
        .one_time_prekeys
        .iter()
        .map(restore_one_time_prekey)
        .collect::<Result<Vec<_>, String>>()?;

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
/// The initiator (Alice) ratchets against the peer's signed pre-key, so `peer_public_key`
/// is required and must be that key. The responder (Bob) seeds his ratchet with his own signed
/// pre-key secret - the one whose public half the initiator used - restored from secure
/// storage, so `peer_public_key` is ignored on that path.
#[tauri::command]
pub async fn init_session(
    peer_id: String,
    shared_secret: String,
    is_initiator: bool,
    peer_public_key: Option<String>,
) -> Result<SessionInfo, String> {
    tracing::info!("Initializing Double Ratchet session with peer: {} (initiator: {})", peer_id, is_initiator);

    let secret_bytes = hex::decode(&shared_secret)
        .map_err(|e| format!("Invalid shared secret: {}", e))?;

    if secret_bytes.len() != 32 {
        return Err("Shared secret must be 32 bytes".to_string());
    }

    // Initialize Double Ratchet.
    // Alice derives her first root key from DH(her fresh key, Bob's signed pre-key); Bob must
    // use the matching secret. Using init_bob for both roles - or init_alice for both - leaves
    // the two sides with different DH outputs, so nothing decrypts.
    let ratchet = if is_initiator {
        let peer_public_key = peer_public_key.ok_or_else(|| {
            "peer_public_key is required to initialize an initiator session".to_string()
        })?;
        let peer_public_bytes =
            hex::decode(&peer_public_key).map_err(|e| format!("Invalid peer public key: {}", e))?;
        let peer_public_bytes: [u8; 32] = peer_public_bytes
            .try_into()
            .map_err(|_| "Peer public key must be 32 bytes".to_string())?;
        let peer_public = guardyn_crypto::X25519PublicKey::from(peer_public_bytes);

        guardyn_crypto::DoubleRatchet::init_alice(&secret_bytes, peer_public)
            .map_err(|e| format!("Failed to init Double Ratchet: {}", e))?
    } else {
        // Bob's initial ratchet key is his signed pre-key - the key whose public half the
        // initiator ran X3DH against. This path was refused outright until PR-79 retained the
        // secret; the refusal was right while there was nothing to seed with, because a
        // session that can never decrypt is worse than a loud failure.
        let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
        let signed_prekey_data = store
            .signed_prekey
            .as_ref()
            .ok_or_else(|| "Signed prekey not generated".to_string())?;
        let signed_prekey = restore_signed_prekey(signed_prekey_data)?;
        drop(store);

        guardyn_crypto::DoubleRatchet::init_bob(&secret_bytes, signed_prekey.ratchet_secret())
            .map_err(|e| format!("Failed to init Double Ratchet: {}", e))?
    };

    // A responder has no sending chain key until its first `decrypt` performs the DH ratchet
    // against the initiator's public key, so it cannot be persisted yet: what would be written
    // is a session that reloads unable to send, and `rehydrate_ratchets` would rightly discard
    // it - losing the ratchet that was about to become usable. `encrypt_for_peer` and
    // `decrypt_message` persist after each operation, so the first successful decrypt writes it.
    // (client-mobile reached the same conclusion: crypto_service.dart:436-441.)
    let can_persist = ratchet.can_send();

    let session = SessionData {
        peer_id: peer_id.clone(),
        established_at: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs(),
        messages_sent: 0,
        messages_received: 0,
        state: ratchet.serialize(),
    };

    // Store ratchet in memory
    {
        let mut ratchet_store = RATCHET_STORE.lock().map_err(|e| e.to_string())?;
        ratchet_store.insert(peer_id.clone(), ratchet);
    }

    // Store session metadata, and persist only what will survive a reload.
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    store.sessions.insert(peer_id.clone(), session.clone());
    if can_persist {
        persist_sessions(&store.sessions)?;
        tracing::info!("Double Ratchet session established and persisted");
    } else {
        tracing::info!(
            "Responder session established in memory; it is persisted after its first decrypt"
        );
    }
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

/// The caller-supplied half of the AEAD associated data for a one-to-one message.
///
/// The full AAD is this value followed by the 40-byte ratchet header, which
/// `guardyn_crypto` appends itself (see `aad_with_header`). The convention is
/// `utf8("{sender_user_id}|{recipient_user_id}")` and it is canonical across both clients -
/// `client-mobile/lib/core/crypto/message_aad.dart` builds the same bytes. It is recorded in
/// `docs/adr/ADR-0011-ratchet-header-authentication.md`.
///
/// Ordering is by **role**, not by point of view: originator first, destination second. That
/// is what makes the two ends agree. This function exists because they previously did not -
/// `encrypt_message` passed `recipient_id` while `decrypt_message` passed `sender_id`, so for
/// a session A-B, A encrypted under `bytes(B)` and B decrypted under `bytes(A)`, and the tag
/// could never verify.
fn message_associated_data(sender_user_id: &str, recipient_user_id: &str) -> Vec<u8> {
    format!("{}|{}", sender_user_id, recipient_user_id).into_bytes()
}

/// Returned when a message cannot be encrypted, so callers can fail closed on it.
///
/// The desktop client must never fall back to transmitting plaintext: the server is a pure
/// relay (see `docs/adr/ADR-0010-pure-relay-server.md`) and stores whatever it is handed
/// byte-for-byte, so an unencrypted send is plaintext at rest, not merely plaintext in flight.
pub const ENCRYPTION_UNAVAILABLE: &str = "encryption unavailable";

/// Shown in place of content that could not be decrypted.
///
/// Kept identical to `client-desktop/src/lib/undecryptable.ts` and to
/// `client-mobile/lib/core/crypto/undecryptable_message.dart`, so the clients say the same
/// thing. Callers set a flag alongside it; the UI keys off the flag rather than matching this
/// string, so a user who types these words is still rendered as having written them.
pub const UNDECRYPTABLE_PLACEHOLDER: &str = "Message cannot be decrypted";

/// Encrypt one message for a peer and return the serialized ciphertext.
///
/// This is the single encryption entry point for the send path. `encrypt_message` exposes it
/// to the frontend and `commands::messaging::send_message` uses it directly, so neither can
/// acquire a way to emit an unencrypted payload without the other noticing.
///
/// Returns an error beginning with [`ENCRYPTION_UNAVAILABLE`] when no Double Ratchet session
/// exists for `recipient_id`. **That error must abort the send.** Today it is the only outcome,
/// because nothing on the desktop establishes a session yet; the callers are nevertheless
/// written against the real contract so that landing session establishment needs no change
/// here.
/// Establish the responder side of a session from the prekey message that arrived with a
/// peer's first message. A no-op when a session already exists.
///
/// The single implementation of the inbound path: `get_messages` calls it directly and the
/// frontend reaches it through the `accept_session` command, so history and live delivery
/// cannot drift apart.
///
/// Re-arrival is normal rather than exceptional. The initiator keeps attaching the prekey
/// message until a send is accepted, so a retry or a duplicate delivery brings it again -
/// acting on it twice would replace a ratchet that has already advanced and lose every message
/// after the first.
pub(crate) fn ensure_responder_session(peer_id: &str, x3dh_prekey: &str) -> Result<(), String> {
    if RATCHET_STORE
        .lock()
        .map_err(|e| e.to_string())?
        .contains_key(peer_id)
    {
        return Ok(());
    }

    let prekey = guardyn_crypto::x3dh::X3DHPrekeyMessage::from_base64(x3dh_prekey)
        .map_err(|e| format!("Malformed X3DH prekey message: {}", e))?;

    let store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    let identity_data = store
        .identity_keypair
        .as_ref()
        .ok_or_else(|| "Identity keys not generated".to_string())?;
    let private_bytes = hex::decode(&identity_data.private_key)
        .map_err(|e| format!("Invalid stored identity private key: {}", e))?;
    let identity_keypair = guardyn_crypto::x3dh::IdentityKeyPair::from_private_bytes(&private_bytes)
        .map_err(|e| format!("Failed to restore identity keypair: {}", e))?;

    let signed_prekey_data = store
        .signed_prekey
        .as_ref()
        .ok_or_else(|| "Signed prekey not generated".to_string())?;
    let signed_prekey = restore_signed_prekey(signed_prekey_data)?;
    let one_time_prekeys = store
        .one_time_prekeys
        .iter()
        .map(restore_one_time_prekey)
        .collect::<Result<Vec<_>, String>>()?;
    drop(store);

    let ratchet_secret = signed_prekey.ratchet_secret();
    let key_material = guardyn_crypto::x3dh::X3DHKeyMaterial {
        identity_key: identity_keypair,
        signed_pre_key: signed_prekey,
        one_time_pre_keys: one_time_prekeys,
    };

    let shared_secret = guardyn_crypto::x3dh::X3DHProtocol::respond_key_agreement(
        &key_material,
        &prekey.sender_identity_key,
        &prekey.ephemeral_key,
        prekey.used_one_time_key_id,
    )
    .map_err(|e| format!("X3DH respond failed: {}", e))?;

    let ratchet = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret, ratchet_secret)
        .map_err(|e| format!("Failed to init Double Ratchet: {}", e))?;

    let session = SessionData {
        peer_id: peer_id.to_string(),
        established_at: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs(),
        messages_sent: 0,
        messages_received: 0,
        state: ratchet.serialize(),
    };

    RATCHET_STORE
        .lock()
        .map_err(|e| e.to_string())?
        .insert(peer_id.to_string(), ratchet);
    SESSION_STORE
        .lock()
        .map_err(|e| e.to_string())?
        .sessions
        .insert(peer_id.to_string(), session);

    // Not persisted here: a responder has no sending chain key until its first decrypt performs
    // the DH ratchet, and `rehydrate_ratchets` rightly discards a session that cannot send.
    // `decrypt_from_peer` writes it once that decrypt succeeds.
    tracing::info!("Responder session established from an inbound prekey message");
    Ok(())
}

/// Establish the responder side of a session, for the frontend's live-delivery path.
#[tauri::command]
pub async fn accept_session(peer_id: String, x3dh_prekey: String) -> Result<(), String> {
    ensure_responder_session(&peer_id, &x3dh_prekey)
}

/// Decrypt a message received from `sender_id`, returning `None` when it cannot be decrypted.
///
/// The mirror of [`encrypt_for_peer`]. `None` rather than an error, because "we could not read
/// this" is a normal outcome the UI renders as a placeholder, not a failure of the operation
/// that is fetching messages - one unreadable message must not blank a whole conversation.
///
/// The associated data names the parties by role, originator first, so both ends compute the
/// same bytes: the sender here is the peer, not the local user (ADR-0011).
pub(crate) fn decrypt_from_peer(
    ciphertext: &[u8],
    sender_id: &str,
    self_user_id: &str,
) -> Option<String> {
    let encrypted = match guardyn_crypto::double_ratchet::EncryptedMessage::from_bytes(ciphertext) {
        Ok(message) => message,
        Err(e) => {
            tracing::debug!("Message is not a well-formed ciphertext: {}", e);
            return None;
        }
    };

    let associated_data = message_associated_data(sender_id, self_user_id);

    let mut ratchet_store = RATCHET_STORE.lock().ok()?;
    let ratchet = ratchet_store.get_mut(sender_id)?;
    let padded = match ratchet.decrypt(&encrypted, &associated_data) {
        Ok(plaintext) => plaintext,
        Err(e) => {
            tracing::debug!("Double Ratchet could not decrypt: {}", e);
            return None;
        }
    };
    // Take the state now, while the ratchet is still borrowed and known to have advanced.
    let state = ratchet.serialize();
    drop(ratchet_store);

    let plaintext = guardyn_crypto::unpad_message(&padded)
        .map_err(|e| tracing::debug!("PADME unpad failed: {}", e))
        .ok()?;

    // The ratchet advanced, so the stored state is now stale. Persisting here is also what
    // writes a responder session for the first time: it is deliberately not persisted at
    // creation, because it cannot send until this decrypt completes it (see init_session).
    if let Ok(mut store) = SESSION_STORE.lock() {
        if let Some(session) = store.sessions.get_mut(sender_id) {
            session.messages_received += 1;
            session.state = state;
        }
        let sessions = store.sessions.clone();
        drop(store);
        if let Err(e) = persist_sessions(&sessions) {
            // The message decrypted; losing the write costs a re-agreement, not the message.
            tracing::warn!("Could not persist the advanced ratchet state: {}", e);
        }
    }

    String::from_utf8(plaintext)
        .map_err(|_| tracing::debug!("Decrypted bytes are not valid UTF-8"))
        .ok()
}

pub(crate) fn encrypt_for_peer(
    plaintext: &str,
    recipient_id: &str,
    self_user_id: &str,
) -> Result<Vec<u8>, String> {
    // Apply PADMÉ padding for traffic analysis protection.
    let padded = guardyn_crypto::pad_message(plaintext.as_bytes())
        .map_err(|e| format!("Padding failed: {}", e))?;

    // Get Double Ratchet for this peer.
    let mut ratchet_store = RATCHET_STORE.lock().map_err(|e| e.to_string())?;
    let ratchet = ratchet_store.get_mut(recipient_id).ok_or_else(|| {
        format!("{}: no Double Ratchet session with peer {}", ENCRYPTION_UNAVAILABLE, recipient_id)
    })?;

    // Encrypt with Double Ratchet. The local user is the sender.
    let associated_data = message_associated_data(self_user_id, recipient_id);
    let encrypted = ratchet
        .encrypt(&padded, &associated_data)
        .map_err(|e| format!("Double Ratchet encryption failed: {}", e))?;

    let encrypted_bytes = encrypted.to_bytes();
    drop(ratchet_store);

    // Update session metadata.
    let mut store = SESSION_STORE.lock().map_err(|e| e.to_string())?;
    if let Some(session) = store.sessions.get_mut(recipient_id) {
        session.messages_sent += 1;
        // Update serialized ratchet state
        if let Ok(ratchet_store) = RATCHET_STORE.lock() {
            if let Some(ratchet) = ratchet_store.get(recipient_id) {
                session.state = ratchet.serialize();
            }
        }
    }

    // Persist updated sessions
    let sessions_clone = store.sessions.clone();
    drop(store);
    persist_sessions(&sessions_clone)?;

    Ok(encrypted_bytes)
}

/// Encrypt a message for a peer using Double Ratchet
#[tauri::command]
pub async fn encrypt_message(
    plaintext: String,
    recipient_id: String,
    self_user_id: String,
) -> Result<EncryptedMessage, String> {
    tracing::debug!("Encrypting message for {} ({} bytes)", recipient_id, plaintext.len());

    let encrypted_bytes = encrypt_for_peer(&plaintext, &recipient_id, &self_user_id)?;

    Ok(EncryptedMessage {
        ciphertext: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &encrypted_bytes,
        ),
        nonce: String::new(),  // Nonce is included in encrypted message
        header: String::new(), // Header is included in encrypted message
    })
}

/// Decrypt a message from a peer using Double Ratchet
#[tauri::command]
pub async fn decrypt_message(
    ciphertext: String,
    _nonce: String, // Nonce is now embedded in ciphertext
    sender_id: String,
    self_user_id: String,
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

    // Decrypt with Double Ratchet. The local user is the recipient.
    let associated_data = message_associated_data(&sender_id, &self_user_id);
    let padded = ratchet.decrypt(&encrypted_msg, &associated_data)
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

    fn proto_bundle(one_time: Vec<Vec<u8>>) -> crate::proto::common::KeyBundle {
        crate::proto::common::KeyBundle {
            identity_key: vec![1; 32],
            signed_pre_key: vec![2; 32],
            signed_pre_key_signature: vec![3; 64],
            one_time_pre_keys: one_time,
            created_at: None,
        }
    }

    /// `common.KeyBundle` carries no key ids. The server assigns a one-time pre-key's id by its
    /// position when it stores the array, and the initiator names the key it used by that same
    /// index - so taking the first element is what makes id 0 mean the same key on both ends.
    ///
    /// `client-mobile` does the same at `key_exchange_datasource.dart:65-69`. If these two ever
    /// diverge the failure is silent: both sides derive a secret, they simply differ, and only
    /// the first message shows it as an AEAD tag rejection.
    #[test]
    fn test_the_first_one_time_prekey_is_the_one_selected() {
        let first = vec![9u8; 32];
        let second = vec![8u8; 32];
        let converted = key_bundle_from_proto(&proto_bundle(vec![first.clone(), second])).unwrap();

        assert_eq!(converted.one_time_prekey, Some(hex::encode(&first)));
    }

    /// SRS: "No one-time pre-keys left: proceed with the three-DH variant - never refuse."
    #[test]
    fn test_an_empty_one_time_pool_yields_the_three_dh_variant() {
        let converted = key_bundle_from_proto(&proto_bundle(vec![])).unwrap();
        assert_eq!(converted.one_time_prekey, None);
        assert!(!converted.identity_key.is_empty());
    }

    /// A bundle whose identity key was destroyed (#243) still comes back as `Some`. Refusing it
    /// here gives a message that names the cause, instead of an opaque signature failure.
    #[test]
    fn test_a_bundle_with_no_identity_key_is_refused() {
        let mut bundle = proto_bundle(vec![]);
        bundle.identity_key = vec![];

        let err = key_bundle_from_proto(&bundle).expect_err("must refuse");
        assert!(err.contains("identity key"), "{err}");
    }

    /// SRS: the signature "must verify against the identity key. Failure aborts - never
    /// downgrade to an unsigned exchange." An absent signature is that case at its limit.
    #[test]
    fn test_a_bundle_with_no_signature_is_refused() {
        let mut bundle = proto_bundle(vec![]);
        bundle.signed_pre_key_signature = vec![];

        let err = key_bundle_from_proto(&bundle).expect_err("must refuse");
        assert!(err.contains("signature"), "{err}");
    }

    fn stored_session(peer: &str, state: Vec<u8>) -> (String, SessionData) {
        (
            peer.to_string(),
            SessionData {
                peer_id: peer.to_string(),
                established_at: 0,
                messages_sent: 0,
                messages_received: 0,
                state,
            },
        )
    }

    /// What `perform_x3dh` parks must survive the trip and parse back. `x3dh_prekey` is an
    /// opaque base64 string on the wire that no type checks, so the format is worth pinning at
    /// the end that produces it - the end that consumes it arrives with #258.
    #[test]
    fn test_the_parked_prekey_message_round_trips() {
        let identity = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();
        let ephemeral = guardyn_crypto::x3dh::OneTimePreKey::generate(0);

        let parked = guardyn_crypto::x3dh::X3DHPrekeyMessage::new(
            identity.public_bytes(),
            ephemeral.public_bytes(),
            Some(0),
        )
        .to_base64();

        let parsed = guardyn_crypto::x3dh::X3DHPrekeyMessage::from_base64(&parked).unwrap();

        assert_eq!(parsed.sender_identity_key, identity.public_bytes());
        assert_eq!(parsed.ephemeral_key, ephemeral.public_bytes());
        assert_eq!(parsed.used_one_time_key_id, Some(0));
    }

    /// `decrypt_from_peer` must never hand back the bytes it failed to read. This is the #232
    /// guarantee at the Rust boundary: the old code used `String::from_utf8_lossy`, which
    /// cannot fail, so ciphertext rendered as replacement characters and anything that happened
    /// to be valid UTF-8 rendered as the message.
    #[test]
    fn test_decrypt_returns_nothing_for_bytes_that_are_not_a_message() {
        // Valid UTF-8, so a lossy conversion would have rendered it as the message text.
        assert_eq!(
            decrypt_from_peer(b"this is not a ciphertext", "someone", "me"),
            None
        );
        assert_eq!(decrypt_from_peer(&[], "someone", "me"), None);
        assert_eq!(decrypt_from_peer(&[0xff; 80], "someone", "me"), None);
    }

    /// A well-formed ciphertext from a peer we have no session with is unreadable, not an
    /// error: the fetch that found it must still return every other message.
    #[test]
    fn test_decrypt_returns_nothing_when_there_is_no_session() {
        let material = guardyn_crypto::x3dh::X3DHKeyMaterial::generate(1).unwrap();
        let peer_public: [u8; 32] = material
            .signed_pre_key
            .public_bytes()
            .try_into()
            .unwrap();
        let mut sender = guardyn_crypto::DoubleRatchet::init_alice(
            &[3u8; 32],
            guardyn_crypto::X25519PublicKey::from(peer_public),
        )
        .unwrap();
        let aad = message_associated_data("stranger-with-no-session", "me");
        let ciphertext = sender.encrypt(b"hello", &aad).unwrap().to_bytes();

        assert_eq!(
            decrypt_from_peer(&ciphertext, "stranger-with-no-session", "me"),
            None
        );
    }

    /// The restart round-trip. A session established before the process ended must decrypt the
    /// next message after it restarts.
    ///
    /// `RATCHET_STORE` used to start empty and never be populated, while the metadata beside it
    /// was restored - so `get_session` reported an active session and `encrypt_for_peer` failed
    /// with "no Double Ratchet session" for ever.
    #[test]
    fn test_a_session_survives_a_restart() {
        let alice_material = guardyn_crypto::x3dh::X3DHKeyMaterial::generate(1).unwrap();
        let bob_material = guardyn_crypto::x3dh::X3DHKeyMaterial::generate(1).unwrap();
        let bob_bundle = bob_material.export_bundle();

        let (secret, ephemeral) = guardyn_crypto::x3dh::X3DHProtocol::initiate_key_agreement(
            &alice_material.identity_key,
            &bob_bundle,
            true,
        )
        .unwrap();
        let bob_secret = guardyn_crypto::x3dh::X3DHProtocol::respond_key_agreement(
            &bob_material,
            &alice_material.identity_key.public_bytes(),
            ephemeral.as_bytes(),
            Some(0),
        )
        .unwrap();

        let peer_public: [u8; 32] = bob_bundle.signed_pre_key.clone().try_into().unwrap();
        let mut alice = guardyn_crypto::DoubleRatchet::init_alice(
            &secret,
            guardyn_crypto::X25519PublicKey::from(peer_public),
        )
        .unwrap();
        let mut bob = guardyn_crypto::DoubleRatchet::init_bob(
            &bob_secret,
            bob_material.signed_pre_key.ratchet_secret(),
        )
        .unwrap();

        let aad = message_associated_data("alice", "bob");

        // Bob cannot send until his first decrypt completes the ratchet, so he must not be
        // persisted before it.
        assert!(!bob.can_send(), "a fresh responder has no sending chain");
        bob.decrypt(&alice.encrypt(b"hello", &aad).unwrap(), &aad)
            .unwrap();
        assert!(bob.can_send(), "the first decrypt completes the ratchet");

        // The process ends here. Only what was persisted comes back.
        let stored: HashMap<_, _> = [stored_session("alice", bob.serialize())].into();
        let (restored_sessions, mut restored_ratchets) = rehydrate_ratchets(stored);

        assert_eq!(restored_sessions.len(), 1, "the session must come back");
        let bob_again = restored_ratchets
            .get_mut("alice")
            .expect("the ratchet must come back");

        let second = alice.encrypt(b"after the restart", &aad).unwrap();
        assert_eq!(bob_again.decrypt(&second, &aad).unwrap(), b"after the restart");
    }

    /// A responder persisted before its first decrypt reloads unable to send. Keeping it would
    /// resurrect a half-session that looks established and refuses everything, so it is dropped
    /// and a fresh key agreement runs instead (client-mobile: crypto_service.dart:508-513).
    #[test]
    fn test_a_session_that_cannot_send_is_dropped_rather_than_restored() {
        let bob_material = guardyn_crypto::x3dh::X3DHKeyMaterial::generate(1).unwrap();
        let bob = guardyn_crypto::DoubleRatchet::init_bob(
            &[7u8; 32],
            bob_material.signed_pre_key.ratchet_secret(),
        )
        .unwrap();
        assert!(!bob.can_send());

        let stored: HashMap<_, _> = [stored_session("alice", bob.serialize())].into();
        let (sessions, ratchets) = rehydrate_ratchets(stored);

        assert!(sessions.is_empty(), "the metadata must go with the ratchet");
        assert!(ratchets.is_empty());
    }

    /// Metadata without a usable ratchet is the exact half-state this step removes, so a
    /// session whose state is missing or corrupt is dropped rather than half-restored.
    #[test]
    fn test_sessions_without_restorable_state_are_dropped() {
        let stored: HashMap<_, _> = [
            stored_session("empty", Vec::new()),
            stored_session("corrupt", vec![0xff; 9]),
        ]
        .into();

        let (sessions, ratchets) = rehydrate_ratchets(stored);

        assert!(sessions.is_empty(), "no session should survive: {sessions:?}");
        assert!(ratchets.is_empty());
    }

    /// The whole responder path, end to end, over the pieces `respond_x3dh` and `init_session`
    /// use: Bob restores the pre-keys he published from storage, completes X3DH, seeds his
    /// ratchet from the same signed pre-key, and decrypts Alice's first message.
    ///
    /// This fails if the restore is replaced by a regenerate - which is exactly what
    /// `respond_x3dh` did before this step. The shared secrets diverge, and the failure
    /// surfaces as an AEAD tag rejection with both sides looking healthy.
    #[test]
    fn test_responder_restored_from_storage_decrypts_the_first_message() {
        // Bob publishes a bundle and keeps the private halves (PR-79).
        let bob_identity = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();
        let (bob_bundle, bob_signed_stored, bob_one_time_stored) =
            build_key_material(&bob_identity, 1, 3).unwrap();

        // Alice fetches the bundle and initiates.
        let alice_identity = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();
        let (alice_secret, alice_ephemeral) =
            guardyn_crypto::x3dh::X3DHProtocol::initiate_key_agreement(
                &alice_identity,
                &bob_bundle,
                true,
            )
            .unwrap();

        // Bob comes back holding only what he persisted, and restores rather than regenerates.
        let bob_material = guardyn_crypto::x3dh::X3DHKeyMaterial {
            identity_key: guardyn_crypto::x3dh::IdentityKeyPair::from_private_bytes(
                &hex::decode(hex::encode(bob_identity.private_key_bytes())).unwrap(),
            )
            .unwrap(),
            signed_pre_key: restore_signed_prekey(&bob_signed_stored).unwrap(),
            one_time_pre_keys: bob_one_time_stored
                .iter()
                .map(|d| restore_one_time_prekey(d).unwrap())
                .collect(),
        };

        let bob_secret = guardyn_crypto::x3dh::X3DHProtocol::respond_key_agreement(
            &bob_material,
            &alice_identity.public_bytes(),
            alice_ephemeral.as_bytes(),
            Some(0),
        )
        .unwrap();

        assert_eq!(alice_secret, bob_secret, "restored responder must agree");

        // And the ratchet must seed from the same signed pre-key, or nothing decrypts.
        let bob_signed = restore_signed_prekey(&bob_signed_stored).unwrap();
        let peer_public_bytes: [u8; 32] = bob_bundle.signed_pre_key.clone().try_into().unwrap();
        let mut alice_ratchet = guardyn_crypto::DoubleRatchet::init_alice(
            &alice_secret,
            guardyn_crypto::X25519PublicKey::from(peer_public_bytes),
        )
        .unwrap();
        let mut bob_ratchet =
            guardyn_crypto::DoubleRatchet::init_bob(&bob_secret, bob_signed.ratchet_secret())
                .unwrap();

        let aad = message_associated_data("alice", "bob");
        let encrypted = alice_ratchet.encrypt(b"first message", &aad).unwrap();
        let decrypted = bob_ratchet.decrypt(&encrypted, &aad).unwrap();

        assert_eq!(decrypted, b"first message");
    }

    /// A pre-key published before PR-79 has no stored secret. Restoring must say so, not
    /// quietly mint a new key - the regenerated key would look fine and decrypt nothing.
    #[test]
    fn test_restoring_a_prekey_with_no_stored_secret_fails_loudly() {
        let stored = PreKeyData {
            key_id: 4,
            public_key: "aa".repeat(32),
            private_key: String::new(),
            signature: String::new(),
        };

        // `expect_err` is unavailable here on purpose: `OneTimePreKey` implements no `Debug`,
        // because a type holding key material must not be renderable into a log line.
        match restore_one_time_prekey(&stored) {
            Ok(_) => panic!("a pre-key with no retained secret must not be restored"),
            Err(err) => assert!(
                err.contains("no stored secret"),
                "the error must name the cause: {err}"
            ),
        }
    }

    /// The property PR-79 exists to establish: every private half of a published bundle is
    /// still on the device, and restoring from it reproduces the exact key that was published.
    ///
    /// Before this step, `commands::auth::generate_key_bundle` called
    /// `X3DHProtocol::generate_key_bundle()`, which returns only `export_bundle()` and drops
    /// the material - so the published pre-keys had no private half anywhere, and the
    /// published *identity* key was not even the one the device held.
    #[test]
    fn test_published_bundle_is_backed_by_retained_private_keys() {
        let identity = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();
        let (bundle, signed, one_time) = build_key_material(&identity, 1, 3).unwrap();

        assert_eq!(
            bundle.identity_key,
            identity.public_bytes(),
            "the published identity key must be the device's own"
        );

        // Signed pre-key: restore from what was stored, and check it is the published key.
        assert!(
            !signed.private_key.is_empty(),
            "signed prekey secret dropped"
        );
        let secret_bytes: [u8; 32] = hex::decode(&signed.private_key)
            .unwrap()
            .try_into()
            .expect("32-byte secret");
        let restored = guardyn_crypto::x3dh::SignedPreKey::from_secret_bytes(
            signed.key_id,
            secret_bytes,
            hex::decode(&signed.signature).unwrap(),
            0,
        );
        assert_eq!(
            restored.public_bytes(),
            bundle.signed_pre_key,
            "the retained secret must reproduce the published signed pre-key"
        );

        // One-time pre-keys: same property, and ids must match their published index, because
        // `common.KeyBundle` carries no ids and the initiator reports the index it used.
        assert_eq!(one_time.len(), 3);
        assert_eq!(bundle.one_time_pre_keys.len(), 3);
        for (index, stored) in one_time.iter().enumerate() {
            assert!(
                !stored.private_key.is_empty(),
                "one-time prekey {index} secret dropped"
            );
            assert_eq!(stored.key_id, index as u32, "id must equal published index");

            let bytes: [u8; 32] = hex::decode(&stored.private_key)
                .unwrap()
                .try_into()
                .expect("32-byte secret");
            let restored =
                guardyn_crypto::x3dh::OneTimePreKey::from_secret_bytes(stored.key_id, bytes);
            assert_eq!(
                restored.public_bytes(),
                bundle.one_time_pre_keys[index].public_key,
                "retained secret must reproduce published one-time prekey {index}"
            );
        }
    }

    /// `PreKeyData` must reach the keychain with its secret and the frontend without it. The
    /// two destinations share no serde impl any more, and this pins that: the public view has
    /// no field a secret could travel in.
    #[test]
    fn test_the_public_prekey_view_carries_no_secret() {
        let identity = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();
        let (_, signed, _) = build_key_material(&identity, 1, 1).unwrap();
        assert!(
            !signed.private_key.is_empty(),
            "storage view keeps the secret"
        );

        let rendered = serde_json::to_string(&PublicPreKeyData::from(&signed)).unwrap();

        assert!(
            !rendered.contains(&signed.private_key),
            "the secret reached the frontend view: {rendered}"
        );
        assert!(
            !rendered.contains("private"),
            "no secret-shaped field: {rendered}"
        );
        assert!(
            rendered.contains(&signed.public_key),
            "public key must survive"
        );

        // The storage view must still round-trip the secret, or persistence silently breaks.
        let stored = serde_json::to_string(&signed).unwrap();
        let back: PreKeyData = serde_json::from_str(&stored).unwrap();
        assert_eq!(back.private_key, signed.private_key);
    }

    /// A published pool the credential manager cannot hold is worse than a small one: the keys
    /// are advertised and unanswerable. Windows caps a credential blob at 2560 bytes.
    #[test]
    fn test_published_prekey_pool_fits_a_windows_credential() {
        let identity = guardyn_crypto::x3dh::IdentityKeyPair::generate().unwrap();
        let (_, _, one_time) =
            build_key_material(&identity, 1, published_one_time_prekey_count()).unwrap();

        let blob = serde_json::to_string(&one_time).unwrap();
        assert!(
            blob.len() < 2560,
            "retained one-time prekey pool is {} bytes, over the Windows credential cap",
            blob.len()
        );
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

        // Bob's signed pre-key doubles as his initial ratchet key
        let bob_dh = guardyn_crypto::StaticSecret::from([7u8; 32]);
        let bob_public = guardyn_crypto::X25519PublicKey::from(&bob_dh);
        let mut bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();

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
    fn associated_data_is_role_ordered_not_point_of_view() {
        // The bug this replaced: encrypt_message passed recipient_id and decrypt_message
        // passed sender_id, so each end built the string from its own point of view.
        let sender = "alice";
        let recipient = "bob";

        // Both ends name originator first, destination second, so both get the same bytes.
        let sending = message_associated_data(sender, recipient);
        let receiving = message_associated_data(sender, recipient);
        assert_eq!(sending, receiving);

        assert_eq!(sending, b"alice|bob".to_vec());

        // And it is directional: the reply is a different context.
        assert_ne!(sending, message_associated_data(recipient, sender));
    }

    #[test]
    fn cross_party_exchange_verifies_with_the_canonical_aad() {
        // The existing ratchet tests pass a symmetric literal (b"ad", b"alice->bob") to both
        // ends, so they cannot catch an asymmetric AAD by construction. This one builds each
        // side's associated data the way the commands do.
        let shared_secret = [11u8; 32];
        let bob_dh = guardyn_crypto::StaticSecret::from([3u8; 32]);
        let bob_public = guardyn_crypto::X25519PublicKey::from(&bob_dh);
        let mut bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();
        let mut alice =
            guardyn_crypto::DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();

        // Alice is the local user when sending; Bob is the local user when receiving.
        let alice_sends = message_associated_data("alice", "bob");
        let bob_receives = message_associated_data("alice", "bob");

        let padded = guardyn_crypto::pad_message(b"hello bob").unwrap();
        let encrypted = alice.encrypt(&padded, &alice_sends).unwrap();
        let out = bob.decrypt(&encrypted, &bob_receives).unwrap();
        assert_eq!(guardyn_crypto::unpad_message(&out).unwrap(), b"hello bob");
    }

    #[test]
    fn encrypt_for_peer_refuses_when_there_is_no_session() {
        // The #163 regression test. Before the fix the send path did not consult the ratchet at
        // all - it assigned `content.as_bytes().to_vec()` and sent it - so a peer with no
        // session produced a perfectly successful "encrypted" send carrying plaintext.
        //
        // A peer id that cannot collide with anything another test established, because
        // RATCHET_STORE is process-global.
        let peer = "no-session-peer-e6f1a4c2";

        let result = encrypt_for_peer("attack at dawn", peer, "self-user");

        let err = result.expect_err("a send with no session must fail, never fall back to plaintext");
        assert!(
            err.starts_with(ENCRYPTION_UNAVAILABLE),
            "callers fail closed by matching on this prefix, so it is part of the contract; got: {}",
            err
        );
        assert!(
            !err.contains("attack at dawn"),
            "the error must not carry the plaintext it refused to send"
        );
    }

    #[test]
    fn the_old_asymmetric_associated_data_would_have_failed() {
        // Pins the defect so it cannot come back: encrypting under the recipient id and
        // decrypting under the sender id must not verify.
        let shared_secret = [12u8; 32];
        let bob_dh = guardyn_crypto::StaticSecret::from([5u8; 32]);
        let bob_public = guardyn_crypto::X25519PublicKey::from(&bob_dh);
        let mut bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();
        let mut alice =
            guardyn_crypto::DoubleRatchet::init_alice(&shared_secret, bob_public).unwrap();

        let encrypted = alice.encrypt(b"hello bob", b"bob").unwrap();
        assert!(
            bob.decrypt(&encrypted, b"alice").is_err(),
            "encrypting under the recipient id and decrypting under the sender id must not \
             verify - if this ever passes, the AAD has stopped binding the participants"
        );
    }

    #[test]
    fn test_double_ratchet_bidirectional() {
        // Test bidirectional message exchange
        let shared_secret = [99u8; 32];

        // Bob's signed pre-key doubles as his initial ratchet key
        let bob_dh = guardyn_crypto::StaticSecret::from([7u8; 32]);
        let bob_public = guardyn_crypto::X25519PublicKey::from(&bob_dh);
        let mut bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();

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
        let bob_dh = guardyn_crypto::StaticSecret::from([7u8; 32]);
        let bob_public = guardyn_crypto::X25519PublicKey::from(&bob_dh);
        let _bob = guardyn_crypto::DoubleRatchet::init_bob(&shared_secret, bob_dh).unwrap();
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
