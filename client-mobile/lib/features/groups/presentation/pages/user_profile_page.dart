import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../contacts/presentation/bloc/contacts_bloc.dart';
import '../../../messaging/domain/usecases/block_user.dart';

/// Page to display a user's profile when tapped from a group member list
class UserProfilePage extends StatefulWidget {
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
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final ContactsBloc _contactsBloc;
  late final BlockUser _blockUser;
  late final UnblockUser _unblockUser;
  late final GetBlockedUsers _getBlockedUsers;
  
  bool _isContact = false;
  bool _isLoading = false;
  bool _isBlocked = false;
  bool _isBlockLoading = false;

  @override
  void initState() {
    super.initState();
    _contactsBloc = getIt<ContactsBloc>();
    _blockUser = getIt<BlockUser>();
    _unblockUser = getIt<UnblockUser>();
    _getBlockedUsers = getIt<GetBlockedUsers>();
    _checkIsContact();
    _checkIsBlocked();
  }

  Future<void> _checkIsContact() async {
    _contactsBloc.add(CheckIsContact(widget.userId));
  }

  Future<void> _checkIsBlocked() async {
    final result = await _getBlockedUsers();
    result.fold(
      (failure) => debugPrint('Failed to get blocked users: $failure'),
      (blockedUsers) {
        final isBlocked = blockedUsers.any((u) => u.userId == widget.userId);
        if (mounted) {
          setState(() => _isBlocked = isBlocked);
        }
      },
    );
  }

  void _addToContacts() {
    setState(() => _isLoading = true);
    _contactsBloc.add(AddContact(userId: widget.userId));
  }

  void _removeFromContacts() {
    setState(() => _isLoading = true);
    _contactsBloc.add(RemoveContact(widget.userId));
  }

  Future<void> _toggleBlock() async {
    setState(() => _isBlockLoading = true);
    
    if (_isBlocked) {
      final result = await _unblockUser(widget.userId);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to unblock user: $failure')),
            );
          }
        },
        (_) {
          if (mounted) {
            setState(() => _isBlocked = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User unblocked')),
            );
          }
        },
      );
    } else {
      final result = await _blockUser(widget.userId);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to block user: $failure')),
            );
          }
        },
        (_) {
          if (mounted) {
            setState(() => _isBlocked = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User blocked')),
            );
          }
        },
      );
    }
    
    if (mounted) {
      setState(() => _isBlockLoading = false);
    }
  }

  @override
  void dispose() {
    _contactsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayNameText = widget.displayName ?? widget.username;

    return BlocProvider.value(
      value: _contactsBloc,
      child: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is IsContactResult && state.userId == widget.userId) {
            setState(() {
              _isContact = state.isContact;
              _isLoading = false;
            });
          } else if (state is ContactAdded &&
              state.contact.userId == widget.userId) {
            setState(() {
              _isContact = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact added successfully')),
            );
          } else if (state is ContactRemoved && state.userId == widget.userId) {
            setState(() {
              _isContact = false;
              _isLoading = false;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Contact removed')));
          } else if (state is ContactAddError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add contact: ${state.message}'),
              ),
            );
          } else if (state is ContactRemoveError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to remove contact: ${state.message}'),
              ),
            );
          }
        },
        child: Scaffold(
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
                          '@${widget.username}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),

                    // Role badge
                        if (widget.role != null && widget.role!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                              color: _getRoleColor(
                                widget.role!,
                              ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                                color: _getRoleColor(
                                  widget.role!,
                                ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                              _formatRole(widget.role!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                                color: _getRoleColor(widget.role!),
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
                        leading: Icon(
                          _isContact ? Icons.person_remove : Icons.person_add,
                          color: _isContact ? Colors.red : null,
                        ),
                        title: Text(
                          _isContact
                              ? 'Remove from Contacts'
                              : 'Add to Contacts',
                        ),
                        trailing: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: _isLoading
                            ? null
                            : () {
                                if (_isContact) {
                                  _removeFromContacts();
                                } else {
                                  _addToContacts();
                                }
                              },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      _isBlocked ? Icons.check_circle : Icons.block,
                      color: _isBlocked ? Colors.green : Colors.orange,
                    ),
                    title: Text(_isBlocked ? 'Unblock User' : 'Block User'),
                    trailing: _isBlockLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _isBlockLoading ? null : _toggleBlock,
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
                          widget.userId,
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
