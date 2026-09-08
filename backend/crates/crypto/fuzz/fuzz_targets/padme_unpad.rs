//! PADMÉ unpadding, fuzzed.
//!
//! `unpad_message` runs on bytes that have just come out of AEAD decryption. A
//! panic here is reachable by anyone who can get ciphertext to a client — and by
//! anyone at all if a bug ever lets unauthenticated bytes through.
//!
//! The target asserts nothing about the *result*: rejecting malformed padding is
//! correct behaviour. It asserts only that the function returns.
#![no_main]

use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = guardyn_crypto::padding::unpad_message(data);
});
