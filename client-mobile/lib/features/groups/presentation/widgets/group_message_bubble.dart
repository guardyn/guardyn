import 'package:flutter/material.dart';

import '../../domain/entities/group.dart';

/// Widget for displaying a group message bubble
class GroupMessageBubble extends StatelessWidget {
  final GroupMessage message;
  final bool showSenderName;

  const GroupMessageBubble({
    super.key,
    required this.message,
    this.showSenderName = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSentByMe = message.isSentByMe;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            _buildAvatar(context),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isSentByMe && showSenderName)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      _getSenderDisplayName(),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSentByMe
                        ? theme.primaryColor
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          Radius.circular(isSentByMe ? 16 : 4),
                      bottomRight:
                          Radius.circular(isSentByMe ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.isDeleted)
                        Text(
                          'This message was deleted',
                          style: TextStyle(
                            color: isSentByMe
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Text(
                          message.textContent,
                          style: TextStyle(
                            color: isSentByMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        message.displayTime,
                        style: TextStyle(
                          color: isSentByMe
                              ? Colors.white70
                              : Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSentByMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final displayName = _getSenderDisplayName();
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).primaryColor.withAlpha(178),
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getSenderDisplayName() {
    if (message.senderUsername.isNotEmpty) {
      return message.senderUsername;
    }
    // Fallback to user ID (show first 8 chars)
    final userId = message.senderUserId;
    return userId.length > 8 ? userId.substring(0, 8) : userId;
  }
}
