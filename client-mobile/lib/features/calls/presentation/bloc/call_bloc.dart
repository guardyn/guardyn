/// Call BLoC
///
/// Manages the state of an active or incoming call.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';
import 'call_event.dart';
import 'call_state.dart' as state;

/// BLoC for managing call state
@injectable
class CallBloc extends Bloc<CallEvent, state.CallState> {
  final InitiateCall _initiateCall;
  final AcceptCall _acceptCall;
  final EndCall _endCall;
  final RejectCall _rejectCall;
  final ToggleMute _toggleMute;
  final ToggleVideo _toggleVideo;
  final ToggleSpeaker _toggleSpeaker;
  final SwitchCamera _switchCamera;

  Timer? _durationTimer;
  Call? _currentCall;

  CallBloc({
    required InitiateCall initiateCall,
    required AcceptCall acceptCall,
    required EndCall endCall,
    required RejectCall rejectCall,
    required ToggleMute toggleMute,
    required ToggleVideo toggleVideo,
    required ToggleSpeaker toggleSpeaker,
    required SwitchCamera switchCamera,
  })  : _initiateCall = initiateCall,
        _acceptCall = acceptCall,
        _endCall = endCall,
        _rejectCall = rejectCall,
        _toggleMute = toggleMute,
        _toggleVideo = toggleVideo,
        _toggleSpeaker = toggleSpeaker,
        _switchCamera = switchCamera,
        super(const state.CallInitial()) {
    on<InitiateCallEvent>(_onInitiateCall);
    on<IncomingCallEvent>(_onIncomingCall);
    on<AcceptCallEvent>(_onAcceptCall);
    on<RejectCallEvent>(_onRejectCall);
    on<EndCallEvent>(_onEndCall);
    on<ToggleMuteEvent>(_onToggleMute);
    on<ToggleVideoEvent>(_onToggleVideo);
    on<ToggleSpeakerEvent>(_onToggleSpeaker);
    on<SwitchCameraEvent>(_onSwitchCamera);
    on<CallStateChangedEvent>(_onCallStateChanged);
    on<CallConnectedEvent>(_onCallConnected);
    on<CallEndedEvent>(_onCallEnded);
    on<CallTimerTickEvent>(_onTimerTick);
  }

  /// Initiate a new outgoing call
  Future<void> _onInitiateCall(
    InitiateCallEvent event,
    Emitter<state.CallState> emit,
  ) async {
    // Create initial call object
    final call = Call(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      type: event.type,
      direction: CallDirection.outgoing,
      status: CallStatus.initiating,
      remoteUserId: event.userId,
      remoteUserName: event.userName,
      remoteUserAvatar: event.userAvatar,
      initiatedAt: DateTime.now(),
    );

    _currentCall = call;
    emit(state.CallInitiating(call));

    final result = await _initiateCall(
      InitiateCallParams(userId: event.userId, type: event.type),
    );

    result.fold(
      (failure) {
        emit(state.CallFailed(failure.message, call: call));
        _currentCall = null;
      },
      (initiatedCall) {
        _currentCall = initiatedCall;
        emit(state.CallInitiating(initiatedCall));
      },
    );
  }

  /// Handle incoming call notification
  Future<void> _onIncomingCall(
    IncomingCallEvent event,
    Emitter<state.CallState> emit,
  ) async {
    _currentCall = event.call;
    emit(state.CallRinging(event.call));
  }

  /// Accept an incoming call
  Future<void> _onAcceptCall(
    AcceptCallEvent event,
    Emitter<state.CallState> emit,
  ) async {
    if (_currentCall == null) return;

    final connecting =
        _currentCall!.copyWith(status: CallStatus.connecting);
    _currentCall = connecting;
    emit(state.CallConnecting(connecting));

    final result = await _acceptCall(event.callId);

    result.fold(
      (failure) {
        emit(state.CallFailed(failure.message, call: _currentCall));
        _currentCall = null;
      },
      (acceptedCall) {
        _currentCall = acceptedCall;
        // State will be updated via CallConnectedEvent from signaling
      },
    );
  }

  /// Reject an incoming call
  Future<void> _onRejectCall(
    RejectCallEvent event,
    Emitter<state.CallState> emit,
  ) async {
    final call = _currentCall;
    if (call == null) return;

    await _rejectCall(event.callId);

    final ended = call.copyWith(
      status: CallStatus.ended,
      endReason: CallEndReason.declined,
      endedAt: DateTime.now(),
    );
    emit(state.CallEnded(ended, CallEndReason.declined));
    _currentCall = null;
  }

