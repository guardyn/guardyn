import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../domain/usecases/block_user.dart';
import '../../domain/usecases/delete_conversation.dart';
import '../../domain/usecases/mute_conversation.dart';
import 'media_gallery_page.dart';
import 'search_messages_page.dart';

/// Chat Settings Page for 1-on-1 conversations
/// Allows users to view contact info, manage notifications,
/// and perform actions like blocking or clearing chat history.
class ChatSettingsPage extends StatefulWidget {
  final String userId;
  final String username;
  final String? conversationId;

  const ChatSettingsPage({
    super.key,
    required this.userId,
    required this.username,
    this.conversationId,
  });

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  bool _isMuted = false;
  bool _isMuteLoading = false;
  bool _isBlockLoading = false;
  bool _isDeleteLoading = false;
  late MuteConversation _muteConversation;
  late BlockUser _blockUser;
  late DeleteConversation _deleteConversation;

  @override
  void initState() {
    super.initState();
    _muteConversation = getIt<MuteConversation>();
    _blockUser = getIt<BlockUser>();
    _deleteConversation = getIt<DeleteConversation>();
  }

  Future<void> _toggleMute(bool muted) async {
    if (widget.conversationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot mute: conversation not found')),
      );
      return;
    }

    setState(() => _isMuteLoading = true);

    final result = await _muteConversation(MuteConversationParams(
      conversationId: widget.conversationId!,
      isGroup: false,
      duration: muted ? MuteDuration.forever : MuteDuration.unmute,
    ));

    setState(() => _isMuteLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (muteResult) {
        setState(() => _isMuted = muteResult.muted);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              muteResult.muted
                  ? 'Notifications muted'
                  : 'Notifications enabled',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Settings')),
      body: ListView(
        children: [
          // User Info Header
          _buildUserHeader(context),
          const Divider(),

          // Actions
          _buildActionsList(context),
          const Divider(),

          // Danger Zone
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Username
          Text(widget.username, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),

          // User ID (for debugging/verification)
          Text(
            'ID: ${widget.userId.length > 12 ? '${widget.userId.substring(0, 12)}...' : widget.userId}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList(BuildContext context) {
    return Column(
      children: [
        // Mute Notifications
        SwitchListTile(
          secondary: _isMuteLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.notifications_off),
          title: const Text('Mute Notifications'),
          subtitle: const Text('Stop receiving notifications from this chat'),
          value: _isMuted,
          onChanged: _isMuteLoading ? null : _toggleMute,
        ),

        // Media, Links, Docs
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Media, Links, and Docs'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MediaGalleryPage(
                  conversationId: widget.conversationId ?? '',
                  conversationUserName: widget.username,
                ),
              ),
            );
          },
        ),

        // Search in Conversation
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Search in Conversation'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final navigator = Navigator.of(context);
            final messageId = await navigator.push<String>(
              MaterialPageRoute(
                builder: (_) => SearchMessagesPage(
                  conversationId: widget.conversationId ?? '',
                  conversationUserName: widget.username,
                ),
              ),
            );

            if (messageId != null && mounted) {
              // Return to chat page with message ID to scroll to
              navigator.pop({'scrollToMessageId': messageId});
            }
          },
        ),

        // Encryption Info
        ListTile(
          leading: const Icon(Icons.lock, color: Colors.green),
          title: const Text('Encryption'),
          subtitle: const Text('Messages are end-to-end encrypted'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showEncryptionInfo(context);
          },
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      children: [
        // Block User
        ListTile(
          leading: _isBlockLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.block, color: Colors.orange),
          title: const Text('Block User'),
          subtitle: const Text('Stop receiving messages from this user'),
          enabled: !_isBlockLoading,
          onTap: _isBlockLoading ? null : () => _confirmBlockUser(context),
        ),

        // Clear Chat History
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.red),
          title: const Text('Clear Chat History'),
          subtitle: const Text('Delete all messages in this chat'),
          onTap: () {
            _confirmClearHistory(context);
          },
        ),

        // Delete Conversation
        ListTile(
          leading: _isDeleteLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Conversation'),
          subtitle: const Text('Remove this conversation completely'),
          enabled: !_isDeleteLoading,
          onTap: _isDeleteLoading
              ? null
              : () => _confirmDeleteConversation(context),
        ),
      ],
    );
  }

  void _showEncryptionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.green),
            SizedBox(width: 8),
            Text('End-to-End Encryption'),
          ],
        ),
        content: const Text(
          'Messages in this chat are secured with end-to-end encryption using the Double Ratchet protocol. '
          'Only you and the recipient can read them.\n\n'
          'Your messages are encrypted on your device before being sent and can only be decrypted by the recipient.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmBlockUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User?'),
        content: Text(
          'Block ${widget.username}? You will no longer receive messages from them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performBlockUser();
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performBlockUser() async {
    setState(() => _isBlockLoading = true);

    final result = await _blockUser(widget.userId);

    if (!mounted) return;

    setState(() => _isBlockLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${widget.username} blocked')));
        // Return to conversation list
        Navigator.of(context).pop({'userBlocked': true});
      },
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text(
          'All messages in this chat will be deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Call MessageBloc.add(MessageClearChat)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteConversation(BuildContext context) {
    if (widget.conversationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete: conversation not found')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: const Text(
          'This conversation will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performDeleteConversation();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteConversation() async {
    if (widget.conversationId == null) return;

    setState(() => _isDeleteLoading = true);

    final result = await _deleteConversation(widget.conversationId!);

    if (!mounted) return;

    setState(() => _isDeleteLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Conversation deleted')));
        // Return to conversation list
        Navigator.of(context).pop({'conversationDeleted': true});
      },
    );
  }
}
