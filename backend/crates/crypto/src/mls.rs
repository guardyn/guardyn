/// MLS (Messaging Layer Security) for group chat encryption
///
/// Implementation using OpenMLS library with RustCrypto backend.
/// Provides secure group communication with forward secrecy, post-compromise security,
/// and membership changes (add/remove members).

use crate::{CryptoError, Result};
use openmls::prelude::*;
use openmls_basic_credential::SignatureKeyPair;
use openmls_rust_crypto::{OpenMlsRustCrypto, RustCrypto};
use serde::{Deserialize, Serialize};
use tls_codec::{Deserialize as TlsDeserialize, Serialize as TlsSerialize};

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
    credential_with_key: CredentialWithKey,
    signature_keypair: SignatureKeyPair,  // Store the keypair for signing operations
}

impl MlsGroupManager {
    /// Create a new MLS group as the creator
    ///
    /// # Arguments
    /// * `group_id` - Unique group identifier
    /// * `creator_identity` - Creator's identity (user_id:device_id)
    /// * `signature_keypair` - Creator's signature keypair for signing operations
    ///
    /// # Returns
    /// New MlsGroupManager instance with initialized group
    pub fn create_group(
        group_id: &str,
        creator_identity: &[u8],
        signature_keypair: SignatureKeyPair,
    ) -> Result<Self> {
        let crypto_backend = OpenMlsRustCrypto::default();
        let group_id_bytes = group_id.as_bytes().to_vec();

        // Create credential (OpenMLS 0.7 API: credential_type first, then identity)
        let credential = Credential::new(CredentialType::Basic, creator_identity.to_vec());

        // Create credential with key bundle
        let credential_with_key = CredentialWithKey {
            credential: credential.clone(),
            signature_key: signature_keypair.public().into(),
        };

        // Configure MLS group
        let group_config = MlsGroupCreateConfig::builder()
            .ciphersuite(MLS_CIPHERSUITE)
            .use_ratchet_tree_extension(true)
            .build();

        // Create MLS group (OpenMLS 0.7 API: provider, signer, group_config, group_id, credential)
        let mls_group = MlsGroup::new(
            &crypto_backend,
            &signature_keypair,
            &group_config,
            credential_with_key.clone(),
        )
        .map_err(|e| CryptoError::Protocol(format!("Failed to create MLS group: {:?}", e)))?;

        Ok(Self {
            mls_group,
            crypto_backend,
            credential_with_key,
            signature_keypair,
        })
    }

