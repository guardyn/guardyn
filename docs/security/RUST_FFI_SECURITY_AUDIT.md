# Rust FFI Security Audit Checklist

> **Version:** 1.0  
> **Status:** Pre-Audit Preparation  
> **Last Updated:** 2026-01-18

## Overview

This document provides a comprehensive security audit checklist for the Guardyn Rust FFI cryptography integration. The audit covers the entire cryptographic stack from the Rust `guardyn-crypto` library to the Flutter/Dart integration layer.

---

## 1. Audit Scope

### 1.1 Components Under Review

| Component              | Location                                               | Lines of Code | Priority     |
| ---------------------- | ------------------------------------------------------ | ------------- | ------------ |
| guardyn-crypto         | `backend/crates/crypto/`                               | ~3,500        | **Critical** |
| guardyn-crypto-ffi     | `backend/crates/crypto-ffi/`                           | ~500          | **Critical** |
| NativeRustCryptoBridge | `client-mobile/lib/core/crypto/native/`                | ~400          | **High**     |
| CryptoPrimitives       | `client-mobile/lib/core/crypto/crypto_primitives.dart` | ~300          | **High**     |
| Generated FFI Bindings | `client-mobile/lib/generated/rust/`                    | ~800          | **Medium**   |

### 1.2 Cryptographic Primitives

| Primitive          | Implementation          | Underlying Library | Audit Status |
| ------------------ | ----------------------- | ------------------ | ------------ |
| X25519 DH          | `crypto/src/x3dh.rs`    | x25519-dalek       | ⏳ Pending   |
| Ed25519 Signatures | `crypto/src/ffi.rs`     | ed25519-dalek      | ⏳ Pending   |
| AES-256-GCM        | `crypto/src/ffi.rs`     | aes-gcm            | ⏳ Pending   |
| ChaCha20-Poly1305  | `crypto/src/ffi.rs`     | chacha20poly1305   | ⏳ Pending   |
| HKDF-SHA256/512    | `crypto/src/ffi.rs`     | hkdf               | ⏳ Pending   |
| ML-KEM-768 (PQ)    | `crypto/src/pqxdh.rs`   | ml-kem             | ⏳ Pending   |
| PADMÉ Padding      | `crypto/src/padding.rs` | Custom             | ⏳ Pending   |

---

## 2. Security Audit Checklist

### 2.1 Memory Safety (Rust Side)

- [ ] **Key Zeroization**
  - [ ] All secret keys implement `Zeroize` trait
  - [ ] Keys are zeroed on drop (`ZeroizeOnDrop`)
  - [ ] Stack memory is cleared after crypto operations
  - [ ] No secret data in error messages or logs

- [ ] **Buffer Handling**
  - [ ] No buffer overflows in FFI boundary
  - [ ] Input validation for all byte arrays
  - [ ] Maximum size limits enforced
  - [ ] Proper handling of empty inputs

- [ ] **Memory Allocation**
  - [ ] No heap fragmentation attacks possible
  - [ ] Constant-time memory operations where needed
  - [ ] No memory leaks in FFI layer

### 2.2 FFI Boundary Security

- [ ] **Type Safety**
  - [ ] All parameters properly validated before use
  - [ ] No raw pointer exposure to Dart
  - [ ] Proper error handling across FFI boundary
  - [ ] No panics that cross FFI boundary

- [ ] **Data Marshaling**
  - [ ] Correct byte order (endianness) handling
  - [ ] No data truncation in conversions
  - [ ] Proper handling of null/empty values
  - [ ] UTF-8 validation for strings

- [ ] **Thread Safety**
  - [ ] No race conditions in crypto state
  - [ ] Proper synchronization for shared resources
  - [ ] No double-free conditions
  - [ ] Safe concurrent key generation

### 2.3 Cryptographic Correctness

- [ ] **Key Generation**
  - [ ] Cryptographically secure RNG used (`OsRng`)
  - [ ] Correct key sizes enforced
  - [ ] Key validation on generation
  - [ ] Ed25519 to X25519 conversion correct

- [ ] **Encryption/Decryption**
  - [ ] Nonce uniqueness enforced
  - [ ] Authentication tag verified before decryption
  - [ ] No padding oracle vulnerabilities
  - [ ] Ciphertext indistinguishable from random

- [ ] **Key Exchange**
  - [ ] X3DH protocol correctly implemented
  - [ ] No small-subgroup attacks possible
  - [ ] Hybrid PQ key exchange correct
  - [ ] Shared secrets properly derived

- [ ] **Signatures**
  - [ ] Ed25519 verification is strict
  - [ ] No signature malleability
  - [ ] Message context/domain separation
  - [ ] Batch verification if used

### 2.4 Side-Channel Resistance

