/// IO implementation for native crypto bridge
///
/// This file is used on platforms where dart:io is available (mobile/desktop).
library;

import '../native_crypto_bridge.dart';
import 'rust_crypto_bridge.dart';

/// Create native crypto bridge for IO platforms
CryptoBridge? createNativeCryptoBridge() {
  if (NativeRustCryptoBridge.checkNativeAvailable()) {
    return NativeRustCryptoBridge();
  }
  return null;
}

/// Check if native crypto is available
bool isNativeCryptoAvailable() {
  return NativeRustCryptoBridge.checkNativeAvailable();
}
