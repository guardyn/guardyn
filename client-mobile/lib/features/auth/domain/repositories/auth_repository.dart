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

  /// Delete user account permanently
  /// This removes all user data from the server and local storage
  ///
  /// Throws [AuthException] on failure
  Future<void> deleteAccount({required String password});

  /// Get the currently authenticated user (from secure storage)
  Future<User?> getCurrentUser();

  /// Check if user is authenticated (has valid access token)
  Future<bool> isAuthenticated();

  /// Update user profile (avatar, display name, bio)
  ///
  /// All parameters are optional:
  /// - [avatarMediaId]: New avatar media ID (null = no change, empty = remove)
  /// - [displayName]: New display name (null = no change, empty = remove)
  /// - [bio]: New bio text (null = no change, empty = remove)
  /// - [clearAvatar]: If true, remove the current avatar
  ///
  /// Returns the updated [User] entity
  /// Throws [AuthException] on failure
  Future<User> updateProfile({
    String? avatarMediaId,
    String? displayName,
    String? bio,
    bool clearAvatar = false,
  });

  /// Get user profile by user ID
  ///
  /// Returns [User] entity with profile information
  /// Throws [AuthException] on failure
  Future<User> getUserProfile(String userId);
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
