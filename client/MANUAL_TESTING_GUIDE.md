# Flutter Client Manual Testing Guide

**Date**: November 14, 2025  
**Status**: Ready for manual testing - All unit tests passing (41/41)

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
   - Password: `password123`
   - Confirm Password: `password123`
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
   - Password: `password123`
   - Device Name: `Test`
2. Try to tap "Register"

**Expected**: Error message appears: "Username must be at least 3 characters"

---

**Test 2b: Short Password**
1. Enter:
   - Username: `testuser2`
   - Password: `pass` (only 4 characters)
   - Device Name: `Test`
2. Try to tap "Register"

**Expected**: Error message appears: "Password must be at least 8 characters"

---

**Test 2c: Password Mismatch**
1. Enter:
   - Username: `testuser2`
   - Password: `password123`
   - Confirm Password: `password456` (different)
   - Device Name: `Test`
2. Try to tap "Register"

**Expected**: Error message appears: "Passwords do not match"

---

**Test 2d: Empty Device Name**
1. Enter:
   - Username: `testuser2`
   - Password: `password123`
   - Confirm Password: `password123`
   - Device Name: `` (empty)
2. Try to tap "Register"

**Expected**: Error message appears: "Device name cannot be empty"

---

### Test Case 3: Duplicate Username ❌

**Steps:**
1. Try to register with username `testuser1` again (already exists)
2. Fill in:
   - Username: `testuser1`
   - Password: `password123`
   - Confirm Password: `password123`
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
   - Password: `password123`
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
   - Password: `password123`
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

**Good luck with testing! 🚀**
