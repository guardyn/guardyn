# guardyn-crypto-ffi

Flutter Rust Bridge bindings for guardyn-crypto library.

## Overview

This crate provides FFI bindings that allow Flutter applications to use Guardyn's Rust cryptography implementation via [flutter_rust_bridge](https://github.com/aspect-build/flutter_rust_bridge).

## Architecture

```text
┌─────────────────────────────────────┐
│        Flutter App (Dart)           │
│   lib/generated/rust/api.dart       │
└─────────────────┬───────────────────┘
                  │ FFI (dart:ffi)
┌─────────────────▼───────────────────┐
│       guardyn-crypto-ffi            │ ◄── This crate
│   (flutter_rust_bridge bindings)    │
└─────────────────┬───────────────────┘
                  │ Rust calls
┌─────────────────▼───────────────────┐
│        guardyn-crypto               │
│  (X3DH, Double Ratchet, MLS, PQXDH) │
└─────────────────────────────────────┘
```

## Features

- `full` (default) - Enable all features including post-quantum
- `pq` - Post-quantum cryptography (ML-KEM-768)

## Exposed Functions

### Initialization

- `crypto_init()` - Initialize the crypto library
- `crypto_status()` - Get library status
- `crypto_is_pq_available()` - Check PQ availability

### Key Generation

- `crypto_generate_x25519_keypair()` - X25519 key pair for DH
- `crypto_generate_ed25519_keypair()` - Ed25519 key pair for signing
- `crypto_generate_hybrid_key_bundle()` - PQXDH hybrid keys

### Key Exchange

- `crypto_x25519_dh()` - Diffie-Hellman key agreement

### Symmetric Encryption

- `crypto_encrypt_aes_gcm()` / `crypto_decrypt_aes_gcm()` - AES-256-GCM
- `crypto_encrypt_chacha20()` / `crypto_decrypt_chacha20()` - ChaCha20-Poly1305

### Key Derivation

- `crypto_hkdf()` - HKDF-SHA256

### Signatures

- `crypto_sign_ed25519()` - Sign message
- `crypto_verify_ed25519()` - Verify signature

### Padding

- `crypto_pad_message()` / `crypto_unpad_message()` - PADMÉ padding

### Utilities

- `crypto_random_bytes()` - Secure random bytes
- `crypto_constant_time_eq()` - Constant-time comparison

## Building

### Prerequisites

1. **Rust** with cross-compilation targets:

   ```bash
   # Android
   rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android

   # iOS (macOS only)
   rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
   ```

2. **Android NDK** (for Android builds)

3. **Xcode** (for iOS builds, macOS only)

4. **flutter_rust_bridge_codegen**:

   ```bash
   cargo install flutter_rust_bridge_codegen
   ```

### Build Commands

```bash
# Build for all platforms
./build-mobile.sh all

# Build for specific platform
./build-mobile.sh android
./build-mobile.sh ios
./build-mobile.sh desktop

# Generate Dart bindings only
./build-mobile.sh generate
```

### Output Locations

After building, libraries are placed in:

```text
client-mobile/native/
├── android/
│   ├── arm64-v8a/libguardyn_crypto_ffi.so
│   ├── armeabi-v7a/libguardyn_crypto_ffi.so
│   └── x86_64/libguardyn_crypto_ffi.so
├── ios/
│   └── GuardynCrypto.xcframework/
├── linux/
│   └── libguardyn_crypto_ffi.so
├── macos/
│   └── libguardyn_crypto_ffi.dylib
└── windows/
    └── guardyn_crypto_ffi.dll
```

## Dart Usage

After building, use in Flutter:

```dart
import 'package:guardyn_client/generated/rust/api.dart';

// Initialize
await cryptoInit();

// Check status
final status = cryptoStatus();
print('PQ available: ${status.postQuantumAvailable}');

// Generate keys
final keypair = cryptoGenerateX25519Keypair();
print('Public key: ${keypair.publicKey}');

// Encrypt
final encrypted = await cryptoEncryptAesGcm(
  plaintext: utf8.encode('Hello, Guardyn!'),
  key: key,
  nonce: null, // Auto-generate
  associatedData: null,
);

// Decrypt
final plaintext = await cryptoDecryptAesGcm(
  encrypted: encrypted,
  key: key,
  associatedData: null,
);
```

## Testing

```bash
# Run Rust tests
cargo test -p guardyn-crypto-ffi

# Run with all features
cargo test -p guardyn-crypto-ffi --features full
```

## Security Notes

- All cryptographic operations are performed in Rust for safety
- Keys are zeroized on drop where possible
- Constant-time comparisons prevent timing attacks
- Post-quantum keys (ML-KEM-768) provide quantum resistance

## License

Apache-2.0
