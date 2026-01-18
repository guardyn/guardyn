#!/usr/bin/env bash
# Install native crypto library for Flutter Linux development
#
# This script copies the compiled Rust library to the Flutter Linux bundle
# so that the Flutter app can load it at runtime.
#
# Usage:
#   ./install-linux-lib.sh
#
# Requirements:
#   - Build the Rust library first: cargo build -p guardyn-crypto-ffi --release

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source and destination paths
RUST_LIB="$PROJECT_ROOT/backend/target/release/libguardyn_crypto_ffi.so"
FLUTTER_LINUX_DIR="$PROJECT_ROOT/client-mobile/linux"
BUNDLE_LIB_DIR="$PROJECT_ROOT/client-mobile/build/linux/x64/release/bundle/lib"

echo "🔧 Installing guardyn-crypto-ffi library for Linux..."

# Check if source library exists
if [[ ! -f "$RUST_LIB" ]]; then
    echo "❌ Error: Native library not found at $RUST_LIB"
    echo "   Build it first with: cargo build -p guardyn-crypto-ffi --release"
    exit 1
fi

# Create symlink in linux directory for CMake to find
LINUX_LIB_LINK="$FLUTTER_LINUX_DIR/libguardyn_crypto_ffi.so"
if [[ -L "$LINUX_LIB_LINK" ]] || [[ -f "$LINUX_LIB_LINK" ]]; then
    rm -f "$LINUX_LIB_LINK"
fi
ln -sf "$RUST_LIB" "$LINUX_LIB_LINK"
echo "✅ Created symlink: $LINUX_LIB_LINK -> $RUST_LIB"

# Copy to bundle directory if it exists (for runtime)
if [[ -d "$BUNDLE_LIB_DIR" ]]; then
    cp -f "$RUST_LIB" "$BUNDLE_LIB_DIR/"
    echo "✅ Copied library to bundle: $BUNDLE_LIB_DIR"
fi

# Verify library symbols
echo "📋 Library symbols (crypto functions):"
nm -D "$RUST_LIB" 2>/dev/null | grep -E "crypto_|frb_" | head -20 || echo "   (no dynamic symbols found)"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 To use in Flutter:"
echo "   1. Run: cd client-mobile && flutter run -d linux"
echo "   2. The library will be loaded automatically"
