#!/usr/bin/env bash
set -e

echo "Testing crypto crate compilation..."
cd "$(dirname "$0")"

# Try to use cargo directly (for Nix environment)
if command -v cargo &> /dev/null; then
    cargo check -p guardyn-crypto
    echo "✅ Compilation successful!"

    echo ""
    echo "Running crypto tests..."
    cargo test -p guardyn-crypto
    echo "✅ Tests passed!"
else
    echo "❌ Cargo not found. Please run this script inside 'nix develop' shell."
    exit 1
fi
