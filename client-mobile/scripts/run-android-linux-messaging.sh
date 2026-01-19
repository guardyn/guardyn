#!/usr/bin/env bash
#
# Run Android + Linux two-client messaging integration test
#
# This script orchestrates simultaneous testing between:
# - Device 1 (Alice): Android device/emulator
# - Device 2 (Bob): Linux desktop
#
# Both clients run the same test file but with different roles,
# synchronized via file-based signaling in /tmp/guardyn_test_sync/
#
# Prerequisites:
# - Backend services running (Docker Compose or Kubernetes)
# - Android device connected (USB debugging enabled)
# - Native FFI libraries built for both platforms
#
# Usage:
#   ./scripts/run-android-linux-messaging.sh
#   ./scripts/run-android-linux-messaging.sh --android-only
#   ./scripts/run-android-linux-messaging.sh --linux-only
#   ./scripts/run-android-linux-messaging.sh --cleanup

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$CLIENT_DIR/.." && pwd)"

# Test configuration
TEST_RUN_ID="${TEST_RUN_ID:-$(date +%s)}"
# Use system temp directory (same as Dart's Directory.systemTemp)
SYNC_DIR="${TMPDIR:-/tmp}/guardyn_test_sync/$TEST_RUN_ID"
TEST_FILE="integration_test/android_linux_messaging_test.dart"

# Process tracking
ALICE_PID=""
BOB_PID=""
LOG_DIR=""

# Logging
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_debug() { [[ "${DEBUG:-}" == "1" ]] && echo -e "${MAGENTA}🔍 $1${NC}" || true; }

log_header() {
    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

log_subheader() {
    echo ""
    echo -e "${BLUE}── $1 ──${NC}"
    echo ""
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    
    # Kill test processes
    [[ -n "${ALICE_PID:-}" ]] && kill "$ALICE_PID" 2>/dev/null || true
    [[ -n "${BOB_PID:-}" ]] && kill "$BOB_PID" 2>/dev/null || true
    [[ -n "${DIALOG_DISMISS_PID:-}" ]] && kill "$DIALOG_DISMISS_PID" 2>/dev/null || true
    
    # Don't delete logs - they're useful for debugging
    if [[ -d "${LOG_DIR:-}" ]]; then
        log_info "Logs saved in: $LOG_DIR"
    fi
    
    log_success "Cleanup complete"
}

trap cleanup EXIT INT TERM

# Parse arguments
ANDROID_ONLY=false
LINUX_ONLY=false
CLEANUP_ONLY=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --android-only)
            ANDROID_ONLY=true
            shift
            ;;
        --linux-only)
            LINUX_ONLY=true
            shift
            ;;
        --cleanup)
            CLEANUP_ONLY=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            export DEBUG=1
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --android-only   Run only Alice (Android) client"
            echo "  --linux-only     Run only Bob (Linux) client"
            echo "  --cleanup        Clean up sync files and exit"
            echo "  --verbose, -v    Enable verbose output"
            echo "  --help, -h       Show this help"
            echo ""
            echo "Environment variables:"
            echo "  TEST_RUN_ID      Unique ID for this test run (default: timestamp)"
            echo "  DEBUG=1          Enable debug output"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Cleanup only mode
if [[ "$CLEANUP_ONLY" == "true" ]]; then
    log_header "Cleaning Up Test Artifacts"
    rm -rf "${TMPDIR:-/tmp}/guardyn_test_sync"
    log_success "All sync files removed"
    exit 0
fi

# ============================================================
# Main Script
# ============================================================

log_header "🚀 Android + Linux Two-Client Messaging Test"

echo "  Test Run ID: $TEST_RUN_ID"
echo "  Sync Dir:    $SYNC_DIR"
echo ""

cd "$CLIENT_DIR"

# ============================================================
# Prerequisites Check
# ============================================================

log_subheader "Prerequisites Check"

# Get devices list once (used by both Android and Linux checks)
log_info "Getting available devices..."
DEVICES_OUTPUT=$(flutter devices 2>/dev/null || true)
log_debug "Devices output:\n$DEVICES_OUTPUT"

