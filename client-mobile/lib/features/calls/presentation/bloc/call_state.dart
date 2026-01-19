/// Call BLoC State
///
/// States representing the current state of a call.
library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/entities.dart';

/// Base class for all call states
sealed class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no active call
class CallInitial extends CallState {
  const CallInitial();
}

/// Incoming call is ringing
class CallRinging extends CallState {
  final Call call;

  const CallRinging(this.call);

  @override
  List<Object?> get props => [call];
}

/// Call is being initiated (outgoing)
class CallInitiating extends CallState {
  final Call call;

  const CallInitiating(this.call);

  @override
  List<Object?> get props => [call];
}

/// Call is connecting (after answer)
class CallConnecting extends CallState {
  final Call call;

  const CallConnecting(this.call);

  @override
  List<Object?> get props => [call];
}

/// Call is active and connected
class CallConnected extends CallState {
  final Call call;
  final Duration duration;

  const CallConnected(this.call, this.duration);

  @override
  List<Object?> get props => [call, duration];
}

/// Call has ended
class CallEnded extends CallState {
  final Call call;
  final CallEndReason reason;

  const CallEnded(this.call, this.reason);

  @override
  List<Object?> get props => [call, reason];
}

/// Call failed to connect
class CallFailed extends CallState {
  final String message;
  final Call? call;

  const CallFailed(this.message, {this.call});

  @override
  List<Object?> get props => [message, call];
}
