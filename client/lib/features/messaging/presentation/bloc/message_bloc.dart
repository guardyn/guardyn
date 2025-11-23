import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/mark_as_read.dart';
import '../../domain/usecases/receive_messages.dart';
import '../../domain/usecases/send_message.dart';
import 'message_event.dart';
import 'message_state.dart';

@injectable
class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final SendMessage sendMessage;
  final GetMessages getMessages;
  final ReceiveMessages receiveMessages;
  final MarkAsRead markAsRead;

  StreamSubscription<dynamic>? _messageStreamSubscription;

  MessageBloc({
    required this.sendMessage,
    required this.getMessages,
    required this.receiveMessages,
    required this.markAsRead,
  }) : super(MessageInitial()) {
    on<MessageLoadHistory>(_onLoadHistory);
    on<MessageSend>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<MessageMarkAsRead>(_onMarkAsRead);
    on<MessageDelete>(_onDeleteMessage);
    on<MessageSubscribeToStream>(_onSubscribeToStream);
  }

  Future<void> _onLoadHistory(
    MessageLoadHistory event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageLoading());

    final result = await getMessages(GetMessagesParams(
      conversationUserId: event.conversationUserId,
      conversationId: event.conversationId,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(MessageError(failure.message, const [])),
      (messages) => emit(MessageLoaded(
        messages: messages,
        hasMore: messages.length >= event.limit,
      )),
    );
  }

  Future<void> _onSendMessage(
    MessageSend event,
    Emitter<MessageState> emit,
  ) async {
    // Get current messages if available
    final currentMessages = state is MessageLoaded
        ? (state as MessageLoaded).messages
        : <Message>[];

    // Emit sending state
    emit(MessageSending(currentMessages));

    final result = await sendMessage(SendMessageParams(
      recipientUserId: event.recipientUserId,
      recipientDeviceId: event.recipientDeviceId,
      textContent: event.textContent,
      metadata: event.metadata,
    ));

    result.fold(
      (failure) => emit(MessageError(failure.message, currentMessages)),
      (message) {
        // Add new message to the list
        final updatedMessages = [message, ...currentMessages];
        emit(MessageLoaded(messages: updatedMessages));
      },
    );
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<MessageState> emit,
  ) {
    // Get current messages if available
    final currentMessages = state is MessageLoaded
        ? (state as MessageLoaded).messages
        : <Message>[];

    // Check if message already exists (deduplication)
    final messageExists = currentMessages.any(
      (m) => m.messageId == event.message.messageId,
    );

    if (!messageExists) {
      // Add new message to the list
      final updatedMessages = [event.message, ...currentMessages];
      emit(MessageLoaded(messages: updatedMessages));
    }
  }

  Future<void> _onMarkAsRead(
    MessageMarkAsRead event,
    Emitter<MessageState> emit,
  ) async {
    final result = await markAsRead(MarkAsReadParams(
      messageId: event.messageId,
    ));

    result.fold(
      (failure) {
        // Silently fail mark as read, don't show error to user
      },
      (_) {
        // Update message status in current list if loaded
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;
          final updatedMessages = currentState.messages.map((message) {
            if (message.messageId == event.messageId) {
              return Message(
                messageId: message.messageId,
                conversationId: message.conversationId,
                senderUserId: message.senderUserId,
                senderDeviceId: message.senderDeviceId,
                recipientUserId: message.recipientUserId,
                recipientDeviceId: message.recipientDeviceId,
                messageType: message.messageType,
                textContent: message.textContent,
                metadata: message.metadata,
                timestamp: message.timestamp,
                deliveryStatus: DeliveryStatus.read,
                currentUserId: message.currentUserId,
              );
            }
            return message;
          }).toList();

          emit(MessageLoaded(
            messages: updatedMessages,
            hasMore: currentState.hasMore,
          ));
        }
      },
    );
  }

  Future<void> _onDeleteMessage(
    MessageDelete event,
    Emitter<MessageState> emit,
  ) async {
    // TODO: Implement delete message
    // For now, just remove from local list
    if (state is MessageLoaded) {
      final currentState = state as MessageLoaded;
      final updatedMessages = currentState.messages
          .where((message) => message.messageId != event.messageId)
          .toList();

      emit(MessageLoaded(
        messages: updatedMessages,
        hasMore: currentState.hasMore,
      ));
    }
  }

  Future<void> _onSubscribeToStream(
    MessageSubscribeToStream event,
    Emitter<MessageState> emit,
  ) async {
    // Cancel existing subscription if any
    await _messageStreamSubscription?.cancel();

    // Subscribe to incoming messages
    final messageStream = receiveMessages();

    _messageStreamSubscription = messageStream.listen(
      (either) {
        either.fold(
          (failure) {
            // Handle stream errors
            add(MessageReceived(
              Message(
                messageId: 'error-${DateTime.now().millisecondsSinceEpoch}',
                conversationId: 'error',
                senderUserId: 'system',
                senderDeviceId: 'system',
                recipientUserId: '',
                recipientDeviceId: '',
                messageType: MessageType.text,
                textContent: 'Stream error: ${failure.message}',
                metadata: const {},
                timestamp: DateTime.now(),
                deliveryStatus: DeliveryStatus.failed,
              ),
            ));
          },
          (message) {
            // Add received message to state
            add(MessageReceived(message));
          },
        );
      },
      onError: (error) {
        // Handle stream errors
      },
    );
  }

  @override
  Future<void> close() {
    _messageStreamSubscription?.cancel();
    return super.close();
  }
}
