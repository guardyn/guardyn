import 'package:equatable/equatable.dart';

/// Media type enumeration for domain layer
enum MediaType {
  unknown,
  image,
  video,
  audio,
  document,
  other;

  /// Convert from proto MediaType value
  static MediaType fromProtoValue(int value) {
    return switch (value) {
      1 => MediaType.image,
      2 => MediaType.video,
      3 => MediaType.audio,
      4 => MediaType.document,
      5 => MediaType.other,
      _ => MediaType.unknown,
    };
  }

  /// Convert to proto MediaType value
  int toProtoValue() {
    return switch (this) {
      MediaType.unknown => 0,
      MediaType.image => 1,
      MediaType.video => 2,
      MediaType.audio => 3,
      MediaType.document => 4,
      MediaType.other => 5,
    };
  }

  /// Get human-readable name
  String get displayName {
    return switch (this) {
      MediaType.unknown => 'Unknown',
      MediaType.image => 'Image',
      MediaType.video => 'Video',
      MediaType.audio => 'Audio',
      MediaType.document => 'Document',
      MediaType.other => 'Other',
    };
  }

  /// Check if this is an image type
  bool get isImage => this == MediaType.image;

  /// Check if this is a video type
  bool get isVideo => this == MediaType.video;

  /// Check if this is an audio type
  bool get isAudio => this == MediaType.audio;

  /// Check if this is a document type
  bool get isDocument => this == MediaType.document;

  /// Check if this media type can be displayed inline
  bool get canDisplayInline => isImage || isVideo;

  /// Check if this media type can be previewed with thumbnail
  bool get canHaveThumbnail => isImage || isVideo;
}

/// Upload status enumeration
enum UploadStatus {
  unknown,
  pending,
  processing,
  completed,
  failed;

  /// Convert from proto UploadStatus value
  static UploadStatus fromProtoValue(int value) {
    return switch (value) {
      1 => UploadStatus.pending,
      2 => UploadStatus.processing,
      3 => UploadStatus.completed,
      4 => UploadStatus.failed,
      _ => UploadStatus.unknown,
    };
  }

  /// Convert to proto UploadStatus value
  int toProtoValue() {
    return switch (this) {
      UploadStatus.unknown => 0,
      UploadStatus.pending => 1,
      UploadStatus.processing => 2,
      UploadStatus.completed => 3,
      UploadStatus.failed => 4,
    };
  }

  /// Check if upload is in progress
  bool get isInProgress =>
      this == UploadStatus.pending || this == UploadStatus.processing;

  /// Check if upload is complete
  bool get isCompleted => this == UploadStatus.completed;

  /// Check if upload failed
  bool get isFailed => this == UploadStatus.failed;
}

/// Media entity representing a media file in the domain layer
class MediaEntity extends Equatable {
  /// Unique identifier for the media
  final String id;

  /// Owner user ID
  final String ownerUserId;

  /// Original filename
  final String filename;

  /// Media type (image, video, audio, document)
  final MediaType type;

  /// MIME type (e.g., "image/jpeg", "video/mp4")
  final String mimeType;

  /// File size in bytes
  final int sizeBytes;

  /// SHA-256 checksum for integrity verification
  final String? checksumSha256;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Upload status
  final UploadStatus status;

  /// Image/video width in pixels
  final int? width;

  /// Image/video height in pixels
  final int? height;

  /// Audio/video duration in milliseconds
  final int? durationMs;

  /// Thumbnail media ID (for images and videos)
  final String? thumbnailId;

  /// Whether the media is encrypted
  final bool isEncrypted;

  /// Conversation ID this media belongs to
  final String? conversationId;

  /// Message ID this media is attached to
  final String? messageId;

  /// Local file path (if downloaded)
  final String? localPath;

  /// Local thumbnail path (if available)
  final String? localThumbnailPath;

  /// Download/upload progress (0.0 - 1.0)
  final double? progress;

