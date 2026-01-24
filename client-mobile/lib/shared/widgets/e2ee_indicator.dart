import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// E2EE encryption status types
enum E2EEStatus {
  /// 1-on-1 Double Ratchet encryption
  encrypted,

  /// Group MLS (RFC 9420) encryption
  mlsEncrypted,

  /// Error state - messages are not encrypted
  notEncrypted,

  /// Encryption keys are being verified
  verifying,
}

/// Visual indicator showing E2EE encryption status.
/// Used in chat headers and group info pages to show users
/// that their messages are protected by end-to-end encryption.
class E2EEIndicator extends StatelessWidget {
  final E2EEStatus status;
  final bool showLabel;
  final double size;

  const E2EEIndicator({
    super.key,
    required this.status,
    this.showLabel = true,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _tooltipMessage,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: size,
            color: _color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  IconData get _icon {
    switch (status) {
      case E2EEStatus.encrypted:
        return Icons.lock;
      case E2EEStatus.mlsEncrypted:
        return Icons.enhanced_encryption;
      case E2EEStatus.notEncrypted:
        return Icons.lock_open;
      case E2EEStatus.verifying:
        return Icons.hourglass_empty;
    }
  }

  Color get _color {
    switch (status) {
      case E2EEStatus.encrypted:
      case E2EEStatus.mlsEncrypted:
        return SemanticColors.success;
      case E2EEStatus.notEncrypted:
        return SemanticColors.error;
      case E2EEStatus.verifying:
        return SemanticColors.warning;
    }
  }

  String get _label {
    switch (status) {
      case E2EEStatus.encrypted:
        return 'E2EE';
      case E2EEStatus.mlsEncrypted:
        return 'MLS';
      case E2EEStatus.notEncrypted:
        return 'Not secure';
      case E2EEStatus.verifying:
        return 'Verifying...';
    }
  }

  String get _tooltipMessage {
    switch (status) {
      case E2EEStatus.encrypted:
        return 'Messages are end-to-end encrypted using Double Ratchet';
      case E2EEStatus.mlsEncrypted:
        return 'Group messages are end-to-end encrypted using MLS (RFC 9420)';
      case E2EEStatus.notEncrypted:
        return 'Messages are NOT encrypted. This conversation is not secure.';
      case E2EEStatus.verifying:
        return 'Verifying encryption keys...';
    }
  }
}
