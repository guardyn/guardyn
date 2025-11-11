/// MLS (Messaging Layer Security) for group chat encryption
/// 
/// Implementation using OpenMLS library with RustCrypto backend.
/// Provides secure group communication with forward secrecy, post-compromise security,
/// and membership changes (add/remove members).

use crate::{CryptoError, Result};
use openmls::prelude::*;
use openmls_basic_credential::SignatureKeyPair;
use openmls_rust_crypto::OpenMlsRustCrypto;
use openmls_traits::types::Ciphersuite;
use serde::{Deserialize, Serialize};

/// MLS ciphersuite configuration
/// Using MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519 for performance and security balance
const MLS_CIPHERSUITE: Ciphersuite =
    Ciphersuite::MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519;

/// Key package with metadata
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsKeyPackage {
    pub package_id: Vec<u8>,
    pub key_package_bytes: Vec<u8>,
    pub credential_identity: Vec<u8>,
}

/// Group state for serialization/deserialization
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MlsGroupState {
    pub group_id: Vec<u8>,
    pub epoch: u64,
    pub serialized_state: Vec<u8>,
}

/// MLS Group Manager
/// 
/// Manages MLS group state, member operations, and message encryption/decryption.
/// Each instance represents a single MLS group from one member's perspective.
pub struct MlsGroupManager {
    mls_group: MlsGroup,
    crypto_backend: OpenMlsRustCrypto,
    credential_bundle: CredentialWithKey,
}

impl MlsGroupManager {
    /// Create a new MLS group as the creator
    /// 
    /// # Arguments
    /// * `group_id` - Unique group identifier
    /// * `creator_identity` - Creator's identity (user_id:device_id)
    /// * `credential_bundle` - Creator's credential with signing key
    /// 
    /// # Returns
    /// New MlsGroupManager instance with initialized group
    pub fn create_group(
        group_id: &str,
        creator_identity: &[u8],
        credential_bundle: CredentialWithKey,
    ) -> Result<Self> {
        let crypto_backend = OpenMlsRustCrypto::default();
        let group_id_bytes = group_id.as_bytes().to_vec();

        // Configure MLS group
        let group_config = MlsGroupCreateConfig::builder()
            .ciphersuite(MLS_CIPHERSUITE)
            .use_ratchet_tree_extension(true)
            .build();

        // Create MLS group
        let mls_group = MlsGroup::new(
            &crypto_backend,
            &group_config,
            GroupId::from_slice(&group_id_bytes),
            credential_bundle.clone(),
        )
        .map_err(|e| CryptoError::Protocol(format!("Failed to create MLS group: {:?}", e)))?;

        Ok(Self {
            mls_group,
            crypto_backend,
            credential_bundle,
        })
    }

    /// Join an existing MLS group using a Welcome message
    /// 
    /// # Arguments
    /// * `welcome_bytes` - Serialized Welcome message from group admin
    /// * `credential_bundle` - Member's credential with signing key
    /// * `key_package` - Member's key package used in the Welcome
    /// 
    /// # Returns
    /// New MlsGroupManager instance for the joined group
    pub fn join_group(
        welcome_bytes: &[u8],
        credential_bundle: CredentialWithKey,
        key_package: KeyPackage,
    ) -> Result<Self> {
        let crypto_backend = OpenMlsRustCrypto::default();

        // Deserialize Welcome message
        let welcome = MlsMessageIn::tls_deserialize(&mut welcome_bytes.as_ref())
            .map_err(|e| CryptoError::Protocol(format!("Failed to deserialize Welcome: {:?}", e)))?;

        // Process Welcome and join group
        let mls_group = MlsGroup::new_from_welcome(
            &crypto_backend,
            &group_config,
            welcome,
            Some(vec![key_package.hash_ref(&crypto_backend).map_err(|e| {
                CryptoError::Protocol(format!("Failed to compute key package hash: {:?}", e))
            })?]),
        )
        .map_err(|e| CryptoError::Protocol(format!("Failed to join group: {:?}", e)))?;

        Ok(Self {
            mls_group,
            crypto_backend,
            credential_bundle,
        })
    }

