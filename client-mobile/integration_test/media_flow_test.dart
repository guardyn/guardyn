/// Media Flow Integration Test
///
/// Tests media caching and local storage operations.
/// Does not require a running backend server.
///
/// Run with:
/// ```bash
/// flutter test integration_test/media_flow_test.dart -d emulator-5554
/// ```
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/data/datasources/media_local_datasource.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MediaLocalDatasource localDatasource;

  setUpAll(() async {
    print('\n🚀 Setting up media integration tests...');

    localDatasource = MediaLocalDatasource();
    await localDatasource.initialize();
    print('  ✅ MediaLocalDatasource ready');
  });

  tearDownAll(() async {
    print('\n🧹 Cleaning up...');
    await localDatasource.clearCache();
  });

  group('Media Local Cache Operations', () {
    testWidgets('should save and retrieve file from cache', (tester) async {
      print('\n💾 Testing file cache operations...');

      // Create test data
      final mediaId = 'test-media-${DateTime.now().millisecondsSinceEpoch}';
      final testData = await _createTestPngBytes();

      // Save to cache
      final cachedFile = await localDatasource.saveToCache(
        mediaId,
        testData,
        mimeType: 'image/png',
      );
      expect(cachedFile.existsSync(), isTrue);
      print('  ✅ Saved file to cache: ${cachedFile.path}');

      // Get cached file
      final retrieved = await localDatasource.getCachedFile(mediaId);
      expect(retrieved, isNotNull);
      expect(await retrieved!.length(), equals(testData.length));
      print('  ✅ Retrieved cached file: ${await retrieved.length()} bytes');

      // Get cached data
      final retrievedData = await localDatasource.getCachedFileData(mediaId);
      expect(retrievedData, isNotNull);
      expect(retrievedData!.length, equals(testData.length));
      print('  ✅ Retrieved cached data: ${retrievedData.length} bytes');

      // Delete cached file
      await localDatasource.deleteCachedFile(mediaId);
      final afterDelete = await localDatasource.getCachedFile(mediaId);
      expect(afterDelete, isNull);
      print('  ✅ Deleted cached file');
    });

    testWidgets('should save and retrieve thumbnail', (tester) async {
      print('\n🖼️ Testing thumbnail cache operations...');

      final mediaId = 'test-thumb-${DateTime.now().millisecondsSinceEpoch}';
      final thumbnailData = await _createTestPngBytes();

      // Save thumbnail to cache
      final cachedThumbnail = await localDatasource.saveThumbnailToCache(
        mediaId,
        thumbnailData,
      );
      expect(cachedThumbnail.existsSync(), isTrue);
      print('  ✅ Saved thumbnail to cache: ${cachedThumbnail.path}');

      // Get cached thumbnail
      final retrieved = await localDatasource.getCachedThumbnail(mediaId);
      expect(retrieved, isNotNull);
      expect(await retrieved!.length(), equals(thumbnailData.length));
      print('  ✅ Retrieved cached thumbnail: ${await retrieved.length()} bytes');

      // Cleanup
      await localDatasource.deleteCachedFile(mediaId);
    });

    testWidgets('should calculate cache size', (tester) async {
      print('\n📊 Testing cache size calculation...');

      // Add some files to cache
      for (var i = 0; i < 5; i++) {
        final mediaId = 'size-test-$i-${DateTime.now().millisecondsSinceEpoch}';
        final data = await _createTestPngBytes();
        await localDatasource.saveToCache(mediaId, data);
      }

      // Get cache size
      final size = await localDatasource.getCacheSize();
      expect(size, greaterThan(0));
      print('  ✅ Cache size: $size bytes');

      // Get item count
      final count = await localDatasource.getCachedItemCount();
      expect(count, greaterThanOrEqualTo(5));
      print('  ✅ Cached items: $count');
    });

    testWidgets('should clear entire cache', (tester) async {
      print('\n🗑️ Testing cache clearing...');

      // Add files
      for (var i = 0; i < 3; i++) {
        final mediaId = 'clear-test-$i-${DateTime.now().millisecondsSinceEpoch}';
        await localDatasource.saveToCache(mediaId, await _createTestPngBytes());
      }

      final sizeBefore = await localDatasource.getCacheSize();
      print('  📦 Cache size before clear: $sizeBefore bytes');

      // Clear cache
      final freedBytes = await localDatasource.clearCache();
      print('  ✅ Freed $freedBytes bytes');

      // Verify cleared
      final sizeAfter = await localDatasource.getCacheSize();
      expect(sizeAfter, equals(0));
      print('  ✅ Cache size after clear: $sizeAfter bytes');
    });

    testWidgets('should handle non-existent file gracefully', (tester) async {
      print('\n⚠️ Testing cache miss handling...');

      final nonExistentId = 'non-existent-${DateTime.now().millisecondsSinceEpoch}';

      // Try to get non-existent file
      final file = await localDatasource.getCachedFile(nonExistentId);
      expect(file, isNull);
      print('  ✅ Correctly returned null for non-existent file');

      // Try to get non-existent data
      final data = await localDatasource.getCachedFileData(nonExistentId);
      expect(data, isNull);
      print('  ✅ Correctly returned null for non-existent data');

      // Try to get non-existent thumbnail
      final thumb = await localDatasource.getCachedThumbnail(nonExistentId);
      expect(thumb, isNull);
      print('  ✅ Correctly returned null for non-existent thumbnail');

      // Delete should not throw for non-existent file
      await localDatasource.deleteCachedFile(nonExistentId);
      print('  ✅ Delete did not throw for non-existent file');
    });
  });
}

/// Create test PNG bytes (1x1 red pixel)
Future<Uint8List> _createTestPngBytes() async {
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 pixels
    0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
    0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
    0x54, 0x08, 0xD7, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
    0x00, 0x05, 0xFE, 0x02, 0xFE, 0xDC, 0xCC, 0x59,
    0xE7, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
    0x44, 0xAE, 0x42, 0x60, 0x82, // IEND chunk
  ]);
}
