# Flutter Client Testing

For complete testing documentation, see:

**[docs/CLIENT_TESTING_GUIDE.md](../docs/CLIENT_TESTING_GUIDE.md)**

## Quick Links

- **Quick Start**: [docs/CLIENT_TESTING_GUIDE.md#quick-start](../docs/CLIENT_TESTING_GUIDE.md#quick-start)
- **Phase 1: Authentication Testing**: [docs/CLIENT_TESTING_GUIDE.md#phase-1-authentication-testing](../docs/CLIENT_TESTING_GUIDE.md#phase-1-authentication-testing)
- **Phase 2: Two-Device Messaging Testing**: [docs/CLIENT_TESTING_GUIDE.md#phase-2-two-device-messaging-testing](../docs/CLIENT_TESTING_GUIDE.md#phase-2-two-device-messaging-testing)
- **Test Commands Reference**: [docs/CLIENT_TESTING_GUIDE.md#test-commands-reference](../docs/CLIENT_TESTING_GUIDE.md#test-commands-reference)
- **Troubleshooting**: [docs/CLIENT_TESTING_GUIDE.md#troubleshooting](../docs/CLIENT_TESTING_GUIDE.md#troubleshooting)

## Quick Commands

### Automated Testing (Recommended)

```bash
# Integration tests
./scripts/run_integration_tests.sh

# Two-device manual testing
./scripts/test_two_devices.sh chrome  # or 'linux'
```

### Manual Testing

```bash
# Prerequisites
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &

# Chrome only: Start Envoy proxy
./scripts/start_envoy_proxy.sh

# Run Flutter
flutter run -d chrome          # Chrome
flutter run -d linux            # Linux desktop
flutter run -d emulator-5554    # Android emulator
```

---

**See full guide**: [docs/CLIENT_TESTING_GUIDE.md](../docs/CLIENT_TESTING_GUIDE.md)
