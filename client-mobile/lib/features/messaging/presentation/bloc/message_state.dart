import 'package:equatable/equatable.dart';

import '../../domain/entities/message.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<Message> messages;
  final bool hasMore;

  const MessageLoaded({
    required this.messages,
    this.hasMore = false,
  });

  MessageLoaded copyWith({
    List<Message>? messages,
    bool? hasMore,
  }) {
    return MessageLoaded(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [messages, hasMore];
}

class MessageSending extends MessageState {
  final List<Message> currentMessages;

  const MessageSending(this.currentMessages);

  @override
  List<Object?> get props => [currentMessages];
}

class MessageError extends MessageState {
  final String message;
  final List<Message> currentMessages;

  const MessageError(this.message, this.currentMessages);

  @override
  List<Object?> get props => [message, currentMessages];
}
