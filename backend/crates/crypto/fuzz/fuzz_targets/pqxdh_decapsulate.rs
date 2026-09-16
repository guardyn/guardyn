//! ML-KEM decapsulation, fuzzed.
//!
//! `derive_recipient_shared_secret` takes `pq_ciphertext` straight off a peer's X3DH prekey
//! message. The responder holds no session with that peer yet and the frame carries no MAC it
//! could check first, so every one of those bytes is attacker-chosen and unauthenticated when
//! the parser runs.
//!
//! `x3dh_prekey_message` already fuzzes the frame that *carries* the ciphertext, but it stops at
//! the frame: it never hands the extracted bytes to ML-KEM. This target is the other half, and
//! the reason the pair is not redundant.
//!
//! The target asserts nothing about the result. Rejecting a malformed ciphertext is correct, and
//! so is accepting one - ML-KEM-768 is unauthenticated and uses implicit rejection, so a wrong
//! ciphertext of the right length decapsulates to a *different* shared secret rather than to an
//! error. Only "it returns" is a property of this code.
#![no_main]

use std::sync::OnceLock;

use guardyn_crypto::pqxdh::{
    derive_recipient_shared_secret, derive_sender_shared_secret, generate_hybrid_key_bundle,
    HybridPrivateKeys,
};
use guardyn_crypto::IdentityKeyPair;
use libfuzzer_sys::fuzz_target;

/// A responder and a peer, built once.
///
/// ML-KEM-768 key generation costs far more than one decapsulation, so minting these per
/// iteration would spend the run on setup instead of on the parser under test.
struct Responder {
    keys: HybridPrivateKeys,
    /// The peer's Ed25519 identity public key. It must be a real one: the classical half runs
    /// `ed25519_public_to_x25519` first and rejects a non-canonical point, which would return
    /// before any fuzzed byte reached ML-KEM.
    sender_identity: [u8; 32],
    /// The peer's X25519 ephemeral public key, as the initiator published it.
    sender_ephemeral: [u8; 32],
    /// A genuine 1088-byte ML-KEM ciphertext for `keys`.
    ///
    /// Needed because the length gate is otherwise the whole target. Random mutation from an
    /// empty corpus essentially never produces exactly 1088 bytes, so every input dies at
    /// `try_into` and `decapsulate` is never reached - 43 000 runs held coverage flat at 613
    /// edges before this existed. Splicing the fuzzer's bytes over a real ciphertext keeps the
    /// length correct so the primitive itself is what gets exercised.
    valid_ciphertext: Vec<u8>,
}

static RESPONDER: OnceLock<Responder> = OnceLock::new();

fn responder() -> &'static Responder {
    RESPONDER.get_or_init(|| {
        let (bundle, keys) =
            generate_hybrid_key_bundle(true, true).expect("hybrid bundle generation");
        let identity = IdentityKeyPair::generate().expect("identity key generation");
        let sender_identity: [u8; 32] = identity
            .public_bytes()
            .try_into()
            .expect("an Ed25519 public key is 32 bytes");
        let sender_identity_secret: [u8; 32] = identity
            .private_key_bytes()
            .try_into()
            .expect("an Ed25519 seed is 32 bytes");

        // `additional_data` is the ephemeral public key followed by the ML-KEM ciphertext -
        // exactly what the initiator puts on the wire.
        let (_secret, additional_data) =
            derive_sender_shared_secret(&sender_identity_secret, &[3u8; 32], &bundle)
                .expect("sender derivation");
        let sender_ephemeral: [u8; 32] = additional_data[..32]
            .try_into()
            .expect("an X25519 public key is 32 bytes");

        Responder {
            keys,
            sender_identity,
            sender_ephemeral,
            valid_ciphertext: additional_data[32..].to_vec(),
        }
    })
}

fuzz_target!(|data: &[u8]| {
    let responder = responder();

    // Any length at all, including the empty slice: this is the length gate and the `None`-free
    // path through it.
    let _ = derive_recipient_shared_secret(
        &responder.keys,
        &responder.sender_identity,
        &responder.sender_ephemeral,
        Some(data),
    );

    // The same bytes spliced over a real ciphertext, so the length is right and ML-KEM itself
    // runs. Without this the target never gets past `try_into`.
    let mut ciphertext = responder.valid_ciphertext.clone();
    let overlap = data.len().min(ciphertext.len());
    ciphertext[..overlap].copy_from_slice(&data[..overlap]);
    let _ = derive_recipient_shared_secret(
        &responder.keys,
        &responder.sender_identity,
        &responder.sender_ephemeral,
        Some(&ciphertext),
    );
});
