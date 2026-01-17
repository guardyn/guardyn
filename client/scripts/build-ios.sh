#!/usr/bin/env bash
# Guardyn iOS Build Script
# Phase 5: Launch Preparation - App Store Submission
#
# This script builds the iOS app for App Store submission.
# Prerequisites:
#   - macOS with Xcode 15+
#   - Flutter SDK installed
#   - Valid Apple Developer account
#   - Code signing certificates configured

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
BUILD_TYPE="${1:-release}"
EXPORT_IPA="${2:-false}"

log_info "Starting iOS build process..."
log_info "Build type: $BUILD_TYPE"

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check OS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script must be run on macOS"
        exit 1
    fi
    
    # Check Xcode
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode is not installed. Please install Xcode from the App Store."
        exit 1
    fi
    
    XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
    log_info "Xcode version: $XCODE_VERSION"
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed. Please install Flutter SDK."
        exit 1
    fi
    
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    log_info "Flutter: $FLUTTER_VERSION"
    
    # Check CocoaPods
    if ! command -v pod &> /dev/null; then
        log_warning "CocoaPods not found. Installing..."
        sudo gem install cocoapods
    fi
    
    log_success "Prerequisites check passed"
}

# Clean previous builds
clean_build() {
    log_info "Cleaning previous builds..."
    
    cd "$CLIENT_DIR"
    flutter clean
    
    cd ios
    rm -rf Pods Podfile.lock
    rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
    
    log_success "Clean completed"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    cd "$CLIENT_DIR"
    flutter pub get
    
    cd ios
    pod install --repo-update
    
    log_success "Dependencies installed"
}

# Build iOS app
build_ios() {
    log_info "Building iOS app..."
    
    cd "$CLIENT_DIR"
    
    # Get version from pubspec.yaml
    VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
    BUILD_NUMBER=$(grep "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)
    
    log_info "Version: $VERSION ($BUILD_NUMBER)"
    
    if [[ "$BUILD_TYPE" == "release" ]]; then
        flutter build ios --release --no-codesign
    else
        flutter build ios --debug
    fi
    
    log_success "iOS build completed"
}

# Archive for App Store
archive_for_appstore() {
    log_info "Creating archive for App Store..."
    
    cd "$CLIENT_DIR/ios"
    
    # Clean build folder
    xcodebuild clean -workspace Runner.xcworkspace -scheme Runner
    
    # Archive
    xcodebuild archive \
        -workspace Runner.xcworkspace \
        -scheme Runner \
        -configuration Release \
        -archivePath "$PROJECT_ROOT/build/ios/Guardyn.xcarchive" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
    
    log_success "Archive created at: $PROJECT_ROOT/build/ios/Guardyn.xcarchive"
    
    if [[ "$EXPORT_IPA" == "true" ]]; then
        log_info "Exporting IPA..."
        
        # Create export options plist
        cat > /tmp/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF
        
        xcodebuild -exportArchive \
            -archivePath "$PROJECT_ROOT/build/ios/Guardyn.xcarchive" \
            -exportOptionsPlist /tmp/ExportOptions.plist \
            -exportPath "$PROJECT_ROOT/build/ios/export"
        
        log_success "IPA exported to: $PROJECT_ROOT/build/ios/export"
    fi
}

# Validate build
validate_build() {
    log_info "Validating build..."
    
    ARCHIVE_PATH="$PROJECT_ROOT/build/ios/Guardyn.xcarchive"
    
    if [[ ! -d "$ARCHIVE_PATH" ]]; then
        log_error "Archive not found at $ARCHIVE_PATH"
        exit 1
    fi
    
    # Check archive contents
    if [[ ! -f "$ARCHIVE_PATH/Info.plist" ]]; then
        log_error "Invalid archive: Info.plist not found"
        exit 1
    fi
    
    log_success "Build validation passed"
}

# Print summary
print_summary() {
    echo ""
    echo "=========================================="
    echo "           BUILD SUMMARY"
    echo "=========================================="
    echo ""
    echo "Build Type: $BUILD_TYPE"
    echo "Archive: $PROJECT_ROOT/build/ios/Guardyn.xcarchive"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode and select the archive"
    echo "2. Click 'Distribute App' → 'App Store Connect'"
    echo "3. Follow the prompts to upload"
    echo ""
    echo "Or use Transporter app to upload the IPA directly."
    echo "=========================================="
}

# Main execution
main() {
    check_prerequisites
    
    if [[ "${CLEAN:-false}" == "true" ]]; then
        clean_build
    fi
    
    install_dependencies
    build_ios
    
    if [[ "$BUILD_TYPE" == "release" ]]; then
        archive_for_appstore
        validate_build
    fi
    
    print_summary
    
    log_success "iOS build completed successfully!"
}

# Run main
main "$@"
