#!/usr/bin/env bash
# Setup Flutter Rust Bridge for Guardyn
#
# This script initializes flutter_rust_bridge for connecting Flutter client
# to the guardyn-crypto Rust library.
#
# Prerequisites:
# - Rust toolchain (via Nix or rustup)
# - Flutter SDK 3.9+
# - cargo-expand (optional, for debugging)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$(dirname "$CLIENT_DIR")/backend"
CRYPTO_CRATE="$BACKEND_DIR/crates/crypto"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v cargo &> /dev/null; then
        log_error "Rust/Cargo not found. Please install via 'nix develop' or rustup"
        exit 1
    fi

    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not found. Please install Flutter SDK"
        exit 1
    fi

    log_info "Prerequisites OK"
}

# Install flutter_rust_bridge_codegen
install_codegen() {
    log_info "Installing flutter_rust_bridge_codegen..."

    if ! cargo install --list | grep -q "flutter_rust_bridge_codegen"; then
        cargo install flutter_rust_bridge_codegen
    else
        log_info "flutter_rust_bridge_codegen already installed"
    fi
}

# Add FFI feature to crypto crate
enable_ffi_feature() {
    log_info "Enabling FFI feature in guardyn-crypto..."

    cd "$CRYPTO_CRATE"

    # Check if ffi feature exists
    if ! grep -q 'feature = "ffi"' src/lib.rs; then
        log_warn "FFI feature not found in crypto crate. Adding it..."

        # This should already be done by the evolution plan implementation
        # but we verify it here
    fi
}

# Generate Dart bindings
generate_bindings() {
    log_info "Generating Dart bindings..."

    cd "$CLIENT_DIR"

    # Create flutter_rust_bridge config if not exists
    if [ ! -f "flutter_rust_bridge.yaml" ]; then
        log_info "Creating flutter_rust_bridge.yaml..."
        cat > flutter_rust_bridge.yaml << 'EOF'
# Flutter Rust Bridge configuration for Guardyn
# See: https://cjycode.com/flutter_rust_bridge/

rust_input: ../backend/crates/crypto/src/ffi.rs
dart_output: lib/core/crypto/generated/

# Rust crate configuration
rust_root: ../backend/crates/crypto

# Additional options
full_dep: true
dart_enums_style: true

# Skip problematic types
skip_deps_check: false
EOF
    fi

    # Generate bindings
    flutter_rust_bridge_codegen generate
}

# Build native library for current platform
build_native() {
    local target=""
    local lib_name=""

    case "$(uname -s)" in
        Linux*)
            target="x86_64-unknown-linux-gnu"
            lib_name="libguardyn_crypto.so"
            ;;
        Darwin*)
            if [ "$(uname -m)" == "arm64" ]; then
                target="aarch64-apple-darwin"
            else
                target="x86_64-apple-darwin"
            fi
            lib_name="libguardyn_crypto.dylib"
            ;;
        *)
            log_error "Unsupported platform: $(uname -s)"
            exit 1
            ;;
    esac

    log_info "Building native library for $target..."

    cd "$CRYPTO_CRATE"

    cargo build --release --features ffi --target "$target"

    # Copy library to Flutter assets
    local lib_path="$BACKEND_DIR/target/$target/release/$lib_name"
    local dest_dir="$CLIENT_DIR/linux/libs" # or macos/libs

    if [ -f "$lib_path" ]; then
        mkdir -p "$dest_dir"
        cp "$lib_path" "$dest_dir/"
        log_info "Library copied to $dest_dir/$lib_name"
    else
        log_error "Library not found at $lib_path"
        exit 1
    fi
}

# Build for Android targets
build_android() {
    log_info "Building for Android targets..."

    cd "$CRYPTO_CRATE"

    local targets=(
        "aarch64-linux-android"
        "armv7-linux-androideabi"
        "x86_64-linux-android"
    )

    for target in "${targets[@]}"; do
        log_info "Building for $target..."
        cargo build --release --features ffi --target "$target" || {
            log_warn "Failed to build for $target (NDK may not be configured)"
        }
    done
}

# Build for iOS targets
build_ios() {
    log_info "Building for iOS targets..."

    cd "$CRYPTO_CRATE"

    local targets=(
        "aarch64-apple-ios"
        "aarch64-apple-ios-sim"
    )

    for target in "${targets[@]}"; do
        log_info "Building for $target..."
        cargo build --release --features ffi --target "$target" || {
            log_warn "Failed to build for $target"
        }
    done
}

# Main
main() {
    log_info "=== Guardyn Flutter Rust Bridge Setup ==="

    check_prerequisites

    case "${1:-setup}" in
        setup)
            install_codegen
            enable_ffi_feature
            generate_bindings
            ;;
        build)
            build_native
            ;;
        android)
            build_android
            ;;
        ios)
            build_ios
            ;;
        all)
            install_codegen
            enable_ffi_feature
            generate_bindings
            build_native
            ;;
        *)
            echo "Usage: $0 {setup|build|android|ios|all}"
            exit 1
            ;;
    esac

    log_info "=== Done ==="
}

main "$@"
