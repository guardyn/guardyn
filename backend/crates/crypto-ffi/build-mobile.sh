#!/usr/bin/env bash
# Build guardyn-crypto-ffi for all mobile platforms
#
# This script compiles the Rust crypto library for:
# - Android (arm64-v8a, armeabi-v7a, x86_64)
# - iOS (arm64, simulator)
#
# Prerequisites:
# - Rust with cross-compilation targets installed
# - Android NDK
# - Xcode (for iOS, macOS only)
#
# Usage:
#   ./build-mobile.sh          # Build all platforms
#   ./build-mobile.sh android  # Build Android only
#   ./build-mobile.sh ios      # Build iOS only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRATE_DIR="$SCRIPT_DIR"
BACKEND_DIR="$SCRIPT_DIR/../.."
CLIENT_MOBILE_DIR="$SCRIPT_DIR/../../../client-mobile"
NATIVE_DIR="$CLIENT_MOBILE_DIR/native"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v cargo &> /dev/null; then
        log_error "cargo not found. Please install Rust."
        exit 1
    fi
    
    if ! command -v rustup &> /dev/null; then
        log_error "rustup not found. Please install rustup."
        exit 1
    fi
}

# Install Rust targets
install_targets() {
    log_info "Installing Rust cross-compilation targets..."
    
    # Android targets
    rustup target add aarch64-linux-android  # arm64-v8a
    rustup target add armv7-linux-androideabi # armeabi-v7a
    rustup target add x86_64-linux-android    # x86_64 (emulator)
    
    # iOS targets
    if [[ "$OSTYPE" == "darwin"* ]]; then
        rustup target add aarch64-apple-ios         # iOS device
        rustup target add aarch64-apple-ios-sim     # iOS simulator (M1/M2)
        rustup target add x86_64-apple-ios          # iOS simulator (Intel)
    fi
}

# Build for Android
build_android() {
    log_info "Building for Android..."
    
    # Check for Android NDK
    if [ -z "${ANDROID_NDK_HOME:-}" ]; then
        # Try common locations
        if [ -d "$HOME/Android/Sdk/ndk" ]; then
            ANDROID_NDK_HOME=$(ls -d "$HOME/Android/Sdk/ndk"/*/ 2>/dev/null | tail -1)
        elif [ -d "$HOME/Library/Android/sdk/ndk" ]; then
            ANDROID_NDK_HOME=$(ls -d "$HOME/Library/Android/sdk/ndk"/*/ 2>/dev/null | tail -1)
        fi
    fi
    
    if [ -z "${ANDROID_NDK_HOME:-}" ]; then
        log_error "ANDROID_NDK_HOME not set and NDK not found."
        log_error "Please set ANDROID_NDK_HOME or install Android NDK."
        exit 1
    fi
    
    log_info "Using Android NDK: $ANDROID_NDK_HOME"
    
    local TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
    
    # Create cargo config for Android
    mkdir -p "$BACKEND_DIR/.cargo"
    cat > "$BACKEND_DIR/.cargo/config.toml" << EOF
[target.aarch64-linux-android]
linker = "${TOOLCHAIN}/bin/aarch64-linux-android24-clang"
ar = "${TOOLCHAIN}/bin/llvm-ar"

[target.armv7-linux-androideabi]
linker = "${TOOLCHAIN}/bin/armv7a-linux-androideabi24-clang"
ar = "${TOOLCHAIN}/bin/llvm-ar"

[target.x86_64-linux-android]
linker = "${TOOLCHAIN}/bin/x86_64-linux-android24-clang"
ar = "${TOOLCHAIN}/bin/llvm-ar"
EOF
    
    # Build for each Android architecture
    local targets=(
        "aarch64-linux-android:arm64-v8a"
        "armv7-linux-androideabi:armeabi-v7a"
        "x86_64-linux-android:x86_64"
    )
    
    for target_info in "${targets[@]}"; do
        IFS=':' read -r target arch <<< "$target_info"
        log_info "Building for Android $arch ($target)..."
        
        cd "$BACKEND_DIR"
        
        # Set CC and AR environment variables for ring crate
        local CC_VAR
        case "$target" in
            aarch64-linux-android)
                CC_VAR="aarch64-linux-android24-clang"
                ;;
            armv7-linux-androideabi)
                CC_VAR="armv7a-linux-androideabi24-clang"
                ;;
            x86_64-linux-android)
                CC_VAR="x86_64-linux-android24-clang"
                ;;
        esac
        
        CC="${TOOLCHAIN}/bin/${CC_VAR}" \
        AR="${TOOLCHAIN}/bin/llvm-ar" \
        cargo build --release --target "$target" -p guardyn-crypto-ffi --features full
        
        cd "$CRATE_DIR"
        
        # Copy to Flutter project
        mkdir -p "$NATIVE_DIR/android/$arch"
        cp "$BACKEND_DIR/target/$target/release/libguardyn_crypto_ffi.so" \
           "$NATIVE_DIR/android/$arch/"
    done
    
    log_info "Android build complete!"
}

