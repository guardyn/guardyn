import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    // Load message history
    context.read<MessageBloc>().add(MessageLoadHistory(
          conversationUserId: widget.conversationUserId,
        ));
    // Subscribe to real-time messages
    context.read<MessageBloc>().add(const MessageSubscribeToStream());
  }

  @override
  void dispose() {
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
    context.read<MessageBloc>().add(MessageSend(
          recipientUserId: widget.conversationUserId,
          recipientDeviceId: widget.deviceId,
          textContent: text,
        ));
    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversationUserName),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
                            context.read<MessageBloc>().add(MessageLoadHistory(
                                  conversationUserId: widget.conversationUserId,
                                ));
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
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
                        onLongPress: () => _handleMessageLongPress(message.messageId),
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
              final isEnabled = state is! MessageSending && state is! MessageLoading;
              return MessageInput(
                onSend: _handleSendMessage,
                enabled: isEnabled,
              );
            },
          ),
        ],
      ),
    );
  }
}
