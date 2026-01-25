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

  /// Delete user account permanently
  Future<DeleteAccountSuccess> deleteAccount({
    required String accessToken,
    required String password,
  }) async {
    try {
      final request = DeleteAccountRequest()
        ..accessToken = accessToken
        ..password = password;

      final response = await grpcClients.authClient.deleteAccount(request);

      if (response.hasSuccess()) {
        logger.i('Account deleted successfully: ${response.success.userId}');
        return response.success;
      } else if (response.hasError()) {
        throw AuthException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw AuthException('Unknown error during account deletion');
      }
    } on GrpcError catch (e) {
      logger.e('gRPC error during account deletion: ${e.message}');
      throw AuthException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during account deletion: $e');
      throw AuthException('Account deletion failed: $e');
    }
  }

  /// Generate real X3DH KeyBundle for registration/login
  /// Uses CryptoService to create cryptographically secure keys
  /// 
  /// OPTIMIZED: Uses isolate-based async generation for instant login.
  /// Only 1 key is generated initially - more keys are added in background.
  /// Call [replenishKeysInBackground] after successful auth to generate more.
  Future<common.KeyBundle> _generateX3DHKeyBundle() async {
    final stopwatch = Stopwatch()..start();
    
    // Use async isolate-based generation for non-blocking UI
    logger.i('Generating X3DH key bundle (async isolate)');
    
    final keyBundle = await cryptoService.generateKeyBundleAsync(
      oneTimePreKeyCount: 1, // Minimal for fast startup
    );

    stopwatch.stop();
    logger.i(
      'Generated X3DH key bundle in ${stopwatch.elapsedMilliseconds}ms '
      'with ${keyBundle.oneTimePreKey != null ? 1 : 0} one-time pre-key',
    );

    final now = DateTime.now();
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

  /// Update user profile (avatar, display name, bio)
  Future<UserProfileData> updateProfile({
    required String accessToken,
    String? avatarMediaId,
    String? displayName,
    String? bio,
    bool clearAvatar = false,
  }) async {
    try {
      final request = UpdateProfileRequest()..accessToken = accessToken;

      // Handle avatar: clearAvatar takes precedence
      if (clearAvatar) {
        request.clearAvatar = true;
      } else if (avatarMediaId != null) {
        request.avatarMediaId = avatarMediaId;
      }
      if (displayName != null) {
        request.displayName = displayName;
      }
      if (bio != null) {
        request.bio = bio;
      }

      final response = await grpcClients.authClient.updateProfile(request);

      if (response.hasProfile()) {
        final profile = response.profile;
        logger.i('Profile updated successfully for user: ${profile.userId}');
        return UserProfileData(
          userId: profile.userId,
          username: profile.username,
          avatarMediaId: profile.hasAvatarMediaId() && profile.avatarMediaId.isNotEmpty
              ? profile.avatarMediaId
              : null,
          displayName: profile.hasDisplayName() && profile.displayName.isNotEmpty
              ? profile.displayName
              : null,
          bio: profile.hasBio() && profile.bio.isNotEmpty ? profile.bio : null,
          createdAt: profile.hasCreatedAt()
              ? DateTime.fromMillisecondsSinceEpoch(
                  profile.createdAt.seconds.toInt() * 1000,
                  isUtc: true,
                ).toLocal()
              : null,
        );
      } else if (response.hasError()) {
        throw AuthException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw AuthException('Unknown error during profile update');
      }
    } on GrpcError catch (e) {
      logger.e('gRPC error during profile update: ${e.message}');
      throw AuthException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during profile update: $e');
      throw AuthException('Profile update failed: $e');
    }
  }

  /// Get user profile by user ID
  Future<UserProfileData> getUserProfile({
    required String accessToken,
    required String userId,
  }) async {
    try {
      // Note: GetUserProfileRequest doesn't take access_token per proto design
      // (internal service-to-service call) but we keep the signature for consistency
      final request = GetUserProfileRequest()..userId = userId;

      final response = await grpcClients.authClient.getUserProfile(request);

      if (response.hasSuccess()) {
        final profile = response.success;
        logger.i('Got profile for user: ${profile.userId}');
        return UserProfileData(
          userId: profile.userId,
          username: profile.username,
          avatarMediaId: profile.hasAvatarMediaId() && profile.avatarMediaId.isNotEmpty
              ? profile.avatarMediaId
              : null,
          displayName: profile.hasDisplayName() && profile.displayName.isNotEmpty
              ? profile.displayName
              : null,
          bio: profile.hasBio() && profile.bio.isNotEmpty ? profile.bio : null,
          createdAt: profile.hasCreatedAt()
              ? DateTime.fromMillisecondsSinceEpoch(
                  profile.createdAt.seconds.toInt() * 1000,
                  isUtc: true,
                ).toLocal()
              : null,
        );
      } else if (response.hasError()) {
        throw AuthException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw AuthException('Unknown error during get user profile');
      }
    } on GrpcError catch (e) {
      logger.e('gRPC error during get user profile: ${e.message}');
      throw AuthException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during get user profile: $e');
      throw AuthException('Get user profile failed: $e');
    }
  }
}

/// Data class for user profile information returned from API
class UserProfileData {
  final String userId;
  final String username;
  final String? avatarMediaId;
  final String? displayName;
  final String? bio;
  final DateTime? createdAt;

  UserProfileData({
    required this.userId,
    required this.username,
    this.avatarMediaId,
    this.displayName,
    this.bio,
    this.createdAt,
  });
}
