/// Signaling DataSource
///
/// Manages WebSocket connection to the signaling server for WebRTC calls.
/// Handles SDP offer/answer exchange and ICE candidate relay.
library;

import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'webrtc_datasource.dart';

/// Signaling message types
enum SignalType {
  /// Register for incoming calls
  register,

  /// Initiate a call
  call,

  /// Call ringing at remote
  ringing,

  /// Accept incoming call
  accept,

  /// Reject incoming call
  reject,

  /// SDP offer
  offer,

  /// SDP answer
  answer,

  /// ICE candidate
  candidate,

  /// End/hangup call
  hangup,

  /// Error message
  error,

  /// Keep-alive ping
  ping,

  /// Keep-alive pong
  pong,
}

/// Base signaling message
abstract class SignalingMessage {
  final SignalType type;
  final String callId;
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp;

  SignalingMessage({
    required this.type,
    required this.callId,
    required this.fromUserId,
    required this.toUserId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap();

  String toJson() => jsonEncode(toMap());
}

/// Call initiation message
class CallMessage extends SignalingMessage {
  final bool isVideo;
  final String? callerName;
  final String? callerAvatar;

  CallMessage({
    required super.callId,
    required super.fromUserId,
    required super.toUserId,
    required this.isVideo,
    this.callerName,
    this.callerAvatar,
    super.timestamp,
  }) : super(type: SignalType.call);

  @override
  Map<String, dynamic> toMap() => {
        'type': 'call',
        'callId': callId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'isVideo': isVideo,
        'callerName': callerName,
        'callerAvatar': callerAvatar,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CallMessage.fromMap(Map<String, dynamic> map) => CallMessage(
        callId: map['callId'] as String,
        fromUserId: map['fromUserId'] as String,
        toUserId: map['toUserId'] as String,
        isVideo: map['isVideo'] as bool? ?? false,
        callerName: map['callerName'] as String?,
        callerAvatar: map['callerAvatar'] as String?,
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'] as String)
            : null,
      );
}

/// SDP message (offer/answer)
class SdpMessage extends SignalingMessage {
  final SessionDescription sdp;

  SdpMessage({
    required super.type,
    required super.callId,
    required super.fromUserId,
    required super.toUserId,
    required this.sdp,
    super.timestamp,
  })  : assert(type == SignalType.offer || type == SignalType.answer);

  @override
  Map<String, dynamic> toMap() => {
        'type': type == SignalType.offer ? 'offer' : 'answer',
        'callId': callId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'sdp': sdp.toMap(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory SdpMessage.fromMap(Map<String, dynamic> map) {
    final type = map['type'] == 'offer' ? SignalType.offer : SignalType.answer;
    return SdpMessage(
      type: type,
      callId: map['callId'] as String,
      fromUserId: map['fromUserId'] as String,
      toUserId: map['toUserId'] as String,
      sdp: SessionDescription.fromMap(map['sdp'] as Map<String, dynamic>),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : null,
    );
  }
}

/// ICE candidate message
class CandidateMessage extends SignalingMessage {
  final IceCandidate candidate;

  CandidateMessage({
    required super.callId,
    required super.fromUserId,
    required super.toUserId,
    required this.candidate,
    super.timestamp,
  }) : super(type: SignalType.candidate);

  @override
  Map<String, dynamic> toMap() => {
        'type': 'candidate',
        'callId': callId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'candidate': candidate.toMap(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory CandidateMessage.fromMap(Map<String, dynamic> map) => CandidateMessage(
        callId: map['callId'] as String,
        fromUserId: map['fromUserId'] as String,
        toUserId: map['toUserId'] as String,
        candidate: IceCandidate.fromMap(map['candidate'] as Map<String, dynamic>),
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'] as String)
            : null,
      );
}

/// Call control message (accept/reject/hangup/ringing)
class CallControlMessage extends SignalingMessage {
  final String? reason;

  CallControlMessage({
    required super.type,
    required super.callId,
    required super.fromUserId,
    required super.toUserId,
    this.reason,
    super.timestamp,
  })  : assert(type == SignalType.accept ||
            type == SignalType.reject ||
            type == SignalType.hangup ||
            type == SignalType.ringing);

  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'callId': callId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        if (reason != null) 'reason': reason,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CallControlMessage.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String;
    final type = SignalType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => SignalType.error,
    );
    return CallControlMessage(
      type: type,
      callId: map['callId'] as String,
      fromUserId: map['fromUserId'] as String,
      toUserId: map['toUserId'] as String,
      reason: map['reason'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : null,
    );
  }
}

/// Signaling connection state
enum SignalingState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Events from signaling datasource
abstract class SignalingEvent {}

class SignalingStateChanged extends SignalingEvent {
  final SignalingState state;
  SignalingStateChanged(this.state);
}

class SignalingMessageReceived extends SignalingEvent {
  final SignalingMessage message;
  SignalingMessageReceived(this.message);
}

class SignalingError extends SignalingEvent {
  final String message;
  final Object? error;
  SignalingError(this.message, [this.error]);
}

/// Signaling DataSource Interface
abstract class SignalingDataSource {
  /// Stream of signaling events
  Stream<SignalingEvent> get events;

  /// Current connection state
  SignalingState get state;

  /// Connect to signaling server
  ///
  /// [serverUrl] - WebSocket URL of signaling server
  /// [userId] - Current user ID for registration
  /// [token] - Authentication token
  Future<void> connect({
    required String serverUrl,
    required String userId,
    required String token,
  });

  /// Send a call initiation
  Future<void> sendCall(CallMessage message);

  /// Send ringing notification
  Future<void> sendRinging(CallControlMessage message);

  /// Send call acceptance
  Future<void> sendAccept(CallControlMessage message);

  /// Send call rejection
  Future<void> sendReject(CallControlMessage message);

  /// Send SDP offer/answer
  Future<void> sendSdp(SdpMessage message);

  /// Send ICE candidate
  Future<void> sendCandidate(CandidateMessage message);

  /// Send hangup
  Future<void> sendHangup(CallControlMessage message);

  /// Disconnect from server
  Future<void> disconnect();

  /// Dispose resources
  Future<void> dispose();
}

/// Signaling DataSource Implementation
class SignalingDataSourceImpl implements SignalingDataSource {
  final Logger _logger;

  final _eventsController = StreamController<SignalingEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  SignalingState _state = SignalingState.disconnected;
  String? _userId;
  String? _serverUrl;
  String? _token;

  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 2);

  SignalingDataSourceImpl({required Logger logger}) : _logger = logger;

  @override
  Stream<SignalingEvent> get events => _eventsController.stream;

  @override
  SignalingState get state => _state;

  @override
  Future<void> connect({
    required String serverUrl,
    required String userId,
    required String token,
  }) async {
    _logger.i('Connecting to signaling server: $serverUrl');

    _userId = userId;
    _serverUrl = serverUrl;
    _token = token;

    await _connect();
  }

  Future<void> _connect() async {
    if (_serverUrl == null || _userId == null || _token == null) {
      throw StateError('Connection parameters not set');
    }

    _updateState(SignalingState.connecting);

    try {
      final uri = Uri.parse('$_serverUrl?userId=$_userId&token=$_token');
      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _updateState(SignalingState.connected);
      _reconnectAttempts = 0;
      _startPingTimer();

      _logger.i('Connected to signaling server');
    } catch (e, stackTrace) {
      _logger.e('Failed to connect to signaling server',
          error: e, stackTrace: stackTrace);
      _updateState(SignalingState.error);
      _eventsController.add(SignalingError('Connection failed', e));
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final typeStr = json['type'] as String;

      _logger.d('Received signaling message: $typeStr');

      final message = _parseMessage(typeStr, json);
      if (message != null) {
        _eventsController.add(SignalingMessageReceived(message));
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to parse signaling message',
          error: e, stackTrace: stackTrace);
      _eventsController.add(SignalingError('Failed to parse message', e));
    }
  }

  SignalingMessage? _parseMessage(String type, Map<String, dynamic> json) {
    return switch (type) {
      'call' => CallMessage.fromMap(json),
      'offer' || 'answer' => SdpMessage.fromMap(json),
      'candidate' => CandidateMessage.fromMap(json),
      'accept' || 'reject' || 'hangup' || 'ringing' =>
        CallControlMessage.fromMap(json),
      'pong' => null, // Keep-alive response, no event needed
      _ => null,
    };
  }

  void _onError(Object error) {
    _logger.e('WebSocket error', error: error);
    _updateState(SignalingState.error);
    _eventsController.add(SignalingError('WebSocket error', error));
    _scheduleReconnect();
  }

  void _onDone() {
    _logger.i('WebSocket connection closed');
    _stopPingTimer();

    if (_state != SignalingState.disconnected) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.e('Max reconnect attempts reached');
      _updateState(SignalingState.error);
      return;
    }

    _reconnectAttempts++;
    final delay = _reconnectDelay * _reconnectAttempts;

    _logger.i(
        'Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');

    _updateState(SignalingState.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      await _cleanup();
      await _connect();
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      _sendRaw({'type': 'ping', 'timestamp': DateTime.now().toIso8601String()});
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<void> _sendRaw(Map<String, dynamic> data) async {
    if (_channel == null || _state != SignalingState.connected) {
      throw StateError('Not connected to signaling server');
    }

    final json = jsonEncode(data);
    _logger.d('Sending: ${data['type']}');
    _channel!.sink.add(json);
  }

  Future<void> _sendMessage(SignalingMessage message) async {
    await _sendRaw(message.toMap());
  }

  @override
  Future<void> sendCall(CallMessage message) async {
    _logger.i('Sending call to ${message.toUserId}');
    await _sendMessage(message);
  }

  @override
  Future<void> sendRinging(CallControlMessage message) async {
    _logger.i('Sending ringing for call ${message.callId}');
    await _sendMessage(message);
  }

  @override
  Future<void> sendAccept(CallControlMessage message) async {
    _logger.i('Sending accept for call ${message.callId}');
    await _sendMessage(message);
  }

  @override
  Future<void> sendReject(CallControlMessage message) async {
    _logger.i('Sending reject for call ${message.callId}');
    await _sendMessage(message);
  }

  @override
  Future<void> sendSdp(SdpMessage message) async {
    _logger.i('Sending ${message.type.name} for call ${message.callId}');
    await _sendMessage(message);
  }

  @override
  Future<void> sendCandidate(CandidateMessage message) async {
    _logger.d('Sending ICE candidate for call ${message.callId}');
    await _sendMessage(message);
  }

  @override
  Future<void> sendHangup(CallControlMessage message) async {
    _logger.i('Sending hangup for call ${message.callId}');
    await _sendMessage(message);
  }

  @override
  Future<void> disconnect() async {
    _logger.i('Disconnecting from signaling server');
    _reconnectTimer?.cancel();
    _stopPingTimer();
    await _cleanup();
    _updateState(SignalingState.disconnected);
  }

  Future<void> _cleanup() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _eventsController.close();
  }

  void _updateState(SignalingState newState) {
    if (_state != newState) {
      _state = newState;
      _eventsController.add(SignalingStateChanged(newState));
      _logger.i('Signaling state changed: $newState');
    }
  }
}