    /// Generate a key package for this member
    /// 
    /// Key packages are pre-generated and stored on the server.
    /// They are used by group admins to add members to groups.
    /// 
    /// # Arguments
    /// * `identity` - Member identity (user_id:device_id)
    /// 
    /// # Returns
    /// MlsKeyPackage with serialized key package and metadata
    pub fn generate_key_package(identity: &[u8]) -> Result<MlsKeyPackage> {
        let crypto_backend = OpenMlsRustCrypto::default();

        // Create credential
        let credential = Credential::new(identity.to_vec(), CredentialType::Basic)
            .map_err(|e| CryptoError::Protocol(format!("Failed to create credential: {:?}", e)))?;

        // Generate signature keypair
        let signature_keypair = SignatureKeyPair::new(MLS_CIPHERSUITE.signature_algorithm())
            .map_err(|e| CryptoError::Protocol(format!("Failed to generate signature key: {:?}", e)))?;

        // Create credential bundle
        let credential_bundle = CredentialWithKey {
            credential: credential.clone(),
            signature_key: signature_keypair.into(),
        };

        // Generate key package
        let key_package = KeyPackage::builder()
            .build(
                MLS_CIPHERSUITE,
                &crypto_backend,
                &credential_bundle.signature_key,
                credential_bundle.credential.clone(),
            )
            .map_err(|e| CryptoError::Protocol(format!("Failed to build key package: {:?}", e)))?;

        // Serialize key package
        let key_package_bytes = key_package
            .tls_serialize_detached()
            .map_err(|e| CryptoError::Protocol(format!("Failed to serialize key package: {:?}", e)))?;

        // Get package ID
        let package_id = key_package
            .hash_ref(&crypto_backend)
            .map_err(|e| CryptoError::Protocol(format!("Failed to compute package hash: {:?}", e)))?
            .as_slice()
            .to_vec();

        Ok(MlsKeyPackage {
            package_id,
            key_package_bytes,
            credential_identity: identity.to_vec(),
        })
    }

    /// Add member to group
    /// 
    /// Creates a Commit message with Welcome for the new member.
    /// The Welcome message must be sent to the new member separately.
    /// 
    /// # Arguments
    /// * `member_key_package_bytes` - Serialized KeyPackage of the member to add
    /// 
    /// # Returns
    /// Tuple of (commit_bytes, welcome_bytes) - commit for group, welcome for new member
    pub fn add_member(&mut self, member_key_package_bytes: &[u8]) -> Result<(Vec<u8>, Vec<u8>)> {
        // Deserialize key package
        let key_package = KeyPackage::tls_deserialize(&mut member_key_package_bytes.as_ref())
            .map_err(|e| {
                CryptoError::Protocol(format!("Failed to deserialize key package: {:?}", e))
            })?;

        // Propose adding the member
        let (commit, welcome, _group_info) = self
            .mls_group
            .add_members(&self.crypto_backend, &self.credential_bundle.signature_key, &[key_package])
            .map_err(|e| CryptoError::Protocol(format!("Failed to add member: {:?}", e)))?;

        // Merge commit (apply changes to local state)
        self.mls_group
            .merge_pending_commit(&self.crypto_backend)
            .map_err(|e| CryptoError::Protocol(format!("Failed to merge commit: {:?}", e)))?;

        // Serialize commit and welcome
        let commit_bytes = commit
            .tls_serialize_detached()
            .map_err(|e| CryptoError::Protocol(format!("Failed to serialize commit: {:?}", e)))?;

        let welcome_bytes = welcome
            .ok_or_else(|| CryptoError::Protocol("No Welcome message generated".to_string()))?
            .tls_serialize_detached()
            .map_err(|e| CryptoError::Protocol(format!("Failed to serialize welcome: {:?}", e)))?;

        Ok((commit_bytes, welcome_bytes))
    }

    /// Remove member from group
    /// 
    /// Creates a Commit message removing the specified member.
    /// The commit must be distributed to all remaining members.
    /// 
    /// # Arguments
    /// * `member_index` - Index of the member to remove (from leaf nodes)
    /// 
    /// # Returns
    /// Serialized commit message
    pub fn remove_member(&mut self, member_index: LeafNodeIndex) -> Result<Vec<u8>> {
        // Propose removing the member
        let (commit, _welcome, _group_info) = self
            .mls_group
            .remove_members(&self.crypto_backend, &self.credential_bundle.signature_key, &[member_index])
            .map_err(|e| CryptoError::Protocol(format!("Failed to remove member: {:?}", e)))?;

        // Merge commit (apply changes to local state)
        self.mls_group
            .merge_pending_commit(&self.crypto_backend)
            .map_err(|e| CryptoError::Protocol(format!("Failed to merge commit: {:?}", e)))?;

        // Serialize commit
        let commit_bytes = commit
            .tls_serialize_detached()
            .map_err(|e| CryptoError::Protocol(format!("Failed to serialize commit: {:?}", e)))?;

        Ok(commit_bytes)
    }