    /// Join an existing MLS group using a Welcome message
    ///
    /// # Arguments
    /// * `welcome_bytes` - Serialized Welcome message from group admin
    /// * `signature_keypair` - Member's signature keypair for signing operations
    /// * `key_package` - Member's key package used in the Welcome
    ///
    /// # Returns
    /// New MlsGroupManager instance for the joined group
    pub fn join_group(
        welcome_bytes: &[u8],
        signature_keypair: SignatureKeyPair,
        key_package: KeyPackage,
    ) -> Result<Self> {
        let crypto_backend = OpenMlsRustCrypto::default();

        // Get identity from key package credential
        let credential = key_package.leaf_node().credential();

        // Create credential with key bundle
        let credential_with_key = CredentialWithKey {
            credential: credential.clone(),
            signature_key: signature_keypair.public().into(),
        };

        // Deserialize Welcome message (OpenMLS 0.6 uses tls_deserialize)
        let mut reader = welcome_bytes.as_ref();
        let mls_message_in = MlsMessageIn::tls_deserialize(&mut reader)
            .map_err(|e| CryptoError::Protocol(format!("Failed to deserialize Welcome: {:?}", e)))?;

        // Extract Welcome from MlsMessageIn
        let welcome = match mls_message_in.extract() {
            MlsMessageBodyIn::Welcome(w) => w,
            _ => return Err(CryptoError::Protocol("Expected Welcome message".to_string())),
        };

        // Configure MLS group (needed for joining)
        let group_config = MlsGroupJoinConfig::default();

        // Process Welcome and join group (OpenMLS 0.6 API)
        // For ratchet_tree, we need to pass None or extract it from Welcome
        let mls_group = StagedWelcome::new_from_welcome(
            &crypto_backend,
            &group_config,
            welcome,
            None,  // ratchet_tree is optional, usually included in Welcome
        )
        .map_err(|e| CryptoError::Protocol(format!("Failed to stage welcome: {:?}", e)))?
        .into_group(&crypto_backend)
        .map_err(|e| CryptoError::Protocol(format!("Failed to join group: {:?}", e)))?;

        Ok(Self {
            mls_group,
            crypto_backend,
            credential_with_key,
            signature_keypair,
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

        // Create credential (OpenMLS 0.6: credential_type first)
        let credential = Credential::new(CredentialType::Basic, identity.to_vec());

        // Generate signature keypair
        let signature_keypair = SignatureKeyPair::new(MLS_CIPHERSUITE.signature_algorithm())
            .map_err(|e| CryptoError::Protocol(format!("Failed to generate signature key: {:?}", e)))?;

        // Create credential with key bundle
        let credential_with_key = CredentialWithKey {
            credential: credential.clone(),
            signature_key: signature_keypair.public().into(),
        };

        // Generate key package bundle (OpenMLS 0.6 returns KeyPackageBundle)
        let key_package_bundle = KeyPackage::builder()
            .build(
                MLS_CIPHERSUITE,
                &crypto_backend,
                &signature_keypair,
                credential_with_key.clone(),
            )
            .map_err(|e| CryptoError::Protocol(format!("Failed to build key package: {:?}", e)))?;

        // Extract key package from bundle
        let key_package = key_package_bundle.key_package();

        // Serialize key package
        let key_package_bytes = key_package
            .tls_serialize_detached()
            .map_err(|e| CryptoError::Protocol(format!("Failed to serialize key package: {:?}", e)))?;

        // Get package ID (use RustCrypto for hash_ref as it implements OpenMlsCrypto)
        let rust_crypto = RustCrypto::default();
        let package_id = key_package
            .hash_ref(&rust_crypto)
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
        // Deserialize key package (OpenMLS 0.6 - KeyPackageIn needs validation)
        let mut reader = member_key_package_bytes.as_ref();
        let key_package_in = KeyPackageIn::tls_deserialize(&mut reader)
            .map_err(|e| {
                CryptoError::Protocol(format!("Failed to deserialize key package: {:?}", e))
            })?;

        // Validate and convert KeyPackageIn to KeyPackage
        let rust_crypto = RustCrypto::default();
        let key_package = key_package_in.validate(&rust_crypto, ProtocolVersion::default())
            .map_err(|e| {
                CryptoError::Protocol(format!("Failed to validate key package: {:?}", e))
            })?;

        // Propose adding the member
        let (commit, welcome, _group_info) = self
            .mls_group
            .add_members(&self.crypto_backend, &self.signature_keypair, &[key_package])
            .map_err(|e| CryptoError::Protocol(format!("Failed to add member: {:?}", e)))?;

        // Merge commit (apply changes to local state)
        self.mls_group
            .merge_pending_commit(&self.crypto_backend)
            .map_err(|e| CryptoError::Protocol(format!("Failed to merge commit: {:?}", e)))?;

        // Serialize commit and welcome (in OpenMLS 0.6, welcome is MlsMessageOut not Option)
        let commit_bytes = commit
            .tls_serialize_detached()
            .map_err(|e| CryptoError::Protocol(format!("Failed to serialize commit: {:?}", e)))?;

        let welcome_bytes = welcome
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
            .remove_members(&self.crypto_backend, &self.signature_keypair, &[member_index])
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
        // Deserialize commit (OpenMLS 0.6)
        let mut reader = commit_bytes.as_ref();
        let commit = MlsMessageIn::tls_deserialize(&mut reader)
            .map_err(|e| CryptoError::Protocol(format!("Failed to deserialize commit: {:?}", e)))?;

        // Convert MlsMessageIn to ProtocolMessage for processing
        let protocol_message: ProtocolMessage = commit.try_into()
            .map_err(|e| CryptoError::Protocol(format!("Failed to convert message: {:?}", e)))?;

        // Process commit (OpenMLS 0.6 API - pass message by reference)
        let _processed = self.mls_group
            .process_message(&self.crypto_backend, protocol_message)
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
            .create_message(&self.crypto_backend, &self.signature_keypair, plaintext)
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
        // Deserialize message (OpenMLS 0.6)
        let mut reader = ciphertext.as_ref();
        let message = MlsMessageIn::tls_deserialize(&mut reader)
            .map_err(|e| CryptoError::Decryption(format!("Failed to deserialize message: {:?}", e)))?;

        // Convert MlsMessageIn to ProtocolMessage for processing
        let protocol_message: ProtocolMessage = message.try_into()
            .map_err(|e| CryptoError::Decryption(format!("Failed to convert message: {:?}", e)))?;

        // Process and decrypt message (OpenMLS 0.6 - provider first, message as ProtocolMessage)
        let processed_message = self
            .mls_group
            .process_message(&self.crypto_backend, protocol_message)
            .map_err(|e| CryptoError::Decryption(format!("Failed to process message: {:?}", e)))?;

        // Extract plaintext from ProcessedMessage (OpenMLS 0.6)
        // We need to consume the ProcessedMessage to get the bytes
        let content = processed_message.into_content();
        match content {
            ProcessedMessageContent::ApplicationMessage(app_msg) => {
                // Now we own app_msg and can call into_bytes()
                let bytes = app_msg.into_bytes();
                Ok((bytes, vec![]))
            }
            ProcessedMessageContent::ProposalMessage(_) => {
                let err_msg = String::from("Unexpected") + " " + "proposal";
                Err(CryptoError::Protocol(err_msg))
            }
            ProcessedMessageContent::StagedCommitMessage(_) => {
                let err_msg = String::from("Unexpected") + " " + "commit";
                Err(CryptoError::Protocol(err_msg))
            }
            _ => {
                Err(CryptoError::Protocol("Unknown message type".to_string()))
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
            .map(|member| {
                // In OpenMLS 0.6, credentials are accessed via serialization
                // For Basic credentials, identity is the serialized form
                member.credential.serialized_content().to_vec()
            })
            .collect()
    }
}

/// Create a test credential (helper for testing and initial development)
///
/// **SECURITY WARNING**: This is for testing only. In production, credentials
/// Test helper to create a signature keypair for testing
///
/// ⚠️ WARNING: This is for testing only! In production, signature keypairs
/// should be generated securely and stored with proper key management.
pub fn create_test_keypair() -> Result<SignatureKeyPair> {
    let signature_keypair = SignatureKeyPair::new(MLS_CIPHERSUITE.signature_algorithm())
        .map_err(|e| CryptoError::Protocol(format!("Failed to generate signature key: {:?}", e)))?;
    Ok(signature_keypair)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_keypair() -> Result<SignatureKeyPair> {
        let signature_keypair = SignatureKeyPair::new(MLS_CIPHERSUITE.signature_algorithm())
            .map_err(|e| CryptoError::Protocol(format!("Failed to generate signature key: {:?}", e)))?;
        Ok(signature_keypair)
    }

    #[test]
    fn test_mls_group_creation() {
        let alice_keypair = create_test_keypair().unwrap();
        let alice_id = b"alice_device1";
        let group = MlsGroupManager::create_group("test_group", alice_id, alice_keypair);
        assert!(group.is_ok());

        let group = group.unwrap();
        assert_eq!(group.epoch(), 0);
        assert_eq!(group.members().len(), 1);
    }

    #[test]
    fn test_key_package_generation() {
        let bob_id = b"bob_device1";
        let key_package = MlsGroupManager::generate_key_package(bob_id);
        assert!(key_package.is_ok());

        let key_package = key_package.unwrap();
        assert!(!key_package.package_id.is_empty());
        assert!(!key_package.key_package_bytes.is_empty());
        assert_eq!(key_package.credential_identity, bob_id);
    }

    #[test]
    fn test_add_member_to_group() {
        // Create group with Alice
        let alice_keypair = create_test_keypair().unwrap();
        let alice_id = b"alice_device1";
        let mut alice_group =
            MlsGroupManager::create_group("test_group", alice_id, alice_keypair).unwrap();

        // Generate key package for Bob
        let bob_id = b"bob_device1";
        let bob_key_package = MlsGroupManager::generate_key_package(bob_id).unwrap();

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
        let alice_keypair = create_test_keypair().unwrap();
        let alice_id = b"alice_device1";
        let mut alice_group =
            MlsGroupManager::create_group("test_group", alice_id, alice_keypair)
                .unwrap();

        // Encrypt message
        let plaintext = b"Hello, MLS group!";
        let ciphertext = alice_group.encrypt_message(plaintext);
        assert!(ciphertext.is_ok());

        // Decrypt message (same member)
        let ciphertext = ciphertext.unwrap();
        let result = alice_group.decrypt_message(&ciphertext);
        assert!(result.is_ok());

        let (decrypted, _aad) = result.unwrap();
        assert_eq!(decrypted, plaintext.to_vec());
    }

    #[test]
    fn test_serialize_group_state() {
        let alice_keypair = create_test_keypair().unwrap();
        let alice_id = b"alice_device1";
        let alice_group =
            MlsGroupManager::create_group("test_group", alice_id, alice_keypair).unwrap();

        let state = alice_group.serialize_state();
        assert!(state.is_ok());

        let state = state.unwrap();
        let group_id_str = "test_group";
        let group_id_bytes = group_id_str.as_bytes().to_vec();
        assert_eq!(state.group_id, group_id_bytes);
        assert_eq!(state.epoch, 0);
        assert!(!state.serialized_state.is_empty());
    }
}