# 1. Check Android device (unless Linux-only)
if [[ "$LINUX_ONLY" != "true" ]]; then
    log_info "Looking for Android device..."
    
    ANDROID_DEVICE=$(echo "$DEVICES_OUTPUT" | grep -i android | head -1 | awk -F'•' '{print $2}' | xargs || true)
    
    if [[ -z "$ANDROID_DEVICE" ]]; then
        log_error "No Android device found!"
        echo ""
        echo "Please:"
        echo "  1. Connect Android device via USB"
        echo "  2. Enable USB Debugging in Developer Options"
        echo "  3. Accept debugging prompt on device"
        echo ""
        echo "Run 'flutter devices' to verify."
        exit 1
    fi
    
    log_success "Android device: $ANDROID_DEVICE"
fi

# 2. Check Linux desktop (unless Android-only)
if [[ "$ANDROID_ONLY" != "true" ]]; then
    log_info "Checking Linux desktop..."
    
    # Check for Linux in devices list (case-insensitive, handles "Linux (desktop)")
    if ! echo "$DEVICES_OUTPUT" | grep -i "linux" | grep -qi "desktop\|linux-x64"; then
        log_error "Linux desktop not available"
        echo "Make sure you have GTK development libraries installed."
        echo ""
        echo "Install on Ubuntu/Debian:"
        echo "  sudo apt install libgtk-3-dev libblkid-dev liblzma-dev"
        exit 1
    fi
    
    log_success "Linux desktop available"
fi

# 3. Check backend services
log_info "Checking backend services..."

BACKEND_RUNNING=false

# Try Docker Compose first (check for "Up" in status)
if docker compose -f "$PROJECT_ROOT/docker-compose.dev.yml" ps 2>/dev/null | grep -qE "Up|running"; then
    log_success "Backend running (Docker Compose)"
    BACKEND_RUNNING=true
# Try Kubernetes
elif kubectl get pods -n apps 2>/dev/null | grep -q "Running"; then
    log_success "Backend running (Kubernetes)"
    BACKEND_RUNNING=true
fi

if [[ "$BACKEND_RUNNING" != "true" ]]; then
    log_warn "Backend services not detected!"
    echo ""
    echo "Start backend with:"
    echo "  docker compose -f docker-compose.dev.yml up -d"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 4. Check native libraries
log_info "Checking native FFI libraries..."

LIBS_MISSING=false

if [[ "$LINUX_ONLY" != "true" ]]; then
    # Android libraries in jniLibs
    if [[ ! -d "$CLIENT_DIR/android/app/src/main/jniLibs/arm64-v8a" ]]; then
        log_warn "Android ARM64 library not in jniLibs"
        
        # Try to copy from native/ directory
        if [[ -d "$CLIENT_DIR/native/android/arm64-v8a" ]]; then
            log_info "Copying Android libraries to jniLibs..."
            mkdir -p "$CLIENT_DIR/android/app/src/main/jniLibs"/{arm64-v8a,armeabi-v7a,x86_64}
            cp -r "$CLIENT_DIR/native/android/"* "$CLIENT_DIR/android/app/src/main/jniLibs/"
            log_success "Android libraries installed"
        else
            log_error "Android libraries not built!"
            echo "Run: just ffi-build-android"
            LIBS_MISSING=true
        fi
    else
        log_success "Android libraries: OK"
    fi
fi

if [[ "$ANDROID_ONLY" != "true" ]]; then
    # Linux library
    if [[ ! -f "$CLIENT_DIR/linux/libguardyn_crypto_ffi.so" ]]; then
        log_warn "Linux library not found"
        
        # Try to build/install
        if command -v just &>/dev/null; then
            log_info "Installing Linux library..."
            cd "$PROJECT_ROOT" && just ffi-install-linux
            cd "$CLIENT_DIR"
            log_success "Linux library installed"
        else
            log_error "Linux library not built!"
            echo "Run: just ffi-install-linux"
            LIBS_MISSING=true
        fi
    else
        log_success "Linux library: OK"
    fi
fi

if [[ "$LIBS_MISSING" == "true" ]]; then
    exit 1
fi

