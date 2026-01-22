import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
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
  bool _notificationsEnabled = true; // Default: notifications on

  @override
  void initState() {
    super.initState();
    _group = widget.initialGroup;
    _loadCurrentUserId();
    _loadGroupDetails();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled =
            prefs.getBool('group_notifications_${widget.groupId}') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('group_notifications_${widget.groupId}', value);
    if (mounted) {
      setState(() {
        _notificationsEnabled = value;
      });
    }
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? GrayColors.gray900
            : GrayColors.gray50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : GrayColors.gray900,
          title: Text(
            'Group Info',
            style: AppTypography.titleLarge.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : GrayColors.gray900,
            ),
          ),
          actions: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: GuardynColors.guardyn500,
                  ),
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
                PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: SemanticColors.error),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        'Leave Group',
                        style: TextStyle(color: SemanticColors.error),
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_errorMessage != null && _group == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: SemanticColors.error,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Failed to load group details',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? Colors.white : GrayColors.gray900,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                _errorMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: GrayColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space6),
              ElevatedButton.icon(
                onPressed: _loadGroupDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GuardynColors.guardyn500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space6,
                    vertical: AppSpacing.space3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_group == null) {
      return Center(
        child: CircularProgressIndicator(
          color: GuardynColors.guardyn500,
        ),
      );
    }

    return _buildGroupContent(context, _group!);
  }

  Widget _buildGroupContent(BuildContext context, Group group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Group Header
          _buildGroupHeader(context, group),
          Divider(
            color: isDark ? GrayColors.gray700 : GrayColors.gray200,
            height: 1,
          ),

          // Members Section
          _buildMembersSection(context, group),
          Divider(
            color: isDark ? GrayColors.gray700 : GrayColors.gray200,
            height: 1,
          ),

          // Actions Section
          _buildActionsSection(context, group),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, Group group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        children: [
          // Group Avatar with gradient
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GuardynColors.guardyn400,
                  GuardynColors.guardyn600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: GuardynColors.guardyn500.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // Group Name
          Text(
            group.name,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? Colors.white : GrayColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),

          // Member Count
          Text(
            '${group.memberCount} ${group.memberCount == 1 ? 'member' : 'members'}',
            style: AppTypography.bodyMedium.copyWith(
              color: GrayColors.gray500,
            ),
          ),

          // Created Date
          const SizedBox(height: AppSpacing.space1),
          Text(
            'Created ${_formatDate(group.createdAt)}',
            style: AppTypography.bodySmall.copyWith(
              color: GrayColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, Group group) {
    final isAdmin = _currentUserId != null && group.isAdmin(_currentUserId!);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${group.members.length})',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? Colors.white : GrayColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isAdmin)
                TextButton.icon(
                  onPressed: () => _showAddMemberDialog(context),
                  icon: Icon(
                    Icons.person_add,
                    size: 18,
                    color: GuardynColors.guardyn500,
                  ),
                  label: Text(
                    'Add',
                    style: AppTypography.labelMedium.copyWith(
                      color: GuardynColors.guardyn500,
                    ),
                  ),
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

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space1,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: isDark
                    ? GrayColors.gray800.withValues(alpha: 0.5)
                    : GrayColors.gray100.withValues(alpha: 0.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: AppSpacing.space1,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isMemberAdmin
                          ? [
                              const Color(0xFFFFB020),
                              const Color(0xFFFF6B20),
                            ]
                          : [
                              GuardynColors.guardyn400,
                              GuardynColors.guardyn600,
                            ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      member.username,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.white : GrayColors.gray900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isCurrentUser)
                      Text(
                        ' (You)',
                        style: AppTypography.bodySmall.copyWith(
                          color: GrayColors.gray500,
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  isMemberAdmin ? 'Admin' : 'Member',
                  style: AppTypography.bodySmall.copyWith(
                    color: isMemberAdmin
                        ? const Color(0xFFFFB020)
                        : GrayColors.gray500,
                  ),
                ),
                trailing: isMemberAdmin
                    ? const Icon(Icons.star, color: Color(0xFFFFB020), size: 20)
                    : null,
                onLongPress: isAdmin && !isCurrentUser
                    ? () => _showMemberOptions(context, member, group)
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, Group group) {
    final isAdmin = _currentUserId != null && group.isAdmin(_currentUserId!);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        children: [
          // Media, Links, Docs (placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? GrayColors.gray800.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isDark
                        ? GrayColors.gray700.withValues(alpha: 0.3)
                        : GrayColors.gray200.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: GuardynColors.guardyn500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: GuardynColors.guardyn500,
                    ),
                  ),
                  title: Text(
                    'Media, Links, and Docs',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white : GrayColors.gray900,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: GrayColors.gray400,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Coming soon',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: GrayColors.gray800,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space3),

          // Notifications Toggle
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? GrayColors.gray800.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isDark
                        ? GrayColors.gray700.withValues(alpha: 0.3)
                        : GrayColors.gray200.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: _notificationsEnabled
                          ? GuardynColors.guardyn500.withValues(alpha: 0.1)
                          : GrayColors.gray500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      _notificationsEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: _notificationsEnabled
                          ? GuardynColors.guardyn500
                          : GrayColors.gray500,
                    ),
                  ),
                  title: Text(
                    'Notifications',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white : GrayColors.gray900,
                    ),
                  ),
                  subtitle: Text(
                    _notificationsEnabled ? 'Enabled' : 'Muted',
                    style: AppTypography.bodySmall.copyWith(
                      color: GrayColors.gray500,
                    ),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeColor: GuardynColors.guardyn500,
                    onChanged: _toggleNotifications,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space6),

          // Leave Group Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLeaveGroup(context),
              icon: Icon(Icons.exit_to_app, color: SemanticColors.error),
              label: Text(
                'Leave Group',
                style: AppTypography.labelLarge.copyWith(
                  color: SemanticColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: SemanticColors.error,
                side: BorderSide(color: SemanticColors.error),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),

          // Delete Group (Admin only)
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.space2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmDeleteGroup(context),
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  'Delete Group',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SemanticColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? GrayColors.gray800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'Leave Group?',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? Colors.white : GrayColors.gray900,
          ),
        ),
        content: Text(
          'You will no longer receive messages from this group.',
          style: AppTypography.bodyMedium.copyWith(
            color: GrayColors.gray500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: GrayColors.gray500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(GroupLeave(widget.groupId));
              // Pop back to group list
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Leave',
              style: AppTypography.labelLarge.copyWith(
                color: SemanticColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? GrayColors.gray800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'Delete Group?',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? Colors.white : GrayColors.gray900,
          ),
        ),
        content: Text(
          'This action cannot be undone. All messages will be permanently deleted.',
          style: AppTypography.bodyMedium.copyWith(
            color: GrayColors.gray500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: GrayColors.gray500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(GroupDelete(widget.groupId));
              // Pop back to group list
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(
                color: SemanticColors.error,
              ),
            ),
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
