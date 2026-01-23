import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../media/presentation/bloc/media_bloc.dart';
import '../../../media/presentation/bloc/media_event.dart';
import '../../../media/presentation/bloc/media_state.dart';
import '../../../media/presentation/widgets/media_picker_sheet.dart';
import '../../domain/entities/group.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import '../widgets/group_message_bubble.dart';
import '../widgets/group_message_input.dart';
import '../widgets/group_typing_indicator.dart';
import 'group_info_page.dart';

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
  final _secureStorage = const FlutterSecureStorage();
  late GroupBloc _groupBloc;
  late MediaBloc _mediaBloc;
  bool _isUploadingMedia = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _groupBloc = getIt<GroupBloc>();
    _mediaBloc = getIt<MediaBloc>();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Load messages first
    _groupBloc.add(GroupLoadMessages(groupId: widget.groupId));
    _groupBloc.add(GroupSetActive(widget.groupId));

    // Connect WebSocket for real-time messaging
    final accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken != null && accessToken.isNotEmpty) {
      _groupBloc.add(GroupConnectWebSocket(accessToken: accessToken));
      _groupBloc.add(GroupSubscribeWebSocket(groupId: widget.groupId));
    } else {
      // Fallback to polling if no token
      _groupBloc.add(GroupStartPolling(groupId: widget.groupId));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mediaBloc.close();
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

  void _handleMediaSelected(MediaPickerResult result) {
    setState(() {
      _isUploadingMedia = true;
      _uploadProgress = 0.0;
    });

    // Upload media
    _mediaBloc.add(MediaUploadRequested(
      filePath: result.filePath,
      mimeType: result.mimeType,
      conversationId: widget.groupId,
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
        _groupBloc.add(GroupSendMessage(
          groupId: widget.groupId,
          textContent: '', // Caption can be added later
          metadata: {
            'media_id': state.media.id,
            'media_type': state.media.type.name,
            'filename': state.media.filename,
            'mime_type': state.media.mimeType,
            'size_bytes': state.media.sizeBytes.toString(),
          },
        ));

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

  void _navigateToGroupInfo(BuildContext context) {
    // Create a simple Group object for the info page
    // In a full implementation, this would be fetched from the repository
    final group = Group(
      groupId: widget.groupId,
      name: widget.groupName,
      creatorUserId: '', // Unknown without fetching
      members: const [], // Will be populated when we implement GetGroupById
      createdAt: DateTime.now(),
      memberCount: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (navContext) => BlocProvider.value(
          value: context.read<GroupBloc>(),
          child: GroupInfoPage(
            groupId: widget.groupId,
            groupName: widget.groupName,
            initialGroup: group,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _groupBloc,
      child: Builder(
        builder: (context) => PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              context.read<GroupBloc>().add(const GroupDisconnectWebSocket());
              context.read<GroupBloc>().add(const GroupStopPolling());
              context.read<GroupBloc>().add(const GroupSetActive(null));
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? ChatColors.darkBackground
                : ChatColors.lightBackground,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? GrayColors.gray900.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
              surfaceTintColor: Colors.transparent,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : GrayColors.gray900,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: AppTypography.titleMedium.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : GrayColors.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  BlocBuilder<GroupBloc, GroupState>(
                    builder: (context, state) {
                      if (state is GroupMessagesLoaded) {
                        return Text(
                          'Group chat',
                          style: AppTypography.bodySmall.copyWith(
                            color: GrayColors.gray500,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.group,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : GrayColors.gray700,
                  ),
                  onPressed: () {
                    _navigateToGroupInfo(context);
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
                            backgroundColor: SemanticColors.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is GroupLoading && state.messages.isEmpty) {
                        return const MessageShimmerList(itemCount: 8);
                      }

                      final messages = state is GroupMessagesLoaded
                          ? state.messages
                          : state is GroupMessageSending
                              ? state.messages
                              : state is GroupError
                                  ? state.messages
                                  : <dynamic>[];

                      if (messages.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space2,
                          vertical: AppSpacing.space3,
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
                    final isLoading = state is GroupMessageSending || _isUploadingMedia;
                    
                    // Get typing usernames from state
                    final typingUsernames = state is GroupTypingUsersUpdated
                        ? state.typingUsernames
                        : _groupBloc.getTypingUsernames(widget.groupId);
                    
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Typing indicator
                        GroupTypingIndicator(typingUsernames: typingUsernames),
                        // Upload progress indicator
                        if (_isUploadingMedia)
                          LinearProgressIndicator(
                            value: _uploadProgress,
                            backgroundColor: GrayColors.gray300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              GuardynColors.guardyn500,
                            ),
                          ),
                        GroupMessageInput(
                          onSend: (text) => _handleSendMessage(context, text),
                          onMediaSelected: _handleMediaSelected,
                          isLoading: isLoading,
                          onTypingChanged: (isTyping) {
                            context.read<GroupBloc>().add(
                              GroupSendTypingIndicator(
                                groupId: widget.groupId,
                                isTyping: isTyping,
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: GrayColors.gray400,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'No messages yet',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? GrayColors.gray300 : GrayColors.gray600,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Start the conversation!',
              style: AppTypography.bodyMedium.copyWith(
                color: GrayColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
