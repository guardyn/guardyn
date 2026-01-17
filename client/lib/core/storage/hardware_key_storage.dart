import 'package:flutter/foundation.dart';

/// Abstract interface for hardware-backed key storage.
///
/// Provides platform-specific secure key storage using:
/// - iOS: Secure Enclave
/// - Android: StrongBox/TEE KeyStore
/// - Desktop: TPM 2.0 or software fallback
abstract class HardwareKeyStorage {
  /// Check if hardware-backed storage is available
  Future<bool> isHardwareBackedAvailable();

  /// Generate a new key pair in secure hardware.
  ///
  /// Returns the public key bytes. Private key never leaves the secure hardware.
  Future<Uint8List> generateKeyPair(String keyId);

  /// Sign data using the private key stored in secure hardware.
  ///
  /// The private key never leaves the secure enclave.
  Future<Uint8List> sign(String keyId, Uint8List data);

  /// Get the public key for a key ID.
  Future<Uint8List?> getPublicKey(String keyId);

  /// Check if a key exists.
  Future<bool> keyExists(String keyId);

  /// Delete a key from secure storage.
  Future<void> deleteKey(String keyId);

  /// List all key IDs.
  Future<List<String>> listKeyIds();

  /// Get information about secure hardware.
  Future<HardwareSecurityInfo> getSecurityInfo();
}

/// Information about the hardware security module.
class HardwareSecurityInfo {
  /// Whether hardware-backed keys are available.
  final bool isHardwareBacked;

  /// Type of secure hardware.
  final SecureHardwareType hardwareType;

  /// Security level provided.
  final SecurityLevel securityLevel;

  /// Human-readable description.
  final String description;

  const HardwareSecurityInfo({
    required this.isHardwareBacked,
    required this.hardwareType,
    required this.securityLevel,
    required this.description,
  });

  @override
  String toString() =>
      'HardwareSecurityInfo(hardware: $isHardwareBacked, type: $hardwareType, level: $securityLevel)';
}

/// Types of secure hardware.
enum SecureHardwareType {
  /// iOS Secure Enclave.
  secureEnclave,

  /// Android StrongBox (dedicated secure processor).
  strongBox,

  /// Android TEE (Trusted Execution Environment).
  tee,

  /// Android software-only KeyStore.
  androidSoftware,

  /// TPM 2.0 module.
  tpm,

  /// Software-only fallback.
  softwareFallback,

  /// Unknown hardware type.
  unknown,
}

/// Security levels for key storage.
enum SecurityLevel {
  /// Hardware-backed with tamper resistance.
  hardware,

  /// Firmware-backed (TEE).
  firmware,

  /// Software-only.
  software,

  /// Unknown security level.
  unknown,
}

/// Key metadata.
@immutable
class KeyMetadata {
  /// Unique identifier for the key.
  final String keyId;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Key algorithm.
  final String algorithm;

  /// Whether the key is hardware-backed.
  final bool isHardwareBacked;

  const KeyMetadata({
    required this.keyId,
    required this.createdAt,
    required this.algorithm,
    required this.isHardwareBacked,
  });
}
