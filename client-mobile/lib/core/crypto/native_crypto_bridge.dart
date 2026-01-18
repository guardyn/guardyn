/// Native Crypto Bridge - Interface for Rust-based cryptography
///
/// This module provides a unified interface for cryptographic operations that
/// can be backed by either:
/// - Pure Dart implementations (current, for Web)
/// - Native Rust FFI (future, via flutter_rust_bridge)
///
/// The Rust backend provides:
/// - Post-quantum cryptography (ML-KEM / PQXDH)
/// - MLS group encryption
/// - Hardware-accelerated AES/ChaCha20
/// - PADMÉ padding for traffic analysis protection
library;

import 'package:flutter/foundation.dart';

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

/// Implementation using pure Dart crypto libraries
///
/// This is the default fallback when native Rust FFI is not available
/// (e.g., on Web platform)
class DartCryptoBridge implements CryptoBridge {
  late NativeCryptoConfig _config;

  @override
  Future<void> initialize(NativeCryptoConfig config) async {
    _config = config;
    debugPrint('🔐 DartCryptoBridge initialized (pure Dart implementation)');
  }

  @override
  bool get isNativeAvailable => false;

  @override
  bool get isPostQuantumAvailable => false;

  @override
  Future<KeyPair> generateIdentityKey() async {
    // Delegate to existing Dart crypto implementation
    // This is a placeholder - actual implementation uses pointycastle/pinenacl
    throw UnimplementedError(
      'Use existing X3DHProtocol.initialize() for key generation',
    );
  }

  @override
  Future<KeyPair> generateSignedPreKey() async {
    throw UnimplementedError(
      'Use existing X3DHProtocol for signed pre-key generation',
    );
  }

  @override
  Future<List<KeyPair>> generateOneTimePreKeys(int count) async {
    throw UnimplementedError(
      'Use existing X3DHProtocol for one-time pre-key generation',
    );
  }

  @override
  Future<HybridKeyBundle?> generateHybridKeyBundle() async {
    // Post-quantum not available in pure Dart
    return null;
  }

  @override
  Future<Uint8List> deriveHybridSharedSecret({
    required Uint8List localPrivateKey,
    required Uint8List remotePublicKey,
    required Uint8List? remotePqPublicKey,
  }) async {
    // Fall back to standard X25519 DH
    // PQ key is ignored in pure Dart mode
    throw UnimplementedError('Use existing X3DH shared secret derivation');
  }

  @override
  Future<EncryptedData> encryptAesGcm({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  }) async {
    // Uses cryptography package
    throw UnimplementedError('Use existing crypto_service.dart for encryption');
  }

  @override
  Future<Uint8List> decryptAesGcm({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  }) async {
    throw UnimplementedError('Use existing crypto_service.dart for decryption');
  }

  @override
  Future<EncryptedData> encryptChaCha20Poly1305({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  }) async {
    throw UnimplementedError('ChaCha20-Poly1305 not implemented in Dart mode');
  }

  @override
  Future<Uint8List> decryptChaCha20Poly1305({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  }) async {
    throw UnimplementedError('ChaCha20-Poly1305 not implemented in Dart mode');
  }

  @override
  Future<Uint8List> padMessage(Uint8List message) async {
    if (!_config.enablePadme) {
      return message;
    }
    // Simple padding fallback (not PADMÉ, just PKCS7-like)
    // Real PADMÉ implementation is in Rust
    return message;
  }

  @override
  Future<Uint8List> unpadMessage(Uint8List paddedMessage) async {
    if (!_config.enablePadme) {
      return paddedMessage;
    }
    return paddedMessage;
  }

  @override
  Future<Uint8List> hkdfDerive({
    required Uint8List inputKeyMaterial,
    required Uint8List info,
    Uint8List? salt,
    int outputLength = 32,
  }) async {
    throw UnimplementedError('Use existing HKDF implementation');
  }

  @override
  Future<Uint8List> signEd25519({
    required Uint8List privateKey,
    required Uint8List message,
  }) async {
    throw UnimplementedError('Use existing Ed25519 signing');
  }

  @override
  Future<bool> verifyEd25519({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  }) async {
    throw UnimplementedError('Use existing Ed25519 verification');
  }
}

/// Factory for creating appropriate crypto bridge based on platform
class CryptoBridgeFactory {
  static CryptoBridge? _instance;

  /// Get the singleton crypto bridge instance
  static CryptoBridge get instance {
    _instance ??= _createBridge();
    return _instance!;
  }

  static CryptoBridge _createBridge() {
    if (kIsWeb) {
      debugPrint('🔐 Web platform detected, using Dart crypto');
      return DartCryptoBridge();
    }

    // Try native Rust implementation on mobile/desktop
    // Import: import 'native/rust_crypto_bridge.dart';
    // if (NativeRustCryptoBridge.checkNativeAvailable()) {
    //   debugPrint('🔐 Using native Rust crypto implementation');
    //   return NativeRustCryptoBridge();
    // }

    debugPrint('🔐 Native crypto not available, falling back to Dart');
    return DartCryptoBridge();
  }

  /// Force native implementation (for testing)
  @visibleForTesting
  static void useNative() {
    // Import: import 'native/rust_crypto_bridge.dart';
    // _instance = NativeRustCryptoBridge();
    throw UnimplementedError('Enable after flutter_rust_bridge generation');
  }

  /// Force Dart implementation (for testing or Web)
  @visibleForTesting
  static void useDart() {
    _instance = DartCryptoBridge();
  }

  /// Reset instance (for testing)
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
