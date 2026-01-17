#!/usr/bin/env bash
#
# Guardyn Desktop Client - Development Setup Script
# Installs dependencies and sets up the development environment
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Guardyn Desktop Client Setup ==="

# Check for required tools
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is required but not installed."
        exit 1
    fi
}

echo "Checking required tools..."
check_command node
check_command npm
check_command cargo

echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Cargo version: $(cargo --version)"

# Install npm dependencies
echo ""
echo "Installing npm dependencies..."
npm install

# Build Tailwind CSS
echo ""
echo "Building CSS..."
npm run build

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To start development:"
echo "  npm run tauri dev"
echo ""
echo "To build for production:"
echo "  npm run tauri build"
echo ""
