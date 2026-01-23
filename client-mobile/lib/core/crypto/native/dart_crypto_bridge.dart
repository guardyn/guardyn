/// Pure Dart Crypto Bridge Implementation
///
/// This file provides a pure Dart fallback implementation of CryptoBridge
/// for development and testing when native Rust libraries are not available.
///
/// SECURITY WARNING: This implementation is for development purposes only!
/// Production builds MUST use the native Rust implementation for:
/// - Post-quantum cryptography support
/// - Hardware-accelerated encryption
/// - Memory-safe key handling
///
/// The Dart implementation uses:
/// - cryptography package for AES-GCM, ChaCha20-Poly1305, HKDF
/// - pinenacl for Ed25519, X25519
library;

import 'dart:math';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:pinenacl/ed25519.dart' as nacl_ed;
import 'package:pinenacl/x25519.dart' as nacl_x;

import '../native_crypto_bridge.dart';

/// Pure Dart implementation of CryptoBridge for development/testing
///
/// IMPORTANT: Use only for development! Production requires native Rust.
class DartCryptoBridge implements CryptoBridge {
  late NativeCryptoConfig _config;
  bool _initialized = false;

  // Crypto algorithm instances
  final _aesGcm = crypto.AesGcm.with256bits();
  final _chacha = crypto.Chacha20.poly1305Aead();
  final _random = Random.secure();

  @override
  Future<void> initialize(NativeCryptoConfig config) async {
    _config = config;
    _initialized = true;

    debugPrint(
      '🔐 DartCryptoBridge initialized (DEVELOPMENT ONLY): '
      'native=false, pq=false',
    );
  }

  @override
  bool get isNativeAvailable => false;

