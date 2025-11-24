import 'dart:math';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/common.pb.dart' as common;
import 'package:logger/logger.dart';

/// Remote data source for authentication via gRPC
class AuthRemoteDatasource {
  final GrpcClients grpcClients;
  final Logger logger = Logger();

  AuthRemoteDatasource(this.grpcClients);

  /// Register a new user
  Future<RegisterSuccess> register({
    required String username,
    required String password,
    required String deviceName,
  }) async {
    try {
      // Generate placeholder KeyBundle (will be replaced with real crypto later)
      final keyBundle = _generatePlaceholderKeyBundle();

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
      // Generate placeholder KeyBundle for new device
      final keyBundle = _generatePlaceholderKeyBundle();

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
    } catch (e) {
      logger.e('Unexpected error during user search: $e');
      throw AuthException('User search failed: $e');
    }
  }

  /// Generate placeholder KeyBundle (temporary until real crypto is implemented)
  /// TODO: Replace with real X3DH key generation
  common.KeyBundle _generatePlaceholderKeyBundle() {
    final random = Random.secure();
    final now = DateTime.now();
    
    return common.KeyBundle()
      ..identityKey = Uint8List.fromList(
        List.generate(32, (_) => random.nextInt(256)),
      )
      ..signedPreKey = Uint8List.fromList(
        List.generate(32, (_) => random.nextInt(256)),
      )
      ..signedPreKeySignature = Uint8List.fromList(
        List.generate(64, (_) => random.nextInt(256)),
      )
      ..oneTimePreKeys.addAll([
        Uint8List.fromList(List.generate(32, (_) => random.nextInt(256))),
        Uint8List.fromList(List.generate(32, (_) => random.nextInt(256))),
      ])
      ..createdAt = (common.Timestamp()
        ..seconds = Int64(now.millisecondsSinceEpoch ~/ 1000)
        ..nanos = (now.millisecondsSinceEpoch % 1000) * 1000000);
  }
}