# 5. Grant notification permission on Android (avoid system dialog blocking test)
if [[ "$LINUX_ONLY" != "true" ]]; then
    log_info "Granting notification permission on Android..."
    
    # Get package name
    PACKAGE_NAME="io.guardyn.client"
    
    # Grant POST_NOTIFICATIONS permission (Android 13+)
    adb -s "$ANDROID_DEVICE" shell pm grant "$PACKAGE_NAME" android.permission.POST_NOTIFICATIONS 2>/dev/null || {
        log_warn "Could not grant notification permission (app may not be installed yet)"
    }
    
    # Close any system dialogs
    adb -s "$ANDROID_DEVICE" shell am broadcast -a android.intent.action.CLOSE_SYSTEM_DIALOGS 2>/dev/null || true
    
    log_success "Android permissions configured"
fi

# 6. Create sync directory
log_info "Creating sync directory..."
mkdir -p "$SYNC_DIR"
log_success "Sync directory: $SYNC_DIR"

# 6. Create log directory
LOG_DIR=$(mktemp -d -t guardyn_test_XXXXXX)
log_success "Log directory: $LOG_DIR"

# ============================================================
# Run Tests
# ============================================================

log_header "🧪 Running Two-Client Test"

ALICE_LOG="$LOG_DIR/alice_android.log"
BOB_LOG="$LOG_DIR/bob_linux.log"

ALICE_EXIT=0
BOB_EXIT=0

# Start Alice (Android) in background
if [[ "$LINUX_ONLY" != "true" ]]; then
    log_subheader "📱 Starting Alice (Android)"
    
    echo "  Device: $ANDROID_DEVICE"
    echo "  Log:    $ALICE_LOG"
    echo ""
    
    # Start a background process to auto-dismiss Android dialogs (permissions and ANR)
    (
        while true; do
            sleep 3
            
            # Check for ANR dialog and click "Wait"
            # ANR dialog "Wait" button coordinates (approximate center of "Wait" option)
            if adb -s "$ANDROID_DEVICE" shell "dumpsys window windows" 2>/dev/null | grep -q "Application Not Responding\|isn't responding"; then
                log_debug "ANR detected, clicking Wait..."
                adb -s "$ANDROID_DEVICE" shell "input tap 120 544" 2>/dev/null || true
                sleep 1
            fi
            
            # Check for permission dialogs and click "Allow"
            # Notification permission dialog "Allow" button
            if adb -s "$ANDROID_DEVICE" shell "dumpsys window windows" 2>/dev/null | grep -q "GrantPermissionsActivity\|notifications"; then
                log_debug "Permission dialog detected, clicking Allow..."
                adb -s "$ANDROID_DEVICE" shell "input tap 205 535" 2>/dev/null || true
                sleep 1
            fi
        done
    ) &
    DIALOG_DISMISS_PID=$!
    
    # Stop dialog dismisser after 120 seconds (crypto ops can take long time)
    (
        sleep 120
        kill $DIALOG_DISMISS_PID 2>/dev/null || true
    ) &
    
    flutter test "$TEST_FILE" \
        -d "$ANDROID_DEVICE" \
        --dart-define=TEST_ROLE=alice \
        --dart-define=TEST_RUN_ID="$TEST_RUN_ID" \
        --reporter expanded \
        2>&1 | tee "$ALICE_LOG" &
    ALICE_PID=$!
    
    log_info "Alice started (PID: $ALICE_PID)"
    
    # Give Android a head start
    sleep 3
fi

# Start Bob (Linux) in background
if [[ "$ANDROID_ONLY" != "true" ]]; then
    log_subheader "🐧 Starting Bob (Linux)"
    
    echo "  Log: $BOB_LOG"
    echo ""
    
    flutter test "$TEST_FILE" \
        -d linux \
        --dart-define=TEST_ROLE=bob \
        --dart-define=TEST_RUN_ID="$TEST_RUN_ID" \
        --reporter expanded \
        2>&1 | tee "$BOB_LOG" &
    BOB_PID=$!
    
    log_info "Bob started (PID: $BOB_PID)"
fi

# Wait for both tests to complete
log_subheader "⏳ Waiting for Tests to Complete"

echo "  Monitoring sync files in: $SYNC_DIR"
echo ""

# Monitor progress
TIMEOUT=300  # 5 minutes max
START_TIME=$(date +%s)

