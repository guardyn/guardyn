/// Call Repository Implementation
///
/// Implements CallRepository interface with WebRTC and gRPC data sources.
/// Orchestrates the complete call flow from initiation to termination.
library;

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/user_provider.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/datasources.dart';
import '../services/call_audio_service.dart';

/// Call Repository Implementation
class CallRepositoryImpl implements CallRepository {
  final WebRTCDataSource _webrtcDataSource;
  final SignalingDataSource _signalingDataSource;
  final CallRemoteDatasource _callRemoteDatasource;
  final CallAudioService _callAudioService;
  final TokenManager _tokenManager;
  final Logger _logger;

  /// User provider for getting current user ID
  final UserProvider _userProvider;

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
  StreamSubscription<IncomingCallData>? _incomingCallsSubscription;

  /// Timer for call duration tracking
  Timer? _durationTimer;

  CallRepositoryImpl({
    required WebRTCDataSource webrtcDataSource,
    required SignalingDataSource signalingDataSource,
    required CallRemoteDatasource callRemoteDatasource,
    required CallAudioService callAudioService,
    required TokenManager tokenManager,
    required Logger logger,
    required UserProvider userProvider,
  })  : _webrtcDataSource = webrtcDataSource,
        _signalingDataSource = signalingDataSource,
       _callRemoteDatasource = callRemoteDatasource,
       _callAudioService = callAudioService,
       _tokenManager = tokenManager,
        _logger = logger,
       _userProvider = userProvider {
    _logger.i('🔔 CallRepositoryImpl: Constructor called, setting up subscriptions...');
    _setupSubscriptions();
  }

  /// Gets the current user ID from the user provider
  String get _currentUserId => _userProvider.currentUserIdSync;

  void _setupSubscriptions() {
    // Subscribe to WebRTC events
    _webrtcSubscription = _webrtcDataSource.events.listen(_handleWebRTCEvent);

    // Subscribe to signaling events
    _signalingSubscription =
        _signalingDataSource.events.listen(_handleSignalingEvent);

    // Subscribe to incoming calls via gRPC
    _startIncomingCallsSubscription();
  }

