import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/group.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

/// Bottom sheet showing options for a group member (remove, make admin, etc.)
class MemberOptionsSheet extends StatelessWidget {
  final GroupMember member;
  final String groupId;
  final bool isAdmin;

  const MemberOptionsSheet({
    super.key,
    required this.member,
    required this.groupId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is GroupMemberRemoved) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member.username} removed from group'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is GroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Member info header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        member.username.isNotEmpty
                            ? member.username[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.username,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          member.role == GroupRole.admin ? 'Admin' : 'Member',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),

              // View Profile
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile view coming soon')),
                  );
                },
              ),

              // Message privately
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Message'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Direct message feature coming soon')),
                  );
                },
              ),

              // Admin options
              if (isAdmin) ...[
                const Divider(),

                // Make admin / Remove admin
                if (member.role != GroupRole.admin)
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('Make Admin'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Admin management coming soon')),
                      );
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.star_border),
                    title: const Text('Remove Admin'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Admin management coming soon')),
                      );
                    },
                  ),

                // Remove from group
                ListTile(
                  leading: const Icon(Icons.person_remove, color: Colors.red),
                  title: const Text(
                    'Remove from Group',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _confirmRemoveMember(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text(
          'Are you sure you want to remove ${member.username} from this group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              context.read<GroupBloc>().add(GroupRemoveMember(
                    groupId: groupId,
                    memberUserId: member.userId,
                  ));
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
