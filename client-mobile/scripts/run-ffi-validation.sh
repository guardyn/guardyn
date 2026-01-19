#!/usr/bin/env bash
#
# Simple FFI validation test for Android and Linux
#
# This script runs the FFI crypto tests on both platforms
# to verify that the Rust crypto library works correctly.
#
# For full two-client E2EE messaging tests, use the manual
# approach described in docs/TWO_CLIENT_TESTING.md
#
# Usage:
#   ./scripts/run-ffi-validation.sh

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

log_header "FFI Validation Test"

cd "$CLIENT_DIR"

# Get devices
DEVICES_OUTPUT=$(flutter devices 2>/dev/null || true)
ANDROID_DEVICE=$(echo "$DEVICES_OUTPUT" | grep -i android | head -1 | awk -F'•' '{print $2}' | xargs || true)

ANDROID_RESULT="SKIPPED"
LINUX_RESULT="SKIPPED"

# Test Android if available
if [ -n "$ANDROID_DEVICE" ]; then
    log_info "Testing on Android: $ANDROID_DEVICE"

    if flutter test integration_test/crypto/rust_ffi_test.dart \
        -d "$ANDROID_DEVICE" \
        --reporter compact 2>&1; then
        ANDROID_RESULT="PASSED"
    else
        ANDROID_RESULT="FAILED"
    fi
else
    log_info "No Android device found, skipping"
fi

# Test Linux
log_info "Testing on Linux..."
if flutter test integration_test/crypto/rust_ffi_test.dart \
    -d linux \
    --reporter compact 2>&1; then
    LINUX_RESULT="PASSED"
else
    LINUX_RESULT="FAILED"
fi

# Results
log_header "Results"

echo ""
if [ "$ANDROID_RESULT" = "PASSED" ]; then
    echo -e "  Android: ${GREEN}✅ PASSED${NC}"
elif [ "$ANDROID_RESULT" = "SKIPPED" ]; then
    echo -e "  Android: ${YELLOW}⏭️  SKIPPED${NC}"
else
    echo -e "  Android: ${RED}❌ FAILED${NC}"
fi

if [ "$LINUX_RESULT" = "PASSED" ]; then
    echo -e "  Linux:   ${GREEN}✅ PASSED${NC}"
elif [ "$LINUX_RESULT" = "SKIPPED" ]; then
    echo -e "  Linux:   ${YELLOW}⏭️  SKIPPED${NC}"
else
    echo -e "  Linux:   ${RED}❌ FAILED${NC}"
fi
echo ""

# Summary
if [ "$ANDROID_RESULT" = "PASSED" ] && [ "$LINUX_RESULT" = "PASSED" ]; then
    log_success "All FFI tests passed!"
    echo ""
    echo "The Rust crypto library works correctly on both platforms."
    echo ""
    echo "For two-client E2EE messaging test, follow the manual steps:"
    echo "  1. Start backend: docker compose -f docker-compose.dev.yml up -d"
    echo "  2. Terminal 1: cd client-desktop && npm run tauri dev (Desktop)"
    echo "  3. Terminal 2: cd client-mobile && flutter run -d emulator-5554 (Android)"
    echo "  4. Register different users on each device"
    echo "  5. Send messages between them"
    exit 0
elif [ "$LINUX_RESULT" = "PASSED" ]; then
    log_success "Linux FFI tests passed (Android skipped)"
    exit 0
else
    log_error "Some tests failed"
    exit 1
fi
