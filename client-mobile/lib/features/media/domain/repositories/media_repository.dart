import 'dart:typed_data';

import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';

/// Abstract repository interface for media operations
abstract class MediaRepository {
  /// Get a presigned URL for uploading media
  ///
  /// [filename] - Original filename
  /// [mimeType] - MIME type of the file
  /// [sizeBytes] - File size in bytes
  /// [conversationId] - Optional conversation this media belongs to
  ///
  /// Returns [UploadUrlResult] with mediaId and presigned URL
  /// Throws [MediaException] on failure
  Future<UploadUrlResult> getUploadUrl({
    required String filename,
    required String mimeType,
    required int sizeBytes,
    String? conversationId,
  });

  /// Upload media file to the presigned URL
  ///
  /// [presignedUrl] - Presigned URL from getUploadUrl
  /// [data] - File data as bytes
  /// [mimeType] - MIME type of the file
  /// [onProgress] - Optional callback for upload progress (0.0 - 1.0)
  ///
  /// Throws [MediaException] on failure
  Future<void> uploadToPresignedUrl({
    required String presignedUrl,
    required Uint8List data,
    required String mimeType,
    void Function(double progress)? onProgress,
  });

  /// Confirm that upload is complete
  ///
  /// [mediaId] - Media ID from getUploadUrl
  /// [checksumSha256] - SHA-256 checksum of uploaded data
  ///
  /// Returns updated [MediaEntity]
  /// Throws [MediaException] on failure
  Future<MediaEntity> confirmUpload({
    required String mediaId,
    required String checksumSha256,
  });

  /// Get a presigned URL for downloading media
  ///
  /// [mediaId] - Media ID to download
  ///
  /// Returns [DownloadUrlResult] with presigned URL
  /// Throws [MediaException] on failure
  Future<DownloadUrlResult> getDownloadUrl({
    required String mediaId,
  });

  /// Download media from presigned URL
  ///
  /// [presignedUrl] - Presigned URL from getDownloadUrl
  /// [onProgress] - Optional callback for download progress (0.0 - 1.0)
  ///
  /// Returns downloaded data as bytes
  /// Throws [MediaException] on failure
  Future<Uint8List> downloadFromPresignedUrl({
    required String presignedUrl,
    void Function(double progress)? onProgress,
  });

  /// Get metadata for a media file
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns [MediaEntity] with metadata
  /// Throws [MediaException] on failure
  Future<MediaEntity> getMetadata({
    required String mediaId,
  });

  /// List media for a conversation
  ///
  /// [conversationId] - Conversation ID
  /// [type] - Optional filter by media type
  /// [limit] - Maximum number of results (default: 50)
  /// [cursor] - Pagination cursor from previous response
  ///
  /// Returns [MediaListResult] with media list and pagination
  /// Throws [MediaException] on failure
  Future<MediaListResult> listMedia({
    required String conversationId,
    MediaType? type,
    int limit = 50,
    String? cursor,
  });

  /// Delete a media file
  ///
  /// [mediaId] - Media ID to delete
  ///
  /// Throws [MediaException] on failure
  Future<void> deleteMedia({
    required String mediaId,
  });

  /// Get thumbnail URL for a media file
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns thumbnail presigned URL or null if not available
  /// Throws [MediaException] on failure
  Future<String?> getThumbnailUrl({
    required String mediaId,
  });

  /// Save media to local cache
  ///
  /// [mediaId] - Media ID
  /// [data] - File data
  ///
  /// Returns local file path
  Future<String> saveToCache({
    required String mediaId,
    required Uint8List data,
    String? filename,
  });

  /// Get media from local cache
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns cached data or null if not in cache
  Future<Uint8List?> getFromCache({
    required String mediaId,
  });

  /// Get local file path from cache
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns local file path or null if not cached
  Future<String?> getCachedPath({
    required String mediaId,
  });

  /// Clear cached media
  ///
  /// [mediaId] - Optional specific media ID to clear, clears all if null
  Future<void> clearCache({String? mediaId});

  /// Get total cache size in bytes
  Future<int> getCacheSize();
}

/// Media-related exceptions
class MediaException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  MediaException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() =>
      'MediaException: $message${code != null ? ' (code: $code)' : ''}';

  /// Check if this is a not found error
  bool get isNotFound => code == 'NOT_FOUND';

  /// Check if this is an unauthorized error
  bool get isUnauthorized => code == 'UNAUTHORIZED' || code == 'UNAUTHENTICATED';

  /// Check if this is a file too large error
  bool get isFileTooLarge => code == 'FILE_TOO_LARGE';

  /// Check if this is an invalid file type error
  bool get isInvalidFileType => code == 'INVALID_FILE_TYPE';

  /// Check if this is a network error
  bool get isNetworkError => code == 'NETWORK_ERROR' || code == 'UNAVAILABLE';

  /// Check if this is a quota exceeded error
  bool get isQuotaExceeded => code == 'QUOTA_EXCEEDED';
}
