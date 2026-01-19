#!/usr/bin/env bash
#
# Run two-client integration test (Android + Linux Desktop)
#
# This script tests E2EE messaging between:
# - Device 1 (Alice): Android device
# - Device 2 (Bob): Linux desktop
#
# Prerequisites:
# - Backend services running (Docker Compose or k8s)
# - Android device connected via USB
# - Rust FFI libraries built for both platforms
#
# Usage:
#   ./scripts/run-android-linux-test.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$CLIENT_DIR/.." && pwd)"

# PIDs for cleanup
LINUX_PID=""
ANDROID_PID=""

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

log_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

cleanup() {
    log_info "Cleaning up..."
    [ -n "${LINUX_PID:-}" ] && kill "$LINUX_PID" 2>/dev/null || true
    [ -n "${ANDROID_PID:-}" ] && kill "$ANDROID_PID" 2>/dev/null || true
    log_success "Cleanup complete"
}

trap cleanup EXIT INT TERM

# ============================================================
# Check Prerequisites
# ============================================================

log_header "Android + Linux Two-Client Test"

cd "$CLIENT_DIR"

# 1. Check Android device
log_info "Checking for Android device..."
# Store output to avoid broken pipe, extract device ID from second column after •
DEVICES_OUTPUT=$(flutter devices 2>/dev/null || true)
ANDROID_DEVICE=$(echo "$DEVICES_OUTPUT" | grep -i android | head -1 | awk -F'•' '{print $2}' | xargs)

if [ -z "$ANDROID_DEVICE" ]; then
    log_error "No Android device found!"
    echo ""
    echo "Please:"
    echo "  1. Connect Android device via USB"
    echo "  2. Enable USB Debugging in Developer Options"
    echo "  3. Accept debugging prompt on device"
    echo ""
    echo "Then run: flutter devices"
    exit 1
fi

log_success "Android device: $ANDROID_DEVICE"

# 2. Check Linux desktop (reuse DEVICES_OUTPUT from above)
log_info "Checking Linux desktop..."
if ! echo "$DEVICES_OUTPUT" | grep -qi linux; then
    log_error "Linux desktop not available"
    exit 1
fi
log_success "Linux desktop available"

# 3. Check backend services
log_info "Checking backend services..."

# Try Docker Compose first
if docker compose -f "$PROJECT_ROOT/docker-compose.dev.yml" ps 2>/dev/null | grep -q "running"; then
    log_success "Backend running (Docker Compose)"
    BACKEND_TYPE="docker"
# Try Kubernetes
elif kubectl get pods -n apps 2>/dev/null | grep -q "Running"; then
    log_success "Backend running (Kubernetes)"
    BACKEND_TYPE="k8s"
else
    log_warn "Backend services not detected (may still work if running)"
    BACKEND_TYPE="unknown"
fi

# 4. Check native libraries
log_info "Checking native libraries..."

if [ ! -f "$CLIENT_DIR/linux/libguardyn_crypto_ffi.so" ]; then
    log_warn "Linux library not found, building..."
    cd "$PROJECT_ROOT" && just ffi-install-linux
    cd "$CLIENT_DIR"
fi
log_success "Linux library: OK"

if [ ! -f "$CLIENT_DIR/android/app/src/main/jniLibs/arm64-v8a/libguardyn_crypto_ffi.so" ]; then
    log_warn "Android libraries not in jniLibs, copying..."
    mkdir -p "$CLIENT_DIR/android/app/src/main/jniLibs"/{arm64-v8a,armeabi-v7a,x86_64}
    cp -r "$CLIENT_DIR/native/android/"* "$CLIENT_DIR/android/app/src/main/jniLibs/" 2>/dev/null || {
        log_error "Android libraries not built!"
        echo "Run: just ffi-build-android"
        exit 1
    }
fi
log_success "Android libraries: OK"

# ============================================================
# Run Tests
# ============================================================

log_header "Running FFI Integration Tests"

# Create temp dir for logs
LOG_DIR=$(mktemp -d)
LINUX_LOG="$LOG_DIR/linux.log"
ANDROID_LOG="$LOG_DIR/android.log"

log_info "Logs: $LOG_DIR"

# ============================================================
# Test 1: FFI Tests on Android
# ============================================================

log_info "Running FFI tests on Android ($ANDROID_DEVICE)..."

flutter test integration_test/crypto/rust_ffi_test.dart \
    -d "$ANDROID_DEVICE" \
    --reporter expanded \
    2>&1 | tee "$ANDROID_LOG" &
ANDROID_PID=$!

# Wait for Android tests
wait $ANDROID_PID
ANDROID_EXIT=$?
ANDROID_PID=""

if [ $ANDROID_EXIT -eq 0 ]; then
    log_success "Android FFI tests: PASSED"
else
    log_error "Android FFI tests: FAILED"
    echo "See log: $ANDROID_LOG"
fi

# ============================================================
# Test 2: FFI Tests on Linux (for comparison)
# ============================================================

log_info "Running FFI tests on Linux..."

flutter test integration_test/crypto/rust_ffi_test.dart \
    -d linux \
    --reporter expanded \
    2>&1 | tee "$LINUX_LOG" &
LINUX_PID=$!

wait $LINUX_PID
LINUX_EXIT=$?
LINUX_PID=""

if [ $LINUX_EXIT -eq 0 ]; then
    log_success "Linux FFI tests: PASSED"
else
    log_error "Linux FFI tests: FAILED"
    echo "See log: $LINUX_LOG"
fi

# ============================================================
# Summary
# ============================================================

log_header "Test Results"

echo ""
if [ $ANDROID_EXIT -eq 0 ]; then
    echo -e "  Android FFI: ${GREEN}✅ PASSED${NC}"
else
    echo -e "  Android FFI: ${RED}❌ FAILED${NC}"
fi

if [ $LINUX_EXIT -eq 0 ]; then
    echo -e "  Linux FFI:   ${GREEN}✅ PASSED${NC}"
else
    echo -e "  Linux FFI:   ${RED}❌ FAILED${NC}"
fi
echo ""

# Overall result
if [ $ANDROID_EXIT -eq 0 ] && [ $LINUX_EXIT -eq 0 ]; then
    log_success "ALL FFI TESTS PASSED"
    echo ""
    echo "Next step: Run two-client messaging test"
    echo "  ./scripts/run-two-client-messaging.sh"
    exit 0
else
    log_error "SOME TESTS FAILED"
    echo ""
    echo "Check logs:"
    echo "  Android: $ANDROID_LOG"
    echo "  Linux:   $LINUX_LOG"
    exit 1
fi
