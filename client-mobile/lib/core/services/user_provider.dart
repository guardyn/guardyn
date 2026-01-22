import '../storage/secure_storage.dart';

/// Provider for current user information
///
/// This service provides centralized access to the current user's data
/// stored in secure storage. Used by repositories and services that
/// need the current user ID for API calls.
class UserProvider {
  final SecureStorage _secureStorage;

  /// Cached user ID for performance
  String? _cachedUserId;

  UserProvider(this._secureStorage);

  /// Gets the current user ID
  ///
  /// Returns the cached value if available, otherwise reads from
  /// secure storage. Returns empty string if not authenticated.
  Future<String> getCurrentUserId() async {
    if (_cachedUserId != null && _cachedUserId!.isNotEmpty) {
      return _cachedUserId!;
    }

    final userId = await _secureStorage.getUserId();
    _cachedUserId = userId ?? '';
    return _cachedUserId!;
  }

  /// Gets current user ID synchronously
  ///
  /// Returns cached value or empty string if not yet loaded.
  /// Use [getCurrentUserId] for async access that ensures the value
  /// is loaded from storage.
  String get currentUserIdSync => _cachedUserId ?? '';

  /// Updates the cached user ID
  ///
  /// Should be called after login/registration when user ID is known.
  void setCurrentUserId(String userId) {
    _cachedUserId = userId;
  }

  /// Clears the cached user ID
  ///
  /// Should be called on logout.
  void clearCurrentUserId() {
    _cachedUserId = null;
  }

  /// Checks if user is authenticated
  Future<bool> isAuthenticated() async {
    final userId = await getCurrentUserId();
    return userId.isNotEmpty;
  }
}
