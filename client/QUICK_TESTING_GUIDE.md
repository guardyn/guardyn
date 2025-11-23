# Quick Testing Guide - Messaging Feature

**Date**: November 23, 2025 ✅ **COMPILATION FIXED**  
**For**: Two-device messaging testing

---

## ✅ Prerequisites Complete

- ✅ **Protocol Buffers generated** (run `./scripts/generate_proto.sh`)
- ✅ **Import paths fixed** (all compilation errors resolved)
- ✅ **MessageBloc registered** (dependency injection working)
- ✅ **App compiles on all platforms** (Chrome, Linux, Android)

---

## 🎯 Two Testing Options

### Option 1: Automated Integration Tests ⚡ (Recommended First)

**What it does**: Programmatically tests registration, login, and messaging flow

**Run time**: 2-3 minutes

**Command**:
```bash
cd client
./scripts/run_integration_tests.sh
```

**What you'll see**:
- ✅ Backend services check
- ✅ Automatic port-forwarding setup
- ✅ Tests run on first available device
- ✅ Pass/fail results with summary

**Prerequisites**:
- k3d cluster running
- Backend services deployed

---

### Option 2: Manual Two-Device Testing 📱 (Complete UX Validation)

**What it does**: You manually test messaging on two devices/emulators

**Run time**: 15-20 minutes

**Full guide**: [`client/MANUAL_TESTING_GUIDE.md`](MANUAL_TESTING_GUIDE.md)

**Quick steps**:

1. **Use automated script (easiest)**:
   ```bash
   cd client
   ./scripts/start_two_device_test.sh
   ```

   OR manually:

2. **Terminal 1 & 2: Port-forward backend**
   ```bash
   kubectl port-forward -n apps svc/auth-service 50051:50051
   kubectl port-forward -n apps svc/messaging-service 50052:50052
   ```

3. **Launch emulator** (Linux - use full path):
   ```bash
   $HOME/Android/Sdk/emulator/emulator -list-avds
   $HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 &
   ```

4. **Terminal 3: Run Flutter on Chrome (Device 1)**
   ```bash
   cd client
   flutter run -d chrome
   ```

5. **Terminal 4: Run Flutter on Android (Device 2)**
   ```bash
   cd client
   flutter devices  # Find emulator ID
   flutter run -d emulator-5554
   ```

6. **Test messaging flow**
   - Device 1: Register as "alice"
   - Device 2: Register as "bob"  
   - Device 1: Navigate to Messages → Send to Bob's ID
   - Device 2: Verify message received
   - Send replies back and forth

**18 test cases** in the full guide covering:
- Registration/login (13 tests)
- Two-device messaging (8 tests)
- Error handling, offline, rapid sending

---

## 📊 Expected Results

### Integration Tests
```
✅ Alice registration: PASS
✅ Bob registration: PASS
✅ Navigation to Messages: PASS
✅ Backend connectivity: PASS
⏳ Full message send: PENDING (requires "New Chat" UI)
```

### Manual Tests
```
✅ Messages send between devices in real-time
✅ Delivery status updates correctly
✅ Conversation list shows all chats
✅ Offline messages delivered when user reconnects
✅ No crashes or data loss
```

---

## 🐛 Troubleshooting

### "Connection refused" error

**Fix**:
```bash
# Check backend is running
kubectl get pods -n apps

# Restart port-forwarding
# Kill existing: Ctrl+C in port-forward terminals
# Then re-run port-forward commands
```

### No devices available

**Fix**:
```bash
# List devices
flutter devices

# Start emulator
emulator -list-avds
emulator -avd <avd-name> &
```

### Integration tests fail

**Check**:
1. Backend services running: `kubectl get pods -n apps`
2. Port-forwarding active: `lsof -i :50051` and `lsof -i :50052`
3. Review test output for specific errors

---

## 📖 Full Documentation

- **Integration Tests**: `client/integration_test/README.md`
- **Manual Testing**: `client/MANUAL_TESTING_GUIDE.md`
- **Client README**: `client/README.md`

---

## 🚀 Next Steps After Testing

1. ✅ Record test results (pass/fail for each test case)
2. 📸 Take screenshots of successful messaging
3. 🐛 Report any bugs found
4. 💡 Provide UX feedback

**Report to**: Session notes or create GitHub issue

---

**Good luck! 🎉**
