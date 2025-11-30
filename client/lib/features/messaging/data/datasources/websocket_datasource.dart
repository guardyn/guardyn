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

  /// Connect to WebSocket server
  Future<void> connect(String accessToken) async {
    if (_state == WebSocketState.connected ||
        _state == WebSocketState.connecting) {
      return;
    }

    _currentToken = accessToken;
    _updateState(WebSocketState.connecting);

    try {
      final wsUrl = _buildWebSocketUrl(accessToken);
      _logger.i(
        'Connecting to WebSocket: ${wsUrl.replaceAll(accessToken, '***')}',
      );

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection
      await _channel!.ready;

      _updateState(WebSocketState.connected);
      _reconnectAttempts = 0;
      _logger.i('WebSocket connected successfully');

      // Start heartbeat
      _startHeartbeat();

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );
    } catch (e) {
      _logger.e('WebSocket connection failed: $e');
      _updateState(WebSocketState.disconnected);
      _scheduleReconnect();
    }
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

  String _buildWebSocketUrl(String token) {
    // Use static AppConfig methods
    return AppConfig.getWebSocketUrl(token);
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
        case 'new_message':
          _handleNewMessage(json);
          break;
        case 'message_sent':
          _handleMessageSent(json);
          break;
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

  void _handleNewMessage(Map<String, dynamic> json) {
    try {
      final model = MessageModel(
        messageId: json['message_id'] as String? ?? '',
        conversationId: json['conversation_id'] as String? ?? '',
        senderUserId: json['sender_id'] as String? ?? '',
        senderDeviceId: '',
        recipientUserId: json['recipient_id'] as String? ?? '',
        recipientDeviceId: '',
        messageType: MessageType.text,
        textContent: json['content'] as String? ?? '',
        metadata: {},
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          json['timestamp'] as int? ?? 0,
        ),
        deliveryStatus: DeliveryStatus.delivered,
      );

      _messageController.add(model);
    } catch (e) {
      _logger.e('Error handling new message: $e');
    }
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
        _send({'type': 'heartbeat'});
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
  }
}
