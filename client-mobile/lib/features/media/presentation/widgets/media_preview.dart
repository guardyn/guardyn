import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/media_entity.dart';

/// Widget for displaying media preview in chat bubbles
///
/// Displays:
/// - Image thumbnail with tap to view
/// - Video thumbnail with play overlay
/// - Audio with waveform placeholder
/// - Document with icon and filename
class MediaPreview extends StatelessWidget {
  /// Media entity to display
  final MediaEntity media;

  /// Local file path (if available)
  final String? localPath;

  /// Thumbnail URL (if available)
  final String? thumbnailUrl;

  /// Callback when preview is tapped
  final VoidCallback? onTap;

  /// Whether the media is currently loading
  final bool isLoading;

  /// Download progress (0.0 - 1.0)
  final double? downloadProgress;

  /// Maximum width for the preview
  final double maxWidth;

  /// Maximum height for the preview
  final double maxHeight;

  /// Border radius
  final double borderRadius;

  const MediaPreview({
    super.key,
    required this.media,
    this.localPath,
    this.thumbnailUrl,
    this.onTap,
    this.isLoading = false,
    this.downloadProgress,
    this.maxWidth = 250,
    this.maxHeight = 200,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (media.type) {
      case MediaType.image:
        return _buildImagePreview(context);
      case MediaType.video:
        return _buildVideoPreview(context);
      case MediaType.audio:
        return _buildAudioPreview(context);
      case MediaType.document:
        return _buildDocumentPreview(context);
      default:
        return _buildUnknownPreview(context);
    }
  }

  Widget _buildImagePreview(BuildContext context) {
    Widget imageWidget;

    if (localPath != null && File(localPath!).existsSync()) {
      // Local file available
      imageWidget = Image.file(
        File(localPath!),
        fit: BoxFit.cover,
        width: maxWidth,
        height: maxHeight,
        errorBuilder: (context, error, stack) => _buildPlaceholder(context),
      );
    } else if (thumbnailUrl != null) {
      // Network thumbnail
      imageWidget = CachedNetworkImage(
        imageUrl: thumbnailUrl!,
        fit: BoxFit.cover,
        width: maxWidth,
        height: maxHeight,
        placeholder: (context, url) => _buildPlaceholder(context, showLoader: true),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    } else {
      imageWidget = _buildPlaceholder(context, showLoader: isLoading);
    }

    return Stack(
      children: [
        imageWidget,
        if (isLoading || downloadProgress != null)
          _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    Widget thumbnailWidget;

    if (thumbnailUrl != null) {
      thumbnailWidget = CachedNetworkImage(
        imageUrl: thumbnailUrl!,
        fit: BoxFit.cover,
        width: maxWidth,
        height: maxHeight,
        placeholder: (context, url) => _buildPlaceholder(context, showLoader: true),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    } else {
      thumbnailWidget = _buildPlaceholder(context);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        thumbnailWidget,

        // Play button overlay
        if (!isLoading)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

        // Duration badge
        if (media.durationMs != null && media.durationMs! > 0)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                media.formattedDuration ?? '00:00',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        if (isLoading || downloadProgress != null)
          _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildAudioPreview(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: maxWidth,
      height: 64,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          // Play button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLoading ? Icons.hourglass_empty_rounded : Icons.play_arrow_rounded,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Waveform placeholder and info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform bars
                if (!isLoading)
                  SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        20,
                        (index) => Container(
                          width: 3,
                          height: (index % 3 + 1) * 6.0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (isLoading)
                  LinearProgressIndicator(
                    value: downloadProgress,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),

                const SizedBox(height: 4),

                // Duration
                Text(
                  media.durationMs != null
                      ? (media.formattedDuration ?? 'Audio')
                      : 'Audio',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: maxWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          // Document icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDocumentIcon(),
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  media.filename,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    Text(
                      media.formattedSize,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (media.extension.isNotEmpty) ...[
                      Text(
                        ' • ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        media.extension.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),

                if (isLoading && downloadProgress != null) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: downloadProgress,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ],
              ],
            ),
          ),

          // Download indicator
          if (!isLoading)
            Icon(
              Icons.download_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildUnknownPreview(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: maxWidth,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              media.filename,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, {bool showLoader = false}) {
    final theme = Theme.of(context);

    return Container(
      width: maxWidth,
      height: maxHeight,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: showLoader
            ? CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              )
            : Icon(
                Icons.image_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 48,
              ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: downloadProgress != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: downloadProgress,
                        strokeWidth: 3,
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                      ),
                      Text(
                        '${(downloadProgress! * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getDocumentIcon() {
    final ext = media.extension.toLowerCase();
    return switch (ext) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'doc' || 'docx' => Icons.description_rounded,
      'xls' || 'xlsx' => Icons.table_chart_rounded,
      'ppt' || 'pptx' => Icons.slideshow_rounded,
      'txt' => Icons.article_rounded,
      'zip' || 'rar' || '7z' => Icons.folder_zip_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }
}