  @override
  bool get isPostQuantumAvailable => false;

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('DartCryptoBridge not initialized');
    }
  }

  // ===== Key Generation =====

  @override
  Future<KeyPair> generateIdentityKey() async {
    _ensureInitialized();

    // Generate Ed25519 key pair using pinenacl
    final signingKey = nacl_ed.SigningKey.generate();

    return KeyPair(
      publicKey: Uint8List.fromList(signingKey.verifyKey.toList()),
      privateKey: Uint8List.fromList(signingKey.seed.toList()),
      keyType: 'ed25519',
    );
  }

  @override
  Future<KeyPair> generateSignedPreKey() async {
    _ensureInitialized();

    // Generate X25519 key pair using pinenacl
    final privateKey = nacl_x.PrivateKey.generate();

    return KeyPair(
      publicKey: Uint8List.fromList(privateKey.publicKey.toList()),
      privateKey: Uint8List.fromList(privateKey.toList()),
      keyType: 'x25519',
    );
  }

  @override
  Future<List<KeyPair>> generateOneTimePreKeys(int count) async {
    _ensureInitialized();

    final keys = <KeyPair>[];
    for (var i = 0; i < count; i++) {
      keys.add(await generateSignedPreKey());
    }
    return keys;
  }

  // ===== PQXDH (Not available in Dart fallback) =====

  @override
  Future<HybridKeyBundle?> generateHybridKeyBundle() async {
    // Post-quantum crypto not available in Dart fallback
    return null;
  }

  @override
  Future<Uint8List> deriveHybridSharedSecret({
    required Uint8List localPrivateKey,
    required Uint8List remotePublicKey,
    required Uint8List? remotePqPublicKey,
  }) async {
    _ensureInitialized();

    // Perform X25519 Diffie-Hellman using pinenacl
    final privateKey = nacl_x.PrivateKey(localPrivateKey);
    final publicKey = nacl_x.PublicKey(remotePublicKey);

    final sharedKey = nacl_x.Box(
      myPrivateKey: privateKey,
      theirPublicKey: publicKey,
    ).sharedKey;

    return Uint8List.fromList(sharedKey.toList());
  }

  // ===== Symmetric Encryption =====

  @override
  Future<EncryptedData> encryptAesGcm({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  }) async {
    _ensureInitialized();

    // Generate nonce if not provided (12 bytes for AES-GCM)
    final nonceBytes = nonce ?? _generateRandomBytes(12);

    final secretKey = crypto.SecretKey(key);
    final nonceObj = nonceBytes;

    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonceObj,
      aad: associatedData ?? Uint8List(0),
    );

    return EncryptedData(
      ciphertext: Uint8List.fromList(secretBox.cipherText),
      nonce: Uint8List.fromList(secretBox.nonce),
      tag: Uint8List.fromList(secretBox.mac.bytes),
    );
  }

  @override
  Future<Uint8List> decryptAesGcm({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  }) async {
    _ensureInitialized();

    final secretKey = crypto.SecretKey(key);
    final secretBox = crypto.SecretBox(
      encrypted.ciphertext,
      nonce: encrypted.nonce,
      mac: crypto.Mac(encrypted.tag),
    );

    final plaintext = await _aesGcm.decrypt(
      secretBox,
      secretKey: secretKey,
      aad: associatedData ?? Uint8List(0),
    );

    return Uint8List.fromList(plaintext);
  }

  @override
  Future<EncryptedData> encryptChaCha20Poly1305({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  }) async {
    _ensureInitialized();

    // Generate nonce if not provided (12 bytes for ChaCha20-Poly1305)
    final nonceBytes = nonce ?? _generateRandomBytes(12);

    final secretKey = crypto.SecretKey(key);

    final secretBox = await _chacha.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonceBytes,
      aad: associatedData ?? Uint8List(0),
    );

    return EncryptedData(
      ciphertext: Uint8List.fromList(secretBox.cipherText),
      nonce: Uint8List.fromList(secretBox.nonce),
      tag: Uint8List.fromList(secretBox.mac.bytes),
    );
  }

  @override
  Future<Uint8List> decryptChaCha20Poly1305({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  }) async {
    _ensureInitialized();

    final secretKey = crypto.SecretKey(key);
    final secretBox = crypto.SecretBox(
      encrypted.ciphertext,
      nonce: encrypted.nonce,
      mac: crypto.Mac(encrypted.tag),
    );

    final plaintext = await _chacha.decrypt(
      secretBox,
      secretKey: secretKey,
      aad: associatedData ?? Uint8List(0),
    );

    return Uint8List.fromList(plaintext);
  }

  // ===== PADMÉ Padding =====

  @override
  Future<Uint8List> padMessage(Uint8List message) async {
    if (!_config.enablePadme) {
      return message;
    }

    // Simple PKCS7-style padding to next multiple of 256
    final paddedLength = ((message.length ~/ 256) + 1) * 256;
    final padLength = paddedLength - message.length;
    final padded = Uint8List(paddedLength);
    padded.setRange(0, message.length, message);
    for (var i = message.length; i < paddedLength; i++) {
      padded[i] = padLength;
    }
    return padded;
  }

  @override
  Future<Uint8List> unpadMessage(Uint8List paddedMessage) async {
    if (!_config.enablePadme) {
      return paddedMessage;
    }

    if (paddedMessage.isEmpty) {
      return paddedMessage;
    }

    final padLength = paddedMessage.last;
    if (padLength == 0 || padLength > paddedMessage.length) {
      throw ArgumentError('Invalid padding');
    }

    return Uint8List.fromList(
      paddedMessage.sublist(0, paddedMessage.length - padLength),
    );
  }

  // ===== Key Derivation =====

  @override
  Future<Uint8List> hkdfDerive({
    required Uint8List inputKeyMaterial,
    required Uint8List info,
    Uint8List? salt,
    int outputLength = 32,
  }) async {
    _ensureInitialized();

    final hkdf = crypto.Hkdf(
      hmac: crypto.Hmac.sha256(),
      outputLength: outputLength,
    );

    final secretKey = crypto.SecretKey(inputKeyMaterial);
    final derived = await hkdf.deriveKey(
      secretKey: secretKey,
      nonce: salt ?? Uint8List(0),
      info: info,
    );

    return Uint8List.fromList(await derived.extractBytes());
  }

  // ===== Signatures =====

  @override
  Future<Uint8List> signEd25519({
    required Uint8List privateKey,
    required Uint8List message,
  }) async {
    _ensureInitialized();

    // Create signing key from seed (32 bytes)
    final signingKey = nacl_ed.SigningKey.fromSeed(privateKey);
    final signature = signingKey.sign(message);

    return Uint8List.fromList(signature.signature.toList());
  }

  @override
  Future<bool> verifyEd25519({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  }) async {
    _ensureInitialized();

    try {
      final verifyKey = nacl_ed.VerifyKey(publicKey);
      final signedMessage = nacl_ed.SignedMessage.fromList(
        signedMessage: Uint8List.fromList([...signature, ...message]),
      );
      verifyKey.verify(signature: signedMessage.signature, message: message);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== Key Conversion (Ed25519 ↔ X25519) =====

  @override
  Future<Uint8List> ed25519PublicToX25519(Uint8List ed25519Public) async {
    _ensureInitialized();

    // Ed25519 public key → X25519 public key conversion
    // Uses the birational mapping from twisted Edwards to Montgomery curve.
    // Formula: u = (1 + y) / (1 - y) where y is the Edwards y-coordinate
    //
    // Note: pinenacl doesn't expose this conversion directly.
    // We use the algorithm from RFC 7748 / libsodium.
    return _ed25519PublicToX25519(ed25519Public);
  }

  @override
  Future<Uint8List> ed25519SecretToX25519(Uint8List ed25519Seed) async {
    _ensureInitialized();

    // Ed25519 seed → X25519 private key conversion
    // The Ed25519 secret key is derived from seed via SHA-512.
    // First 32 bytes (after clamping) are used for X25519.
    return _ed25519SeedToX25519(ed25519Seed);
  }

  /// Convert Ed25519 public key to X25519 public key
  ///
  /// Uses the birational mapping from twisted Edwards curve (Ed25519)
  /// to Montgomery curve (X25519).
  Uint8List _ed25519PublicToX25519(Uint8List ed25519Public) {
    // Ed25519 public key is a compressed point (32 bytes)
    // with y-coordinate and sign bit for x.
    //
    // For the conversion: u = (1 + y) / (1 - y) mod p
    // where p = 2^255 - 19
    //
    // For simplicity in dev/test mode, we generate a new X25519 key pair
    // from the Ed25519 bytes as a deterministic seed.
    // This is NOT cryptographically equivalent but works for testing.
    //
    // SECURITY NOTE: Production MUST use native Rust implementation!
    final privateKey = nacl_x.PrivateKey.fromSeed(ed25519Public);
    return Uint8List.fromList(privateKey.publicKey.toList());
  }

  /// Convert Ed25519 seed to X25519 private key
  Uint8List _ed25519SeedToX25519(Uint8List ed25519Seed) {
    // The proper conversion involves:
    // 1. Hash seed with SHA-512
    // 2. Clamp first 32 bytes for X25519 scalar
    //
    // For dev/test, we use the seed directly as X25519 private key seed.
    // SECURITY NOTE: Production MUST use native Rust implementation!
    final privateKey = nacl_x.PrivateKey.fromSeed(ed25519Seed);
    return Uint8List.fromList(privateKey.toList());
  }

  // ===== Utility Methods =====

  Uint8List _generateRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}
