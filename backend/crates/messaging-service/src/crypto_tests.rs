/// Integration tests for E2EE messaging
///
/// Tests X3DH key exchange and Double Ratchet encryption/decryption

#[cfg(test)]
mod e2ee_integration_tests {
    use guardyn_crypto::{
        x3dh::{IdentityKeyPair, SignedPreKey, OneTimePreKey, X3DHProtocol, KeyBundle},
        double_ratchet::DoubleRatchet,
    };

    #[test]
    fn test_x3dh_key_agreement_basic() {
        // Alice (sender) and Bob (receiver) setup
        let alice_identity = IdentityKeyPair::generate().expect("Failed to generate Alice identity");
        let bob_identity = IdentityKeyPair::generate().expect("Failed to generate Bob identity");

        // Bob publishes key bundle
        let bob_signed_prekey = SignedPreKey::generate(1, &bob_identity)
            .expect("Failed to generate Bob signed pre-key");
        let bob_one_time_key = OneTimePreKey::generate()
            .expect("Failed to generate Bob one-time key");

        let bob_bundle = KeyBundle {
            identity_key: bob_identity.public_bytes(),
            signed_pre_key: bob_signed_prekey.public_bytes(),
            signed_pre_key_signature: bob_signed_prekey.signature.clone(),
            one_time_pre_keys: vec![bob_one_time_key.public_bytes()],
            created_at: Some(guardyn_crypto::x3dh::Timestamp {
                seconds: chrono::Utc::now().timestamp(),
                nanos: 0,
            }),
        };

        // Alice initiates key agreement
        // TODO: Complete test when X3DH API is fully implemented
        // For now, this tests that key bundle structure is correct
        assert!(!bob_bundle.identity_key.is_empty());
        assert!(!bob_bundle.signed_pre_key.is_empty());
        assert!(!bob_bundle.signed_pre_key_signature.is_empty());
        assert_eq!(bob_bundle.one_time_pre_keys.len(), 1);
    }

    #[test]
    fn test_double_ratchet_basic_exchange() {
        use guardyn_crypto::double_ratchet::DoubleRatchet;
        use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret};
        use rand::rngs::OsRng;

        // Shared secret from X3DH (32 bytes)
        let shared_secret = [42u8; 32];

        // Bob's initial DH public key
        let bob_dh_secret = StaticSecret::random_from_rng(OsRng);
        let bob_dh_public = X25519PublicKey::from(&bob_dh_secret);

        // Alice initializes as sender
        let mut alice_ratchet = DoubleRatchet::init_alice(&shared_secret, bob_dh_public)
            .expect("Failed to initialize Alice ratchet");

        // Bob initializes as receiver
        let mut bob_ratchet = DoubleRatchet::init_bob(&shared_secret)
            .expect("Failed to initialize Bob ratchet");

        // Alice sends message to Bob
        let plaintext = b"Hello Bob from Alice!";
        let associated_data = b"message_id_1";

        let encrypted_msg = alice_ratchet.encrypt(plaintext, associated_data)
            .expect("Failed to encrypt message");

        // Bob receives and decrypts
        let decrypted = bob_ratchet.decrypt(&encrypted_msg, associated_data)
            .expect("Failed to decrypt message");

        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_double_ratchet_multiple_messages() {
        use guardyn_crypto::double_ratchet::DoubleRatchet;
        use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret};
        use rand::rngs::OsRng;

        let shared_secret = [42u8; 32];
        let bob_dh_secret = StaticSecret::random_from_rng(OsRng);
        let bob_dh_public = X25519PublicKey::from(&bob_dh_secret);

        let mut alice = DoubleRatchet::init_alice(&shared_secret, bob_dh_public)
            .expect("Alice init failed");
        let mut bob = DoubleRatchet::init_bob(&shared_secret)
            .expect("Bob init failed");

        // Send 5 messages
        for i in 1..=5 {
            let plaintext = format!("Message {}", i);
            let ad = format!("msg_id_{}", i);

            let encrypted = alice.encrypt(plaintext.as_bytes(), ad.as_bytes())
                .expect("Encryption failed");

            let decrypted = bob.decrypt(&encrypted, ad.as_bytes())
                .expect("Decryption failed");

            assert_eq!(decrypted, plaintext.as_bytes());
        }
    }

    #[test]
    fn test_ratchet_session_id_generation() {
        use crate::models::RatchetSession;

        // Test canonical ordering
        let id1 = RatchetSession::session_id("alice", "dev1", "bob", "dev2");
        let id2 = RatchetSession::session_id("bob", "dev2", "alice", "dev1");

        assert_eq!(id1, id2, "Session IDs should be identical regardless of order");

        // Test different users
        let id3 = RatchetSession::session_id("alice", "dev1", "charlie", "dev3");
        assert_ne!(id1, id3, "Different user pairs should have different session IDs");
    }

    // TODO: Add tests for:
    // - Out-of-order message delivery
    // - Session serialization/deserialization
    // - Key rotation after N messages
    // - Error handling (invalid ciphertext, wrong AD)
    // - Session recovery after connection loss
}

#[cfg(test)]
mod e2ee_database_tests {
    use super::*;
    use crate::models::RatchetSession;

    // TODO: Add database integration tests
    // - Store/retrieve ratchet sessions
    // - Update session state after encryption
    // - List all sessions for a device
    // - Delete sessions
}

#[cfg(test)]
mod e2ee_handler_tests {
    use super::*;

    // TODO: Add handler integration tests
    // - Send E2EE message (full flow)
    // - Receive E2EE message with decryption
    // - Handle missing session (require key exchange)
    // - Handle decryption errors
}
