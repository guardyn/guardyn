import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/media_entity.dart';

/// Widget to show upload progress for media files
///
/// Features:
/// - Progress bar with percentage
/// - File thumbnail preview
/// - Cancel button
/// - Filename display
class UploadProgressWidget extends StatelessWidget {
  /// Filename being uploaded
  final String filename;

  /// Upload progress (0.0 - 1.0)
  final double progress;

  /// Media type
  final MediaType? type;

  /// Local file path for thumbnail preview
  final String? localPath;

  /// Callback to cancel upload
  final VoidCallback? onCancel;

  /// Whether the upload failed
  final bool hasFailed;

  /// Error message if failed
  final String? errorMessage;

  /// Callback to retry failed upload
  final VoidCallback? onRetry;

  const UploadProgressWidget({
    super.key,
    required this.filename,
    required this.progress,
    this.type,
    this.localPath,
    this.onCancel,
    this.hasFailed = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasFailed
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Thumbnail or icon
          _buildThumbnail(context),

          const SizedBox(width: 12),

          // Info and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filename
                Text(
                  filename,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Progress or error
                if (hasFailed)
                  Text(
                    errorMessage ?? 'Upload failed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  )
                else
                  _buildProgressBar(context),

                const SizedBox(height: 2),

                // Status text
                if (!hasFailed)
                  Text(
                    '${(progress * 100).toInt()}% uploaded',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action button
          if (hasFailed && onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                color: theme.colorScheme.error,
              ),
              tooltip: 'Retry',
            )
          else if (onCancel != null)
            IconButton(
              onPressed: onCancel,
              icon: Icon(
                Icons.close_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              tooltip: 'Cancel',
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    const size = 48.0;

    // Show image preview if available
    if (localPath != null &&
        (type == MediaType.image || type == null) &&
        File(localPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(localPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildIcon(context, size),
        ),
      );
    }

    return _buildIcon(context, size);
  }

  Widget _buildIcon(BuildContext context, double size) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasFailed
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getIcon(),
        color: hasFailed
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
        size: 24,
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        minHeight: 4,
      ),
    );
  }

  IconData _getIcon() {
    if (hasFailed) return Icons.error_outline_rounded;

    return switch (type) {
      MediaType.image => Icons.image_rounded,
      MediaType.video => Icons.videocam_rounded,
      MediaType.audio => Icons.audiotrack_rounded,
      MediaType.document => Icons.insert_drive_file_rounded,
      _ => Icons.upload_file_rounded,
    };
  }
}

/// Compact upload progress indicator for inline use
class UploadProgressIndicator extends StatelessWidget {
  /// Upload progress (0.0 - 1.0)
  final double progress;

  /// Size of the indicator
  final double size;

  /// Show as failed
  final bool hasFailed;

  const UploadProgressIndicator({
    super.key,
    required this.progress,
    this.size = 40,
    this.hasFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (hasFailed) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.error_outline_rounded,
          color: theme.colorScheme.error,
          size: size * 0.5,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Upload queue widget showing multiple pending uploads
class UploadQueueWidget extends StatelessWidget {
  /// List of uploads in progress
  final List<UploadItem> uploads;

  /// Callback to cancel specific upload
  final void Function(String id)? onCancel;

  /// Callback to retry specific upload
  final void Function(String id)? onRetry;

  /// Whether the queue is collapsed
  final bool collapsed;

  /// Callback to toggle collapsed state
  final VoidCallback? onToggleCollapsed;

  const UploadQueueWidget({
    super.key,
    required this.uploads,
    this.onCancel,
    this.onRetry,
    this.collapsed = false,
    this.onToggleCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    if (uploads.isEmpty) return const SizedBox.shrink();

    final pendingCount = uploads.where((u) => !u.hasFailed).length;
    final failedCount = uploads.where((u) => u.hasFailed).length;

    if (collapsed) {
      return _buildCollapsedView(context, pendingCount, failedCount);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        _buildHeader(context, pendingCount, failedCount),

        // Upload items
        ...uploads.map((upload) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: UploadProgressWidget(
                filename: upload.filename,
                progress: upload.progress,
                type: upload.type,
                localPath: upload.localPath,
                hasFailed: upload.hasFailed,
                errorMessage: upload.errorMessage,
                onCancel: onCancel != null ? () => onCancel!(upload.id) : null,
                onRetry: onRetry != null ? () => onRetry!(upload.id) : null,
              ),
            )),
      ],
    );
  }

  Widget _buildCollapsedView(
    BuildContext context,
    int pendingCount,
    int failedCount,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onToggleCollapsed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (pendingCount > 0) ...[
              UploadProgressIndicator(
                progress: _averageProgress(),
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '$pendingCount uploading',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (failedCount > 0) ...[
              if (pendingCount > 0) const SizedBox(width: 8),
              Icon(
                Icons.error_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                '$failedCount failed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const Spacer(),
            Icon(
              Icons.expand_less_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int pendingCount,
    int failedCount,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            'Uploading',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(width: 8),
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pendingCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          const Spacer(),
          if (onToggleCollapsed != null)
            IconButton(
              onPressed: onToggleCollapsed,
              icon: Icon(
                Icons.expand_more_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  double _averageProgress() {
    final pending = uploads.where((u) => !u.hasFailed).toList();
    if (pending.isEmpty) return 0;
    return pending.map((u) => u.progress).reduce((a, b) => a + b) / pending.length;
  }
}

/// Model for an upload item
class UploadItem {
  final String id;
  final String filename;
  final double progress;
  final MediaType? type;
  final String? localPath;
  final bool hasFailed;
  final String? errorMessage;

  const UploadItem({
    required this.id,
    required this.filename,
    required this.progress,
    this.type,
    this.localPath,
    this.hasFailed = false,
    this.errorMessage,
  });
}
