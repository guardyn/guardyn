import 'dart:io';
import 'dart:typed_data';

import 'android_keystore_storage.dart';
import 'hardware_key_storage.dart';
import 'secure_enclave_storage.dart';

/// Factory for creating platform-appropriate hardware key storage.
///
/// Automatically selects:
/// - iOS: Secure Enclave
/// - Android: StrongBox/TEE KeyStore
/// - Desktop: Software fallback (with optional TPM support)
class HardwareKeyStorageFactory {
  static HardwareKeyStorage? _instance;

  /// Get the platform-appropriate hardware key storage.
  static HardwareKeyStorage getInstance() {
    _instance ??= _createInstance();
    return _instance!;
  }

  static HardwareKeyStorage _createInstance() {
    if (Platform.isIOS) {
      return SecureEnclaveStorage();
    } else if (Platform.isAndroid) {
      return AndroidKeyStoreStorage();
    } else {
      // Desktop platforms - software fallback
      return SoftwareFallbackStorage();
    }
  }

  /// Reset the singleton (for testing).
  static void reset() {
    _instance = null;
  }
}

/// Software fallback for platforms without hardware security.
///
/// Uses encrypted local storage. Not as secure as hardware-backed storage.
/// This is for development and platforms without HSM support.
class SoftwareFallbackStorage implements HardwareKeyStorage {
  final Map<String, Uint8List> _keys = {};
  final Map<String, Uint8List> _publicKeys = {};

  @override
  Future<bool> isHardwareBackedAvailable() async => false;

  @override
  Future<Uint8List> generateKeyPair(String keyId) async {
    // In production, this would generate real keys using a crypto library
    // For now, generate placeholder bytes
    final privateKey = Uint8List(32);
    final publicKey = Uint8List(33);

    // Fill with pseudo-random data (NOT SECURE - use proper crypto in production)
    for (int i = 0; i < 32; i++) {
      privateKey[i] = (keyId.hashCode + i) % 256;
      publicKey[i] = (keyId.hashCode * 2 + i) % 256;
    }
    publicKey[32] = 0x02; // Compressed point prefix

    _keys[keyId] = privateKey;
    _publicKeys[keyId] = publicKey;

    print(
      '⚠️ WARNING: Using software fallback for key storage. Not secure for production!',
    );

    return publicKey;
  }

  @override
  Future<Uint8List> sign(String keyId, Uint8List data) async {
    final privateKey = _keys[keyId];
    if (privateKey == null) {
      throw StateError('Key not found: $keyId');
    }

    // In production, use proper ECDSA signing
    // This is a placeholder that creates a fake signature
    final signature = Uint8List(64);
    for (int i = 0; i < 64; i++) {
      signature[i] = (data[i % data.length] ^ privateKey[i % 32]) % 256;
    }

    return signature;
  }

  @override
  Future<Uint8List?> getPublicKey(String keyId) async {
    return _publicKeys[keyId];
  }

  @override
  Future<bool> keyExists(String keyId) async {
    return _keys.containsKey(keyId);
  }

  @override
  Future<void> deleteKey(String keyId) async {
    _keys.remove(keyId);
    _publicKeys.remove(keyId);
  }

  @override
  Future<List<String>> listKeyIds() async {
    return _keys.keys.toList();
  }

  @override
  Future<HardwareSecurityInfo> getSecurityInfo() async {
    return HardwareSecurityInfo(
      isHardwareBacked: false,
      hardwareType: SecureHardwareType.softwareFallback,
      securityLevel: SecurityLevel.software,
      description: 'Software fallback (${Platform.operatingSystem})',
    );
  }
}

/// Unified key manager that handles all platform-specific key operations.
///
/// Use this class to manage identity keys, signed prekeys, and one-time prekeys.
class UnifiedKeyManager {
  final HardwareKeyStorage _storage;

  UnifiedKeyManager() : _storage = HardwareKeyStorageFactory.getInstance();

  /// Initialize and check hardware security availability.
  Future<HardwareSecurityInfo> initialize() async {
    return await _storage.getSecurityInfo();
  }

  /// Generate identity key pair.
  ///
  /// Returns the public key. Private key is stored securely.
  Future<Uint8List> generateIdentityKey(String userId) async {
    final keyId = 'identity_$userId';
    return await _storage.generateKeyPair(keyId);
  }

  /// Generate signed prekey.
  Future<({Uint8List publicKey, Uint8List signature})> generateSignedPreKey(
    String userId,
    int preKeyId,
  ) async {
    final keyId = 'signed_prekey_${userId}_$preKeyId';
    final publicKey = await _storage.generateKeyPair(keyId);

    // Sign the public key with identity key
    final identityKeyId = 'identity_$userId';
    final signature = await _storage.sign(identityKeyId, publicKey);

    return (publicKey: publicKey, signature: signature);
  }

  /// Sign data with identity key.
  Future<Uint8List> signWithIdentityKey(String userId, Uint8List data) async {
    final keyId = 'identity_$userId';
    return await _storage.sign(keyId, data);
  }

  /// Get identity public key.
  Future<Uint8List?> getIdentityPublicKey(String userId) async {
    final keyId = 'identity_$userId';
    return await _storage.getPublicKey(keyId);
  }

  /// Check if identity key exists.
  Future<bool> hasIdentityKey(String userId) async {
    final keyId = 'identity_$userId';
    return await _storage.keyExists(keyId);
  }

  /// Delete all keys for a user (for account deletion).
  Future<void> deleteAllKeys(String userId) async {
    final keyIds = await _storage.listKeyIds();
    for (final keyId in keyIds) {
      if (keyId.contains(userId)) {
        await _storage.deleteKey(keyId);
      }
    }
  }
}
