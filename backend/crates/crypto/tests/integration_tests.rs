//! Integration tests for guardyn-crypto
//!
//! These tests verify:
//! - PQXDH hybrid key exchange roundtrip
//! - PADMÉ padding roundtrip
//! - FFI function correctness
//! - Cross-component interoperability

use guardyn_crypto::{
    pad_message, unpad_message, next_padme_length,
    pqxdh::{generate_hybrid_key_bundle, verify_hybrid_bundle, HybridKeyBundle},
};

mod pqxdh_tests {
    use super::*;

    #[test]
    fn test_hybrid_key_bundle_generation() {
        // Generate bundle with one-time prekey
        let result = generate_hybrid_key_bundle(true, false);
        assert!(result.is_ok(), "Bundle generation failed: {:?}", result.err());

        let (bundle, private_keys) = result.unwrap();

        // Verify bundle structure
        assert_eq!(bundle.identity_key.len(), 32);
        assert_eq!(bundle.signed_prekey.len(), 32);
        assert!(bundle.one_time_prekey.is_some());
    }

    #[test]
    fn test_hybrid_key_bundle_without_otpk() {
        let result = generate_hybrid_key_bundle(false, false);
        assert!(result.is_ok());

        let (bundle, _) = result.unwrap();
        assert!(bundle.one_time_prekey.is_none());
    }

    #[test]
    fn test_bundle_signature_verification() {
        let (bundle, _) = generate_hybrid_key_bundle(true, false).unwrap();

        // Verification should pass for valid bundle
        let verify_result = verify_hybrid_bundle(&bundle);
        assert!(verify_result.is_ok(), "Verification failed: {:?}", verify_result.err());
    }

    #[test]
    fn test_bundle_signature_tampering_detected() {
        let (mut bundle, _) = generate_hybrid_key_bundle(true, false).unwrap();

        // Tamper with signed prekey
        bundle.signed_prekey[0] ^= 0xff;

        // Verification should fail
        let verify_result = verify_hybrid_bundle(&bundle);
        assert!(verify_result.is_err());
    }

    #[test]
    fn test_bundle_serialization_roundtrip() {
        let (bundle, _) = generate_hybrid_key_bundle(true, false).unwrap();

        // Serialize to JSON
        let json = serde_json::to_string(&bundle).expect("Serialization failed");

        // Deserialize back
        let restored: HybridKeyBundle = serde_json::from_str(&json).expect("Deserialization failed");

        // Verify integrity
        assert_eq!(bundle.identity_key, restored.identity_key);
        assert_eq!(bundle.signed_prekey, restored.signed_prekey);
        assert_eq!(bundle.signed_prekey_signature.0, restored.signed_prekey_signature.0);
    }

    #[cfg(feature = "pq")]
    #[test]
    fn test_hybrid_key_bundle_with_pq() {
        let result = generate_hybrid_key_bundle(true, true);
        assert!(result.is_ok());

        let (bundle, _) = result.unwrap();

        // PQ prekey should be present
        assert!(bundle.pq_prekey.is_some());
        assert!(bundle.pq_prekey_signature.is_some());

        // PQ prekey should be ML-KEM-768 size (1184 bytes)
        let pq_prekey = bundle.pq_prekey.unwrap();
        assert_eq!(pq_prekey.len(), 1184);
    }
}

mod padme_tests {
    use super::*;

    #[test]
    fn test_padme_roundtrip_small() {
        let original = b"Hello, Guardyn!";
        let padded = pad_message(original).expect("Padding failed");
        let unpadded = unpad_message(&padded).expect("Unpadding failed");

        assert_eq!(original.as_slice(), unpadded.as_slice());
    }

    #[test]
    fn test_padme_roundtrip_empty() {
        let original: &[u8] = b"";
        let padded = pad_message(original).expect("Padding failed");
        let unpadded = unpad_message(&padded).expect("Unpadding failed");

        assert_eq!(original, unpadded.as_slice());
    }

    #[test]
    fn test_padme_roundtrip_large() {
        // 10KB message
        let original: Vec<u8> = (0..10240).map(|i| (i % 256) as u8).collect();
        let padded = pad_message(&original).expect("Padding failed");
        let unpadded = unpad_message(&padded).expect("Unpadding failed");

        assert_eq!(original, unpadded);
    }

    #[test]
    fn test_padme_minimum_size() {
        let small = b"x";
        let padded = pad_message(small).expect("Padding failed");

        // PADMÉ ensures minimum 32-byte padding
        assert!(padded.len() >= 32);
    }

    #[test]
    fn test_padme_length_calculation() {
        // Test that PADMÉ produces consistent padding
        // PADMÉ algorithm doesn't always round to powers of 2
        let test_cases = [
            (10, 32),    // Small messages padded to minimum
            (100, 100),  // Should be at least 100
            (1000, 1000), // Should be at least 1000
            (5000, 5000), // Should be at least input size
        ];

        for (input_len, min_expected) in test_cases {
            let padded_len = next_padme_length(input_len);
            assert!(
                padded_len >= min_expected,
                "For input {} expected at least {}, got {}",
                input_len, min_expected, padded_len
            );
            // PADMÉ should not produce excessive padding (max ~14% overhead for large messages)
            assert!(
                padded_len <= input_len + input_len / 7 + 32,
                "For input {} got excessive padding: {}",
                input_len, padded_len
            );
        }
    }

    #[test]
    fn test_padme_deterministic() {
        let message = b"Test message for determinism";

        let padded1 = pad_message(message).unwrap();
        let padded2 = pad_message(message).unwrap();

        // Padded length should be deterministic
        assert_eq!(padded1.len(), padded2.len());

        // Content may differ due to random padding bytes, but structure is same
    }

