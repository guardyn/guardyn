import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../media/domain/entities/media_entity.dart';
import '../../../media/presentation/bloc/media_bloc.dart';
import '../../../media/presentation/bloc/media_event.dart';
import '../../../media/presentation/bloc/media_state.dart';
import '../../../media/presentation/pages/media_viewer_page.dart';
import '../../../media/presentation/widgets/media_preview.dart';
import '../../domain/entities/group.dart';

/// Widget for displaying media attachments in group chat messages
///
/// Handles:
/// - Displaying media preview based on metadata
/// - Download/upload progress
/// - Tap to view full media
/// - Error states
class GroupChatMediaBubble extends StatefulWidget {
  /// The group message containing media metadata
  final GroupMessage message;

  /// Whether the message was sent by current user
  final bool isSentByMe;

  const GroupChatMediaBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
  });

  @override
  State<GroupChatMediaBubble> createState() => _GroupChatMediaBubbleState();
}

class _GroupChatMediaBubbleState extends State<GroupChatMediaBubble> {
  late MediaBloc _mediaBloc;
  MediaEntity? _media;
  String? _localPath;
  String? _thumbnailUrl;
  bool _isLoading = false;
  double? _downloadProgress;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _mediaBloc = getIt<MediaBloc>();
    _loadMediaMetadata();
  }

  @override
  void dispose() {
    _mediaBloc.close();
    super.dispose();
  }

  void _loadMediaMetadata() {
    final mediaId = widget.message.mediaId;
    if (mediaId == null) return;

    setState(() {
      _isLoading = true;
    });

    _mediaBloc.add(MediaMetadataRequested(mediaId: mediaId));
  }

  void _handleTap() {
    if (_media == null) return;

    // For images and videos, open the viewer
    if (_media!.type == MediaType.image || _media!.type == MediaType.video) {
      MediaViewerPage.show(
        context,
        mediaItems: [_media!],
        localPaths: _localPath != null ? {_media!.id: _localPath!} : {},
        thumbnailUrls: _thumbnailUrl != null ? {_media!.id: _thumbnailUrl!} : {},
        onDownloadRequested: (mediaId) {
          _mediaBloc.add(MediaDownloadRequested(mediaId: mediaId));
        },
      );
    } else {
      // For other files, trigger download
      _mediaBloc.add(MediaDownloadRequested(mediaId: _media!.id));
    }
  }

  MediaEntity _buildMediaEntityFromMetadata() {
    final metadata = widget.message.metadata;
    return MediaEntity(
      id: metadata['media_id'] ?? '',
      ownerUserId: widget.message.senderUserId,
      type: _parseMediaType(metadata['media_type'] ?? 'image'),
      filename: metadata['filename'] ?? 'file',
      mimeType: metadata['mime_type'] ?? 'application/octet-stream',
      sizeBytes: int.tryParse(metadata['size_bytes'] ?? '0') ?? 0,
      status: UploadStatus.completed,
    );
  }

  MediaType _parseMediaType(String type) {
    return switch (type.toLowerCase()) {
      'image' => MediaType.image,
      'video' => MediaType.video,
      'audio' => MediaType.audio,
      'document' => MediaType.document,
      _ => MediaType.other,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mediaBloc,
      child: BlocConsumer<MediaBloc, MediaState>(
        listener: (context, state) {
          if (state is MediaMetadataLoaded) {
            setState(() {
              _media = state.media;
              _isLoading = false;
            });
            // Request thumbnail for images/videos
            if (state.media.type == MediaType.image ||
                state.media.type == MediaType.video) {
              _mediaBloc.add(MediaThumbnailRequested(mediaId: state.media.id));
            }
          } else if (state is MediaThumbnailLoaded) {
            setState(() {
              _thumbnailUrl = state.thumbnailUrl;
            });
          } else if (state is MediaDownloading) {
            setState(() {
              _downloadProgress = state.progress;
            });
          } else if (state is MediaDownloadSuccess) {
            setState(() {
              _localPath = state.localPath;
              _downloadProgress = null;
            });
          } else if (state is MediaError) {
            setState(() {
              _errorMessage = state.message;
              _isLoading = false;
              _downloadProgress = null;
            });
          }
        },
        builder: (context, state) {
          // Use metadata from message if media not loaded yet
          final media = _media ?? _buildMediaEntityFromMetadata();

          return GestureDetector(
            onTap: _handleTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.space1),
              child: _errorMessage != null
                  ? _buildErrorWidget(context)
                  : MediaPreview(
                      media: media,
                      localPath: _localPath,
                      thumbnailUrl: _thumbnailUrl,
                      isLoading: _isLoading,
                      downloadProgress: _downloadProgress,
                      maxWidth: 220,
                      maxHeight: 180,
                      borderRadius: 8,
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 180,
      height: 100,
      decoration: BoxDecoration(
        color: isDark
            ? GrayColors.gray800.withValues(alpha: 0.5)
            : GrayColors.gray200.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: SemanticColors.error,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            'Failed to load media',
            style: TextStyle(
              color: isDark ? GrayColors.gray400 : GrayColors.gray600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space1),
          GestureDetector(
            onTap: _loadMediaMetadata,
            child: Text(
              'Tap to retry',
              style: TextStyle(
                color: GuardynColors.guardyn500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
