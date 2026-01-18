/// Stub implementation for platforms where native crypto is not available
///
/// This file is used on Web platform where dart:io is not available.
library;

import '../native_crypto_bridge.dart';

/// Create native crypto bridge (stub - returns null on unsupported platforms)
CryptoBridge? createNativeCryptoBridge() => null;

/// Check if native crypto is available (stub - always false)
bool isNativeCryptoAvailable() => false;
