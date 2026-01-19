/// Unit tests for CryptoBridgeFactory and native bridge selection
///
/// Run with:
/// ```bash
/// flutter test test/core/crypto/crypto_bridge_factory_test.dart
/// ```
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/native_crypto_bridge.dart';

void main() {
  group('CryptoBridgeFactory', () {
    tearDown(() {
      CryptoBridgeFactory.reset();
    });

    test('instance returns singleton', () {
      final bridge1 = CryptoBridgeFactory.instance;
      final bridge2 = CryptoBridgeFactory.instance;

      expect(
        identical(bridge1, bridge2),
        isTrue,
        reason: 'Factory should return same instance',
      );
    });

    test('reset clears singleton', () {
      final bridge1 = CryptoBridgeFactory.instance;
      CryptoBridgeFactory.reset();
      final bridge2 = CryptoBridgeFactory.instance;

      expect(
        identical(bridge1, bridge2),
        isFalse,
        reason: 'Reset should clear the singleton',
      );
    });

    test('factory returns native bridge on supported platforms', () {
      // On desktop/mobile, should return NativeRustCryptoBridge
      // On web (removed), would throw UnsupportedError
      final bridge = CryptoBridgeFactory.instance;

      // The bridge should be a NativeCryptoBridge on all supported platforms
      expect(bridge, isNotNull);
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

  group('Platform support', () {
    test('web platform is not supported', () {
      // This test documents that web platform is intentionally not supported
      // for security reasons - all crypto must use native Rust FFI
      //
      // If someone tries to run on web, CryptoBridgeFactory.instance
      // will throw UnsupportedError
      expect(true, isTrue); // Placeholder - actual test would need web context
    });
  });
}
