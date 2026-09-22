/// Proves both halves of hybrid PQXDH as `CryptoService` implements them: the responder
/// selects its KDF domain on the prekey message's `0x02` flag and refuses rather than degrades
/// when it cannot answer in the domain it was asked for, and the publisher emits an ML-KEM
/// pre-key and its signature together or emits neither.
///
/// They share a file because they share a seed. The key the publisher advertises must be the
/// one the responder decapsulates with, and the cheapest way to keep that true is to let both
/// sets of assertions run against the same storage fake.
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
import 'package:guardyn_client/core/crypto/crypto_primitives.dart';
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

/// Bytes in an ML-KEM-768 encapsulation key, per FIPS 203.
const _mlKemPublicLength = 1184;

/// Bytes in an Ed25519 signature.
const _signatureLength = 64;

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

  cryptoGroup('CryptoService as hybrid PQXDH publisher', () {
    late CryptoService service;
    late _FakeSecureStorage storage;

    setUp(() async {
      storage = _FakeSecureStorage();
      service = CryptoService(storage: storage);
      await service.initialize();
      await service.initializeX3DH(oneTimePreKeyCount: 1);
    });

    cryptoTest('publishes nothing on a device with no post-quantum capability', () async {
      // The path every CI run takes, and the one every classical peer depends on. A null here
      // is what makes the caller send tags 1-5 only, which is a bundle the server accepts.
      expect(
        CryptoPrimitives.isPostQuantumAvailable,
        isFalse,
        reason: 'DartCryptoBridge has no ML-KEM; the suite runs on it',
      );

      expect(await service.mlKemPreKeyForPublication(), isNull);
    });

    cryptoTest('never mints a seed', () async {
      // Publishing must read the seed the responder already answers with. Minting one here
      // would advertise an encapsulation key whose decapsulation key the responder does not
      // hold, and ML-KEM's implicit rejection means that surfaces only as an AEAD tag
      // rejection later, with both ends looking healthy.
      expect(storage.store.containsKey(_mlKemSeedKey), isFalse);

      await service.mlKemPreKeyForPublication();

      expect(
        storage.store.containsKey(_mlKemSeedKey),
        isFalse,
        reason: 'the publisher reads the seed, it does not create one',
      );
    });

    cryptoTest('degrades to classical rather than throwing with no seed stored', () async {
      storage.store.remove(_mlKemSeedKey);

      // _storedMlKemSeed throws by design. Letting that escape would take registration down
      // with it on every device that has no seed yet.
      await expectLater(service.mlKemPreKeyForPublication(), completion(isNull));
    });

    cryptoTest('degrades to classical rather than throwing on a malformed seed', () async {
      storage.store[_mlKemSeedKey] = 'this is not base64';
      await expectLater(service.mlKemPreKeyForPublication(), completion(isNull));

      storage.store[_mlKemSeedKey] = base64Encode(Uint8List(_mlKemSeedLength - 1));
      await expectLater(service.mlKemPreKeyForPublication(), completion(isNull));
    });

    ffiOnlyCryptoTest('derives a signed encapsulation key from the stored seed', () async {
      final preKey = await service.mlKemPreKeyForPublication();

      expect(preKey, isNotNull);
      expect(preKey!.publicKey.length, _mlKemPublicLength);
      expect(preKey.signature.length, _signatureLength);

      // Tag 7 must verify under the same identity key that signs the signed pre-key, because
      // that is the single key `pqxdh::verify_hybrid_bundle` checks both signatures against.
      final bundle = service.exportKeyBundles().first;
      expect(
        await IdentityKeyPair.verify(
          preKey.publicKey,
          preKey.signature,
          bundle.identityKey,
        ),
        isTrue,
        reason: 'a peer rejects the whole bundle if this does not verify',
      );
    });

    ffiOnlyCryptoTest('names the same key on every call', () async {
      // Login republishes the bundle. If the key moved between publications the server would
      // advertise one the responder can no longer decapsulate to.
      final first = await service.mlKemPreKeyForPublication();
      final second = await service.mlKemPreKeyForPublication();

      expect(first, isNotNull);
      expect(second!.publicKey, equals(first!.publicKey));
    });
  });
}
