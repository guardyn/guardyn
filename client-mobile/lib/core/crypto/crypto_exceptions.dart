/// Cryptographic exceptions for E2EE operations
library;

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

/// Thrown when padding is malformed or a message is too large to pad
class PaddingException extends CryptoException {
  const PaddingException(super.message);
}

/// Thrown when a message cannot be encrypted or decrypted and there is no safe alternative.
///
/// This exists so the message path has something to *fail with*. It previously fell back to
/// sending the plaintext, which is the I-2 breach this type replaces: encryption that can be
/// skipped when it is inconvenient is not always-on encryption.
class EncryptionUnavailableException extends CryptoException {
  const EncryptionUnavailableException(super.message);
}
