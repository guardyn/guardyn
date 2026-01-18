# Rust FFI Integration Guide

This document describes the Rust FFI integration for Guardyn, enabling Flutter to use native Rust cryptography.

## Architecture

```text
┌─────────────────────────────────────┐
│        Flutter App (Dart)           │
│   lib/core/crypto/                  │
│   lib/generated/rust/               │
└─────────────────┬───────────────────┘
                  │ FFI (dart:ffi)
┌─────────────────▼───────────────────┐
│       guardyn-crypto-ffi            │
│   backend/crates/crypto-ffi/        │
│   (flutter_rust_bridge bindings)    │
└─────────────────┬───────────────────┘
                  │ Rust
┌─────────────────▼───────────────────┐
│        guardyn-crypto               │
│   backend/crates/crypto/            │
│  (X3DH, Double Ratchet, MLS, PQXDH) │
└─────────────────────────────────────┘
```

## Current Status

| Component                  | Status      | Notes                                |
| -------------------------- | ----------- | ------------------------------------ |
| guardyn-crypto crate       | ✅ Complete | X3DH, Double Ratchet, MLS, PQXDH     |
| guardyn-crypto-ffi crate   | ✅ Complete | FFI wrapper with flutter_rust_bridge |
| FFI API (api.rs)           | ✅ Complete | 20+ functions exposed                |
| Build scripts              | ✅ Complete | Android, iOS, Desktop support        |
| Flutter integration        | ✅ Complete | Placeholder bindings ready           |
| Dart bindings generation   | 🔜 Pending  | Run `just ffi-generate`              |
| Legacy Dart crypto removal | ⏸️ Deferred | After FFI validation                 |

## Quick Start

### 1. Check FFI compiles

```bash
just ffi-check
```

### 2. Run tests

```bash
just ffi-test
```

### 3. Build for current platform

```bash
just ffi-build-desktop
```

### 4. Generate Dart bindings

```bash
just ffi-generate
```

### 5. Build for mobile

```bash
# Android
just ffi-build-android

# iOS (macOS only)
just ffi-build-ios

# All platforms
just ffi-build-all
```

## Project Structure

### Backend (Rust)

```text
backend/crates/
├── crypto/                     # Core crypto library
│   ├── src/
│   │   ├── x3dh.rs            # X3DH key exchange
│   │   ├── double_ratchet.rs  # Double Ratchet
│   │   ├── mls.rs             # MLS group encryption
│   │   ├── pqxdh.rs           # Post-quantum key exchange
│   │   ├── padding.rs         # PADMÉ padding
│   │   ├── sealed_sender.rs   # Metadata protection
│   │   └── ffi.rs             # FFI exports
│   └── Cargo.toml
│
└── crypto-ffi/                 # Flutter Rust Bridge wrapper
    ├── src/
    │   ├── lib.rs             # Crate root
    │   ├── api.rs             # FRB API (exposed to Dart)
    │   └── frb_generated.rs   # Generated code placeholder
    ├── flutter_rust_bridge.yaml  # FRB configuration
    ├── build-mobile.sh        # Cross-compilation script
    ├── Cargo.toml
    └── README.md
```

### Client (Flutter)

```text
client-mobile/
├── lib/
│   ├── core/
│   │   └── crypto/
│   │       ├── native_crypto_bridge.dart    # CryptoBridge interface
│   │       └── native/
│   │           └── rust_crypto_bridge.dart  # Native implementation
│   └── generated/
│       └── rust/
│           ├── lib.dart           # Re-exports
│           ├── api.dart           # API stubs (generated)
│           └── frb_generated.dart # FRB runtime (generated)
├── native/                        # Compiled libraries
│   ├── android/
│   │   ├── arm64-v8a/
│   │   ├── armeabi-v7a/
│   │   └── x86_64/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   └── windows/
└── scripts/
    └── build-native-crypto.sh    # Integration script
```

## API Reference

### Initialization

| Function                   | Description               |
| -------------------------- | ------------------------- |
| `crypto_init()`            | Initialize crypto library |
| `crypto_status()`          | Get library status        |
| `crypto_is_pq_available()` | Check PQ availability     |

