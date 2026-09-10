/// Proves that CryptoService applies PADMÉ, rather than merely owning a correct
/// implementation of it.
///
/// Padding was a no-op on this client for its whole history: `padMessage` had no production
/// caller anywhere in `lib/`, so ciphertext length tracked plaintext length exactly and the
/// `enablePadme` flag was inert. A unit test of `padme.dart` alone cannot catch a regression
/// that simply stops calling it, which is what these assert against.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/crypto/message_aad.dart';
import 'package:guardyn_client/core/crypto/padme.dart' as padme;
import 'package:mocktail/mocktail.dart';

import 'crypto_test_helper.dart';

/// An in-memory stand-in for the platform keystore.
class _FakeSecureStorage extends Mock implements FlutterSecureStorage {
  final Map<String, String> store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store.remove(key);
  }
}

void main() {
  setUpAll(() async {
    await initializeCryptoForTests();
  });

  cryptoGroup('CryptoService applies PADMÉ', () {
    late CryptoService alice;

    setUp(() async {
      alice = CryptoService(storage: _FakeSecureStorage());
      await alice.initialize();
      await alice.initializeX3DH(oneTimePreKeyCount: 2);
    });

    Future<void> openSessionToBob() async {
      final bobService = CryptoService(storage: _FakeSecureStorage());
      await bobService.initialize();
      await bobService.initializeX3DH(oneTimePreKeyCount: 2);
      final bobBundle = bobService.exportKeyBundles().first;

      await alice.createSessionAsInitiator(
        recipientUserId: 'bob',
        recipientDeviceId: 'device-1',
        remoteKeyBundle: bobBundle,
      );
    }

    Future<int> ciphertextLengthFor(String text) async {
      final bytes = await alice.encrypt(
        recipientUserId: 'bob',
        recipientDeviceId: 'device-1',
        plaintext: Uint8List.fromList(utf8.encode(text)),
        associatedData: messageAssociatedData(
          senderUserId: 'alice',
          recipientUserId: 'bob',
        ),
      );
      return bytes.length;
    }

    test('short messages of different lengths share a ciphertext length', () async {
      await openSessionToBob();

      // 'a' and a 20-character message both fall in the 32-byte PADMÉ bucket, so an observer
      // cannot tell them apart by size. Without padding these differ by 19 bytes.
      final short = await ciphertextLengthFor('a');
      final longer = await ciphertextLengthFor('12345678901234567890');

      expect(short, equals(longer));
    });

    test('ciphertext length follows the PADMÉ schedule, not the plaintext', () async {
      await openSessionToBob();

      // Ciphertext is version(1) + len(4) + header(40) + nonce(12) + padded + tag(16).
      const overhead = 1 + 4 + 40 + 12 + 16;

      for (final text in ['a', 'hello there', 'x' * 100, 'y' * 300]) {
        final len = await ciphertextLengthFor(text);
        final expectedPadded = padme.nextPadmeLength(utf8.encode(text).length);
        expect(
          len,
          equals(overhead + expectedPadded),
          reason: 'ciphertext for ${text.length} chars should carry '
              '$expectedPadded padded bytes',
        );
      }
    });

    test('a 300-byte message is not the same size as a 100-byte one', () async {
      await openSessionToBob();

      // Padding hides length within a bucket, not across buckets - the property is
      // indistinguishability among neighbours, not uniformity.
      expect(
        await ciphertextLengthFor('x' * 100),
        isNot(equals(await ciphertextLengthFor('y' * 300))),
      );
    });
  });
}
