import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:logger/logger.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final SecureStorage secureStorage;
  final CryptoService cryptoService;
  final Logger logger = Logger();

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.secureStorage,
    required this.cryptoService,
  });

  @override
  Future<User> register({
    required String username,
    required String password,
    required String deviceName,
  }) async {
    try {
      final response = await remoteDatasource.register(
        username: username,
        password: password,
        deviceName: deviceName,
      );

      // Store tokens and user info
      await Future.wait([
        secureStorage.saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
        secureStorage.saveUserId(response.userId),
        secureStorage.saveDeviceId(response.deviceId),
        secureStorage.saveUsername(username),
      ]);

      logger.i('User registered and tokens stored: ${response.userId}');

      return User(
        userId: response.userId,
        username: username,
        deviceId: response.deviceId,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          response.createdAt.seconds.toInt() * 1000,
        ),
      );
    } catch (e) {
      logger.e('Registration failed: $e');
      rethrow;
    }
  }

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await remoteDatasource.login(
        username: username,
        password: password,
      );

      // Store tokens and user info
      await Future.wait([
        secureStorage.saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
        secureStorage.saveUserId(response.userId),
        secureStorage.saveDeviceId(response.deviceId),
        secureStorage.saveUsername(username),
      ]);

      logger.i('User logged in and tokens stored: ${response.userId}');

      return User(
        userId: response.userId,
        username: username,
        deviceId: response.deviceId,
      );
    } catch (e) {
      logger.e('Login failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken != null) {
        try {
          // Call backend to invalidate session
          await remoteDatasource.logout(accessToken);
        } on AuthException catch (e) {
          // If token is already invalid/expired, that's fine - user is already logged out on server
          if (e.code == 'UNAUTHORIZED' || e.code == 'ErrorCode.UNAUTHORIZED') {
            logger.w(
              'Token already invalid during logout, continuing with local cleanup',
            );
          } else {
            rethrow;
          }
        }
      }

      // Clear all local data
      await secureStorage.clearAll();
      // Clear all crypto state (X3DH keys and sessions)
      await cryptoService.clearAll();

      logger.i('User logged out and local data cleared');
    } catch (e) {
      logger.e('Logout failed: $e');
      // Still clear local data even if backend call fails
      await secureStorage.clearAll();
      await cryptoService.clearAll();
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null) {
        throw AuthException('Not authenticated');
      }

      // Call backend to delete account
      await remoteDatasource.deleteAccount(
        accessToken: accessToken,
        password: password,
      );

      // Clear all local data
      await secureStorage.clearAll();
      // Clear all crypto state (X3DH keys and sessions)
      await cryptoService.clearAll();

      logger.i('Account deleted and local data cleared');
    } catch (e) {
      logger.e('Account deletion failed: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userId = await secureStorage.getUserId();
      final username = await secureStorage.getUsername();
      final deviceId = await secureStorage.getDeviceId();

      if (userId != null && username != null && deviceId != null) {
        return User(userId: userId, username: username, deviceId: deviceId);
      }
      return null;
    } catch (e) {
      logger.e('Failed to get current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await secureStorage.isAuthenticated();
  }
}
