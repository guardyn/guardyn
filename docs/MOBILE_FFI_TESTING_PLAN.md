# Mobile FFI Testing Plan (Android + Linux Cross-Device)

> **Goal:** Validate Rust FFI crypto works on real Android device and test cross-platform messaging between Android and Linux clients.

---

## Quick Reference

```bash
# Android FFI test only
just ffi-test-android

# Two clients (Android + Linux) messaging test
./client-mobile/scripts/run-android-linux-test.sh
```

---

## Part 1: Android FFI Integration Test

### Prerequisites

1. **Android device connected via USB** (or emulator running)
2. **USB Debugging enabled** on device
3. **Android libraries built** (already done)

### Step-by-Step

#### 1. Check device connection

```bash
# List connected devices
flutter devices

# Expected output:
# SM G990B (mobile) • RFXXXXXXXX • android-arm64 • Android 14
```

#### 2. Verify native libraries are in place

```bash
ls -la client-mobile/android/app/src/main/jniLibs/*/
# Should show libguardyn_crypto_ffi.so for all architectures
```

#### 3. Run FFI integration tests

```bash
cd client-mobile

# Run crypto FFI tests on Android
flutter test integration_test/crypto/rust_ffi_test.dart -d <device-id>

# Or use just command
just ffi-test-android
```

#### 4. Expected output (17 tests)

```
✓ Native crypto is available
✓ Generate X25519 key pair
✓ Generate Ed25519 key pair
✓ AES-256-GCM encryption/decryption round-trip
✓ ChaCha20-Poly1305 encryption/decryption round-trip
✓ Ed25519 signing and verification
✓ HKDF key derivation
✓ X25519 Diffie-Hellman key agreement
✓ PADMÉ padding
✓ Random bytes generation
✓ Constant-time comparison
✓ CryptoBridgeFactory returns native bridge
✓ Ed25519 public key to X25519 conversion
✓ Ed25519 secret key to X25519 conversion
✓ Ed25519 to X25519 conversion enables DH
✓ Check PQ availability
✓ Generate hybrid key bundle (if PQ available)

All tests passed!
```

---

## Part 2: Two-Client Testing (Android + Linux)

This tests real E2EE messaging between two different users on different platforms.

### Architecture

```
┌─────────────────────┐              ┌─────────────────────┐
│   Android Device    │              │   Linux Desktop     │
│   (User: Alice)     │◄────────────►│   (User: Bob)       │
│                     │              │                     │
│ - Rust FFI crypto   │   Backend    │ - Rust FFI crypto   │
│ - Native gRPC       │   Services   │ - Native gRPC       │
└──────────┬──────────┘              └──────────┬──────────┘
           │                                    │
           └────────────────┬───────────────────┘
                            │
              ┌─────────────▼─────────────┐
              │   Backend (Docker Compose) │
              │   - auth-service:50051     │
              │   - messaging-service:50052│
              │   - envoy-proxy:18080      │
              └───────────────────────────┘
```

### Prerequisites

1. **Backend services running**
2. **Android device connected**
3. **Linux desktop (current machine)**

### Step-by-Step

#### 1. Start backend services

```bash
# Option A: Docker Compose (recommended for local dev)
docker compose -f docker-compose.dev.yml up -d

# Verify services are running
docker compose -f docker-compose.dev.yml ps

# Option B: Kubernetes cluster
just kube-bootstrap
just k8s-deploy all
```

#### 2. Verify backend connectivity

```bash
# Check auth service
grpcurl -plaintext localhost:50051 list

# Check messaging service
grpcurl -plaintext localhost:50052 list
```

#### 3. Connect Android device

```bash
# Ensure device is connected
adb devices
# Should show: RFXXXXXXXX  device

# Check Flutter sees it
flutter devices
```

#### 4. Run the test

**Option A: Automated script** (Recommended)

```bash
# From project root
./client-mobile/scripts/run-android-linux-test.sh
```

**Option B: Manual (two terminals)**

**Terminal 1 - Desktop (Bob) - Tauri:**

```bash
cd client-desktop

# Run Tauri desktop app
npm run tauri dev
```

**Terminal 2 - Android (Alice) - Flutter:**

```bash
cd client-mobile

# Run on Android device
flutter run -d <device-id> --dart-define=TEST_USER=alice
```

#### 5. Manual test flow

1. **Bob (Desktop - Tauri):** Register account → copy username
2. **Alice (Android - Flutter):** Register account → search for Bob → send message
3. **Bob (Desktop):** Receive message → verify decryption → reply
4. **Alice (Android):** Receive reply → verify decryption

---

## Part 3: Full E2E Integration Test

For automated cross-device messaging test:

### Prerequisites

```bash
# 1. Backend running
docker compose -f docker-compose.dev.yml up -d

# 2. Android device connected
flutter devices | grep android

# 3. Linux libraries installed
just ffi-install-linux
```

### Run automated test

```bash
cd client-mobile

# Run two-client messaging test
flutter test integration_test/two_client_messaging_test.dart \
  -d linux \
  --dart-define=TEST_PLATFORM=linux &

flutter test integration_test/two_client_messaging_test.dart \
  -d <android-device-id> \
  --dart-define=TEST_PLATFORM=android
```

---

## Troubleshooting

### "Native library not found" on Android

```bash
# Rebuild and reinstall libraries
just ffi-build-android

# Copy to jniLibs
cp -r client-mobile/native/android/* \
      client-mobile/android/app/src/main/jniLibs/

# Clean and rebuild app
cd client-mobile && flutter clean && flutter run -d <device>
```

### "Connection refused" to backend

```bash
# Check Docker services
docker compose -f docker-compose.dev.yml ps

# Restart if needed
docker compose -f docker-compose.dev.yml restart
```

### Android device not visible

```bash
# Restart ADB
adb kill-server && adb start-server

# Check USB debugging is enabled
adb devices
```

### "flutter_rust_bridge already initialized"

This is a known limitation - FRB can only be initialized once per process. The tests handle this by catching the exception.

---

## Test Matrix

| Test                 | Platform         | Crypto   | Status     |
| -------------------- | ---------------- | -------- | ---------- |
| FFI Unit Tests       | Linux            | Rust FFI | ✅ 62/62   |
| FFI Integration      | Linux            | Rust FFI | ✅ 17/17   |
| FFI Integration      | Android          | Rust FFI | ⏳ Pending |
| FFI Integration      | iOS              | Rust FFI | ⏳ Pending |
| Two-Client Messaging | Android + Linux  | Rust FFI | ⏳ Pending |
| Two-Client Messaging | Android + Chrome | Rust FFI | ⏳ Pending |

---

## Success Criteria

### FFI Test (per platform)

- [ ] All 17 crypto tests pass
- [ ] Native library loads successfully
- [ ] Key generation works
- [ ] Encryption/decryption round-trip succeeds
- [ ] Signatures verify correctly

### Two-Client Test

- [ ] Both users can register
- [ ] Key exchange completes (X3DH)
- [ ] Message encrypts on sender
- [ ] Message decrypts on receiver
- [ ] Reply works in both directions
- [ ] No plaintext visible in logs
