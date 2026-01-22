import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/entities/group.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import 'group_chat_page.dart';
import 'group_create_page.dart';

/// Page showing list of user's groups
///
/// Displays all groups the user belongs to with glassmorphism styling.
class GroupListPage extends StatelessWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupBloc>()..add(const GroupLoadAll()),
      child: const _GroupListView(),
    );
  }
}

class _GroupListView extends StatelessWidget {
  const _GroupListView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? GrayColors.gray900 : GrayColors.gray50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Groups',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? Colors.white : GrayColors.gray900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? Colors.white : GrayColors.gray900,
            ),
            onPressed: () => _navigateToCreateGroup(context),
          ),
        ],
      ),
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const ConversationShimmerList(itemCount: 6);
          }

          if (state is GroupError) {
            return _buildErrorState(context, state.message);
          }

          if (state is GroupListLoaded) {
            if (state.groups.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildGroupList(context, state.groups);
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context, isDark),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.md,
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToCreateGroup(context),
        backgroundColor: GuardynColors.guardyn500,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.group_add),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
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
              'Error',
              style: AppTypography.headlineMedium.copyWith(
                color: isDark ? Colors.white : GrayColors.gray900,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: GrayColors.gray500,
              ),
            ),
            const SizedBox(height: AppSpacing.space6),
            ElevatedButton.icon(
              onPressed: () {
                context.read<GroupBloc>().add(const GroupLoadAll());
              },
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

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: GrayColors.gray400,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'No groups yet',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? GrayColors.gray300 : GrayColors.gray600,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Create a group to start chatting',
              style: AppTypography.bodyMedium.copyWith(
                color: GrayColors.gray500,
              ),
            ),
            const SizedBox(height: AppSpacing.space6),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateGroup(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Group'),
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

  Widget _buildGroupList(BuildContext context, List<Group> groups) {
    return RefreshIndicator(
      color: GuardynColors.guardyn500,
      onRefresh: () async {
        context.read<GroupBloc>().add(const GroupLoadAll());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return GroupItemCard(group: group);
        },
      ),
    );
  }

  void _navigateToCreateGroup(BuildContext context) {
    final bloc = context.read<GroupBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupCreatePage(),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the list after creating a group
        bloc.add(const GroupLoadAll());
      }
    });
  }
}

/// Group item card with glassmorphism styling
///
/// Displays a single group with avatar, name, member count, and last message.
class GroupItemCard extends StatelessWidget {
  final Group group;

  const GroupItemCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _navigateToGroupChat(context),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: isDark
                    ? GrayColors.gray800.withOpacity(0.6)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : GrayColors.gray300.withOpacity(0.3),
                ),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  _buildAvatar(isDark),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: _buildContent(context, isDark),
                  ),
                  _buildTrailing(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 48,
      height: 48,
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
            color: GuardynColors.guardyn500.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          group.name,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : GrayColors.gray900,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.space1),
        Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 14,
              color: GrayColors.gray500,
            ),
            const SizedBox(width: AppSpacing.space1),
            Text(
              '${group.memberCount} members',
              style: AppTypography.bodySmall.copyWith(
                color: GrayColors.gray500,
              ),
            ),
          ],
        ),
        if (group.lastMessage != null) ...[
          const SizedBox(height: AppSpacing.space1),
          Text(
            group.lastMessage!.textContent,
            style: AppTypography.bodySmall.copyWith(
              color: GrayColors.gray500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing(bool isDark) {
    if (group.lastMessage == null) {
      return const SizedBox.shrink();
    }

    return Text(
      group.lastMessage!.displayTime,
      style: AppTypography.labelSmall.copyWith(
        color: GrayColors.gray400,
      ),
    );
  }

  void _navigateToGroupChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatPage(
          groupId: group.groupId,
          groupName: group.name,
        ),
      ),
    );
  }
}
