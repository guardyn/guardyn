import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../domain/entities/group.dart';
import 'group_chat_media_bubble.dart';

/// Widget for displaying a group message bubble with glassmorphism styling
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            _buildAvatar(context),
            const SizedBox(width: AppSpacing.space2),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isSentByMe && showSenderName)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.space1,
                      bottom: AppSpacing.space1,
                    ),
                    child: Text(
                      _getSenderDisplayName(),
                      style: AppTypography.labelSmall.copyWith(
                        color: GuardynColors.guardyn600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                _buildMessageBubble(context, isSentByMe, isDark),
              ],
            ),
          ),
          if (isSentByMe) const SizedBox(width: AppSpacing.space2),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, bool isSentByMe, bool isDark) {
    if (isSentByMe) {
      // Sent messages - primary color with shadow
      return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GuardynColors.guardyn500,
              GuardynColors.guardyn600,
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.xl),
            topRight: const Radius.circular(AppRadius.xl),
            bottomLeft: const Radius.circular(AppRadius.xl),
            bottomRight: const Radius.circular(AppRadius.sm),
          ),
          boxShadow: [
            BoxShadow(
              color: GuardynColors.guardyn500.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildMessageContent(isSentByMe, isDark),
      );
    } else {
      // Received messages - glassmorphism effect
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.xl),
          topRight: const Radius.circular(AppRadius.xl),
          bottomLeft: const Radius.circular(AppRadius.sm),
          bottomRight: const Radius.circular(AppRadius.xl),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.xl),
                topRight: const Radius.circular(AppRadius.xl),
                bottomLeft: const Radius.circular(AppRadius.sm),
                bottomRight: const Radius.circular(AppRadius.xl),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
            child: _buildMessageContent(isSentByMe, isDark),
          ),
        ),
      );
    }
  }

  Widget _buildMessageContent(bool isSentByMe, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media attachment (if present)
        if (message.hasMedia)
          GroupChatMediaBubble(
            message: message,
            isSentByMe: isSentByMe,
          ),
        if (message.isDeleted)
          Text(
            'This message was deleted',
            style: AppTypography.bodyMedium.copyWith(
              color: isSentByMe
                  ? Colors.white.withOpacity(0.7)
                  : GrayColors.gray500,
              fontStyle: FontStyle.italic,
            ),
          )
        else if (message.textContent.isNotEmpty)
          Text(
            message.textContent,
            style: AppTypography.bodyMedium.copyWith(
              color: isSentByMe
                  ? Colors.white
                  : (isDark ? Colors.white : GrayColors.gray900),
            ),
          ),
        SizedBox(height: message.hasMedia && message.textContent.isEmpty 
            ? AppSpacing.space0_5 
            : AppSpacing.space1),
        Text(
          message.displayTime,
          style: AppTypography.labelSmall.copyWith(
            color: isSentByMe
                ? Colors.white.withOpacity(0.7)
                : GrayColors.gray400,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final displayName = _getSenderDisplayName();
    return Container(
      width: 32,
      height: 32,
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
      ),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
