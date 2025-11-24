# Two-Client Integration Testing (Android + Chrome)

This guide describes how to run automated integration tests between two different Flutter clients running on different platforms.

## Overview

The two-client test simulates real-world messaging between:

- **Alice** on Android emulator
- **Bob** on Chrome browser

This validates cross-platform E2EE messaging, key exchange, and real-time communication.

## Architecture

```
┌─────────────────┐         ┌─────────────────┐
│  Alice (Android)│         │   Bob (Chrome)  │
│   emulator      │◄───────►│    browser      │
└────────┬────────┘         └────────┬────────┘
         │                           │
         │        gRPC               │  gRPC-Web
         │                           │   (Envoy)
         ▼                           ▼
    ┌────────────────────────────────────┐
    │      Backend Services (k8s)        │
    │  - auth-service (port 50051)       │
    │  - messaging-service (port 50052)  │
    │  - Envoy proxy (port 18080)         │
    └────────────────────────────────────┘
```

## Prerequisites

### 1. Backend Services Running

```bash
# Check services are running
kubectl get pods -n apps

# Should show:
# - auth-service (2 pods)
# - messaging-service (3 pods)
# - guardyn-envoy (1 pod)
```

### 2. Port-Forwarding Active

```bash
# Auth service
kubectl port-forward -n apps svc/auth-service 50051:50051 &

# Messaging service
kubectl port-forward -n apps svc/messaging-service 50052:50052 &

# Envoy proxy (for Chrome gRPC-Web)
kubectl port-forward -n apps svc/guardyn-envoy 18080:18080 &
```

### 3. Android Emulator Running

```bash
# List available AVDs
$HOME/Android/Sdk/emulator/emulator -list-avds

# Start an emulator
$HOME/Android/Sdk/emulator/emulator -avd <avd-name> &

# Wait for emulator to boot (30-60 seconds)
flutter devices  # Should show emulator-5554
```

### 4. Chrome Available

```bash
# Verify Chrome is available
flutter devices | grep chrome
```

## Running the Tests

### Automated Test (Recommended)

Run both clients in parallel with orchestration:

```bash
cd client/
./scripts/run-two-client-test.sh
```

This will:

1. Verify all prerequisites
2. Launch Android test (Alice) in background
3. Launch Chrome test (Bob) in background
4. Monitor both test outputs
5. Report results

**Expected output:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Two-Client Integration Test
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Testing Android <-> Chrome messaging

✅ Auth service: 2 pods
✅ Messaging service: 3 pods
✅ Port-forwarding active
✅ Envoy proxy active
✅ Android emulator: emulator-5554
✅ Chrome available

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Running Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [Android] 📱 ANDROID CLIENT (Alice) - Starting...
  [Chrome] 🌐 CHROME CLIENT (Bob) - Starting...
  [Android] 📱 Registering Alice...
  [Chrome] 🌐 Registering Bob...
  [Android] 📱 ✅ Alice registered
  [Chrome] 🌐 ✅ Bob registered
  [Android] 📱 Sending message to Bob...
  [Chrome] 🌐 ✅ Received message from Alice
  [Chrome] 🌐 Sending reply to Alice...
  [Android] 📱 ✅ Received reply from Bob
  [Android] 📱 ✅ ANDROID CLIENT TEST COMPLETED
  [Chrome] 🌐 ✅ CHROME CLIENT TEST COMPLETED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Android test: PASSED
✅ Chrome test: PASSED

✅ ALL TESTS PASSED ✅
```

### Manual Test (Each Client Separately)

If you need to run tests manually:

**Terminal 1 - Android (Alice):**

```bash
cd client/
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_client_messaging_test.dart \
  -d emulator-5554 \
  --dart-define=TEST_PLATFORM=android
```

**Terminal 2 - Chrome (Bob):**

```bash
cd client/
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_client_messaging_test.dart \
  -d chrome \
  --dart-define=TEST_PLATFORM=chrome
