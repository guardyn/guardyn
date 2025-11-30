import 'package:equatable/equatable.dart';

import '../../domain/entities/presence_info.dart';

/// Base class for presence states
abstract class PresenceState extends Equatable {
  const PresenceState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any presence data is loaded
class PresenceInitial extends PresenceState {
  const PresenceInitial();
}

/// Loading presence data
class PresenceLoading extends PresenceState {
  const PresenceLoading();
}

/// Presence data loaded successfully
class PresenceLoaded extends PresenceState {
  /// Map of userId to their presence info
  final Map<String, PresenceInfo> presenceMap;

  /// Currently active typing indicators (userId -> conversationId)
  final Map<String, String> typingUsers;

  /// Whether subscription to real-time updates is active
  final bool isSubscribed;

  /// Current user's status (if set)
  final PresenceStatus? myStatus;

  const PresenceLoaded({
    required this.presenceMap,
    this.typingUsers = const {},
    this.isSubscribed = false,
    this.myStatus,
  });

  /// Get presence for a specific user
  PresenceInfo? getPresence(String userId) {
    return presenceMap[userId];
  }

  /// Check if a user is online
  bool isUserOnline(String userId) {
    final presence = presenceMap[userId];
    return presence?.isOnline ?? false;
  }

  /// Check if a user is typing in a specific conversation
  bool isUserTyping(String userId, String conversationId) {
    return typingUsers[userId] == conversationId;
  }

  /// Get last seen text for a user
  String getLastSeenText(String userId) {
    final presence = presenceMap[userId];
    return presence?.lastSeenText ?? 'offline';
  }

  /// Create a copy with updated fields
  PresenceLoaded copyWith({
    Map<String, PresenceInfo>? presenceMap,
    Map<String, String>? typingUsers,
    bool? isSubscribed,
    PresenceStatus? myStatus,
  }) {
    return PresenceLoaded(
      presenceMap: presenceMap ?? this.presenceMap,
      typingUsers: typingUsers ?? this.typingUsers,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      myStatus: myStatus ?? this.myStatus,
    );
  }

  @override
  List<Object?> get props => [presenceMap, typingUsers, isSubscribed, myStatus];
}

/// Error loading presence data
class PresenceError extends PresenceState {
  final String message;

  /// Previous presence data (if any)
  final Map<String, PresenceInfo> presenceMap;

  const PresenceError({
    required this.message,
    this.presenceMap = const {},
  });

  @override
  List<Object?> get props => [message, presenceMap];
}
