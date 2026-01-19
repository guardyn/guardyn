/// Call Participant Entity
///
/// Represents a participant in a voice or video call.
/// Tracks their media state and connection quality.
library;

import 'package:equatable/equatable.dart';

/// Connection state of a participant
enum ParticipantConnectionState {
  connecting,
  connected,
  reconnecting,
  disconnected,
}

/// A participant in a call
class CallParticipant extends Equatable {
  /// Unique user ID
  final String id;

  /// Display name
  final String displayName;

  /// Avatar URL
  final String? avatarUrl;

  /// Whether audio is muted
  final bool isMuted;

  /// Whether video is enabled
  final bool isVideoEnabled;

  /// Whether they are speaking (voice activity detection)
  final bool isSpeaking;

  /// Whether screen sharing is active
  final bool isScreenSharing;

  /// Whether this is the local user
  final bool isLocal;

  /// Connection state
  final ParticipantConnectionState connectionState;

  /// Connection quality score (0-100)
  final int? qualityScore;

  /// When they joined the call
  final DateTime joinedAt;

  const CallParticipant({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isSpeaking = false,
    this.isScreenSharing = false,
    this.isLocal = false,
    this.connectionState = ParticipantConnectionState.connecting,
    this.qualityScore,
    required this.joinedAt,
  });

  /// Create a copy with updated fields
  CallParticipant copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isSpeaking,
    bool? isScreenSharing,
    bool? isLocal,
    ParticipantConnectionState? connectionState,
    int? qualityScore,
    DateTime? joinedAt,
  }) {
    return CallParticipant(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isLocal: isLocal ?? this.isLocal,
      connectionState: connectionState ?? this.connectionState,
      qualityScore: qualityScore ?? this.qualityScore,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  /// Get initials from display name
  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Whether participant is fully connected
  bool get isConnected =>
      connectionState == ParticipantConnectionState.connected;

  @override
  List<Object?> get props => [
        id,
        displayName,
        avatarUrl,
        isMuted,
        isVideoEnabled,
        isSpeaking,
        isScreenSharing,
        isLocal,
        connectionState,
        qualityScore,
        joinedAt,
      ];

  @override
  String toString() =>
      'CallParticipant(id: $id, name: $displayName, muted: $isMuted)';
}
