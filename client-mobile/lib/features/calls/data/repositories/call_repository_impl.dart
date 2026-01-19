/// Call Repository Implementation
///
/// Implements CallRepository interface with WebRTC and Signaling data sources.
/// Orchestrates the complete call flow from initiation to termination.
library;

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/datasources.dart';

/// Call Repository Implementation
class CallRepositoryImpl implements CallRepository {
  final WebRTCDataSource _webrtcDataSource;
  final SignalingDataSource _signalingDataSource;
  final Logger _logger;
  final Uuid _uuid;

  /// Current user ID
  final String _currentUserId;

  /// Active call state
  Call? _activeCall;

  /// Call history (in-memory for now, could be persisted)
  final List<Call> _callHistory = [];

  /// Stream controllers for reactive updates
  final _incomingCallsController = StreamController<Call>.broadcast();
  final _callStateChangesController = StreamController<Call>.broadcast();

  /// Subscriptions to data source events
  StreamSubscription? _webrtcSubscription;
  StreamSubscription? _signalingSubscription;

  /// Timer for call duration tracking
  Timer? _durationTimer;

  CallRepositoryImpl({
    required WebRTCDataSource webrtcDataSource,
    required SignalingDataSource signalingDataSource,
    required Logger logger,
    required String currentUserId,
    Uuid? uuid,
  })  : _webrtcDataSource = webrtcDataSource,
        _signalingDataSource = signalingDataSource,
        _logger = logger,
        _currentUserId = currentUserId,
        _uuid = uuid ?? const Uuid() {
    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    // Subscribe to WebRTC events
    _webrtcSubscription = _webrtcDataSource.events.listen(_handleWebRTCEvent);

    // Subscribe to signaling events
    _signalingSubscription =
        _signalingDataSource.events.listen(_handleSignalingEvent);
  }

  void _handleWebRTCEvent(WebRTCEvent event) {
    switch (event) {
      case WebRTCConnectionStateChanged(state: final state):
        _handleConnectionStateChange(state);
      case WebRTCIceCandidateGenerated(candidate: final candidate):
        _sendIceCandidate(candidate);
      case WebRTCRemoteStreamAdded():
        // Update call state to reflect media connection
        if (_activeCall != null) {
          _updateCallStatus(CallStatus.connected);
        }
      case WebRTCError(message: final message, error: final error):
        _logger.e('WebRTC error: $message', error: error);
        _handleCallError(message);
      default:
        break;
    }
  }

  void _handleSignalingEvent(SignalingEvent event) {
    switch (event) {
      case SignalingMessageReceived(message: final message):
        _handleSignalingMessage(message);
      case SignalingStateChanged(state: final state):
        _logger.i('Signaling state: $state');
      case SignalingError(message: final message, error: final error):
        _logger.e('Signaling error: $message', error: error);
      default:
        break;
    }
  }

  void _handleSignalingMessage(SignalingMessage message) {
    switch (message) {
      case CallMessage():
        _handleIncomingCall(message);
      case SdpMessage():
        _handleSdp(message);
      case CandidateMessage():
        _handleRemoteCandidate(message);
      case CallControlMessage():
        _handleCallControl(message);
    }
  }

  void _handleIncomingCall(CallMessage message) {
    _logger.i('Incoming call from ${message.fromUserId}');

    final call = Call(
      id: message.callId,
      type: message.isVideo ? CallType.video : CallType.voice,
      direction: CallDirection.incoming,
      status: CallStatus.ringing,
      remoteUserId: message.fromUserId,
      remoteUserName: message.callerName,
      remoteUserAvatar: message.callerAvatar,
      initiatedAt: message.timestamp,
    );

    _activeCall = call;
    _incomingCallsController.add(call);
    _callStateChangesController.add(call);

    // Send ringing notification
    _signalingDataSource.sendRinging(CallControlMessage(
      type: SignalType.ringing,
      callId: message.callId,
      fromUserId: _currentUserId,
      toUserId: message.fromUserId,
    ));
  }

