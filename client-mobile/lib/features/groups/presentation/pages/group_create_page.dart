import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/di/injection.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

/// Page for creating a new group
class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _membersController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  List<String> _parseMembers(String input) {
    return input
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _handleCreate(BuildContext blocContext) {
    if (!_formKey.currentState!.validate()) return;

    final memberUserIds = _parseMembers(_membersController.text);

    blocContext.read<GroupBloc>().add(GroupCreate(
          name: _nameController.text.trim(),
          memberUserIds: memberUserIds,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => getIt<GroupBloc>(),
      child: Builder(
        builder: (blocContext) => Scaffold(
          backgroundColor: isDark ? GrayColors.gray900 : GrayColors.gray50,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Create Group',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? Colors.white : GrayColors.gray900,
              ),
            ),
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : GrayColors.gray900,
            ),
          ),
          body: BlocConsumer<GroupBloc, GroupState>(
            listener: (context, state) {
              if (state is GroupCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Group "${state.group.name}" created!',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: SemanticColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                );
                Navigator.pop(context, true);
              }
              if (state is GroupError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: SemanticColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                );
              }
              if (state is GroupLoading) {
                setState(() => _isLoading = true);
              }
            },
            builder: (context, state) {
              return _buildForm(blocContext, isDark);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext blocContext, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group icon with gradient
            Center(
              child: Container(
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
                child: const Icon(
                  Icons.group,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space6),

            // Group name field with glassmorphism
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? GrayColors.gray800.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isDark
                          ? GrayColors.gray700.withValues(alpha: 0.3)
                          : GrayColors.gray200.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white : GrayColors.gray900,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      labelStyle: AppTypography.bodyMedium.copyWith(
                        color: GrayColors.gray500,
                      ),
                      hintText: 'Enter group name',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: GrayColors.gray400,
                      ),
                      prefixIcon: Icon(
                        Icons.edit,
                        color: GuardynColors.guardyn500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space4,
                        vertical: AppSpacing.space3,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a group name';
                      }
                      if (value.trim().length < 3) {
                        return 'Group name must be at least 3 characters';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),

            // Members field with glassmorphism
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? GrayColors.gray800.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isDark
                          ? GrayColors.gray700.withValues(alpha: 0.3)
                          : GrayColors.gray200.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TextFormField(
                    controller: _membersController,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white : GrayColors.gray900,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Members (optional)',
                      labelStyle: AppTypography.bodyMedium.copyWith(
                        color: GrayColors.gray500,
                      ),
                      hintText: 'Enter user IDs separated by commas',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: GrayColors.gray400,
                      ),
                      prefixIcon: Icon(
                        Icons.people,
                        color: GuardynColors.guardyn500,
                      ),
                      helperText: 'Leave empty to create a group with just yourself',
                      helperStyle: AppTypography.bodySmall.copyWith(
                        color: GrayColors.gray500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space4,
                        vertical: AppSpacing.space3,
                      ),
                    ),
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space2),

            // Info card with glassmorphism
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: GuardynColors.guardyn500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: GuardynColors.guardyn500.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: GuardynColors.guardyn600,
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Text(
                          'You will be added as the group admin. '
                          'You can add more members later.',
                          style: AppTypography.bodySmall.copyWith(
                            color: GuardynColors.guardyn700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space8),

            // Create button with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: _isLoading
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GuardynColors.guardyn500,
                          GuardynColors.guardyn600,
                        ],
                      ),
                color: _isLoading ? GrayColors.gray400 : null,
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: GuardynColors.guardyn500.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleCreate(blocContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Create Group',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
