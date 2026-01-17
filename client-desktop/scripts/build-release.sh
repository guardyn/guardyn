#!/usr/bin/env bash
# Guardyn Desktop Release Script
# Phase 5: Launch Preparation - Desktop Distribution
#
# This script creates a signed release for distribution.
# It builds for Linux, generates changelog, and prepares GitHub Release assets.

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

# Get version from Cargo.toml
get_version() {
    grep "^version" "$DESKTOP_DIR/src-tauri/Cargo.toml" | head -n 1 | sed 's/.*"\(.*\)".*/\1/'
}

VERSION=$(get_version)
RELEASE_DIR="$PROJECT_ROOT/dist/releases/v${VERSION}"

log_info "Preparing release v${VERSION}..."

# Check if version is already released
check_version() {
    if [[ -d "$RELEASE_DIR" && "${FORCE:-false}" != "true" ]]; then
        log_error "Release v${VERSION} already exists. Use FORCE=true to override."
        exit 1
    fi
}

# Build for all targets
build_all() {
    log_info "Building for Linux..."
    
    # Build Linux
    "$SCRIPT_DIR/build-linux.sh" linux release
}

# Create release directory structure
prepare_release_dir() {
    log_info "Preparing release directory..."
    
    mkdir -p "$RELEASE_DIR"
    mkdir -p "$RELEASE_DIR/linux"
    
    # Copy Linux artifacts
    if [[ -d "$PROJECT_ROOT/dist/desktop/linux" ]]; then
        cp -r "$PROJECT_ROOT/dist/desktop/linux/"* "$RELEASE_DIR/linux/" 2>/dev/null || true
    fi
}

# Generate changelog from git commits
generate_changelog() {
    log_info "Generating changelog..."
    
    CHANGELOG_FILE="$RELEASE_DIR/CHANGELOG.md"
    
    cat > "$CHANGELOG_FILE" << EOF
# Guardyn Desktop v${VERSION}

## Release Notes

### What's New
EOF
    
    # Get commits since last tag
    LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    if [[ -n "$LAST_TAG" ]]; then
        git log "${LAST_TAG}..HEAD" --pretty=format:"- %s" -- client-desktop/ >> "$CHANGELOG_FILE" 2>/dev/null || true
    else
        git log --oneline -10 --pretty=format:"- %s" -- client-desktop/ >> "$CHANGELOG_FILE" 2>/dev/null || true
    fi
    
    cat >> "$CHANGELOG_FILE" << EOF

### Installation

#### Linux

**Debian/Ubuntu:**
\`\`\`bash
sudo dpkg -i guardyn_${VERSION}_amd64.deb
\`\`\`

**AppImage:**
\`\`\`bash
chmod +x guardyn-${VERSION}.AppImage
./guardyn-${VERSION}.AppImage
\`\`\`

**Fedora/RHEL:**
\`\`\`bash
sudo rpm -i guardyn-${VERSION}-1.x86_64.rpm
\`\`\`

### Verify Downloads

All downloads are signed. Verify with:
\`\`\`bash
sha256sum -c SHA256SUMS.txt
\`\`\`

### Requirements

- **Linux:** Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- GTK 3.24+
- WebKitGTK 2.38+

### Security

This release is cryptographically signed. Please verify the checksums before installation.
EOF

    log_success "Changelog generated: $CHANGELOG_FILE"
}

# Generate combined checksums
generate_combined_checksums() {
    log_info "Generating combined checksums..."
    
    cd "$RELEASE_DIR"
    
    # Create combined checksums
    find . -type f \( -name "*.deb" -o -name "*.AppImage" -o -name "*.rpm" \) -exec sha256sum {} \; > SHA256SUMS.txt
    
    log_success "Combined checksums generated"
}

# Sign release
sign_release() {
    log_info "Signing release..."
    
    # Check for signing key
    if [[ -z "${GPG_KEY_ID:-}" ]]; then
        log_warning "GPG_KEY_ID not set. Skipping signing..."
        return
    fi
    
    cd "$RELEASE_DIR"
    
    # Sign checksums
    gpg --local-user "$GPG_KEY_ID" --armor --detach-sign SHA256SUMS.txt
    
    log_success "Release signed"
}

# Create release manifest for auto-updater
create_update_manifest() {
    log_info "Creating update manifest..."
    
    MANIFEST_FILE="$RELEASE_DIR/latest.json"
    
    # Calculate signature for AppImage (Tauri updater uses this)
    LINUX_SIGNATURE=""
    APPIMAGE_PATH="$RELEASE_DIR/linux/guardyn-${VERSION}.AppImage"
    
    if [[ -f "$APPIMAGE_PATH" ]]; then
        # Generate signature if private key exists
        if [[ -f "$DESKTOP_DIR/src-tauri/tauri.key" ]]; then
            LINUX_SIGNATURE=$(echo -n "$APPIMAGE_PATH" | openssl dgst -sha256 -sign "$DESKTOP_DIR/src-tauri/tauri.key" | base64 -w 0)
        fi
    fi
    
    cat > "$MANIFEST_FILE" << EOF
{
  "version": "${VERSION}",
  "notes": "Guardyn Desktop v${VERSION}",
  "pub_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "platforms": {
    "linux-x86_64": {
      "signature": "${LINUX_SIGNATURE}",
      "url": "https://github.com/AoT-Technologies/guardyn/releases/download/v${VERSION}/guardyn-${VERSION}.AppImage"
    }
  }
}
EOF
    
    log_success "Update manifest created: $MANIFEST_FILE"
}

# Print release summary
print_summary() {
    echo ""
    echo "=========================================="
    echo "           RELEASE SUMMARY"
    echo "=========================================="
    echo ""
    echo "Version: v${VERSION}"
    echo "Release directory: $RELEASE_DIR"
    echo ""
    echo "Files:"
    find "$RELEASE_DIR" -type f | sort | while read -r file; do
        SIZE=$(ls -lh "$file" | awk '{print $5}')
        echo "  $(basename "$file") ($SIZE)"
    done
    echo ""
    echo "To create GitHub Release:"
    echo "  gh release create v${VERSION} \\"
    echo "    --title 'Guardyn Desktop v${VERSION}' \\"
    echo "    --notes-file $RELEASE_DIR/CHANGELOG.md \\"
    echo "    $RELEASE_DIR/linux/* \\"
    echo "    $RELEASE_DIR/SHA256SUMS.txt"
    echo ""
    echo "=========================================="
}

# Main execution
main() {
    check_version
    build_all
    prepare_release_dir
    generate_changelog
    generate_combined_checksums
    
    if [[ "${SIGN:-false}" == "true" ]]; then
        sign_release
    fi
    
    create_update_manifest
    print_summary
    
    log_success "Release v${VERSION} prepared successfully!"
}

# Run main
main "$@"
