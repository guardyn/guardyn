import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/media_entity.dart';

/// Base class for all media events
abstract class MediaEvent extends Equatable {
  const MediaEvent();

  @override
  List<Object?> get props => [];
}

/// Request to upload a media file
class MediaUploadRequested extends MediaEvent {
  /// Path to the local file to upload
  final String filePath;

  /// MIME type of the file
  final String mimeType;

  /// Optional conversation ID this media belongs to
  final String? conversationId;

  /// Optional message ID this media is attached to
  final String? messageId;

  const MediaUploadRequested({
    required this.filePath,
    required this.mimeType,
    this.conversationId,
    this.messageId,
  });

  @override
  List<Object?> get props => [filePath, mimeType, conversationId, messageId];
}

/// Request to upload media from bytes (for avatar uploads, etc.)
class MediaUploadFromBytesRequested extends MediaEvent {
  /// File data as bytes
  final Uint8List data;

  /// Filename for the upload
  final String filename;

  /// MIME type of the file
  final String mimeType;

  /// Optional conversation ID this media belongs to
  final String? conversationId;

  const MediaUploadFromBytesRequested({
    required this.data,
    required this.filename,
    required this.mimeType,
    this.conversationId,
  });

  @override
  List<Object?> get props => [data, filename, mimeType, conversationId];
}

/// Request to download a media file
class MediaDownloadRequested extends MediaEvent {
  /// Media ID to download
  final String mediaId;

  /// Whether to skip the cache and force download
  final bool forceDownload;

  const MediaDownloadRequested({
    required this.mediaId,
    this.forceDownload = false,
  });

  @override
  List<Object?> get props => [mediaId, forceDownload];
}

/// Request to list media for a conversation
class MediaListRequested extends MediaEvent {
  /// Conversation ID to list media for
  final String conversationId;

  /// Optional filter by media type
  final MediaType? filterType;

  /// Maximum number of items to load
  final int limit;

  /// Pagination cursor from previous response
  final String? cursor;

  const MediaListRequested({
    required this.conversationId,
    this.filterType,
    this.limit = 50,
    this.cursor,
  });

  @override
  List<Object?> get props => [conversationId, filterType, limit, cursor];
}

/// Load more items for pagination
class MediaLoadMoreRequested extends MediaEvent {
  /// Conversation ID to list media for
  final String conversationId;

  /// Optional filter by media type
  final MediaType? filterType;

  const MediaLoadMoreRequested({
    required this.conversationId,
    this.filterType,
  });

  @override
  List<Object?> get props => [conversationId, filterType];
}

/// Request to get metadata for a single media item
class MediaMetadataRequested extends MediaEvent {
  /// Media ID to get metadata for
  final String mediaId;

  const MediaMetadataRequested({required this.mediaId});

  @override
  List<Object?> get props => [mediaId];
}

/// Request to delete a media file
class MediaDeleteRequested extends MediaEvent {
  /// Media ID to delete
  final String mediaId;

  /// Whether to also delete from local cache
  final bool deleteFromCache;

  const MediaDeleteRequested({
    required this.mediaId,
    this.deleteFromCache = true,
  });

  @override
  List<Object?> get props => [mediaId, deleteFromCache];
}

/// Request to get a thumbnail URL
class MediaThumbnailRequested extends MediaEvent {
  /// Media ID to get thumbnail for
  final String mediaId;

  /// Thumbnail width
  final int width;

  /// Thumbnail height
  final int height;

  const MediaThumbnailRequested({
    required this.mediaId,
    this.width = 200,
    this.height = 200,
  });

  @override
  List<Object?> get props => [mediaId, width, height];
}

/// Clear all media cache
class MediaCacheClearRequested extends MediaEvent {
  const MediaCacheClearRequested();
}

/// Reset media state (clear errors, etc.)
class MediaReset extends MediaEvent {
  const MediaReset();
}

/// Update upload progress (internal event)
class MediaUploadProgressUpdated extends MediaEvent {
  /// Upload progress from 0.0 to 1.0
  final double progress;

  /// Media ID being uploaded
  final String? mediaId;

  const MediaUploadProgressUpdated({
    required this.progress,
    this.mediaId,
  });

  @override
  List<Object?> get props => [progress, mediaId];
}

/// Update download progress (internal event)
class MediaDownloadProgressUpdated extends MediaEvent {
  /// Download progress from 0.0 to 1.0
  final double progress;

  /// Media ID being downloaded
  final String mediaId;

  const MediaDownloadProgressUpdated({
    required this.progress,
    required this.mediaId,
  });

  @override
  List<Object?> get props => [progress, mediaId];
}
