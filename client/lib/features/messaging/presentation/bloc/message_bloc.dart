import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
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
  Timer? _pollingTimer;
  String? _pollingConversationUserId;
  String? _pollingConversationId;
  
  /// Currently open conversation user ID (to suppress notifications for active chat)
  String? _activeConversationUserId;

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
    on<MessageSetActiveConversation>(_onSetActiveConversation);
    on<MessageStartPolling>(_onStartPolling);
    on<MessageStopPolling>(_onStopPolling);
  }
  
  /// Set the active conversation (to suppress notifications for current chat)
  void _onSetActiveConversation(
    MessageSetActiveConversation event,
    Emitter<MessageState> emit,
  ) {
    _activeConversationUserId = event.userId;
  }
  
  /// Start polling for new messages (fallback for gRPC streaming)
  void _onStartPolling(
    MessageStartPolling event,
    Emitter<MessageState> emit,
  ) {
    // Cancel existing polling timer
    _pollingTimer?.cancel();
    
    _pollingConversationUserId = event.conversationUserId;
    _pollingConversationId = event.conversationId;
    
    // ignore: avoid_print
    print('📡 Starting message polling for conversation: ${event.conversationUserId}');
    
    // Start periodic polling
    _pollingTimer = Timer.periodic(event.interval, (_) {
      _pollForNewMessages();
    });
    
    // Also poll immediately
    _pollForNewMessages();
  }
  
  /// Stop polling for new messages
  void _onStopPolling(
    MessageStopPolling event,
    Emitter<MessageState> emit,
  ) {
    // ignore: avoid_print
    print('📡 Stopping message polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollingConversationUserId = null;
    _pollingConversationId = null;
  }
  
  /// Poll for new messages
  Future<void> _pollForNewMessages() async {
    if (_pollingConversationUserId == null) return;
    
    final result = await getMessages(GetMessagesParams(
      conversationUserId: _pollingConversationUserId!,
      conversationId: _pollingConversationId,
      limit: 20,
    ));
    
    result.fold(
      (failure) {
        // ignore: avoid_print
        print('📡 Polling error: ${failure.message}');
      },
      (messages) {
        if (messages.isEmpty) return;
        
        // Get current messages
        final currentMessages = state is MessageLoaded
            ? (state as MessageLoaded).messages
            : <Message>[];
        
        // Find new messages (not already in current list)
        final currentIds = currentMessages.map((m) => m.messageId).toSet();
        final newMessages = messages.where((m) => !currentIds.contains(m.messageId)).toList();
        
        if (newMessages.isNotEmpty) {
          // ignore: avoid_print
          print('📡 Found ${newMessages.length} new messages via polling');
          
          // Add each new message via MessageReceived event
          for (final message in newMessages) {
            add(MessageReceived(message));
          }
        }
      },
    );
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
      recipientUsername: event.recipientUsername,
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
      
      // Show notification if message is not from the active conversation
      // (i.e., the chat that is currently open)
      final isFromActiveConversation = 
          _activeConversationUserId != null && 
          event.message.senderUserId == _activeConversationUserId;
      
      // Only notify for messages received from others, not sent by current user
      final isReceivedMessage = !event.message.isSentByMe;
      
      if (isReceivedMessage && !isFromActiveConversation) {
        _showNotification(event.message);
      }
    }
  }
  
  /// Show notification for incoming message
  void _showNotification(Message message) {
    try {
      final notificationService = getIt<NotificationService>();
      
      // Construct notification title and body
      final senderName = message.senderUserId; // TODO: Get username from user cache
      final messagePreview = message.textContent.length > 50
          ? '${message.textContent.substring(0, 50)}...'
          : message.textContent;
      
      notificationService.showMessageNotification(
        title: 'New message from $senderName',
        body: messagePreview,
        payload: message.conversationId,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Failed to show notification: $e');
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
            // Log stream errors but don't show them as messages to user
            // Stream errors are expected when connection is interrupted
            // The UI will show existing messages and user can retry
            // ignore: avoid_print
            print('Message stream error: ${failure.message}');
          },
          (message) {
            // Add received message to state
            add(MessageReceived(message));
          },
        );
      },
      onError: (error) {
        // Handle stream errors silently - connection issues are transient
        // ignore: avoid_print
        print('Message stream connection error: $error');
      },
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _messageStreamSubscription?.cancel();
    return super.close();
  }
}
