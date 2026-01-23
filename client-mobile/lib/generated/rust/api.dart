// AUTO-GENERATED STUB FILE
// This file is a placeholder for Flutter Rust Bridge generated code.
// Run `flutter_rust_bridge_codegen generate` to regenerate real bindings.
//
// DO NOT EDIT MANUALLY
library;

import 'dart:typed_data';

// ============================================================================
// Data Types (stubs matching Rust API)
// ============================================================================

/// Key pair with public and private components
class KeyPair {
  final List<int> publicKey;
  final List<int> privateKey;
  final String keyType;

  KeyPair({
    required this.publicKey,
    required this.privateKey,
    required this.keyType,
  });
}

/// Encrypted data container
class EncryptedData {
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List tag;

  EncryptedData({
    required this.ciphertext,
    required this.nonce,
    required this.tag,
  });
}

/// Hybrid key bundle for PQXDH
class HybridKeyBundle {
  final List<int> x25519Public;
  final List<int> x25519Private;
  final List<int> mlKemPublic;
  final List<int> mlKemPrivate;

  HybridKeyBundle({
    required this.x25519Public,
    required this.x25519Private,
    required this.mlKemPublic,
    required this.mlKemPrivate,
  });
}

/// Crypto library status information
class CryptoStatus {
  final bool initialized;
  final bool postQuantumAvailable;
  final String version;

  CryptoStatus({
    required this.initialized,
    required this.postQuantumAvailable,
    required this.version,
  });
}

// ============================================================================
// Stub Functions (throw when called - native library not loaded)
// ============================================================================

const _stubError =
    'Native crypto library not loaded. '
    'Run `flutter_rust_bridge_codegen generate` and build native libraries.';

/// Initialize the cryptographic library
void cryptoInit() {
  throw UnsupportedError(_stubError);
}

/// Get the current status of the crypto library
CryptoStatus cryptoStatus() {
  throw UnsupportedError(_stubError);
}

/// Generate Ed25519 key pair
KeyPair cryptoGenerateEd25519Keypair() {
  throw UnsupportedError(_stubError);
}

/// Generate Ed25519 key pair from seed
KeyPair cryptoGenerateEd25519KeypairFromSeed({required List<int> seed}) {
  throw UnsupportedError(_stubError);
}

/// Generate X25519 key pair
KeyPair cryptoGenerateX25519Keypair() {
  throw UnsupportedError(_stubError);
}

/// Generate hybrid key bundle (X25519 + ML-KEM-768)
HybridKeyBundle? cryptoGenerateHybridKeyBundle() {
  throw UnsupportedError(_stubError);
}

/// X25519 Diffie-Hellman
Uint8List cryptoX25519Dh({
  required List<int> privateKey,
  required List<int> publicKey,
}) {
  throw UnsupportedError(_stubError);
}

/// Encrypt with AES-256-GCM
Future<EncryptedData> cryptoEncryptAesGcm({
  required List<int> plaintext,
  required List<int> key,
  List<int>? nonce,
  List<int>? associatedData,
}) async {
  throw UnsupportedError(_stubError);
}

/// Decrypt AES-256-GCM
Future<Uint8List> cryptoDecryptAesGcm({
  required EncryptedData encrypted,
  required List<int> key,
  List<int>? associatedData,
}) async {
  throw UnsupportedError(_stubError);
}

/// Encrypt with ChaCha20-Poly1305
Future<EncryptedData> cryptoEncryptChacha20({
  required List<int> plaintext,
  required List<int> key,
  List<int>? nonce,
  List<int>? associatedData,
}) async {
  throw UnsupportedError(_stubError);
}

/// Decrypt ChaCha20-Poly1305
Future<Uint8List> cryptoDecryptChacha20({
  required EncryptedData encrypted,
  required List<int> key,
  List<int>? associatedData,
}) async {
  throw UnsupportedError(_stubError);
}

/// Apply PADMÉ padding
Future<Uint8List> cryptoPadMessage({required List<int> message}) async {
  throw UnsupportedError(_stubError);
}

/// Remove PADMÉ padding
Future<Uint8List> cryptoUnpadMessage({required List<int> paddedMessage}) async {
  throw UnsupportedError(_stubError);
}

/// HKDF-SHA256 key derivation
Future<Uint8List> cryptoHkdf({
  required List<int> inputKeyMaterial,
  List<int>? salt,
  required List<int> info,
  required int outputLength,
}) async {
  throw UnsupportedError(_stubError);
}

/// Sign with Ed25519
Uint8List cryptoSignEd25519({
  required List<int> privateKey,
  required List<int> message,
}) {
  throw UnsupportedError(_stubError);
}

/// Verify Ed25519 signature
bool cryptoVerifyEd25519({
  required List<int> publicKey,
  required List<int> message,
  required List<int> signature,
}) {
  throw UnsupportedError(_stubError);
}

/// Convert Ed25519 public key to X25519
Uint8List cryptoEd25519PublicToX25519({required List<int> ed25519Public}) {
  throw UnsupportedError(_stubError);
}

/// Convert Ed25519 secret key to X25519
Uint8List cryptoEd25519SecretToX25519({required List<int> ed25519Seed}) {
  throw UnsupportedError(_stubError);
}

/// Generate random bytes
Uint8List cryptoRandomBytes({required int length}) {
  throw UnsupportedError(_stubError);
}

/// Constant-time byte comparison
bool cryptoConstantTimeEq({required List<int> a, required List<int> b}) {
  throw UnsupportedError(_stubError);
}
