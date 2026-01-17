#!/usr/bin/env bash
# Guardyn Android Build Script
# Phase 5: Launch Preparation - Google Play Submission
#
# This script builds the Android app for Google Play submission.
# Prerequisites:
#   - Android SDK installed
#   - Flutter SDK installed
#   - Release keystore configured

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CLIENT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
BUILD_TYPE="${1:-appbundle}"  # appbundle or apk
BUILD_MODE="${2:-release}"    # release or debug

log_info "Starting Android build process..."
log_info "Build type: $BUILD_TYPE"
log_info "Build mode: $BUILD_MODE"

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed. Please install Flutter SDK."
        exit 1
    fi
    
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    log_info "Flutter: $FLUTTER_VERSION"
    
    # Check Android SDK
    if [[ -z "${ANDROID_HOME:-}" ]] && [[ -z "${ANDROID_SDK_ROOT:-}" ]]; then
        log_warning "ANDROID_HOME/ANDROID_SDK_ROOT not set. Checking common paths..."
        
        if [[ -d "$HOME/Android/Sdk" ]]; then
            export ANDROID_HOME="$HOME/Android/Sdk"
        elif [[ -d "$HOME/Library/Android/sdk" ]]; then
            export ANDROID_HOME="$HOME/Library/Android/sdk"
        else
            log_error "Android SDK not found. Please install Android SDK."
            exit 1
        fi
    fi
    
    log_info "Android SDK: ${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
    
    # Check key.properties for release builds
    if [[ "$BUILD_MODE" == "release" ]]; then
        KEY_PROPERTIES="$CLIENT_DIR/android/key.properties"
        if [[ ! -f "$KEY_PROPERTIES" ]]; then
            log_error "key.properties not found at $KEY_PROPERTIES"
            log_info "Create it with the following content:"
            echo ""
            echo "storePassword=<your-store-password>"
            echo "keyPassword=<your-key-password>"
            echo "keyAlias=guardyn"
            echo "storeFile=<path-to-keystore>"
            echo ""
            exit 1
        fi
        log_success "key.properties found"
    fi
    
    log_success "Prerequisites check passed"
}

# Clean previous builds
clean_build() {
    log_info "Cleaning previous builds..."
    
    cd "$CLIENT_DIR"
    flutter clean
    
    log_success "Clean completed"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    cd "$CLIENT_DIR"
    flutter pub get
    
    log_success "Dependencies installed"
}

# Build Android app
build_android() {
    log_info "Building Android app..."
    
    cd "$CLIENT_DIR"
    
    # Get version from pubspec.yaml
    VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
    BUILD_NUMBER=$(grep "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)
    
    log_info "Version: $VERSION ($BUILD_NUMBER)"
    
    if [[ "$BUILD_TYPE" == "appbundle" ]]; then
        if [[ "$BUILD_MODE" == "release" ]]; then
            flutter build appbundle --release
        else
            flutter build appbundle --debug
        fi
        
        OUTPUT_PATH="$CLIENT_DIR/build/app/outputs/bundle/${BUILD_MODE}/app-${BUILD_MODE}.aab"
    else
        if [[ "$BUILD_MODE" == "release" ]]; then
            flutter build apk --release
        else
            flutter build apk --debug
        fi
        
        OUTPUT_PATH="$CLIENT_DIR/build/app/outputs/flutter-apk/app-${BUILD_MODE}.apk"
    fi
    
    log_success "Android build completed"
    log_info "Output: $OUTPUT_PATH"
}

# Validate build
validate_build() {
    log_info "Validating build..."
    
    if [[ "$BUILD_TYPE" == "appbundle" ]]; then
        OUTPUT_PATH="$CLIENT_DIR/build/app/outputs/bundle/${BUILD_MODE}/app-${BUILD_MODE}.aab"
    else
        OUTPUT_PATH="$CLIENT_DIR/build/app/outputs/flutter-apk/app-${BUILD_MODE}.apk"
    fi
    
    if [[ ! -f "$OUTPUT_PATH" ]]; then
        log_error "Build output not found at $OUTPUT_PATH"
        exit 1
    fi
    
    FILE_SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
    log_info "Build size: $FILE_SIZE"
    
    log_success "Build validation passed"
}

# Copy to dist folder
copy_to_dist() {
    log_info "Copying to dist folder..."
    
    DIST_DIR="$PROJECT_ROOT/dist/android"
    mkdir -p "$DIST_DIR"
    
    # Get version
    VERSION=$(grep "^version:" "$CLIENT_DIR/pubspec.yaml" | awk '{print $2}')
    
    if [[ "$BUILD_TYPE" == "appbundle" ]]; then
        SOURCE="$CLIENT_DIR/build/app/outputs/bundle/${BUILD_MODE}/app-${BUILD_MODE}.aab"
        DEST="$DIST_DIR/guardyn-${VERSION}.aab"
    else
        SOURCE="$CLIENT_DIR/build/app/outputs/flutter-apk/app-${BUILD_MODE}.apk"
        DEST="$DIST_DIR/guardyn-${VERSION}.apk"
    fi
    
    cp "$SOURCE" "$DEST"
    
    log_success "Copied to: $DEST"
}

# Print summary
print_summary() {
    VERSION=$(grep "^version:" "$CLIENT_DIR/pubspec.yaml" | awk '{print $2}')
    
    echo ""
    echo "=========================================="
    echo "           BUILD SUMMARY"
    echo "=========================================="
    echo ""
    echo "Build Type: $BUILD_TYPE"
    echo "Build Mode: $BUILD_MODE"
    echo "Version: $VERSION"
    echo ""
    
    if [[ "$BUILD_TYPE" == "appbundle" ]]; then
        echo "Output: $PROJECT_ROOT/dist/android/guardyn-${VERSION}.aab"
        echo ""
        echo "Next steps:"
        echo "1. Go to Google Play Console"
        echo "2. Select your app → Release → Production"
        echo "3. Upload the .aab file"
        echo "4. Complete release notes and submit"
    else
        echo "Output: $PROJECT_ROOT/dist/android/guardyn-${VERSION}.apk"
        echo ""
        echo "Note: APKs cannot be uploaded to Google Play."
        echo "Use 'appbundle' for Play Store submission."
    fi
    
    echo "=========================================="
}

# Main execution
main() {
    check_prerequisites
    
    if [[ "${CLEAN:-false}" == "true" ]]; then
        clean_build
    fi
    
    install_dependencies
    build_android
    validate_build
    copy_to_dist
    print_summary
    
    log_success "Android build completed successfully!"
}

# Run main
main "$@"
