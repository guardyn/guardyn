#!/usr/bin/env bash
# Guardyn Desktop Build Script
# Phase 5: Launch Preparation - Desktop Distribution
#
# This script builds the Tauri desktop app for Linux distribution.
# Prerequisites:
#   - Rust toolchain
#   - Node.js 18+
#   - Tauri CLI
#   - Linux build dependencies

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$DESKTOP_DIR")"

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
BUILD_TARGET="${1:-linux}"  # linux (windows/macos skipped)
BUILD_MODE="${2:-release}"  # release or debug

log_info "Starting desktop build process..."
log_info "Target: $BUILD_TARGET"
log_info "Mode: $BUILD_MODE"

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Rust
    if ! command -v rustc &> /dev/null; then
        log_error "Rust is not installed. Please install Rust toolchain."
        exit 1
    fi
    
    RUST_VERSION=$(rustc --version)
    log_info "Rust: $RUST_VERSION"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 18+."
        exit 1
    fi
    
    NODE_VERSION=$(node --version)
    log_info "Node.js: $NODE_VERSION"
    
    # Check npm/pnpm
    if command -v pnpm &> /dev/null; then
        PKG_MANAGER="pnpm"
    elif command -v npm &> /dev/null; then
        PKG_MANAGER="npm"
    else
        log_error "Neither npm nor pnpm found."
        exit 1
    fi
    
    log_info "Package manager: $PKG_MANAGER"
    
    # Check Tauri CLI
    if ! command -v cargo-tauri &> /dev/null && ! command -v tauri &> /dev/null; then
        log_warning "Tauri CLI not found. Installing..."
        cargo install tauri-cli
    fi
    
    # Check Linux dependencies
    if [[ "$BUILD_TARGET" == "linux" ]]; then
        check_linux_deps
    fi
    
    log_success "Prerequisites check passed"
}

# Check Linux build dependencies
check_linux_deps() {
    log_info "Checking Linux build dependencies..."
    
    MISSING_DEPS=()
    
    # Check required packages
    if ! pkg-config --exists webkit2gtk-4.1 2>/dev/null; then
        MISSING_DEPS+=("libwebkit2gtk-4.1-dev")
    fi
    
    if ! pkg-config --exists gtk+-3.0 2>/dev/null; then
        MISSING_DEPS+=("libgtk-3-dev")
    fi
    
    if ! pkg-config --exists libayatana-appindicator3-0.1 2>/dev/null; then
        MISSING_DEPS+=("libayatana-appindicator3-dev")
    fi
    
    if ! command -v dpkg-deb &> /dev/null; then
        MISSING_DEPS+=("dpkg-dev")
    fi
    
    if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
        log_warning "Missing dependencies: ${MISSING_DEPS[*]}"
        log_info "Install with: sudo apt install ${MISSING_DEPS[*]}"
        
        if [[ "${AUTO_INSTALL:-false}" == "true" ]]; then
            sudo apt update && sudo apt install -y "${MISSING_DEPS[@]}"
        else
            exit 1
        fi
    fi
    
    log_success "Linux dependencies check passed"
}

# Install JS dependencies
install_dependencies() {
    log_info "Installing JavaScript dependencies..."
    
    cd "$DESKTOP_DIR"
    
    if [[ "$PKG_MANAGER" == "pnpm" ]]; then
        pnpm install
    else
        npm install
    fi
    
    log_success "Dependencies installed"
}

# Build frontend
build_frontend() {
    log_info "Building frontend..."
    
    cd "$DESKTOP_DIR"
    
    if [[ "$PKG_MANAGER" == "pnpm" ]]; then
        pnpm run build
    else
        npm run build
    fi
    
    log_success "Frontend build completed"
}

# Build Tauri app
build_tauri() {
    log_info "Building Tauri application..."
    
    cd "$DESKTOP_DIR"
    
    if [[ "$BUILD_MODE" == "release" ]]; then
        cargo tauri build
    else
        cargo tauri build --debug
    fi
    
    log_success "Tauri build completed"
}

# Get version from Cargo.toml
get_version() {
    grep "^version" "$DESKTOP_DIR/src-tauri/Cargo.toml" | head -n 1 | sed 's/.*"\(.*\)".*/\1/'
}

