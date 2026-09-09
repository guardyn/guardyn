//! X3DH prekey message parsing, fuzzed.
//!
//! The prekey message is the first thing a responder sees from an unknown
//! initiator: it arrives before any session exists, so there is no key with
//! which to authenticate it first.
#![no_main]

use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = guardyn_crypto::x3dh::X3DHPrekeyMessage::from_bytes(data);
});
