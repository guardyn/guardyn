/// Native Crypto Bridge - Interface for Rust-based cryptography
///
/// This module provides a unified interface for cryptographic operations
/// backed by native Rust FFI via flutter_rust_bridge.
///
/// IMPORTANT: Web platform is NOT supported for security reasons:
/// - No Rust FFI for post-quantum cryptography
/// - No secure key storage (localStorage is vulnerable)
/// - XSS and browser extension attacks possible
///
/// Supported platforms:
/// - Android (via libguardyn_crypto_ffi.so)
/// - iOS (via GuardynCrypto.framework)
/// - Linux (via libguardyn_crypto_ffi.so)
/// - macOS (via libguardyn_crypto_ffi.dylib)
/// - Windows (via guardyn_crypto_ffi.dll)
///
/// The Rust backend provides:
/// - Post-quantum cryptography (ML-KEM / PQXDH)
/// - MLS group encryption
/// - Hardware-accelerated AES/ChaCha20
/// - PADMÉ padding for traffic analysis protection
library;

import 'package:flutter/foundation.dart';

// Native bridge implementation (mobile/desktop only)
import 'native/native_bridge_io.dart' as native_bridge;

/// Configuration for native crypto backend
class NativeCryptoConfig {
  /// Whether to prefer native crypto when available
  final bool preferNative;

  /// Whether to enable post-quantum key exchange
  final bool enablePostQuantum;

  /// Whether to enable PADMÉ padding
  final bool enablePadme;

  /// Whether to enable hardware acceleration
  final bool enableHardwareAcceleration;

  const NativeCryptoConfig({
    this.preferNative = true,
    this.enablePostQuantum = false, // Disabled until ML-KEM is fully tested
    this.enablePadme = true,
    this.enableHardwareAcceleration = true,
  });

  static const defaultConfig = NativeCryptoConfig();
}

/// Abstract interface for cryptographic operations
///
/// This interface allows swapping between Dart and Rust implementations
abstract class CryptoBridge {
  /// Initialize the crypto backend
  Future<void> initialize(NativeCryptoConfig config);

  /// Check if native backend is available
  bool get isNativeAvailable;

  /// Check if post-quantum crypto is available
  bool get isPostQuantumAvailable;

  // ===== Key Generation =====

  /// Generate a new identity key pair (Ed25519)
  Future<KeyPair> generateIdentityKey();

  /// Generate a new signed pre-key pair (X25519)
  Future<KeyPair> generateSignedPreKey();

  /// Generate multiple one-time pre-keys
  Future<List<KeyPair>> generateOneTimePreKeys(int count);

  // ===== PQXDH (Hybrid Post-Quantum Key Exchange) =====

  /// Generate hybrid key bundle (X25519 + ML-KEM-768)
  /// Only available when post-quantum is enabled
  Future<HybridKeyBundle?> generateHybridKeyBundle();

  /// Derive shared secret using hybrid key exchange
  /// Falls back to standard X3DH if PQ is not available
  Future<Uint8List> deriveHybridSharedSecret({
    required Uint8List localPrivateKey,
    required Uint8List remotePublicKey,
    required Uint8List? remotePqPublicKey,
  });

  // ===== Symmetric Encryption =====

  /// Encrypt data with AES-256-GCM
  Future<EncryptedData> encryptAesGcm({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  });

  /// Decrypt AES-256-GCM ciphertext
  Future<Uint8List> decryptAesGcm({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  });

  /// Encrypt data with ChaCha20-Poly1305
  Future<EncryptedData> encryptChaCha20Poly1305({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  });

  /// Decrypt ChaCha20-Poly1305 ciphertext
  Future<Uint8List> decryptChaCha20Poly1305({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  });

  // ===== PADMÉ Padding =====

  /// Apply PADMÉ padding to message
  Future<Uint8List> padMessage(Uint8List message);

  /// Remove PADMÉ padding from message
  Future<Uint8List> unpadMessage(Uint8List paddedMessage);

  // ===== Key Derivation =====

