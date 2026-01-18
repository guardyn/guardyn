#!/usr/bin/env bash
# Build and integrate Rust crypto FFI into Flutter project
#
# This script:
# 1. Builds the Rust library for target platforms
# 2. Generates Dart bindings with flutter_rust_bridge
# 3. Copies libraries to correct Flutter locations
#
# Usage:
#   ./scripts/build-native-crypto.sh          # Build all
#   ./scripts/build-native-crypto.sh android  # Android only
#   ./scripts/build-native-crypto.sh ios      # iOS only
#   ./scripts/build-native-crypto.sh generate # Generate bindings only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
CRYPTO_FFI_DIR="$PROJECT_ROOT/../backend/crates/crypto-ffi"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v cargo &> /dev/null; then
        log_error "Rust not installed. Please install from https://rustup.rs"
        exit 1
    fi

    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not installed."
        exit 1
    fi
}

build_rust() {
    local target="${1:-all}"

    log_info "Building Rust crypto library..."

    if [ ! -f "$CRYPTO_FFI_DIR/build-mobile.sh" ]; then
        log_error "build-mobile.sh not found in $CRYPTO_FFI_DIR"
        exit 1
    fi

    cd "$CRYPTO_FFI_DIR"
    ./build-mobile.sh "$target"
}

generate_bindings() {
    log_info "Generating Dart bindings..."

    # Install flutter_rust_bridge_codegen if not present
    if ! command -v flutter_rust_bridge_codegen &> /dev/null; then
        log_info "Installing flutter_rust_bridge_codegen..."
        cargo install flutter_rust_bridge_codegen
    fi

    cd "$CRYPTO_FFI_DIR"
    flutter_rust_bridge_codegen generate

    log_info "Dart bindings generated in $PROJECT_ROOT/lib/generated/rust/"
}

setup_android() {
    log_info "Setting up Android native libraries..."

    local JNI_DIR="$PROJECT_ROOT/android/app/src/main/jniLibs"
    local NATIVE_DIR="$PROJECT_ROOT/native/android"

    # Create jniLibs directory structure
    mkdir -p "$JNI_DIR/arm64-v8a"
    mkdir -p "$JNI_DIR/armeabi-v7a"
    mkdir -p "$JNI_DIR/x86_64"

    # Copy libraries if they exist
    if [ -d "$NATIVE_DIR" ]; then
        for arch in arm64-v8a armeabi-v7a x86_64; do
            if [ -f "$NATIVE_DIR/$arch/libguardyn_crypto_ffi.so" ]; then
                cp "$NATIVE_DIR/$arch/libguardyn_crypto_ffi.so" "$JNI_DIR/$arch/"
                log_info "Copied $arch library"
            else
                log_warn "Library not found for $arch"
            fi
        done
    else
        log_warn "Android native libraries not found. Run build first."
    fi
}

setup_ios() {
    log_info "Setting up iOS native libraries..."

    local NATIVE_DIR="$PROJECT_ROOT/native/ios"
    local XCFRAMEWORK="$NATIVE_DIR/GuardynCrypto.xcframework"

    if [ -d "$XCFRAMEWORK" ]; then
        # Copy to ios directory
        cp -r "$XCFRAMEWORK" "$PROJECT_ROOT/ios/"
        log_info "Copied XCFramework to ios/"
    else
        log_warn "iOS XCFramework not found. Run build on macOS."
    fi
}

update_flutter() {
    log_info "Updating Flutter dependencies..."

    cd "$PROJECT_ROOT"
    flutter pub get
}

main() {
    local cmd="${1:-all}"

    check_prerequisites

    case "$cmd" in
        android)
            build_rust android
            setup_android
            ;;
        ios)
            build_rust ios
            setup_ios
            ;;
        generate)
            generate_bindings
            update_flutter
            ;;
        desktop)
            build_rust desktop
            ;;
        all)
            build_rust all
            setup_android
            setup_ios
            generate_bindings
            update_flutter
            ;;
        *)
            echo "Usage: $0 [android|ios|desktop|generate|all]"
            exit 1
            ;;
    esac

    log_info "Done!"
}

main "$@"
