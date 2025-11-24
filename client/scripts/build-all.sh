#!/usr/bin/env bash
# Comprehensive build script for all Flutter platforms
# Addresses all known build warnings

set -e

BUILD_MODE="${1:-debug}"

echo "🚀 Building Guardyn Flutter client for all platforms..."
echo "Build mode: $BUILD_MODE"
echo ""

# Linux
echo "📦 Building Linux client..."
flutter build linux --$BUILD_MODE
echo "✓ Linux build complete: build/linux/x64/$BUILD_MODE/bundle/guardyn_client"
echo ""

# Android (Java warnings suppressed via gradle.properties)
echo "📦 Building Android APK..."
flutter build apk --$BUILD_MODE
echo "✓ Android build complete: build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
echo ""

# Web (Wasm warnings suppressed)
echo "📦 Building Web client..."
flutter build web --$BUILD_MODE --no-wasm-dry-run
echo "✓ Web build complete: build/web"
echo ""

echo "🎉 All platform builds completed successfully!"
echo ""
echo "Build artifacts:"
echo "  - Linux: build/linux/x64/$BUILD_MODE/bundle/guardyn_client"
echo "  - Android: build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
echo "  - Web: build/web"
