import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

/// Page to display a user's profile when tapped from a group member list
class UserProfilePage extends StatelessWidget {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarMediaId;
  final String? role;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarMediaId,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayNameText = displayName ?? username;

    return Scaffold(
      backgroundColor: isDark ? GrayColors.gray900 : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDark ? GrayColors.gray800 : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? GrayColors.gray800 : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        displayNameText.isNotEmpty
                            ? displayNameText[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display name
                    Text(
                      displayNameText,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),

                    // Username
                    Text(
                      '@$username',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),

                    // Role badge
                    if (role != null && role!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(role!).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getRoleColor(role!).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _formatRole(role!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getRoleColor(role!),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions section
            Container(
              decoration: BoxDecoration(
                color: isDark ? GrayColors.gray800 : Colors.white,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.message,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Send Message'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Return with action to start DM
                      Navigator.pop(context, 'start_dm');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Add to Contacts'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contacts feature coming soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.block, color: Colors.orange),
                    title: const Text('Block User'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Block feature coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info section
            Container(
              decoration: BoxDecoration(
                color: isDark ? GrayColors.gray800 : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'User ID',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SelectableText(
                      userId,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String roleValue) {
    switch (roleValue.toLowerCase()) {
      case 'owner':
        return Colors.amber;
      case 'admin':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatRole(String roleValue) {
    switch (roleValue.toLowerCase()) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      default:
        return 'Member';
    }
  }
}
