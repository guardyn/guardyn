#!/usr/bin/env bash
# Build script for Flutter Mobile platforms (iOS/Android)
# Note: Desktop builds use Tauri (client-desktop), not Flutter

set -e

BUILD_MODE="${1:-debug}"

echo "🚀 Building Guardyn Flutter client for mobile platforms..."
echo "Build mode: $BUILD_MODE"
echo ""
echo "Note: For Desktop (Windows/macOS/Linux), use Tauri:"
echo "  cd client-desktop && npm run tauri build"
echo ""

# Android (Java warnings suppressed via gradle.properties)
echo "📦 Building Android APK..."
flutter build apk --$BUILD_MODE
echo "✓ Android build complete: build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
echo ""

echo "🎉 All platform builds completed successfully!"
echo ""
echo "Build artifacts:"
echo "  - Android: build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
echo ""
echo "Note: For Desktop (Windows/macOS/Linux), use Tauri: cd client-desktop && npm run tauri build"
echo "Note: Web builds are disabled for security reasons (no browser support)."
