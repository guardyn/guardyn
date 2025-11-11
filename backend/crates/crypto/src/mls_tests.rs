/// Comprehensive MLS Integration Tests
///
/// Tests the full MLS protocol implementation including:
/// - Group creation
/// - Member addition/removal
/// - Message encryption/decryption
/// - Epoch advancement
/// - Multi-member scenarios

#[cfg(test)]
mod mls_integration_tests {
    use guardyn_crypto::mls::{MlsGroupManager, MlsKeyPackage};
    use guardyn_crypto::{CryptoError, Result};

    /// Helper to create a test credential
    fn create_credential(identity: &str) -> Result<openmls::prelude::CredentialWithKey> {
        guardyn_crypto::mls::create_test_credential(identity)
    }

    #[test]
    fn test_create_group() {
        // Alice creates a group
        let alice_identity = b"alice:device1";
        let alice_cred = create_credential("alice:device1").unwrap();

        let group = MlsGroupManager::create_group("test_group_001", alice_identity, alice_cred);

        assert!(group.is_ok());
        let group = group.unwrap();
        assert_eq!(group.epoch(), 0);
        assert_eq!(group.group_id(), b"test_group_001");
    }

    #[test]
    fn test_generate_key_package() {
        // Generate key package for Bob
        let bob_key_package = MlsGroupManager::generate_key_package(b"bob:device1");

        assert!(bob_key_package.is_ok());
        let key_package = bob_key_package.unwrap();

        assert!(!key_package.package_id.is_empty());
        assert!(!key_package.key_package_bytes.is_empty());
        assert_eq!(key_package.credential_identity, b"bob:device1");
    }

    #[test]
    fn test_add_single_member() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_002", b"alice:device1", alice_cred)
                .unwrap();

        assert_eq!(alice_group.members().len(), 1);
        assert_eq!(alice_group.epoch(), 0);

        // Generate key package for Bob
        let bob_key_package = MlsGroupManager::generate_key_package(b"bob:device1").unwrap();

        // Alice adds Bob
        let result = alice_group.add_member(&bob_key_package.key_package_bytes);
        assert!(result.is_ok());

        let (commit, welcome) = result.unwrap();
        assert!(!commit.is_empty());
        assert!(!welcome.is_empty());

        // Verify epoch advanced
        assert_eq!(alice_group.epoch(), 1);