while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    
    if [[ $ELAPSED -gt $TIMEOUT ]]; then
        log_error "Test timeout after ${TIMEOUT}s"
        break
    fi
    
    # Check if processes are still running
    ALICE_RUNNING=false
    BOB_RUNNING=false
    
    [[ -n "${ALICE_PID:-}" ]] && kill -0 "$ALICE_PID" 2>/dev/null && ALICE_RUNNING=true
    [[ -n "${BOB_PID:-}" ]] && kill -0 "$BOB_PID" 2>/dev/null && BOB_RUNNING=true
    
    # Show progress
    if [[ "$VERBOSE" == "true" ]]; then
        echo -n "  [${ELAPSED}s] "
        ls -1 "$SYNC_DIR"/*.done 2>/dev/null | xargs -n1 basename 2>/dev/null | tr '\n' ' ' || true
        echo ""
    fi
    
    # Both done?
    if [[ "$ALICE_RUNNING" == "false" && "$BOB_RUNNING" == "false" ]]; then
        log_info "Both tests completed"
        break
    fi
    
    # Single client mode?
    if [[ "$LINUX_ONLY" == "true" && "$BOB_RUNNING" == "false" ]]; then
        log_info "Bob test completed"
        break
    fi
    
    if [[ "$ANDROID_ONLY" == "true" && "$ALICE_RUNNING" == "false" ]]; then
        log_info "Alice test completed"
        break
    fi
    
    sleep 2
done

# Get exit codes
if [[ -n "${ALICE_PID:-}" ]]; then
    wait "$ALICE_PID" || ALICE_EXIT=$?
    ALICE_PID=""
fi

if [[ -n "${BOB_PID:-}" ]]; then
    wait "$BOB_PID" || BOB_EXIT=$?
    BOB_PID=""
fi

# ============================================================
# Results Summary
# ============================================================

log_header "📊 Test Results"

echo ""

if [[ "$LINUX_ONLY" != "true" ]]; then
    if [[ $ALICE_EXIT -eq 0 ]]; then
        echo -e "  📱 Alice (Android): ${GREEN}✅ PASSED${NC}"
    else
        echo -e "  📱 Alice (Android): ${RED}❌ FAILED${NC} (exit code: $ALICE_EXIT)"
    fi
fi

if [[ "$ANDROID_ONLY" != "true" ]]; then
    if [[ $BOB_EXIT -eq 0 ]]; then
        echo -e "  🐧 Bob (Linux):     ${GREEN}✅ PASSED${NC}"
    else
        echo -e "  🐧 Bob (Linux):     ${RED}❌ FAILED${NC} (exit code: $BOB_EXIT)"
    fi
fi

echo ""

# Show sync events
log_subheader "Sync Events"
if ls "$SYNC_DIR"/*.done &>/dev/null; then
    for f in "$SYNC_DIR"/*.done; do
        PHASE=$(basename "$f" .done)
        TIME=$(cat "$f" 2>/dev/null || echo "unknown")
        echo "  ✓ $PHASE ($TIME)"
    done
else
    echo "  (no sync events)"
fi

echo ""

# Log file locations
log_subheader "Log Files"
echo "  Alice: $ALICE_LOG"
echo "  Bob:   $BOB_LOG"
echo ""

# Overall result
OVERALL_PASS=true
[[ "$LINUX_ONLY" != "true" && $ALICE_EXIT -ne 0 ]] && OVERALL_PASS=false
[[ "$ANDROID_ONLY" != "true" && $BOB_EXIT -ne 0 ]] && OVERALL_PASS=false

if [[ "$OVERALL_PASS" == "true" ]]; then
    log_header "🎉 ALL TESTS PASSED!"
    echo "Two-client E2EE messaging between Android and Linux verified successfully."
    echo ""
    exit 0
else
    log_header "💥 SOME TESTS FAILED"
    echo "Check the log files for details:"
    echo ""
    
    if [[ $ALICE_EXIT -ne 0 ]]; then
        echo "  tail -100 $ALICE_LOG"
    fi
    
    if [[ $BOB_EXIT -ne 0 ]]; then
        echo "  tail -100 $BOB_LOG"
    fi
    
    echo ""
    exit 1
fi