  const MediaEntity({
    required this.id,
    required this.ownerUserId,
    required this.filename,
    required this.type,
    required this.mimeType,
    required this.sizeBytes,
    this.checksumSha256,
    this.createdAt,
    this.updatedAt,
    this.status = UploadStatus.unknown,
    this.width,
    this.height,
    this.durationMs,
    this.thumbnailId,
    this.isEncrypted = false,
    this.conversationId,
    this.messageId,
    this.localPath,
    this.localThumbnailPath,
    this.progress,
  });

  @override
  List<Object?> get props => [
    id,
    ownerUserId,
    filename,
    type,
    mimeType,
    sizeBytes,
    checksumSha256,
    createdAt,
    updatedAt,
    status,
    width,
    height,
    durationMs,
    thumbnailId,
    isEncrypted,
    conversationId,
    messageId,
    localPath,
    localThumbnailPath,
    progress,
  ];

  /// Create a copy with updated fields
  MediaEntity copyWith({
    String? id,
    String? ownerUserId,
    String? filename,
    MediaType? type,
    String? mimeType,
    int? sizeBytes,
    String? checksumSha256,
    DateTime? createdAt,
    DateTime? updatedAt,
    UploadStatus? status,
    int? width,
    int? height,
    int? durationMs,
    String? thumbnailId,
    bool? isEncrypted,
    String? conversationId,
    String? messageId,
    String? localPath,
    String? localThumbnailPath,
    double? progress,
  }) {
    return MediaEntity(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      filename: filename ?? this.filename,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      localPath: localPath ?? this.localPath,
      localThumbnailPath: localThumbnailPath ?? this.localThumbnailPath,
      progress: progress ?? this.progress,
    );
  }

  /// Get formatted file size string
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Get formatted duration string for audio/video
  String? get formattedDuration {
    if (durationMs == null) return null;

    final totalSeconds = durationMs! ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get aspect ratio for images/videos
  double? get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return null;
  }

  /// Check if the media is available locally
  bool get isAvailableLocally => localPath != null;

  /// Check if thumbnail is available locally
  bool get hasThumbnailLocally => localThumbnailPath != null;

  /// Check if the media is ready to display
  bool get isReady => status.isCompleted;

  /// Get file extension from filename
  String get extension {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1 || lastDot == filename.length - 1) {
      return '';
    }
    return filename.substring(lastDot + 1).toLowerCase();
  }
}

/// Result of a presigned upload URL request
class UploadUrlResult extends Equatable {
  /// Generated media ID
  final String mediaId;

  /// Presigned URL for upload
  final String presignedUrl;

  /// URL expiration time
  final DateTime expiresAt;

  /// Headers required for upload (includes Content-Type used in signature)
  final Map<String, String> headers;

  const UploadUrlResult({
    required this.mediaId,
    required this.presignedUrl,
    required this.expiresAt,
    this.headers = const {},
  });

  /// Get Content-Type header if present
  String? get contentType => headers['Content-Type'];

  @override
  List<Object?> get props => [mediaId, presignedUrl, expiresAt, headers];

  /// Check if the URL is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Time remaining until expiration
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());
}

/// Result of a presigned download URL request
class DownloadUrlResult extends Equatable {
  /// Media ID
  final String mediaId;

  /// Presigned URL for download
  final String presignedUrl;

  /// URL expiration time
  final DateTime expiresAt;

  const DownloadUrlResult({
    required this.mediaId,
    required this.presignedUrl,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [mediaId, presignedUrl, expiresAt];

  /// Check if the URL is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt);
}

/// Paginated list of media
class MediaListResult extends Equatable {
  /// List of media entities
  final List<MediaEntity> media;

  /// Cursor for next page (null if no more pages)
  final String? nextCursor;

  /// Total count (if available)
  final int? totalCount;

  const MediaListResult({
    required this.media,
    this.nextCursor,
    this.totalCount,
  });

  @override
  List<Object?> get props => [media, nextCursor, totalCount];

  /// Check if there are more pages
  bool get hasMore => nextCursor != null;
}
