import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Local data source for media caching
///
/// Provides file-based caching for downloaded media files
/// to enable offline access and reduce bandwidth usage.
class MediaLocalDatasource {
  final Logger logger = Logger();

  Directory? _cacheDir;
  static const String _mediaCacheSubdir = 'media_cache';
  static const String _thumbnailCacheSubdir = 'thumbnail_cache';

  /// Initialize the cache directories
  Future<void> initialize() async {
    if (_cacheDir != null) return;

    final tempDir = await getTemporaryDirectory();
    _cacheDir = Directory('${tempDir.path}/$_mediaCacheSubdir');

    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }

    final thumbnailDir = Directory('${_cacheDir!.path}/$_thumbnailCacheSubdir');
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }

    logger.d('Media cache initialized at: ${_cacheDir!.path}');
  }

  /// Get the cache directory path
  Future<String> get cachePath async {
    await initialize();
    return _cacheDir!.path;
  }

  /// Get cached file for a media ID
  ///
  /// Returns [File] if exists and is valid, null otherwise
  Future<File?> getCachedFile(String mediaId) async {
    await initialize();

    final file = File('${_cacheDir!.path}/$mediaId');
    if (await file.exists()) {
      logger.d('Cache hit for mediaId: $mediaId');
      return file;
    }

    logger.d('Cache miss for mediaId: $mediaId');
    return null;
  }

  /// Get cached file data as bytes
  ///
  /// Returns file data if cached, null otherwise
  Future<Uint8List?> getCachedFileData(String mediaId) async {
    final file = await getCachedFile(mediaId);
    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }

  /// Save file data to cache
  ///
  /// [mediaId] - Unique identifier for the media
  /// [data] - File data to cache
  /// [mimeType] - Optional MIME type for metadata (not used currently)
  Future<File> saveToCache(
    String mediaId,
    Uint8List data, {
    String? mimeType,
  }) async {
    await initialize();

    final file = File('${_cacheDir!.path}/$mediaId');
    await file.writeAsBytes(data);

    logger.d('Saved ${data.length} bytes to cache for mediaId: $mediaId');
    return file;
  }

  /// Get cached thumbnail for a media ID
  ///
  /// Returns [File] if exists, null otherwise
  Future<File?> getCachedThumbnail(String mediaId) async {
    await initialize();

    final file = File('${_cacheDir!.path}/$_thumbnailCacheSubdir/$mediaId');
    if (await file.exists()) {
      logger.d('Thumbnail cache hit for mediaId: $mediaId');
      return file;
    }

    logger.d('Thumbnail cache miss for mediaId: $mediaId');
    return null;
  }

  /// Save thumbnail data to cache
  Future<File> saveThumbnailToCache(String mediaId, Uint8List data) async {
    await initialize();

    final file = File('${_cacheDir!.path}/$_thumbnailCacheSubdir/$mediaId');
    await file.writeAsBytes(data);

    logger.d('Saved thumbnail ${data.length} bytes for mediaId: $mediaId');
    return file;
  }

  /// Delete cached file for a media ID
  Future<void> deleteCachedFile(String mediaId) async {
    await initialize();

    final file = File('${_cacheDir!.path}/$mediaId');
    if (await file.exists()) {
      await file.delete();
      logger.d('Deleted cached file for mediaId: $mediaId');
    }

    // Also delete thumbnail if exists
    final thumbnail =
        File('${_cacheDir!.path}/$_thumbnailCacheSubdir/$mediaId');
    if (await thumbnail.exists()) {
      await thumbnail.delete();
      logger.d('Deleted cached thumbnail for mediaId: $mediaId');
    }
  }

  /// Clear entire media cache
  ///
  /// Returns the number of bytes freed
  Future<int> clearCache() async {
    await initialize();

    var freedBytes = 0;

    try {
      if (await _cacheDir!.exists()) {
        final entities = await _cacheDir!.list(recursive: true).toList();

        for (final entity in entities) {
          if (entity is File) {
            final size = await entity.length();
            await entity.delete();
            freedBytes += size;
          }
        }

        // Recreate directory structure
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
        final thumbnailDir =
            Directory('${_cacheDir!.path}/$_thumbnailCacheSubdir');
        await thumbnailDir.create(recursive: true);
      }

      logger.i('Cleared media cache, freed $freedBytes bytes');
    } catch (e) {
      logger.e('Error clearing cache: $e');
    }

    return freedBytes;
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    await initialize();

    var totalSize = 0;

    try {
      if (await _cacheDir!.exists()) {
        final entities = await _cacheDir!.list(recursive: true).toList();

        for (final entity in entities) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      logger.e('Error calculating cache size: $e');
    }

    return totalSize;
  }

  /// Get number of cached items
  Future<int> getCachedItemCount() async {
    await initialize();

    var count = 0;

    try {
      if (await _cacheDir!.exists()) {
        final entities = await _cacheDir!.list().toList();

        for (final entity in entities) {
          if (entity is File) {
            count++;
          }
        }
      }
    } catch (e) {
      logger.e('Error counting cached items: $e');
    }

    return count;
  }

  /// Check if a file is cached
  Future<bool> isCached(String mediaId) async {
    await initialize();

    final file = File('${_cacheDir!.path}/$mediaId');
    return await file.exists();
  }

  /// Get cache stats
  Future<CacheStats> getCacheStats() async {
    final size = await getCacheSize();
    final count = await getCachedItemCount();

    return CacheStats(
      totalSizeBytes: size,
      itemCount: count,
      cachePath: _cacheDir?.path ?? '',
    );
  }

  /// Clean old cache entries based on age
  ///
  /// [maxAge] - Maximum age for cache entries
  /// Returns number of files deleted
  Future<int> cleanOldEntries(Duration maxAge) async {
    await initialize();

    var deletedCount = 0;
    final cutoff = DateTime.now().subtract(maxAge);

    try {
      if (await _cacheDir!.exists()) {
        final entities = await _cacheDir!.list(recursive: true).toList();

        for (final entity in entities) {
          if (entity is File) {
            final stat = await entity.stat();
            if (stat.modified.isBefore(cutoff)) {
              await entity.delete();
              deletedCount++;
            }
          }
        }
      }

      logger.i('Cleaned $deletedCount old cache entries');
    } catch (e) {
      logger.e('Error cleaning old entries: $e');
    }

    return deletedCount;
  }
}

/// Statistics about the media cache
class CacheStats {
  final int totalSizeBytes;
  final int itemCount;
  final String cachePath;

  const CacheStats({
    required this.totalSizeBytes,
    required this.itemCount,
    required this.cachePath,
  });

  /// Get formatted size string
  String get formattedSize {
    if (totalSizeBytes < 1024) {
      return '$totalSizeBytes B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  @override
  String toString() => 'CacheStats($itemCount items, $formattedSize)';
}
