import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/conversation_utils.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../calls/domain/entities/entities.dart';
import '../../../calls/presentation/bloc/call_bloc.dart';
import '../../../calls/presentation/bloc/call_event.dart';
import '../../../calls/presentation/pages/call_page.dart';
import '../../../media/presentation/bloc/media_bloc.dart';
import '../../../media/presentation/bloc/media_event.dart';
import '../../../media/presentation/bloc/media_state.dart';
import '../../../media/presentation/widgets/media_picker_sheet.dart';
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
import 'chat_settings_page.dart';

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
  late MessageBloc _messageBloc;
  late MediaBloc _mediaBloc;
  bool _isUploadingMedia = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Store reference to MessageBloc for safe use in dispose()
    _messageBloc = context.read<MessageBloc>();
    // Initialize presence bloc
    _presenceBloc = getIt<PresenceBloc>();
    // Initialize media bloc for attachment uploads
    _mediaBloc = getIt<MediaBloc>();
    // Set current user as online and start heartbeat
    _presenceBloc.add(const PresenceSetOnline());
    _presenceBloc.add(PresenceFetchUser(widget.conversationUserId));
    // Subscribe to real-time presence updates for the conversation partner
    _presenceBloc.add(PresenceSubscribe([widget.conversationUserId]));

    // Initialize chat: load messages and connect WebSocket
    // Note: Active conversation is set in _initializeChat after getting currentUserId
    _initializeChat();
  }

  /// Initialize chat: load messages and connect WebSocket
  Future<void> _initializeChat() async {
    // Get user ID from secure storage
    final currentUserId = await _secureStorage.read(key: 'user_id');
    
    // Get valid access token using TokenManager (handles auto-refresh)
    final tokenManager = getIt<TokenManager>();
    final accessToken = await tokenManager.getValidAccessToken();

    if (currentUserId != null && currentUserId.isNotEmpty) {
      // Generate deterministic conversation ID matching backend
      _conversationId = ConversationUtils.generateConversationId(
        currentUserId,
        widget.conversationUserId,
      );

      // Set active conversation with all required info (userId, conversationId, currentUserId)
      // This enables proper filtering of incoming messages
      if (mounted) {
        context.read<MessageBloc>().add(
          MessageSetActiveConversation(
            widget.conversationUserId,
            conversationId: _conversationId,
            currentUserId: currentUserId,
          ),
        );
      }

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
        // Set active conversation without currentUserId
        context.read<MessageBloc>().add(
          MessageSetActiveConversation(widget.conversationUserId),
        );
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
    // Disconnect WebSocket when leaving chat (using stored reference)
    _messageBloc.add(const MessageDisconnectWebSocket());
    // Clear active conversation when leaving chat
    _messageBloc.add(const MessageSetActiveConversation(null));
    // Stop presence subscription and set offline
    // Note: Don't close _presenceBloc - it's a singleton managed by GetIt
    if (!_presenceBloc.isClosed) {
      _presenceBloc.add(const PresenceUnsubscribe());
      _presenceBloc.add(const PresenceSetOffline());
    }
    // Close media bloc
    _mediaBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear chat'),
        content: Text(
          'Are you sure you want to delete all messages with ${widget.conversationUserName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (_conversationId != null) {
                context.read<MessageBloc>().add(
                  MessageClearChat(conversationId: _conversationId!),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatSettingsPage(
          userId: widget.conversationUserId,
          username: widget.conversationUserName,
          conversationId: _conversationId,
        ),
      ),
    );
  }

  /// Initiate a voice or video call with the conversation partner
  void _initiateCall(CallType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => getIt<CallBloc>()
            ..add(InitiateCallEvent(
              userId: widget.conversationUserId,
              userName: widget.conversationUserName,
              type: type,
            )),
          child: const CallPage(),
        ),
      ),
    );
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

  void _handleMediaSelected(MediaPickerResult result) {
    setState(() {
      _isUploadingMedia = true;
      _uploadProgress = 0.0;
    });

    // Upload media
    _mediaBloc.add(MediaUploadRequested(
      filePath: result.filePath,
      mimeType: result.mimeType,
      conversationId: _conversationId,
    ));

    // Listen for upload completion
    _mediaBloc.stream.listen((state) {
      if (state is MediaUploading) {
        setState(() {
          _uploadProgress = state.progress;
        });
      } else if (state is MediaUploadSuccess) {
        setState(() {
          _isUploadingMedia = false;
          _uploadProgress = 0.0;
        });

        // Send message with media attachment
        context.read<MessageBloc>().add(
          MessageSend(
            recipientUserId: widget.conversationUserId,
            recipientDeviceId: widget.deviceId,
            recipientUsername: widget.conversationUserName,
            textContent: '', // Caption can be added later
            metadata: {
              'media_id': state.media.id,
              'media_type': state.media.type.name,
              'filename': state.media.filename,
              'mime_type': state.media.mimeType,
              'size_bytes': state.media.sizeBytes.toString(),
            },
          ),
        );

        // Scroll to bottom after sending
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      } else if (state is MediaError) {
        setState(() {
          _isUploadingMedia = false;
          _uploadProgress = 0.0;
        });

        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload: ${state.message}'),
              backgroundColor: SemanticColors.error,
            ),
          );
        }
      }
    });
  }

  void _handleTypingChanged(bool isTyping) {
    _presenceBloc.add(
      PresenceSendTyping(
        conversationId: widget.conversationUserId,
        isTyping: isTyping,
      ),
    );
  }

  void _handleMessageLongPress(String messageId, String messageText) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: messageText));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<MessageBloc>().add(MessageDelete(messageId));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? ChatColors.darkBackground
          : ChatColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : GrayColors.gray900,
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
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversationUserName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : GrayColors.gray900,
                    ),
                  ),
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
            onPressed: () => _initiateCall(CallType.video),
            tooltip: 'Video call',
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _initiateCall(CallType.voice),
            tooltip: 'Voice call',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_chat') {
                _showClearChatDialog();
              } else if (value == 'settings') {
                _navigateToSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Chat Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_chat',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
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
                  return const MessageShimmerList();
                }

                if (state is MessageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: SemanticColors.error,
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          state.message,
                          style: TextStyle(color: SemanticColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        ElevatedButton(
                          onPressed: () {
                            // Reload messages and reconnect WebSocket
                            _initializeChat();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GuardynColors.guardyn500,
                            foregroundColor: Colors.white,
                          ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_outlined,
                            size: 64,
                            color: GrayColors.gray400,
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark ? GrayColors.gray400 : GrayColors.gray600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            'Send a message to start the conversation!',
                            style: TextStyle(color: GrayColors.gray500),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
                        onLongPress: () => _handleMessageLongPress(
                          message.messageId,
                          message.textContent,
                        ),
                      );
                    },
                  );
                }

                // Initial state
                return const Center(child: Text('Loading messages...'));
              },
            ),
          ),
          // Message input with upload progress
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              final isEnabled =
                  state is! MessageSending && state is! MessageLoading && !_isUploadingMedia;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Upload progress indicator
                  if (_isUploadingMedia)
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: GrayColors.gray300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GuardynColors.guardyn500,
                      ),
                    ),
                  MessageInput(
                    onSend: _handleSendMessage,
                    onTypingChanged: _handleTypingChanged,
                    onMediaSelected: _handleMediaSelected,
                    enabled: isEnabled,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
