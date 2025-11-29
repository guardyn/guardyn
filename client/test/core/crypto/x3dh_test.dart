import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/x3dh.dart';

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
}
