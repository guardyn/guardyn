import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onLongPress;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSentByMe = message.isSentByMe;
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isSentByMe
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message text
              Text(
                message.textContent,
                style: TextStyle(
                  color: isSentByMe
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              // Timestamp and delivery status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isSentByMe
                          ? theme.colorScheme.onPrimary.withOpacity(0.7)
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  if (isSentByMe) ...[
                    const SizedBox(width: 4),
                    _buildDeliveryStatusIcon(message.deliveryStatus, theme),
                  ],
                ],
              ),
            ],
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
      return '${DateFormat('EEE HH:mm').format(timestamp)}';
    } else {
      // Older - show date and time
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  Widget _buildDeliveryStatusIcon(DeliveryStatus status, ThemeData theme) {
    IconData icon;
    Color color = theme.colorScheme.onPrimary.withOpacity(0.7);

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
        color = Colors.redAccent;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }
}
