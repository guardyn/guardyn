//! Property tests for the crypto primitives.
//!
//! These assert invariants over *generated* inputs rather than fixed vectors. A
//! unit test proves a function works for the case someone thought of; a property
//! test looks for the case nobody did. Both matter, and the existing unit tests
//! are not replaced by these.
//!
//! Every property here is one an attacker would try to falsify:
//!
//! - a round trip that loses or corrupts a byte is a message that silently changes
//! - a padding scheme whose output length leaks the input length defeats its purpose
//! - a parser reachable from the network that panics is a remote crash
//! - a ratchet that accepts a tampered ciphertext is not authenticated

use proptest::prelude::*;

use crate::double_ratchet::DoubleRatchet;
use crate::padding::{next_padme_length, pad_message, unpad_message};
use crate::x3dh::{IdentityKeyPair, SignedPreKey};

/// Messages up to 4 KiB. `pad_message` accepts 16 MiB, but generating those makes
/// the suite slow without exercising a different branch: the size classes that
/// matter are `<= 32`, `<= 256` and the exponential regime above it.
fn message() -> impl Strategy<Value = Vec<u8>> {
    prop::collection::vec(any::<u8>(), 0..4096)
}

// ---------------------------------------------------------------- PADMÉ

proptest! {
    /// Padding then unpadding returns exactly what went in.
    #[test]
    fn padme_round_trips(msg in message()) {
        let padded = pad_message(&msg).expect("pad");
        let recovered = unpad_message(&padded).expect("unpad");
        prop_assert_eq!(recovered, msg);
    }

    /// The padded length never reveals the exact input length: there is always at
    /// least one byte of marker, so distinct inputs can share an output length.
    #[test]
    fn padme_always_leaves_room_for_the_marker(msg in message()) {
        let padded = pad_message(&msg).expect("pad");
        prop_assert!(padded.len() > msg.len(),
            "padded {} not longer than input {}", padded.len(), msg.len());
    }

    /// Padded output falls into a small number of buckets. Above the 256-byte
    /// threshold PADMÉ bounds overhead; this pins it at 12%, the figure the paper
    /// gives. A regression that widened the buckets would show up as wasted
    /// bandwidth, and one that narrowed them as a length oracle.
    #[test]
    fn padme_overhead_is_bounded_above_the_small_message_threshold(
        len in 256usize..4096
    ) {
        let padded = next_padme_length(len);
        prop_assert!(padded > len);
        let overhead = (padded - len) as f64 / len as f64;
        prop_assert!(overhead <= 0.12, "overhead {overhead} for len {len}");
    }

    /// Longer input never produces shorter output. Non-monotonicity would let an
    /// observer rule out input lengths from an output length.
    #[test]
    fn padme_length_is_monotonic(a in 0usize..8192, b in 0usize..8192) {
        let (small, large) = if a <= b { (a, b) } else { (b, a) };
        prop_assert!(next_padme_length(small) <= next_padme_length(large));
    }

    /// `unpad_message` is reachable with attacker-chosen bytes once an AEAD tag
    /// has been forged or a bug lets ciphertext through. It may reject anything,
    /// but it may not panic.
    #[test]
    fn unpad_never_panics_on_arbitrary_input(bytes in prop::collection::vec(any::<u8>(), 0..512)) {
        let _ = unpad_message(&bytes);
    }
}

// ---------------------------------------------------------------- X3DH

proptest! {
    /// Diffie-Hellman agrees in both directions. This is the property the whole
    /// session establishment rests on, and the one a key-format change breaks.
    #[test]
    fn x3dh_dh_is_symmetric(seed in any::<u64>()) {
        let _ = seed; // key generation is randomised; the seed only varies the case count
        let alice_identity = IdentityKeyPair::generate().expect("alice identity");
        let bob_identity = IdentityKeyPair::generate().expect("bob identity");
        let alice_prekey = SignedPreKey::generate(1, &alice_identity).expect("alice prekey");
        let bob_prekey = SignedPreKey::generate(1, &bob_identity).expect("bob prekey");

        let alice_view = alice_prekey.dh(&bob_prekey.public);
        let bob_view = bob_prekey.dh(&alice_prekey.public);

        prop_assert_eq!(alice_view, bob_view);
    }

    /// An identity key survives export and re-import. `private_key_bytes` and
    /// `from_private_bytes` are what a client's key storage round-trips through,
    /// so a mismatch here loses every session on the device.
    #[test]
    fn x3dh_identity_key_round_trips(seed in any::<u64>()) {
        let _ = seed;
        let original = IdentityKeyPair::generate().expect("generate");
        let restored = IdentityKeyPair::from_private_bytes(&original.private_key_bytes())
            .expect("restore");
        prop_assert_eq!(original.public_bytes(), restored.public_bytes());
    }

    /// A signature verifies against the message it was made over, and the
    /// verification is bound to that message.
    #[test]
    fn x3dh_signature_binds_to_its_message(msg in message(), other in message()) {
        prop_assume!(msg != other);
        let identity = IdentityKeyPair::generate().expect("generate");
        let signature = identity.sign(&msg).expect("sign");

        prop_assert!(IdentityKeyPair::verify(&identity.public_bytes(), &msg, &signature).is_ok());
        prop_assert!(IdentityKeyPair::verify(&identity.public_bytes(), &other, &signature).is_err());
    }
}

