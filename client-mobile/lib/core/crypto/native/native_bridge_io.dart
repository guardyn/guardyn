/// IO implementation for native crypto bridge
///
/// This file is used on platforms where dart:io is available (mobile/desktop).
/// It provides either native Rust FFI or pure Dart fallback implementation.
library;

import 'package:flutter/foundation.dart';

import '../native_crypto_bridge.dart';
import 'dart_crypto_bridge.dart';
import 'rust_crypto_bridge.dart';

/// Create the crypto bridge for IO platforms.
///
/// Returns the native Rust implementation, or throws [UnsupportedError].
///
/// This used to fall back to [DartCryptoBridge] whenever the FFI failed to load, announcing it
/// with a `debugPrint` - which is compiled out of release builds. So any failure to load the
/// library, from a missing `.so` to an ABI mismatch, silently demoted the entire application to
/// an implementation that describes itself as *"for development purposes only"*, with nothing
/// in a release build to say so. There is no `kReleaseMode` check anywhere in the app to catch
/// it either.
///
/// A downgrade the user cannot observe is worse than a crash: a crash is reported, a quiet
/// downgrade ships. So the fallback now requires
/// [CryptoBridgeFactory.allowInsecureDartFallback] to be set explicitly, which only the test
/// suite does.
CryptoBridge createNativeCryptoBridge() {
  if (NativeRustCryptoBridge.checkNativeAvailable()) {
    return NativeRustCryptoBridge();
  }

  if (CryptoBridgeFactory.insecureDartFallbackAllowed) {
    debugPrint('🔐 Native crypto unavailable; using DartCryptoBridge by explicit opt-in.');
    return DartCryptoBridge();
  }

  throw UnsupportedError(
    'Native Rust crypto is required but not available. Ensure libguardyn_crypto_ffi is built '
    'and bundled with the app. Refusing to fall back to the development-only Dart '
    'implementation.',
  );
}

/// Check if native crypto is available
bool isNativeCryptoAvailable() {
  return NativeRustCryptoBridge.checkNativeAvailable();
}
