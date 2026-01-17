import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/x3dh.dart';
import 'package:pinenacl/tweetnacl.dart' show TweetNaCl;

void main() {
  group('IdentityKeyPair', () {
    test('generate creates valid Ed25519 key pair', () async {
      final keyPair = await IdentityKeyPair.generate();

      expect(keyPair.privateKey.length, equals(32));
      expect(keyPair.publicKey.length, equals(32));
    });

    test('sign produces valid signature', () async {
      final keyPair = await IdentityKeyPair.generate();
      final data = Uint8List.fromList('test data'.codeUnits);

      final signature = await keyPair.sign(data);

      expect(signature.length, equals(64)); // Ed25519 signature is 64 bytes
    });

    test('verify returns true for valid signature', () async {
      final keyPair = await IdentityKeyPair.generate();
      final data = Uint8List.fromList('test data'.codeUnits);

      final signature = await keyPair.sign(data);
      final isValid = await IdentityKeyPair.verify(
        data,
        signature,
        keyPair.publicKey,
      );

      expect(isValid, isTrue);
    });

    test('verify returns false for tampered data', () async {
      final keyPair = await IdentityKeyPair.generate();
      final data = Uint8List.fromList('original data'.codeUnits);
      final tamperedData = Uint8List.fromList('tampered data'.codeUnits);

      final signature = await keyPair.sign(data);
      final isValid = await IdentityKeyPair.verify(
        tamperedData,
        signature,
        keyPair.publicKey,
      );

      expect(isValid, isFalse);
    });
  });

  group('SignedPreKey', () {
    test('generate creates valid signed pre-key', () async {
      final identity = await IdentityKeyPair.generate();
      final signedPreKey = await SignedPreKey.generate(
        identityKey: identity,
        keyId: 1,
      );

      expect(signedPreKey.privateKey.length, equals(32));
      expect(signedPreKey.publicKey.length, equals(32));
      expect(signedPreKey.signature.length, equals(64));
      expect(signedPreKey.keyId, equals(1));
    });

    test('verify returns true for valid signature', () async {
      final identity = await IdentityKeyPair.generate();
      final signedPreKey = await SignedPreKey.generate(
        identityKey: identity,
        keyId: 1,
      );

      final isValid = await signedPreKey.verify(identity.publicKey);

      expect(isValid, isTrue);
    });
  });

  group('OneTimePreKey', () {
    test('generate creates valid one-time pre-key', () async {
      final otpk = await OneTimePreKey.generate(42);

      expect(otpk.privateKey.length, equals(32));
      expect(otpk.publicKey.length, equals(32));
      expect(otpk.keyId, equals(42));
    });
  });

  group('X3DHKeyBundle', () {
    test('toJson/fromJson roundtrip', () async {
      final identity = await IdentityKeyPair.generate();
      final signedPreKey = await SignedPreKey.generate(
        identityKey: identity,
        keyId: 1,
      );
      final otpk = await OneTimePreKey.generate(1);

      final bundle = X3DHKeyBundle(
        identityKey: identity.publicKey,
        signedPreKey: signedPreKey.publicKey,
        signedPreKeySignature: signedPreKey.signature,
        signedPreKeyId: 1,
        oneTimePreKey: otpk.publicKey,
        oneTimePreKeyId: 1,
      );

      final json = bundle.toJson();
      final restored = X3DHKeyBundle.fromJson(json);

      expect(restored.identityKey, equals(bundle.identityKey));
      expect(restored.signedPreKey, equals(bundle.signedPreKey));
      expect(restored.signedPreKeySignature, equals(bundle.signedPreKeySignature));
      expect(restored.signedPreKeyId, equals(bundle.signedPreKeyId));
      expect(restored.oneTimePreKey, equals(bundle.oneTimePreKey));
      expect(restored.oneTimePreKeyId, equals(bundle.oneTimePreKeyId));
    });

    test('verify returns true for valid bundle', () async {
      final identity = await IdentityKeyPair.generate();
      final signedPreKey = await SignedPreKey.generate(
        identityKey: identity,
        keyId: 1,
      );

      final bundle = X3DHKeyBundle(
        identityKey: identity.publicKey,
        signedPreKey: signedPreKey.publicKey,
        signedPreKeySignature: signedPreKey.signature,
        signedPreKeyId: 1,
      );

      final isValid = await bundle.verify();

      expect(isValid, isTrue);
    });
  });

  group('X3DHProtocol', () {
    test('initialize creates valid protocol state', () async {
      final protocol = await X3DHProtocol.initialize(oneTimePreKeyCount: 10);

      expect(protocol.identityKey.publicKey.length, equals(32));
      expect(protocol.signedPreKey.publicKey.length, equals(32));
      expect(protocol.oneTimePreKeys.length, equals(10));
    });

    test('exportKeyBundle returns valid bundle', () async {
      final protocol = await X3DHProtocol.initialize(oneTimePreKeyCount: 10);
      final bundle = protocol.exportKeyBundle(oneTimePreKeyIndex: 0);

      expect(bundle.identityKey, equals(protocol.identityKey.publicKey));
      expect(bundle.signedPreKey, equals(protocol.signedPreKey.publicKey));
      expect(bundle.oneTimePreKey, equals(protocol.oneTimePreKeys[0].publicKey));
    });

    test('serialize/deserialize roundtrip', () async {
      final protocol = await X3DHProtocol.initialize(oneTimePreKeyCount: 5);
      final serialized = protocol.serialize();
      final restored = X3DHProtocol.deserialize(serialized);

      expect(
        restored.identityKey.publicKey,
        equals(protocol.identityKey.publicKey),
      );
      expect(
        restored.signedPreKey.publicKey,
        equals(protocol.signedPreKey.publicKey),
      );
      expect(
        restored.oneTimePreKeys.length,
        equals(protocol.oneTimePreKeys.length),
      );
    });

    test('initiateKeyAgreement produces shared secret', () async {
      final alice = await X3DHProtocol.initialize(oneTimePreKeyCount: 10);
      final bob = await X3DHProtocol.initialize(oneTimePreKeyCount: 10);


      final bobBundle = bob.exportKeyBundle(oneTimePreKeyIndex: 0);
      final (sharedSecret, ephemeralKey) = await X3DHProtocol.initiateKeyAgreement(
        alice.identityKey,
        bobBundle,
      );

      expect(sharedSecret.length, equals(32));
      expect(ephemeralKey.length, equals(32));
    });

    test('completeKeyAgreement produces shared secret', () async {
      final alice = await X3DHProtocol.initialize(oneTimePreKeyCount: 10);
      final bob = await X3DHProtocol.initialize(oneTimePreKeyCount: 10);

      final bobBundle = bob.exportKeyBundle(oneTimePreKeyIndex: 0);
      final (_, ephemeralKey) = await X3DHProtocol.initiateKeyAgreement(
        alice.identityKey,
        bobBundle,
      );

      final bobSharedSecret = await bob.completeKeyAgreement(
        remoteIdentityKey: alice.identityKey.publicKey,
        remoteEphemeralKey: ephemeralKey,
        usedOneTimePreKeyId: 1,
      );

      expect(bobSharedSecret.length, equals(32));
    });
  });

  /// Cross-platform compatibility tests with Rust test vectors.
  ///
  /// These test vectors were generated by the Rust crypto library using
  /// `cargo test -p guardyn-crypto generate_dart_test_vectors -- --nocapture`
  ///
  /// The vectors verify that Ed25519 → X25519 key conversion produces identical
  /// results in both Rust (ed25519-dalek + curve25519-dalek) and Dart (pinenacl/TweetNaCl).
  group('Cross-platform Ed25519→X25519 Compatibility', () {
    test('all_zeros seed produces correct X25519 keys', () async {
      final seed = Uint8List.fromList(List.filled(32, 0x00));

      final expectedX25519Public = Uint8List.fromList([
        0x5b,
        0xf5,
        0x5c,
        0x73,
        0xb8,
        0x2e,
        0xbe,
        0x22,
        0xbe,
        0x80,
        0xf3,
        0x43,
        0x06,
        0x67,
        0xaf,
        0x57,
        0x0f,
        0xae,
        0x25,
        0x56,
        0xa6,
        0x41,
        0x5e,
        0x6b,
        0x30,
        0xd4,
        0x06,
        0x53,
        0x00,
        0xaa,
        0x94,
        0x7d,
      ]);

      final expectedX25519Secret = Uint8List.fromList([
        0x50,
        0x46,
        0xad,
        0xc1,
        0xdb,
        0xa8,
        0x38,
        0x86,
        0x7b,
        0x2b,
        0xbb,
        0xfd,
        0xd0,
        0xc3,
        0x42,
        0x3e,
        0x58,
        0xb5,
        0x79,
        0x70,
        0xb5,
        0x26,
        0x7a,
        0x90,
        0xf5,
        0x79,
        0x60,
        0x92,
        0x4a,
        0x87,
        0xf1,
        0x56,
      ]);

      final keyPair = await IdentityKeyPair.fromSeed(seed);
      final x25519Public = keyPair.toX25519PublicKey();
      final x25519Secret = keyPair.toX25519SecretKey();

      expect(
        x25519Public,
        equals(expectedX25519Public),
        reason: 'X25519 public key must match Rust test vector',
      );
      expect(
        x25519Secret,
        equals(expectedX25519Secret),
        reason: 'X25519 secret key must match Rust test vector',
      );
    });

    test('sequential seed produces correct X25519 keys', () async {
      final seed = Uint8List.fromList(List.generate(32, (i) => i));

      final expectedX25519Public = Uint8List.fromList([
        0x47,
        0x01,
        0xd0,
        0x84,
        0x88,
        0x45,
        0x1f,
        0x54,
        0x5a,
        0x40,
        0x9f,
        0xb5,
        0x8a,
        0xe3,
        0xe5,
        0x85,
        0x81,
        0xca,
        0x40,
        0xac,
        0x3f,
        0x7f,
        0x11,
        0x46,
        0x98,
        0xcd,
        0x71,
        0xde,
        0xac,
        0x73,
        0xca,
        0x01,
      ]);

      final expectedX25519Secret = Uint8List.fromList([
        0x38,
        0x94,
        0xee,
        0xa4,
        0x9c,
        0x58,
        0x0a,
        0xef,
        0x81,
        0x69,
        0x35,
        0x76,
        0x2b,
        0xe0,
        0x49,
        0x55,
        0x9d,
        0x6d,
        0x14,
        0x40,
        0xde,
        0xde,
        0x12,
        0xe6,
        0xa1,
        0x25,
        0xf1,
        0x84,
        0x1f,
        0xff,
        0x8e,
        0x6f,
      ]);

      final keyPair = await IdentityKeyPair.fromSeed(seed);
      final x25519Public = keyPair.toX25519PublicKey();
      final x25519Secret = keyPair.toX25519SecretKey();

      expect(
        x25519Public,
        equals(expectedX25519Public),
        reason: 'X25519 public key must match Rust test vector',
      );
      expect(
        x25519Secret,
        equals(expectedX25519Secret),
        reason: 'X25519 secret key must match Rust test vector',
      );
    });

    test('random_pattern seed produces correct X25519 keys', () async {
      final seed = Uint8List.fromList([
        0x9d,
        0x61,
        0xb1,
        0x9d,
        0xef,
        0xfd,
        0x5a,
        0x60,
        0xba,
        0x84,
        0x4a,
        0xf4,
        0x92,
        0xec,
        0x2c,
        0xc4,
        0x44,
        0x49,
        0xc5,
        0x69,
        0x7b,
        0x32,
        0x69,
        0x19,
        0x70,
        0x3b,
        0xac,
        0x03,
        0x1c,
        0xae,
        0x7f,
        0x60,
      ]);

      final expectedX25519Public = Uint8List.fromList([
        0xd8,
        0x5e,
        0x07,
        0xec,
        0x22,
        0xb0,
        0xad,
        0x88,
        0x15,
        0x37,
        0xc2,
        0xf4,
        0x4d,
        0x66,
        0x2d,
        0x1a,
        0x14,
        0x3c,
        0xf8,
        0x30,
        0xc5,
        0x7a,
        0xca,
        0x43,
        0x05,
        0xd8,
        0x5c,
        0x7a,
        0x90,
        0xf6,
        0xb6,
        0x2e,
      ]);

      final expectedX25519Secret = Uint8List.fromList([
        0x30,
        0x7c,
        0x83,
        0x86,
        0x4f,
        0x28,
        0x33,
        0xcb,
        0x42,
        0x7a,
        0x2e,
        0xf1,
        0xc0,
        0x0a,
        0x01,
        0x3c,
        0xfd,
        0xff,
        0x27,
        0x68,
        0xd9,
        0x80,
        0xc0,
        0xa3,
        0xa5,
        0x20,
        0xf0,
        0x06,
        0x90,
        0x4d,
        0xe9,
        0x4f,
      ]);

      final keyPair = await IdentityKeyPair.fromSeed(seed);
      final x25519Public = keyPair.toX25519PublicKey();
      final x25519Secret = keyPair.toX25519SecretKey();

      expect(
        x25519Public,
        equals(expectedX25519Public),
        reason: 'X25519 public key must match Rust test vector',
      );
      expect(
        x25519Secret,
        equals(expectedX25519Secret),
        reason: 'X25519 secret key must match Rust test vector',
      );
    });

    test(
      'X25519 DH produces identical shared secrets cross-platform',
      () async {
        // Alice's seed (sequential)
        final aliceSeed = Uint8List.fromList(List.generate(32, (i) => i));
        // Bob's seed (random_pattern)
        final bobSeed = Uint8List.fromList([
          0x9d,
          0x61,
          0xb1,
          0x9d,
          0xef,
          0xfd,
          0x5a,
          0x60,
          0xba,
          0x84,
          0x4a,
          0xf4,
          0x92,
          0xec,
          0x2c,
          0xc4,
          0x44,
          0x49,
          0xc5,
          0x69,
          0x7b,
          0x32,
          0x69,
          0x19,
          0x70,
          0x3b,
          0xac,
          0x03,
          0x1c,
          0xae,
          0x7f,
          0x60,
        ]);

        final alice = await IdentityKeyPair.fromSeed(aliceSeed);
        final bob = await IdentityKeyPair.fromSeed(bobSeed);

        final aliceX25519Secret = alice.toX25519SecretKey();
        final bobX25519Public = bob.toX25519PublicKey();

        final bobX25519Secret = bob.toX25519SecretKey();
        final aliceX25519Public = alice.toX25519PublicKey();

        // Compute DH shared secrets using TweetNaCl scalarmult
        final aliceShared = Uint8List(32);
        final bobShared = Uint8List(32);

        TweetNaCl.crypto_scalarmult(
          aliceShared,
          aliceX25519Secret,
          bobX25519Public,
        );
        TweetNaCl.crypto_scalarmult(
          bobShared,
          bobX25519Secret,
          aliceX25519Public,
        );

        expect(
          aliceShared,
          equals(bobShared),
          reason: 'DH shared secrets must be identical',
        );
      },
    );
  });
}
