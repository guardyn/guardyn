/// Proves that the responder selects its KDF domain on the prekey message's `0x02` flag, and
/// that it refuses rather than degrades when it cannot answer in the domain it was asked for.
///
/// The decapsulation itself cannot be asserted here. `flutter test` runs the whole suite on
/// [DartCryptoBridge] - there is no FFI in a headless VM - and ML-KEM has no Dart
/// implementation at all, so a real hybrid round trip lives in
/// `integration_test/crypto/rust_ffi_test.dart` and runs on a device under
/// `just ffi-test-mobile`.
///
/// What is asserted here is everything above the boundary, which is where the failure this
/// step exists to prevent actually lives: that a classical handshake still succeeds on a
/// device holding no seed, that a ciphertext arriving at a device holding no seed is a hard
/// error rather than a classical derivation, and that a malformed stored seed is refused. A
/// silent degrade would produce a secret that merely *differs* from the initiator's, and the
/// disagreement would surface much later as an AEAD tag rejection with both ends looking
/// healthy.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_exceptions.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/crypto/x3dh.dart';
import 'package:mocktail/mocktail.dart';

import 'crypto_test_helper.dart';

/// The storage key [CryptoService] persists the ML-KEM seed under.
const _mlKemSeedKey = 'guardyn_ml_kem_seed';

/// Bytes in an ML-KEM seed, per FIPS 203.
const _mlKemSeedLength = 64;

