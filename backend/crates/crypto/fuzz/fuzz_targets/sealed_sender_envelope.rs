//! Sealed-sender envelope parsing, fuzzed.
//!
//! Sealed sender exists so a relay cannot see who sent a message, which means
//! the envelope is parsed before the sender is known and before anything about
//! it has been authenticated.
#![no_main]

use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = guardyn_crypto::sealed_sender::SealedSenderEnvelope::from_bytes(data);
});
