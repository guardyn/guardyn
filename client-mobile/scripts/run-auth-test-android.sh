#!/usr/bin/env bash
#
# Run authentication integration tests on Android
#
# Tests:
# - Registration flow
# - Logout
# - Login flow
# - Form validation
#
# Prerequisites:
# - Backend services running (Docker Compose)
# - Android device/emulator connected
#
# Usage:
#   ./scripts/run-auth-test-android.sh              # Run all auth tests
#   ./scripts/run-auth-test-android.sh --full       # Run full flow only
#   ./scripts/run-auth-test-android.sh --validation # Run validation tests only

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$CLIENT_DIR/.." && pwd)"

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

log_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Parse arguments
TEST_FILTER=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --full)
            TEST_FILTER="Complete auth flow"
            shift
            ;;
        --validation)
            TEST_FILTER="validation"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --full        Run only the full auth flow test"
            echo "  --validation  Run only validation tests"
            echo "  --help        Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

log_header "🔐 Authentication Integration Test (Android)"

cd "$CLIENT_DIR"

# ═══════════════════════════════════════════════════════════════════════════
# Prerequisites Check
# ═══════════════════════════════════════════════════════════════════════════

log_info "Checking prerequisites..."

# 1. Check Android device
log_info "Looking for Android device..."
DEVICES_OUTPUT=$(flutter devices 2>/dev/null || true)
ANDROID_DEVICE=$(echo "$DEVICES_OUTPUT" | grep -i "android" | head -1 | awk -F'•' '{print $2}' | xargs)

if [ -z "$ANDROID_DEVICE" ]; then
    log_error "No Android device found!"
    echo ""
    echo "Available devices:"
    echo "$DEVICES_OUTPUT"
    echo ""
    echo "Please:"
    echo "  1. Connect Android device via USB with debugging enabled"
    echo "  2. Or start emulator: \$HOME/Android/Sdk/emulator/emulator -avd <avd-name>"
    exit 1
fi

log_success "Android device: $ANDROID_DEVICE"

# 2. Check backend services
log_info "Checking backend services..."

BACKEND_RUNNING=false
if docker compose -f "$PROJECT_ROOT/docker-compose.dev.yml" ps 2>/dev/null | grep -q "running\|Up"; then
    log_success "Backend services: Running (Docker Compose)"
    BACKEND_RUNNING=true
fi

if [ "$BACKEND_RUNNING" = false ]; then
    log_warn "Backend services may not be running!"
    echo ""
    echo "Start with: docker compose -f docker-compose.dev.yml up -d"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 3. Check native libraries
log_info "Checking native libraries..."

ANDROID_JNI_DIR="$CLIENT_DIR/android/app/src/main/jniLibs"
if [ ! -f "$ANDROID_JNI_DIR/arm64-v8a/libguardyn_crypto_ffi.so" ]; then
    log_warn "Android native libraries not found in jniLibs"
    log_info "Checking alternative location..."
    
    if [ -f "$CLIENT_DIR/native/android/arm64-v8a/libguardyn_crypto_ffi.so" ]; then
        log_info "Found in native/android/, copying to jniLibs..."
        mkdir -p "$ANDROID_JNI_DIR"/{arm64-v8a,armeabi-v7a,x86_64}
        cp -r "$CLIENT_DIR/native/android/"*/ "$ANDROID_JNI_DIR/" 2>/dev/null || true
        log_success "Copied native libraries"
    else
        log_error "Native libraries not found!"
        echo "Run: just ffi-build-android"
        exit 1
    fi
fi
log_success "Native libraries: OK"

# ═══════════════════════════════════════════════════════════════════════════
# Clear App Data (fresh start)
# ═══════════════════════════════════════════════════════════════════════════

log_info "Clearing app data for clean test..."

PACKAGE_NAME="io.guardyn.guardyn_client"

# Try to clear app data
if adb -s "$ANDROID_DEVICE" shell pm clear "$PACKAGE_NAME" 2>/dev/null; then
    log_success "App data cleared"
else
    log_info "Could not clear app data (app may not be installed yet)"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Run Tests
# ═══════════════════════════════════════════════════════════════════════════

log_header "Running Authentication Tests"

TEST_FILE="integration_test/auth_registration_test.dart"

# Build test command
TEST_CMD="flutter test $TEST_FILE -d $ANDROID_DEVICE"

if [ -n "$TEST_FILTER" ]; then
    TEST_CMD="$TEST_CMD --name=\"$TEST_FILTER\""
    log_info "Filter: $TEST_FILTER"
fi

log_info "Executing: $TEST_CMD"
echo ""

# Run tests
set +e
eval "$TEST_CMD"
TEST_EXIT_CODE=$?
set -e

# ═══════════════════════════════════════════════════════════════════════════
# Results
# ═══════════════════════════════════════════════════════════════════════════

log_header "Test Results"

if [ $TEST_EXIT_CODE -eq 0 ]; then
    log_success "ALL TESTS PASSED!"
    echo ""
    echo -e "${GREEN}${BOLD}Authentication flow verified:${NC}"
    echo "  ✅ Registration - creates new account"
    echo "  ✅ Logout - terminates session"
    echo "  ✅ Login - authenticates existing user"
    echo "  ✅ Validation - form validation works"
else
    log_error "TESTS FAILED (exit code: $TEST_EXIT_CODE)"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check backend logs: docker logs guardyn-auth --tail 100"
    echo "  2. Check device logs: adb logcat -s flutter"
    echo "  3. Run with verbose: flutter test $TEST_FILE -d $ANDROID_DEVICE --verbose"
fi

exit $TEST_EXIT_CODE
