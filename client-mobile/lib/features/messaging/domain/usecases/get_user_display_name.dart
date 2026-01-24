import 'package:dartz/dartz.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/grpc_clients.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../generated/auth.pb.dart';

/// Use case for getting a user's display name
/// Used by MessageBloc to resolve sender usernames for incoming messages
class GetUserDisplayName {
  final GrpcClients _grpcClients;
  final SecureStorage _secureStorage;

  /// Cache of userId -> displayName to avoid repeated API calls
  final Map<String, String> _cache = {};

  GetUserDisplayName({
    GrpcClients? grpcClients,
    SecureStorage? secureStorage,
  })  : _grpcClients = grpcClients ?? getIt<GrpcClients>(),
        _secureStorage = secureStorage ?? getIt<SecureStorage>();

  /// Get the display name for a user
  /// Returns username or displayName, with fallback to userId
  Future<Either<Failure, String>> call(String userId) async {
    // Check cache first
    if (_cache.containsKey(userId)) {
      return Right(_cache[userId]!);
    }

    try {
      // Verify we have a valid session
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        return Left(ServerFailure('No access token available'));
      }

      // Build request using proto builder pattern
      final request = GetUserProfileRequest()..userId = userId;

      final response = await _grpcClients.authClient.getUserProfile(request);

      if (response.hasSuccess()) {
        final profile = response.success;
        // Prefer displayName, fallback to username
        final displayName = profile.displayName.isNotEmpty
            ? profile.displayName
            : profile.username;

        // Cache the result
        _cache[userId] = displayName;
        return Right(displayName);
      } else if (response.hasError()) {
        return Left(ServerFailure(response.error.message));
      }

      return Left(ServerFailure('Unknown error getting user profile'));
    } catch (e) {
      return Left(ServerFailure('Failed to get user profile: $e'));
    }
  }

  /// Get display name synchronously from cache (returns null if not cached)
  String? getCached(String userId) {
    return _cache[userId];
  }

  /// Pre-populate cache (useful when you already know the username)
  void cacheUsername(String userId, String displayName) {
    _cache[userId] = displayName;
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }
}
