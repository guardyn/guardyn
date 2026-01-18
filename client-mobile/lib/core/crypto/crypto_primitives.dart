/// Low-level cryptographic primitives using CryptoBridge
///
/// This module provides access to cryptographic primitives that can use
/// either Dart or native Rust implementations depending on platform.
///
/// All high-level protocols (X3DH, Double Ratchet) use these primitives.
library;

import 'package:flutter/foundation.dart';

import 'native_crypto_bridge.dart';

/// Global crypto primitives instance
///
/// Initialized automatically on first use.
/// Uses native Rust on mobile/desktop, Dart on web.
class CryptoPrimitives {
  static CryptoPrimitives? _instance;
  static CryptoBridge? _bridge;
  static bool _initialized = false;

  CryptoPrimitives._();

  /// Get the singleton instance
  static CryptoPrimitives get instance {
    _instance ??= CryptoPrimitives._();
    return _instance!;
  }

  /// Initialize the crypto primitives
  ///
  /// Call this once at app startup, typically in main()
  static Future<void> initialize([NativeCryptoConfig? config]) async {
    if (_initialized) return;

    _bridge = CryptoBridgeFactory.instance;
    await _bridge!.initialize(config ?? NativeCryptoConfig.defaultConfig);
    _initialized = true;

    debugPrint(
      '🔐 CryptoPrimitives initialized: '
      'native=${_bridge!.isNativeAvailable}, '
      'pq=${_bridge!.isPostQuantumAvailable}',
    );
  }

  /// Check if initialized
  static bool get isInitialized => _initialized;

  /// Check if native crypto is available
  static bool get isNativeAvailable => _bridge?.isNativeAvailable ?? false;

  /// Check if post-quantum is available
  static bool get isPostQuantumAvailable =>
      _bridge?.isPostQuantumAvailable ?? false;

  // =========================================================================
  // Key Generation
  // =========================================================================

  /// Generate X25519 key pair for Diffie-Hellman
  static Future<(Uint8List publicKey, Uint8List privateKey)>
  generateX25519KeyPair() async {
    _ensureInitialized();
    final kp = await _bridge!.generateSignedPreKey();
    return (kp.publicKey, kp.privateKey);
  }

  /// Generate Ed25519 key pair for signatures
  static Future<(Uint8List publicKey, Uint8List privateKey)>
  generateEd25519KeyPair() async {
    _ensureInitialized();
    final kp = await _bridge!.generateIdentityKey();
    return (kp.publicKey, kp.privateKey);
  }

  // =========================================================================
  // Key Conversion (Ed25519 ↔ X25519)
  // =========================================================================

  /// Convert Ed25519 public key to X25519 public key
  ///
  /// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
  /// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
  static Future<Uint8List> ed25519PublicToX25519(
    Uint8List ed25519Public,
  ) async {
    _ensureInitialized();
    return _bridge!.ed25519PublicToX25519(ed25519Public);
  }

  /// Convert Ed25519 secret key (seed) to X25519 secret key
  ///
  /// The conversion matches TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk.
  static Future<Uint8List> ed25519SecretToX25519(Uint8List ed25519Seed) async {
    _ensureInitialized();
    return _bridge!.ed25519SecretToX25519(ed25519Seed);
  }

  // =========================================================================
  // Key Exchange
  // =========================================================================

  /// Perform X25519 Diffie-Hellman key agreement
  ///
  /// Returns 32-byte shared secret
  static Future<Uint8List> x25519DiffieHellman({
    required Uint8List privateKey,
    required Uint8List remotePublicKey,
  }) async {
    _ensureInitialized();
    return _bridge!.deriveHybridSharedSecret(
      localPrivateKey: privateKey,
      remotePublicKey: remotePublicKey,
      remotePqPublicKey: null,
    );
  }

  // =========================================================================
  // Symmetric Encryption
  // =========================================================================

  /// Encrypt data with AES-256-GCM
  ///
  /// Returns (ciphertext, nonce, tag)
  static Future<(Uint8List ciphertext, Uint8List nonce, Uint8List tag)>
  encryptAesGcm({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  }) async {
    _ensureInitialized();
    final encrypted = await _bridge!.encryptAesGcm(
      plaintext: plaintext,
      key: key,
      nonce: nonce,
      associatedData: associatedData,
    );
    return (encrypted.ciphertext, encrypted.nonce, encrypted.tag);
  }

  /// Decrypt AES-256-GCM ciphertext
  static Future<Uint8List> decryptAesGcm({
    required Uint8List ciphertext,
    required Uint8List nonce,
    required Uint8List tag,
    required Uint8List key,
    Uint8List? associatedData,
  }) async {
    _ensureInitialized();
    return _bridge!.decryptAesGcm(
      encrypted: EncryptedData(ciphertext: ciphertext, nonce: nonce, tag: tag),
      key: key,
      associatedData: associatedData,
    );
  }

  // =========================================================================
  // Key Derivation
  // =========================================================================

  /// Derive key using HKDF-SHA256
  static Future<Uint8List> hkdf({
    required Uint8List inputKeyMaterial,
    required Uint8List info,
    Uint8List? salt,
    int outputLength = 32,
  }) async {
    _ensureInitialized();
    return _bridge!.hkdfDerive(
      inputKeyMaterial: inputKeyMaterial,
      info: info,
      salt: salt,
      outputLength: outputLength,
    );
  }

  // =========================================================================
  // Signatures
  // =========================================================================

  /// Sign message with Ed25519
  ///
  /// Returns 64-byte signature
  static Future<Uint8List> signEd25519({
    required Uint8List privateKey,
    required Uint8List message,
  }) async {
    _ensureInitialized();
    return _bridge!.signEd25519(privateKey: privateKey, message: message);
  }

  /// Verify Ed25519 signature
  static Future<bool> verifyEd25519({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  }) async {
    _ensureInitialized();
    return _bridge!.verifyEd25519(
      publicKey: publicKey,
      message: message,
      signature: signature,
    );
  }

  // =========================================================================
  // Padding
  // =========================================================================

  /// Apply PADMÉ padding to message
  static Future<Uint8List> padMessage(Uint8List message) async {
    _ensureInitialized();
    return _bridge!.padMessage(message);
  }

  /// Remove PADMÉ padding from message
  static Future<Uint8List> unpadMessage(Uint8List paddedMessage) async {
    _ensureInitialized();
    return _bridge!.unpadMessage(paddedMessage);
  }

  // =========================================================================
  // Private Helpers
  // =========================================================================

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'CryptoPrimitives not initialized. '
        'Call CryptoPrimitives.initialize() first.',
      );
    }
  }
}
