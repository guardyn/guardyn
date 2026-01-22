/// Shimmer Loading Widgets
///
/// Reusable shimmer loading animations for list views and cards.
/// Used as skeleton placeholder while data is loading.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shimmer loading widget for conversation list items
class ConversationShimmerList extends StatelessWidget {
  final int itemCount;

  const ConversationShimmerList({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      itemBuilder: (context, index) => _buildShimmerItem(isDark),
    );
  }

  Widget _buildShimmerItem(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? GrayColors.gray800 : GrayColors.gray200,
      highlightColor: isDark ? GrayColors.gray700 : GrayColors.gray100,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name placeholder
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  // Message placeholder
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            // Timestamp placeholder
            Container(
              height: 12,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading widget for message bubbles
class MessageShimmerList extends StatelessWidget {
  final int itemCount;

  const MessageShimmerList({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      reverse: true,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      itemBuilder: (context, index) => _buildShimmerMessage(isDark, index),
    );
  }

  Widget _buildShimmerMessage(bool isDark, int index) {
    final isRight = index.isEven;
    final width = [0.6, 0.45, 0.7, 0.5, 0.55, 0.65][index % 6];

    return Shimmer.fromColors(
      baseColor: isDark ? GrayColors.gray800 : GrayColors.gray200,
      highlightColor: isDark ? GrayColors.gray700 : GrayColors.gray100,
      child: Align(
        alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: isRight ? 80 : AppSpacing.space4,
            right: isRight ? AppSpacing.space4 : 80,
            top: AppSpacing.space1,
            bottom: AppSpacing.space1,
          ),
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: 180 * width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Container(
                height: 10,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic shimmer card placeholder
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsets margin;

  const ShimmerCard({
    super.key,
    this.height = 72,
    this.width,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppSpacing.space4,
      vertical: AppSpacing.space2,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? GrayColors.gray800 : GrayColors.gray200,
      highlightColor: isDark ? GrayColors.gray700 : GrayColors.gray100,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