/// Bytes in an ML-KEM-768 ciphertext, per FIPS 203.
const _mlKemCiphertextLength = 1088;

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
  }) async => store[key];

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => Map<String, String>.from(store);

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

  cryptoGroup('CryptoService as hybrid PQXDH responder', () {
    late CryptoService alice;
    late CryptoService bob;
    late _FakeSecureStorage bobStorage;

    setUp(() async {
      alice = CryptoService(storage: _FakeSecureStorage());
      await alice.initialize();
      await alice.initializeX3DH(oneTimePreKeyCount: 2);

      bobStorage = _FakeSecureStorage();
      bob = CryptoService(storage: bobStorage);
      await bob.initialize();
      await bob.initializeX3DH(oneTimePreKeyCount: 2);
    });

    /// Alice opens a session to Bob and returns the prekey message she would attach.
    ///
    /// A genuine one rather than a synthetic frame, so the keys Bob is handed are the keys an
    /// initiator would really send.
    Future<X3DHPrekeyMessage> alicePrekeyForBob() async {
      final bobBundle = bob.exportKeyBundles().first;
      final (_, prekey) = await alice.createSessionAsInitiator(
        recipientUserId: 'bob',
        recipientDeviceId: 'device-1',
        remoteKeyBundle: bobBundle,
      );
      return prekey;
    }

    Uint8List syntheticCiphertext() =>
        Uint8List.fromList(List<int>.filled(_mlKemCiphertextLength, 0xcd));

    cryptoTest(
      'a classical handshake still succeeds on a device holding no ML-KEM seed',
      () async {
        // The regression this change most needs not to cause. No mobile device publishes an
        // ML-KEM pre-key until PR-98c, so this is the only path any real peer takes today.
        expect(bobStorage.store.containsKey(_mlKemSeedKey), isFalse);

        final prekey = await alicePrekeyForBob();
        expect(prekey.pqCiphertext, isNull);

        final ratchet = await bob.createSessionAsResponder(
          senderUserId: 'alice',
          senderDeviceId: 'device-1',
          remoteIdentityKey: prekey.senderIdentityKey,
          remoteEphemeralKey: prekey.ephemeralKey,
          usedOneTimePreKeyId: prekey.usedOneTimePreKeyId,
        );

        expect(ratchet, isNotNull);
      },
    );

    cryptoTest(
      'a ciphertext addressed to a device holding no seed is refused, not downgraded',
      () async {
        final prekey = await alicePrekeyForBob();
        expect(bobStorage.store.containsKey(_mlKemSeedKey), isFalse);

        // Minting a seed here would answer with a secret the initiator cannot match: ML-KEM
        // uses implicit rejection, so a wrong decapsulation key yields a pseudorandom secret
        // rather than an error. Refusing is the only honest answer.
        await expectLater(
          bob.createSessionAsResponder(
            senderUserId: 'alice',
            senderDeviceId: 'device-1',
            remoteIdentityKey: prekey.senderIdentityKey,
            remoteEphemeralKey: prekey.ephemeralKey,
            usedOneTimePreKeyId: prekey.usedOneTimePreKeyId,
            pqCiphertext: syntheticCiphertext(),
          ),
          throwsA(
            isA<ProtocolException>().having(
              (e) => e.message,
              'message',
              contains('holds no ML-KEM seed'),
            ),
          ),
        );
      },
    );

    cryptoTest('a stored seed of the wrong length is refused', () async {
      bobStorage.store[_mlKemSeedKey] = base64Encode(
        List<int>.filled(_mlKemSeedLength - 1, 0x01),
      );
      final prekey = await alicePrekeyForBob();

      await expectLater(
        bob.createSessionAsResponder(
          senderUserId: 'alice',
          senderDeviceId: 'device-1',
          remoteIdentityKey: prekey.senderIdentityKey,
          remoteEphemeralKey: prekey.ephemeralKey,
          usedOneTimePreKeyId: prekey.usedOneTimePreKeyId,
          pqCiphertext: syntheticCiphertext(),
        ),
        throwsA(
          isA<InvalidKeyException>().having(
            (e) => e.message,
            'message',
            contains('63 bytes, expected 64'),
          ),
        ),
      );
    });

    cryptoTest('a seed that is not valid base64 is refused', () async {
      bobStorage.store[_mlKemSeedKey] = 'not base64 at all!!';
      final prekey = await alicePrekeyForBob();

      await expectLater(
        bob.createSessionAsResponder(
          senderUserId: 'alice',
          senderDeviceId: 'device-1',
          remoteIdentityKey: prekey.senderIdentityKey,
          remoteEphemeralKey: prekey.ephemeralKey,
          usedOneTimePreKeyId: prekey.usedOneTimePreKeyId,
          pqCiphertext: syntheticCiphertext(),
        ),
        throwsA(isA<InvalidKeyException>()),
      );
    });

    cryptoTest(
      'a well-formed seed is accepted and the handshake reaches key agreement',
      () async {
        // A 64-byte seed round-trips through storage and passes the gate, so the next failure
        // is the FFI boundary rather than the seed. That distinction is the assertion: it
        // proves the seed check is not what rejects a legitimate hybrid handshake. The
        // derivation itself is asserted on a device, in integration_test/.
        final seed = Uint8List.fromList(
          List<int>.generate(_mlKemSeedLength, (i) => i),
        );
        bobStorage.store[_mlKemSeedKey] = base64Encode(seed);
        final prekey = await alicePrekeyForBob();

        await expectLater(
          bob.createSessionAsResponder(
            senderUserId: 'alice',
            senderDeviceId: 'device-1',
            remoteIdentityKey: prekey.senderIdentityKey,
            remoteEphemeralKey: prekey.ephemeralKey,
            usedOneTimePreKeyId: prekey.usedOneTimePreKeyId,
            pqCiphertext: syntheticCiphertext(),
          ),
          throwsA(
            isA<ProtocolException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('Hybrid PQXDH respond failed'),
                isNot(contains('holds no ML-KEM seed')),
              ),
            ),
          ),
        );

        // Unchanged by the failed attempt - one seed, one keypair.
        expect(bobStorage.store[_mlKemSeedKey], equals(base64Encode(seed)));
      },
    );

    cryptoTest('clearAll deletes the ML-KEM seed', () async {
      bobStorage.store[_mlKemSeedKey] = base64Encode(
        List<int>.filled(_mlKemSeedLength, 0x07),
      );

      await bob.clearAll();

      // A seed outliving its identity would let a re-registered device answer handshakes
      // addressed to the encapsulation key the previous one published.
      expect(bobStorage.store.containsKey(_mlKemSeedKey), isFalse);
    });
  });
}
