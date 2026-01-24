/// IO implementation for native crypto bridge
///
/// This file is used on platforms where dart:io is available (mobile/desktop).
/// It provides either native Rust FFI or pure Dart fallback implementation.
library;

import 'package:flutter/foundation.dart';

import '../native_crypto_bridge.dart';
import 'dart_crypto_bridge.dart';
import 'rust_crypto_bridge.dart';

/// Create crypto bridge for IO platforms
///
/// Tries native Rust implementation first, falls back to Dart if not available.
CryptoBridge? createNativeCryptoBridge() {
  // Try native Rust implementation first
  if (NativeRustCryptoBridge.checkNativeAvailable()) {
    debugPrint('🔐 Using native Rust crypto implementation');
    return NativeRustCryptoBridge();
  }

  // Fall back to pure Dart implementation
  debugPrint(
    '🔐 Native Rust crypto not available, using Dart fallback. '
    'Build native libraries for production use.',
  );
  return DartCryptoBridge();
}

/// Check if native crypto is available
bool isNativeCryptoAvailable() {
  return NativeRustCryptoBridge.checkNativeAvailable();
}
