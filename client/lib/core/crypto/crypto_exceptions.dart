/// Cryptographic exceptions for E2EE operations

/// Base class for crypto exceptions
abstract class CryptoException implements Exception {
  final String message;
  const CryptoException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when key generation fails
class KeyGenerationException extends CryptoException {
  const KeyGenerationException(super.message);
}

/// Thrown when encryption fails
class EncryptionException extends CryptoException {
  const EncryptionException(super.message);
}

/// Thrown when decryption fails
class DecryptionException extends CryptoException {
  const DecryptionException(super.message);
}

/// Thrown when key derivation fails
class KeyDerivationException extends CryptoException {
  const KeyDerivationException(super.message);
}

/// Thrown when protocol error occurs
class ProtocolException extends CryptoException {
  const ProtocolException(super.message);
}

/// Thrown when invalid key is provided
class InvalidKeyException extends CryptoException {
  const InvalidKeyException(super.message);
}