- [ ] **Timing Attacks**
  - [ ] Constant-time comparison for secrets
  - [ ] No secret-dependent branches
  - [ ] Constant-time key operations
  - [ ] Timing-safe memory access

- [ ] **Cache Attacks**
  - [ ] No secret-dependent memory access patterns
  - [ ] Precomputation tables properly used
  - [ ] AES-NI used when available

- [ ] **Power Analysis**
  - [ ] Relevant for mobile/embedded audit
  - [ ] Consider hardware security modules

### 2.5 Error Handling

- [ ] **Information Leakage**
  - [ ] Error messages don't reveal secrets
  - [ ] No timing differences in error paths
  - [ ] Consistent error types returned
  - [ ] Stack traces don't contain keys

- [ ] **Failure Modes**
  - [ ] Fail-closed behavior (deny on error)
  - [ ] No partial state on failure
  - [ ] Atomic operations for crypto state

---

## 3. FFI-Specific Security Concerns

### 3.1 Flutter Rust Bridge (FRB) Security

| Concern           | Check                               | Status    |
| ----------------- | ----------------------------------- | --------- |
| Memory management | FRB handles allocation/deallocation | ⏳ Verify |
| Async safety      | Isolate-safe operations             | ⏳ Verify |
| Error propagation | Rust errors converted safely        | ⏳ Verify |
| Type mapping      | All types correctly mapped          | ⏳ Verify |

### 3.2 Platform-Specific Concerns

#### Android

- [ ] JNI library loading secure
- [ ] No world-readable library files
- [ ] Correct ABI for each architecture
- [ ] ProGuard/R8 doesn't strip needed symbols
- [ ] No cleartext secrets in Logcat

#### iOS

- [ ] XCFramework properly signed
- [ ] No exportable symbols leak secrets
- [ ] Correct architectures for device/simulator
- [ ] App Transport Security compatible
- [ ] No secrets in crash logs

#### Desktop

- [ ] Library loading from secure paths
- [ ] No DLL hijacking possible (Windows)
- [ ] Correct RPATH settings (Linux)
- [ ] Code signing verified (macOS)

---

## 4. Test Coverage Requirements

### 4.1 Unit Tests (Rust)

```bash
# Run all crypto tests
cargo test -p guardyn-crypto --features full

# Current status
✅ 45+ unit tests passing
```

| Module         | Tests | Coverage |
| -------------- | ----- | -------- |
| X3DH           | 12    | 85%+     |
| Double Ratchet | 15    | 85%+     |
| MLS            | 8     | 80%+     |
| PQXDH          | 5     | 80%+     |
| Padding        | 5     | 90%+     |

### 4.2 Integration Tests (Flutter)

```bash
# Desktop
flutter test integration_test/crypto/rust_ffi_test.dart -d linux

# Android (device required)
flutter test integration_test/crypto/rust_ffi_test.dart -d <device>

# iOS (macOS + device required)
flutter test integration_test/crypto/rust_ffi_test.dart -d <ios-device>
```

| Platform            | Tests | Status     |
| ------------------- | ----- | ---------- |
| Linux x86_64        | 17/17 | ✅ Passed  |
| Android arm64-v8a   | 17    | ⏳ Pending |
| Android armeabi-v7a | 17    | ⏳ Pending |
| Android x86_64      | 17    | ⏳ Pending |
| iOS arm64           | 17    | ⏳ Pending |
| iOS Simulator       | 17    | ⏳ Pending |
| macOS               | 17    | ⏳ Pending |
| Windows             | 17    | ⏳ Pending |

### 4.3 Fuzzing Requirements

| Target            | Tool       | Duration | Status   |
| ----------------- | ---------- | -------- | -------- |
| FFI input parsing | cargo-fuzz | 24h+     | ⏳ Setup |
| Crypto decryption | cargo-fuzz | 24h+     | ⏳ Setup |
| Key derivation    | cargo-fuzz | 24h+     | ⏳ Setup |
| PADMÉ padding     | cargo-fuzz | 24h+     | ⏳ Setup |

---

## 5. Dependency Audit

### 5.1 Direct Dependencies

| Crate               | Version | Audit Status      | CVE Check |
| ------------------- | ------- | ----------------- | --------- |
| ed25519-dalek       | 2.1+    | ✅ Audited (2023) | ✅ Clear  |
| x25519-dalek        | 2.0+    | ✅ Audited (2023) | ✅ Clear  |
| aes-gcm             | 0.10+   | ✅ RustCrypto     | ✅ Clear  |
| chacha20poly1305    | 0.10+   | ✅ RustCrypto     | ✅ Clear  |
| hkdf                | 0.12+   | ✅ RustCrypto     | ✅ Clear  |
| ml-kem              | 0.2+    | ⚠️ New (NIST)     | ✅ Clear  |
| zeroize             | 1.7+    | ✅ RustCrypto     | ✅ Clear  |
| rand_core           | 0.6+    | ✅ Audited        | ✅ Clear  |
| flutter_rust_bridge | 2.0+    | ⚠️ Review needed  | ✅ Clear  |

