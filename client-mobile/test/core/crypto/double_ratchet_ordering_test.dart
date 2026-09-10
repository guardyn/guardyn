/// Out-of-order delivery tests for the Double Ratchet.
///
/// These are regression tests for #198. The suite had no coverage of skipped message keys at
/// all - nothing in `double_ratchet_test.dart` mentions `skip` or reordering - which is how
/// two defects in `_skipMessageKeys` survived: the loop advanced `_receivingMessageNumber` to
/// `until` and then discarded it with `= 0`, and the `MAX_SKIP` bound counted the size of the
/// *gap* rather than the size of the stored map.
///
/// They also exercise the only realistic Alice/Bob pairing: `initBob` generates its own DH
/// key pair, so Alice must be initialised from `bob.publicKey` for the first DH ratchet on
/// Bob's side to succeed.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_exceptions.dart';
import 'package:guardyn_client/core/crypto/double_ratchet.dart';

import 'crypto_test_helper.dart';

void main() {
  setUpAll(() async {
    await initializeCryptoForTests();
  });

  final ad = Uint8List.fromList(utf8.encode('alice|bob'));
  late Uint8List sharedSecret;

  setUp(() {
    sharedSecret = Uint8List.fromList(List.generate(32, (i) => i));
  });

  Future<(DoubleRatchet alice, DoubleRatchet bob)> pair() async {
    final bob = await DoubleRatchet.initBob(sharedSecret);
    final alice = await DoubleRatchet.initAlice(sharedSecret, bob.publicKey);
    return (alice, bob);
  }

  cryptoGroup('out-of-order delivery', () {
    test('in-order delivery still works', () async {
      final (alice, bob) = await pair();

      for (var i = 0; i < 5; i++) {
        final msg = await alice.encrypt(
          Uint8List.fromList(utf8.encode('message $i')),
          ad,
        );
        final got = await bob.decrypt(msg, ad);
        expect(utf8.decode(got), equals('message $i'));
      }
    });

    test('a later message decrypts before the ones it skipped', () async {
      final (alice, bob) = await pair();

      final m0 = await alice.encrypt(Uint8List.fromList(utf8.encode('zero')), ad);
      final m1 = await alice.encrypt(Uint8List.fromList(utf8.encode('one')), ad);
      final m2 = await alice.encrypt(Uint8List.fromList(utf8.encode('two')), ad);

      // Bob sees the third message first; 0 and 1 are staged as skipped keys.
      expect(utf8.decode(await bob.decrypt(m2, ad)), equals('two'));

      // Then the stragglers arrive, in the wrong order relative to each other.
      expect(utf8.decode(await bob.decrypt(m1, ad)), equals('one'));
      expect(utf8.decode(await bob.decrypt(m0, ad)), equals('zero'));
    });

    test('the receive counter is not reset after skipping', () async {
      // The regression that #198 names. `_skipMessageKeys` used to finish with
      // `_receivingMessageNumber = 0`, throwing away the position it had just walked to. The
      // next in-order message then re-entered the skip loop from 1, re-derived keys for
      // indices it had already stored, and walked the receiving chain past the key it needed.
      final (alice, bob) = await pair();

      final msgs = <EncryptedMessage>[];
      for (var i = 0; i < 4; i++) {
        msgs.add(
          await alice.encrypt(Uint8List.fromList(utf8.encode('m$i')), ad),
        );
      }

      // Skip ahead to index 2, then continue in order with index 3.
      expect(utf8.decode(await bob.decrypt(msgs[2], ad)), equals('m2'));
      expect(utf8.decode(await bob.decrypt(msgs[3], ad)), equals('m3'));

      // And the skipped ones are still recoverable.
      expect(utf8.decode(await bob.decrypt(msgs[0], ad)), equals('m0'));
      expect(utf8.decode(await bob.decrypt(msgs[1], ad)), equals('m1'));
    });

    test('a skipped key is consumed exactly once', () async {
      final (alice, bob) = await pair();

      final m0 = await alice.encrypt(Uint8List.fromList(utf8.encode('zero')), ad);
      final m1 = await alice.encrypt(Uint8List.fromList(utf8.encode('one')), ad);

      expect(utf8.decode(await bob.decrypt(m1, ad)), equals('one'));
      expect(utf8.decode(await bob.decrypt(m0, ad)), equals('zero'));

      // Replaying m0 must not succeed - its key was removed when it was used.
      await expectLater(bob.decrypt(m0, ad), throwsA(isA<Exception>()));
    });

    test('the bound counts stored keys, not the size of one gap', () async {
      // The second #198 defect. The old guard was
      //   if (_receivingMessageNumber + _maxSkip < until) throw
      // which bounds a single gap. Many small gaps could therefore grow the stored map
      // without limit - exactly the memory exhaustion the bound exists to prevent. The bound
      // now counts the map itself, and is checked inside the loop.
      final (alice, bob) = await pair();

      // Produce more messages than the ratchet is willing to stage keys for.
      const overshoot = 1200; // > _maxSkip (1000)
      late EncryptedMessage far;
      for (var i = 0; i <= overshoot; i++) {
        far = await alice.encrypt(Uint8List.fromList(utf8.encode('m$i')), ad);
      }

      await expectLater(bob.decrypt(far, ad), throwsA(isA<ProtocolException>()));
    });
  });
}
