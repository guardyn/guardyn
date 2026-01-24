import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar widget for displaying user/group profile pictures
///
/// Features:
/// - Displays initials when no image available
/// - Cached network image loading
/// - Local file support
/// - Edit overlay for editable avatars
/// - Multiple size presets
/// - Online status indicator
class AvatarWidget extends StatelessWidget {
  /// Avatar image URL (for remote images)
  final String? imageUrl;

  /// Local file path (for local images)
  final String? localPath;

  /// User/group name for generating initials
  final String name;

  /// Avatar size preset
  final AvatarSize size;

  /// Custom size (overrides size preset)
  final double? customSize;

  /// Whether the avatar is editable (shows edit overlay on tap)
  final bool editable;

  /// Callback when edit is requested
  final VoidCallback? onEdit;

  /// Callback when avatar is tapped
  final VoidCallback? onTap;

  /// Whether to show online status indicator
  final bool showOnlineStatus;

  /// Whether the user is online
  final bool isOnline;

  /// Background color (defaults to theme primary)
  final Color? backgroundColor;

  /// Text color for initials (defaults to theme onPrimary)
  final Color? foregroundColor;

  /// Border to add around the avatar
  final Border? border;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.localPath,
    required this.name,
    this.size = AvatarSize.medium,
    this.customSize,
    this.editable = false,
    this.onEdit,
    this.onTap,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarSize = customSize ?? size.pixels;

    final bgColor = backgroundColor ?? theme.colorScheme.primary;
    final fgColor = foregroundColor ?? theme.colorScheme.onPrimary;

    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildAvatarContent(context, avatarSize, bgColor, fgColor),
    );

    // Wrap with gesture detector if tappable
    if (onTap != null || (editable && onEdit != null)) {
      avatar = GestureDetector(
        onTap: editable ? onEdit : onTap,
        child: avatar,
      );
    }

    // Add edit overlay if editable
    if (editable) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildEditBadge(context, avatarSize),
          ),
        ],
      );
    }

    // Add online status indicator
    if (showOnlineStatus) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: editable ? avatarSize * 0.25 : 0,
            child: _buildStatusIndicator(context, avatarSize),
          ),
        ],
      );
    }

    return avatar;
  }

  Widget _buildAvatarContent(
    BuildContext context,
    double avatarSize,
    Color bgColor,
    Color fgColor,
  ) {
    // Priority: local file > network image > initials
    if (localPath != null && File(localPath!).existsSync()) {
      return Image.file(
        File(localPath!),
        fit: BoxFit.cover,
        width: avatarSize,
        height: avatarSize,
        errorBuilder: (context, error, stack) =>
            _buildInitials(avatarSize, fgColor),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: avatarSize,
        height: avatarSize,
        placeholder: (context, url) => _buildInitials(avatarSize, fgColor),
        errorWidget: (context, url, error) =>
            _buildInitials(avatarSize, fgColor),
      );
    }

    return _buildInitials(avatarSize, fgColor);
  }

  Widget _buildInitials(double avatarSize, Color fgColor) {
    final initials = _getInitials(name);
    final fontSize = avatarSize * 0.4;

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: fgColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEditBadge(BuildContext context, double avatarSize) {
    final theme = Theme.of(context);
    final badgeSize = avatarSize * 0.32;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.camera_alt_rounded,
        size: badgeSize * 0.6,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, double avatarSize) {
    final theme = Theme.of(context);
    final indicatorSize = avatarSize * 0.25;

    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? Colors.green : Colors.grey,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(0, 2)).toUpperCase();
    }

    // First letter of first two words
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

/// Avatar size presets
enum AvatarSize {
  /// 24px - for inline/list indicators
  tiny(24),

  /// 32px - for compact lists
  small(32),

  /// 44px - standard list item
  medium(44),

  /// 56px - conversation headers
  large(56),

  /// 80px - profile sections
  xlarge(80),

  /// 120px - full profile pages
  xxlarge(120);

  final double pixels;
  const AvatarSize(this.pixels);
}

/// Group avatar widget that shows multiple user avatars in a stacked layout
class GroupAvatarWidget extends StatelessWidget {
  /// List of member image URLs (max 4 shown)
  final List<String?> memberImageUrls;

  /// List of member names for initials
  final List<String> memberNames;

  /// Avatar size
  final AvatarSize size;

  /// Custom group icon URL (overrides member avatars)
  final String? groupIconUrl;

  /// Group name (for initials if no icon)
  final String groupName;

  /// Callback when tapped
  final VoidCallback? onTap;

  const GroupAvatarWidget({
    super.key,
    this.memberImageUrls = const [],
    this.memberNames = const [],
    this.size = AvatarSize.medium,
    this.groupIconUrl,
    this.groupName = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If group has custom icon, show that
    if (groupIconUrl != null && groupIconUrl!.isNotEmpty) {
      return AvatarWidget(
        imageUrl: groupIconUrl,
        name: groupName,
        size: size,
        onTap: onTap,
      );
    }

    // If 1 or fewer members, show single avatar
    if (memberNames.length <= 1) {
      return AvatarWidget(
        imageUrl: memberImageUrls.isNotEmpty ? memberImageUrls.first : null,
        name: memberNames.isNotEmpty ? memberNames.first : groupName,
        size: size,
        onTap: onTap,
      );
    }

    // Show stacked avatars (max 4)
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size.pixels,
        height: size.pixels,
        child: _buildStackedAvatars(context),
      ),
    );
  }

  Widget _buildStackedAvatars(BuildContext context) {
    final theme = Theme.of(context);
    final itemCount = memberNames.length.clamp(0, 4);
    final itemSize = size.pixels * 0.55;

    // Calculate positions for 2-4 avatars in a grid
    final positions = _getPositions(itemCount, size.pixels, itemSize);

    return Stack(
      children: [
        for (var i = 0; i < itemCount; i++)
          Positioned(
            left: positions[i].dx,
            top: positions[i].dy,
            child: Container(
              width: itemSize,
              height: itemSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: AvatarWidget(
                  imageUrl:
                      i < memberImageUrls.length ? memberImageUrls[i] : null,
                  name: memberNames[i],
                  customSize: itemSize - 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Offset> _getPositions(int count, double containerSize, double itemSize) {
    final offset = (containerSize - itemSize) / 2;

    return switch (count) {
      2 => [
          Offset(0, offset),
          Offset(containerSize - itemSize, offset),
        ],
      3 => [
          Offset(offset, 0),
          Offset(0, containerSize - itemSize),
          Offset(containerSize - itemSize, containerSize - itemSize),
        ],
      4 => [
          const Offset(0, 0),
          Offset(containerSize - itemSize, 0),
          Offset(0, containerSize - itemSize),
          Offset(containerSize - itemSize, containerSize - itemSize),
        ],
      _ => [Offset(offset, offset)],
    };
  }
}
