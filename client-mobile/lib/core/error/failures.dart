import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server-side failures (HTTP 5xx, gRPC errors)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Network-related failures (no internet, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

/// Authentication failures (invalid token, expired session)
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

/// Validation failures (invalid input data)
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Storage failures (local database, secure storage)
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed']);
}

/// Cryptography failures (encryption/decryption errors)
class CryptoFailure extends Failure {
  const CryptoFailure([super.message = 'Cryptography operation failed']);
}

/// Call/WebRTC failures
class CallFailure extends Failure {
  const CallFailure([super.message = 'Call operation failed']);
}

/// Media failures (camera, microphone access)
class MediaFailure extends Failure {
  const MediaFailure([super.message = 'Media access failed']);
}

/// Generic/unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
/// Not found failures (resource doesn't exist)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Conflict failures (resource already exists)
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Resource already exists']);
}
