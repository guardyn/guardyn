# guardyn-crypto-ffi Native Libraries

This directory contains pre-compiled Rust native libraries for guardyn-crypto-ffi crate.

## Building

To build these libraries:

```bash
cd backend/crates/crypto-ffi
./build-mobile.sh all
```

## Structure

```text
native/
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

## Important Notes

- DO NOT COMMIT BINARY FILES TO GIT
- Add `*.so`, `*.dylib`, `*.dll`, `*.a`, `*.xcframework` to `.gitignore`