    /// Process incoming commit message from another member
    /// 
    /// Updates group state based on membership changes or epoch advancement.
    /// 
    /// # Arguments
    /// * `commit_bytes` - Serialized commit message
    /// 
    /// # Returns
    /// Ok(()) if commit processed successfully
    pub fn process_commit(&mut self, commit_bytes: &[u8]) -> Result<()> {
        // Deserialize commit
        let commit = MlsMessageIn::tls_deserialize(&mut commit_bytes.as_ref())
            .map_err(|e| CryptoError::Protocol(format!("Failed to deserialize commit: {:?}", e)))?;

        // Process commit
        self.mls_group
            .process_message(&self.crypto_backend, commit)
            .map_err(|e| CryptoError::Protocol(format!("Failed to process commit: {:?}", e)))?;

        Ok(())
    }

    /// Encrypt a group message
    /// 
    /// # Arguments
    /// * `plaintext` - Message plaintext bytes
    /// 
    /// # Returns
    /// Serialized encrypted MLS message
    /// 
    /// Note: OpenMLS 0.5 removed AAD parameter from create_message
    pub fn encrypt_message(&mut self, plaintext: &[u8]) -> Result<Vec<u8>> {
        // Create application message
        let message = self
            .mls_group
            .create_message(&self.crypto_backend, &self.credential_bundle.signature_key, plaintext)
            .map_err(|e| CryptoError::Encryption(format!("Failed to create message: {:?}", e)))?;

        // Serialize message
        let ciphertext = message
            .tls_serialize_detached()
            .map_err(|e| CryptoError::Encryption(format!("Failed to serialize message: {:?}", e)))?;

        Ok(ciphertext)
    }

    /// Decrypt a group message
    /// 
    /// # Arguments
    /// * `ciphertext` - Serialized encrypted MLS message
    /// 
    /// # Returns
    /// Tuple of (plaintext, aad) - decrypted message and associated data
    pub fn decrypt_message(&mut self, ciphertext: &[u8]) -> Result<(Vec<u8>, Vec<u8>)> {
        // Deserialize message
        let message = MlsMessageIn::tls_deserialize(&mut ciphertext.as_ref())
            .map_err(|e| CryptoError::Decryption(format!("Failed to deserialize message: {:?}", e)))?;

        // Process and decrypt message
        let processed_message = self
            .mls_group
            .process_message(&self.crypto_backend, message)
            .map_err(|e| CryptoError::Decryption(format!("Failed to process message: {:?}", e)))?;

        // Extract plaintext
        match processed_message.into_content() {
            ProcessedMessageContent::ApplicationMessage(app_msg) => {
                Ok((app_msg.into_bytes(), vec![]))
            }
            ProcessedMessageContent::ProposalMessage(_) => {
                Err(CryptoError::Protocol("Received proposal, not application message".to_string()))
            }
            ProcessedMessageContent::ExternalJoinProposalMessage(_) => {
                Err(CryptoError::Protocol("Received external join proposal".to_string()))
            }
            ProcessedMessageContent::StagedCommitMessage(_) => {
                Err(CryptoError::Protocol("Received commit, not application message".to_string()))
            }
        }
    }

    /// Serialize group state for storage
    /// 
    /// # Returns
    /// MlsGroupState with serialized group data
    pub fn serialize_state(&self) -> Result<MlsGroupState> {
        let serialized_state = self
            .mls_group
            .export_secret(&self.crypto_backend, "group_state", &[], 32)
            .map_err(|e| CryptoError::Protocol(format!("Failed to export group state: {:?}", e)))?;

        Ok(MlsGroupState {
            group_id: self.mls_group.group_id().as_slice().to_vec(),
            epoch: self.mls_group.epoch().as_u64(),
            serialized_state,
        })
    }

    /// Get current epoch number
    pub fn epoch(&self) -> u64 {
        self.mls_group.epoch().as_u64()
    }

