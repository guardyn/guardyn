import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isSentByMe = message.isSentByMe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: isSentByMe ? 60 : AppSpacing.space2,
            right: isSentByMe ? AppSpacing.space2 : 60,
            top: AppSpacing.space1,
            bottom: AppSpacing.space1,
          ),
          decoration: BoxDecoration(
            color: isSentByMe
                ? GuardynColors.guardyn500
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.7)),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.xl),
              topRight: const Radius.circular(AppRadius.xl),
              bottomLeft: Radius.circular(isSentByMe ? AppRadius.xl : AppRadius.sm),
              bottomRight: Radius.circular(isSentByMe ? AppRadius.sm : AppRadius.xl),
            ),
            border: isSentByMe
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : GrayColors.gray200.withOpacity(0.5),
                  ),
            boxShadow: AppShadows.sm,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.xl),
              topRight: const Radius.circular(AppRadius.xl),
              bottomLeft: Radius.circular(isSentByMe ? AppRadius.xl : AppRadius.sm),
              bottomRight: Radius.circular(isSentByMe ? AppRadius.sm : AppRadius.xl),
            ),
            child: BackdropFilter(
              filter: isSentByMe
                  ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                  : ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space2_5,
                  horizontal: AppSpacing.space3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message text
                    Text(
                      message.textContent,
                      style: TextStyle(
                        color: isSentByMe
                            ? Colors.white
                            : (isDark ? Colors.white : GrayColors.gray900),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    // Timestamp and delivery status
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: isSentByMe
                                ? Colors.white.withOpacity(0.7)
                                : GrayColors.gray500,
                            fontSize: 11,
                          ),
                        ),
                        if (isSentByMe) ...[
                          const SizedBox(width: AppSpacing.space1),
                          _buildDeliveryStatusIcon(message.deliveryStatus),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time only
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
    } else if (difference.inDays < 7) {
      // Within a week - show day name and time
      return DateFormat('EEE HH:mm').format(timestamp);
    } else {
      // Older - show date and time
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  Widget _buildDeliveryStatusIcon(DeliveryStatus status) {
    IconData icon;
    Color color = Colors.white.withOpacity(0.7);

    switch (status) {
      case DeliveryStatus.pending:
        icon = Icons.access_time;
        break;
      case DeliveryStatus.sent:
        icon = Icons.check;
        break;
      case DeliveryStatus.delivered:
        icon = Icons.done_all;
        break;
      case DeliveryStatus.read:
        icon = Icons.done_all;
        color = Colors.lightBlueAccent;
        break;
      case DeliveryStatus.failed:
        icon = Icons.error_outline;
        color = SemanticColors.error;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }
}
