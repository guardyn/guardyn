# Two-Client Integration Testing (Android + Linux)

This guide describes how to run integration tests between two different Flutter clients running on different platforms.

## Overview

The two-client test simulates real-world messaging between:

- **Alice** on Android emulator
- **Bob** on Linux desktop

This validates cross-platform E2EE messaging, key exchange, and real-time communication.

> **Security Note**: Web platform (Chrome/Firefox) has been removed for security reasons.
> All cryptographic operations use native Rust FFI via guardyn-crypto library.

## Architecture

```
┌─────────────────┐         ┌─────────────────┐
│  Alice (Android)│         │   Bob (Linux)   │
│   emulator      │◄───────►│    desktop      │
└────────┬────────┘         └────────┬────────┘
         │                           │
         │        Native gRPC        │  Native gRPC
         │       (10.0.2.2:50051)    │  (localhost:50051)
         ▼                           ▼
    ┌────────────────────────────────────┐
    │      Backend Services              │
    │  - auth-service (port 50051)       │
    │  - messaging-service (port 50052)  │
    └────────────────────────────────────┘
```

## Prerequisites

### 1. Backend Services Running (Docker Compose)

```bash
# Start all backend services
docker compose -f docker-compose.dev.yml up -d

# Check services are running
docker compose -f docker-compose.dev.yml ps

# Should show:
# - auth-service     Running
# - messaging-service Running
# - redis            Running
# - scylla           Running
```

### 2. Android Emulator Running

```bash
# List available AVDs
$HOME/Android/Sdk/emulator/emulator -list-avds

# Start an emulator
$HOME/Android/Sdk/emulator/emulator -avd <avd-name> &

# Wait for emulator to boot (30-60 seconds)
flutter devices  # Should show emulator-5554
```

### 3. Flutter Desktop Enabled

```bash
# Verify Linux desktop support
flutter devices | grep linux

# If not shown, enable it
flutter config --enable-linux-desktop
```

## Running the Tests

### Automated Test (Recommended)

Run the two-client messaging test:

```bash
just test-two-client-messaging
```

This will:

1. Verify all prerequisites
2. Launch Android test (Alice)
3. Launch Linux test (Bob)
4. Monitor both test outputs
5. Report results

### Quick Setup Script

```bash
cd client-mobile/
./scripts/test-client.sh two-device linux
```

### Manual Test (Each Client Separately)

If you need to run tests manually:

**Terminal 1 - Linux (Alice):**

```bash
cd client-mobile/
flutter run -d linux
```

**Terminal 2 - Android (Bob):**

```bash
cd client-mobile/
flutter run -d emulator-5554
```

## Test Scenarios

### Scenario 1: Basic Message Exchange

1. **Alice (Linux)**: Register as `alice` / `password12345`
2. **Bob (Android)**: Register as `bob` / `password12345`
3. **Alice**: Copy Bob's User ID from his HomePage
4. **Alice**: Open Messages → New Chat → Enter Bob's User ID
5. **Alice**: Send message "Hello Bob!"
6. **Bob**: Receive message notification, open chat
7. **Bob**: Reply "Hi Alice!"
8. **Alice**: Receive Bob's reply

**Expected Results:**

- ✅ Both users register successfully
- ✅ Messages delivered in real-time (< 2 seconds)
- ✅ Messages appear with correct sender/receiver alignment
- ✅ Delivery status updates (sent → delivered)

### Scenario 2: Offline Message Delivery

1. **Alice (Linux)**: Login as `alice`
2. **Bob (Android)**: Close app completely
3. **Alice**: Send message "Are you there?"
4. **Bob**: Open app, login as `bob`
5. **Bob**: Check Messages

**Expected Results:**

- ✅ Message queued on server while Bob offline
- ✅ Message delivered when Bob comes online
- ✅ Message history persisted correctly

### Scenario 3: E2EE Key Exchange

1. **Clear all local data on both devices**
2. **Alice**: Register new user `alice2`
3. **Bob**: Register new user `bob2`
4. **Alice**: Send first message to Bob

**Expected Results:**

- ✅ X3DH key exchange happens automatically
- ✅ Double Ratchet session established
- ✅ Messages encrypted with forward secrecy
- ✅ Check logs for `[CRYPTO]` messages showing key exchange

## Troubleshooting

### "Connection refused" on Android

```bash
# Verify backend services are running
docker compose -f docker-compose.dev.yml ps

# Check if ports are accessible
nc -zv localhost 50051
nc -zv localhost 50052
```

Android emulator uses `10.0.2.2` to reach host's `localhost`.

### "Connection refused" on Linux

```bash
# Check services
docker compose -f docker-compose.dev.yml ps

# View auth-service logs
docker compose -f docker-compose.dev.yml logs auth-service
```

### Messages not appearing

```bash
# Check messaging-service logs
docker compose -f docker-compose.dev.yml logs messaging-service

# Verify both clients are connected to same backend
# Check User IDs are copied correctly
```

### Crypto initialization error

```bash
# Verify native library built
ls client-mobile/native/target/release/

# Rebuild if needed
cd client-mobile/native
cargo build --release
```

## Verification Checklist

**Before testing:**

- [ ] Backend services running (`docker compose ps`)
- [ ] Android emulator booted (`flutter devices`)
- [ ] Linux desktop enabled (`flutter config`)
- [ ] Native crypto library built

**During testing:**

- [ ] Both clients successfully register
- [ ] User IDs displayed on HomePage
- [ ] Messages send without errors
- [ ] Messages received in real-time
- [ ] Delivery status updates
- [ ] Bidirectional communication works
- [ ] No crashes or data loss

## Platform-Specific Notes

### Android

- Uses host IP `10.0.2.2` for localhost access
- Requires ADB port-forwarding for USB debugging
- Test on API 30+ for best results

### Linux

- Uses native gRPC (not gRPC-Web)
- Connects directly to `localhost:50051`
- Requires GTK libraries installed

### iOS (Future)

- Uses `localhost` like Linux
- Requires Xcode and iOS Simulator
- Same gRPC configuration as Linux

### macOS/Windows Desktop (via Tauri)

For desktop platforms, use the Tauri client:

```bash
cd client-desktop/
npm run tauri dev
```

## Additional Resources

- [Client Testing Guide](CLIENT_TESTING_GUIDE.md)
- [Docker Development Guide](DOCKER_DEV_GUIDE.md)
- [Encryption Architecture](ENCRYPTION_ARCHITECTURE.md)
- [Rust FFI Integration](RUST_FFI_INTEGRATION.md)

---

**Ready to test! Good luck! 🚀**
