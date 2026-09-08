//! Double Ratchet wire-message parsing, fuzzed.
//!
//! `EncryptedMessage::from_bytes` is the first code to touch a message off the
//! wire. It reads a 32-bit header length from attacker bytes and slices on it,
//! then hands the header to `MessageHeader::from_bytes` — all before the AEAD
//! tag has authenticated anything. An attacker controls every byte and needs no
//! key, which makes this the most exposed parser in the crate.
//!
//! Fuzzing the public entry point rather than the header parser directly is
//! deliberate: `MessageHeader::from_bytes` is private, and this is the path that
//! actually reaches it.
#![no_main]

use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = guardyn_crypto::double_ratchet::EncryptedMessage::from_bytes(data);
});
