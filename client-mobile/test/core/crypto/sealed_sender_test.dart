// Sealed Sender Protocol Tests
//
// Tests for metadata protection protocol

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_primitives.dart';
import 'package:guardyn_client/core/crypto/sealed_sender.dart';

void main() {
  // Initialize CryptoPrimitives before tests
  setUpAll(() async {
    await CryptoPrimitives.initialize();
  });

  group('SenderCertificate', () {
    late Uint8List signingPrivateKey;
    late Uint8List signingPublicKey;

    setUpAll(() async {
      final (pubKey, privKey) = await CryptoPrimitives.generateEd25519KeyPair();
      signingPublicKey = pubKey;
      signingPrivateKey = privKey;
    });

    test('creates certificate with valid signature', () async {
      final expiresAt =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400; // 24h

      final cert = await SenderCertificate.create(
        senderUserId: 'user-123',
        senderDeviceId: 'device-456',
        signingPrivateKey: signingPrivateKey,
        signingPublicKey: signingPublicKey,
        expiresAt: expiresAt,
      );

      expect(cert.senderUserId, 'user-123');
      expect(cert.senderDeviceId, 'device-456');
      expect(cert.senderIdentityKey.length, 32);
      expect(cert.signature.length, 64);
    });

    test('verifies valid certificate', () async {
      final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400;

      final cert = await SenderCertificate.create(
        senderUserId: 'user-123',
        senderDeviceId: 'device-456',
        signingPrivateKey: signingPrivateKey,
        signingPublicKey: signingPublicKey,
        expiresAt: expiresAt,
      );

      final isValid = await cert.verify();
      expect(isValid, isTrue);
    });

    test('detects expired certificate', () async {
      final expiresAt =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
          3600; // Expired 1h ago

      final cert = await SenderCertificate.create(
        senderUserId: 'user-123',
        senderDeviceId: 'device-456',
        signingPrivateKey: signingPrivateKey,
        signingPublicKey: signingPublicKey,
        expiresAt: expiresAt,
      );

      expect(cert.isExpired, isTrue);
    });

    test('serializes and deserializes correctly', () async {
      final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400;

      final cert = await SenderCertificate.create(
        senderUserId: 'user-123',
        senderDeviceId: 'device-456',
        signingPrivateKey: signingPrivateKey,
        signingPublicKey: signingPublicKey,
        expiresAt: expiresAt,
      );

      final bytes = cert.toBytes();
      final recovered = SenderCertificate.fromBytes(bytes);

      expect(recovered.senderUserId, cert.senderUserId);
      expect(recovered.senderDeviceId, cert.senderDeviceId);
      expect(recovered.senderIdentityKey, cert.senderIdentityKey);
      expect(recovered.expiresAt, cert.expiresAt);
      expect(recovered.signature, cert.signature);
    });
  });

  group('SealedSenderEnvelope', () {
    test('serializes and deserializes correctly', () {
      final envelope = SealedSenderEnvelope(
        version: 1,
        ephemeralPublicKey: Uint8List.fromList(List.generate(32, (i) => i)),
        encryptedPayload: Uint8List.fromList(List.generate(100, (i) => i * 2)),
      );

      final bytes = envelope.toBytes();
      final recovered = SealedSenderEnvelope.fromBytes(bytes);

      expect(recovered.version, envelope.version);
      expect(recovered.ephemeralPublicKey, envelope.ephemeralPublicKey);
      expect(recovered.encryptedPayload, envelope.encryptedPayload);
    });

    test('rejects unsupported version', () {
      final bytes = Uint8List.fromList([
        2, // Invalid version
        ...List.generate(32, (i) => i), // pubkey
        ...List.generate(28, (i) => i), // min payload
      ]);

      expect(
        () => SealedSenderEnvelope.fromBytes(bytes),
        throwsFormatException,
      );
    });

    test('rejects too short envelope', () {
      final bytes = Uint8List.fromList([1, 2, 3]); // Too short

      expect(
        () => SealedSenderEnvelope.fromBytes(bytes),
        throwsFormatException,
      );
    });
  });

  group('SealedSender', () {
    late Uint8List senderSigningPrivateKey;
    late Uint8List senderSigningPublicKey;
    late Uint8List recipientPublicKey;
    late Uint8List recipientPrivateKey;

    setUpAll(() async {
      // Generate sender Ed25519 keys for signing
      final (senderPub, senderPriv) =
          await CryptoPrimitives.generateEd25519KeyPair();
      senderSigningPublicKey = senderPub;
      senderSigningPrivateKey = senderPriv;

      // Generate recipient X25519 keys for encryption
      final (recipientPub, recipientPriv) =
          await CryptoPrimitives.generateX25519KeyPair();
      recipientPublicKey = recipientPub;
      recipientPrivateKey = recipientPriv;
    });

    test('seals and unseals message successfully', () async {
      // Create sender certificate
      final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400;
      final senderCert = await SenderCertificate.create(
        senderUserId: 'sender-user',
        senderDeviceId: 'sender-device',
        signingPrivateKey: senderSigningPrivateKey,
        signingPublicKey: senderSigningPublicKey,
        expiresAt: expiresAt,
      );

      // Seal message
      final innerMessage = Uint8List.fromList('Hello, secret world!'.codeUnits);
      final envelope = await SealedSender.seal(
        certificate: senderCert,
        recipientPublicKey: recipientPublicKey,
        innerMessage: innerMessage,
      );

      expect(envelope.version, 1);
      expect(envelope.ephemeralPublicKey.length, 32);
      expect(envelope.encryptedPayload.isNotEmpty, isTrue);

      // Unseal message
      final result = await SealedSender.unseal(
        envelope: envelope,
        recipientPrivateKey: recipientPrivateKey,
      );

      expect(result.senderCertificate.senderUserId, 'sender-user');
      expect(result.senderCertificate.senderDeviceId, 'sender-device');
      expect(result.innerMessage, innerMessage);
    });

    test('envelope serialization round trip works', () async {
      final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400;
      final senderCert = await SenderCertificate.create(
        senderUserId: 'sender-user',
        senderDeviceId: 'sender-device',
        signingPrivateKey: senderSigningPrivateKey,
        signingPublicKey: senderSigningPublicKey,
        expiresAt: expiresAt,
      );

      final innerMessage = Uint8List.fromList('Test message'.codeUnits);

      final envelope = await SealedSender.seal(
        certificate: senderCert,
        recipientPublicKey: recipientPublicKey,
        innerMessage: innerMessage,
      );

      // Serialize and deserialize
      final bytes = envelope.toBytes();
      final recoveredEnvelope = SealedSenderEnvelope.fromBytes(bytes);

      // Unseal recovered envelope
      final result = await SealedSender.unseal(
        envelope: recoveredEnvelope,
        recipientPrivateKey: recipientPrivateKey,
      );

      expect(result.innerMessage, innerMessage);
    });

    test('rejects expired certificate during unseal', () async {
      final expiresAt =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600; // Expired

      final senderCert = await SenderCertificate.create(
        senderUserId: 'sender-user',
        senderDeviceId: 'sender-device',
        signingPrivateKey: senderSigningPrivateKey,
        signingPublicKey: senderSigningPublicKey,
        expiresAt: expiresAt,
      );

      final innerMessage = Uint8List.fromList('Test'.codeUnits);

      final envelope = await SealedSender.seal(
        certificate: senderCert,
        recipientPublicKey: recipientPublicKey,
        innerMessage: innerMessage,
      );

      expect(
        () async => SealedSender.unseal(
          envelope: envelope,
          recipientPrivateKey: recipientPrivateKey,
        ),
        throwsA(isA<SecurityException>()),
      );
    });

    test('wrong recipient cannot decrypt', () async {
      // Generate a different recipient keypair
      final (_, wrongPrivateKey) =
          await CryptoPrimitives.generateX25519KeyPair();

      final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400;
      final senderCert = await SenderCertificate.create(
        senderUserId: 'sender-user',
        senderDeviceId: 'sender-device',
        signingPrivateKey: senderSigningPrivateKey,
        signingPublicKey: senderSigningPublicKey,
        expiresAt: expiresAt,
      );

      final innerMessage = Uint8List.fromList('Secret'.codeUnits);

      final envelope = await SealedSender.seal(
        certificate: senderCert,
        recipientPublicKey: recipientPublicKey,
        innerMessage: innerMessage,
      );

      // Try to unseal with wrong key
      expect(
        () async => SealedSender.unseal(
          envelope: envelope,
          recipientPrivateKey: wrongPrivateKey,
        ),
        throwsA(anything), // Will fail decryption
      );
    });

    test('tampered envelope fails decryption', () async {
      final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400;
      final senderCert = await SenderCertificate.create(
        senderUserId: 'sender-user',
        senderDeviceId: 'sender-device',
        signingPrivateKey: senderSigningPrivateKey,
        signingPublicKey: senderSigningPublicKey,
        expiresAt: expiresAt,
      );

      final innerMessage = Uint8List.fromList('Secret'.codeUnits);

      final envelope = await SealedSender.seal(
        certificate: senderCert,
        recipientPublicKey: recipientPublicKey,
        innerMessage: innerMessage,
      );

      // Tamper with payload
      final tamperedPayload = Uint8List.fromList(envelope.encryptedPayload);
      tamperedPayload[tamperedPayload.length - 1] ^= 0xFF;

      final tamperedEnvelope = SealedSenderEnvelope(
        version: envelope.version,
        ephemeralPublicKey: envelope.ephemeralPublicKey,
        encryptedPayload: tamperedPayload,
      );

      expect(
        () async => SealedSender.unseal(
          envelope: tamperedEnvelope,
          recipientPrivateKey: recipientPrivateKey,
        ),
        throwsA(anything), // Will fail MAC verification
      );
    });
  });
}
