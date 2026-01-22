import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';

/// Use case for managing media cache
class ManageMediaCache {
  final MediaRepository repository;

  ManageMediaCache(this.repository);

  /// Clear all cached media
  Future<void> clearAll() async {
    await repository.clearCache();
  }

  /// Clear specific media from cache
  ///
  /// [mediaId] - Media ID to clear
  Future<void> clear({required String mediaId}) async {
    if (mediaId.isEmpty) {
      throw MediaException(
        'Media ID cannot be empty',
        code: 'INVALID_ARGUMENT',
      );
    }

    await repository.clearCache(mediaId: mediaId);
  }

  /// Get total cache size in bytes
  Future<int> getSize() async {
    return repository.getCacheSize();
  }

  /// Get formatted cache size string
  Future<String> getFormattedSize() async {
    final sizeBytes = await getSize();

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

  /// Check if a media file is cached
  ///
  /// [mediaId] - Media ID to check
  Future<bool> isCached({required String mediaId}) async {
    final path = await repository.getCachedPath(mediaId: mediaId);
    return path != null;
  }
}
