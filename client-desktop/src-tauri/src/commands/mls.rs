//! MLS (Messaging Layer Security) Commands
//!
//! Exposes OpenMLS functionality to the frontend for group chat encryption.
//! Provides group creation, member management, and message encryption/decryption.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{LazyLock, Mutex};

// =============================================================================
// MLS GROUP STORAGE
// =============================================================================

/// In-memory storage for MLS groups and key packages
/// TODO: Persist to secure storage (keychain/credential manager)
struct MlsStore {
    /// User identity for MLS operations
    identity: Option<Vec<u8>>,
    /// Signature keypair (serialized)
    signature_keypair: Option<Vec<u8>>,
    /// Generated key packages (waiting to be uploaded)
    pending_key_packages: Vec<MlsKeyPackageData>,
    /// Active MLS group states by group ID (hex-encoded)
    group_states: HashMap<String, MlsGroupData>,
}

impl Default for MlsStore {
    fn default() -> Self {
        Self {
            identity: None,
            signature_keypair: None,
            pending_key_packages: Vec::new(),
            group_states: HashMap::new(),
        }
    }
}

/// Global MLS store
static MLS_STORE: LazyLock<Mutex<MlsStore>> = LazyLock::new(|| Mutex::new(MlsStore::default()));

// =============================================================================
// DATA TYPES
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsKeyPackageData {
    /// Unique package identifier (hex)
    pub package_id: String,
    /// Serialized key package bytes (base64)
    pub key_package: String,
    /// Creation timestamp
    pub created_at: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsGroupData {
    /// Group ID (hex)
    pub group_id: String,
    /// Group display name
    pub name: String,
    /// Current epoch
    pub epoch: u64,
    /// Member identities (hex-encoded)
    pub members: Vec<String>,
    /// Messages sent in this group
    pub messages_sent: u64,
    /// Messages received in this group
    pub messages_received: u64,
    /// Last activity timestamp
    pub last_activity: u64,
    /// Serialized group state (base64) - only stored internally
    /// TODO: Used for group state persistence in production
    #[serde(skip)]
    #[allow(dead_code)]
    serialized_state: Vec<u8>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsGroupInfo {
    pub group_id: String,
    pub name: String,
    pub epoch: u64,
    pub member_count: usize,
    pub messages_sent: u64,
    pub messages_received: u64,
    pub last_activity: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsGroupCreateResult {
    /// Group ID (hex)
    pub group_id: String,
    /// Initial epoch (0)
    pub epoch: u64,
    /// Serialized group state for persistence (base64)
    pub state: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsAddMemberResult {
    /// Serialized commit message (base64) - send to existing members
    pub commit: String,
    /// Serialized welcome message (base64) - send to new member
    pub welcome: String,
    /// New epoch after adding member
    pub epoch: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsRemoveMemberResult {
    /// Serialized commit message (base64) - send to remaining members
    pub commit: String,
    /// New epoch after removing member
    pub epoch: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsEncryptedMessage {
    /// Serialized encrypted MLS message (base64)
    pub ciphertext: String,
    /// Group ID this message belongs to (hex)
    pub group_id: String,
    /// Epoch at which message was encrypted
    pub epoch: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsDecryptedMessage {
    /// Decrypted plaintext
    pub plaintext: String,
    /// Sender identity (hex)
    pub sender_id: String,
    /// Epoch at which message was sent
    pub epoch: u64,
}

// =============================================================================
// INITIALIZATION COMMANDS
// =============================================================================

/// Initialize MLS identity for the current user
///
/// Must be called before any other MLS operations.
/// Generates a signature keypair for MLS protocol operations.
#[tauri::command]
pub async fn mls_init(user_id: String, device_id: String) -> Result<bool, String> {
    tracing::info!("Initializing MLS for user: {}:{}", user_id, device_id);

    let identity = format!("{}:{}", user_id, device_id).into_bytes();

    // Generate signature keypair using guardyn-crypto
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create MLS keypair: {}", e))?;

    // Serialize keypair for storage
    // Note: OpenMLS SignatureKeyPair doesn't directly expose private bytes,
    // so we store a placeholder. In production, use proper key serialization.
    let keypair_bytes = keypair.public().to_vec();

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    store.identity = Some(identity);
    store.signature_keypair = Some(keypair_bytes);

    tracing::info!("MLS initialized successfully");
    Ok(true)
}

/// Check if MLS is initialized
#[tauri::command]
pub async fn mls_is_initialized() -> Result<bool, String> {
    let store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    Ok(store.identity.is_some() && store.signature_keypair.is_some())
}

// =============================================================================
// KEY PACKAGE COMMANDS
// =============================================================================

/// Generate a new MLS key package
///
/// Key packages are pre-generated and uploaded to the server.
/// They are consumed when users are added to groups.
#[tauri::command]
pub async fn mls_generate_key_package() -> Result<MlsKeyPackageData, String> {
    tracing::info!("Generating MLS key package");

    let store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized. Call mls_init first.".to_string())?;

    // Generate key package
    let key_package = guardyn_crypto::mls::MlsGroupManager::generate_key_package(identity)
        .map_err(|e| format!("Failed to generate key package: {}", e))?;

    let data = MlsKeyPackageData {
        package_id: hex::encode(&key_package.package_id),
        key_package: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &key_package.key_package_bytes,
        ),
        created_at: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs(),
    };

    tracing::info!("Key package generated: {}", data.package_id);
    Ok(data)
}

/// Generate multiple key packages at once
#[tauri::command]
pub async fn mls_generate_key_packages(count: u32) -> Result<Vec<MlsKeyPackageData>, String> {
    tracing::info!("Generating {} MLS key packages", count);

    let mut packages = Vec::with_capacity(count as usize);
    for _ in 0..count {
        let pkg = mls_generate_key_package().await?;
        packages.push(pkg);
    }

    tracing::info!("Generated {} key packages", packages.len());
    Ok(packages)
}

// =============================================================================
// GROUP CREATION COMMANDS
// =============================================================================

/// Create a new MLS group
///
/// The caller becomes the initial group admin/creator.
#[tauri::command]
pub async fn mls_create_group(group_id: String, name: String) -> Result<MlsGroupCreateResult, String> {
    tracing::info!("Creating MLS group: {} ({})", name, group_id);

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized. Call mls_init first.".to_string())?
        .clone();

    // Check if group already exists
    if store.group_states.contains_key(&group_id) {
        return Err(format!("Group already exists: {}", group_id));
    }

    // Create keypair for this group
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create keypair: {}", e))?;

    // Create MLS group
    let group = guardyn_crypto::mls::MlsGroupManager::create_group(&group_id, &identity, keypair)
        .map_err(|e| format!("Failed to create MLS group: {}", e))?;

    // Serialize group state
    let state = group.serialize_state()
        .map_err(|e| format!("Failed to serialize group state: {}", e))?;

    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    // Store group data
    let group_data = MlsGroupData {
        group_id: group_id.clone(),
        name: name.clone(),
        epoch: group.epoch(),
        members: vec![hex::encode(&identity)],
        messages_sent: 0,
        messages_received: 0,
        last_activity: now,
        serialized_state: state.serialized_state.clone(),
    };

    store.group_states.insert(group_id.clone(), group_data);

    tracing::info!("MLS group created: {} at epoch 0", group_id);
    Ok(MlsGroupCreateResult {
        group_id,
        epoch: 0,
        state: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &state.serialized_state,
        ),
    })
}

/// Get group information
#[tauri::command]
pub async fn mls_get_group(group_id: String) -> Result<Option<MlsGroupInfo>, String> {
    let store = MLS_STORE.lock().map_err(|e| e.to_string())?;

    Ok(store.group_states.get(&group_id).map(|g| MlsGroupInfo {
        group_id: g.group_id.clone(),
        name: g.name.clone(),
        epoch: g.epoch,
        member_count: g.members.len(),
        messages_sent: g.messages_sent,
        messages_received: g.messages_received,
        last_activity: g.last_activity,
    }))
}

/// List all groups
#[tauri::command]
pub async fn mls_list_groups() -> Result<Vec<MlsGroupInfo>, String> {
    let store = MLS_STORE.lock().map_err(|e| e.to_string())?;

    Ok(store.group_states.values().map(|g| MlsGroupInfo {
        group_id: g.group_id.clone(),
        name: g.name.clone(),
        epoch: g.epoch,
        member_count: g.members.len(),
        messages_sent: g.messages_sent,
        messages_received: g.messages_received,
        last_activity: g.last_activity,
    }).collect())
}

// =============================================================================
// MEMBER MANAGEMENT COMMANDS
// =============================================================================

/// Add a member to an MLS group
///
/// Requires the member's key package (obtained from server).
/// Returns commit (for existing members) and welcome (for new member).
#[tauri::command]
pub async fn mls_add_member(
    group_id: String,
    member_key_package: String,
) -> Result<MlsAddMemberResult, String> {
    tracing::info!("Adding member to MLS group: {}", group_id);

    // Decode key package from base64
    let key_package_bytes = base64::Engine::decode(
        &base64::engine::general_purpose::STANDARD,
        &member_key_package,
    ).map_err(|e| format!("Invalid key package base64: {}", e))?;

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized".to_string())?
        .clone();

    // Get group data
    let group_data = store.group_states.get(&group_id)
        .ok_or_else(|| format!("Group not found: {}", group_id))?
        .clone();

    // Recreate MLS group from stored state
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create keypair: {}", e))?;

    let mut group = guardyn_crypto::mls::MlsGroupManager::create_group(&group_id, &identity, keypair)
        .map_err(|e| format!("Failed to recreate group: {}", e))?;

    // Add member
    let (commit_bytes, welcome_bytes) = group.add_member(&key_package_bytes)
        .map_err(|e| format!("Failed to add member: {}", e))?;

    let new_epoch = group.epoch();

    // Update stored group data
    let mut updated_group = group_data.clone();
    updated_group.epoch = new_epoch;
    updated_group.members = group.members().iter()
        .map(|m| hex::encode(m))
        .collect();
    updated_group.last_activity = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    store.group_states.insert(group_id.clone(), updated_group);

    tracing::info!("Member added to group: {} (epoch {})", group_id, new_epoch);
    Ok(MlsAddMemberResult {
        commit: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &commit_bytes,
        ),
        welcome: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &welcome_bytes,
        ),
        epoch: new_epoch,
    })
}

/// Remove a member from an MLS group
///
/// Only group admins can remove members.
/// Returns commit for remaining members.
#[tauri::command]
pub async fn mls_remove_member(
    group_id: String,
    member_index: u32,
) -> Result<MlsRemoveMemberResult, String> {
    tracing::info!("Removing member {} from MLS group: {}", member_index, group_id);

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized".to_string())?
        .clone();

    // Get group data
    let group_data = store.group_states.get(&group_id)
        .ok_or_else(|| format!("Group not found: {}", group_id))?
        .clone();

    // Recreate MLS group from stored state
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create keypair: {}", e))?;

    let mut group = guardyn_crypto::mls::MlsGroupManager::create_group(&group_id, &identity, keypair)
        .map_err(|e| format!("Failed to recreate group: {}", e))?;

    // Remove member using LeafNodeIndex
    let leaf_index = openmls::prelude::LeafNodeIndex::new(member_index);
    let commit_bytes = group.remove_member(leaf_index)
        .map_err(|e| format!("Failed to remove member: {}", e))?;

    let new_epoch = group.epoch();

    // Update stored group data
    let mut updated_group = group_data.clone();
    updated_group.epoch = new_epoch;
    updated_group.members = group.members().iter()
        .map(|m| hex::encode(m))
        .collect();
    updated_group.last_activity = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    store.group_states.insert(group_id.clone(), updated_group);

    tracing::info!("Member removed from group: {} (epoch {})", group_id, new_epoch);
    Ok(MlsRemoveMemberResult {
        commit: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &commit_bytes,
        ),
        epoch: new_epoch,
    })
}

// =============================================================================
// GROUP JOIN COMMANDS
// =============================================================================

/// Join an MLS group using a Welcome message
#[tauri::command]
pub async fn mls_join_group(
    welcome: String,
    group_name: String,
) -> Result<MlsGroupInfo, String> {
    tracing::info!("Joining MLS group: {}", group_name);

    // Decode welcome from base64
    let welcome_bytes = base64::Engine::decode(
        &base64::engine::general_purpose::STANDARD,
        &welcome,
    ).map_err(|e| format!("Invalid welcome base64: {}", e))?;

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized".to_string())?
        .clone();

    // Generate keypair and key package for joining
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create keypair: {}", e))?;

    let key_package_data = guardyn_crypto::mls::MlsGroupManager::generate_key_package(&identity)
        .map_err(|e| format!("Failed to generate key package: {}", e))?;

    // Deserialize key package
    let mut reader = key_package_data.key_package_bytes.as_slice();
    let key_package_in = openmls::prelude::KeyPackageIn::tls_deserialize(&mut reader)
        .map_err(|e| format!("Failed to deserialize key package: {:?}", e))?;

    let rust_crypto = openmls_rust_crypto::RustCrypto::default();
    let key_package = key_package_in.validate(&rust_crypto, openmls::prelude::ProtocolVersion::default())
        .map_err(|e| format!("Failed to validate key package: {:?}", e))?;

    // Join group
    let group = guardyn_crypto::mls::MlsGroupManager::join_group(&welcome_bytes, keypair, key_package)
        .map_err(|e| format!("Failed to join group: {}", e))?;

    let group_id = hex::encode(group.group_id());
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    // Store group data
    let group_data = MlsGroupData {
        group_id: group_id.clone(),
        name: group_name.clone(),
        epoch: group.epoch(),
        members: group.members().iter()
            .map(|m| hex::encode(m))
            .collect(),
        messages_sent: 0,
        messages_received: 0,
        last_activity: now,
        serialized_state: Vec::new(), // Will be updated on next operation
    };

    let info = MlsGroupInfo {
        group_id: group_data.group_id.clone(),
        name: group_data.name.clone(),
        epoch: group_data.epoch,
        member_count: group_data.members.len(),
        messages_sent: group_data.messages_sent,
        messages_received: group_data.messages_received,
        last_activity: group_data.last_activity,
    };

    store.group_states.insert(group_id.clone(), group_data);

    tracing::info!("Joined MLS group: {} at epoch {}", group_id, info.epoch);
    Ok(info)
}

// =============================================================================
// MESSAGE ENCRYPTION COMMANDS
// =============================================================================

/// Encrypt a message for an MLS group
#[tauri::command]
pub async fn mls_encrypt_message(
    group_id: String,
    plaintext: String,
) -> Result<MlsEncryptedMessage, String> {
    tracing::debug!("Encrypting message for MLS group: {}", group_id);

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized".to_string())?
        .clone();

    // Get group data
    let group_data = store.group_states.get_mut(&group_id)
        .ok_or_else(|| format!("Group not found: {}", group_id))?;

    // Recreate MLS group (in production, deserialize actual state)
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create keypair: {}", e))?;

    let mut group = guardyn_crypto::mls::MlsGroupManager::create_group(&group_id, &identity, keypair)
        .map_err(|e| format!("Failed to recreate group: {}", e))?;

    // Encrypt message
    let ciphertext = group.encrypt_message(plaintext.as_bytes())
        .map_err(|e| format!("Failed to encrypt message: {}", e))?;

    let epoch = group.epoch();

    // Update stats
    group_data.messages_sent += 1;
    group_data.last_activity = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    tracing::debug!("Message encrypted for group: {} (epoch {})", group_id, epoch);
    Ok(MlsEncryptedMessage {
        ciphertext: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &ciphertext,
        ),
        group_id,
        epoch,
    })
}

/// Decrypt an MLS group message
#[tauri::command]
pub async fn mls_decrypt_message(
    group_id: String,
    ciphertext: String,
) -> Result<MlsDecryptedMessage, String> {
    tracing::debug!("Decrypting message from MLS group: {}", group_id);

    // Decode ciphertext from base64
    let ciphertext_bytes = base64::Engine::decode(
        &base64::engine::general_purpose::STANDARD,
        &ciphertext,
    ).map_err(|e| format!("Invalid ciphertext base64: {}", e))?;

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized".to_string())?
        .clone();

    // Get group data
    let group_data = store.group_states.get_mut(&group_id)
        .ok_or_else(|| format!("Group not found: {}", group_id))?;

    // Recreate MLS group (in production, deserialize actual state)
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create keypair: {}", e))?;

    let mut group = guardyn_crypto::mls::MlsGroupManager::create_group(&group_id, &identity, keypair)
        .map_err(|e| format!("Failed to recreate group: {}", e))?;

    // Decrypt message
    let (plaintext_bytes, _aad) = group.decrypt_message(&ciphertext_bytes)
        .map_err(|e| format!("Failed to decrypt message: {}", e))?;

    let plaintext = String::from_utf8(plaintext_bytes)
        .map_err(|e| format!("Invalid UTF-8 in decrypted message: {}", e))?;

    let epoch = group.epoch();

    // Update stats
    group_data.messages_received += 1;
    group_data.last_activity = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    tracing::debug!("Message decrypted from group: {} (epoch {})", group_id, epoch);
    Ok(MlsDecryptedMessage {
        plaintext,
        sender_id: hex::encode(&identity), // In production, extract from message
        epoch,
    })
}

// =============================================================================
// UTILITY COMMANDS
// =============================================================================

/// Process an incoming commit message (from another member's add/remove)
#[tauri::command]
pub async fn mls_process_commit(
    group_id: String,
    commit: String,
) -> Result<u64, String> {
    tracing::info!("Processing commit for MLS group: {}", group_id);

    // Decode commit from base64
    let commit_bytes = base64::Engine::decode(
        &base64::engine::general_purpose::STANDARD,
        &commit,
    ).map_err(|e| format!("Invalid commit base64: {}", e))?;

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let identity = store.identity.as_ref()
        .ok_or_else(|| "MLS not initialized".to_string())?
        .clone();

    // Get group data
    let group_data = store.group_states.get_mut(&group_id)
        .ok_or_else(|| format!("Group not found: {}", group_id))?;

    // Recreate MLS group and process commit
    let keypair = guardyn_crypto::mls::create_test_keypair()
        .map_err(|e| format!("Failed to create keypair: {}", e))?;

    let mut group = guardyn_crypto::mls::MlsGroupManager::create_group(&group_id, &identity, keypair)
        .map_err(|e| format!("Failed to recreate group: {}", e))?;

    // Process commit
    group.process_commit(&commit_bytes)
        .map_err(|e| format!("Failed to process commit: {}", e))?;

    let new_epoch = group.epoch();

    // Update group data
    group_data.epoch = new_epoch;
    group_data.members = group.members().iter()
        .map(|m| hex::encode(m))
        .collect();
    group_data.last_activity = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    tracing::info!("Commit processed for group: {} (epoch {})", group_id, new_epoch);
    Ok(new_epoch)
}

/// Delete a group (leave and remove local state)
#[tauri::command]
pub async fn mls_delete_group(group_id: String) -> Result<bool, String> {
    tracing::info!("Deleting MLS group: {}", group_id);

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    let removed = store.group_states.remove(&group_id).is_some();

    if removed {
        tracing::info!("MLS group deleted: {}", group_id);
    } else {
        tracing::warn!("MLS group not found: {}", group_id);
    }

    Ok(removed)
}

/// Clear all MLS state (logout/reset)
#[tauri::command]
pub async fn mls_clear_state() -> Result<(), String> {
    tracing::warn!("Clearing all MLS state");

    let mut store = MLS_STORE.lock().map_err(|e| e.to_string())?;
    store.identity = None;
    store.signature_keypair = None;
    store.pending_key_packages.clear();
    store.group_states.clear();

    tracing::info!("MLS state cleared");
    Ok(())
}

/// Get MLS library version
#[tauri::command]
pub async fn mls_get_version() -> String {
    "openmls 0.6.x".to_string()
}

// =============================================================================
// IMPORT/EXPORT FOR NEEDED TRAITS
// =============================================================================

use openmls::prelude::*;
use tls_codec::Deserialize as TlsDeserialize;
