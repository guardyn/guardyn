# Flutter Client Manual Testing Guide

**Date**: November 23, 2025  
**Status**: Ready for messaging testing - Authentication + Messaging UI complete

---

## 📋 Testing Phases

- ✅ **Phase 1: Authentication Flow** (Completed November 14, 2025)
- 🔄 **Phase 2: Messaging Between Two Users** (Current - November 23, 2025)

---

## ✅ Prerequisites

- k3d cluster running with auth-service and messaging-service deployed
- Backend services verified: `kubectl get pods -n apps`
  - auth-service: 2/2 replicas Running
  - messaging-service: 3/3 replicas Running

---

## 🚀 Step 1: Setup Port-Forwarding

**You need to run these commands in separate terminal windows:**

### Terminal 1: Auth Service Port-Forward

```bash
kubectl port-forward -n apps svc/auth-service 50051:50051
```

**Expected output:**

```
Forwarding from 127.0.0.1:50051 -> 50051
Forwarding from [::1]:50051 -> 50051
```

Keep this terminal running.

### Terminal 2: Messaging Service Port-Forward

```bash
kubectl port-forward -n apps svc/messaging-service 50052:50052
```

**Expected output:**

```
Forwarding from 127.0.0.1:50052 -> 50052
Forwarding from [::1]:50052 -> 50052
```

Keep this terminal running.

---

## 📱 Step 2: Run Flutter App

### Terminal 3: Start Flutter App

```bash
cd client
flutter devices  # List available devices
flutter run      # Run on default device
# OR
flutter run -d chrome  # Run in Chrome browser
```

**Expected**: App launches and shows SplashPage, then navigates to LoginPage.

---

## 🧪 Step 3: Test Registration Flow

### Test Case 1: Successful Registration ✅

**Steps:**

1. Tap "Don't have an account? Register"
2. Fill in the form:
   - Username: `testuser1`
   - Password: `password12345`
   - Confirm Password: `password12345`
   - Device Name: `Flutter Test Device`
