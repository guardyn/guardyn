import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/conversation_utils.dart';
import '../../../presence/presentation/bloc/presence_bloc.dart';
import '../../../presence/presentation/bloc/presence_event.dart';
import '../../../presence/presentation/bloc/presence_state.dart';
import '../../../presence/presentation/widgets/last_seen_text.dart';
import '../../../presence/presentation/widgets/online_indicator.dart';
import '../../../presence/presentation/widgets/typing_indicator.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatPage extends StatefulWidget {
  final String conversationUserId;
  final String conversationUserName;
  final String deviceId;

  const ChatPage({
    super.key,
    required this.conversationUserId,
    required this.conversationUserName,
    required this.deviceId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final _secureStorage = const FlutterSecureStorage();
  String? _conversationId;
  late PresenceBloc _presenceBloc;

  @override
  void initState() {
    super.initState();
    // Initialize presence bloc
    _presenceBloc = getIt<PresenceBloc>();
    // Set current user as online and start heartbeat
    _presenceBloc.add(const PresenceSetOnline());
    _presenceBloc.add(PresenceFetchUser(widget.conversationUserId));
    // Subscribe to real-time presence updates for the conversation partner
    _presenceBloc.add(PresenceSubscribe([widget.conversationUserId]));

    // Set active conversation (to suppress notifications for current chat)
    context.read<MessageBloc>().add(
      MessageSetActiveConversation(widget.conversationUserId),
    );

    // Initialize chat: load messages and connect WebSocket
    _initializeChat();
  }

  /// Initialize chat: load messages and connect WebSocket
  Future<void> _initializeChat() async {
    // Get tokens and user ID
    final currentUserId = await _secureStorage.read(key: 'user_id');
    final accessToken = await _secureStorage.read(key: 'access_token');

    if (currentUserId != null && currentUserId.isNotEmpty) {
      // Generate deterministic conversation ID matching backend
      _conversationId = ConversationUtils.generateConversationId(
        currentUserId,
        widget.conversationUserId,
      );

      // Load message history with conversation ID
      if (mounted) {
        context.read<MessageBloc>().add(
          MessageLoadHistory(
            conversationUserId: widget.conversationUserId,
            conversationId: _conversationId,
          ),
        );
      }
    } else {
      // Fallback: try loading without conversation ID
      if (mounted) {
        context.read<MessageBloc>().add(
          MessageLoadHistory(conversationUserId: widget.conversationUserId),
        );
      }
    }

    // Connect WebSocket for real-time messaging
    // ignore: avoid_print
    print(
      '🔌 ChatPage: accessToken present: ${accessToken != null && accessToken.isNotEmpty}',
    );
    if (accessToken != null && accessToken.isNotEmpty && mounted) {
      // ignore: avoid_print
      print('🔌 ChatPage: Calling MessageConnectWebSocket');
      context.read<MessageBloc>().add(
        MessageConnectWebSocket(accessToken: accessToken),
      );
      // Subscribe to conversation after WebSocket connects
      if (_conversationId != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _conversationId != null) {
            context.read<MessageBloc>().add(
              MessageSubscribeConversation(conversationId: _conversationId!),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // Disconnect WebSocket when leaving chat
    context.read<MessageBloc>().add(const MessageDisconnectWebSocket());
    // Clear active conversation when leaving chat
    context.read<MessageBloc>().add(const MessageSetActiveConversation(null));
    // Stop presence subscription and set offline
    _presenceBloc.add(const PresenceUnsubscribe());
    _presenceBloc.add(const PresenceSetOffline());
    _presenceBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage(String text) {
    context.read<MessageBloc>().add(
      MessageSend(
        recipientUserId: widget.conversationUserId,
        recipientDeviceId: widget.deviceId,
        recipientUsername: widget.conversationUserName,
        textContent: text,
      ),
    );
    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _handleTypingChanged(bool isTyping) {
    _presenceBloc.add(
      PresenceSendTyping(
        conversationId: widget.conversationUserId,
        isTyping: isTyping,
      ),
    );
  }

  void _handleMessageLongPress(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                // TODO: Implement copy to clipboard
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                context.read<MessageBloc>().add(MessageDelete(messageId));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Online indicator dot
            StreamBuilder<PresenceState>(
              stream: _presenceBloc.stream,
              initialData: _presenceBloc.state,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state is PresenceLoaded) {
                  final presence = state.presenceMap[widget.conversationUserId];
                  return OnlineIndicator(presenceInfo: presence, size: 10);
                }
                return const OnlineIndicator(size: 10);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.conversationUserName),
                  StreamBuilder<PresenceState>(
                    stream: _presenceBloc.stream,
                    initialData: _presenceBloc.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      if (state is PresenceLoaded) {
                        final presence =
                            state.presenceMap[widget.conversationUserId];
                        if (presence != null) {
                          // Check if typing - either from typingUsers map or from presence itself
                          final isTyping =
                              state.typingUsers.containsKey(
                                widget.conversationUserId,
                              ) ||
                              presence.isTyping;
                          if (isTyping) {
                            return const TypingIndicator(dotSize: 4);
                          }
                          return LastSeenText(presenceInfo: presence);
                        }
                      }
                      return const Text(
                        'Connecting...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement chat settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: BlocConsumer<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state is MessageLoaded) {
                  // Auto-scroll to bottom when new message arrives
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    _scrollToBottom,
                  );
                }
              },
              builder: (context, state) {
                if (state is MessageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MessageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Reload messages and reconnect WebSocket
                            _initializeChat();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is MessageLoaded || state is MessageSending) {
                  final messages = state is MessageLoaded
                      ? state.messages
                      : (state as MessageSending).currentMessages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet.\nSend a message to start the conversation!',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Show newest messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(
                        message: message,
                        onLongPress: () =>
                            _handleMessageLongPress(message.messageId),
                      );
                    },
                  );
                }

                // Initial state
                return const Center(child: Text('Loading messages...'));
              },
            ),
          ),
          // Message input
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              final isEnabled =
                  state is! MessageSending && state is! MessageLoading;
              return MessageInput(
                onSend: _handleSendMessage,
                onTypingChanged: _handleTypingChanged,
                enabled: isEnabled,
              );
            },
          ),
        ],
      ),
    );
  }
}