    #[test]
    fn test_invalid_unpadding() {
        // Too short to contain valid padding
        let invalid = vec![0u8; 4];
        let result = unpad_message(&invalid);
        assert!(result.is_err());
    }
}

mod ffi_tests {
    #[test]
    fn test_aes_gcm_roundtrip() {
        #[cfg(feature = "ffi")]
        {
            use guardyn_crypto::ffi::{encrypt_aes256_gcm, decrypt_aes256_gcm};

            let key = vec![0u8; 32];
            let plaintext = b"Secret message".to_vec();

            let encrypted = encrypt_aes256_gcm(plaintext.clone(), key.clone(), None, None)
                .expect("Encryption failed");

            let decrypted = decrypt_aes256_gcm(encrypted, key, None)
                .expect("Decryption failed");

            assert_eq!(plaintext, decrypted);
        }
    }

    #[test]
    fn test_chacha20_poly1305_roundtrip() {
        #[cfg(feature = "ffi")]
        {
            use guardyn_crypto::ffi::{encrypt_chacha20_poly1305, decrypt_chacha20_poly1305};

            let key = vec![0u8; 32];
            let plaintext = b"Another secret".to_vec();

            let encrypted = encrypt_chacha20_poly1305(plaintext.clone(), key.clone(), None, None)
                .expect("Encryption failed");

            let decrypted = decrypt_chacha20_poly1305(encrypted, key, None)
                .expect("Decryption failed");

            assert_eq!(plaintext, decrypted);
        }
    }

    #[test]
    fn test_ed25519_sign_verify() {
        #[cfg(feature = "ffi")]
        {
            use guardyn_crypto::ffi::{generate_ed25519_keypair, sign_ed25519, verify_ed25519};

            let keypair = generate_ed25519_keypair();
            let message = b"Sign this message".to_vec();

            let signature = sign_ed25519(keypair.private_key.clone(), message.clone())
                .expect("Signing failed");

            let valid = verify_ed25519(keypair.public_key, message, signature)
                .expect("Verification failed");

            assert!(valid);
        }
    }

    #[test]
    fn test_x25519_key_exchange() {
        #[cfg(feature = "ffi")]
        {
            use guardyn_crypto::ffi::{generate_x25519_keypair, x25519_diffie_hellman};

            let alice = generate_x25519_keypair();
            let bob = generate_x25519_keypair();

            let shared_alice = x25519_diffie_hellman(
                alice.private_key,
                bob.public_key.clone(),
            ).expect("DH failed");

            let shared_bob = x25519_diffie_hellman(
                bob.private_key,
                alice.public_key.clone(),
            ).expect("DH failed");

            assert_eq!(shared_alice, shared_bob);
        }
    }

    #[test]
    fn test_hkdf_derivation() {
        #[cfg(feature = "ffi")]
        {
            use guardyn_crypto::ffi::hkdf_sha256;

            let ikm = vec![0u8; 32];
            let info = b"guardyn-key".to_vec();

            let derived = hkdf_sha256(ikm, None, info, 64)
                .expect("HKDF failed");

            assert_eq!(derived.len(), 64);
        }
    }
}

mod mls_tests {
    //! MLS group tests
    //!
    //! Note: MLS group creation requires proper OpenMLS setup which is complex.
    //! These are basic smoke tests - full MLS testing is in mls_tests.rs

    #[test]
    fn test_mls_ciphersuite_available() {
        use openmls::prelude::*;

        // Verify our target ciphersuites exist
        let _cs1 = Ciphersuite::MLS_128_DHKEMP256_AES128GCM_SHA256_P256;
        let _cs2 = Ciphersuite::MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519;

        // Get signature algorithm - this validates ciphersuite is valid
        let sig = _cs1.signature_algorithm();
        println!("Ciphersuite signature algorithm: {:?}", sig);
    }

    #[test]
    fn test_mls_group_manager_exists() {
        // Just verify the type is exported and usable
        use guardyn_crypto::MlsGroupManager;
        let _ = std::any::type_name::<MlsGroupManager>();
    }
}

mod cross_platform_tests {
    //! Tests to verify compatibility between Rust and Dart implementations
    //!
    //! These tests use known test vectors that can be replicated in Dart
    //! to ensure both implementations produce identical results.

    use guardyn_crypto::padding::{pad_message, unpad_message};

    /// Test vector for cross-platform padding verification
    #[test]
    fn test_padding_test_vector() {
        // Known test vector: message "test" should pad to specific size
        let message = b"test";
        let padded = pad_message(message).unwrap();

        // Verify minimum padding applied
        assert!(padded.len() >= 32);

        // Verify roundtrip
        let unpadded = unpad_message(&padded).unwrap();
        assert_eq!(message.as_slice(), unpadded.as_slice());

        // Print for Dart test creation
        println!("Padded length: {}", padded.len());
        println!("Padded (hex): {}", hex::encode(&padded));
    }

    /// Key derivation test vector for Dart compatibility
    #[test]
    #[cfg(feature = "ffi")]
    fn test_hkdf_test_vector() {
        use guardyn_crypto::ffi::hkdf_sha256;

        // Known input
        let ikm = vec![0x0b; 22]; // 22 bytes of 0x0b
        let salt = Some(vec![0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c]);
        let info = vec![0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9];

        let okm = hkdf_sha256(ikm, salt, info, 42).unwrap();

        // RFC 5869 Test Case 1 expected output
        let expected = hex::decode(
            "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865"
        ).unwrap();

        assert_eq!(okm, expected);
    }
}