  /// Starts subscription to incoming calls from the backend
  Future<void> _startIncomingCallsSubscription() async {
    // Cancel existing subscription before creating a new one
    await _incomingCallsSubscription?.cancel();
    _incomingCallsSubscription = null;

    _logger.i('🔔 CallRepository: Starting incoming calls subscription...');

    try {
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken == null) {
        _logger.w('🔔 CallRepository: No access token, skipping incoming calls subscription');
        return;
      }

      _logger.i('🔔 CallRepository: Got access token, subscribing to gRPC stream...');

      _incomingCallsSubscription = _callRemoteDatasource
          .subscribeToIncomingCalls(accessToken: accessToken)
          .listen(
            _handleIncomingCallNotification,
            onError: (error) {
              _logger.e('🔔 CallRepository: Incoming calls subscription error: $error');
              // Retry subscription after delay
              Future.delayed(const Duration(seconds: 5), () {
                _startIncomingCallsSubscription();
              });
            },
            onDone: () {
              _logger.i('🔔 CallRepository: Incoming calls subscription closed, reconnecting...');
              // Reconnect subscription
              Future.delayed(const Duration(seconds: 1), () {
                _startIncomingCallsSubscription();
              });
            },
          );

      _logger.i('🔔 CallRepository: Incoming calls subscription started successfully');
    } catch (e, stackTrace) {
      _logger.e(
        '🔔 CallRepository: Failed to start incoming calls subscription',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handles incoming call notification from gRPC stream
  void _handleIncomingCallNotification(IncomingCallData data) {
    _logger.i(
      '🔔 CallRepository: RECEIVED incoming call notification: '
      'call_id=${data.callId}, caller_id=${data.callerId}, '
      'caller_name=${data.callerDisplayName}',
    );

    final call = Call(
      id: data.callId,
      type: data.isVideo ? CallType.video : CallType.voice,
      direction: CallDirection.incoming,
      status: CallStatus.ringing,
      remoteUserId: data.callerId,
      remoteUserName: data.callerDisplayName,
      remoteUserAvatar: data.callerAvatarUrl,
      initiatedAt: data.createdAt,
    );

    _activeCall = call;
    _logger.i('🔔 CallRepository: Adding call to incomingCallsController...');
    _incomingCallsController.add(call);
    _callStateChangesController.add(call);

    // Start listening for call events IMMEDIATELY
    // This is crucial to detect if the caller cancels the call before we accept/reject
    _startPendingCallEventStream(data.callId);

    // Play incoming ringtone
    _callAudioService.playIncomingRingtone();
    _logger.i('🔔 CallRepository: Incoming call processing complete, ringtone playing');
  }

  /// Subscription for pending call events (incoming calls before accept/reject)
  StreamSubscription<CallEventData>? _pendingCallEventsSubscription;

  /// Start listening for events on a pending incoming call
  /// This detects if the caller cancels before we accept/reject
  Future<void> _startPendingCallEventStream(String callId) async {
    await _pendingCallEventsSubscription?.cancel();
    _pendingCallEventsSubscription = null;

    _logger.i('🔔 CallRepository: Starting pending call events stream for $callId');

    try {
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken == null) {
        _logger.w('🔔 CallRepository: No access token for pending call events');
        return;
      }

      _pendingCallEventsSubscription = _callRemoteDatasource
          .streamCallEvents(accessToken: accessToken, callId: callId)
          .listen(
            (event) => _handlePendingCallEvent(event),
            onError: (error) {
              _logger.e('🔔 CallRepository: Pending call events error: $error');
            },
            onDone: () {
              _logger.i('🔔 CallRepository: Pending call events stream closed');
            },
          );
    } catch (e, stackTrace) {
      _logger.e(
        '🔔 CallRepository: Failed to start pending call events stream',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle events for pending incoming calls (before accept/reject)
  void _handlePendingCallEvent(CallEventData event) {
    if (event is CallStateChangedEvent) {
      _logger.i('🔔 CallRepository: Pending call state changed to ${event.newState}');
      
      if (event.newState == CallStateType.ended ||
          event.newState == CallStateType.failed) {
        // Caller cancelled the call before we answered
        _logger.i('🔔 CallRepository: Caller cancelled - ending pending call');
        
        // Stop ringtone
        _callAudioService.stopIncomingRingtone();
        
        // End the call with appropriate reason
        _endCall(_mapEndReason(event.endReason));
        
        // Cancel the pending subscription
        _pendingCallEventsSubscription?.cancel();
        _pendingCallEventsSubscription = null;
      }
    }
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

    // Play incoming ringtone
    _callAudioService.playIncomingRingtone();

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
        // Stop dial tone/ringtone when call connects
        _callAudioService.stopAll();
        _callAudioService.playCallConnected();
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
      // Get access token
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken == null) {
        _logger.w('No access token for sending ICE candidate');
        return;
      }

      // Send ICE candidate via gRPC
      await _callRemoteDatasource.exchangeIceCandidate(
        accessToken: accessToken,
        callId: _activeCall!.id,
        targetUserId: _activeCall!.remoteUserId!,
        candidate: candidate.candidate,
        sdpMid: candidate.sdpMid ?? '',
        sdpMLineIndex: candidate.sdpMLineIndex ?? 0,
      );
    } on GrpcCallException catch (e) {
      _logger.e('gRPC error sending ICE candidate: ${e.message}');
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

    // Cancel call events subscription
    _callEventsSubscription?.cancel();
    _callEventsSubscription = null;

    // Stop any playing audio and play end sound
    _callAudioService.stopAll();

    // Play appropriate end sound
    if (reason == CallEndReason.busy) {
      _callAudioService.playBusyTone();
    } else {
      _callAudioService.playCallEnded();
    }

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
      // Get access token
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      // Initiate call via gRPC
      final result = await _callRemoteDatasource.initiateCall(
        accessToken: accessToken,
        userId: userId,
        isVideo: type == CallType.video,
      );

      // Create call entity with server-assigned ID
      final call = Call(
        id: result.callId,
        type: type,
        direction: CallDirection.outgoing,
        status: _mapCallState(result.state),
        remoteUserId: userId,
        initiatedAt: DateTime.now(),
        isLocalVideoEnabled: type == CallType.video,
      );

      _activeCall = call;
      _callStateChangesController.add(call);

      // Initialize WebRTC with ICE servers from backend
      await _webrtcDataSource.initialize(
        WebRTCConfig(
          iceServers: result.iceServers
              .map(
                (s) => <String, dynamic>{
                  'urls': s.urls,
                  if (s.username != null) 'username': s.username,
                  if (s.credential != null) 'credential': s.credential,
                },
              )
              .toList(),
        ),
      );

      // Start local media
      await _webrtcDataSource.startLocalMedia(
        enableVideo: type == CallType.video,
        enableAudio: true,
      );

      // Create and set local description
      final offer = await _webrtcDataSource.createOffer();
      await _webrtcDataSource.setLocalDescription(offer);

      // Send SDP offer via gRPC
      await _callRemoteDatasource.exchangeSdp(
        accessToken: accessToken,
        callId: result.callId,
        targetUserId: userId,
        type: SdpMessageType.offer,
        sdp: offer.sdp,
      );

      // Start listening for call events
      _startCallEventStream(result.callId, accessToken);

      _updateCallStatus(CallStatus.ringing);

      // Start playing dial tone
      await _callAudioService.playDialTone();

      return Right(_activeCall!);
    } on GrpcCallException catch (e) {
      _logger.e('gRPC error initiating call: ${e.message}');
      _activeCall = null;
      await _callAudioService.stopAll();
      return Left(ServerFailure('Failed to initiate call: ${e.message}'));
    } catch (e, stackTrace) {
      _logger.e('Failed to initiate call', error: e, stackTrace: stackTrace);
      _activeCall = null;
      await _callAudioService.stopAll();
      return Left(ServerFailure('Failed to initiate call: $e'));
    }
  }

  /// Map gRPC call state to domain call status
  CallStatus _mapCallState(CallStateType state) {
    switch (state) {
      case CallStateType.initiating:
        return CallStatus.initiating;
      case CallStateType.ringing:
        return CallStatus.ringing;
      case CallStateType.connecting:
        return CallStatus.connecting;
      case CallStateType.connected:
        return CallStatus.connected;
      case CallStateType.onHold:
        return CallStatus.onHold;
      case CallStateType.ended:
        return CallStatus.ended;
      case CallStateType.failed:
        return CallStatus.ended;
      case CallStateType.unknown:
        return CallStatus.initiating;
    }
  }

  /// Subscription for call events stream
  StreamSubscription<CallEventData>? _callEventsSubscription;

  /// Start listening for call events from the server
  void _startCallEventStream(String callId, String accessToken) {
    _callEventsSubscription?.cancel();
    _callEventsSubscription = _callRemoteDatasource
        .streamCallEvents(accessToken: accessToken, callId: callId)
        .listen(
          (event) {
            _handleGrpcCallEvent(event, accessToken);
          },
          onError: (error) {
            _logger.e('Call events stream error: $error');
          },
        );
  }

  /// Handle call events from gRPC stream
  Future<void> _handleGrpcCallEvent(
    CallEventData event,
    String accessToken,
  ) async {
    if (event is CallStateChangedEvent) {
      _updateCallStatus(_mapCallState(event.newState));
      if (event.newState == CallStateType.ended ||
          event.newState == CallStateType.failed) {
        _endCall(_mapEndReason(event.endReason));
      }
    } else if (event is IceCandidateReceivedEvent) {
      try {
        await _webrtcDataSource.addIceCandidate(
          IceCandidate(
            candidate: event.candidate,
            sdpMid: event.sdpMid,
            sdpMLineIndex: event.sdpMLineIndex,
          ),
        );
      } catch (e) {
        _logger.e('Failed to add remote ICE candidate: $e');
      }
    } else if (event is SdpReceivedEvent) {
      try {
        await _webrtcDataSource.setRemoteDescription(
          SessionDescription(
            type: event.sdpType == SdpMessageType.offer ? 'offer' : 'answer',
            sdp: event.sdp,
          ),
        );
        if (event.sdpType == SdpMessageType.offer) {
          // Create and send answer
          final answer = await _webrtcDataSource.createAnswer();
          await _webrtcDataSource.setLocalDescription(answer);

          await _callRemoteDatasource.exchangeSdp(
            accessToken: accessToken,
            callId: event.callId,
            targetUserId: _activeCall?.remoteUserId ?? '',
            type: SdpMessageType.answer,
            sdp: answer.sdp,
          );
        }
      } catch (e) {
        _logger.e('Failed to handle remote SDP: $e');
      }
    }
  }

  /// Map gRPC end reason to domain end reason
  CallEndReason _mapEndReason(CallEndReasonType reason) {
    switch (reason) {
      case CallEndReasonType.completed:
        return CallEndReason.localHangup;
      case CallEndReasonType.declined:
        return CallEndReason.declined;
      case CallEndReasonType.missed:
        return CallEndReason.noAnswer;
      case CallEndReasonType.busy:
        return CallEndReason.busy;
      case CallEndReasonType.failedConnection:
        return CallEndReason.networkError;
      case CallEndReasonType.cancelled:
        return CallEndReason.localHangup;
      case CallEndReasonType.unknown:
        return CallEndReason.unknown;
    }
  }

  @override
  Future<Either<Failure, Call>> acceptCall(String callId) async {
    _logger.i('Accepting call $callId');

    if (_activeCall == null || _activeCall!.id != callId) {
      return const Left(ServerFailure('No active call to accept'));
    }

    try {
      // Cancel pending call events subscription - we'll start a new one for the active call
      await _pendingCallEventsSubscription?.cancel();
      _pendingCallEventsSubscription = null;

      // Stop incoming ringtone
      await _callAudioService.stopIncomingRingtone();

      // Get access token
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      // Accept call via gRPC
      final result = await _callRemoteDatasource.acceptCall(
        accessToken: accessToken,
        callId: callId,
      );

      // Initialize WebRTC with ICE servers from backend
      await _webrtcDataSource.initialize(
        WebRTCConfig(
          iceServers: result.iceServers
              .map(
                (s) => <String, dynamic>{
                  'urls': s.urls,
                  if (s.username != null) 'username': s.username,
                  if (s.credential != null) 'credential': s.credential,
                },
              )
              .toList(),
      ));

      // Start local media
      await _webrtcDataSource.startLocalMedia(
        enableVideo: _activeCall!.isVideoCall,
        enableAudio: true,
      );

      // Start listening for call events
      _startCallEventStream(callId, accessToken);

      _updateCallStatus(CallStatus.connecting);

      return Right(_activeCall!);
    } on GrpcCallException catch (e) {
      _logger.e('gRPC error accepting call: ${e.message}');
      return Left(ServerFailure('Failed to accept call: ${e.message}'));
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
      // Cancel pending call events subscription
      await _pendingCallEventsSubscription?.cancel();
      _pendingCallEventsSubscription = null;

      // Stop incoming ringtone
      await _callAudioService.stopIncomingRingtone();

      // Get access token
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      // Reject call via gRPC
      await _callRemoteDatasource.rejectCall(
        accessToken: accessToken,
        callId: callId,
      );

      _endCall(CallEndReason.declined);

      return const Right(null);
    } on GrpcCallException catch (e) {
      _logger.e('gRPC error rejecting call: ${e.message}');
      return Left(ServerFailure('Failed to reject call: ${e.message}'));
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
      // Get access token
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      // End call via gRPC
      await _callRemoteDatasource.endCall(
        accessToken: accessToken,
        callId: callId,
      );

      _endCall(CallEndReason.localHangup);

      return const Right(null);
    } on GrpcCallException catch (e) {
      _logger.e('gRPC error ending call: ${e.message}');
      // Still end the call locally even if gRPC fails
      _endCall(CallEndReason.localHangup);
      return const Right(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to end call', error: e, stackTrace: stackTrace);
      // Still end the call locally even if gRPC fails
      _endCall(CallEndReason.localHangup);
      return const Right(null);
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
    await _callEventsSubscription?.cancel();
    await _pendingCallEventsSubscription?.cancel();
    await _webrtcSubscription?.cancel();
    await _signalingSubscription?.cancel();
    await _incomingCallsSubscription?.cancel();
    await _incomingCallsController.close();
    await _callStateChangesController.close();
    await _callAudioService.dispose();
    await _webrtcDataSource.dispose();
    await _signalingDataSource.dispose();
  }
}
