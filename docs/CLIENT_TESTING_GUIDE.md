# Flutter Client Testing Guide

**Date**: November 23, 2025  
**Status**: ✅ Compilation Fixed - Ready for Testing  
**Phases**: Authentication + Messaging

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Phase 1: Authentication Testing](#phase-1-authentication-testing)
5. [Phase 2: Two-Device Messaging Testing](#phase-2-two-device-messaging-testing)
6. [Test Commands Reference](#test-commands-reference)
7. [Troubleshooting](#troubleshooting)
8. [Test Results Tracking](#test-results-tracking)

---

## Overview

This guide covers comprehensive testing of the Guardyn Flutter client, including:

- ✅ **Authentication Flow**: Registration, login, token persistence
- ✅ **Two-Device Messaging**: Real-time message exchange, delivery status, offline messages
- ✅ **Error Handling**: Network errors, validation, backend unavailability
- ✅ **Cross-Platform**: Chrome (via Envoy), Linux desktop, Android emulator

### Current Status

✅ **Protocol Buffers generated** - All `.proto` files compiled to Dart  
✅ **Import paths corrected** - Fixed `lib/generated/` vs `lib/features/generated/`  
✅ **MessageBloc registered** - Added to MultiBlocProvider in `app.dart`  
✅ **Error handling fixed** - Proto enum values converted correctly  
✅ **Platform-specific gRPC** - Android uses 10.0.2.2, Chrome/Linux use localhost  
✅ **Compiles on all platforms** - Chrome, Linux, Android tested

---

## Prerequisites

### Backend Services

Verify backend services are running:

```bash
kubectl get pods -n apps
```

**Expected output:**

```
NAME                                  READY   STATUS    RESTARTS   AGE
auth-service-xxx                      2/2     Running   0          10m
messaging-service-xxx                 3/3     Running   0          10m
```

### Port-Forwarding Setup

**You need TWO terminal windows running these commands:**

#### Terminal 1: Auth Service

```bash
kubectl port-forward -n apps svc/auth-service 50051:50051
```

#### Terminal 2: Messaging Service

```bash
kubectl port-forward -n apps svc/messaging-service 50052:50052
```

**Keep these terminals running throughout testing!**

### Chrome-Specific Requirements

**⚠️ Chrome/Web requires Envoy gRPC-Web proxy** (browsers can't use native gRPC):

```bash
cd client
./scripts/start_envoy_proxy.sh
```

Verify Envoy is running:

```bash
docker ps | grep envoy
# Should show: guardyn-envoy-grpc-web
```

**Note**: Linux desktop and Android emulator use native gRPC and don't need Envoy.

---

## Quick Start

### Option 1: Automated Integration Tests ⚡ (Recommended First)

**What it does**: Programmatically tests registration, login, and messaging flow  
**Run time**: 2-3 minutes

```bash
cd client
./scripts/run_integration_tests.sh
```

**Expected output:**

```
✅ Backend services check
✅ Automatic port-forwarding setup
✅ Tests run on first available device
✅ Pass/fail results with summary
```

### Option 2: Automated Two-Device Setup 🚀

**What it does**: Launches two devices and guides you through manual testing  
**Run time**: 5 minutes setup + 15-20 minutes testing

```bash
cd client
./scripts/test_two_devices.sh chrome  # Or 'linux' for desktop
```

**Output shows:**

- Device 1 (Alice): Command to run on Chrome/Linux
- Device 2 (Bob): Command to run on Android emulator

### Option 3: Manual Step-by-Step

See [Test Commands Reference](#test-commands-reference) for complete manual setup.

---

## Phase 1: Authentication Testing

**Duration**: 15-20 minutes  
**Objective**: Verify registration, login, token persistence, error handling

### Test Case 1: Successful Registration ✅

**Steps:**

1. Launch app: `flutter run -d <device>`
2. Tap "Don't have an account? Register"
3. Fill in the form:
   - Username: `testuser1`
   - Password: `password12345`
   - Confirm Password: `password12345`
   - Device Name: `Flutter Test Device`
4. Tap "Register" button

**Expected Results:**

- ✅ Loading indicator appears briefly
- ✅ Navigation to HomePage
- ✅ HomePage displays:
  - Username: "testuser1"
  - User ID: (some UUID)
  - Device ID: (some UUID)
  - "Logout" button visible

**Backend Verification:**

```bash
kubectl logs -n apps deployment/auth-service | grep "testuser1"
```

---

### Test Case 2: Validation Errors ❌

#### Test 2a: Short Username

**Steps:**

1. Enter username: `ab` (only 2 characters)
2. Enter password: `password12345`
3. Try to tap "Register"

**Expected**: Error message: "Username must be at least 3 characters"

#### Test 2b: Short Password

**Steps:**

1. Enter username: `testuser2`
2. Enter password: `short` (only 5 characters)
3. Try to tap "Register"

**Expected**: Error message: "Password must be at least 12 characters"

#### Test 2c: Password Mismatch

**Steps:**

1. Enter username: `testuser2`
2. Enter password: `password12345`
3. Confirm Password: `password67890` (different)
4. Try to tap "Register"

**Expected**: Error message: "Passwords do not match"

#### Test 2d: Empty Device Name

**Steps:**

1. Fill username and password correctly
2. Leave Device Name empty
3. Try to tap "Register"

**Expected**: Error message: "Device name cannot be empty"

---

### Test Case 3: Duplicate Username ❌

**Steps:**

1. Try to register with username `testuser1` again (already exists)
2. Fill in:
   - Username: `testuser1`
   - Password: `password12345`
   - Confirm Password: `password12345`
   - Device Name: `Another Device`
3. Tap "Register"

**Expected Results:**

- ✅ Loading indicator appears
- ✅ Error SnackBar: "Username already exists" or "ALREADY_EXISTS"
- ✅ AuthBloc transitions to AuthError state
- ✅ User stays on RegistrationPage

---

### Test Case 4: Successful Login ✅

**Pre-requisite**: User `testuser1` must be registered (from Test Case 1)

**Steps:**

1. If on HomePage, tap "Logout" → navigates to LoginPage
2. Enter credentials:
   - Username: `testuser1`
   - Password: `password12345`
3. Tap "Login" button

**Expected Results:**

- ✅ Loading indicator appears briefly
- ✅ Navigation to HomePage
- ✅ HomePage displays correct user info (username: "testuser1")

---

### Test Case 5: Invalid Credentials ❌

**Steps:**

1. On LoginPage, enter:
   - Username: `testuser1`
   - Password: `wrongpassword`
2. Tap "Login"

**Expected Results:**

- ✅ Loading indicator appears
- ✅ Error SnackBar: "Invalid username or password" or "INVALID_CREDENTIALS"
- ✅ User stays on LoginPage

**Alternative: Non-existent Username**

1. Enter:
   - Username: `nonexistentuser`
   - Password: `password12345`
2. Tap "Login"

**Expected**: Same error behavior as above

---

### Test Case 6: Network Error Simulation ⚠️

**Steps:**

1. Stop port-forwarding (kill the kubectl process in Terminal 1)
2. Try to login with valid credentials
3. Tap "Login"

**Expected Results:**

- ✅ Error SnackBar: "Connection error" or "Unable to reach server"
- ✅ App doesn't crash
- ✅ AuthBloc transitions to AuthError state

**After Test**: Restart port-forwarding:

```bash
kubectl port-forward -n apps svc/auth-service 50051:50051
```

---

### Test Case 7: Token Persistence ✅

**Pre-requisite**: User `testuser1` is logged in

**Steps:**

1. Verify you're on HomePage (logged in as testuser1)
2. **Close the app completely** (not just minimize):
   - Chrome: Close the browser tab
   - Android: Swipe away the app from recents
   - Linux: Close window
3. **Restart the app** (run `flutter run` again or reopen browser)

**Expected Results:**

- ✅ SplashPage appears briefly
- ✅ AuthBloc checks SecureStorage for tokens
- ✅ Tokens found → AuthCheckStatus succeeds
- ✅ **Navigation directly to HomePage** (skip LoginPage)
- ✅ HomePage displays user info from stored tokens

**Explanation**: JWT tokens are persisted in secure storage and reloaded on app restart.

---

### Test Case 8: Logout Clears Session ✅

**Steps:**

1. From HomePage, tap "Logout" button
2. Verify navigation to LoginPage
3. **Close and restart the app** (same as Test Case 7)

**Expected Results:**

- ✅ SplashPage appears
- ✅ AuthBloc checks SecureStorage → no tokens found
- ✅ **Navigation to LoginPage** (not HomePage)
- ✅ User must login again

**Explanation**: Logout clears tokens from secure storage, so app doesn't auto-login.

---

### Test Case 9: Backend Service Down ⚠️

**Steps:**

1. Stop auth-service pods:

   ```bash
   kubectl scale deployment auth-service -n apps --replicas=0
   ```

2. Try to register or login

**Expected Results:**

- ✅ Error SnackBar with user-friendly message
- ✅ App doesn't crash
- ✅ AuthBloc handles GrpcError gracefully

**After Test**: Restore service:

```bash
kubectl scale deployment auth-service -n apps --replicas=2
```

---

### Test Case 10: Rapid Button Taps (Double-submit Prevention)

**Steps:**

1. Fill in registration form
2. Tap "Register" button **multiple times quickly** (simulate double-tap)

**Expected Results:**

- ✅ Only one registration request sent (AuthBloc in Loading state prevents duplicate events)
- ✅ No duplicate user creation
- ✅ UI shows loading indicator during first request

---

### Phase 1 Test Results Summary

```
Authentication Test Results:
[ ] Test Case 1: Successful Registration ✅
[ ] Test Case 2a: Short Username Validation ❌
[ ] Test Case 2b: Short Password Validation ❌
[ ] Test Case 2c: Password Mismatch Validation ❌
[ ] Test Case 2d: Empty Device Name Validation ❌
[ ] Test Case 3: Duplicate Username Error ❌
[ ] Test Case 4: Successful Login ✅
[ ] Test Case 5: Invalid Credentials Error ❌
[ ] Test Case 6: Network Error Handling ⚠️
[ ] Test Case 7: Token Persistence (Auto-login) ✅
[ ] Test Case 8: Logout Clears Session ✅
[ ] Test Case 9: Backend Service Down ⚠️
[ ] Test Case 10: Rapid Button Taps ⚠️
```

**Phase 1 Complete** when all 13 test cases pass with no app crashes.

---

## Phase 2: Two-Device Messaging Testing

**Duration**: 30-40 minutes  
**Objective**: Test real-time message sending and receiving between two users

### Setup: Launch Two Flutter Instances

You have **three options** for running two simultaneous instances:

#### Option A: Automated Setup Script (Recommended) 🚀

```bash
cd client
./scripts/start_two_device_test.sh
```

This script will:

- ✅ Check backend services
- ✅ Setup port-forwarding automatically
- ✅ Launch Android emulator
- ✅ Guide you through Chrome or Linux desktop setup
- ✅ Display step-by-step instructions

---

#### Option B: Manual - Chrome + Android Emulator

1. **Launch Android emulator** (use full path on Linux):

   ```bash
   # List available AVDs
   $HOME/Android/Sdk/emulator/emulator -list-avds

   # Start emulator (replace with your AVD name)
   $HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 &
   ```

2. **Wait for emulator to boot** (30-60 seconds)

3. **Run Flutter on Chrome (Device 1 - Alice)**:

   ```bash
   cd client
   flutter run -d chrome
   ```

4. **Run Flutter on Android (Device 2 - Bob)**:
   ```bash
   # New terminal window
   cd client
   flutter devices  # Find emulator ID (e.g., emulator-5554)
   flutter run -d emulator-5554
   ```

---

#### Option C: Manual - Linux Desktop + Android Emulator

1. **Launch Android emulator**:

   ```bash
   $HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 &
   ```

2. **Wait for emulator to boot** (30-60 seconds)

3. **Run Flutter on Linux (Device 1 - Alice)**:

   ```bash
   cd client
   flutter run -d linux
   ```

4. **Run Flutter on Android (Device 2 - Bob)**:
   ```bash
   # New terminal window
   cd client
   flutter run -d emulator-5554
   ```

---

### Test Case 11: Two-Device Message Exchange ✅

**Duration**: 5-10 minutes  
**Complexity**: Medium

#### Setup Phase

1. **Device 1 (Alice)**:

   - Register new user: `alice`
   - Password: `password12345`
   - Device name: `Alice Device`
   - ✅ Verify successful registration
   - **Copy Alice's User ID** (displayed on HomePage)

2. **Device 2 (Bob)**:
   - Register new user: `bob`
   - Password: `password12345`
   - Device name: `Bob Device`
   - ✅ Verify successful registration
   - **Copy Bob's User ID** (displayed on HomePage)

#### Messaging Test - Alice sends to Bob

1. **Device 1 (Alice)**:

   - Tap "Open Messages" button on HomePage
   - ✅ Verify ConversationListPage opens
   - Tap "New Chat" or navigate to ChatPage directly
   - Enter **Bob's User ID** as recipient
   - Type message: `"Hello Bob! 👋"`
   - Tap Send button

2. **Device 1 (Alice) - Expected Results**:

   - ✅ Message appears in chat bubble (right-aligned, blue)
   - ✅ Delivery status icon shows "sent" (single checkmark ✓)
   - ✅ No error SnackBar
   - ✅ Input field clears after sending

3. **Device 2 (Bob)**:
   - Wait 1-3 seconds
   - ✅ Message appears automatically (if already on ChatPage)
   - OR: Tap "Open Messages" → see conversation with Alice
   - ✅ Message appears in chat bubble (left-aligned, gray)
   - ✅ Message text: "Hello Bob! 👋"
   - ✅ Sender shown as "alice"

#### Messaging Test - Bob replies to Alice

4. **Device 2 (Bob)**:

   - Open chat with Alice (if not already there)
   - Type message: `"Hi Alice! How are you?"`
   - Tap Send button

5. **Device 2 (Bob) - Expected Results**:

   - ✅ Message appears in chat bubble (right-aligned, blue)
   - ✅ Delivery status shows "sent"

6. **Device 1 (Alice)**:
   - Wait 1-3 seconds
   - ✅ Bob's reply appears automatically
   - ✅ Message text: "Hi Alice! How are you?"
   - ✅ Left-aligned, gray bubble
   - ✅ Auto-scroll to bottom of chat

#### Bidirectional Conversation Test

7. **Both devices**:

   - Send 3-5 more messages back and forth
   - Test different content:
     - Short message: `"OK"`
     - Long message: `"This is a longer message to test how the UI handles text wrapping and multiple lines of content in the message bubble"`
     - Special characters: `"Test 123 !@#$%^&*()"`
     - Emoji: `"🚀 🎉 💬"`

8. **Expected Results**:
   - ✅ All messages delivered in correct order
   - ✅ Auto-scroll works on new messages
   - ✅ Message bubbles format correctly (no overflow)
   - ✅ Timestamps display properly
   - ✅ Sender/recipient alignment correct (right/left)

---

### Test Case 12: Conversation List

**Duration**: 3-5 minutes

1. **Device 1 (Alice)**:

   - Navigate back to ConversationListPage (tap back button)
   - ✅ Verify conversation with Bob appears in list
   - ✅ Last message preview shows latest text
   - ✅ Timestamp shows correct time

2. **Device 2 (Bob)**:

   - Send another message to Alice: `"Testing conversation list"`

3. **Device 1 (Alice)**:
   - Check ConversationListPage
   - ✅ Last message updates to "Testing conversation list"
   - ✅ Unread count badge appears (if implemented)
   - Tap on Bob's conversation
   - ✅ Opens ChatPage with full message history

---

### Test Case 13: Message Delivery Status

**Duration**: 2-3 minutes

1. **Device 1 (Alice)**:

   - Send message to Bob
   - Observe delivery status icon progression:
     - Initially: ⏳ Pending (clock icon)
     - After send: ✓ Sent (single checkmark)
     - After delivery: ✓✓ Delivered (double checkmark - if implemented)
     - After read: ✓✓ Read (blue checkmarks - if implemented)

2. **Expected Status Flow**:
   - ✅ Status icon updates correctly
   - ✅ No status gets stuck in "pending"
   - ✅ Failed messages show error icon (✗)

---

### Test Case 14: Offline Message Delivery

**Duration**: 5 minutes  
**Complexity**: Advanced

#### Steps

1. **Device 2 (Bob)**:

   - **Close the app completely** (swipe away from recent apps)
   - OR: Put device in airplane mode

2. **Device 1 (Alice)**:

   - Send message to Bob: `"Are you there?"`
   - ✅ Message shows as "sent" (not delivered yet)

3. **Wait 5-10 seconds**

4. **Device 2 (Bob)**:

   - **Re-open the app** (or disable airplane mode)
   - App should auto-login

5. **Device 2 (Bob) - Expected Results**:
   - ✅ Alice's message appears automatically
   - ✅ Message text: "Are you there?"
   - ✅ No data loss

---

### Test Case 15: Rapid Message Sending

**Duration**: 2 minutes

1. **Device 1 (Alice)**:

   - Send 5 messages rapidly (one after another):
     - `"Message 1"`
     - `"Message 2"`
     - `"Message 3"`
     - `"Message 4"`
     - `"Message 5"`

2. **Device 1 (Alice) - Expected Results**:

   - ✅ All 5 messages appear in chat
   - ✅ Messages in correct order (1, 2, 3, 4, 5)
   - ✅ No duplicate messages
   - ✅ No dropped messages

3. **Device 2 (Bob) - Expected Results**:
   - ✅ All 5 messages received
   - ✅ Correct order preserved
   - ✅ No UI lag or freezing

---

### Test Case 16: Long Conversation Scrolling

**Duration**: 3 minutes  
**Prerequisites**: Send 20+ messages between Alice and Bob

1. **Device 1 (Alice)**:

   - Scroll to top of conversation (oldest messages)
   - Send new message: `"Testing scroll"`

2. **Expected Results**:

   - ✅ Chat auto-scrolls to bottom (new message visible)
   - ✅ Scroll animation smooth
   - ✅ No jump/flash in UI

3. **Manual Scroll Test**:
   - Scroll up to middle of conversation
   - Hold position for 5 seconds
   - ✅ Chat stays at scroll position (no auto-scroll unless user is near bottom)

---

### Test Case 17: Error Handling - Backend Unavailable

**Duration**: 3 minutes

1. **Stop messaging service**:

   ```bash
   kubectl scale deployment messaging-service -n apps --replicas=0
   ```

2. **Device 1 (Alice)**:

   - Try to send message: `"Will this work?"`

3. **Expected Results**:

   - ✅ Message shows as "failed" (error icon ✗)
   - ✅ Error SnackBar appears with user-friendly message
   - ✅ App doesn't crash
   - ✅ Can retry sending later

4. **Restore service**:

   ```bash
   kubectl scale deployment messaging-service -n apps --replicas=3
   ```

5. **Wait for pods to be Ready** (30-60 seconds):

   ```bash
   kubectl get pods -n apps -w
   ```

6. **Device 1 (Alice)**:
   - Try sending message again
   - ✅ Message sends successfully

---

### Test Case 18: Multiple Conversations

**Duration**: 5-7 minutes  
**Prerequisites**: Need third user

1. **Device 1 or 2**:

   - Logout current user
   - Register third user: `charlie`
   - Password: `password12345`
   - Device name: `Charlie Device`

2. **Device 1 (Alice)**:

   - Start conversation with Charlie
   - Send: `"Hi Charlie!"`

3. **Device 2 (Charlie)**:

   - Reply: `"Hello Alice!"`

4. **Device 1 (Alice)**:

   - Go to ConversationListPage
   - ✅ Verify two conversations visible:
     - Conversation with Bob
     - Conversation with Charlie
   - ✅ Each shows correct last message
   - ✅ Tapping each opens correct chat

5. **Switch between conversations**:
   - Open Bob's chat → send message
   - Back to list
   - Open Charlie's chat → send message
   - ✅ Messages don't mix between conversations
   - ✅ Each conversation maintains separate history

---

### Phase 2 Test Results Summary

```
Messaging Test Results:
[ ] Test Case 11: Two-Device Message Exchange ✅
[ ] Test Case 12: Conversation List ✅
[ ] Test Case 13: Message Delivery Status ✅
[ ] Test Case 14: Offline Message Delivery ✅
[ ] Test Case 15: Rapid Message Sending ✅
[ ] Test Case 16: Long Conversation Scrolling ✅
[ ] Test Case 17: Error Handling - Backend Unavailable ✅
[ ] Test Case 18: Multiple Conversations ✅
```

**Phase 2 Complete** when all 8 test cases pass with real-time messaging working.

---

## Test Commands Reference

### Complete Testing Sequence - Linux + Android

```bash
# Terminal 1: Auth service port-forwarding
kubectl port-forward -n apps svc/auth-service 50051:50051

# Terminal 2: Messaging service port-forwarding
kubectl port-forward -n apps svc/messaging-service 50052:50052

# Terminal 3: Start Android emulator
$HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 -no-snapshot -no-audio -gpu swiftshader_indirect &

# Wait 30-60 seconds for boot, then verify
flutter devices  # Should show: emulator-5554

# Terminal 4: Run Linux client (Device 1 - Alice)
cd /home/anry/projects/guardyn/guardyn/client
flutter run -d linux

# Terminal 5: Run Android client (Device 2 - Bob)
cd /home/anry/projects/guardyn/guardyn/client
flutter run -d emulator-5554
```

---

### Complete Testing Sequence - Chrome + Android

```bash
# Terminal 1: Auth service port-forwarding
kubectl port-forward -n apps svc/auth-service 50051:50051

# Terminal 2: Messaging service port-forwarding
kubectl port-forward -n apps svc/messaging-service 50052:50052

# Terminal 3: Start Envoy gRPC-Web proxy (required for Chrome)
cd /home/anry/projects/guardyn/guardyn/client
./scripts/start_envoy_proxy.sh

# Verify Envoy is running
docker ps | grep envoy  # Should show: guardyn-envoy-grpc-web

# Terminal 4: Start Android emulator
$HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 -no-snapshot -no-audio -gpu swiftshader_indirect &

# Wait 30-60 seconds, then verify
flutter devices

# Terminal 5: Run Chrome client (Device 1 - Alice)
cd /home/anry/projects/guardyn/guardyn/client
flutter run -d chrome

# Terminal 6: Run Android client (Device 2 - Bob)
cd /home/anry/projects/guardyn/guardyn/client
flutter run -d emulator-5554
```

---

### Cleanup After Testing

```bash
# Stop Flutter applications
# In each Flutter terminal, press: q

# Stop port-forwarding
# In port-forward terminals, press: Ctrl+C

# Stop Android emulator
adb emu kill

# Stop Envoy proxy (if using Chrome)
docker stop guardyn-envoy-grpc-web
docker rm guardyn-envoy-grpc-web
```

---

## Troubleshooting

### "Connection refused" (Chrome only)

Chrome needs Envoy gRPC-Web proxy:

```bash
# Start Envoy proxy
cd client
./scripts/start_envoy_proxy.sh

# Verify it's running
docker ps | grep envoy
```

---

### "Connection refused" (Linux/Android)

```bash
# Check backend services
kubectl get pods -n apps

# Restart port-forwarding
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &
```

---

### "No devices found"

```bash
# List emulators
$HOME/Android/Sdk/emulator/emulator -list-avds

# Start emulator
$HOME/Android/Sdk/emulator/emulator -avd <avd-name> &

# Verify device is detected
flutter devices
```

---

### Compilation errors

```bash
# Regenerate proto files
cd client
./scripts/generate_proto.sh

# Clean build
flutter clean
flutter pub get
flutter run
```

---

### "MissingPluginException" (Linux only)

```bash
sudo apt-get install libsecret-1-dev
flutter clean
flutter pub get
flutter run
```

---

### Messages not appearing on second device

**Solution:**

1. Verify both devices connected to same backend:

   ```bash
   # Check port-forwards are active
   lsof -i :50051  # Auth service
   lsof -i :50052  # Messaging service
   ```

2. Check backend logs:

   ```bash
   kubectl logs -n apps deployment/messaging-service --tail=50
   ```

3. Verify user IDs are correct (copy-paste from HomePage)

---

### "User not found" error when sending message

**Solution:**

1. Verify recipient user ID is exact (no extra spaces)
2. Check both users are registered:
   ```bash
   kubectl logs -n apps deployment/auth-service | grep "registered"
   ```

---

### Message stuck in "pending" status

**Solution:**

1. Check messaging service is running:

   ```bash
   kubectl get pods -n apps | grep messaging
   ```

2. Check gRPC connection in Flutter console for:

   - "gRPC Error: Connection refused"

3. Restart port-forward if needed

---

### Duplicate messages appearing

**Potential causes:**

- StreamSubscription not cancelled properly
- Multiple BLoC instances created

**Solution:**

- Restart both Flutter apps
- Check Flutter console for warnings

---

## Test Results Tracking

### Overall Success Criteria

**Testing Complete** when:

- ✅ All 13 authentication test cases pass
- ✅ All 8 messaging test cases pass
- ✅ No app crashes during any scenario
- ✅ Error messages are user-friendly
- ✅ Messages send/receive in real-time
- ✅ Offline messages delivered correctly
- ✅ Auto-login works correctly
- ✅ UI handles long conversations smoothly

---

### Recording Test Results

**Please capture:**

1. **Screenshots:**

   - Both devices showing bidirectional conversation
   - ConversationListPage with multiple conversations
   - Message delivery status icons
   - Error handling examples

2. **Screen Recording (Optional):**

   - 30-second video showing:
     - Alice sending message
     - Bob receiving message (real-time)
     - Reply from Bob to Alice

3. **Console Logs:**
   - Flutter console output from both devices
   - Any errors or warnings
   - Backend logs if errors occur

---

### Reporting Issues

If you encounter issues, please provide:

1. **Test case number** (e.g., "Test Case 11: Two-Device Message Exchange")
2. **Steps to reproduce**
3. **Expected behavior**
4. **Actual behavior**
5. **Flutter console logs** (check terminal where `flutter run` is running)
6. **Backend logs** (check `kubectl logs -n apps deployment/<service-name>`)
7. **Screenshots/recordings** if applicable

---

## Verification Checklist

**Before testing:**

- [ ] Backend pods are Running (`kubectl get pods -n apps`)
- [ ] Port-forwarding active on 50051 and 50052 (`lsof -i :50051`)
- [ ] Envoy running if using Chrome (`docker ps | grep envoy`)
- [ ] Android emulator booted (`flutter devices`)
- [ ] Proto files generated (`./scripts/generate_proto.sh`)

**During testing:**

- [ ] Both clients successfully register
- [ ] User IDs displayed on HomePage
- [ ] Messages send without errors
- [ ] Messages received in real-time
- [ ] Delivery status updates
- [ ] Bidirectional communication works
- [ ] No crashes or data loss
- [ ] Error handling works gracefully

---

## Additional Resources

- **Integration Tests**: `client/integration_test/README.md`
- **Client README**: `client/README.md`
- **Backend API Documentation**: `docs/GRPC_API.md`
- **Architecture Overview**: `docs/mvp_discovery.md`

---

**Ready to test! Good luck! 🚀**
