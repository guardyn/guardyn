# Integration Tests - Messaging Flow

**Created**: November 23, 2025  
**Purpose**: Automated testing of two-device messaging functionality

---

## 📋 Overview

This directory contains Flutter integration tests that simulate real user interactions with the Guardyn app, specifically testing the messaging flow between two users.

### What Gets Tested

- ✅ User registration (Alice and Bob)
- ✅ User login/logout
- ✅ Navigation to Messages screen
- ✅ Backend service connectivity (auth + messaging)
- ⏳ Message sending (requires UI implementation for "New Chat")

---

## 🚀 Prerequisites

### 1. Backend Services Running

Ensure your k3d cluster is running with services deployed:

```bash
# Check cluster status
kubectl get pods -n apps

# Expected output:
# auth-service-xxx         2/2   Running
# messaging-service-xxx    3/3   Running
```

### 2. Port-Forwarding Active

**Terminal 1:**
```bash
kubectl port-forward -n apps svc/auth-service 50051:50051
```

**Terminal 2:**
```bash
kubectl port-forward -n apps svc/messaging-service 50052:50052
```

Keep these terminals running during test execution.

---

## 🧪 Running Integration Tests

### Run All Tests

```bash
cd client
flutter test integration_test/messaging_two_device_test.dart
```

### Run on Specific Device

```bash
# List devices
flutter devices

# Run on Android emulator
flutter test integration_test/messaging_two_device_test.dart -d emulator-5554

# For desktop testing, use Tauri client:
cd ../client-desktop && npm run tauri dev
```

> **Note**: Web/Chrome testing is disabled for security reasons.

### Run with Verbose Output

```bash
flutter test integration_test/messaging_two_device_test.dart --verbose
```

---

## 🔄 Two-Client Testing (Android + Linux)

### Overview

The `android_linux_messaging_test.dart` tests **simultaneous communication** between:
- **Alice**: Android device/emulator
- **Bob**: Linux desktop

Both clients run the same test file with different roles, synchronized via file-based signaling.

### Quick Start (Recommended)

```bash
# Run both clients simultaneously
./scripts/run-android-linux-messaging.sh
```

### Manual Execution

**Terminal 1 (Android - Alice):**
```bash
flutter test integration_test/android_linux_messaging_test.dart \
  -d <android-device-id> \
  --dart-define=TEST_ROLE=alice \
  --dart-define=TEST_RUN_ID=12345
```

**Terminal 2 (Desktop - Bob) - Tauri:**
```bash
cd ../client-desktop && npm run tauri dev
# Manual testing with Tauri desktop client

> ⚠️ **Important**: Use the same `TEST_RUN_ID` for both clients to enable synchronization.

### Synchronization Mechanism

Tests coordinate via files in `/tmp/guardyn_test_sync/<TEST_RUN_ID>/`:

```
Timeline:
────────────────────────────────────────────────────────────────────────────
Alice (Android)                    Bob (Linux)
────────────────────────────────────────────────────────────────────────────
1. Register                        1. Wait for alice_registered.done
2. Signal: alice_registered.done   2. (receives signal)
3. Wait for bob_registered.done    3. Register
4. (receives signal)               4. Signal: bob_registered.done
5. Start conversation              5. Wait for alice_message_sent.done
6. Send message                    
7. Signal: alice_message_sent      6. (receives signal)
8. Wait for bob_message_sent       7. Open conversation, see message
9. (receives signal)               8. Send reply
10. Verify reply received          9. Signal: bob_message_sent.done
11. Signal: alice_complete.done    10. Wait for alice_complete.done
                                   11. Cleanup sync files
────────────────────────────────────────────────────────────────────────────
```

### Script Options

```bash
# Test both clients (default)
./scripts/run-android-linux-messaging.sh

# Test only Android client
./scripts/run-android-linux-messaging.sh --android-only

# Test only Linux client
./scripts/run-android-linux-messaging.sh --linux-only

# Clean up old sync files
./scripts/run-android-linux-messaging.sh --cleanup

# Verbose mode (show sync events)
./scripts/run-android-linux-messaging.sh --verbose
```

### Prerequisites for Two-Client Testing

1. **Backend running** (Docker Compose or Kubernetes)
2. **Android device connected** with USB debugging enabled
3. **FFI libraries built** for both platforms:
   ```bash
   just ffi-install-linux
   just ffi-build-android
   ```

### Troubleshooting

**Android device not found:**
```bash
flutter devices  # Verify device listed
adb devices      # Check ADB connection
```

**Sync timeout:**
- Increase timeout in test file (`TestSyncHelper.waitFor()`)
- Check if other client is running
- Clean sync files: `rm -rf /tmp/guardyn_test_sync`

**Library not found:**
```bash
# Linux
ls -la linux/libguardyn_crypto_ffi.so

