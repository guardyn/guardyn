import 'package:guardyn_client/features/auth/domain/entities/user.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Register a new user
  ///
  /// Throws [AuthException] on failure
  Future<User> register({
    required String username,
    required String password,
    required String deviceName,
  });

  /// Login an existing user
  ///
  /// Throws [AuthException] on failure
  Future<User> login({required String username, required String password});

  /// Logout the current user
  ///
  /// Throws [AuthException] on failure
  Future<void> logout();

  /// Get the currently authenticated user (from secure storage)
  Future<User?> getCurrentUser();

  /// Check if user is authenticated (has valid access token)
  Future<bool> isAuthenticated();
}

/// Authentication-related exceptions
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