```

**Important:** Start both tests within a few seconds of each other for proper synchronization.

## Test Flow

### Alice (Android) Timeline

1. **Launch app** → Login page
2. **Register** as `alice_android`
3. **Navigate** to Messages
4. **Wait** for Bob to register (~10s)
5. **Search** for `bob_chrome`
6. **Send** message: "Hello from Android! 📱"
7. **Wait** for Bob's reply (~30s)
8. **Verify** received: "Hello from Chrome! 🌐"
9. **Complete** ✅

### Bob (Chrome) Timeline

1. **Launch app** → Login page
2. **Register** as `bob_chrome`
3. **Navigate** to Messages
4. **Wait** for Alice's message (~40s)
5. **Open** conversation with Alice
6. **Verify** message: "Hello from Android! 📱"
7. **Send** reply: "Hello from Chrome! 🌐"
8. **Complete** ✅

## Synchronization Points

The tests use time-based coordination:

| Time | Alice (Android)      | Bob (Chrome)         |
| ---- | -------------------- | -------------------- |
| 0s   | Register             | Register             |
| 5s   | Navigate to Messages | Navigate to Messages |
| 10s  | Search for Bob       | Wait for message     |
| 15s  | Send message         | Still waiting        |
| 20s  | Wait for reply       | Receive message      |
| 25s  | Still waiting        | Send reply           |
| 30s  | Receive reply ✅     | Complete ✅          |

## Troubleshooting

### Android Test Fails

**Issue:** Android test times out or can't find widgets

**Solutions:**

```bash
# 1. Check emulator is fully booted
flutter devices

# 2. Check backend connectivity
curl -v http://localhost:50051  # Should connect

# 3. Restart emulator
adb reboot

# 4. View Android test log
tail -f /tmp/android_test.log
```

### Chrome Test Fails

**Issue:** Chrome can't connect to backend

**Solutions:**

```bash
# 1. Verify Envoy proxy is running
kubectl get pods -n apps -l app=guardyn-envoy

# 2. Check Envoy port-forward
lsof -i :18080

# 3. Test Envoy connectivity
curl -v http://localhost:18080

# 4. Restart Envoy port-forward
kubectl port-forward -n apps svc/guardyn-envoy 18080:18080 &

# 5. View Chrome test log
tail -f /tmp/chrome_test.log
```

### Messages Not Received

**Issue:** Alice sends message but Bob doesn't receive it

**Solutions:**

```bash
# 1. Check messaging-service logs
kubectl logs -n apps deployment/messaging-service --tail=50

# 2. Check NATS connectivity
kubectl exec -it -n messaging deployment/nats-0 -- nats sub "messages.>"

# 3. Verify both users registered
kubectl logs -n apps deployment/auth-service | grep -E "alice_android|bob_chrome"

# 4. Check WebSocket connections
kubectl logs -n apps deployment/messaging-service | grep "WebSocket"
```

### Tests Timeout

**Issue:** Tests run longer than expected

**Causes:**

- Slow emulator startup
- Backend services under load
- Network latency
- Crypto operations taking longer

**Solutions:**

- Increase timeout in test code
- Use faster emulator image
- Check backend resource allocation
- Run on better hardware

## Test Logs

All test logs are saved to `/tmp/`:

```bash
# View Android test log
cat /tmp/android_test.log

# View Chrome test log
cat /tmp/chrome_test.log

# Follow logs in real-time
tail -f /tmp/android_test.log /tmp/chrome_test.log
```

## CI/CD Integration

To run these tests in CI/CD:

```yaml
# .github/workflows/integration-tests.yml
name: Two-Client Integration Tests

on: [push, pull_request]

jobs:
  integration-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Setup k3d cluster
        run: |
          just kube-create
          just kube-bootstrap
          just k8s-deploy nats
          just k8s-deploy auth
          just k8s-deploy messaging

      - name: Start port-forwarding
        run: |
          kubectl port-forward -n apps svc/auth-service 50051:50051 &
          kubectl port-forward -n apps svc/messaging-service 50052:50052 &
          kubectl port-forward -n apps svc/guardyn-envoy 18080:18080 &

      - name: Start Android emulator
        uses: reactivecircus/android-emulator-runner@v2

      - name: Run two-client tests
        run: |
          cd client
          ./scripts/run-two-client-test.sh
```

## Performance Metrics

Expected test duration:

- **Setup phase:** 10-15 seconds (registration)
- **Message exchange:** 30-40 seconds
- **Total:** ~60-90 seconds

If tests consistently take longer, investigate:

- Backend performance
- Database query times
- Crypto operation efficiency
- Network latency

## Next Steps

After successful two-client testing:

1. **Add more platforms**: Test Android ↔ Linux, Chrome ↔ iOS
2. **Stress testing**: Multiple clients simultaneously
3. **Group messaging**: 3+ clients in same conversation
4. **Media messages**: Test image/video exchange
5. **Network conditions**: Test with packet loss, latency

## Related Documentation

- [Testing Guide](../docs/TESTING_GUIDE.md) - Complete testing overview
- [Architecture](../docs/ARCHITECTURE.md) - System architecture
- [E2EE Implementation](../docs/E2EE.md) - Encryption details
