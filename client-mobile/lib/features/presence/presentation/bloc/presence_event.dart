import 'package:equatable/equatable.dart';

import '../../domain/entities/presence_info.dart';

/// Base class for presence events
abstract class PresenceEvent extends Equatable {
  const PresenceEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch presence for a single user
class PresenceFetchUser extends PresenceEvent {
  final String userId;

  const PresenceFetchUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Fetch presence for multiple users (e.g., conversation list)
class PresenceFetchBulk extends PresenceEvent {
  final List<String> userIds;

  const PresenceFetchBulk(this.userIds);

  @override
  List<Object?> get props => [userIds];
}

/// Update current user's status
class PresenceUpdateMyStatus extends PresenceEvent {
  final PresenceStatus status;

  const PresenceUpdateMyStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// User presence changed (from server push or subscription)
class PresenceUserChanged extends PresenceEvent {
  final PresenceInfo presenceInfo;

  const PresenceUserChanged(this.presenceInfo);

  @override
  List<Object?> get props => [presenceInfo];
}

/// Send typing indicator for current user
class PresenceSendTyping extends PresenceEvent {
  final String conversationId;
  final bool isTyping;

  const PresenceSendTyping({
    required this.conversationId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [conversationId, isTyping];
}

/// User started/stopped typing (received from server)
class PresenceTypingChanged extends PresenceEvent {
  final String userId;
  final String conversationId;
  final bool isTyping;

  const PresenceTypingChanged({
    required this.userId,
    required this.conversationId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [userId, conversationId, isTyping];
}

/// Start heartbeat timer
class PresenceStartHeartbeat extends PresenceEvent {
  const PresenceStartHeartbeat();
}

/// Stop heartbeat timer
class PresenceStopHeartbeat extends PresenceEvent {
  const PresenceStopHeartbeat();
}

/// Subscribe to real-time updates for specified users
class PresenceSubscribe extends PresenceEvent {
  final List<String> userIds;

  const PresenceSubscribe(this.userIds);

  @override
  List<Object?> get props => [userIds];
}

/// Unsubscribe from real-time updates
class PresenceUnsubscribe extends PresenceEvent {
  const PresenceUnsubscribe();
}

/// Clear presence cache
class PresenceClearCache extends PresenceEvent {
  const PresenceClearCache();
}

/// Set current user as online
class PresenceSetOnline extends PresenceEvent {
  const PresenceSetOnline();
}

/// Set current user as offline
class PresenceSetOffline extends PresenceEvent {
  const PresenceSetOffline();
}
