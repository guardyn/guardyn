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
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

/// Network-related failures (no internet, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed']) : super(message);
}

/// Authentication failures (invalid token, expired session)
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed']) : super(message);
}

/// Validation failures (invalid input data)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed']) : super(message);
}

/// Storage failures (local database, secure storage)
class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage operation failed']) : super(message);
}

/// Cryptography failures (encryption/decryption errors)
class CryptoFailure extends Failure {
  const CryptoFailure([String message = 'Cryptography operation failed']) : super(message);
}

/// Generic/unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred']) : super(message);
}