    /// Get group ID
    pub fn group_id(&self) -> Vec<u8> {
        self.mls_group.group_id().as_slice().to_vec()
    }

    /// Get list of member identities in the group
    pub fn members(&self) -> Vec<Vec<u8>> {
        self.mls_group
            .members()
            .map(|member| member.credential.identity().to_vec())
            .collect()
    }
}

/// Create a test credential (helper for testing and initial development)
///
/// **SECURITY WARNING**: This is for testing only. In production, credentials
/// should be generated securely and stored with proper key management.
pub fn create_test_credential(identity: &str) -> Result<CredentialWithKey> {
    let identity_bytes = identity.as_bytes().to_vec();
    let credential = Credential::new(identity_bytes, CredentialType::Basic)
        .map_err(|e| CryptoError::Protocol(format!("Failed to create credential: {:?}", e)))?;

    let signature_keypair = SignatureKeyPair::new(MLS_CIPHERSUITE.signature_algorithm())
        .map_err(|e| CryptoError::Protocol(format!("Failed to generate signature key: {:?}", e)))?;

    Ok(CredentialWithKey {
        credential,
        signature_key: signature_keypair.into(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_credential(identity: &str) -> Result<CredentialWithKey> {
        let identity_bytes = identity.as_bytes().to_vec();
        let credential = Credential::new(identity_bytes, CredentialType::Basic)
            .map_err(|e| CryptoError::Protocol(format!("Failed to create credential: {:?}", e)))?;

        let signature_keypair = SignatureKeyPair::new(MLS_CIPHERSUITE.signature_algorithm())
            .map_err(|e| CryptoError::Protocol(format!("Failed to generate signature key: {:?}", e)))?;

        Ok(CredentialWithKey {
            credential,
            signature_key: signature_keypair.into(),
        })
    }

    #[test]
    fn test_mls_group_creation() {
        let alice_cred = create_test_credential("alice:device1").unwrap();
        let group = MlsGroupManager::create_group("test_group", b"alice:device1", alice_cred);
        assert!(group.is_ok());

        let group = group.unwrap();
        assert_eq!(group.epoch(), 0);
        assert_eq!(group.members().len(), 1);
    }

    #[test]
    fn test_key_package_generation() {
        let key_package = MlsGroupManager::generate_key_package(b"bob:device1");
        assert!(key_package.is_ok());

        let key_package = key_package.unwrap();
        assert!(!key_package.package_id.is_empty());
        assert!(!key_package.key_package_bytes.is_empty());
        assert_eq!(key_package.credential_identity, b"bob:device1");
    }

    #[test]
    fn test_add_member_to_group() {
        // Create group with Alice
        let alice_cred = create_test_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group", b"alice:device1", alice_cred).unwrap();

        // Generate key package for Bob
        let bob_key_package = MlsGroupManager::generate_key_package(b"bob:device1").unwrap();

        // Alice adds Bob
        let result = alice_group.add_member(&bob_key_package.key_package_bytes);
        assert!(result.is_ok());

        let (commit, welcome) = result.unwrap();
        assert!(!commit.is_empty());
        assert!(!welcome.is_empty());
        assert_eq!(alice_group.epoch(), 1); // Epoch advanced
        assert_eq!(alice_group.members().len(), 2); // Alice + Bob
    }

    #[test]
    fn test_encrypt_decrypt_message() {
        // Create group with Alice
        let alice_cred = create_test_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group", b"alice:device1", alice_cred.clone())
                .unwrap();

        // Encrypt message
        let plaintext = b"Hello, MLS group!";
        let aad = b"metadata";
        let ciphertext = alice_group.encrypt_message(plaintext, aad);
        assert!(ciphertext.is_ok());

        // Decrypt message (same member)
        let ciphertext = ciphertext.unwrap();
        let result = alice_group.decrypt_message(&ciphertext);
        assert!(result.is_ok());

        let (decrypted, _aad) = result.unwrap();
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_serialize_group_state() {
        let alice_cred = create_test_credential("alice:device1").unwrap();
        let alice_group =
            MlsGroupManager::create_group("test_group", b"alice:device1", alice_cred).unwrap();

        let state = alice_group.serialize_state();
        assert!(state.is_ok());

        let state = state.unwrap();
        assert_eq!(state.group_id, b"test_group");
        assert_eq!(state.epoch, 0);
        assert!(!state.serialized_state.is_empty());
    }
}
