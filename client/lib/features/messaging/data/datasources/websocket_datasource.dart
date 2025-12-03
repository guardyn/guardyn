import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/config.dart';
import '../../domain/entities/message.dart';
import '../models/message_model.dart';

/// WebSocket message types (matching backend)
enum WsMessageType {
  // Client -> Server
  sendMessage,
  subscribe,
  typingIndicator,
  heartbeat,
  // Server -> Client
  newMessage,
  messageSent,
  presenceUpdate,
  typing,
  subscribed,
  pong,
  error,
}

/// WebSocket connection state
enum WebSocketState { disconnected, connecting, connected, reconnecting }

/// WebSocket datasource for real-time messaging
@lazySingleton
class WebSocketDatasource {
  final Logger _logger = Logger();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String? _currentToken;

  final _messageController = StreamController<MessageModel>.broadcast();
  final _presenceController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _stateController = StreamController<WebSocketState>.broadcast();

  WebSocketState _state = WebSocketState.disconnected;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 2);

  WebSocketDatasource();

  /// Current connection state
  WebSocketState get state => _state;

  /// Stream of incoming messages
  Stream<MessageModel> get messageStream => _messageController.stream;

  /// Stream of presence updates
  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;

  /// Stream of typing indicators
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  /// Stream of connection state changes
  Stream<WebSocketState> get stateStream => _stateController.stream;

  /// Whether WebSocket is connected
  bool get isConnected => _state == WebSocketState.connected;

  /// Stream to notify about authentication errors (for token refresh)
  final _authErrorController = StreamController<String>.broadcast();
  Stream<String> get authErrorStream => _authErrorController.stream;

  /// Connect to WebSocket server
  Future<void> connect(String accessToken) async {
    if (_state == WebSocketState.connected ||
        _state == WebSocketState.connecting) {
      // ignore: avoid_print
      print('🔌 WebSocket already connected/connecting, skipping');
      return;
    }

    _currentToken = accessToken;
    _updateState(WebSocketState.connecting);

    try {
      // Connect to WebSocket endpoint without token in URL
      // Authentication happens via auth message after connection
      final wsUrl = _buildWebSocketUrl();
      // ignore: avoid_print
      print('🔌 Connecting to WebSocket: $wsUrl');
      _logger.i('Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection
      // ignore: avoid_print
      print('🔌 Waiting for WebSocket ready...');
      await _channel!.ready;

      // ignore: avoid_print
      print('🔌 WebSocket connection established, authenticating...');
      _logger.i('WebSocket connection established, authenticating...');

      // Start listening to messages before sending auth
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      // Send authentication message
      await _authenticate(accessToken);
    } catch (e) {
      // ignore: avoid_print
      print('🔌 WebSocket connection failed: $e');
      _logger.e('WebSocket connection failed: $e');
      _updateState(WebSocketState.disconnected);
      _scheduleReconnect();
    }
  }

  /// Send authentication message to WebSocket server
  Future<void> _authenticate(String token) async {
    final authMessage = {
      'type': 'auth',
      'payload': {
        'token': token,
        'device_id': 'flutter-client', // TODO: Get actual device ID
      },
    };
    _send(authMessage);
    _logger.d('Sent authentication message');
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _cancelTimers();
    _updateState(WebSocketState.disconnected);

    if (_channel != null) {
      try {
        await _channel!.sink.close();
      } catch (e) {
        _logger.w('Error closing WebSocket: $e');
      }
      _channel = null;
    }

    _currentToken = null;
    _reconnectAttempts = 0;
  }

  /// Send a message via WebSocket
  Future<void> sendMessage({
    required String recipientId,
    required String content,
    required String contentType,
    required bool encrypted,
  }) async {
    if (!isConnected) {
      throw StateError('WebSocket not connected');
    }

    final message = {
      'type': 'send_message',
      'recipient_id': recipientId,
      'content': content,
      'content_type': contentType,
      'encrypted': encrypted,
    };

    _send(message);
  }

  /// Subscribe to a conversation
  Future<void> subscribeToConversation(String conversationId) async {
    if (!isConnected) {
      throw StateError('WebSocket not connected');
    }

    final message = {
      'type': 'subscribe',
      'subscription_type': 'conversation',
      'target_id': conversationId,
    };

    _send(message);
    _logger.d('Subscribed to conversation: $conversationId');
  }

  /// Subscribe to presence updates for a user
  Future<void> subscribeToPresence(String userId) async {
    if (!isConnected) {
      throw StateError('WebSocket not connected');
    }

    final message = {
      'type': 'subscribe',
      'subscription_type': 'presence',
      'target_id': userId,
    };

    _send(message);
    _logger.d('Subscribed to presence: $userId');
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    if (!isConnected) return;

    final message = {
      'type': 'typing_indicator',
      'conversation_id': conversationId,
      'is_typing': isTyping,
    };

    _send(message);
  }

  // Private methods

  String _buildWebSocketUrl() {
    // Build WebSocket URL without token (auth via message)
    final protocol = AppConfig.websocketSecure ? 'wss' : 'ws';
    return '$protocol://${AppConfig.websocketHost}:${AppConfig.websocketPort}/ws';
  }

  void _send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      _logger.d('WebSocket message received: $type');

      switch (type) {
        case 'auth_response':
          _handleAuthResponse(json);
          break;
        case 'message':
        case 'new_message':
          _handleNewMessage(json);
          break;
        case 'message_sent':
          _handleMessageSent(json);
          break;
        case 'presence':
        case 'presence_update':
          _handlePresenceUpdate(json);
          break;
        case 'typing':
          _handleTyping(json);
          break;
        case 'subscribed':
          _logger.d('Subscription confirmed: ${json['subscription_type']}');
          break;
        case 'pong':
          _logger.d('Heartbeat pong received');
          break;
        case 'error':
          _handleServerError(json);
          break;
        default:
          _logger.w('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      _logger.e('Error parsing WebSocket message: $e');
    }
  }

  /// Handle authentication response from server
  void _handleAuthResponse(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>?;
    final success = payload?['success'] as bool? ?? false;
    final error = payload?['error'] as String?;

    if (success) {
      _logger.i('WebSocket authentication successful');
      _updateState(WebSocketState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
    } else {
      _logger.e('WebSocket authentication failed: $error');
      _authErrorController.add(error ?? 'Authentication failed');
      _updateState(WebSocketState.disconnected);
      // Don't reconnect with same token - need new token
    }
  }

  void _handleNewMessage(Map<String, dynamic> json) {
    try {
      // Handle both direct message format and payload-wrapped format
      final payload = json['payload'] as Map<String, dynamic>? ?? json;

      final model = MessageModel(
        messageId: payload['message_id'] as String? ?? '',
        conversationId: payload['conversation_id'] as String? ?? '',
        senderUserId:
            payload['sender_id'] as String? ??
            payload['sender_user_id'] as String? ??
            '',
        senderDeviceId: payload['sender_device_id'] as String? ?? '',
        recipientUserId:
            payload['recipient_id'] as String? ??
            payload['recipient_user_id'] as String? ??
            '',
        recipientDeviceId: payload['recipient_device_id'] as String? ?? '',
        messageType: MessageType.text,
        textContent:
            payload['content'] as String? ??
            payload['text_content'] as String? ??
            '',
        metadata: {},
        timestamp: _parseTimestamp(payload['timestamp']),
        deliveryStatus: DeliveryStatus.delivered,
      );

      _messageController.add(model);
      _logger.d('New message received: ${model.messageId}');
    } catch (e) {
      _logger.e('Error handling new message: $e');
    }
  }

  /// Parse timestamp from various formats
  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  void _handleMessageSent(Map<String, dynamic> json) {
    _logger.d('Message sent confirmed: ${json['message_id']}');
    // Could update UI with confirmed message ID
  }

  void _handlePresenceUpdate(Map<String, dynamic> json) {
    _presenceController.add(json);
  }

  void _handleTyping(Map<String, dynamic> json) {
    _typingController.add(json);
  }

  void _handleServerError(Map<String, dynamic> json) {
    final error = json['error'] as String?;
    _logger.e('WebSocket server error: $error');
  }

  void _handleError(Object error) {
    _logger.e('WebSocket error: $error');
    _updateState(WebSocketState.disconnected);
    _scheduleReconnect();
  }

  void _handleDone() {
    _logger.i('WebSocket connection closed');
    _updateState(WebSocketState.disconnected);
    _scheduleReconnect();
  }

  void _updateState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (isConnected) {
        _send({
          'type': 'ping',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  void _scheduleReconnect() {
    if (_currentToken == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.e('Max reconnect attempts reached');
      return;
    }

    _cancelTimers();
    _updateState(WebSocketState.reconnecting);

    final delay = _reconnectDelay * (_reconnectAttempts + 1);
    _reconnectAttempts++;

    _logger.i(
      'Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectTimer = Timer(delay, () {
      if (_currentToken != null) {
        connect(_currentToken!);
      }
    });
  }

  void _cancelTimers() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Dispose resources
  @disposeMethod
  void dispose() {
    _cancelTimers();
    _channel?.sink.close();
    _messageController.close();
    _presenceController.close();
    _typingController.close();
    _stateController.close();
    _authErrorController.close();
  }
}
