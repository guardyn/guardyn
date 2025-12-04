/// Cross-platform Ed25519 → X25519 conversion compatibility tests
///
/// These tests verify that Ed25519 to X25519 key conversion produces identical
/// results in Rust (ed25519_dalek + curve25519_dalek) and Dart (TweetNaCl via pinenacl).
///
/// The conversion process:
/// 1. Generate Ed25519 keypair from 32-byte seed
/// 2. Convert Ed25519 public key to X25519 public key (birational equivalence via to_montgomery)
/// 3. Convert Ed25519 secret to X25519 secret: SHA512(seed)[0:32] + clamping
/// 4. Verify: X25519 public derived from X25519 secret matches converted public
///
/// IMPORTANT: We use to_scalar_bytes() + clamp_integer() which applies ONLY clamping,
/// matching TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk().
/// Do NOT use to_scalar() which also performs modular reduction - this breaks compatibility!

use crate::x3dh::IdentityKeyPair;
use curve25519_dalek::scalar::clamp_integer;
use ed25519_dalek::SigningKey;
use sha2::{Sha512, Digest};
use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret};

/// Test that Ed25519 → X25519 conversion is internally consistent
#[test]
fn test_ed25519_to_x25519_internal_consistency() {
    // Generate Ed25519 keypair from random seed
    let identity = IdentityKeyPair::generate().expect("Failed to generate identity key");

    // Convert to X25519
    let x25519_public = identity.to_x25519_public();
    let x25519_secret = identity.to_x25519_secret();

    // Derive public from secret
    let derived_public = X25519PublicKey::from(&x25519_secret);

    // They must match
    assert_eq!(
        x25519_public.as_bytes(),
        derived_public.as_bytes(),
        "X25519 public key derived from converted secret must match converted public key"
    );
}

/// Test conversion with known test vectors
///
/// This test uses a fixed seed to produce deterministic results that can be
/// verified against the Dart implementation.
#[test]
fn test_ed25519_to_x25519_deterministic() {
    // Fixed seed for reproducibility (32 bytes)
    let seed: [u8; 32] = [
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
        0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
        0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20,
    ];

    // Create Ed25519 signing key from seed
    let signing_key = SigningKey::from_bytes(&seed);
    let verifying_key = signing_key.verifying_key();

    // Convert to X25519 using to_scalar_bytes() + clamp_integer() (TweetNaCl compatible)
    let x25519_public = verifying_key.to_montgomery();
    let x25519_secret_bytes = clamp_integer(signing_key.to_scalar_bytes());
    let x25519_secret = StaticSecret::from(x25519_secret_bytes);

    // Derive public from secret to verify consistency
    let derived_public = X25519PublicKey::from(&x25519_secret);

    assert_eq!(
        x25519_public.as_bytes(),
        derived_public.as_bytes(),
        "Internal consistency check failed"
    );

    // Print the values for cross-platform verification
    println!("=== Ed25519 → X25519 Test Vectors ===");
    println!("Ed25519 Seed (32 bytes):     {:02x?}", seed);
    println!("Ed25519 Public Key (32 bytes): {:02x?}", verifying_key.to_bytes());
    println!("X25519 Public Key (32 bytes):  {:02x?}", x25519_public.as_bytes());
    println!("X25519 Secret Key (32 bytes):  {:02x?}", x25519_secret_bytes);
}

/// Test that to_scalar_bytes() + clamp_integer() matches manual SHA512 + clamping
///
/// This verifies the internal implementation matches TweetNaCl by manually
/// performing the same operation: SHA512(seed)[0:32] with X25519 scalar clamping.
///
/// X25519 clamping (same as Ed25519, per RFC 7748):
/// - Clear bottom 3 bits of byte 0 (make divisible by 8)
/// - Clear top bit of byte 31 (ensure < 2^255)
/// - Set second-to-top bit of byte 31 (ensure >= 2^254)
#[test]
fn test_clamp_integer_matches_manual_clamping() {
    let seed: [u8; 32] = [
        0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe,
        0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef,
        0xfe, 0xdc, 0xba, 0x98, 0x76, 0x54, 0x32, 0x10,
        0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    ];

    // Method 1: Use to_scalar_bytes() + clamp_integer() (TweetNaCl compatible)
    let signing_key = SigningKey::from_bytes(&seed);
    let clamped_bytes = clamp_integer(signing_key.to_scalar_bytes());

    // Method 2: Manual SHA512 + clamping
    // This is exactly what TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk does
    let mut hasher = Sha512::new();
    hasher.update(&seed);
    let hash = hasher.finalize();

    let mut manual_scalar = [0u8; 32];
    manual_scalar.copy_from_slice(&hash[..32]);

    // Apply X25519 scalar clamping (per RFC 7748)
    manual_scalar[0] &= 0xF8;      // Clear bottom 3 bits (248 = 0xF8)
    manual_scalar[31] &= 0x7F;     // Clear top bit (127 = 0x7F)
    manual_scalar[31] |= 0x40;     // Set bit 6 (64 = 0x40)

    // Print both values for comparison
    println!("=== SHA512 + Clamping Test ===");
    println!("Seed:                {:02x?}", seed);
    println!("clamp_integer():     {:02x?}", clamped_bytes);
    println!("Manual SHA512+clamp: {:02x?}", manual_scalar);

    // Byte-by-byte comparison for debugging
    for i in 0..32 {
        if clamped_bytes[i] != manual_scalar[i] {
            println!("DIFF at byte {}: clamp_integer={:02x}, manual={:02x}",
                i, clamped_bytes[i], manual_scalar[i]);
        }
    }

    assert_eq!(
        clamped_bytes,
        manual_scalar,
        "clamp_integer(to_scalar_bytes()) should match manual SHA512 + clamping (TweetNaCl compatible)"
    );
}

