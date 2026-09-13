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
//!
//! The `#![cfg(test)]` below is redundant with `#[cfg(test)] mod proptests;` in
//! `lib.rs`, and deliberate: `RS-UNWRAP` in `rules-verify.sh` strips a file from
//! its first `#[cfg(test)]` onward, so a file that is *entirely* tests and says
//! so only at the module declaration has every `expect()` counted as production
//! debt. See #177.
#![cfg(test)]

use proptest::prelude::*;

use crate::double_ratchet::DoubleRatchet;
use crate::padding::{next_padme_length, pad_message, unpad_message};
use crate::x3dh::{IdentityKeyPair, SignedPreKey, X3DHPrekeyMessage};

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

    /// A prekey message round-trips for *any* one-time key id and *any* ML-KEM ciphertext,
    /// not just the `0` and the `None` every client sends today.
    ///
    /// The known-answer vectors pin the encoding to a few constants; this pins the parser
    /// across the whole `u32` range, where an off-by-one slice or a width mistake shows up as
    /// a value that does not survive the trip. The ciphertext length is varied for the same
    /// reason - the vectors use only 4 bytes and 1088, and a `ct_len` mistake could survive
    /// both.
    #[test]
    fn x3dh_prekey_message_round_trips_any_one_time_key_id(
        identity in prop::collection::vec(any::<u8>(), 32),
        ephemeral in prop::collection::vec(any::<u8>(), 32),
        id in prop::option::of(any::<u32>()),
        ct in prop::option::of(prop::collection::vec(any::<u8>(), 1..2048)),
    ) {
        let mut message = X3DHPrekeyMessage::new(identity.clone(), ephemeral.clone(), id);
        if let Some(ref bytes) = ct {
            message = message.with_pq_ciphertext(bytes.clone());
        }
        let decoded = X3DHPrekeyMessage::from_bytes(&message.to_bytes()).expect("decode");

        prop_assert_eq!(decoded.sender_identity_key, identity);
        prop_assert_eq!(decoded.ephemeral_key, ephemeral);
        prop_assert_eq!(decoded.used_one_time_key_id, id);
        prop_assert_eq!(decoded.pq_ciphertext, ct);
    }

    /// The v1 encoding is canonical: every frame the parser accepts re-encodes to itself.
    ///
    /// This is the property that closes the v0 loophole: v0 never checked an exact length, so
    /// a frame with anything appended decoded to a message whose re-encoding was shorter than
    /// the input, and that silent discard is what would have let an ML-KEM ciphertext be
    /// appended and ignored. A parser that cannot lose bytes cannot have that defect.
    ///
    /// The input is a *valid* frame with one byte overwritten, not random bytes: pure noise
    /// practically never satisfies the version byte and the framing at once, so the assertion
    /// would almost never run and the property would be decorative.
    #[test]
    fn x3dh_prekey_message_encoding_is_canonical(
        id in prop::option::of(any::<u32>()),
        ct in prop::option::of(prop::collection::vec(any::<u8>(), 1..256)),
        index in any::<prop::sample::Index>(),
        replacement in any::<u8>(),
    ) {
        let mut message = X3DHPrekeyMessage::new(vec![7u8; 32], vec![9u8; 32], id);
        if let Some(bytes) = ct {
            message = message.with_pq_ciphertext(bytes);
        }

        let mut frame = message.to_bytes();
        // The unmutated frame must itself be canonical.
        let decoded = X3DHPrekeyMessage::from_bytes(&frame).expect("decode");
        prop_assert_eq!(decoded.to_bytes(), frame.clone());

        let position = index.index(frame.len());
        frame[position] = replacement;
        if let Ok(decoded) = X3DHPrekeyMessage::from_bytes(&frame) {
            prop_assert_eq!(decoded.to_bytes(), frame);
        }
    }

    /// Appending anything to a valid frame must be refused, never silently dropped.
    #[test]
    fn x3dh_prekey_message_rejects_trailing_bytes(
        id in prop::option::of(any::<u32>()),
        ct in prop::option::of(prop::collection::vec(any::<u8>(), 1..256)),
        suffix in prop::collection::vec(any::<u8>(), 1..16),
    ) {
        let mut message = X3DHPrekeyMessage::new(vec![7u8; 32], vec![9u8; 32], id);
        if let Some(bytes) = ct {
            message = message.with_pq_ciphertext(bytes);
        }

        let mut frame = message.to_bytes();
        prop_assert!(X3DHPrekeyMessage::from_bytes(&frame).is_ok());

        frame.extend_from_slice(&suffix);
        prop_assert!(X3DHPrekeyMessage::from_bytes(&frame).is_err());
    }

    /// Any reserved flag bit must be an error. v0 compared its flag byte `== 1`, so `2..=255`
    /// read as "no one-time key" - a whole byte of extension space silently ignored.
    #[test]
    fn x3dh_prekey_message_rejects_reserved_flag_bits(
        id in prop::option::of(any::<u32>()),
        reserved in 1u8..64,
    ) {
        let frame = X3DHPrekeyMessage::new(vec![7u8; 32], vec![9u8; 32], id).to_bytes();
        prop_assert!(X3DHPrekeyMessage::from_bytes(&frame).is_ok());

        let mut tampered = frame;
        // Bits 0x04 and above are reserved; `reserved` is shifted into that range.
        tampered[65] |= reserved << 2;
        prop_assert!(X3DHPrekeyMessage::from_bytes(&tampered).is_err());
    }

    /// `from_bytes` is reachable from attacker-controlled bytes - the server relays the
    /// prekey message without inspecting it - so it must refuse or parse, never panic.
    /// The `x3dh_prekey_message` fuzz target covers this continuously; this keeps a cheap
    /// version in the suite that runs on every build.
    #[test]
    fn x3dh_prekey_message_never_panics_on_arbitrary_input(
        bytes in prop::collection::vec(any::<u8>(), 0..256)
    ) {
        let _ = X3DHPrekeyMessage::from_bytes(&bytes);
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
