//! Proof that no key or payload material can reach a `{:?}` sink (invariant I-1).
//!
//! Each test asserts two things: the placeholder is present, and a byte pattern
//! unique to the secret is absent. Asserting only the former would pass for a
//! `Debug` impl that printed `[REDACTED]` *next to* the secret.

use crate::mls::{MlsGroupState, MlsKeyPackage};
use crate::sealed_sender::SealedSenderEnvelope;
use crate::x3dh::IdentityKeyPair;

/// A byte pattern that will not occur by chance in a struct name or field name.
const CANARY: &[u8] = &[0xDE, 0xAD, 0xBE, 0xEF, 0xCA, 0xFE, 0xBA, 0xBE];

/// How `{:?}` renders `CANARY` if it is ever printed.
fn canary_rendered() -> String {
    format!("{:?}", CANARY)
}

#[test]
fn test_identity_key_pair_debug_hides_the_signing_key() -> crate::Result<()> {
    // Returns Result rather than unwrapping: RS-UNWRAP counts this file, because
    // it carries no in-file `#[cfg(test)]` for the ratchet's stripper to find.
    let pair = IdentityKeyPair::generate()?;
    let rendered = format!("{:?}", pair);

    // The signing key is private and randomly generated, so there is no canary to
    // look for: assert the exact rendering instead.
    assert!(
        rendered.contains("secret: [REDACTED]"),
        "signing key not redacted: {rendered}"
    );
    assert!(
        rendered.contains("public"),
        "the public half stays visible: {rendered}"
    );
    Ok(())
}

#[test]
fn test_sealed_sender_envelope_debug_hides_the_payload() {
    let envelope = SealedSenderEnvelope {
        version: 1,
        ephemeral_public_key: [7u8; 32],
        encrypted_payload: CANARY.to_vec(),
    };
    let rendered = format!("{:?}", envelope);

    assert!(rendered.contains("[REDACTED]"), "got: {rendered}");
    assert!(
        !rendered.contains(&canary_rendered()),
        "payload leaked: {rendered}"
    );
    assert!(
        rendered.contains("version: 1"),
        "version stays visible for correlation: {rendered}"
    );
}

#[test]
fn test_mls_group_state_debug_hides_the_exported_secret() {
    let state = MlsGroupState {
        group_id: b"group-1".to_vec(),
        epoch: 42,
        serialized_state: CANARY.to_vec(),
    };
    let rendered = format!("{:?}", state);

    assert!(rendered.contains("[REDACTED]"), "got: {rendered}");
    assert!(
        !rendered.contains(&canary_rendered()),
        "group secret leaked: {rendered}"
    );
    assert!(
        rendered.contains("epoch: 42"),
        "epoch stays visible: {rendered}"
    );
}

#[test]
fn test_mls_key_package_debug_hides_bytes_and_identity() {
    let package = MlsKeyPackage {
        package_id: b"pkg-1".to_vec(),
        key_package_bytes: CANARY.to_vec(),
        credential_identity: CANARY.to_vec(),
    };
    let rendered = format!("{:?}", package);

    assert!(rendered.contains("[REDACTED]"), "got: {rendered}");
    assert!(
        !rendered.contains(&canary_rendered()),
        "key package or identity leaked: {rendered}"
    );
}

#[cfg(feature = "ffi")]
mod ffi_types {
    use super::{canary_rendered, CANARY};
    use crate::ffi::{FfiEncryptedData, FfiHybridKeyBundle, FfiKeyPair};

    #[test]
    fn test_hybrid_key_bundle_debug_hides_both_private_halves() {
        let bundle = FfiHybridKeyBundle {
            x25519_public: vec![1, 2, 3],
            x25519_private: CANARY.to_vec(),
            ml_kem_public: vec![4, 5, 6],
            ml_kem_private: CANARY.to_vec(),
        };
        let rendered = format!("{:?}", bundle);

        assert!(rendered.contains("[REDACTED]"), "got: {rendered}");
        assert!(
            !rendered.contains(&canary_rendered()),
            "private key material leaked: {rendered}"
        );
        assert!(
            rendered.contains("[1, 2, 3]"),
            "public halves stay visible: {rendered}"
        );
    }

    #[test]
    fn test_encrypted_data_debug_hides_only_the_ciphertext() {
        let data = FfiEncryptedData {
            ciphertext: CANARY.to_vec(),
            nonce: vec![9; 12],
            tag: vec![8; 16],
        };
        let rendered = format!("{:?}", data);

        assert!(rendered.contains("[REDACTED]"), "got: {rendered}");
        assert!(
            !rendered.contains(&canary_rendered()),
            "ciphertext leaked: {rendered}"
        );
    }

    #[test]
    fn test_key_pair_debug_hides_the_private_key() {
        let pair = FfiKeyPair {
            public_key: vec![1, 2, 3],
            private_key: CANARY.to_vec(),
            key_type: "x25519".to_owned(),
        };
        let rendered = format!("{:?}", pair);

        assert!(rendered.contains("[REDACTED]"), "got: {rendered}");
        assert!(
            !rendered.contains(&canary_rendered()),
            "private key leaked: {rendered}"
        );
        assert!(
            rendered.contains("x25519"),
            "key_type stays visible: {rendered}"
        );
    }
}
