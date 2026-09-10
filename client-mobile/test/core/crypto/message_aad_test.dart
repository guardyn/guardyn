/// Tests for the canonical caller-side associated data, and for UTF-8 correctness.
///
/// Both clients must compute identical AAD bytes or no message crosses between them. Two
/// things used to break that:
///
///   * `client-desktop` passed `recipient_id` when encrypting and `sender_id` when decrypting,
///     so the two ends never agreed;
///   * `client-mobile` built the string with `String.codeUnits`, which yields UTF-16 units and
///     is then truncated by `Uint8List.fromList`, so any non-ASCII identifier silently
///     produced different bytes.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/double_ratchet.dart';
import 'package:guardyn_client/core/crypto/message_aad.dart';

import 'crypto_test_helper.dart';

void main() {
  setUpAll(() async {
    await initializeCryptoForTests();
  });

  group('messageAssociatedData', () {
    test('is utf8("{sender}|{recipient}")', () {
      expect(
        messageAssociatedData(senderUserId: 'alice', recipientUserId: 'bob'),
        equals(Uint8List.fromList(utf8.encode('alice|bob'))),
      );
    });

    test('both ends of one message compute identical bytes', () {
      // The sender knows itself as "me" and the peer as the recipient; the receiver knows the
      // peer as the sender and itself as "me". Naming originator-then-destination is what
      // makes those two views agree.
      final sending = messageAssociatedData(
        senderUserId: 'alice',
        recipientUserId: 'bob',
      );
      final receiving = messageAssociatedData(
        senderUserId: 'alice',
        recipientUserId: 'bob',
      );
      expect(sending, equals(receiving));
    });

    test('is directional', () {
      expect(
        messageAssociatedData(senderUserId: 'alice', recipientUserId: 'bob'),
        isNot(
          equals(
            messageAssociatedData(
              senderUserId: 'bob',
              recipientUserId: 'alice',
            ),
          ),
        ),
      );
    });

    test('encodes non-ASCII identifiers as UTF-8, not truncated UTF-16', () {
      const sender = 'Пётр';
      final aad = messageAssociatedData(
        senderUserId: sender,
        recipientUserId: 'bob',
      );

      expect(aad, equals(Uint8List.fromList(utf8.encode('$sender|bob'))));

      // The old construction. Every Cyrillic code unit exceeds 0xFF, so Uint8List.fromList
      // truncates it - a different byte string entirely.
      final broken = Uint8List.fromList('$sender|bob'.codeUnits);
      expect(aad, isNot(equals(broken)));
    });
  });

  cryptoGroup('non-ASCII message round trip', () {
    test('Cyrillic and emoji survive encrypt/decrypt', () async {
      final secret = Uint8List.fromList(List.generate(32, (i) => i));
      final bob = await DoubleRatchet.initBob(secret);
      final alice = await DoubleRatchet.initAlice(secret, bob.publicKey);

      final ad = messageAssociatedData(
        senderUserId: 'Пётр',
        recipientUserId: 'bob',
      );

      // A messaging product has to prove non-Latin text round-trips; the repository keeps
      // Cyrillic fixtures for exactly this reason.
      const messages = ['Привет, мир!', 'ऄआइ', '🔐 end-to-end 🎉', 'plain ascii'];

      for (final text in messages) {
        final encrypted = await alice.encrypt(
          Uint8List.fromList(utf8.encode(text)),
          ad,
        );
        final decrypted = await bob.decrypt(encrypted, ad);
        expect(utf8.decode(decrypted), equals(text));

        // And the old encoding would not have survived: codeUnits truncates above 0xFF.
        if (text.codeUnits.any((u) => u > 0xff)) {
          expect(
            Uint8List.fromList(text.codeUnits),
            isNot(equals(Uint8List.fromList(utf8.encode(text)))),
          );
        }
      }
    });
  });
}
