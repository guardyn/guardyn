#!/usr/bin/env bash
# Mobile FFI Integration Test Runner
#
# This script builds native crypto libraries and runs integration tests
# on connected mobile devices.
#
# Usage:
#   ./run-mobile-ffi-tests.sh android    # Test on Android device
#   ./run-mobile-ffi-tests.sh ios        # Test on iOS device
#   ./run-mobile-ffi-tests.sh all        # Test on all connected devices
#   ./run-mobile-ffi-tests.sh list       # List available devices

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."
CLIENT_MOBILE="$PROJECT_ROOT/client-mobile"
CRYPTO_FFI="$PROJECT_ROOT/backend/crates/crypto-ffi"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not found. Please install Flutter SDK."
        exit 1
    fi
    
    if ! command -v cargo &> /dev/null; then
        log_error "Cargo not found. Please install Rust."
        exit 1
    fi
    
    log_info "Prerequisites OK"
}

# List available devices
list_devices() {
    log_step "Available devices:"
    flutter devices
}

# Build Android libraries
build_android() {
    log_step "Building native crypto library for Android..."
    
    cd "$CRYPTO_FFI"
    ./build-mobile.sh android
    
    # Verify libraries exist
    local NATIVE_DIR="$CLIENT_MOBILE/native/android"
    
    if [ ! -f "$NATIVE_DIR/arm64-v8a/libguardyn_crypto_ffi.so" ]; then
        log_error "Android arm64-v8a library not found!"
        exit 1
    fi
    
    log_info "Android libraries built successfully"
    log_info "  - arm64-v8a: $(ls -lh "$NATIVE_DIR/arm64-v8a/libguardyn_crypto_ffi.so" | awk '{print $5}')"
    log_info "  - armeabi-v7a: $(ls -lh "$NATIVE_DIR/armeabi-v7a/libguardyn_crypto_ffi.so" | awk '{print $5}')"
    log_info "  - x86_64: $(ls -lh "$NATIVE_DIR/x86_64/libguardyn_crypto_ffi.so" | awk '{print $5}')"
}

# Build iOS libraries
build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warn "iOS builds require macOS. Skipping."
        return 1
    fi
    
    log_step "Building native crypto library for iOS..."
    
    cd "$CRYPTO_FFI"
    ./build-mobile.sh ios
    
    # Verify XCFramework exists
    local IOS_DIR="$CLIENT_MOBILE/native/ios"
    
    if [ ! -d "$IOS_DIR/GuardynCrypto.xcframework" ]; then
        log_error "iOS XCFramework not found!"
        exit 1
    fi
    
    log_info "iOS libraries built successfully"
}

# Copy Android libraries to jniLibs
setup_android_jni() {
    log_step "Setting up Android JNI libraries..."
    
    local NATIVE_DIR="$CLIENT_MOBILE/native/android"
    local JNI_DIR="$CLIENT_MOBILE/android/app/src/main/jniLibs"
    
    # Create jniLibs directory structure
    mkdir -p "$JNI_DIR/arm64-v8a"
    mkdir -p "$JNI_DIR/armeabi-v7a"
    mkdir -p "$JNI_DIR/x86_64"
    
    # Copy libraries
    cp "$NATIVE_DIR/arm64-v8a/libguardyn_crypto_ffi.so" "$JNI_DIR/arm64-v8a/"
    cp "$NATIVE_DIR/armeabi-v7a/libguardyn_crypto_ffi.so" "$JNI_DIR/armeabi-v7a/"
    cp "$NATIVE_DIR/x86_64/libguardyn_crypto_ffi.so" "$JNI_DIR/x86_64/"
    
    log_info "JNI libraries copied to Android project"
}

# Run tests on Android
test_android() {
    local device_id="${1:-}"
    
    log_step "Running FFI integration tests on Android..."
    
    cd "$CLIENT_MOBILE"
    
    # Get first Android device if not specified
    if [ -z "$device_id" ]; then
        # Extract device ID from flutter devices output
        # Format: "Name (type) • device-id • platform • OS"
        # Example: "sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 16"
        device_id=$(flutter devices 2>/dev/null | grep -i android | head -1 | awk -F'•' '{print $2}' | xargs)
        if [ -z "$device_id" ]; then
            log_error "No Android device found. Connect a device or start an emulator."
            exit 1
        fi
    fi
    
    log_info "Testing on device: $device_id"

    
    flutter test integration_test/crypto/rust_ffi_test.dart \
        -d "$device_id" \
        --reporter expanded \
        2>&1 | tee /tmp/android_ffi_test.log
    
    local exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -eq 0 ]; then
        log_info "✅ Android FFI tests PASSED"
    else
        log_error "❌ Android FFI tests FAILED"
        log_info "See logs at /tmp/android_ffi_test.log"
    fi
    
    return $exit_code
}