  /// Derive encryption key using HKDF-SHA256
  Future<Uint8List> hkdfDerive({
    required Uint8List inputKeyMaterial,
    required Uint8List info,
    Uint8List? salt,
    int outputLength = 32,
  });

  // ===== Signatures =====

  /// Sign data with Ed25519
  Future<Uint8List> signEd25519({
    required Uint8List privateKey,
    required Uint8List message,
  });

  /// Verify Ed25519 signature
  Future<bool> verifyEd25519({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  });

  // ===== Key Conversion (Ed25519 ↔ X25519) =====

  /// Convert Ed25519 public key to X25519 public key
  ///
  /// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
  /// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
  Future<Uint8List> ed25519PublicToX25519(Uint8List ed25519Public);

  /// Convert Ed25519 secret key (seed) to X25519 secret key
  ///
  /// The conversion matches TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk.
  Future<Uint8List> ed25519SecretToX25519(Uint8List ed25519Seed);
}

/// Key pair representation
class KeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;
  final String keyType;

  const KeyPair({
    required this.publicKey,
    required this.privateKey,
    required this.keyType,
  });
}

/// Hybrid key bundle for PQXDH
class HybridKeyBundle {
  /// Standard X25519 public key
  final Uint8List x25519PublicKey;

  /// Standard X25519 private key
  final Uint8List x25519PrivateKey;

  /// ML-KEM-768 encapsulation key (public)
  final Uint8List mlKemPublicKey;

  /// ML-KEM-768 decapsulation key (private)
  final Uint8List mlKemPrivateKey;

  const HybridKeyBundle({
    required this.x25519PublicKey,
    required this.x25519PrivateKey,
    required this.mlKemPublicKey,
    required this.mlKemPrivateKey,
  });
}

/// Encrypted data with ciphertext and nonce
class EncryptedData {
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List tag;

  const EncryptedData({
    required this.ciphertext,
    required this.nonce,
    required this.tag,
  });

  /// Serialize to bytes [nonce || ciphertext || tag]
  Uint8List toBytes() {
    final result = Uint8List(nonce.length + ciphertext.length + tag.length);
    result.setAll(0, nonce);
    result.setAll(nonce.length, ciphertext);
    result.setAll(nonce.length + ciphertext.length, tag);
    return result;
  }

  /// Deserialize from bytes
  static EncryptedData fromBytes(
    Uint8List bytes, {
    int nonceLength = 12,
    int tagLength = 16,
  }) {
    if (bytes.length < nonceLength + tagLength) {
      throw ArgumentError('Data too short to contain nonce and tag');
    }

    return EncryptedData(
      nonce: bytes.sublist(0, nonceLength),
      ciphertext: bytes.sublist(nonceLength, bytes.length - tagLength),
      tag: bytes.sublist(bytes.length - tagLength),
    );
  }
}

/// Factory for creating crypto bridge on native platforms
///
/// IMPORTANT: Web is NOT supported. Use only on:
/// - Android, iOS (mobile)
/// - Linux, macOS, Windows (desktop via Tauri)
class CryptoBridgeFactory {
  static CryptoBridge? _instance;

  /// Get the singleton crypto bridge instance
  static CryptoBridge get instance {
    _instance ??= _createBridge();
    return _instance!;
  }

  static CryptoBridge _createBridge() {
    // Create crypto bridge (native Rust or Dart fallback)
    final bridge = native_bridge.createNativeCryptoBridge();
    if (bridge != null) {
      return bridge;
    }

    // This should not happen - createNativeCryptoBridge now always returns a bridge
    throw UnsupportedError(
      'Failed to create crypto bridge. '
      'This is an internal error - please report it.',
    );
  }

  /// Force native implementation (for testing)
  @visibleForTesting
  static void useNative() {
    if (!native_bridge.isNativeCryptoAvailable()) {
      throw UnsupportedError(
        'Native Rust crypto is not available on this platform. '
        'Build native libraries first.',
      );
    }
    _instance = native_bridge.createNativeCryptoBridge();
  }

  /// Reset instance (for testing)
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
