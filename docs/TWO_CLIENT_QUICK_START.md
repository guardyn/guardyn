# Two-Client Testing Quick Start (Android + Linux)

Quick guide for testing messaging between Android and Linux clients.

## Prerequisites

1. **Backend running** (Docker Compose)
2. **Android emulator** running
3. **Rust FFI libraries** compiled for both platforms

## Quick Start

### Step 1: Start Backend

```bash
cd /home/anry/projects/guardyn/guardyn
docker compose -f docker-compose.dev.yml up -d
```

Verify all services are healthy:

```bash
docker compose -f docker-compose.dev.yml ps
```

All services should show `(healthy)` or `Up`.

### Step 2: Start Android Emulator

```bash
# List available emulators
$HOME/Android/Sdk/emulator/emulator -list-avds

# Start emulator (replace with your AVD name)
$HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36 &

# Wait for boot and verify
adb devices
# Should show: emulator-5554  device
```

### Step 3: Build FFI Libraries (if not done)

```bash
cd client-mobile

# For Linux
./scripts/build-rust-ffi.sh linux

# For Android
./scripts/build-rust-ffi.sh android
```

### Step 4: Run Two Clients

**Option A: Using Script (Recommended)**

```bash
cd client-mobile
./scripts/run-android-linux-messaging.sh
```

**Option B: Manual (Two Terminals)**

**Terminal 1 - Linux (Bob):**

```bash
cd client-mobile
flutter test integration_test/android_linux_messaging_test.dart \
  -d linux \
  --dart-define=TEST_ROLE=bob \
  --dart-define=TEST_RUN_ID=test1
```

**Terminal 2 - Android (Alice):** (start within 30 seconds)

```bash
cd client-mobile
flutter test integration_test/android_linux_messaging_test.dart \
  -d emulator-5554 \
  --dart-define=TEST_ROLE=alice \
  --dart-define=TEST_RUN_ID=test1
```

## Expected Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Test Timeline                          │
├─────────────────────────────────────────────────────────────┤
│ Time   │ Alice (Android)          │ Bob (Linux)            │
├────────┼──────────────────────────┼────────────────────────┤
│ 0s     │ Start test               │ Start test             │
│ 5s     │ Register alice_test1     │ Wait for Alice...      │
│ 30s    │ -                        │ Register bob_test1     │
│ 35s    │ Search for Bob           │ Wait for message       │
│ 40s    │ Send "Hello from Android"│ Receive message        │
│ 45s    │ Wait for reply           │ Send "Reply from Linux"│
│ 50s    │ Receive reply ✅          │ Complete ✅             │
│ 55s    │ Complete ✅               │ -                      │
└────────┴──────────────────────────┴────────────────────────┘
```

## Troubleshooting

### Backend Services Not Running

```bash
# Check status
docker compose -f docker-compose.dev.yml ps

# Restart all
docker compose -f docker-compose.dev.yml up -d

# Check logs if service crashed
docker logs guardyn-auth --tail 50
docker logs guardyn-messaging --tail 50
```

### Android App Crashes (ANR Dialog)

Heavy crypto operations can cause ANR. The test script auto-dismisses these:

```bash
# Manual dismiss if needed
adb shell input tap 800 1050
```

### Permission Dialogs on Android

Grant permissions before test:

```bash
adb shell pm grant io.guardyn.guardyn_client android.permission.POST_NOTIFICATIONS
```

### Client Already Logged In

Clear app data before test:

```bash
# Android
adb shell pm clear io.guardyn.guardyn_client

# Linux - delete secure storage
rm -rf ~/.local/share/guardyn_client/
```

### Test Timeout

Increase sync timeout in test or check backend connectivity:

```bash
# Test gRPC connectivity
grpcurl -plaintext localhost:50051 list
grpcurl -plaintext localhost:50052 list
```

## Clean Restart

If tests fail repeatedly:

```bash
# 1. Stop everything
docker compose -f docker-compose.dev.yml down

# 2. Clear Android app data
adb shell pm clear io.guardyn.guardyn_client 2>/dev/null || true

# 3. Clear Linux app data
rm -rf ~/.local/share/guardyn_client/

# 4. Clear sync files
rm -rf /tmp/guardyn_test_sync/

# 5. Restart backend
docker compose -f docker-compose.dev.yml up -d

# 6. Wait for services
sleep 30

# 7. Run tests again
cd client-mobile && ./scripts/run-android-linux-messaging.sh
```

## See Also

- [Full Testing Guide](TWO_CLIENT_TESTING.md) - Detailed documentation
- [Client Mobile README](../client-mobile/README.md) - Client setup
- [Docker Dev Guide](DOCKER_DEV_GUIDE.md) - Backend setup
