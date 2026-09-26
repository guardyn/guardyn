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
/// Construction is pure: it chooses an implementation and returns it, and cannot fail. Whether
/// the native library actually works is established by `CryptoBridge.initialize`, which is the
/// only code that can answer the question - see `CryptoBridgeFactory.ensureInstance`.
///
/// This used to decide by *probing* the FFI here, before anything had initialised
/// flutter_rust_bridge, and to cache the answer. That could not succeed on the first call in a
/// process and poisoned every later one (#366).
///
/// The refusal it used to make has not gone away, it has moved to where it can be evaluated.
/// Falling back to [DartCryptoBridge] whenever the FFI failed to load announced itself with a
/// `debugPrint`, which is compiled out of release builds - so any failure, from a missing `.so`
/// to an ABI mismatch, silently demoted the whole application to an implementation that
/// describes itself as *"for development purposes only"*, with nothing in a release build to say
/// so. A downgrade the user cannot observe is worse than a crash: a crash is reported, a quiet
/// downgrade ships. So the fallback requires [CryptoBridgeFactory.allowInsecureDartFallback] to
/// be set explicitly, which only the test suite does, and `initialize` throws otherwise (#230).
CryptoBridge createNativeCryptoBridge() {
  if (CryptoBridgeFactory.insecureDartFallbackAllowed) {
    debugPrint('🔐 Using DartCryptoBridge by explicit opt-in. Development only.');
    return DartCryptoBridge();
  }

  return NativeRustCryptoBridge();
}