# Build for iOS
build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warn "iOS builds require macOS. Skipping iOS build."
        return
    fi
    
    log_info "Building for iOS..."
    
    cd "$BACKEND_DIR"
    
    # Build for device (arm64)
    log_info "Building for iOS device (arm64)..."
    cargo build --release --target aarch64-apple-ios -p guardyn-crypto-ffi --features full
    
    # Build for simulator
    log_info "Building for iOS simulator..."
    cargo build --release --target aarch64-apple-ios-sim -p guardyn-crypto-ffi --features full
    cargo build --release --target x86_64-apple-ios -p guardyn-crypto-ffi --features full
    
    cd "$CRATE_DIR"
    
    # Create XCFramework
    log_info "Creating XCFramework..."
    
    local IOS_OUTPUT="$NATIVE_DIR/ios"
    mkdir -p "$IOS_OUTPUT"
    
    # Create fat library for simulator (combines arm64 and x86_64)
    mkdir -p "$IOS_OUTPUT/simulator"
    lipo -create \
        "$BACKEND_DIR/target/aarch64-apple-ios-sim/release/libguardyn_crypto_ffi.a" \
        "$BACKEND_DIR/target/x86_64-apple-ios/release/libguardyn_crypto_ffi.a" \
        -output "$IOS_OUTPUT/simulator/libguardyn_crypto_ffi.a"
    
    # Copy device library
    mkdir -p "$IOS_OUTPUT/device"
    cp "$BACKEND_DIR/target/aarch64-apple-ios/release/libguardyn_crypto_ffi.a" \
       "$IOS_OUTPUT/device/"
    
    # Create XCFramework
    rm -rf "$IOS_OUTPUT/GuardynCrypto.xcframework"
    xcodebuild -create-xcframework \
        -library "$IOS_OUTPUT/device/libguardyn_crypto_ffi.a" \
        -library "$IOS_OUTPUT/simulator/libguardyn_crypto_ffi.a" \
        -output "$IOS_OUTPUT/GuardynCrypto.xcframework"
    
    log_info "iOS build complete!"
}

# Build for current desktop platform (for development/testing)
build_desktop() {
    log_info "Building for current desktop platform..."
    
    cd "$BACKEND_DIR"
    cargo build --release -p guardyn-crypto-ffi --features full
    cd "$CRATE_DIR"
    
    local LIB_NAME
    local LIB_EXT
    local OS_DIR
    
    case "$OSTYPE" in
        linux*)
            LIB_NAME="libguardyn_crypto_ffi"
            LIB_EXT="so"
            OS_DIR="linux"
            ;;
        darwin*)
            LIB_NAME="libguardyn_crypto_ffi"
            LIB_EXT="dylib"
            OS_DIR="macos"
            ;;
        msys*|cygwin*|win*)
            LIB_NAME="guardyn_crypto_ffi"
            LIB_EXT="dll"
            OS_DIR="windows"
            ;;
        *)
            log_error "Unsupported OS: $OSTYPE"
            exit 1
            ;;
    esac
    
    mkdir -p "$NATIVE_DIR/$OS_DIR"
    cp "$BACKEND_DIR/target/release/${LIB_NAME}.${LIB_EXT}" "$NATIVE_DIR/$OS_DIR/"
    
    log_info "Desktop build complete!"
}

# Generate Dart bindings
generate_bindings() {
    log_info "Generating Dart bindings with flutter_rust_bridge..."
    
    if ! command -v flutter_rust_bridge_codegen &> /dev/null; then
        log_info "Installing flutter_rust_bridge_codegen..."
        cargo install flutter_rust_bridge_codegen
    fi
    
    cd "$CRATE_DIR"
    flutter_rust_bridge_codegen generate
    
    log_info "Dart bindings generated!"
}

# Main
main() {
    check_prerequisites
    
    local BUILD_TARGET="${1:-all}"
    
    case "$BUILD_TARGET" in
        android)
            install_targets
            build_android
            ;;
        ios)
            install_targets
            build_ios
            ;;
        desktop)
            build_desktop
            ;;
        generate)
            generate_bindings
            ;;
        all)
            install_targets
            build_android
            build_ios
            build_desktop
            generate_bindings
            ;;
        *)
            echo "Usage: $0 [android|ios|desktop|generate|all]"
            exit 1
            ;;
    esac
    
    log_info "Build completed successfully!"
}

main "$@"
