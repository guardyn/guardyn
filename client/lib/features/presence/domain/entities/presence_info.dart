import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User presence status enumeration
enum PresenceStatus {
  online,
  offline,
  away,
  doNotDisturb,
  invisible,
}

/// Core business entity representing a user's presence information
class PresenceInfo extends Equatable {
  final String userId;
  final PresenceStatus status;
  final DateTime? lastSeen;
  final bool isTyping;
  final String? typingInConversationId;
  final String? customStatusText;

  const PresenceInfo({
    required this.userId,
    required this.status,
    this.lastSeen,
    this.isTyping = false,
    this.typingInConversationId,
    this.customStatusText,
  });

  /// Check if user is online
  bool get isOnline => status == PresenceStatus.online;

  /// Check if user is available (online or away)
  bool get isAvailable =>
      status == PresenceStatus.online || status == PresenceStatus.away;

  /// Human-readable last seen text
  String get lastSeenText {
    if (status == PresenceStatus.online) return 'online';
    if (lastSeen == null) return 'offline';

    final now = DateTime.now();
    final diff = now.difference(lastSeen!);

    if (diff.inSeconds < 60) return 'last seen just now';
    if (diff.inMinutes < 60) {
      return 'last seen ${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      return 'last seen ${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      return 'last seen ${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    }
    return 'last seen ${lastSeen!.day}/${lastSeen!.month}/${lastSeen!.year}';
  }

  /// Status display text
  String get statusText {
    switch (status) {
      case PresenceStatus.online:
        return 'Online';
      case PresenceStatus.away:
        return 'Away';
      case PresenceStatus.doNotDisturb:
        return 'Do Not Disturb';
      case PresenceStatus.invisible:
        return 'Invisible';
      case PresenceStatus.offline:
        return lastSeenText;
    }
  }

  /// Status color for UI
  Color get statusColor {
    switch (status) {
      case PresenceStatus.online:
        return Colors.green;
      case PresenceStatus.away:
        return Colors.orange;
      case PresenceStatus.doNotDisturb:
        return Colors.red;
      case PresenceStatus.invisible:
        return Colors.grey;
      case PresenceStatus.offline:
        return Colors.grey;
    }
  }

  /// Create a copy with updated fields
  PresenceInfo copyWith({
    String? userId,
    PresenceStatus? status,
    DateTime? lastSeen,
    bool? isTyping,
    String? typingInConversationId,
    String? customStatusText,
  }) {
    return PresenceInfo(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      isTyping: isTyping ?? this.isTyping,
      typingInConversationId:
          typingInConversationId ?? this.typingInConversationId,
      customStatusText: customStatusText ?? this.customStatusText,
    );
  }

  /// Create an offline presence for a user
  factory PresenceInfo.offline(String userId) {
    return PresenceInfo(
      userId: userId,
      status: PresenceStatus.offline,
    );
  }

  /// Create an online presence for a user
  factory PresenceInfo.online(String userId) {
    return PresenceInfo(
      userId: userId,
      status: PresenceStatus.online,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        status,
        lastSeen,
        isTyping,
        typingInConversationId,
        customStatusText,
      ];
}
