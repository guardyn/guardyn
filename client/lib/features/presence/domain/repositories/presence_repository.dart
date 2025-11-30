import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/presence_info.dart';

/// Repository interface for presence operations
/// (Implementation will be in data layer)
abstract class PresenceRepository {
  /// Get presence for a single user
  /// Returns presence info including status, last seen, and typing indicator
  Future<Either<Failure, PresenceInfo>> getUserPresence(String userId);

  /// Get presence for multiple users (batch)
  /// Returns a map of userId to PresenceInfo
  /// Useful for conversation lists to fetch all statuses at once
  Future<Either<Failure, Map<String, PresenceInfo>>> getBulkPresence(
    List<String> userIds,
  );

  /// Update current user's status
  /// Sets the user's presence status (online, away, dnd, etc.)
  Future<Either<Failure, void>> updateMyStatus(PresenceStatus status);

  /// Send heartbeat to keep online status
  /// Should be called periodically to maintain online presence
  Future<Either<Failure, void>> sendHeartbeat();

  /// Send typing indicator
  /// Notifies the server that user started/stopped typing
  Future<Either<Failure, void>> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  });

  /// Subscribe to real-time presence updates
  /// Returns a stream that emits presence changes for specified users
  Stream<PresenceInfo> subscribeToPresence(List<String> userIds);
}