### Key Generation

| Function                              | Description       |
| ------------------------------------- | ----------------- |
| `crypto_generate_x25519_keypair()`    | X25519 key pair   |
| `crypto_generate_ed25519_keypair()`   | Ed25519 key pair  |
| `crypto_generate_hybrid_key_bundle()` | PQXDH hybrid keys |

### Encryption

| Function                    | Description                  |
| --------------------------- | ---------------------------- |
| `crypto_encrypt_aes_gcm()`  | AES-256-GCM encryption       |
| `crypto_decrypt_aes_gcm()`  | AES-256-GCM decryption       |
| `crypto_encrypt_chacha20()` | ChaCha20-Poly1305 encryption |
| `crypto_decrypt_chacha20()` | ChaCha20-Poly1305 decryption |

### Key Derivation

| Function             | Description    |
| -------------------- | -------------- |
| `crypto_hkdf()`      | HKDF-SHA256    |
| `crypto_x25519_dh()` | Diffie-Hellman |

### Signatures

| Function                  | Description          |
| ------------------------- | -------------------- |
| `crypto_sign_ed25519()`   | Ed25519 signing      |
| `crypto_verify_ed25519()` | Ed25519 verification |

### Padding

| Function                 | Description          |
| ------------------------ | -------------------- |
| `crypto_pad_message()`   | Apply PADMÉ padding  |
| `crypto_unpad_message()` | Remove PADMÉ padding |

### Utilities

| Function                    | Description              |
| --------------------------- | ------------------------ |
| `crypto_random_bytes()`     | Secure random bytes      |
| `crypto_constant_time_eq()` | Constant-time comparison |

## Cross-Platform Support

| Platform            | Library                       | Status       |
| ------------------- | ----------------------------- | ------------ |
| Android arm64-v8a   | `libguardyn_crypto_ffi.so`    | ✅ Supported |
| Android armeabi-v7a | `libguardyn_crypto_ffi.so`    | ✅ Supported |
| Android x86_64      | `libguardyn_crypto_ffi.so`    | ✅ Supported |
| iOS arm64           | `GuardynCrypto.xcframework`   | ✅ Supported |
| iOS simulator       | `GuardynCrypto.xcframework`   | ✅ Supported |
| Linux x86_64        | `libguardyn_crypto_ffi.so`    | ✅ Supported |
| macOS arm64/x86_64  | `libguardyn_crypto_ffi.dylib` | ✅ Supported |
| Windows x86_64      | `guardyn_crypto_ffi.dll`      | ✅ Supported |
| Web (WASM)          | `guardyn_crypto_ffi.wasm`     | 🔜 Planned   |

## Prerequisites

### All Platforms

- Rust 1.70+
- `flutter_rust_bridge_codegen`:
  ```bash
  cargo install flutter_rust_bridge_codegen
  ```

### Android

- Android NDK 24+
- Set `ANDROID_NDK_HOME` environment variable

### iOS (macOS only)

- Xcode 14+
- iOS SDK

## Troubleshooting

### "Library not found" on Android

Ensure libraries are in correct JNI directory:

```bash
cd client-mobile
./scripts/build-native-crypto.sh android
```

### flutter_rust_bridge_codegen fails

Update to latest version:

```bash
cargo install flutter_rust_bridge_codegen --force
```

### Post-quantum not available

Enable the `pq` feature:

```bash
cargo build -p guardyn-crypto-ffi --features pq
```

## Next Steps

1. **Generate bindings**: `just ffi-generate`
2. **Build for platform**: `just ffi-build-android` / `just ffi-build-ios`
3. **Enable in Flutter**: Uncomment NativeRustCryptoBridge in factory
4. **Remove legacy Dart crypto**: After validation

## Security Notes

- All cryptographic operations are performed in Rust
- Keys are zeroized on drop
- Constant-time comparisons prevent timing attacks
- Post-quantum keys (ML-KEM-768) provide quantum resistance
- PADMÉ padding protects against traffic analysis