3. Tap "Register" button

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
# Check that user was created in backend
kubectl logs -n apps deployment/auth-service | grep "testuser1"
```

---

### Test Case 2: Validation Errors ❌

**Test 2a: Short Username**

1. On RegistrationPage, enter:
   - Username: `ab` (only 2 characters)
   - Password: `password12345`
   - Device Name: `Test`
2. Try to tap "Register"

**Expected**: Error message appears: "Username must be at least 3 characters"

---

**Test 2b: Short Password**

1. Enter:
   - Username: `testuser2`
   - Password: `short` (only 5 characters)
   - Device Name: `Test`
2. Try to tap "Register"

**Expected**: Error message appears: "Password must be at least 12 characters"

---

**Test 2c: Password Mismatch**

1. Enter:
   - Username: `testuser2`
   - Password: `password12345`
   - Confirm Password: `password67890` (different)
   - Device Name: `Test`
2. Try to tap "Register"

**Expected**: Error message appears: "Passwords do not match"

---

**Test 2d: Empty Device Name**

1. Enter:
   - Username: `testuser2`
   - Password: `password12345`
   - Confirm Password: `password12345`
   - Device Name: `` (empty)
2. Try to tap "Register"

**Expected**: Error message appears: "Device name cannot be empty"

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
- ✅ Error SnackBar appears with message (e.g., "Username already exists" or "ALREADY_EXISTS")
- ✅ AuthBloc transitions to AuthError state
- ✅ User stays on RegistrationPage

---

## 🔐 Step 4: Test Login Flow

### Test Case 4: Successful Login ✅

**Pre-requisite**: User `testuser1` must be registered (from Test Case 1).

**Steps:**

1. If on HomePage, tap "Logout" button → navigates to LoginPage
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

---

**Alternative: Non-existent Username**

1. Enter:
   - Username: `nonexistentuser`
   - Password: `password12345`
2. Tap "Login"

**Expected**: Same error behavior as above.

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

**After Test:**

- Restart port-forwarding: `kubectl port-forward -n apps svc/auth-service 50051:50051`

---

## 🔄 Step 5: Test Auto-Login (Token Persistence)

### Test Case 7: Token Persistence ✅

**Pre-requisite**: User `testuser1` is logged in.

**Steps:**

1. Verify you're on HomePage (logged in as testuser1)
2. **Close the app completely** (not just minimize):
   - Chrome: Close the browser tab
   - Android: Swipe away the app from recents
   - iOS: Swipe up and close
3. **Restart the app** (run `flutter run` again or reopen browser)

**Expected Results:**

- ✅ SplashPage appears briefly
- ✅ AuthBloc checks SecureStorage for tokens
- ✅ Tokens found → AuthCheckStatus succeeds
- ✅ **Navigation directly to HomePage** (skip LoginPage)
- ✅ HomePage displays user info from stored tokens

**Explanation**: This verifies that JWT tokens are persisted in secure storage and reloaded on app restart.

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

## 🐛 Step 6: Error Handling Edge Cases

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

**After Test:**

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

## 📊 Test Results Summary

After completing all test cases, fill out this checklist:

```
Test Results:
[x] Test Case 1: Successful Registration ✅
[x] Test Case 2a: Short Username Validation ❌
[x] Test Case 2b: Short Password Validation ❌
[x] Test Case 2c: Password Mismatch Validation ❌
[x] Test Case 2d: Empty Device Name Validation ❌
[x] Test Case 3: Duplicate Username Error ❌
[x] Test Case 4: Successful Login ✅
[x] Test Case 5: Invalid Credentials Error ❌
[x] Test Case 6: Network Error Handling ⚠️
[x] Test Case 7: Token Persistence (Auto-login) ✅
[x] Test Case 8: Logout Clears Session ✅
[x] Test Case 9: Backend Service Down ⚠️
[x] Test Case 10: Rapid Button Taps ⚠️
```

---

## 🎯 Success Criteria

**Phase 1 Testing Complete** when:

- ✅ All 13 test cases pass
- ✅ No app crashes during any scenario
- ✅ Error messages are user-friendly
- ✅ Auto-login works correctly
- ✅ Logout clears session properly

---

## 📝 Notes for Reporting Issues

If you encounter issues, please provide:

1. **Test case number** (e.g., "Test Case 5: Invalid Credentials")
2. **Steps to reproduce**
3. **Expected behavior**
4. **Actual behavior**
5. **Flutter console logs** (check terminal where `flutter run` is running)
6. **Backend logs** (check `kubectl logs -n apps deployment/auth-service`)

---

## 🔧 Troubleshooting

### Issue: "Connection refused" error

**Solution:**

1. Verify backend pods are running: `kubectl get pods -n apps`
2. Verify port-forwarding is active: Check Terminal 1 and 2
3. Restart port-forwarding if needed

---

### Issue: "MissingPluginException" (Linux only)

**Solution:**

```bash
sudo apt-get install libsecret-1-dev
flutter clean
flutter pub get
flutter run
```

---

### Issue: App doesn't launch

**Solution:**

```bash
flutter doctor  # Check for issues
flutter clean
flutter pub get
flutter run
```

---

## ✅ After Manual Testing Complete

Once all manual tests pass, report back with:

1. Test results checklist (all checkboxes)
2. Any issues encountered
3. Screenshots/recordings (optional but helpful)

Then we'll proceed to Phase 2: Messaging UI implementation.

---

## 🔥 PHASE 2: TWO-DEVICE MESSAGING TESTING

**Date**: November 23, 2025  
**Objective**: Test real-time message sending and receiving between two users

---

### 🎯 Test Overview

This phase tests the complete messaging flow:
- ✅ Sending messages between two devices
- ✅ Real-time message reception
- ✅ Delivery status updates
- ✅ Conversation list
- ✅ Message persistence
- ✅ Offline message delivery

---

### 📱 Step 1: Launch Two Flutter Instances

You have **three options** for running two simultaneous instances:

#### Option A: Automated Setup Script (Recommended) 🚀

**Easiest way - Use the automated script:**

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

> **Note**: On Linux, use full path to Android SDK emulator.

1. **Launch Android emulator:**
   ```bash
   # List available AVDs
   $HOME/Android/Sdk/emulator/emulator -list-avds
   
   # Start emulator (replace with your AVD name)
   $HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 &
   ```

2. **Wait for emulator to boot** (30-60 seconds)

3. **Run Flutter on Chrome (Device 1 - Alice):**
   ```bash
   cd client
   flutter run -d chrome
   ```

4. **Run Flutter on Android (Device 2 - Bob):**
   ```bash
   # New terminal window
   cd client
   flutter devices  # Find emulator ID (e.g., emulator-5554)
   flutter run -d emulator-5554
   ```

---

#### Option C: Manual - Two Android Emulators

> **Note**: You need to create two AVDs in Android Studio first.

1. **Launch first emulator:**
   ```bash
   # List available AVDs
   $HOME/Android/Sdk/emulator/emulator -list-avds
   
   # Start first emulator
   $HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 &
   ```

2. **Create second AVD** (if not exists):
   - Open Android Studio → Device Manager → Create Virtual Device

3. **Launch second emulator:**
   ```bash
   # Start second emulator (replace with your second AVD name)
   $HOME/Android/Sdk/emulator/emulator -avd <second_avd_name> &
   ```

3. **Verify both devices are detected:**
   ```bash
   cd client
   flutter devices
   ```
   
   **Expected output:**
   ```
   4 connected devices:
   
   sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
   sdk gphone64 arm64 (mobile) • emulator-5556 • android-arm64  • Android 14 (API 34)
   ...
   ```

4. **Run Flutter on first device:**
   ```bash
   # Terminal 3 (keep port-forwards running in Terminal 1 & 2)
   cd client
   flutter run -d emulator-5554
   ```

5. **Run Flutter on second device:**
   ```bash
   # Terminal 4 (new terminal window)
   cd client
   flutter run -d emulator-5556
   ```

#### Option B: Chrome + Android Emulator

1. **Launch Android emulator:**
   ```bash
   emulator -avd Pixel_6_API_33 &
   ```

2. **Run on Chrome (Device 1):**
   ```bash
   cd client
   flutter run -d chrome
   ```

3. **Run on Android (Device 2):**
   ```bash
   # New terminal
   cd client
   flutter run -d emulator-5554
   ```

---

### 🧪 Test Case 11: Two-Device Message Exchange

**Duration**: 5-10 minutes  
**Complexity**: Medium

#### Setup Phase

1. **Device 1 (Alice):**
   - Register new user: `alice`
   - Password: `password123`
   - Device name: `Alice iPhone`
   - ✅ Verify successful registration
   - **Write down Alice's User ID** (displayed on HomePage)

2. **Device 2 (Bob):**
   - Register new user: `bob`
   - Password: `password123`
   - Device name: `Bob Android`
   - ✅ Verify successful registration
   - **Write down Bob's User ID** (displayed on HomePage)

#### Messaging Test - Alice sends to Bob

1. **Device 1 (Alice):**
   - Tap "Open Messages" button on HomePage
   - ✅ Verify ConversationListPage opens
   - Tap "New Chat" or navigate to ChatPage directly
   - Enter **Bob's User ID** as recipient
   - Type message: `"Hello Bob! 👋"`
   - Tap Send button

2. **Device 1 (Alice) - Expected Results:**
   - ✅ Message appears in chat bubble (right-aligned, blue)
   - ✅ Delivery status icon shows "sent" (single checkmark ✓)
   - ✅ No error SnackBar
   - ✅ Input field clears after sending

3. **Device 2 (Bob):**
   - Wait 1-3 seconds
   - ✅ Message appears automatically (if already on ChatPage)
   - OR: Tap "Open Messages" → see conversation with Alice
   - ✅ Message appears in chat bubble (left-aligned, gray)
   - ✅ Message text: "Hello Bob! 👋"
   - ✅ Sender shown as "alice"

#### Messaging Test - Bob replies to Alice

4. **Device 2 (Bob):**
   - Open chat with Alice (if not already there)
   - Type message: `"Hi Alice! How are you?"`
   - Tap Send button

5. **Device 2 (Bob) - Expected Results:**
   - ✅ Message appears in chat bubble (right-aligned, blue)
   - ✅ Delivery status shows "sent"

6. **Device 1 (Alice):**
   - Wait 1-3 seconds
   - ✅ Bob's reply appears automatically
   - ✅ Message text: "Hi Alice! How are you?"
   - ✅ Left-aligned, gray bubble
   - ✅ Auto-scroll to bottom of chat

#### Bidirectional Conversation Test

7. **Both devices:**
   - Send 3-5 more messages back and forth
   - Test different content:
     - Short message: `"OK"`
     - Long message: `"This is a longer message to test how the UI handles text wrapping and multiple lines of content in the message bubble"`
     - Special characters: `"Test 123 !@#$%^&*()"`
     - Emoji: `"🚀 🎉 💬"`

8. **Expected Results:**
   - ✅ All messages delivered in correct order
   - ✅ Auto-scroll works on new messages
   - ✅ Message bubbles format correctly (no overflow)
   - ✅ Timestamps display properly
   - ✅ Sender/recipient alignment correct (right/left)

---

### 🧪 Test Case 12: Conversation List

**Duration**: 3-5 minutes

1. **Device 1 (Alice):**
   - Navigate back to ConversationListPage (tap back button)
   - ✅ Verify conversation with Bob appears in list
   - ✅ Last message preview shows latest text
   - ✅ Timestamp shows correct time

2. **Device 2 (Bob):**
   - Send another message to Alice: `"Testing conversation list"`

3. **Device 1 (Alice):**
   - Check ConversationListPage
   - ✅ Last message updates to "Testing conversation list"
   - ✅ Unread count badge appears (if implemented)
   - Tap on Bob's conversation
   - ✅ Opens ChatPage with full message history

---

### 🧪 Test Case 13: Message Delivery Status

**Duration**: 2-3 minutes

1. **Device 1 (Alice):**
   - Send message to Bob
   - Observe delivery status icon progression:
     - Initially: ⏳ Pending (clock icon)
     - After send: ✓ Sent (single checkmark)
     - After delivery: ✓✓ Delivered (double checkmark - if implemented)
     - After read: ✓✓ Read (blue checkmarks - if implemented)

2. **Expected Status Flow:**
   - ✅ Status icon updates correctly
   - ✅ No status gets stuck in "pending"
   - ✅ Failed messages show error icon (✗)

---

### 🧪 Test Case 14: Offline Message Delivery

**Duration**: 5 minutes  
**Complexity**: Advanced

#### Setup

1. **Device 2 (Bob):**
   - **Close the app completely** (swipe away from recent apps)
   - OR: Put device in airplane mode

2. **Device 1 (Alice):**
   - Send message to Bob: `"Are you there?"`
   - ✅ Message shows as "sent" (not delivered yet)

3. **Wait 5-10 seconds**

4. **Device 2 (Bob):**
   - **Re-open the app** (or disable airplane mode)
   - App should auto-login

5. **Device 2 (Bob) - Expected Results:**
   - ✅ Alice's message appears automatically
   - ✅ Message text: "Are you there?"
   - ✅ No data loss

---

### 🧪 Test Case 15: Rapid Message Sending

**Duration**: 2 minutes

1. **Device 1 (Alice):**
   - Send 5 messages rapidly (one after another):
     - `"Message 1"`
     - `"Message 2"`
     - `"Message 3"`
     - `"Message 4"`
     - `"Message 5"`

2. **Device 1 (Alice) - Expected Results:**
   - ✅ All 5 messages appear in chat
   - ✅ Messages in correct order (1, 2, 3, 4, 5)
   - ✅ No duplicate messages
   - ✅ No dropped messages

3. **Device 2 (Bob) - Expected Results:**
   - ✅ All 5 messages received
   - ✅ Correct order preserved
   - ✅ No UI lag or freezing

---

### 🧪 Test Case 16: Long Conversation Scrolling

**Duration**: 3 minutes

**Prerequisites**: Send 20+ messages between Alice and Bob

1. **Device 1 (Alice):**
   - Scroll to top of conversation (oldest messages)
   - Send new message: `"Testing scroll"`

2. **Expected Results:**
   - ✅ Chat auto-scrolls to bottom (new message visible)
   - ✅ Scroll animation smooth
   - ✅ No jump/flash in UI

3. **Manual Scroll Test:**
   - Scroll up to middle of conversation
   - Hold position for 5 seconds
   - ✅ Chat stays at scroll position (no auto-scroll unless user is near bottom)

---

### 🧪 Test Case 17: Error Handling - Backend Unavailable

**Duration**: 3 minutes

1. **Stop messaging service:**
   ```bash
   kubectl scale deployment messaging-service -n apps --replicas=0
   ```

2. **Device 1 (Alice):**
   - Try to send message: `"Will this work?"`

3. **Expected Results:**
   - ✅ Message shows as "failed" (error icon ✗)
   - ✅ Error SnackBar appears with user-friendly message
   - ✅ App doesn't crash
   - ✅ Can retry sending later

4. **Restore service:**
   ```bash
   kubectl scale deployment messaging-service -n apps --replicas=3
   ```

5. **Wait for pods to be Ready (30-60 seconds):**
   ```bash
   kubectl get pods -n apps -w
   ```

6. **Device 1 (Alice):**
   - Try sending message again
   - ✅ Message sends successfully

---

### 🧪 Test Case 18: Multiple Conversations

**Duration**: 5-7 minutes

**Prerequisites**: Need third user

1. **Device 1 or 2:**
   - Logout current user
   - Register third user: `charlie`
   - Password: `password123`

2. **Device 1 (Alice):**
   - Start conversation with Charlie
   - Send: `"Hi Charlie!"`

3. **Device 2 (Charlie):**
   - Reply: `"Hello Alice!"`

4. **Device 1 (Alice):**
   - Go to ConversationListPage
   - ✅ Verify two conversations visible:
     - Conversation with Bob
     - Conversation with Charlie
   - ✅ Each shows correct last message
   - ✅ Tapping each opens correct chat

5. **Switch between conversations:**
   - Open Bob's chat → send message
   - Back to list
   - Open Charlie's chat → send message
   - ✅ Messages don't mix between conversations
   - ✅ Each conversation maintains separate history

---

### 📊 Phase 2 Test Results Summary

After completing all messaging tests, fill out this checklist:

```
Messaging Test Results:
[ ] Test Case 11: Two-Device Message Exchange ✅/❌
[ ] Test Case 12: Conversation List ✅/❌
[ ] Test Case 13: Message Delivery Status ✅/❌
[ ] Test Case 14: Offline Message Delivery ✅/❌
[ ] Test Case 15: Rapid Message Sending ✅/❌
[ ] Test Case 16: Long Conversation Scrolling ✅/❌
[ ] Test Case 17: Error Handling - Backend Unavailable ✅/❌
[ ] Test Case 18: Multiple Conversations ✅/❌
```

---

### 🎯 Phase 2 Success Criteria

**Messaging Testing Complete** when:

- ✅ Messages send and receive between two devices in real-time
- ✅ Delivery status updates correctly
- ✅ Conversation list shows all conversations
- ✅ Offline messages delivered when user comes online
- ✅ No messages lost or duplicated
- ✅ No app crashes during any messaging scenario
- ✅ UI handles long conversations smoothly
- ✅ Error handling works gracefully

---

### 📸 Recording Test Results

**Please capture:**

1. **Screenshots:**
   - Both devices showing bidirectional conversation
   - ConversationListPage with multiple conversations
   - Message delivery status icons

2. **Screen Recording (Optional):**
   - 30-second video showing:
     - Alice sending message
     - Bob receiving message (real-time)
     - Reply from Bob to Alice

3. **Console Logs:**
   - Flutter console output from both devices
   - Any errors or warnings

---

### 🐛 Troubleshooting Messaging Tests

#### Issue: Messages not appearing on second device

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

#### Issue: "User not found" error when sending message

**Solution:**

1. Verify recipient user ID is exact (no extra spaces)
2. Check both users are registered:
   ```bash
   kubectl logs -n apps deployment/auth-service | grep "registered"
   ```

---

#### Issue: Message stuck in "pending" status

**Solution:**

1. Check messaging service is running:
   ```bash
   kubectl get pods -n apps | grep messaging
   ```

2. Check gRPC connection:
   ```bash
   # From Flutter console, look for:
   # "gRPC Error: Connection refused"
   ```

3. Restart port-forward if needed

---

#### Issue: Duplicate messages appearing

**Potential causes:**
- StreamSubscription not cancelled properly
- Multiple BLoC instances created

**Solution:**
- Restart both Flutter apps
- Check Flutter console for warnings

---

### ✅ After Phase 2 Testing Complete

Report back with:

1. ✅ Phase 2 test results checklist (all 8 test cases)
2. 🐛 Any issues encountered (with screenshots/logs)
3. 📸 Screenshots of successful two-device messaging
4. 💡 UX feedback (UI improvements, missing features)

---

**Good luck with messaging testing! 🚀💬**
