import 'package:flutter/material.dart';

import '../../domain/entities/presence_info.dart';

/// Widget that displays a colored dot indicating user's online status
class OnlineIndicator extends StatelessWidget {
  /// The presence info to display
  final PresenceInfo? presenceInfo;

  /// Size of the indicator dot
  final double size;

  /// Whether to show a border around the indicator
  final bool showBorder;

  /// Border color (used when showBorder is true)
  final Color borderColor;

  const OnlineIndicator({
    super.key,
    this.presenceInfo,
    this.size = 12.0,
    this.showBorder = true,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = presenceInfo?.statusColor ?? Colors.grey;
    final isOnline = presenceInfo?.isOnline ?? false;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: statusColor,
        border: showBorder
            ? Border.all(
                color: borderColor,
                width: size > 10 ? 2.0 : 1.5,
              )
            : null,
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Widget that wraps an avatar and shows an online indicator badge
class AvatarWithStatus extends StatelessWidget {
  /// The avatar widget to wrap
  final Widget avatar;

  /// The presence info for the status indicator
  final PresenceInfo? presenceInfo;

  /// Size of the avatar
  final double avatarSize;

  /// Size of the status indicator
  final double indicatorSize;

  /// Position of the indicator (bottom-right offset)
  final double indicatorOffset;

  const AvatarWithStatus({
    super.key,
    required this.avatar,
    this.presenceInfo,
    this.avatarSize = 40.0,
    this.indicatorSize = 12.0,
    this.indicatorOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: Stack(
        children: [
          // Avatar
          avatar,
          // Status indicator (bottom-right)
          Positioned(
            right: indicatorOffset,
            bottom: indicatorOffset,
            child: OnlineIndicator(
              presenceInfo: presenceInfo,
              size: indicatorSize,
              showBorder: true,
              borderColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
