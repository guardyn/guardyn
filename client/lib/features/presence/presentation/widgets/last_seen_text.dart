import 'package:flutter/material.dart';

import '../../domain/entities/presence_info.dart';

/// Widget that displays last seen time or online status
class LastSeenText extends StatelessWidget {
  /// The presence info to display
  final PresenceInfo? presenceInfo;

  /// Text style
  final TextStyle? style;

  /// Prefix text (e.g., "Last seen: ")
  final String? prefix;

  /// Whether to show "online" text when user is online
  final bool showOnlineText;

  const LastSeenText({
    super.key,
    this.presenceInfo,
    this.style,
    this.prefix,
    this.showOnlineText = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
    );

    String text;
    TextStyle effectiveStyle = style ?? defaultStyle;

    if (presenceInfo == null) {
      text = 'offline';
    } else if (presenceInfo!.isOnline) {
      if (showOnlineText) {
        text = 'online';
        effectiveStyle = effectiveStyle.copyWith(
          color: Colors.green,
          fontWeight: FontWeight.w500,
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      text = presenceInfo!.lastSeenText;
    }

    final displayText = prefix != null ? '$prefix$text' : text;

    return Text(displayText, style: effectiveStyle);
  }
}

/// Widget that displays user status in a more detailed format
class StatusText extends StatelessWidget {
  /// The presence info to display
  final PresenceInfo? presenceInfo;

  /// Text style
  final TextStyle? style;

  const StatusText({
    super.key,
    this.presenceInfo,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
    );

    if (presenceInfo == null) {
      return Text('Offline', style: style ?? defaultStyle);
    }

    String text;
    Color? textColor;

    switch (presenceInfo!.status) {
      case PresenceStatus.online:
        text = 'Online';
        textColor = Colors.green;
        break;
      case PresenceStatus.away:
        text = 'Away';
        textColor = Colors.orange;
        break;
      case PresenceStatus.doNotDisturb:
        text = 'Do Not Disturb';
        textColor = Colors.red;
        break;
      case PresenceStatus.invisible:
        text = 'Invisible';
        textColor = Colors.grey;
        break;
      case PresenceStatus.offline:
        text = presenceInfo!.lastSeenText;
        textColor = Colors.grey;
        break;
    }

    return Text(
      text,
      style: (style ?? defaultStyle).copyWith(color: textColor),
    );
  }
}
