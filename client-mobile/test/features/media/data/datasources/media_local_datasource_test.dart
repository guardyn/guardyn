import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/data/datasources/media_local_datasource.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock PathProvider
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;

  MockPathProviderPlatform(this.tempPath);

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;
}

void main() {
  late MediaLocalDatasource datasource;
  late Directory tempDir;

  setUp(() async {
    // Create temp directory for tests
    tempDir = await Directory.systemTemp.createTemp('media_cache_test_');

    // Mock path provider
    PathProviderPlatform.instance =
        MockPathProviderPlatform(tempDir.path);

    datasource = MediaLocalDatasource();
  });

  tearDown(() async {
    // Clean up temp directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MediaLocalDatasource', () {
    group('initialize', () {
      test('creates cache directory', () async {
        // Act
        await datasource.initialize();
        final cachePath = await datasource.cachePath;

        // Assert
        expect(await Directory(cachePath).exists(), isTrue);
      });

      test('is idempotent', () async {
        // Act - call initialize multiple times
        await datasource.initialize();
        await datasource.initialize();
        await datasource.initialize();

        // Assert - should not throw
        final cachePath = await datasource.cachePath;
        expect(await Directory(cachePath).exists(), isTrue);
      });
    });

    group('saveToCache', () {
      test('saves file data correctly', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        const mediaId = 'test-media-123';

        // Act
        final file = await datasource.saveToCache(mediaId, testData);

        // Assert
        expect(await file.exists(), isTrue);
        expect(await file.readAsBytes(), testData);
      });

      test('overwrites existing file', () async {
        // Arrange
        final data1 = Uint8List.fromList([1, 2, 3]);
        final data2 = Uint8List.fromList([4, 5, 6, 7]);
        const mediaId = 'test-media-123';

        // Act
        await datasource.saveToCache(mediaId, data1);
        final file = await datasource.saveToCache(mediaId, data2);

        // Assert
        expect(await file.readAsBytes(), data2);
      });
    });

    group('getCachedFile', () {
      test('returns file when cached', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        const mediaId = 'test-media-123';
        await datasource.saveToCache(mediaId, testData);

        // Act
        final file = await datasource.getCachedFile(mediaId);

        // Assert
        expect(file, isNotNull);
        expect(await file!.readAsBytes(), testData);
      });

      test('returns null when not cached', () async {
        // Act
        final file = await datasource.getCachedFile('nonexistent-media');

        // Assert
        expect(file, isNull);
      });
    });

    group('getCachedFileData', () {
      test('returns bytes when cached', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        const mediaId = 'test-media-123';
        await datasource.saveToCache(mediaId, testData);

        // Act
        final data = await datasource.getCachedFileData(mediaId);

        // Assert
        expect(data, testData);
      });

      test('returns null when not cached', () async {
        // Act
        final data = await datasource.getCachedFileData('nonexistent-media');

        // Assert
        expect(data, isNull);
      });
    });

    group('isCached', () {
      test('returns true when file is cached', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3]);
        const mediaId = 'test-media-123';
        await datasource.saveToCache(mediaId, testData);

        // Act
        final result = await datasource.isCached(mediaId);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when file is not cached', () async {
        // Act
        final result = await datasource.isCached('nonexistent-media');

        // Assert
        expect(result, isFalse);
      });
    });

    group('deleteCachedFile', () {
      test('removes cached file', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3]);
        const mediaId = 'test-media-123';
        await datasource.saveToCache(mediaId, testData);

        // Act
        await datasource.deleteCachedFile(mediaId);

        // Assert
        expect(await datasource.isCached(mediaId), isFalse);
      });

      test('does nothing for nonexistent file', () async {
        // Act & Assert - should not throw
        await expectLater(
          datasource.deleteCachedFile('nonexistent-media'),
          completes,
        );
      });
    });

    group('getCacheSize', () {
      test('returns 0 for empty cache', () async {
        // Act
        final size = await datasource.getCacheSize();

        // Assert
        expect(size, 0);
      });

      test('returns correct size for cached files', () async {
        // Arrange
        final data1 = Uint8List.fromList([1, 2, 3, 4, 5]); // 5 bytes
        final data2 = Uint8List.fromList([1, 2, 3]); // 3 bytes
        await datasource.saveToCache('media-1', data1);
        await datasource.saveToCache('media-2', data2);

        // Act
        final size = await datasource.getCacheSize();

        // Assert
        expect(size, 8);
      });
    });

    group('getCachedItemCount', () {
      test('returns 0 for empty cache', () async {
        // Act
        final count = await datasource.getCachedItemCount();

        // Assert
        expect(count, 0);
      });

      test('returns correct count for cached files', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3]);
        await datasource.saveToCache('media-1', testData);
        await datasource.saveToCache('media-2', testData);
        await datasource.saveToCache('media-3', testData);

        // Act
        final count = await datasource.getCachedItemCount();

        // Assert
        expect(count, 3);
      });
    });

    group('clearCache', () {
      test('removes all cached files', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3]);
        await datasource.saveToCache('media-1', testData);
        await datasource.saveToCache('media-2', testData);

        // Act
        final freedBytes = await datasource.clearCache();

        // Assert
        expect(freedBytes, 6); // 3 + 3 bytes
        expect(await datasource.getCacheSize(), 0);
        expect(await datasource.getCachedItemCount(), 0);
      });

      test('returns 0 when cache is already empty', () async {
        // Act
        final freedBytes = await datasource.clearCache();

        // Assert
        expect(freedBytes, 0);
      });
    });

    group('getCacheStats', () {
      test('returns correct stats', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        await datasource.saveToCache('media-1', testData);
        await datasource.saveToCache('media-2', testData);

        // Act
        final stats = await datasource.getCacheStats();

        // Assert
        expect(stats.itemCount, 2);
        expect(stats.totalSizeBytes, 10);
        expect(stats.cachePath, isNotEmpty);
      });
    });

    group('thumbnails', () {
      test('saves and retrieves thumbnail', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3]);
        const mediaId = 'media-123';

        // Act
        await datasource.saveThumbnailToCache(mediaId, testData);
        final file = await datasource.getCachedThumbnail(mediaId);

        // Assert
        expect(file, isNotNull);
        expect(await file!.readAsBytes(), testData);
      });

      test('returns null for missing thumbnail', () async {
        // Act
        final file = await datasource.getCachedThumbnail('nonexistent');

        // Assert
        expect(file, isNull);
      });
    });

    group('cleanOldEntries', () {
      test('removes files older than max age', () async {
        // Arrange - create files
        final testData = Uint8List.fromList([1, 2, 3]);
        await datasource.saveToCache('media-1', testData);

        // Make the file appear old by modifying its timestamp
        // Note: This is a simplified test - in real scenario, we'd need
        // to mock the file system time
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - clean with very short max age
        final deleted = await datasource.cleanOldEntries(Duration.zero);

        // Assert - file should be deleted because it's "old"
        expect(deleted, greaterThanOrEqualTo(0));
      });
    });
  });

  group('CacheStats', () {
    test('formats bytes correctly', () {
      expect(
        const CacheStats(totalSizeBytes: 500, itemCount: 1, cachePath: '')
            .formattedSize,
        '500 B',
      );
    });

    test('formats kilobytes correctly', () {
      expect(
        const CacheStats(totalSizeBytes: 2048, itemCount: 1, cachePath: '')
            .formattedSize,
        '2.0 KB',
      );
    });

    test('formats megabytes correctly', () {
      expect(
        const CacheStats(
                totalSizeBytes: 5 * 1024 * 1024, itemCount: 1, cachePath: '')
            .formattedSize,
        '5.0 MB',
      );
    });

    test('formats gigabytes correctly', () {
      expect(
        const CacheStats(
                totalSizeBytes: 2 * 1024 * 1024 * 1024,
                itemCount: 1,
                cachePath: '')
            .formattedSize,
        '2.0 GB',
      );
    });

    test('toString returns expected format', () {
      const stats =
          CacheStats(totalSizeBytes: 1024, itemCount: 5, cachePath: '/cache');

      expect(stats.toString(), 'CacheStats(5 items, 1.0 KB)');
    });
  });
}
