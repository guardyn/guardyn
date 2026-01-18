/// Tests for CryptoPrimitives
///
/// Verifies that low-level crypto primitives work correctly via CryptoBridge.
///
/// Note: These tests require native library to be available.
/// In headless test mode (flutter test), they will be skipped.
/// Run integration tests for full coverage on real devices.
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_primitives.dart';
import 'package:guardyn_client/core/crypto/native_crypto_bridge.dart';

void main() {
  late bool nativeAvailable;

  setUpAll(() async {
    await CryptoPrimitives.initialize(
      const NativeCryptoConfig(preferNative: true, enablePadme: true),
    );
    nativeAvailable = CryptoPrimitives.isNativeAvailable;

    if (!nativeAvailable) {
      // ignore: avoid_print
      print(
        '⚠️ Native crypto not available in test environment. '
        'Run integration tests on real device for full coverage.',
      );
    }
  });

  group('CryptoPrimitives', () {
    test('is initialized', () {
      expect(CryptoPrimitives.isInitialized, isTrue);
    });

    test('generates X25519 key pair', () async {
      if (!nativeAvailable) {
        // ignore: avoid_print
        print('Skipping: native crypto required');
        return;
      }

      final (publicKey, privateKey) =
          await CryptoPrimitives.generateX25519KeyPair();

      expect(publicKey.length, equals(32));
      expect(privateKey.length, equals(32));
    });

    test('generates Ed25519 key pair', () async {
      if (!nativeAvailable) {
        // ignore: avoid_print
        print('Skipping: native crypto required');
        return;
      }

      final (publicKey, privateKey) =
          await CryptoPrimitives.generateEd25519KeyPair();

      expect(publicKey.length, equals(32));
      expect(privateKey.length, equals(32));
    });

    test('X25519 Diffie-Hellman produces same shared secret', () async {
      if (!nativeAvailable) {
        // ignore: avoid_print
        print('Skipping: native crypto required');
        return;
      }

      final (alicePub, alicePriv) =
          await CryptoPrimitives.generateX25519KeyPair();
      final (bobPub, bobPriv) = await CryptoPrimitives.generateX25519KeyPair();

      final aliceShared = await CryptoPrimitives.x25519DiffieHellman(
        privateKey: alicePriv,
        remotePublicKey: bobPub,
      );

      final bobShared = await CryptoPrimitives.x25519DiffieHellman(
        privateKey: bobPriv,
        remotePublicKey: alicePub,
      );

      expect(aliceShared.length, equals(32));
      expect(aliceShared, equals(bobShared));
    });

    test('AES-GCM round-trip encryption', () async {
      if (!nativeAvailable) {
        // ignore: avoid_print
        print('Skipping: native crypto required');
        return;
      }

      final plaintext = Uint8List.fromList('Hello, Guardyn!'.codeUnits);
      final key = Uint8List.fromList(List.generate(32, (i) => i));

      final (ciphertext, nonce, tag) = await CryptoPrimitives.encryptAesGcm(
        plaintext: plaintext,
        key: key,
      );

      expect(ciphertext.isNotEmpty, isTrue);
      expect(nonce.length, equals(12));
      expect(tag.length, equals(16));

      final decrypted = await CryptoPrimitives.decryptAesGcm(
        ciphertext: ciphertext,
        nonce: nonce,
        tag: tag,
        key: key,
      );

      expect(decrypted, equals(plaintext));
    });

    test('HKDF derives consistent keys', () async {
      if (!nativeAvailable) {
        // ignore: avoid_print
        print('Skipping: native crypto required');
        return;
      }

      final ikm = Uint8List.fromList(List.generate(32, (i) => i));
      final info = Uint8List.fromList('test-info'.codeUnits);

      final key1 = await CryptoPrimitives.hkdf(
        inputKeyMaterial: ikm,
        info: info,
        outputLength: 32,
      );

      final key2 = await CryptoPrimitives.hkdf(
        inputKeyMaterial: ikm,
        info: info,
        outputLength: 32,
      );

      expect(key1.length, equals(32));
      expect(key1, equals(key2));
    });

    test('Ed25519 sign and verify', () async {
      if (!nativeAvailable) {
        // ignore: avoid_print
        print('Skipping: native crypto required');
        return;
      }

      final (publicKey, privateKey) =
          await CryptoPrimitives.generateEd25519KeyPair();
      final message = Uint8List.fromList('Sign this message'.codeUnits);

      final signature = await CryptoPrimitives.signEd25519(
        privateKey: privateKey,
        message: message,
      );

      expect(signature.length, equals(64));

      final isValid = await CryptoPrimitives.verifyEd25519(
        publicKey: publicKey,
        message: message,
        signature: signature,
      );

      expect(isValid, isTrue);

      // Verify tampered message fails
      final tampered = Uint8List.fromList('Tampered'.codeUnits);
      final isInvalid = await CryptoPrimitives.verifyEd25519(
        publicKey: publicKey,
        message: tampered,
        signature: signature,
      );

      expect(isInvalid, isFalse);
    });

    test('PADMÉ padding round-trip', () async {
      if (!nativeAvailable) {
        // ignore: avoid_print
        print('Skipping: native crypto required');
        return;
      }

      final message = Uint8List.fromList('Pad this message'.codeUnits);

      final padded = await CryptoPrimitives.padMessage(message);

      expect(padded.length, greaterThan(message.length));

      final unpadded = await CryptoPrimitives.unpadMessage(padded);

      expect(unpadded, equals(message));
    });
  });
}
