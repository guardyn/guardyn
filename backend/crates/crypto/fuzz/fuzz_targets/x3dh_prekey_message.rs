//! X3DH prekey message parsing, fuzzed.
//!
//! The prekey message is the first thing a responder sees from an unknown
//! initiator: it arrives before any session exists, so there is no key with
//! which to authenticate it first.
#![no_main]

use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    if let Ok(message) = guardyn_crypto::x3dh::X3DHPrekeyMessage::from_bytes(data) {
        // The v1 encoding is canonical: anything the parser accepts must re-encode to exactly
        // the bytes it was given. Not panicking is the weaker half of what this target is for
        // - a parser that quietly drops bytes it did not understand is the v0 defect this
        // format version closes, and `docs/spec/SRS.md` records what that cost.
        assert_eq!(
            message.to_bytes(),
            data,
            "from_bytes accepted a frame that does not re-encode to itself"
        );
    }
});
