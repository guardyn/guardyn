/// Call BLoC Events
///
/// Events that can occur during a call.
library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/entities.dart';

/// Base class for all call events
sealed class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

/// Initiate a new call
class InitiateCallEvent extends CallEvent {
  final String userId;
  final String userName;
  final String? userAvatar;
  final CallType type;

  const InitiateCallEvent({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.type,
  });

  @override
  List<Object?> get props => [userId, userName, userAvatar, type];
}

/// Incoming call received
class IncomingCallEvent extends CallEvent {
  final Call call;

  const IncomingCallEvent(this.call);

  @override
  List<Object?> get props => [call];
}

/// Accept an incoming call
class AcceptCallEvent extends CallEvent {
  final String callId;

  const AcceptCallEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// Reject an incoming call
class RejectCallEvent extends CallEvent {
  final String callId;

  const RejectCallEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// End the current call
class EndCallEvent extends CallEvent {
  final String callId;

  const EndCallEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// Toggle mute state
class ToggleMuteEvent extends CallEvent {
  const ToggleMuteEvent();
}

/// Toggle video state
class ToggleVideoEvent extends CallEvent {
  const ToggleVideoEvent();
}

/// Toggle speaker state
class ToggleSpeakerEvent extends CallEvent {
  const ToggleSpeakerEvent();
}

/// Switch camera (front/back)
class SwitchCameraEvent extends CallEvent {
  const SwitchCameraEvent();
}

/// Call state changed (from signaling)
class CallStateChangedEvent extends CallEvent {
  final Call call;

  const CallStateChangedEvent(this.call);

  @override
  List<Object?> get props => [call];
}

/// Call connected successfully
class CallConnectedEvent extends CallEvent {
  final String callId;

  const CallConnectedEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// Call ended
class CallEndedEvent extends CallEvent {
  final String callId;
  final CallEndReason reason;

  const CallEndedEvent(this.callId, this.reason);

  @override
  List<Object?> get props => [callId, reason];
}

/// Timer tick (every second)
class CallTimerTickEvent extends CallEvent {
  const CallTimerTickEvent();
}
