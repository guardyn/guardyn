import 'package:equatable/equatable.dart';

import '../../domain/entities/media_entity.dart';

/// Base class for all media states
abstract class MediaState extends Equatable {
  const MediaState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class MediaInitial extends MediaState {
  const MediaInitial();
}

/// Loading state for any async operation
class MediaLoading extends MediaState {
  /// Optional list of previously loaded media items
  final List<MediaEntity> media;

  const MediaLoading({this.media = const []});

  @override
  List<Object?> get props => [media];
}

/// Upload in progress state
class MediaUploading extends MediaState {
  /// Upload progress from 0.0 to 1.0
  final double progress;

  /// Media ID (available after presigned URL is obtained)
  final String? mediaId;

  /// Original filename being uploaded
  final String filename;

  const MediaUploading({
    required this.progress,
    this.mediaId,
    required this.filename,
  });

  @override
  List<Object?> get props => [progress, mediaId, filename];

  /// Create a copy with updated progress
  MediaUploading copyWith({
    double? progress,
    String? mediaId,
    String? filename,
  }) {
    return MediaUploading(
      progress: progress ?? this.progress,
      mediaId: mediaId ?? this.mediaId,
      filename: filename ?? this.filename,
    );
  }
}

/// Upload completed successfully
class MediaUploadSuccess extends MediaState {
  /// Uploaded media entity with metadata
  final MediaEntity media;

  const MediaUploadSuccess({required this.media});

  @override
  List<Object?> get props => [media];
}

/// Download in progress state
class MediaDownloading extends MediaState {
  /// Download progress from 0.0 to 1.0
  final double progress;

  /// Media ID being downloaded
  final String mediaId;

  const MediaDownloading({
    required this.progress,
    required this.mediaId,
  });

  @override
  List<Object?> get props => [progress, mediaId];

  /// Create a copy with updated progress
  MediaDownloading copyWith({
    double? progress,
    String? mediaId,
  }) {
    return MediaDownloading(
      progress: progress ?? this.progress,
      mediaId: mediaId ?? this.mediaId,
    );
  }
}

/// Download completed successfully
class MediaDownloadSuccess extends MediaState {
  /// Local file path where media was saved
  final String localPath;

  /// Media entity with metadata
  final MediaEntity media;

  const MediaDownloadSuccess({
    required this.localPath,
    required this.media,
  });

  @override
  List<Object?> get props => [localPath, media];
}

/// Media list loaded successfully
class MediaListLoaded extends MediaState {
  /// Loaded media items
  final List<MediaEntity> media;

  /// Conversation ID for the list
  final String conversationId;

  /// Whether there are more items to load
  final bool hasMore;

  /// Pagination cursor for next page
  final String? nextCursor;

  /// Current filter type
  final MediaType? filterType;

  const MediaListLoaded({
    required this.media,
    required this.conversationId,
    this.hasMore = false,
    this.nextCursor,
    this.filterType,
  });

  @override
  List<Object?> get props => [media, conversationId, hasMore, nextCursor, filterType];

  /// Create a copy with additional media items appended
  MediaListLoaded copyWithMore({
    required List<MediaEntity> newMedia,
    bool? hasMore,
    String? nextCursor,
  }) {
    return MediaListLoaded(
      media: [...media, ...newMedia],
      conversationId: conversationId,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      filterType: filterType,
    );
  }

  /// Filter media by type
  List<MediaEntity> filterByType(MediaType type) {
    return media.where((m) => m.type == type).toList();
  }

  /// Get only images
  List<MediaEntity> get images => filterByType(MediaType.image);

  /// Get only videos
  List<MediaEntity> get videos => filterByType(MediaType.video);

  /// Get only audio files
  List<MediaEntity> get audioFiles => filterByType(MediaType.audio);

  /// Get only documents
  List<MediaEntity> get documents => filterByType(MediaType.document);
}

/// Single media metadata loaded
class MediaMetadataLoaded extends MediaState {
  /// Media entity with metadata
  final MediaEntity media;

  const MediaMetadataLoaded({required this.media});

  @override
  List<Object?> get props => [media];
}

/// Thumbnail URL retrieved
class MediaThumbnailLoaded extends MediaState {
  /// Media ID for the thumbnail
  final String mediaId;

  /// Presigned URL for the thumbnail
  final String thumbnailUrl;

  const MediaThumbnailLoaded({
    required this.mediaId,
    required this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [mediaId, thumbnailUrl];
}

/// Media deleted successfully
class MediaDeleteSuccess extends MediaState {
  /// Deleted media ID
  final String mediaId;

  const MediaDeleteSuccess({required this.mediaId});

  @override
  List<Object?> get props => [mediaId];
}

/// Cache cleared successfully
class MediaCacheCleared extends MediaState {
  const MediaCacheCleared();
}

/// Error state
class MediaError extends MediaState {
  /// Error message
  final String message;

  /// Error code (optional)
  final String? code;

  /// Previously loaded media items (preserved on error)
  final List<MediaEntity> media;

  const MediaError({
    required this.message,
    this.code,
    this.media = const [],
  });

  @override
  List<Object?> get props => [message, code, media];
}
