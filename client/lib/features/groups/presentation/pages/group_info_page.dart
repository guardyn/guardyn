import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/group.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/member_options_sheet.dart';

/// Page displaying group details, members, and settings
class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final Group? initialGroup;

  const GroupInfoPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.initialGroup,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final _secureStorage = const FlutterSecureStorage();
  String? _currentUserId;
  Group? _group;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _group = widget.initialGroup;
    _loadCurrentUserId();
    _loadGroupDetails();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await _secureStorage.read(key: 'user_id');
    if (mounted) {
      setState(() {
        _currentUserId = userId;
      });
    }
  }

  void _loadGroupDetails() {
    context.read<GroupBloc>().add(GroupLoadDetails(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is GroupLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is GroupDetailsLoaded) {
          setState(() {
            _group = state.group;
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (state is GroupError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        } else if (state is GroupLeft) {
          // Successfully left group - navigate back
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have left the group'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is GroupMemberAdded || state is GroupMemberRemoved) {
          // Reload group details after member changes
          _loadGroupDetails();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group Info'),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadGroupDetails,
                tooltip: 'Refresh',
              ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Leave Group', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_errorMessage != null && _group == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load group details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadGroupDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_group == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildGroupContent(context, _group!);
  }

  Widget _buildGroupContent(BuildContext context, Group group) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Group Header
          _buildGroupHeader(context, group),
          const Divider(),

          // Members Section
          _buildMembersSection(context, group),
          const Divider(),

          // Actions Section
          _buildActionsSection(context, group),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, Group group) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Group Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            child: Text(
              group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
              style: TextStyle(
                fontSize: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Group Name
          Text(
            group.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Member Count
          Text(
            '${group.memberCount} ${group.memberCount == 1 ? 'member' : 'members'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),

          // Created Date
          Text(
            'Created ${_formatDate(group.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, Group group) {
    final isAdmin = _currentUserId != null && group.isAdmin(_currentUserId!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${group.members.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (isAdmin)
                TextButton.icon(
                  onPressed: () => _showAddMemberDialog(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add'),
                ),
            ],
          ),
        ),

        // Member List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: group.members.length,
          itemBuilder: (context, index) {
            final member = group.members[index];
            final isMemberAdmin = member.role == GroupRole.admin;
            final isCurrentUser = _currentUserId != null && member.userId == _currentUserId;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              title: Row(
                children: [
                  Text(member.username),
                  if (isCurrentUser)
                    const Text(' (You)', style: TextStyle(color: Colors.grey)),
                ],
              ),
              subtitle: Text(isMemberAdmin ? 'Admin' : 'Member'),
              trailing: isMemberAdmin
                  ? const Icon(Icons.star, color: Colors.amber, size: 20)
                  : null,
              onLongPress: isAdmin && !isCurrentUser
                  ? () => _showMemberOptions(context, member, group)
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, Group group) {
    final isAdmin = _currentUserId != null && group.isAdmin(_currentUserId!);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Media, Links, Docs (placeholder)
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Media, Links, and Docs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),

          // Mute Notifications (placeholder)
          ListTile(
            leading: const Icon(Icons.notifications_off),
            title: const Text('Mute Notifications'),
            trailing: Switch(
              value: false, // TODO: Implement notification settings
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification settings coming soon')),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Leave Group Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLeaveGroup(context),
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              label: const Text('Leave Group'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),

          // Delete Group (Admin only)
          if (isAdmin) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmDeleteGroup(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'leave':
        _confirmLeaveGroup(context);
        break;
    }
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupBloc>(),
        child: AddMemberDialog(groupId: widget.groupId),
      ),
    );
  }

  void _showMemberOptions(BuildContext context, GroupMember member, Group group) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<GroupBloc>(),
        child: MemberOptionsSheet(
          member: member,
          groupId: widget.groupId,
          isAdmin: _currentUserId != null && group.isAdmin(_currentUserId!),
        ),
      ),
    );
  }

  void _confirmLeaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Group?'),
        content: const Text('You will no longer receive messages from this group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(GroupLeave(widget.groupId));
              // Pop back to group list
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text(
          'This action cannot be undone. All messages will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement group deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group deletion coming soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      final weeks = diff.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (diff.inDays < 365) {
      final months = diff.inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = diff.inDays ~/ 365;
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
