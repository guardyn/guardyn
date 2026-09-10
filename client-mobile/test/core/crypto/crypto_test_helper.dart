/// Test helpers for the crypto suite.
///
/// The suite used to skip in its entirety under `flutter test`: every test was written with
/// [nativeCryptoTest], which skipped whenever the Rust FFI was unavailable - and it is always
/// unavailable in a headless VM. That left the Double Ratchet, X3DH and sealed sender with no
/// automated coverage at all, so a green mobile job proved nothing about them.
///
/// Almost none of it needs the FFI. [DartCryptoBridge] supplies real AES-GCM, HKDF, X25519 and
/// Ed25519 through `cryptography` and `pinenacl`, which is enough to exercise every protocol
/// concern: framing, the wire format, key schedules, skipped-message keys and AAD.
///
/// So the default is now [cryptoTest], which always runs. [ffiOnlyCryptoTest] is reserved for
/// the handful of assertions that genuinely cannot hold without the real library - currently
/// the cross-platform Ed25519 to X25519 vectors, because `DartCryptoBridge` derives that key
/// from a seed rather than performing the birational map, and says so in its own comment.
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
      'ℹ️ Native crypto (FFI) not loaded; running the suite on DartCryptoBridge. '
      'Only ffiOnlyCryptoTest cases are skipped.',
    );
  }
}

/// A crypto test that runs on whichever bridge is present.
///
/// This is the default. Use it for anything that exercises protocol behaviour rather than the
/// FFI boundary itself.
@isTest
void cryptoTest(
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
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
  );
}

/// A crypto test that is skipped unless the real Rust FFI is loaded.
///
/// Reserve this for assertions that cannot hold on [DartCryptoBridge]. Every use is a claim
/// that the pure-Dart implementation is not merely slower but *different*, so it needs a
/// reason at the call site.
@isTest
void ffiOnlyCryptoTest(
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

/// A crypto group that runs on whichever bridge is present.
@isTestGroup
void cryptoGroup(String description, dynamic Function() body) {
  group(description, body);
}

/// A crypto group skipped unless the real Rust FFI is loaded.
@isTestGroup
void ffiOnlyCryptoGroup(String description, dynamic Function() body) {
  group(
    description,
    body,
    skip: nativeCryptoAvailable ? null : skipNativeCryptoMessage,
  );
}