/// Generate test vectors for Dart compatibility testing
///
/// Run this test with `cargo test generate_dart_test_vectors -- --nocapture`
/// to see the output that should be verified in Dart.
#[test]
fn generate_dart_test_vectors() {
    println!("\n=== DART COMPATIBILITY TEST VECTORS ===\n");

    // Test vector 1: All zeros (edge case)
    let seed1 = [0u8; 32];
    print_test_vector("all_zeros", &seed1);

    // Test vector 2: All ones (edge case)
    let seed2 = [0xff; 32];
    print_test_vector("all_ones", &seed2);

    // Test vector 3: Sequential bytes
    let mut seed3 = [0u8; 32];
    for (i, byte) in seed3.iter_mut().enumerate() {
        *byte = i as u8;
    }
    print_test_vector("sequential", &seed3);

    // Test vector 4: Random-looking pattern
    let seed4: [u8; 32] = [
        0x9d, 0x61, 0xb1, 0x9d, 0xef, 0xfd, 0x5a, 0x60,
        0xba, 0x84, 0x4a, 0xf4, 0x92, 0xec, 0x2c, 0xc4,
        0x44, 0x49, 0xc5, 0x69, 0x7b, 0x32, 0x69, 0x19,
        0x70, 0x3b, 0xac, 0x03, 0x1c, 0xae, 0x7f, 0x60,
    ];
    print_test_vector("random_pattern", &seed4);

    println!("\n=== END TEST VECTORS ===\n");
}

fn print_test_vector(name: &str, seed: &[u8; 32]) {
    let signing_key = SigningKey::from_bytes(seed);
    let verifying_key = signing_key.verifying_key();

    let x25519_public = verifying_key.to_montgomery();
    // Use to_scalar_bytes() + clamp_integer() for TweetNaCl compatibility
    let x25519_secret = clamp_integer(signing_key.to_scalar_bytes());

    println!("Test Vector: {}", name);
    println!("  ed25519_seed:      [{}]",
        seed.iter().map(|b| format!("0x{:02x}", b)).collect::<Vec<_>>().join(", "));
    println!("  ed25519_public:    [{}]",
        verifying_key.to_bytes().iter().map(|b| format!("0x{:02x}", b)).collect::<Vec<_>>().join(", "));
    println!("  x25519_public:     [{}]",
        x25519_public.as_bytes().iter().map(|b| format!("0x{:02x}", b)).collect::<Vec<_>>().join(", "));
    println!("  x25519_secret:     [{}]",
        x25519_secret.iter().map(|b| format!("0x{:02x}", b)).collect::<Vec<_>>().join(", "));
    println!();
}

/// Test that X3DH key exchange produces same shared secret with converted keys
#[test]
fn test_x25519_dh_with_converted_keys() {
    // Alice's Ed25519 identity key
    let alice_identity = IdentityKeyPair::generate().expect("Alice keygen failed");

    // Bob's Ed25519 identity key
    let bob_identity = IdentityKeyPair::generate().expect("Bob keygen failed");

    // Convert to X25519 for DH
    let alice_x25519_secret = alice_identity.to_x25519_secret();
    let bob_x25519_public = bob_identity.to_x25519_public();

    let bob_x25519_secret = bob_identity.to_x25519_secret();
    let alice_x25519_public = alice_identity.to_x25519_public();

    // Perform DH from both sides
    let alice_shared = alice_x25519_secret.diffie_hellman(&bob_x25519_public);
    let bob_shared = bob_x25519_secret.diffie_hellman(&alice_x25519_public);

    assert_eq!(
        alice_shared.as_bytes(),
        bob_shared.as_bytes(),
        "DH shared secrets must match"
    );
}

/// Generate hex string from bytes (for documentation)
#[allow(dead_code)]
fn bytes_to_hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{:02x}", b)).collect()
}
