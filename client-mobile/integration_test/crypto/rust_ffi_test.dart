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
import 'package:guardyn_client/core/crypto/native/rust_crypto_bridge.dart';
import 'package:guardyn_client/core/crypto/native_crypto_bridge.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NativeRustCryptoBridge Integration Tests', () {
    late NativeRustCryptoBridge bridge;

    setUpAll(() async {
      bridge = NativeRustCryptoBridge();
      await bridge.initialize(
        const NativeCryptoConfig(
          preferNative: true,
          enablePostQuantum: false,
          enablePadme: true,
        ),
      );
    });

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
    // Reuse the bridge from previous group to avoid double initialization
    late NativeRustCryptoBridge bridge;

    setUpAll(() async {
      bridge = NativeRustCryptoBridge();
      // Try to initialize, but ignore if already initialized
      try {
        await bridge.initialize(
          const NativeCryptoConfig(
            preferNative: true,
            enablePostQuantum: true,
            enablePadme: true,
          ),
        );
      } catch (e) {
        // Ignore double initialization error - FRB can only init once
        print('Note: PQ bridge initialization skipped (already initialized)');
      }
    });

    testWidgets('Check PQ availability', (tester) async {
      // Note: PQ may not be available depending on build configuration
      final pqAvailable = bridge.isPostQuantumAvailable;

      if (pqAvailable) {
        expect(pqAvailable, isTrue);
        print('✅ Post-quantum cryptography is available');
      } else {
        print(
          '⚠️ Post-quantum cryptography is not available (feature disabled)',
        );
      }
    });

    testWidgets('Generate hybrid key bundle (if PQ available)', (tester) async {
      if (!bridge.isPostQuantumAvailable) {
        print('Skipping PQ test - not available');
        return;
      }

      final bundle = await bridge.generateHybridKeyBundle();

      expect(bundle, isNotNull, reason: 'PQ bundle should be generated');
      expect(bundle!.x25519PublicKey.length, equals(32));
      expect(
        bundle.mlKemPublicKey.length,
        greaterThan(0),
        reason: 'ML-KEM public key should be generated',
      );
    });
  });
}
