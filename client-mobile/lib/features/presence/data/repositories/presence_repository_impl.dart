import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/presence_info.dart';
import '../../domain/repositories/presence_repository.dart';
import '../datasources/presence_remote_datasource.dart';

/// Implementation of PresenceRepository
/// Handles presence data fetching, caching, and real-time updates
@Injectable(as: PresenceRepository)
class PresenceRepositoryImpl implements PresenceRepository {
  final PresenceRemoteDatasource remoteDatasource;
  final SecureStorage secureStorage;
  final Logger _logger = Logger();

  // In-memory cache for presence info
  final Map<String, PresenceInfo> _presenceCache = {};

  // Timer for periodic heartbeat
  Timer? _heartbeatTimer;

  PresenceRepositoryImpl(
    this.remoteDatasource,
    this.secureStorage,
  );

  @override
  Future<Either<Failure, PresenceInfo>> getUserPresence(String userId) async {
    try {
      // Check cache first
      if (_presenceCache.containsKey(userId)) {
        final cached = _presenceCache[userId]!;
        // Cache is valid for 30 seconds for online users, 5 minutes for offline
        final cacheAge = DateTime.now().difference(cached.lastSeen ?? DateTime(2000));
        if (cached.isOnline && cacheAge.inSeconds < 30) {
          return Right(cached);
        } else if (!cached.isOnline && cacheAge.inMinutes < 5) {
          return Right(cached);
        }
      }

      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Fetch from server
      final presenceModel = await remoteDatasource.getUserPresence(
        accessToken: accessToken,
        userId: userId,
      );

      // Update cache
      final presenceInfo = presenceModel.toEntity();
      _presenceCache[userId] = presenceInfo;

      return Right(presenceInfo);
    } on GrpcError catch (e) {
      _logger.w('gRPC error getting presence for $userId: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error getting presence for $userId: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, PresenceInfo>>> getBulkPresence(
    List<String> userIds,
  ) async {
    try {
      if (userIds.isEmpty) {
        return const Right({});
      }

      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Use bulk presence RPC for efficient batch retrieval
      final presenceModels = await remoteDatasource.getBulkStatus(
        accessToken: accessToken,
        userIds: userIds,
      );

      final result = <String, PresenceInfo>{};
      for (final model in presenceModels) {
        final presenceInfo = model.toEntity();
        result[model.userId] = presenceInfo;
        _presenceCache[model.userId] = presenceInfo;
      }

      return Right(result);
    } on GrpcError catch (e) {
      _logger.w('gRPC error getting bulk presence: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error getting bulk presence: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMyStatus(PresenceStatus status) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      await remoteDatasource.updateStatus(
        accessToken: accessToken,
        status: status,
      );

      // Start or stop heartbeat based on status
      if (status == PresenceStatus.online) {
        _startHeartbeat();
      } else {
        _stopHeartbeat();
      }

      return const Right(null);
    } on GrpcError catch (e) {
      _logger.w('gRPC error updating status: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error updating status: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendHeartbeat() async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      await remoteDatasource.updateLastSeen(
        accessToken: accessToken,
      );

      return const Right(null);
    } on GrpcError catch (e) {
      _logger.w('gRPC error sending heartbeat: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error sending heartbeat: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // conversationId is actually the other user's ID for 1-on-1 chats
      await remoteDatasource.setTyping(
        accessToken: accessToken,
        conversationUserId: conversationId,
        isTyping: isTyping,
      );

      return const Right(null);
    } on GrpcError catch (e) {
      _logger.w('gRPC error sending typing indicator: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error sending typing indicator: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<PresenceInfo> subscribeToPresence(List<String> userIds) async* {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount <= maxRetries) {
      try {
        // Get access token
        final accessToken = await secureStorage.getAccessToken();
        if (accessToken == null) {
          _logger.w('No access token for presence subscription');
          return;
        }

        final stream = remoteDatasource.subscribe(
          accessToken: accessToken,
          userIds: userIds,
        );

        await for (final update in stream) {
          final presenceInfo = update.toEntity();
          _presenceCache[presenceInfo.userId] = presenceInfo;
          yield presenceInfo;
          // Reset retry count on successful data
          retryCount = 0;
        }
        // Stream ended normally
        break;
      } on GrpcError catch (e) {
        _logger.w('gRPC error subscribing to presence (attempt ${retryCount + 1}): ${e.message}');
        // Don't retry on auth errors
        if (e.code == StatusCode.unauthenticated || e.code == StatusCode.permissionDenied) {
          break;
        }
        retryCount++;
        if (retryCount <= maxRetries) {
          await Future<void>.delayed(retryDelay * retryCount);
        }
      } catch (e) {
        _logger.e('Error subscribing to presence (attempt ${retryCount + 1}): $e');
        retryCount++;
        if (retryCount <= maxRetries) {
          await Future<void>.delayed(retryDelay * retryCount);
        }
      }
    }

    if (retryCount > maxRetries) {
      _logger.w('Presence subscription failed after $maxRetries retries');
    }
  }

  // Start periodic heartbeat to maintain online status
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => sendHeartbeat(),
    );
  }

  // Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Get cached presence (returns null if not cached)
  PresenceInfo? getCachedPresence(String userId) {
    return _presenceCache[userId];
  }

  /// Clear presence cache
  void clearCache() {
    _presenceCache.clear();
  }

  /// Dispose repository resources
  void dispose() {
    _stopHeartbeat();
    _presenceCache.clear();
  }

  // Handle gRPC errors and convert to Failure
  Failure _handleGrpcError(GrpcError e) {
    switch (e.code) {
      case StatusCode.unauthenticated:
        return const AuthFailure('Authentication required');
      case StatusCode.permissionDenied:
        return const AuthFailure('Permission denied');
      case StatusCode.notFound:
        return const ServerFailure('User not found');
      case StatusCode.unavailable:
        return const NetworkFailure('Service unavailable');
      default:
        return ServerFailure(e.message ?? 'Unknown error');
    }
  }
}
