import 'package:flutter/material.dart';

/// Chat Settings Page for 1-on-1 conversations
/// Allows users to view contact info, manage notifications,
/// and perform actions like blocking or clearing chat history.
class ChatSettingsPage extends StatelessWidget {
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
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Username
          Text(username, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),

          // User ID (for debugging/verification)
          Text(
            'ID: ${userId.length > 12 ? '${userId.substring(0, 12)}...' : userId}',
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
          secondary: const Icon(Icons.notifications_off),
          title: const Text('Mute Notifications'),
          subtitle: const Text('Stop receiving notifications from this chat'),
          value: false, // TODO: Get from settings
          onChanged: (value) {
            // TODO: Implement mute
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Coming soon')));
          },
        ),

        // Media, Links, Docs
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Media, Links, and Docs'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to media gallery
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Coming soon')));
          },
        ),

        // Search in Conversation
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Search in Conversation'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement search
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Coming soon')));
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
          leading: const Icon(Icons.block, color: Colors.orange),
          title: const Text('Block User'),
          subtitle: const Text('Stop receiving messages from this user'),
          onTap: () {
            _confirmBlockUser(context);
          },
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
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Conversation'),
          subtitle: const Text('Remove this conversation completely'),
          onTap: () {
            _confirmDeleteConversation(context);
          },
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
          'Block $username? You will no longer receive messages from them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement block user API call
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('User blocked')));
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement delete conversation API call
              Navigator.pop(context); // Return to conversation list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
