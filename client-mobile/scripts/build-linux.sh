#!/usr/bin/env bash
# Build script for Flutter Linux client

set -e

BUILD_MODE="${1:-debug}"

echo "Building Flutter Linux client in $BUILD_MODE mode..."

flutter build linux --$BUILD_MODE

echo "✓ Linux build completed successfully"
echo "Output: build/linux/x64/$BUILD_MODE/bundle/guardyn_client"
