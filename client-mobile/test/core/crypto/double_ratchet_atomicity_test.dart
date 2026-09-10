/// Atomicity tests for Double Ratchet decryption.
///
/// The Dart mirror of #106, fixed in Rust by `0be3de17` and never carried across. Before
/// that fix, `decrypt` mutated the session before the AEAD tag was checked:
///
///   * `_dhRatchetReceive` rotated `_dhRemote`, `_rootKey` and both chain keys as soon as it
///     saw an unfamiliar DH public key - so a single forged header destroyed the session,
///     even when the skip loop never ran.
///   * a skipped message key was removed from the map and *then* used, so one corrupted copy
///     of a message burned the key needed by the genuine one.
///
/// Binding the header into the AAD (#213) narrows the first case but does not close it: the
/// mutation still happened before the tag was verified.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/double_ratchet.dart';

import 'crypto_test_helper.dart';

void main() {
  setUpAll(() async {
    await initializeCryptoForTests();
  });

  final ad = Uint8List.fromList(utf8.encode('alice|bob'));

  Future<(DoubleRatchet alice, DoubleRatchet bob)> pair() async {
    final secret = Uint8List.fromList(List.generate(32, (i) => i));
    final bob = await DoubleRatchet.initBob(secret);
    final alice = await DoubleRatchet.initAlice(secret, bob.publicKey);
    return (alice, bob);
  }

  cryptoGroup('decryption is atomic', () {
    test('a forged header does not poison the session', () async {
      final (alice, bob) = await pair();

      final genuine = await alice.encrypt(
        Uint8List.fromList(utf8.encode('genuine')),
        ad,
      );

      // A header claiming a DH public key Bob has never seen. Before the fix this drove
      // _dhRatchetReceive on the live session, rotating the root key and both chain keys,
      // after which no genuine message could ever be decrypted again.
      final forgedKey = (await X25519KeyPair.generate()).publicKey;
      final forged = EncryptedMessage(
        header: MessageHeader(
          dhPublicKey: forgedKey,
          previousChainLength: 0,
          messageNumber: 0,
        ),
        ciphertext: genuine.ciphertext,
      );

      await expectLater(bob.decrypt(forged, ad), throwsA(isA<Exception>()));

      // The session must be exactly as it was.
      expect(utf8.decode(await bob.decrypt(genuine, ad)), equals('genuine'));
    });

    test('a forged header that would trip the skip bound changes nothing', () async {
      final (alice, bob) = await pair();

      final genuine = await alice.encrypt(
        Uint8List.fromList(utf8.encode('still here')),
        ad,
      );

      // An absurd message number on the real DH key: the skip loop tries to stage far more
      // keys than _maxSkip allows and throws. That must leave no partial state behind.
      final forged = EncryptedMessage(
        header: MessageHeader(
          dhPublicKey: genuine.header.dhPublicKey,
          previousChainLength: 0,
          messageNumber: 500000,
        ),
        ciphertext: genuine.ciphertext,
      );

      await expectLater(bob.decrypt(forged, ad), throwsA(isA<Exception>()));
      expect(bob.skippedMessagesCount, equals(0));

      expect(utf8.decode(await bob.decrypt(genuine, ad)), equals('still here'));
    });

    test('a failed skipped-key decrypt keeps the key', () async {
      final (alice, bob) = await pair();

      final m0 = await alice.encrypt(Uint8List.fromList(utf8.encode('zero')), ad);
      final m1 = await alice.encrypt(Uint8List.fromList(utf8.encode('one')), ad);

      // Receiving m1 first stages a skipped key for m0.
      expect(utf8.decode(await bob.decrypt(m1, ad)), equals('one'));
      expect(bob.skippedMessagesCount, equals(1));

      // A corrupted copy of m0: same header, mangled ciphertext. Before the fix the key was
      // removed before the decrypt was attempted, so this destroyed the ability to read the
      // genuine m0 that follows.
      final corrupted = EncryptedMessage(
        header: m0.header,
        ciphertext: Uint8List.fromList(
          m0.ciphertext.map((b) => b ^ 0xff).toList(),
        ),
      );
      await expectLater(bob.decrypt(corrupted, ad), throwsA(isA<Exception>()));
      expect(bob.skippedMessagesCount, equals(1));

      // The genuine message still decrypts.
      expect(utf8.decode(await bob.decrypt(m0, ad)), equals('zero'));
      expect(bob.skippedMessagesCount, equals(0));
    });
  });
}
