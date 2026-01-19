/// Call State Enums
///
/// Defines the various states a call can be in and reasons for ending.
library;

/// Current status of a call
enum CallStatus {
  /// Call has been initiated but not yet ringing
  initiating,

  /// Call is ringing on the remote device
  ringing,

  /// Call is being connected (after answer)
  connecting,

  /// Call is active and connected
  connected,

  /// Call is on hold
  onHold,

  /// Call has ended
  ended,

  /// Call failed to connect
  failed,
}

/// Reason why a call ended
enum CallEndReason {
  /// Normal hangup by local user
  localHangup,

  /// Normal hangup by remote user
  remoteHangup,

  /// Call was declined/rejected
  declined,

  /// Call was not answered (timeout)
  noAnswer,

  /// Call was busy
  busy,

  /// Network error
  networkError,

  /// Media error (camera/microphone)
  mediaError,

  /// Call was canceled before connecting
  canceled,

  /// Unknown reason
  unknown,
}

/// Extension methods for CallStatus
extension CallStatusX on CallStatus {
  /// Whether this status indicates an active call
  bool get isActive =>
      this == CallStatus.connecting ||
      this == CallStatus.ringing ||
      this == CallStatus.connected;

  /// Whether this status indicates call has ended
  bool get isEnded => this == CallStatus.ended || this == CallStatus.failed;

  /// Human-readable label
  String get label {
    switch (this) {
      case CallStatus.initiating:
        return 'Initiating...';
      case CallStatus.ringing:
        return 'Ringing...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return 'Connected';
      case CallStatus.onHold:
        return 'On Hold';
      case CallStatus.ended:
        return 'Call Ended';
      case CallStatus.failed:
        return 'Call Failed';
    }
  }
}

/// Extension methods for CallEndReason
extension CallEndReasonX on CallEndReason {
  /// Human-readable message
  String get message {
    switch (this) {
      case CallEndReason.localHangup:
        return 'You ended the call';
      case CallEndReason.remoteHangup:
        return 'Call ended';
      case CallEndReason.declined:
        return 'Call declined';
      case CallEndReason.noAnswer:
        return 'No answer';
      case CallEndReason.busy:
        return 'Line busy';
      case CallEndReason.networkError:
        return 'Network error';
      case CallEndReason.mediaError:
        return 'Media error';
      case CallEndReason.canceled:
        return 'Call canceled';
      case CallEndReason.unknown:
        return 'Call ended';
    }
  }

  /// Whether this is an error reason
  bool get isError =>
      this == CallEndReason.networkError || this == CallEndReason.mediaError;
}
