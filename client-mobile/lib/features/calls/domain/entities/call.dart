/// Call Entity
///
/// Represents a voice or video call in the Guardyn system.
/// Contains all metadata about a call including participants,
/// timing, and current status.
library;

import 'package:equatable/equatable.dart';

import 'call_state.dart';
import 'participant.dart';

/// Type of call (voice or video)
enum CallType {
  voice,
  video,
}

/// Direction of the call
enum CallDirection {
  incoming,
  outgoing,
}

/// Main Call entity
class Call extends Equatable {
  /// Unique identifier for the call
  final String id;

  /// Type of call (voice/video)
  final CallType type;

  /// Direction (incoming/outgoing)
  final CallDirection direction;

  /// Current status of the call
  final CallStatus status;

  /// List of participants in the call
  final List<CallParticipant> participants;

  /// Remote user ID (for 1:1 calls)
  final String? remoteUserId;

  /// Remote user display name
  final String? remoteUserName;

  /// Remote user avatar URL
  final String? remoteUserAvatar;

  /// When the call was initiated
  final DateTime initiatedAt;

  /// When the call was connected (answered)
  final DateTime? connectedAt;

  /// When the call ended
  final DateTime? endedAt;

  /// Duration in seconds (calculated when call ends)
  final int? durationSeconds;

  /// Whether local audio is muted
  final bool isLocalMuted;

  /// Whether local video is enabled
  final bool isLocalVideoEnabled;

  /// Whether speaker is on
  final bool isSpeakerOn;

  /// Whether using front camera
  final bool isFrontCamera;

  /// Call quality indicator (0-100)
  final int? qualityScore;

  /// End reason if call ended
  final CallEndReason? endReason;

  const Call({
    required this.id,
    required this.type,
    required this.direction,
    required this.status,
    this.participants = const [],
    this.remoteUserId,
    this.remoteUserName,
    this.remoteUserAvatar,
    required this.initiatedAt,
    this.connectedAt,
    this.endedAt,
    this.durationSeconds,
    this.isLocalMuted = false,
    this.isLocalVideoEnabled = true,
    this.isSpeakerOn = false,
    this.isFrontCamera = true,
    this.qualityScore,
    this.endReason,
  });

  /// Whether call is currently active (connecting or connected)
  bool get isActive =>
      status == CallStatus.connecting ||
      status == CallStatus.ringing ||
      status == CallStatus.connected;

  /// Whether this is a video call
  bool get isVideoCall => type == CallType.video;

  /// Whether this is a group call
  bool get isGroupCall => participants.length > 2;

  /// Get the active duration of the call
  Duration? get activeDuration {
    if (durationSeconds != null) {
      return Duration(seconds: durationSeconds!);
    }
    if (connectedAt != null) {
      final end = endedAt ?? DateTime.now();
      return end.difference(connectedAt!);
    }
    return null;
  }

  /// Format duration as MM:SS
  String get formattedDuration {
    final duration = activeDuration;
    if (duration == null) return '00:00';

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  /// Create a copy with updated fields
  Call copyWith({
    String? id,
    CallType? type,
    CallDirection? direction,
    CallStatus? status,
    List<CallParticipant>? participants,
    String? remoteUserId,
    String? remoteUserName,
    String? remoteUserAvatar,
    DateTime? initiatedAt,
    DateTime? connectedAt,
    DateTime? endedAt,
    int? durationSeconds,
    bool? isLocalMuted,
    bool? isLocalVideoEnabled,
    bool? isSpeakerOn,
    bool? isFrontCamera,
    int? qualityScore,
    CallEndReason? endReason,
  }) {
    return Call(
      id: id ?? this.id,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      remoteUserName: remoteUserName ?? this.remoteUserName,
      remoteUserAvatar: remoteUserAvatar ?? this.remoteUserAvatar,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      connectedAt: connectedAt ?? this.connectedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isLocalMuted: isLocalMuted ?? this.isLocalMuted,
      isLocalVideoEnabled: isLocalVideoEnabled ?? this.isLocalVideoEnabled,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      qualityScore: qualityScore ?? this.qualityScore,
      endReason: endReason ?? this.endReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        direction,
        status,
        participants,
        remoteUserId,
        remoteUserName,
        remoteUserAvatar,
        initiatedAt,
        connectedAt,
        endedAt,
        durationSeconds,
        isLocalMuted,
        isLocalVideoEnabled,
        isSpeakerOn,
        isFrontCamera,
        qualityScore,
        endReason,
      ];

  @override
  String toString() =>
      'Call(id: $id, type: $type, status: $status, remote: $remoteUserName)';
}
