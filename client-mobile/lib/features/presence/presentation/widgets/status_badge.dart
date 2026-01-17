import 'package:flutter/material.dart';

import '../../domain/entities/presence_info.dart';

/// Widget that displays a status badge with icon and text
class StatusBadge extends StatelessWidget {
  /// The presence status to display
  final PresenceStatus status;

  /// Optional custom text (overrides default status text)
  final String? customText;

  /// Badge size (small, medium, large)
  final StatusBadgeSize size;

  /// Whether to show the icon
  final bool showIcon;

  /// Whether to show the text
  final bool showText;

  const StatusBadge({
    super.key,
    required this.status,
    this.customText,
    this.size = StatusBadgeSize.medium,
    this.showIcon = true,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final iconSize = _getIconSize();
    final fontSize = _getFontSize();
    final padding = _getPadding();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              colors.icon,
              size: iconSize,
              color: colors.iconColor,
            ),
            if (showText) const SizedBox(width: 4),
          ],
          if (showText)
            Text(
              customText ?? _getStatusText(),
              style: TextStyle(
                fontSize: fontSize,
                color: colors.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  _StatusColors _getColors() {
    switch (status) {
      case PresenceStatus.online:
        return _StatusColors(
          backgroundColor: Colors.green.withOpacity(0.1),
          borderColor: Colors.green.withOpacity(0.3),
          iconColor: Colors.green,
          textColor: Colors.green[700]!,
          icon: Icons.circle,
        );
      case PresenceStatus.away:
        return _StatusColors(
          backgroundColor: Colors.orange.withOpacity(0.1),
          borderColor: Colors.orange.withOpacity(0.3),
          iconColor: Colors.orange,
          textColor: Colors.orange[700]!,
          icon: Icons.schedule,
        );
      case PresenceStatus.doNotDisturb:
        return _StatusColors(
          backgroundColor: Colors.red.withOpacity(0.1),
          borderColor: Colors.red.withOpacity(0.3),
          iconColor: Colors.red,
          textColor: Colors.red[700]!,
          icon: Icons.do_not_disturb_on,
        );
      case PresenceStatus.invisible:
        return _StatusColors(
          backgroundColor: Colors.grey.withOpacity(0.1),
          borderColor: Colors.grey.withOpacity(0.3),
          iconColor: Colors.grey,
          textColor: Colors.grey[700]!,
          icon: Icons.visibility_off,
        );
      case PresenceStatus.offline:
        return _StatusColors(
          backgroundColor: Colors.grey.withOpacity(0.1),
          borderColor: Colors.grey.withOpacity(0.3),
          iconColor: Colors.grey,
          textColor: Colors.grey[700]!,
          icon: Icons.circle_outlined,
        );
    }
  }

  String _getStatusText() {
    switch (status) {
      case PresenceStatus.online:
        return 'Online';
      case PresenceStatus.away:
        return 'Away';
      case PresenceStatus.doNotDisturb:
        return 'Do Not Disturb';
      case PresenceStatus.invisible:
        return 'Invisible';
      case PresenceStatus.offline:
        return 'Offline';
    }
  }

  double _getIconSize() {
    switch (size) {
      case StatusBadgeSize.small:
        return 8;
      case StatusBadgeSize.medium:
        return 10;
      case StatusBadgeSize.large:
        return 14;
    }
  }

  double _getFontSize() {
    switch (size) {
      case StatusBadgeSize.small:
        return 10;
      case StatusBadgeSize.medium:
        return 12;
      case StatusBadgeSize.large:
        return 14;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case StatusBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case StatusBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case StatusBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }
}

enum StatusBadgeSize { small, medium, large }

class _StatusColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _StatusColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