  Future<void> _handleSdp(SdpMessage message) async {
    _logger.i('Received ${message.type.name} from ${message.fromUserId}');

    try {
      await _webrtcDataSource.setRemoteDescription(message.sdp);

      if (message.type == SignalType.offer) {
        // Create and send answer
        final answer = await _webrtcDataSource.createAnswer();
        await _webrtcDataSource.setLocalDescription(answer);

        await _signalingDataSource.sendSdp(SdpMessage(
          type: SignalType.answer,
          callId: message.callId,
          fromUserId: _currentUserId,
          toUserId: message.fromUserId,
          sdp: answer,
        ));
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to handle SDP', error: e, stackTrace: stackTrace);
      _handleCallError('Failed to establish connection');
    }
  }

  Future<void> _handleRemoteCandidate(CandidateMessage message) async {
    try {
      await _webrtcDataSource.addIceCandidate(message.candidate);
    } catch (e, stackTrace) {
      _logger.e('Failed to add ICE candidate', error: e, stackTrace: stackTrace);
    }
  }

  void _handleCallControl(CallControlMessage message) {
    switch (message.type) {
      case SignalType.ringing:
        _updateCallStatus(CallStatus.ringing);
      case SignalType.accept:
        _handleRemoteAccept(message);
      case SignalType.reject:
        _handleRemoteReject(message);
      case SignalType.hangup:
        _handleRemoteHangup(message);
      default:
        break;
    }
  }

  Future<void> _handleRemoteAccept(CallControlMessage message) async {
    _logger.i('Call accepted by ${message.fromUserId}');
    _updateCallStatus(CallStatus.connecting);
  }

  void _handleRemoteReject(CallControlMessage message) {
    _logger.i('Call rejected by ${message.fromUserId}');
    _endCall(CallEndReason.declined);
  }

  void _handleRemoteHangup(CallControlMessage message) {
    _logger.i('Call ended by ${message.fromUserId}');
    _endCall(CallEndReason.remoteHangup);
  }

  void _handleConnectionStateChange(PeerConnectionState state) {
    switch (state) {
      case PeerConnectionState.connected:
        _updateCallStatus(CallStatus.connected);
        _startDurationTimer();
      case PeerConnectionState.disconnected:
        _updateCallStatus(CallStatus.onHold);
      case PeerConnectionState.failed:
        _handleCallError('Connection failed');
      case PeerConnectionState.closed:
        if (_activeCall != null &&
            _activeCall!.status != CallStatus.ended) {
          _endCall(CallEndReason.networkError);
        }
      default:
        break;
    }
  }

  Future<void> _sendIceCandidate(IceCandidate candidate) async {
    if (_activeCall == null) return;

    try {
      await _signalingDataSource.sendCandidate(CandidateMessage(
        callId: _activeCall!.id,
        fromUserId: _currentUserId,
        toUserId: _activeCall!.remoteUserId!,
        candidate: candidate,
      ));
    } catch (e, stackTrace) {
      _logger.e('Failed to send ICE candidate', error: e, stackTrace: stackTrace);
    }
  }

  void _updateCallStatus(CallStatus status) {
    if (_activeCall == null) return;

    final updatedCall = _activeCall!.copyWith(
      status: status,
      connectedAt:
          status == CallStatus.connected ? DateTime.now() : _activeCall!.connectedAt,
    );

    _activeCall = updatedCall;
    _callStateChangesController.add(updatedCall);
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeCall != null) {
        _callStateChangesController.add(_activeCall!);
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _endCall(CallEndReason reason) {
    if (_activeCall == null) return;

    _stopDurationTimer();

    final endedCall = _activeCall!.copyWith(
      status: CallStatus.ended,
      endedAt: DateTime.now(),
      endReason: reason,
      durationSeconds: _activeCall!.activeDuration?.inSeconds,
    );

    // Add to history
    _callHistory.insert(0, endedCall);

    _activeCall = null;
    _callStateChangesController.add(endedCall);

    // Clean up WebRTC
    _webrtcDataSource.close();
  }

  void _handleCallError(String message) {
    _logger.e('Call error: $message');
    _endCall(CallEndReason.networkError);
  }

  // Repository interface implementation

  @override
  Future<Either<Failure, Call>> initiateCall({
    required String userId,
    required CallType type,
  }) async {
    _logger.i('Initiating ${type.name} call to $userId');

    try {
      // Generate call ID
      final callId = _uuid.v4();

      // Create call entity
      final call = Call(
        id: callId,
        type: type,
        direction: CallDirection.outgoing,
        status: CallStatus.initiating,
        remoteUserId: userId,
        initiatedAt: DateTime.now(),
        isLocalVideoEnabled: type == CallType.video,
      );

      _activeCall = call;
      _callStateChangesController.add(call);

      // Initialize WebRTC
      await _webrtcDataSource.initialize(const WebRTCConfig());

      // Start local media
      await _webrtcDataSource.startLocalMedia(
        enableVideo: type == CallType.video,
        enableAudio: true,
      );

      // Create and set local description
      final offer = await _webrtcDataSource.createOffer();
      await _webrtcDataSource.setLocalDescription(offer);

      // Send call initiation
      await _signalingDataSource.sendCall(CallMessage(
        callId: callId,
        fromUserId: _currentUserId,
        toUserId: userId,
        isVideo: type == CallType.video,
      ));

      // Send SDP offer
      await _signalingDataSource.sendSdp(SdpMessage(
        type: SignalType.offer,
        callId: callId,
        fromUserId: _currentUserId,
        toUserId: userId,
        sdp: offer,
      ));

      _updateCallStatus(CallStatus.ringing);

      return Right(_activeCall!);
    } catch (e, stackTrace) {
      _logger.e('Failed to initiate call', error: e, stackTrace: stackTrace);
      _activeCall = null;
      return Left(ServerFailure('Failed to initiate call: $e'));
    }
  }

  @override
  Future<Either<Failure, Call>> acceptCall(String callId) async {
    _logger.i('Accepting call $callId');

    if (_activeCall == null || _activeCall!.id != callId) {
      return const Left(ServerFailure('No active call to accept'));
    }

    try {
      // Send accept
      await _signalingDataSource.sendAccept(CallControlMessage(
        type: SignalType.accept,
        callId: callId,
        fromUserId: _currentUserId,
        toUserId: _activeCall!.remoteUserId!,
      ));

      // Initialize WebRTC
      await _webrtcDataSource.initialize(const WebRTCConfig());

      // Start local media
      await _webrtcDataSource.startLocalMedia(
        enableVideo: _activeCall!.isVideoCall,
        enableAudio: true,
      );

      _updateCallStatus(CallStatus.connecting);

      return Right(_activeCall!);
    } catch (e, stackTrace) {
      _logger.e('Failed to accept call', error: e, stackTrace: stackTrace);
      return Left(ServerFailure('Failed to accept call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectCall(String callId) async {
    _logger.i('Rejecting call $callId');

    if (_activeCall == null || _activeCall!.id != callId) {
      return const Left(ServerFailure('No active call to reject'));
    }

    try {
      await _signalingDataSource.sendReject(CallControlMessage(
        type: SignalType.reject,
        callId: callId,
        fromUserId: _currentUserId,
        toUserId: _activeCall!.remoteUserId!,
      ));

      _endCall(CallEndReason.declined);

      return const Right(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to reject call', error: e, stackTrace: stackTrace);
      return Left(ServerFailure('Failed to reject call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endCall(String callId) async {
    _logger.i('Ending call $callId');

    if (_activeCall == null || _activeCall!.id != callId) {
      return const Left(ServerFailure('No active call to end'));
    }

    try {
      await _signalingDataSource.sendHangup(CallControlMessage(
        type: SignalType.hangup,
        callId: callId,
        fromUserId: _currentUserId,
        toUserId: _activeCall!.remoteUserId!,
      ));

      _endCall(CallEndReason.localHangup);

      return const Right(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to end call', error: e, stackTrace: stackTrace);
      return Left(ServerFailure('Failed to end call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setMuted(String callId, bool muted) async {
    try {
      await _webrtcDataSource.setAudioEnabled(!muted);

      if (_activeCall != null) {
        _activeCall = _activeCall!.copyWith(isLocalMuted: muted);
        _callStateChangesController.add(_activeCall!);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set mute: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setVideoEnabled(
      String callId, bool enabled) async {
    try {
      await _webrtcDataSource.setVideoEnabled(enabled);

      if (_activeCall != null) {
        _activeCall = _activeCall!.copyWith(isLocalVideoEnabled: enabled);
        _callStateChangesController.add(_activeCall!);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set video: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setSpeakerEnabled(
      String callId, bool enabled) async {
    try {
      await _webrtcDataSource.setSpeakerEnabled(enabled);

      if (_activeCall != null) {
        _activeCall = _activeCall!.copyWith(isSpeakerOn: enabled);
        _callStateChangesController.add(_activeCall!);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set speaker: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> switchCamera(String callId) async {
    try {
      await _webrtcDataSource.switchCamera();

      if (_activeCall != null) {
        _activeCall =
            _activeCall!.copyWith(isFrontCamera: !_activeCall!.isFrontCamera);
        _callStateChangesController.add(_activeCall!);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to switch camera: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Call>>> getCallHistory({
    int limit = 50,
    int offset = 0,
    CallType? type,
  }) async {
    var history = _callHistory;

    if (type != null) {
      history = history.where((c) => c.type == type).toList();
    }

    final paged = history.skip(offset).take(limit).toList();
    return Right(paged);
  }

  @override
  Future<Either<Failure, Call>> getCall(String callId) async {
    final call = _callHistory.firstWhere(
      (c) => c.id == callId,
      orElse: () => _activeCall?.id == callId
          ? _activeCall!
          : throw StateError('Call not found'),
    );
    return Right(call);
  }

  @override
  Future<Either<Failure, void>> deleteCallFromHistory(String callId) async {
    _callHistory.removeWhere((c) => c.id == callId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearCallHistory() async {
    _callHistory.clear();
    return const Right(null);
  }

  @override
  Stream<Call> get incomingCalls => _incomingCallsController.stream;

  @override
  Stream<Call> get callStateChanges => _callStateChangesController.stream;

  /// Dispose all resources
  Future<void> dispose() async {
    _stopDurationTimer();
    await _webrtcSubscription?.cancel();
    await _signalingSubscription?.cancel();
    await _incomingCallsController.close();
    await _callStateChangesController.close();
    await _webrtcDataSource.dispose();
    await _signalingDataSource.dispose();
  }
}