  /// End the current call
  Future<void> _onEndCall(
    EndCallEvent event,
    Emitter<state.CallState> emit,
  ) async {
    _stopDurationTimer();

    final call = _currentCall;
    if (call == null) return;

    await _endCall(event.callId);

    final ended = call.copyWith(
      status: CallStatus.ended,
      endReason: CallEndReason.localHangup,
      endedAt: DateTime.now(),
      durationSeconds: call.activeDuration?.inSeconds,
    );
    emit(state.CallEnded(ended, CallEndReason.localHangup));
    _currentCall = null;
  }

  /// Toggle mute
  Future<void> _onToggleMute(
    ToggleMuteEvent event,
    Emitter<state.CallState> emit,
  ) async {
    final call = _currentCall;
    if (call == null) return;

    final newMuted = !call.isLocalMuted;
    _currentCall = call.copyWith(isLocalMuted: newMuted);

    await _toggleMute(ToggleMuteParams(callId: call.id, muted: newMuted));

    _emitCurrentState(emit);
  }

  /// Toggle video
  Future<void> _onToggleVideo(
    ToggleVideoEvent event,
    Emitter<state.CallState> emit,
  ) async {
    final call = _currentCall;
    if (call == null) return;

    final newEnabled = !call.isLocalVideoEnabled;
    _currentCall = call.copyWith(isLocalVideoEnabled: newEnabled);

    await _toggleVideo(ToggleVideoParams(callId: call.id, enabled: newEnabled));

    _emitCurrentState(emit);
  }

  /// Toggle speaker
  Future<void> _onToggleSpeaker(
    ToggleSpeakerEvent event,
    Emitter<state.CallState> emit,
  ) async {
    final call = _currentCall;
    if (call == null) return;

    final newEnabled = !call.isSpeakerOn;
    _currentCall = call.copyWith(isSpeakerOn: newEnabled);

    await _toggleSpeaker(
        ToggleSpeakerParams(callId: call.id, enabled: newEnabled));

    _emitCurrentState(emit);
  }

  /// Switch camera
  Future<void> _onSwitchCamera(
    SwitchCameraEvent event,
    Emitter<state.CallState> emit,
  ) async {
    final call = _currentCall;
    if (call == null) return;

    _currentCall = call.copyWith(isFrontCamera: !call.isFrontCamera);
    await _switchCamera(call.id);

    _emitCurrentState(emit);
  }

  /// Handle call state change from signaling
  Future<void> _onCallStateChanged(
    CallStateChangedEvent event,
    Emitter<state.CallState> emit,
  ) async {
    _currentCall = event.call;
    _emitCurrentState(emit);
  }

  /// Handle call connected
  Future<void> _onCallConnected(
    CallConnectedEvent event,
    Emitter<state.CallState> emit,
  ) async {
    if (_currentCall == null) return;

    final connected = _currentCall!.copyWith(
      status: CallStatus.connected,
      connectedAt: DateTime.now(),
    );
    _currentCall = connected;

    _startDurationTimer();
    emit(state.CallConnected(connected, Duration.zero));
  }

  /// Handle call ended from remote
  Future<void> _onCallEnded(
    CallEndedEvent event,
    Emitter<state.CallState> emit,
  ) async {
    _stopDurationTimer();

    final call = _currentCall;
    if (call == null) return;

    final ended = call.copyWith(
      status: CallStatus.ended,
      endReason: event.reason,
      endedAt: DateTime.now(),
      durationSeconds: call.activeDuration?.inSeconds,
    );
    emit(state.CallEnded(ended, event.reason));
    _currentCall = null;
  }

  /// Handle timer tick
  Future<void> _onTimerTick(
    CallTimerTickEvent event,
    Emitter<state.CallState> emit,
  ) async {
    final call = _currentCall;
    if (call == null || call.status != CallStatus.connected) return;

    final duration = call.activeDuration ?? Duration.zero;
    emit(state.CallConnected(call, duration));
  }

  /// Start duration timer
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const CallTimerTickEvent()),
    );
  }

  /// Stop duration timer
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// Emit current state based on call status
  void _emitCurrentState(Emitter<state.CallState> emit) {
    final call = _currentCall;
    if (call == null) {
      emit(const state.CallInitial());
      return;
    }

    switch (call.status) {
      case CallStatus.initiating:
        emit(state.CallInitiating(call));
      case CallStatus.ringing:
        emit(state.CallRinging(call));
      case CallStatus.connecting:
        emit(state.CallConnecting(call));
      case CallStatus.connected:
        emit(state.CallConnected(call, call.activeDuration ?? Duration.zero));
      case CallStatus.onHold:
        emit(state.CallConnected(call, call.activeDuration ?? Duration.zero));
      case CallStatus.ended:
      case CallStatus.failed:
        emit(state.CallEnded(
            call, call.endReason ?? CallEndReason.unknown));
    }
  }

  @override
  Future<void> close() {
    _stopDurationTimer();
    return super.close();
  }
}