        // Verify member count increased
        assert_eq!(alice_group.members().len(), 2);
    }

    #[test]
    fn test_add_multiple_members() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_003", b"alice:device1", alice_cred)
                .unwrap();

        // Add Bob
        let bob_key_package = MlsGroupManager::generate_key_package(b"bob:device1").unwrap();
        let _ = alice_group.add_member(&bob_key_package.key_package_bytes).unwrap();

        assert_eq!(alice_group.epoch(), 1);
        assert_eq!(alice_group.members().len(), 2);

        // Add Charlie
        let charlie_key_package =
            MlsGroupManager::generate_key_package(b"charlie:device1").unwrap();
        let _ = alice_group
            .add_member(&charlie_key_package.key_package_bytes)
            .unwrap();

        assert_eq!(alice_group.epoch(), 2);
        assert_eq!(alice_group.members().len(), 3);

        // Add Dave
        let dave_key_package = MlsGroupManager::generate_key_package(b"dave:device1").unwrap();
        let _ = alice_group
            .add_member(&dave_key_package.key_package_bytes)
            .unwrap();

        assert_eq!(alice_group.epoch(), 3);
        assert_eq!(alice_group.members().len(), 4);
    }

    #[test]
    fn test_encrypt_decrypt_message() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_004", b"alice:device1", alice_cred)
                .unwrap();

        // Encrypt a message
        let plaintext = b"Hello, MLS group!";
        let aad = b"metadata";

        let ciphertext = alice_group.encrypt_message(plaintext, aad);
        assert!(ciphertext.is_ok());

        let ciphertext = ciphertext.unwrap();
        assert!(!ciphertext.is_empty());
        assert_ne!(ciphertext, plaintext); // Ciphertext should differ from plaintext

        // Decrypt the message (same member)
        let result = alice_group.decrypt_message(&ciphertext);
        assert!(result.is_ok());

        let (decrypted, _aad) = result.unwrap();
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_group_state_serialization() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let alice_group =
            MlsGroupManager::create_group("test_group_005", b"alice:device1", alice_cred)
                .unwrap();

        // Serialize group state
        let state = alice_group.serialize_state();
        assert!(state.is_ok());

        let state = state.unwrap();
        assert_eq!(state.group_id, b"test_group_005");
        assert_eq!(state.epoch, 0);
        assert!(!state.serialized_state.is_empty());
    }

    #[test]
    fn test_encrypt_after_adding_member() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_006", b"alice:device1", alice_cred)
                .unwrap();

        // Add Bob
        let bob_key_package = MlsGroupManager::generate_key_package(b"bob:device1").unwrap();
        let _ = alice_group.add_member(&bob_key_package.key_package_bytes).unwrap();

        // Alice encrypts a message after adding Bob
        let plaintext = b"Welcome, Bob!";
        let ciphertext = alice_group.encrypt_message(plaintext, b"");

        assert!(ciphertext.is_ok());
        let ciphertext = ciphertext.unwrap();

        // Alice can decrypt her own message
        let (decrypted, _) = alice_group.decrypt_message(&ciphertext).unwrap();
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_member_list() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_007", b"alice:device1", alice_cred)
                .unwrap();

        let members = alice_group.members();
        assert_eq!(members.len(), 1);
        assert_eq!(members[0], b"alice:device1");

        // Add Bob
        let bob_key_package = MlsGroupManager::generate_key_package(b"bob:device1").unwrap();
        let _ = alice_group.add_member(&bob_key_package.key_package_bytes).unwrap();

        let members = alice_group.members();
        assert_eq!(members.len(), 2);
        assert!(members.contains(&b"alice:device1".to_vec()));
        assert!(members.contains(&b"bob:device1".to_vec()));
    }

    #[test]
    fn test_epoch_advancement() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_008", b"alice:device1", alice_cred)
                .unwrap();

        assert_eq!(alice_group.epoch(), 0);

        // Each member addition should advance the epoch
        for i in 1..=5 {
            let identity = format!("user{}:device1", i);
            let key_package = MlsGroupManager::generate_key_package(identity.as_bytes()).unwrap();
            let _ = alice_group.add_member(&key_package.key_package_bytes).unwrap();
            assert_eq!(alice_group.epoch(), i);
        }
    }

    #[test]
    fn test_multiple_messages() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_009", b"alice:device1", alice_cred)
                .unwrap();

        // Send multiple messages
        let messages = vec![
            b"First message".to_vec(),
            b"Second message".to_vec(),
            b"Third message with more content".to_vec(),
            b"Final message".to_vec(),
        ];

        for msg in &messages {
            let ciphertext = alice_group.encrypt_message(msg, b"").unwrap();
            let (decrypted, _) = alice_group.decrypt_message(&ciphertext).unwrap();
            assert_eq!(decrypted, *msg);
        }
    }

    #[test]
    fn test_key_package_uniqueness() {
        // Generate multiple key packages for the same identity
        let identity = b"test:device1";

        let pkg1 = MlsGroupManager::generate_key_package(identity).unwrap();
        let pkg2 = MlsGroupManager::generate_key_package(identity).unwrap();

        // Package IDs should be different (random key generation)
        assert_ne!(pkg1.package_id, pkg2.package_id);

        // But identity should be the same
        assert_eq!(pkg1.credential_identity, pkg2.credential_identity);
    }

    #[test]
    fn test_empty_message() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_010", b"alice:device1", alice_cred)
                .unwrap();

        // Try to encrypt empty message
        let plaintext = b"";
        let ciphertext = alice_group.encrypt_message(plaintext, b"");

        assert!(ciphertext.is_ok());
        let ciphertext = ciphertext.unwrap();

        // Decrypt should work
        let (decrypted, _) = alice_group.decrypt_message(&ciphertext).unwrap();
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_large_message() {
        // Alice creates a group
        let alice_cred = create_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_011", b"alice:device1", alice_cred)
                .unwrap();

        // Encrypt a large message (1 MB)
        let plaintext = vec![b'X'; 1024 * 1024];
        let ciphertext = alice_group.encrypt_message(&plaintext, b"");

        assert!(ciphertext.is_ok());
        let ciphertext = ciphertext.unwrap();

        // Decrypt should work
        let (decrypted, _) = alice_group.decrypt_message(&ciphertext).unwrap();
        assert_eq!(decrypted.len(), plaintext.len());
        assert_eq!(decrypted, plaintext);
    }
}

#[cfg(test)]
mod mls_error_handling_tests {
    use super::*;
    use guardyn_crypto::mls::MlsGroupManager;

    #[test]
    fn test_decrypt_invalid_ciphertext() {
        let alice_cred = guardyn_crypto::mls::create_test_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_error_001", b"alice:device1", alice_cred)
                .unwrap();

        // Try to decrypt invalid ciphertext
        let invalid_ciphertext = b"not a valid MLS message";
        let result = alice_group.decrypt_message(invalid_ciphertext);

        assert!(result.is_err());
    }

    #[test]
    fn test_add_invalid_key_package() {
        let alice_cred = guardyn_crypto::mls::create_test_credential("alice:device1").unwrap();
        let mut alice_group =
            MlsGroupManager::create_group("test_group_error_002", b"alice:device1", alice_cred)
                .unwrap();

        // Try to add member with invalid key package
        let invalid_key_package = b"not a valid key package";
        let result = alice_group.add_member(invalid_key_package);

        assert!(result.is_err());
    }
}
