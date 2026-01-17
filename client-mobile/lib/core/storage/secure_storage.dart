import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for sensitive data like tokens and keys
class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys for storage
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyDeviceId = 'device_id';
  static const String _keyUsername = 'username';

  // Token management
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }

  // User info management
  Future<void> saveUserId(String userId) async {
    // ignore: avoid_print
    print('🔒 SecureStorage.saveUserId: $userId');
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    final userId = await _storage.read(key: _keyUserId);
    // ignore: avoid_print
    print('🔒 SecureStorage.getUserId: $userId');
    return userId;
  }

  Future<void> saveDeviceId(String deviceId) async {
    // ignore: avoid_print
    print('🔒 SecureStorage.saveDeviceId: $deviceId');
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  Future<String?> getDeviceId() async {
    final deviceId = await _storage.read(key: _keyDeviceId);
    // ignore: avoid_print
    print('🔒 SecureStorage.getDeviceId: $deviceId');
    return deviceId;
  }

  Future<void> saveUsername(String username) async {
    await _storage.write(key: _keyUsername, value: username);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