# Android (check jniLibs)
ls -la android/app/src/main/jniLibs/arm64-v8a/
```

---

## 📊 Test Structure

### Test Group 1: Two-Device Messaging Flow

**Test Case**: `Alice and Bob can exchange messages`

**Flow**:
1. Launch app
2. Register Alice
3. Navigate to Messages screen
4. Logout Alice
5. Register Bob
6. Logout Bob, login as Alice
7. Attempt to send message to Bob

**Expected Results**:
- ✅ Both users register successfully
- ✅ Navigation works correctly
- ✅ Login/logout functions properly
- ⏳ Message sending (pending "New Chat" UI)

---

**Test Case**: `User can send message to self (loopback test)`

**Flow**:
1. Register single user
2. Navigate to Messages screen
3. Send message to own user ID

**Purpose**: Verify messaging infrastructure without needing two devices

---

### Test Group 2: Messaging Service Health Check

**Test Case**: `Can connect to backend services`

**Flow**:
1. Attempt user registration (tests auth-service)
2. Navigate to Messages screen (tests messaging-service)
3. Report connectivity status

**Expected Results**:
- ✅ Auth service responds
- ✅ Messaging service accessible
- ❌ Clear error messages if services unavailable

---

## 📸 Test Output Example

```
🔵 DEVICE 1: Alice registration starting...
✅ Alice registered successfully
📝 Alice User ID: 123e4567-e89b-12d3-a456-426614174000
✅ Alice navigated to Messages screen

🟢 DEVICE 2: Bob registration starting...
✅ Bob registered successfully
📝 Bob User ID: 987fcdeb-51a2-43d1-9012-987654321098

💬 Testing messaging: Alice → Bob
✅ Alice logged in
⚠️  Note: Full navigation to ChatPage requires UI for "New Chat" flow
   This would be implemented in the actual ConversationListPage

✅ Integration test completed successfully
📊 Test Summary:
   - Alice registration: ✅
   - Bob registration: ✅
   - Navigation to Messages: ✅
   - Message sending: ⏳ (requires "New Chat" UI implementation)
```

---

## 🐛 Troubleshooting

### Test Fails with "Connection refused"

**Problem**: Backend services not reachable

**Solution**:
1. Verify k3d cluster is running: `kubectl get nodes`
2. Check pods are Ready: `kubectl get pods -n apps`
3. Restart port-forwarding (see Prerequisites)
4. Test connectivity: `grpcurl -plaintext localhost:50051 list`

---

### Test Fails with "Widget not found"

**Problem**: UI element not rendered or text doesn't match

**Solution**:
1. Check if UI has changed (button text, labels)
2. Update finder strings in test code
3. Use `tester.printToConsole()` to debug widget tree

---

### Test Times Out

**Problem**: App not responding or backend slow

**Solution**:
1. Increase timeout: `await tester.pumpAndSettle(const Duration(seconds: 5));`
2. Check backend logs for errors: `kubectl logs -n apps deployment/auth-service`
3. Verify backend database (TiKV/ScyllaDB) is healthy

---

## 🔮 Future Enhancements

### Planned Improvements

1. **Full Message Sending Test**
   - Implement "New Chat" UI in ConversationListPage
   - Add recipient selection
   - Test complete send/receive flow

2. **Message Reception Test**
   - Verify real-time message updates
   - Test delivery status changes
   - Validate message ordering

3. **Multi-Message Test**
   - Send multiple messages rapidly
   - Test message persistence
   - Verify conversation history

4. **Offline Test**
   - Simulate network disconnection
   - Test offline message queuing
   - Verify delivery after reconnection

5. **Error Handling Test**
   - Backend service down scenarios
   - Network timeout handling
   - Invalid recipient ID errors

---

## 📚 Writing New Tests

### Template for New Test Case

```dart
testWidgets('Test description', (WidgetTester tester) async {
  // Setup
  print('\n🧪 Test: Your test name');
  
  app.main();
  await tester.pumpAndSettle();

  // Actions
  await tester.tap(find.text('Button'));
  await tester.pumpAndSettle();

  // Assertions
  expect(find.text('Expected Text'), findsOneWidget);
  
  print('✅ Test completed');
});
```

### Best Practices

1. **Use Descriptive Print Statements**: Help debug when tests fail
2. **Add Sufficient Delays**: `pumpAndSettle()` with timeout for async operations
3. **Check Multiple Conditions**: Verify both positive and negative cases
4. **Clean Up After Tests**: Logout users, clear data
5. **Use Unique Usernames**: Append timestamp to avoid conflicts

---

## 🎯 Success Criteria

**Integration tests are successful when:**

- ✅ All tests pass without failures
- ✅ Backend connectivity verified
- ✅ User flows work end-to-end
- ✅ No app crashes during tests
- ✅ Test output is clear and informative

---

## 🚀 CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  integration-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Setup k3d cluster
        run: |
          curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
          k3d cluster create test-cluster
      - name: Deploy services
        run: |
          kubectl apply -f infra/k8s/base/
          kubectl wait --for=condition=ready pod -n apps --all --timeout=300s
      - name: Run integration tests
        run: |
          kubectl port-forward -n apps svc/auth-service 50051:50051 &
          kubectl port-forward -n apps svc/messaging-service 50052:50052 &
          cd client
          flutter test integration_test/
```

---

**For questions or issues, see `client/MANUAL_TESTING_GUIDE.md`** 📖
