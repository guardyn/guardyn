# Flutter Client Testing

For complete testing documentation, see:

**[docs/CLIENT_TESTING_GUIDE.md](../docs/CLIENT_TESTING_GUIDE.md)**

## Quick Links

- **Quick Start**: [docs/CLIENT_TESTING_GUIDE.md#quick-start](../docs/CLIENT_TESTING_GUIDE.md#quick-start)
- **Phase 1: Authentication Testing**: [docs/CLIENT_TESTING_GUIDE.md#phase-1-authentication-testing](../docs/CLIENT_TESTING_GUIDE.md#phase-1-authentication-testing)
- **Phase 2: Two-Device Messaging Testing**: [docs/CLIENT_TESTING_GUIDE.md#phase-2-two-device-messaging-testing](../docs/CLIENT_TESTING_GUIDE.md#phase-2-two-device-messaging-testing)
- **Success Criteria Checklist**: [docs/CLIENT_TESTING_GUIDE.md#success-criteria-checklist](../docs/CLIENT_TESTING_GUIDE.md#success-criteria-checklist)
- **Backend API Testing (grpcurl)**: [docs/CLIENT_TESTING_GUIDE.md#backend-api-testing-grpcurl](../docs/CLIENT_TESTING_GUIDE.md#backend-api-testing-grpcurl)
- **Test Commands Reference**: [docs/CLIENT_TESTING_GUIDE.md#test-commands-reference](../docs/CLIENT_TESTING_GUIDE.md#test-commands-reference)
- **Troubleshooting**: [docs/CLIENT_TESTING_GUIDE.md#troubleshooting](../docs/CLIENT_TESTING_GUIDE.md#troubleshooting)

## Quick Commands

### Automated Testing (Recommended)

```bash
# Integration tests (automated)
./scripts/test-client.sh integration

# Two-device manual testing (Linux + Android)
./scripts/test-client.sh two-device linux

# Verify setup and build
./scripts/test-client.sh verify

# Show all commands
./scripts/test-client.sh help
```

### Manual Testing

```bash
# Prerequisites (Docker Compose backend)
docker compose -f ../docker-compose.dev.yml up -d

# Run Flutter Mobile (iOS/Android only)
flutter run -d emulator-5554    # Android emulator

# For Desktop clients (Windows/macOS/Linux) use Tauri:
cd ../client-desktop && npm run tauri dev
```

---

**See full guide**: [docs/CLIENT_TESTING_GUIDE.md](../docs/CLIENT_TESTING_GUIDE.md)
