/// Unit tests for CryptoBridgeFactory and native bridge selection
///
/// Run with:
/// ```bash
/// flutter test test/core/crypto/crypto_bridge_factory_test.dart
/// ```
library;

import 'package:flutter/foundation.dart';
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

    test('useDart forces Dart implementation', () {
      CryptoBridgeFactory.useDart();
      final bridge = CryptoBridgeFactory.instance;

      expect(bridge, isA<DartCryptoBridge>());
      expect(bridge.isNativeAvailable, isFalse);
    });

    test('DartCryptoBridge reports no native or PQ', () async {
      CryptoBridgeFactory.useDart();
      final bridge = CryptoBridgeFactory.instance;

      await bridge.initialize(const NativeCryptoConfig());

      expect(bridge.isNativeAvailable, isFalse);
      expect(bridge.isPostQuantumAvailable, isFalse);
    });

    test('DartCryptoBridge returns null for hybrid bundle', () async {
      CryptoBridgeFactory.useDart();
      final bridge = CryptoBridgeFactory.instance;

      await bridge.initialize(const NativeCryptoConfig());

      final bundle = await bridge.generateHybridKeyBundle();
      expect(bundle, isNull, reason: 'PQ not available in Dart implementation');
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
      expect(config.enablePadme, isTrue);
      expect(config.enableHardwareAcceleration, isTrue);
    });

    test('custom config overrides defaults', () {
      const config = NativeCryptoConfig(
        preferNative: false,
        enablePostQuantum: true,
        enablePadme: false,
        enableHardwareAcceleration: false,
      );

      expect(config.preferNative, isFalse);
      expect(config.enablePostQuantum, isTrue);
      expect(config.enablePadme, isFalse);
      expect(config.enableHardwareAcceleration, isFalse);
    });
  });

  group('KeyPair', () {
    test('equality based on all fields', () {
      final kp1 = KeyPair(
        publicKey: Uint8List.fromList([1, 2, 3]),
        privateKey: Uint8List.fromList([4, 5, 6]),
        keyType: 'X25519',
      );
      final kp2 = KeyPair(
        publicKey: Uint8List.fromList([1, 2, 3]),
        privateKey: Uint8List.fromList([4, 5, 6]),
        keyType: 'X25519',
      );

      // Note: Uint8List doesn't implement equality by content
      // This test verifies the KeyPair structure
      expect(kp1.publicKey, equals(kp2.publicKey));
      expect(kp1.privateKey, equals(kp2.privateKey));
      expect(kp1.keyType, equals(kp2.keyType));
    });
  });

  group('EncryptedData', () {
    test('toBytes and fromBytes round-trip', () {
      final original = EncryptedData(
        nonce: Uint8List.fromList(List.generate(12, (i) => i)),
        ciphertext: Uint8List.fromList(List.generate(32, (i) => i + 50)),
        tag: Uint8List.fromList(List.generate(16, (i) => i + 100)),
      );

      final bytes = original.toBytes();
      final restored = EncryptedData.fromBytes(bytes);

      expect(restored.nonce, equals(original.nonce));
      expect(restored.ciphertext, equals(original.ciphertext));
      expect(restored.tag, equals(original.tag));
    });

    test('fromBytes throws on too short data', () {
      final shortData = Uint8List(20); // Less than nonce + tag

      expect(
        () => EncryptedData.fromBytes(shortData),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('HybridKeyBundle', () {
    test('stores all key types', () {
      final bundle = HybridKeyBundle(
        x25519PublicKey: Uint8List(32),
        x25519PrivateKey: Uint8List(32),
        mlKemPublicKey: Uint8List(1184), // ML-KEM-768 public key size
        mlKemPrivateKey: Uint8List(2400), // ML-KEM-768 private key size
      );

      expect(bundle.x25519PublicKey.length, equals(32));
      expect(bundle.x25519PrivateKey.length, equals(32));
      expect(bundle.mlKemPublicKey.length, greaterThan(0));
      expect(bundle.mlKemPrivateKey.length, greaterThan(0));
    });
  });
}
