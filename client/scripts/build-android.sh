#!/usr/bin/env bash
# Build script for Flutter Android client
# Configured with Java 11 to avoid deprecation warnings

set -e

BUILD_MODE="${1:-debug}"

echo "Building Flutter Android client in $BUILD_MODE mode..."

flutter build apk --$BUILD_MODE

echo "✓ Android APK build completed successfully"
echo "Output: build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
