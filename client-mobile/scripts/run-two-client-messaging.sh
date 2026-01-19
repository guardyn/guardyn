#!/usr/bin/env bash
#
# Run two-client E2EE messaging test (Android + Linux)
#
# Tests encrypted messaging between two devices:
# - Alice: Android device
# - Bob: Linux desktop
#
# Flow:
# 1. Alice registers on Android
# 2. Bob registers on Linux
# 3. Alice sends encrypted message to Bob
# 4. Bob receives and decrypts message
# 5. Bob replies to Alice
# 6. Alice receives and decrypts reply
#
# Usage:
#   ./scripts/run-two-client-messaging.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$CLIENT_DIR/.." && pwd)"

# Configurable
ALICE_USER="alice-$(date +%s)"
BOB_USER="bob-$(date +%s)"
TEST_MESSAGE="Hello from Android! $(date +%H:%M:%S)"

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

log_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================
# Setup
# ============================================================

log_header "Two-Client E2EE Messaging Test (Android + Linux)"

cd "$CLIENT_DIR"

# Find Android device - store output first to avoid broken pipe
DEVICES_OUTPUT=$(flutter devices 2>/dev/null || true)
ANDROID_DEVICE=$(echo "$DEVICES_OUTPUT" | grep -i android | head -1 | awk -F'•' '{print $2}' | xargs)

if [ -z "$ANDROID_DEVICE" ]; then
    log_error "No Android device found"
    exit 1
fi

log_info "Android device: $ANDROID_DEVICE"
log_info "Alice (Android): $ALICE_USER"
log_info "Bob (Linux): $BOB_USER"

# ============================================================
# Clear App Data (for clean test state)
# ============================================================

log_header "Clearing App Data"

# Get package name
PACKAGE_NAME="io.guardyn.client"

# Clear Android app data
log_info "Clearing Android app data..."
adb -s "$ANDROID_DEVICE" shell pm clear "$PACKAGE_NAME" 2>/dev/null || {
    log_info "Could not clear Android data (app may not be installed yet)"
}

# Clear Linux app data
log_info "Clearing Linux app data..."
rm -rf "$HOME/.local/share/guardyn_client" 2>/dev/null || true
rm -rf "$HOME/.config/guardyn_client" 2>/dev/null || true

log_success "App data cleared"

# ============================================================
# Run Integration Test
# ============================================================

log_header "Running Two-Client Test"

# Run the existing two-client test with Android + Linux
flutter test integration_test/two_client_messaging_test.dart \
    -d linux \
    --dart-define=ALICE_DEVICE=android \
    --dart-define=BOB_DEVICE=linux \
    --dart-define=ALICE_NAME="$ALICE_USER" \
    --dart-define=BOB_NAME="$BOB_USER" \
    --reporter expanded

exit_code=$?

# ============================================================
# Result
# ============================================================

log_header "Test Results"

if [ $exit_code -eq 0 ]; then
    log_success "TWO-CLIENT MESSAGING TEST PASSED"
    echo ""
    echo "E2EE messaging verified:"
    echo "  - Alice (Android) ↔ Bob (Linux)"
    echo "  - X3DH key exchange: OK"
    echo "  - Message encryption: OK"
    echo "  - Message decryption: OK"
else
    log_error "TWO-CLIENT MESSAGING TEST FAILED"
    echo ""
    echo "Debugging tips:"
    echo "  1. Check backend logs: docker compose logs -f"
    echo "  2. Check device logcat: adb logcat | grep guardyn"
    echo "  3. Run with verbose: flutter test --verbose ..."
fi

exit $exit_code
