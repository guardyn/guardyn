/// Integration tests for Native Rust Crypto Bridge
///
/// These tests verify that the Rust FFI integration works correctly.
/// Run on a real device or desktop to test native crypto.
///
/// Run with:
/// ```bash
/// flutter test integration_test/crypto/rust_ffi_test.dart
/// ```
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/crypto_primitives.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/crypto/native/rust_crypto_bridge.dart';
import 'package:guardyn_client/core/crypto/native_crypto_bridge.dart';
import 'package:guardyn_client/generated/rust/api.dart' as rust_api;
import 'package:integration_test/integration_test.dart';

/// Fails rather than skips when the build has no post-quantum support.
///
/// The three cases below used to open with `if (!bridge.isPostQuantumAvailable) { print(...);
/// return; }`, and every one of them took that branch on every run - so they reported as
/// passing while asserting nothing, from the day they were written until #363. A PQ case that
/// quietly returns is indistinguishable from one that passed, which is the whole defect. If
/// this build genuinely has no `pq` feature, that is worth a red run and a rebuild.
void _requirePostQuantum(NativeRustCryptoBridge bridge) {
  expect(
    bridge.isPostQuantumAvailable,
    isTrue,
    reason: 'this build has no post-quantum support - rebuild the native library with '
        '--features full (backend/crates/crypto-ffi/build-mobile.sh)',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // One bridge, initialised exactly once, through the path the application itself uses.
  //
  // Each group used to build its own NativeRustCryptoBridge and initialise it. The second call
  // reached `GuardynCrypto.init()`, which throws `Should not initialize flutter_rust_bridge
  // twice` - and `NativeRustCryptoBridge.initialize` catches that internally, leaving
  // `_pqAvailable` at its `false` default. The group's own try/catch never fired, because
  // nothing was ever rethrown. That is what disabled every post-quantum assertion in this file
  // (#363); the `enablePostQuantum: false` that used to sit here would have been a second,
  // independent cause once the first was fixed.
  //
  // Going through CryptoPrimitives rather than constructing the bridge directly means
  // CryptoService works too, so the publishing path can be exercised as the app runs it.
  late NativeRustCryptoBridge bridge;

  setUpAll(() async {
    const config = NativeCryptoConfig(
      preferNative: true,
      enablePostQuantum: true,
      enablePadme: true,
    );

    // The bridge is constructed directly and initialised first, because
    // `CryptoBridgeFactory` probes for the library by *calling* it
    // (`NativeRustCryptoBridge.checkNativeAvailable` -> `cryptoStatus()`), which cannot
    // succeed until flutter_rust_bridge is up. The probe also caches its answer, so a
    // premature call would pin "unavailable" for the rest of the process.
    bridge = NativeRustCryptoBridge();
    await bridge.initialize(config);

    // Then the facade, so CryptoService works and the publishing path can be exercised as the
    // application runs it. This is only safe because `initialize` now treats the
    // flutter_rust_bridge init as a one-shot rather than discovering it by exception.
    await CryptoPrimitives.initialize(config);
  });

  group('NativeRustCryptoBridge Integration Tests', () {

    testWidgets('Native crypto is available', (tester) async {
      expect(
        bridge.isNativeAvailable,
        isTrue,
        reason: 'Native Rust crypto should be available on this platform',
      );
    });

    testWidgets('Generate X25519 key pair', (tester) async {
      final keyPair = await bridge.generateSignedPreKey();

      expect(
        keyPair.publicKey.length,
        equals(32),
        reason: 'X25519 public key should be 32 bytes',
      );
      expect(
        keyPair.privateKey.length,
        equals(32),
        reason: 'X25519 private key should be 32 bytes',
      );
      expect(keyPair.keyType, equals('X25519'));
    });

    testWidgets('Generate Ed25519 key pair', (tester) async {
      final keyPair = await bridge.generateIdentityKey();

      expect(
        keyPair.publicKey.length,
        equals(32),
        reason: 'Ed25519 public key should be 32 bytes',
      );
      expect(
        keyPair.privateKey.length,
        equals(32),
        reason: 'Ed25519 private key should be 32 bytes',
      );
      expect(keyPair.keyType, equals('Ed25519'));
    });

    testWidgets('AES-256-GCM encryption/decryption round-trip', (tester) async {
      final plaintext = List<int>.generate(64, (i) => i);
      final key = List<int>.generate(32, (i) => i * 7 % 256);

      final encrypted = await bridge.encryptAesGcm(
        plaintext: Uint8List.fromList(plaintext),
        key: Uint8List.fromList(key),
      );

      expect(
        encrypted.ciphertext.length,
        greaterThan(0),
        reason: 'Ciphertext should not be empty',
      );
      expect(
        encrypted.nonce.length,
        equals(12),
        reason: 'AES-GCM nonce should be 12 bytes',
      );
      expect(
        encrypted.tag.length,
        equals(16),
        reason: 'AES-GCM tag should be 16 bytes',
      );

      final decrypted = await bridge.decryptAesGcm(
        encrypted: encrypted,
        key: Uint8List.fromList(key),
      );

      expect(
        decrypted,
        equals(Uint8List.fromList(plaintext)),
        reason: 'Decrypted data should match original plaintext',
      );
    });

    testWidgets('ChaCha20-Poly1305 encryption/decryption round-trip', (
      tester,
    ) async {
      final plaintext = List<int>.generate(128, (i) => (i * 3) % 256);
      final key = List<int>.generate(32, (i) => (i * 11) % 256);

      final encrypted = await bridge.encryptChaCha20Poly1305(
        plaintext: Uint8List.fromList(plaintext),
        key: Uint8List.fromList(key),
      );

      expect(encrypted.ciphertext.length, greaterThan(0));
      expect(
        encrypted.nonce.length,
        equals(12),
        reason: 'ChaCha20-Poly1305 nonce should be 12 bytes',
      );

      final decrypted = await bridge.decryptChaCha20Poly1305(
        encrypted: encrypted,
        key: Uint8List.fromList(key),
      );

      expect(decrypted, equals(Uint8List.fromList(plaintext)));
    });

    testWidgets('Ed25519 signing and verification', (tester) async {
      final keyPair = await bridge.generateIdentityKey();
      final message = Uint8List.fromList(
        'Test message for Ed25519 signature'.codeUnits,
      );

      final signature = await bridge.signEd25519(
        privateKey: keyPair.privateKey,
        message: message,
      );

      expect(
        signature.length,
        equals(64),
        reason: 'Ed25519 signature should be 64 bytes',
      );

      final isValid = await bridge.verifyEd25519(
        publicKey: keyPair.publicKey,
        message: message,
        signature: signature,
      );

      expect(isValid, isTrue, reason: 'Valid signature should verify');

      // Modify message and verify fails
      final tamperedMessage = Uint8List.fromList('Tampered message'.codeUnits);

      final isInvalid = await bridge.verifyEd25519(
        publicKey: keyPair.publicKey,
        message: tamperedMessage,
        signature: signature,
      );

      expect(
        isInvalid,
        isFalse,
        reason: 'Tampered message should fail verification',
      );
    });

    testWidgets('HKDF key derivation', (tester) async {
      final ikm = Uint8List.fromList(List.generate(32, (i) => i));
      final salt = Uint8List.fromList(List.generate(32, (i) => i + 100));
      final info = Uint8List.fromList('guardyn-test-context'.codeUnits);

      final derived = await bridge.hkdfDerive(
        inputKeyMaterial: ikm,
        salt: salt,
        info: info,
        outputLength: 64,
      );

      expect(
        derived.length,
        equals(64),
        reason: 'HKDF should derive 64 bytes as requested',
      );

      // Same input should produce same output (deterministic)
      final derived2 = await bridge.hkdfDerive(
        inputKeyMaterial: ikm,
        salt: salt,
        info: info,
        outputLength: 64,
      );

      expect(derived, equals(derived2), reason: 'HKDF should be deterministic');
    });

    testWidgets('X25519 Diffie-Hellman key agreement', (tester) async {
      // Generate two key pairs
      final aliceKeyPair = await bridge.generateSignedPreKey();
      final bobKeyPair = await bridge.generateSignedPreKey();

      // Alice derives shared secret
      final aliceShared = await bridge.deriveHybridSharedSecret(
        localPrivateKey: aliceKeyPair.privateKey,
        remotePublicKey: bobKeyPair.publicKey,
        remotePqPublicKey: null,
      );

      // Bob derives shared secret
      final bobShared = await bridge.deriveHybridSharedSecret(
        localPrivateKey: bobKeyPair.privateKey,
        remotePublicKey: aliceKeyPair.publicKey,
        remotePqPublicKey: null,
      );

      expect(
        aliceShared.length,
        equals(32),
        reason: 'X25519 shared secret should be 32 bytes',
      );
      expect(
        aliceShared,
        equals(bobShared),
        reason: 'Both parties should derive the same shared secret',
      );
    });

    testWidgets('PADMÉ padding', (tester) async {
      final message = Uint8List.fromList('Short message'.codeUnits);

      final padded = await bridge.padMessage(message);

      expect(
        padded.length,
        greaterThan(message.length),
        reason: 'Padded message should be longer',
      );

      final unpadded = await bridge.unpadMessage(padded);

      expect(
        unpadded,
        equals(message),
        reason: 'Unpadded message should match original',
      );
    });

    testWidgets('Random bytes generation', (tester) async {
      final random1 = await bridge.randomBytes(32);
      final random2 = await bridge.randomBytes(32);

      expect(random1.length, equals(32));
      expect(random2.length, equals(32));
      expect(
        random1,
        isNot(equals(random2)),
        reason: 'Random bytes should be different each time',
      );
    });

    testWidgets('Constant-time comparison', (tester) async {
      final a = Uint8List.fromList([1, 2, 3, 4, 5]);
      final b = Uint8List.fromList([1, 2, 3, 4, 5]);
      final c = Uint8List.fromList([1, 2, 3, 4, 6]);

      final equal = await bridge.constantTimeEquals(a, b);
      final notEqual = await bridge.constantTimeEquals(a, c);

      expect(equal, isTrue, reason: 'Same bytes should be equal');
      expect(notEqual, isFalse, reason: 'Different bytes should not be equal');
    });

    testWidgets('CryptoBridgeFactory returns native bridge', (tester) async {
      // Note: Don't reset/reinitialize - flutter_rust_bridge can only be
      // initialized once per process. Just verify the existing bridge.
      final factoryBridge = CryptoBridgeFactory.instance;

      // Factory should have returned our native bridge (since tests run
      // after setUpAll already initialized it)
      expect(
        factoryBridge,
        isA<NativeRustCryptoBridge>(),
        reason: 'Factory should return native bridge on this platform',
      );
    });

    testWidgets('Ed25519 public key to X25519 conversion', (tester) async {
      // Generate Ed25519 keypair
      final ed25519KeyPair = await bridge.generateIdentityKey();
      expect(ed25519KeyPair.keyType, equals('Ed25519'));

      // Convert Ed25519 public key to X25519
      final x25519Public = await bridge.ed25519PublicToX25519(
        ed25519KeyPair.publicKey,
      );

      expect(
        x25519Public.length,
        equals(32),
        reason: 'X25519 public key should be 32 bytes',
      );

      // Conversion should be deterministic
      final x25519Public2 = await bridge.ed25519PublicToX25519(
        ed25519KeyPair.publicKey,
      );
      expect(
        x25519Public,
        equals(x25519Public2),
        reason: 'Same Ed25519 key should produce same X25519 key',
      );
    });

    testWidgets('Ed25519 secret key to X25519 conversion', (tester) async {
      // Generate Ed25519 keypair
      final ed25519KeyPair = await bridge.generateIdentityKey();

      // Convert Ed25519 secret to X25519
      final x25519Secret = await bridge.ed25519SecretToX25519(
        ed25519KeyPair.privateKey,
      );

      expect(
        x25519Secret.length,
        equals(32),
        reason: 'X25519 secret key should be 32 bytes',
      );

      // Conversion should be deterministic
      final x25519Secret2 = await bridge.ed25519SecretToX25519(
        ed25519KeyPair.privateKey,
      );
      expect(
        x25519Secret,
        equals(x25519Secret2),
        reason: 'Same Ed25519 seed should produce same X25519 secret',
      );
    });

    testWidgets('Ed25519 to X25519 conversion enables DH', (tester) async {
      // Generate Ed25519 keypair for Alice
      final aliceEd25519 = await bridge.generateIdentityKey();

      // Convert Alice's Ed25519 to X25519
      final aliceX25519Secret = await bridge.ed25519SecretToX25519(
        aliceEd25519.privateKey,
      );
      final aliceX25519Public = await bridge.ed25519PublicToX25519(
        aliceEd25519.publicKey,
      );

      // Generate pure X25519 keypair for Bob
      final bobX25519 = await bridge.generateSignedPreKey();

      // Both should be able to compute shared secret
      final sharedFromAlice = await bridge.deriveHybridSharedSecret(
        localPrivateKey: aliceX25519Secret,
        remotePublicKey: bobX25519.publicKey,
        remotePqPublicKey: null,
      );

      final sharedFromBob = await bridge.deriveHybridSharedSecret(
        localPrivateKey: bobX25519.privateKey,
        remotePublicKey: aliceX25519Public,
        remotePqPublicKey: null,
      );

      expect(
        sharedFromAlice,
        equals(sharedFromBob),
        reason: 'DH should work with converted Ed25519 keys',
      );
    });
  });

  group('Post-Quantum (PQXDH) Tests', () {
    testWidgets('Post-quantum support is compiled in', (tester) async {
      _requirePostQuantum(bridge);
    });

    testWidgets('Generate hybrid key bundle', (tester) async {
      _requirePostQuantum(bridge);

      final bundle = await bridge.generateHybridKeyBundle();

      expect(bundle, isNotNull, reason: 'PQ bundle should be generated');
      expect(bundle!.x25519PublicKey.length, equals(32));
      expect(
        bundle.mlKemPublicKey.length,
        greaterThan(0),
        reason: 'ML-KEM public key should be generated',
      );
    });

    // The assertion `flutter test` cannot make. The unit suite runs on DartCryptoBridge, which
    // has no ML-KEM at all, so everything it can check about the hybrid responder stops at the
    // FFI boundary. This is the one that proves the two halves agree - and agreeing is the
    // whole point, since a responder answering in the wrong KDF domain still returns 32
    // perfectly well-formed bytes.
    testWidgets('hybrid PQXDH initiator and responder agree a shared secret', (
      tester,
    ) async {
      _requirePostQuantum(bridge);

      // Bob's published bundle, built the way auth-service would serve it.
      final bobIdentity = rust_api.cryptoGenerateEd25519Keypair();
      final bobSignedPrekey = rust_api.cryptoGenerateX25519Keypair();
      final bobMlKemSeed = rust_api.cryptoRandomBytes(length: 64);
      final bobMlKemPublic = rust_api.cryptoMlKemPublicFromSeed(
        seed: bobMlKemSeed,
      );

      expect(bobMlKemSeed.length, equals(64));
      expect(bobMlKemPublic.length, equals(1184));

      // Both pre-keys are signed by the same identity, and the ML-KEM signature is over the
      // raw encapsulation-key bytes - no domain separator, no length prefix.
      final bobBundle = rust_api.HybridPeerBundle(
        identityKey: bobIdentity.publicKey,
        signedPrekey: bobSignedPrekey.publicKey,
        signedPrekeySignature: rust_api.cryptoSignEd25519(
          privateKey: bobIdentity.privateKey,
          message: bobSignedPrekey.publicKey,
        ),
        pqPrekey: bobMlKemPublic,
        pqPrekeySignature: rust_api.cryptoSignEd25519(
          privateKey: bobIdentity.privateKey,
          message: bobMlKemPublic,
        ),
      );

      // Alice initiates. The ciphertext she gets back is what rides in the prekey message's
      // 0x02 field.
      final aliceIdentity = rust_api.cryptoGenerateEd25519Keypair();
      final agreement = rust_api.cryptoDeriveSenderSharedSecret(
        senderIdentitySeed: aliceIdentity.privateKey,
        recipientBundle: bobBundle,
      );

      expect(agreement.sharedSecret.length, equals(32));
      expect(agreement.ephemeralPublic.length, equals(32));
      expect(agreement.pqCiphertext, isNotNull);
      expect(agreement.pqCiphertext!.length, equals(1088));

      // Bob answers from the 64 bytes he persisted - the 2400-byte decapsulation key is
      // rebuilt inside Rust and never crosses the boundary.
      final bobSecret = rust_api.cryptoDeriveRecipientSharedSecret(
        identitySeed: bobIdentity.privateKey,
        signedPrekeySecret: bobSignedPrekey.privateKey,
        mlKemSeed: bobMlKemSeed,
        senderIdentityKey: aliceIdentity.publicKey,
        senderEphemeralKey: agreement.ephemeralPublic,
        pqCiphertext: agreement.pqCiphertext,
      );

      expect(
        rust_api.cryptoConstantTimeEq(a: bobSecret, b: agreement.sharedSecret),
        isTrue,
        reason:
            'The responder must derive the initiator\'s secret. A mismatch here is the '
            'PQXDH_SharedSecret/X3DH domain split, and it would surface in production only '
            'as an AEAD tag rejection with both ends looking healthy.',
      );
    });

    testWidgets('a responder holding no seed refuses the handshake', (
      tester,
    ) async {
      _requirePostQuantum(bridge);

      final identity = rust_api.cryptoGenerateEd25519Keypair();
      final signedPrekey = rust_api.cryptoGenerateX25519Keypair();
      final sender = rust_api.cryptoGenerateEd25519Keypair();
      final ephemeral = rust_api.cryptoGenerateX25519Keypair();

      // Fails closed rather than deriving from the classical halves alone. Both would
      // otherwise succeed - the classical DHs still agree - and the result would be a secret
      // that is merely different.
      expect(
        () => rust_api.cryptoDeriveRecipientSharedSecret(
          identitySeed: identity.privateKey,
          signedPrekeySecret: signedPrekey.privateKey,
          senderIdentityKey: sender.publicKey,
          senderEphemeralKey: ephemeral.publicKey,
          pqCiphertext: Uint8List.fromList(List<int>.filled(1088, 0xcd)),
        ),
        throwsA(anything),
      );
    });

    // The assertion PR-98c could not make. `flutter test` runs on DartCryptoBridge, which has
    // no ML-KEM, so CI can only check that the publisher refuses and degrades correctly - never
    // that the key it publishes is one a peer will actually accept. This runs the production
    // path: CryptoService reads the seed it persisted and signs with the identity key it holds,
    // exactly as `_generateX3DHKeyBundle` does before an upload.
    testWidgets('the published ML-KEM pre-key is one a peer accepts', (
      tester,
    ) async {
      _requirePostQuantum(bridge);

      final service = CryptoService();
      // A previous run's identity and seed would let this pass on stale state.
      await service.clearAll();
      await service.initialize();
      await service.initializeX3DH(oneTimePreKeyCount: 1);

      final published = await service.mlKemPreKeyForPublication();
      expect(
        published,
        isNotNull,
        reason: 'a post-quantum-capable device must publish tags 6 and 7',
      );
      expect(published!.publicKey.length, equals(1184));
      expect(published.signature.length, equals(64));

      final keyBundle = service.exportKeyBundles().first;
      final peerView = rust_api.HybridPeerBundle(
        identityKey: keyBundle.identityKey,
        signedPrekey: keyBundle.signedPreKey,
        signedPrekeySignature: keyBundle.signedPreKeySignature,
        pqPrekey: published.publicKey,
        pqPrekeySignature: published.signature,
      );

      // The crate's own verifier - the exact check a peer runs before encapsulating. It
      // rejects the bundle if tag 7 was signed by anything other than the identity key on
      // tag 1, which is a mistake a client otherwise makes silently.
      rust_api.cryptoVerifyHybridBundle(bundle: peerView);

      // And the published key has to be usable, not merely well-signed: an initiator
      // encapsulating to it must get a ciphertext back.
      final initiatorIdentity = rust_api.cryptoGenerateEd25519Keypair();
      final agreement = rust_api.cryptoDeriveSenderSharedSecret(
        senderIdentitySeed: initiatorIdentity.privateKey,
        recipientBundle: peerView,
      );
      expect(agreement.sharedSecret.length, equals(32));
      expect(agreement.pqCiphertext, isNotNull);
      expect(agreement.pqCiphertext!.length, equals(1088));

      await service.clearAll();
    });
  });
}