### 5.2 Transitive Dependencies

```bash
# Run dependency audit
cargo audit

# Generate SBOM
cargo sbom > sbom.json
```

---

## 6. Pre-Audit Preparation Tasks

### 6.1 Code Preparation

- [x] All code in single repository
- [x] Clear documentation of crypto architecture
- [x] Test coverage reports available
- [ ] Fuzzing harnesses prepared
- [ ] Build instructions verified

### 6.2 Documentation Preparation

- [x] `docs/RUST_FFI_INTEGRATION.md` - Integration guide
- [x] `docs/RUST_FFI_STATUS.md` - Implementation status
- [x] `docs/security/SECURITY_AUDIT.md` - General audit info
- [x] `docs/security/RUST_FFI_SECURITY_AUDIT.md` - This document
- [ ] Threat model document (update for FFI)
- [ ] Data flow diagrams

### 6.3 Environment Preparation

- [ ] Clean build environment
- [ ] All platforms tested
- [ ] Debugging symbols available
- [ ] Source maps for auditors

---

## 7. Recommended Audit Focus Areas

### Priority 1: Critical

1. **FFI Boundary** - Memory safety at Rust/Dart interface
2. **Key Zeroization** - Proper secret cleanup
3. **RNG Usage** - Cryptographic randomness source
4. **AEAD Implementation** - Encryption correctness

### Priority 2: High

1. **X3DH Protocol** - Key exchange security
2. **Double Ratchet** - Message key derivation
3. **Ed25519/X25519 Conversion** - Key conversion correctness
4. **Error Handling** - No information leakage

### Priority 3: Medium

1. **PADMÉ Padding** - Traffic analysis resistance
2. **MLS Integration** - Group encryption
3. **Post-Quantum** - ML-KEM integration
4. **Platform-Specific** - Mobile security

---

## 8. Post-Audit Actions

### 8.1 Issue Remediation

| Severity | SLA     | Action                      |
| -------- | ------- | --------------------------- |
| Critical | 24h     | Immediate patch, disclosure |
| High     | 7 days  | Priority fix, testing       |
| Medium   | 30 days | Scheduled fix               |
| Low      | 90 days | Backlog                     |

### 8.2 Verification

- [ ] Fixes reviewed by auditors
- [ ] Regression tests added
- [ ] Re-audit of changed code
- [ ] Public disclosure (if applicable)

---

## Appendix A: Build Commands

```bash
# Build all FFI libraries
just ffi-build-all

# Individual platforms
just ffi-build-android
just ffi-build-ios
just ffi-build-desktop

# Run tests
just ffi-test

# Generate Dart bindings
just ffi-generate
```

## Appendix B: Key Files for Audit

```
backend/crates/crypto/
├── src/
│   ├── lib.rs              # Crate root, feature flags
│   ├── ffi.rs              # FFI exports (~300 lines) ⭐
│   ├── x3dh.rs             # X3DH protocol (~500 lines) ⭐
│   ├── double_ratchet.rs   # Double Ratchet (~400 lines) ⭐
│   ├── mls.rs              # MLS groups (~300 lines)
│   ├── pqxdh.rs            # Post-quantum (~200 lines)
│   ├── padding.rs          # PADMÉ (~100 lines)
│   └── sealed_sender.rs    # Metadata protection (~200 lines)
└── Cargo.toml

backend/crates/crypto-ffi/
├── src/
│   ├── lib.rs              # Crate root
│   └── api.rs              # FRB API (~400 lines) ⭐
├── flutter_rust_bridge.yaml
└── Cargo.toml

client-mobile/lib/core/crypto/
├── native_crypto_bridge.dart      # Interface (~150 lines)
├── crypto_primitives.dart         # Static API (~200 lines) ⭐
└── native/
    ├── rust_crypto_bridge.dart    # Native impl (~300 lines) ⭐
    ├── native_bridge_io.dart      # IO support (~50 lines)
    └── native_bridge_stub.dart    # Web stub (~20 lines)
```

## Appendix C: Security Contacts

| Role           | Contact                  |
| -------------- | ------------------------ |
| Security Lead  | security@yourdomain.com  |
| Technical Lead | tech-lead@yourdomain.com |
| Emergency      | emergency@yourdomain.com |

---

**Document History:**

| Version | Date       | Author       | Changes          |
| ------- | ---------- | ------------ | ---------------- |
| 1.0     | 2026-01-18 | Guardyn Team | Initial document |