# Run tests on iOS
test_ios() {
    local device_id="${1:-}"
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warn "iOS tests require macOS. Skipping."
        return 1
    fi
    
    log_step "Running FFI integration tests on iOS..."
    
    cd "$CLIENT_MOBILE"
    
    # Get first iOS device if not specified
    if [ -z "$device_id" ]; then
        device_id=$(flutter devices | grep -E 'iphone|ipad|ios' -i | head -1 | awk '{print $2}' | tr -d '•')
        if [ -z "$device_id" ]; then
            log_error "No iOS device found. Connect a device or start a simulator."
            exit 1
        fi
    fi
    
    log_info "Testing on device: $device_id"
    
    flutter test integration_test/crypto/rust_ffi_test.dart \
        -d "$device_id" \
        --reporter expanded \
        2>&1 | tee /tmp/ios_ffi_test.log
    
    local exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -eq 0 ]; then
        log_info "✅ iOS FFI tests PASSED"
    else
        log_error "❌ iOS FFI tests FAILED"
        log_info "See logs at /tmp/ios_ffi_test.log"
    fi
    
    return $exit_code
}

# Generate test report
generate_report() {
    local platform="$1"
    local log_file="/tmp/${platform}_ffi_test.log"
    local report_file="$CLIENT_MOBILE/test-reports/ffi_${platform}_$(date +%Y%m%d_%H%M%S).md"
    
    mkdir -p "$CLIENT_MOBILE/test-reports"
    
    cat > "$report_file" << EOF
# FFI Integration Test Report

**Platform:** $platform  
**Date:** $(date -Iseconds)  
**Device:** $(flutter devices | grep -i "$platform" | head -1)

## Test Results

\`\`\`
$(tail -50 "$log_file" 2>/dev/null || echo "No log available")
\`\`\`

## Summary

$(grep -E '(PASSED|FAILED|✅|❌|tests passed|tests failed)' "$log_file" 2>/dev/null || echo "No summary available")
EOF

    log_info "Report saved: $report_file"
}

# Print usage
usage() {
    echo "Usage: $0 <command> [device-id]"
    echo ""
    echo "Commands:"
    echo "  list       List available devices"
    echo "  android    Build and test on Android device"
    echo "  ios        Build and test on iOS device (macOS only)"
    echo "  all        Build and test on all connected devices"
    echo "  build      Build libraries only (no tests)"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 android"
    echo "  $0 android emulator-5554"
    echo "  $0 ios"
    echo "  $0 all"
}

# Main
main() {
    local command="${1:-help}"
    local device_id="${2:-}"
    
    check_prerequisites
    
    case "$command" in
        list)
            list_devices
            ;;
        android)
            build_android
            setup_android_jni
            test_android "$device_id"
            generate_report "android"
            ;;
        ios)
            build_ios
            test_ios "$device_id"
            generate_report "ios"
            ;;
        all)
            local android_result=0
            local ios_result=0
            
            # Android
            if flutter devices | grep -qi android; then
                build_android
                setup_android_jni
                test_android || android_result=$?
                generate_report "android"
            else
                log_warn "No Android device found, skipping"
            fi
            
            # iOS
            if [[ "$OSTYPE" == "darwin"* ]] && flutter devices | grep -qiE 'iphone|ipad|ios'; then
                build_ios
                test_ios || ios_result=$?
                generate_report "ios"
            else
                log_warn "No iOS device found or not on macOS, skipping"
            fi
            
            # Summary
            echo ""
            log_step "Test Summary:"
            if [ $android_result -eq 0 ]; then
                log_info "  Android: ✅ PASSED"
            else
                log_error "  Android: ❌ FAILED"
            fi
            if [ $ios_result -eq 0 ]; then
                log_info "  iOS: ✅ PASSED"
            else
                log_error "  iOS: ❌ FAILED"
            fi
            
            [ $android_result -eq 0 ] && [ $ios_result -eq 0 ]
            ;;
        build)
            build_android || true
            build_ios || true
            log_info "Build complete (run 'list' to see devices for testing)"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
