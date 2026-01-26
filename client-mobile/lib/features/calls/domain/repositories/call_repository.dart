/// Call Repository Interface
///
/// Defines the contract for call-related data operations.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';

/// Repository interface for call operations
abstract class CallRepository {
  /// Initiate a new call
  ///
  /// [userId] - Remote user ID to call
  /// [type] - Type of call (voice/video)
  /// Returns the created Call or a Failure
  Future<Either<Failure, Call>> initiateCall({
    required String userId,
    required CallType type,
  });

  /// Accept an incoming call
  ///
  /// [callId] - ID of the incoming call
  Future<Either<Failure, Call>> acceptCall(String callId);

  /// Reject/decline an incoming call
  ///
  /// [callId] - ID of the incoming call
  Future<Either<Failure, void>> rejectCall(String callId);

  /// End an active call
  ///
  /// [callId] - ID of the active call
  Future<Either<Failure, void>> endCall(String callId);

  /// Toggle local mute state
  ///
  /// [callId] - ID of the active call
  /// [muted] - New mute state
  Future<Either<Failure, void>> setMuted(String callId, bool muted);

  /// Toggle local video state
  ///
  /// [callId] - ID of the active call
  /// [enabled] - New video state
  Future<Either<Failure, void>> setVideoEnabled(String callId, bool enabled);

  /// Toggle speaker state
  ///
  /// [callId] - ID of the active call
  /// [enabled] - New speaker state
  Future<Either<Failure, void>> setSpeakerEnabled(String callId, bool enabled);

  /// Switch between front and back camera
  ///
  /// [callId] - ID of the active call
  Future<Either<Failure, void>> switchCamera(String callId);

  /// Get call history
  ///
  /// [limit] - Maximum number of calls to return
  /// [offset] - Pagination offset
  /// [type] - Optional filter by call type
  Future<Either<Failure, List<Call>>> getCallHistory({
    int limit = 50,
    int offset = 0,
    CallType? type,
  });

  /// Get a specific call by ID
  Future<Either<Failure, Call>> getCall(String callId);

  /// Delete call from history
  Future<Either<Failure, void>> deleteCallFromHistory(String callId);

  /// Clear all call history
  Future<Either<Failure, void>> clearCallHistory();

  /// Restart incoming calls subscription
  /// Should be called after re-login to ensure subscription is active with new token
  Future<void> restartIncomingCallsSubscription();

  /// Stream of incoming calls
  Stream<Call> get incomingCalls;

  /// Stream of call state changes
  Stream<Call> get callStateChanges;
}