# Copy to dist folder
copy_to_dist() {
    log_info "Copying to dist folder..."
    
    VERSION=$(get_version)
    DIST_DIR="$PROJECT_ROOT/dist/desktop/$BUILD_TARGET"
    mkdir -p "$DIST_DIR"
    
    # Linux outputs
    if [[ "$BUILD_TARGET" == "linux" ]]; then
        BUNDLE_DIR="$DESKTOP_DIR/src-tauri/target/release/bundle"
        
        # Copy .deb package
        if [[ -f "$BUNDLE_DIR/deb/guardyn_${VERSION}_amd64.deb" ]]; then
            cp "$BUNDLE_DIR/deb/guardyn_${VERSION}_amd64.deb" "$DIST_DIR/"
            log_info "Copied: guardyn_${VERSION}_amd64.deb"
        fi
        
        # Copy .AppImage
        APPIMAGE=$(find "$BUNDLE_DIR/appimage" -name "*.AppImage" 2>/dev/null | head -n 1 || true)
        if [[ -n "$APPIMAGE" && -f "$APPIMAGE" ]]; then
            cp "$APPIMAGE" "$DIST_DIR/guardyn-${VERSION}.AppImage"
            log_info "Copied: guardyn-${VERSION}.AppImage"
        fi
        
        # Copy .rpm if exists
        if [[ -f "$BUNDLE_DIR/rpm/guardyn-${VERSION}-1.x86_64.rpm" ]]; then
            cp "$BUNDLE_DIR/rpm/guardyn-${VERSION}-1.x86_64.rpm" "$DIST_DIR/"
            log_info "Copied: guardyn-${VERSION}-1.x86_64.rpm"
        fi
    fi
    
    log_success "Distribution files copied to: $DIST_DIR"
}

# Generate checksums
generate_checksums() {
    log_info "Generating checksums..."
    
    VERSION=$(get_version)
    DIST_DIR="$PROJECT_ROOT/dist/desktop/$BUILD_TARGET"
    
    cd "$DIST_DIR"
    
    # Generate SHA256 checksums
    sha256sum guardyn* > SHA256SUMS.txt 2>/dev/null || true
    
    if [[ -f "SHA256SUMS.txt" ]]; then
        log_success "Checksums generated: SHA256SUMS.txt"
        cat SHA256SUMS.txt
    fi
}

# Sign packages (optional)
sign_packages() {
    log_info "Signing packages..."
    
    # Check for GPG key
    if ! gpg --list-secret-keys "guardyn" &>/dev/null; then
        log_warning "No GPG key found for signing. Skipping..."
        return
    fi
    
    DIST_DIR="$PROJECT_ROOT/dist/desktop/$BUILD_TARGET"
    
    cd "$DIST_DIR"
    
    # Sign checksums file
    gpg --armor --detach-sign SHA256SUMS.txt
    
    log_success "Packages signed"
}

# Print summary
print_summary() {
    VERSION=$(get_version)
    DIST_DIR="$PROJECT_ROOT/dist/desktop/$BUILD_TARGET"
    
    echo ""
    echo "=========================================="
    echo "           BUILD SUMMARY"
    echo "=========================================="
    echo ""
    echo "Target: $BUILD_TARGET"
    echo "Mode: $BUILD_MODE"
    echo "Version: $VERSION"
    echo ""
    echo "Output directory: $DIST_DIR"
    echo ""
    echo "Generated files:"
    ls -lh "$DIST_DIR" 2>/dev/null || echo "  (no files)"
    echo ""
    echo "Distribution methods:"
    echo "1. .deb - For Debian/Ubuntu: dpkg -i guardyn_${VERSION}_amd64.deb"
    echo "2. .AppImage - Universal: ./guardyn-${VERSION}.AppImage"
    echo "3. .rpm - For Fedora/RHEL: rpm -i guardyn-${VERSION}-1.x86_64.rpm"
    echo ""
    echo "=========================================="
}

# Main execution
main() {
    check_prerequisites
    
    if [[ "${CLEAN:-false}" == "true" ]]; then
        log_info "Cleaning previous builds..."
        cd "$DESKTOP_DIR"
        rm -rf node_modules dist
        cd src-tauri && cargo clean
    fi
    
    install_dependencies
    build_frontend
    build_tauri
    copy_to_dist
    generate_checksums
    
    if [[ "${SIGN:-false}" == "true" ]]; then
        sign_packages
    fi
    
    print_summary
    
    log_success "Desktop build completed successfully!"
}

# Run main
main "$@"
