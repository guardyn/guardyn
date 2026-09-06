# Flutter Client Testing

`docs/CLIENT_TESTING_GUIDE.md` was deleted in PR-01. Its replacements:

- Setup and the pull-request contract — [`CONTRIBUTING.md`](../CONTRIBUTING.md)
- Running and troubleshooting the stack — [`docs/ops/RUNBOOK.md`](../docs/ops/RUNBOOK.md)
- Deploying it — [`docs/ops/DEPLOYMENT.md`](../docs/ops/DEPLOYMENT.md)

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

For anything not covered here, start at [`docs/INDEX.md`](../docs/INDEX.md).
