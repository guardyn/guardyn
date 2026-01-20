/// Test helper for crypto tests that require native FFI
///
/// Native crypto tests require the Rust FFI library (libguardyn_crypto_ffi.so)
/// which is only available when running on real devices or integration tests.
/// Unit tests (flutter test) run in a headless VM without native library support.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_primitives.dart';
import 'package:meta/meta.dart';

/// Whether native crypto is available in the current test environment.
///
/// This is set during [initializeCryptoForTests] and should be checked
/// before running tests that require native crypto operations.
bool nativeCryptoAvailable = false;

/// Skip message for tests that require native crypto.
const String skipNativeCryptoMessage =
    'Requires native crypto (FFI). Run integration tests on real device.';

/// Initialize CryptoPrimitives for testing and detect native availability.
///
/// Call this in setUpAll() of crypto test files.
/// After calling, check [nativeCryptoAvailable] to skip tests if needed.
Future<void> initializeCryptoForTests() async {
  await CryptoPrimitives.initialize();
  nativeCryptoAvailable = CryptoPrimitives.isNativeAvailable;

  if (!nativeCryptoAvailable) {
    // ignore: avoid_print
    print(
      '⚠️ Native crypto not available in test environment. '
      'Crypto tests will be skipped. '
      'Run integration tests on real device for full coverage.',
    );
  }
}

/// Creates a test with conditional skip based on native crypto availability.
///
/// Use this instead of [test] for tests that require native crypto.
/// The test will be skipped with proper message if native crypto is unavailable.
///
/// Example:
/// ```dart
/// nativeCryptoTest('encrypts message', () async {
///   final result = await CryptoPrimitives.encrypt(...);
///   expect(result, isNotNull);
/// });
/// ```
@isTest
void nativeCryptoTest(
  String description,
  dynamic Function() body, {
  String? testOn,
  Timeout? timeout,
  dynamic skip,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) {
  test(
    description,
    body,
    testOn: testOn,
    timeout: timeout,
    skip: nativeCryptoAvailable ? skip : skipNativeCryptoMessage,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
  );
}

/// Creates a test group with conditional skip based on native crypto availability.
///
/// Use this instead of [group] for test groups that require native crypto.
@isTestGroup
void nativeCryptoGroup(String description, dynamic Function() body) {
  group(
    description,
    body,
    skip: nativeCryptoAvailable ? null : skipNativeCryptoMessage,
  );
}
