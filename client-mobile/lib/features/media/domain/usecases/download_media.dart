import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';

/// Use case for downloading media files
///
/// This handles the complete download flow:
/// 1. Check local cache first
/// 2. Get presigned URL from server if not cached
/// 3. Download file from presigned URL
/// 4. Save to local cache
@injectable
class DownloadMedia {
  final MediaRepository repository;

  DownloadMedia(this.repository);

  /// Download a media file
  ///
  /// [mediaId] - Media ID to download
  /// [onProgress] - Optional callback for download progress (0.0 - 1.0)
  /// [skipCache] - If true, always download fresh copy
  ///
  /// Returns downloaded data as bytes
  /// Throws [MediaException] on failure
  Future<Uint8List> call({
    required String mediaId,
    void Function(double progress)? onProgress,
    bool skipCache = false,
  }) async {
    // Check cache first
    if (!skipCache) {
      final cached = await repository.getFromCache(mediaId: mediaId);
      if (cached != null) {
        onProgress?.call(1.0);
        return cached;
      }
    }

    // Get download URL
    final downloadUrl = await repository.getDownloadUrl(mediaId: mediaId);

    // Download from presigned URL
    final data = await repository.downloadFromPresignedUrl(
      presignedUrl: downloadUrl.presignedUrl,
      onProgress: onProgress,
    );

    // Save to cache
    await repository.saveToCache(mediaId: mediaId, data: data);

    return data;
  }

  /// Get download URL without downloading
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns [DownloadUrlResult] with presigned URL
  /// Throws [MediaException] on failure
  Future<DownloadUrlResult> getUrl({
    required String mediaId,
  }) async {
    return repository.getDownloadUrl(mediaId: mediaId);
  }

  /// Get local path if available
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns local file path or null if not cached
  Future<String?> getLocalPath({
    required String mediaId,
  }) async {
    return repository.getCachedPath(mediaId: mediaId);
  }
}
