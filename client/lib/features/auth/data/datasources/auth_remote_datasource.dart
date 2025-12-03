import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/common.pb.dart' as common;
import 'package:logger/logger.dart';

/// Remote data source for authentication via gRPC
class AuthRemoteDatasource {
  final GrpcClients grpcClients;
  final CryptoService cryptoService;
  final Logger logger = Logger();

  AuthRemoteDatasource(this.grpcClients, this.cryptoService);

  /// Register a new user
  Future<RegisterSuccess> register({
    required String username,
    required String password,
    required String deviceName,
  }) async {
    try {
      // Generate real X3DH KeyBundle for E2EE
      final keyBundle = await _generateX3DHKeyBundle();

      final request = RegisterRequest()
        ..username = username
        ..password = password
        ..deviceName = deviceName
        ..deviceType = 'flutter'
        ..keyBundle = keyBundle;

      final response = await grpcClients.authClient.register(request);

      if (response.hasSuccess()) {
        logger.i('Registration successful for user: $username');
        return response.success;
      } else if (response.hasError()) {
        throw AuthException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw AuthException('Unknown error during registration');
      }
    } on GrpcError catch (e) {
      logger.e('gRPC error during registration: ${e.message}');
      throw AuthException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during registration: $e');
      throw AuthException('Registration failed: $e');
    }
  }

  /// Login an existing user
  Future<LoginSuccess> login({
    required String username,
    required String password,
  }) async {
    try {
      // Generate real X3DH KeyBundle for E2EE
      final keyBundle = await _generateX3DHKeyBundle();

      final request = LoginRequest()
        ..username = username
        ..password = password
        ..deviceName = 'Flutter Client'
        ..deviceType = 'flutter'
        ..keyBundle = keyBundle;

      final response = await grpcClients.authClient.login(request);

      if (response.hasSuccess()) {
        logger.i('Login successful for user: $username');
        return response.success;
      } else if (response.hasError()) {
        throw AuthException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw AuthException('Unknown error during login');
      }
    } on GrpcError catch (e) {
      logger.e('gRPC error during login: ${e.message}');
      throw AuthException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during login: $e');
      throw AuthException('Login failed: $e');
    }
  }

  /// Logout current user
  Future<void> logout(String accessToken) async {
    try {
      final request = LogoutRequest()..accessToken = accessToken;

      final response = await grpcClients.authClient.logout(request);

      if (response.hasSuccess()) {
        logger.i('Logout successful');
      } else if (response.hasError()) {
        throw AuthException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw AuthException('Unknown error during logout');
      }
    } on GrpcError catch (e) {
      logger.e('gRPC error during logout: ${e.message}');
      throw AuthException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during logout: $e');
      throw AuthException('Logout failed: $e');
    }
  }

  /// Search for users by username
  Future<List<UserSearchResult>> searchUsers({
    required String accessToken,
    required String query,
    int limit = 20,
  }) async {
    try {
      final request = SearchUsersRequest()
        ..accessToken = accessToken
        ..query = query
        ..limit = limit;

      final response = await grpcClients.authClient.searchUsers(request);

      if (response.hasSuccess()) {
        logger.i('User search successful, found ${response.success.users.length} results');
        return response.success.users;
      } else if (response.hasError()) {
        throw AuthException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw AuthException('Unknown error during user search');
      }
    } on GrpcError catch (e) {
      logger.e('gRPC error during user search: ${e.message}');
      throw AuthException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during user search: $e');
      throw AuthException('User search failed: $e');
    }
  }

  /// Generate real X3DH KeyBundle for registration/login
  /// Uses CryptoService to create cryptographically secure keys
  Future<common.KeyBundle> _generateX3DHKeyBundle() async {
    // Initialize X3DH if not already done
    if (!cryptoService.isInitialized) {
      logger.i('Initializing X3DH protocol for key bundle generation');
      await cryptoService.initializeX3DH(oneTimePreKeyCount: 100);
    }

    // Export real cryptographic key bundle
    final keyBundle = cryptoService.exportKeyBundle(oneTimePreKeyIndex: 0);
    if (keyBundle == null) {
      throw AuthException('Failed to generate X3DH key bundle');
    }

    final now = DateTime.now();
    logger.i('Generated real X3DH key bundle with ${keyBundle.oneTimePreKey != null ? 1 : 0} one-time pre-key');

    return common.KeyBundle()
      ..identityKey = keyBundle.identityKey
      ..signedPreKey = keyBundle.signedPreKey
      ..signedPreKeySignature = keyBundle.signedPreKeySignature
      ..oneTimePreKeys.addAll([
        if (keyBundle.oneTimePreKey != null) keyBundle.oneTimePreKey!,
      ])
      ..createdAt = (common.Timestamp()
        ..seconds = Int64(now.millisecondsSinceEpoch ~/ 1000)
        ..nanos = (now.millisecondsSinceEpoch % 1000) * 1000000);
  }
}
