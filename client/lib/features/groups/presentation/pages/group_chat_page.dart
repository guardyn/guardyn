import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import '../widgets/group_message_bubble.dart';
import '../widgets/group_message_input.dart';

/// Page for group chat messages
class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ScrollController _scrollController = ScrollController();

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

  void _handleSendMessage(BuildContext context, String text) {
    context.read<GroupBloc>().add(GroupSendMessage(
          groupId: widget.groupId,
          textContent: text,
        ));
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupBloc>()
        ..add(GroupLoadMessages(groupId: widget.groupId))
        ..add(GroupStartPolling(groupId: widget.groupId))
        ..add(GroupSetActive(widget.groupId)),
      child: Builder(
        builder: (context) => PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              context.read<GroupBloc>().add(const GroupStopPolling());
              context.read<GroupBloc>().add(const GroupSetActive(null));
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.groupName),
                  BlocBuilder<GroupBloc, GroupState>(
                    builder: (context, state) {
                      if (state is GroupMessagesLoaded) {
                        return Text(
                          'Group chat',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.group),
                  onPressed: () {
                    // TODO: Show group members
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Group members - coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocConsumer<GroupBloc, GroupState>(
                    listener: (context, state) {
                      if (state is GroupMessageSent) {
                        _scrollToBottom();
                      }
                      if (state is GroupError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is GroupLoading && state.messages.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = state is GroupMessagesLoaded
                          ? state.messages
                          : state is GroupMessageSending
                              ? state.messages
                              : state is GroupError
                                  ? state.messages
                                  : <dynamic>[];

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start the conversation!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return GroupMessageBubble(
                            message: message,
                            showSenderName: true,
                          );
                        },
                      );
                    },
                  ),
                ),
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    final isLoading = state is GroupMessageSending;
                    return GroupMessageInput(
                      onSend: (text) => _handleSendMessage(context, text),
                      isLoading: isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
