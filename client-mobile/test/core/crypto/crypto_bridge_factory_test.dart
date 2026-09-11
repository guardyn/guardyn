/// Unit tests for CryptoBridgeFactory and native bridge selection
///
/// Run with:
/// ```bash
/// flutter test test/core/crypto/crypto_bridge_factory_test.dart
/// ```
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/native/dart_crypto_bridge.dart';
import 'package:guardyn_client/core/crypto/native_crypto_bridge.dart';

void main() {
  group('CryptoBridgeFactory', () {
    setUp(() {
      CryptoBridgeFactory.reset();
      CryptoBridgeFactory.allowInsecureDartFallback = false;
    });

    tearDown(() {
      CryptoBridgeFactory.reset();
      CryptoBridgeFactory.allowInsecureDartFallback = false;
    });

    test('refuses to build a bridge when the native library is missing', () {
      // The #230 regression test, and the reason the three tests that used to live here were
      // rewritten: they asserted `expect(bridge, isNotNull)` under the title "factory returns
      // native bridge on supported platforms". That passed on DartCryptoBridge just as happily
      // as on the real one, so it certified precisely the downgrade it was named after.
      //
      // There is no FFI in a headless test VM, so this exercises the missing-library path.
      expect(
        () => CryptoBridgeFactory.instance,
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('Refusing to fall back'),
          ),
        ),
        reason: 'a missing native library must fail loudly, never downgrade silently',
      );
    });

    test('uses the Dart bridge only when the fallback is granted explicitly', () {
      CryptoBridgeFactory.allowInsecureDartFallback = true;

      expect(CryptoBridgeFactory.instance, isA<DartCryptoBridge>());
    });

    test('instance returns singleton', () {
      CryptoBridgeFactory.allowInsecureDartFallback = true;

      final bridge1 = CryptoBridgeFactory.instance;
      final bridge2 = CryptoBridgeFactory.instance;

      expect(
        identical(bridge1, bridge2),
        isTrue,
        reason: 'Factory should return same instance',
      );
    });

    test('reset clears singleton', () {
      CryptoBridgeFactory.allowInsecureDartFallback = true;

      final bridge1 = CryptoBridgeFactory.instance;
      CryptoBridgeFactory.reset();
      final bridge2 = CryptoBridgeFactory.instance;

      expect(
        identical(bridge1, bridge2),
        isFalse,
        reason: 'Reset should clear the singleton',
      );
    });

    test('revoking the grant makes the next build refuse again', () {
      // The permission is not sticky: it gates each construction, so a test that granted it
      // cannot leave the application permanently downgraded.
      CryptoBridgeFactory.allowInsecureDartFallback = true;
      expect(CryptoBridgeFactory.instance, isA<DartCryptoBridge>());

      CryptoBridgeFactory.reset();
      CryptoBridgeFactory.allowInsecureDartFallback = false;

      expect(() => CryptoBridgeFactory.instance, throwsUnsupportedError);
    });
  });

  group('NativeCryptoConfig', () {
    test('default config has expected values', () {
      const config = NativeCryptoConfig.defaultConfig;

      expect(config.preferNative, isTrue);
      expect(
        config.enablePostQuantum,
        isFalse,
        reason: 'PQ disabled by default until fully tested',
      );
    });

    test('withPostQuantum enables PQ', () {
      const config = NativeCryptoConfig(enablePostQuantum: true);

      expect(config.enablePostQuantum, isTrue);
    });

    test('config is immutable', () {
      const config1 = NativeCryptoConfig.defaultConfig;
      const config2 = NativeCryptoConfig.defaultConfig;

      expect(config1.preferNative, equals(config2.preferNative));
      expect(config1.enablePostQuantum, equals(config2.enablePostQuantum));
    });
  });

}