// ------------------------------------------------------- Double Ratchet

/// Establish a ratchet pair the way `x3dh` does: Bob's signed pre-key is his
/// initial ratchet key, and Alice runs against its public half.
fn ratchet_pair(shared_secret: &[u8]) -> (DoubleRatchet, DoubleRatchet) {
    let bob_identity = IdentityKeyPair::generate().expect("bob identity");
    let bob_prekey = SignedPreKey::generate(1, &bob_identity).expect("bob prekey");

    let alice = DoubleRatchet::init_alice(shared_secret, bob_prekey.public).expect("init alice");
    let bob =
        DoubleRatchet::init_bob(shared_secret, bob_prekey.ratchet_secret()).expect("init bob");
    (alice, bob)
}

proptest! {
    /// What Alice encrypts, Bob decrypts — for any plaintext and any associated
    /// data, not just the ASCII the unit tests use.
    #[test]
    fn ratchet_round_trips(
        secret in prop::collection::vec(any::<u8>(), 32..33),
        plaintext in message(),
        aad in prop::collection::vec(any::<u8>(), 0..64),
    ) {
        let (mut alice, mut bob) = ratchet_pair(&secret);
        let encrypted = alice.encrypt(&plaintext, &aad).expect("encrypt");
        let decrypted = bob.decrypt(&encrypted, &aad).expect("decrypt");
        prop_assert_eq!(decrypted, plaintext);
    }

    /// Associated data is authenticated. Decrypting under different AAD must fail
    /// rather than return altered plaintext — this is what binds a message to its
    /// sender, recipient and timestamp.
    #[test]
    fn ratchet_rejects_mismatched_associated_data(
        secret in prop::collection::vec(any::<u8>(), 32..33),
        plaintext in message(),
        aad in prop::collection::vec(any::<u8>(), 1..64),
        other_aad in prop::collection::vec(any::<u8>(), 1..64),
    ) {
        prop_assume!(aad != other_aad);
        let (mut alice, mut bob) = ratchet_pair(&secret);
        let encrypted = alice.encrypt(&plaintext, &aad).expect("encrypt");
        prop_assert!(bob.decrypt(&encrypted, &other_aad).is_err());
    }

    /// Flipping any single bit of the ciphertext makes it undecryptable. An AEAD
    /// that tolerated this would not be one.
    #[test]
    fn ratchet_rejects_tampered_ciphertext(
        secret in prop::collection::vec(any::<u8>(), 32..33),
        plaintext in prop::collection::vec(any::<u8>(), 1..256),
        bit in 0usize..8,
        byte_index in any::<prop::sample::Index>(),
    ) {
        let (mut alice, mut bob) = ratchet_pair(&secret);
        let mut encrypted = alice.encrypt(&plaintext, b"aad").expect("encrypt");

        let i = byte_index.index(encrypted.ciphertext.len());
        encrypted.ciphertext[i] ^= 1 << bit;

        prop_assert!(bob.decrypt(&encrypted, b"aad").is_err());
    }

    /// Messages that arrive out of order still decrypt. The ratchet stores skipped
    /// message keys for exactly this, and a network reorders freely.
    #[test]
    fn ratchet_handles_out_of_order_delivery(
        secret in prop::collection::vec(any::<u8>(), 32..33),
        messages in prop::collection::vec(message(), 2..6),
    ) {
        let (mut alice, mut bob) = ratchet_pair(&secret);

        let encrypted: Vec<_> = messages
            .iter()
            .map(|m| alice.encrypt(m, b"aad").expect("encrypt"))
            .collect();

        // Deliver last-to-first: the worst ordering for skipped-key handling.
        for (original, ciphertext) in messages.iter().zip(encrypted.iter()).rev() {
            let decrypted = bob.decrypt(ciphertext, b"aad").expect("decrypt out of order");
            prop_assert_eq!(&decrypted, original);
        }
    }
}
