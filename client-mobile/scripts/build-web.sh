#!/usr/bin/env bash
# Build script for Flutter web client
# Suppresses Wasm dry run warnings since flutter_secure_storage_web uses dart:html/dart:js
# which are not compatible with WebAssembly but work fine for JS compilation

set -e

BUILD_MODE="${1:-debug}"

echo "Building Flutter web client in $BUILD_MODE mode..."

flutter build web --$BUILD_MODE --no-wasm-dry-run

echo "✓ Web build completed successfully"
echo "Output: build/web"
