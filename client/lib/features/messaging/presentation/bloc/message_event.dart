import 'package:equatable/equatable.dart';

import '../../domain/entities/message.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class MessageLoadHistory extends MessageEvent {
  final String conversationUserId;
  final String? conversationId;
  final int limit;

  const MessageLoadHistory({
    required this.conversationUserId,
    this.conversationId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [conversationUserId, conversationId, limit];
}

class MessageSend extends MessageEvent {
  final String recipientUserId;
  final String recipientDeviceId;
  final String recipientUsername;
  final String textContent;
  final Map<String, String>? metadata;

  const MessageSend({
    required this.recipientUserId,
    required this.recipientDeviceId,
    required this.recipientUsername,
    required this.textContent,
    this.metadata,
  });

  @override
  List<Object?> get props => [recipientUserId, recipientDeviceId, recipientUsername, textContent, metadata];
}

class MessageReceived extends MessageEvent {
  final Message message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageMarkAsRead extends MessageEvent {
  final String messageId;

  const MessageMarkAsRead(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class MessageDelete extends MessageEvent {
  final String messageId;

  const MessageDelete(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class MessageSubscribeToStream extends MessageEvent {
  const MessageSubscribeToStream();
}

/// Event to set the currently active conversation
/// Used to suppress notifications for messages in the currently open chat
class MessageSetActiveConversation extends MessageEvent {
  final String? userId;

  const MessageSetActiveConversation(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to start periodic polling for new messages
/// This is used as a fallback when gRPC streaming fails
class MessageStartPolling extends MessageEvent {
  final String conversationUserId;
  final String? conversationId;
  final Duration interval;

  const MessageStartPolling({
    required this.conversationUserId,
    this.conversationId,
    this.interval = const Duration(seconds: 2),
  });

  @override
  List<Object?> get props => [conversationUserId, conversationId, interval];
}

/// Event to stop polling for new messages
class MessageStopPolling extends MessageEvent {
  const MessageStopPolling();
}
