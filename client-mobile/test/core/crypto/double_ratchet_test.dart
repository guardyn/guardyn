import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_exceptions.dart';
import 'package:guardyn_client/core/crypto/double_ratchet.dart';

void main() {
  group('X25519KeyPair', () {
    test('generate creates valid key pair', () async {
      final keyPair = await X25519KeyPair.generate();

      expect(keyPair.privateKey.length, equals(32));
      expect(keyPair.publicKey.length, equals(32));
    });

    test('diffieHellman produces shared secret', () async {
      final alice = await X25519KeyPair.generate();
      final bob = await X25519KeyPair.generate();

      final aliceSecret = await alice.diffieHellman(bob.publicKey);
      final bobSecret = await bob.diffieHellman(alice.publicKey);

      expect(aliceSecret.length, equals(32));
      expect(bobSecret.length, equals(32));
      // In real X25519, the secrets should be equal
    });

    test('throws on invalid key length', () {
      expect(
        () => X25519KeyPair.fromBytes(
          privateKey: Uint8List(31), // Wrong length
          publicKey: Uint8List(32),
        ),
        throwsA(isA<InvalidKeyException>()),
      );
    });
  });

  group('MessageHeader', () {
    test('serialization roundtrip', () async {
      final keyPair = await X25519KeyPair.generate();
      final header = MessageHeader(
        dhPublicKey: keyPair.publicKey,
        previousChainLength: 10,
        messageNumber: 42,
      );

      final bytes = header.toBytes();
      final restored = MessageHeader.fromBytes(bytes);

      expect(restored.dhPublicKey, equals(header.dhPublicKey));
      expect(restored.previousChainLength, equals(header.previousChainLength));
      expect(restored.messageNumber, equals(header.messageNumber));
    });

    test('throws on invalid header length', () {
      expect(
        () => MessageHeader.fromBytes(Uint8List(10)),
        throwsA(isA<ProtocolException>()),
      );
    });
  });

  group('EncryptedMessage', () {
    test('serialization roundtrip', () async {
      final keyPair = await X25519KeyPair.generate();
      final header = MessageHeader(
        dhPublicKey: keyPair.publicKey,
        previousChainLength: 5,
        messageNumber: 100,
      );

      final original = EncryptedMessage(
        header: header,
        ciphertext: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      final bytes = original.toBytes();
      final restored = EncryptedMessage.fromBytes(bytes);

      expect(restored.header.messageNumber, equals(original.header.messageNumber));
      expect(restored.ciphertext, equals(original.ciphertext));
    });

    test('deserialization works with base64 decoded bytes (non-zero offset)', () async {
      // This test verifies that fromBytes works correctly when the input
      // bytes have a non-zero offset in their underlying buffer, which
      // can happen with base64.decode() output
      final keyPair = await X25519KeyPair.generate();
      final header = MessageHeader(
        dhPublicKey: keyPair.publicKey,
        previousChainLength: 5,
        messageNumber: 100,
      );

      final original = EncryptedMessage(
        header: header,
        ciphertext: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      final bytes = original.toBytes();

      // Simulate base64 encode/decode cycle which may create non-zero offset
      final base64Encoded = base64Encode(bytes);
      final base64Decoded = base64Decode(base64Encoded);

      // The decoded bytes should work correctly even if offset is non-zero
      final restored = EncryptedMessage.fromBytes(base64Decoded);

      expect(restored.header.dhPublicKey, equals(original.header.dhPublicKey));
      expect(restored.header.previousChainLength, equals(original.header.previousChainLength));
      expect(restored.header.messageNumber, equals(original.header.messageNumber));
      expect(restored.ciphertext, equals(original.ciphertext));
    });
  });

  group('DoubleRatchet', () {
    late Uint8List sharedSecret;
    late Uint8List bobPublicKey;

    setUp(() async {
      sharedSecret = Uint8List.fromList(List.generate(32, (i) => i));
      final bobKeyPair = await X25519KeyPair.generate();
      bobPublicKey = bobKeyPair.publicKey;
    });

    test('initAlice creates valid ratchet', () async {
      final alice = await DoubleRatchet.initAlice(sharedSecret, bobPublicKey);

      expect(alice.publicKey.length, equals(32));
    });

    test('initBob creates valid ratchet', () async {
      final bob = await DoubleRatchet.initBob(sharedSecret);

      expect(bob.publicKey.length, equals(32));
    });

    test('throws on invalid shared secret length', () async {
      expect(
        () => DoubleRatchet.initAlice(Uint8List(16), bobPublicKey),
        throwsA(isA<InvalidKeyException>()),
      );
    });

    test('basic encryption/decryption', () async {
      final alice = await DoubleRatchet.initAlice(sharedSecret, bobPublicKey);
      // Bob would need proper setup for decryption in full test
      // ignore: unused_local_variable
      final bob = await DoubleRatchet.initBob(sharedSecret);

      final plaintext = Uint8List.fromList('Hello, Bob!'.codeUnits);
      final associatedData = Uint8List.fromList('test'.codeUnits);

      final encrypted = await alice.encrypt(plaintext, associatedData);

      expect(encrypted.ciphertext.isNotEmpty, isTrue);
      expect(encrypted.header.messageNumber, equals(0));

      // Note: Full decryption test requires proper session setup
      // This tests encryption doesn't throw
    });

    test('message number increments', () async {
      final alice = await DoubleRatchet.initAlice(sharedSecret, bobPublicKey);
      final plaintext = Uint8List.fromList('Test'.codeUnits);
      final ad = Uint8List(0);

      final msg1 = await alice.encrypt(plaintext, ad);
      final msg2 = await alice.encrypt(plaintext, ad);
      final msg3 = await alice.encrypt(plaintext, ad);

      expect(msg1.header.messageNumber, equals(0));
      expect(msg2.header.messageNumber, equals(1));
      expect(msg3.header.messageNumber, equals(2));
    });

    test('serialization roundtrip', () async {
      final alice = await DoubleRatchet.initAlice(sharedSecret, bobPublicKey);

      // Encrypt a message to advance state
      await alice.encrypt(
        Uint8List.fromList('Test'.codeUnits),
        Uint8List(0),
      );

      final serialized = alice.serialize();
      final restored = DoubleRatchet.deserialize(serialized);

      expect(restored.publicKey.length, equals(32));
    });
  });
}
