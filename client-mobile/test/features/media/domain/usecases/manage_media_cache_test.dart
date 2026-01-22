import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/manage_media_cache.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late ManageMediaCache manageMediaCache;
  late MockMediaRepository mockRepository;

  setUp(() {
    mockRepository = MockMediaRepository();
    manageMediaCache = ManageMediaCache(mockRepository);
  });

  group('ManageMediaCache', () {
    test('clearAll clears entire cache', () async {
      when(() => mockRepository.clearCache(mediaId: null))
          .thenAnswer((_) async {});

      await manageMediaCache.clearAll();

      verify(() => mockRepository.clearCache(mediaId: null)).called(1);
    });

    test('clear clears specific media from cache', () async {
      const mediaId = 'media-123';

      when(() => mockRepository.clearCache(mediaId: mediaId))
          .thenAnswer((_) async {});

      await manageMediaCache.clear(mediaId: mediaId);

      verify(() => mockRepository.clearCache(mediaId: mediaId)).called(1);
    });

    test('clear throws for empty mediaId', () async {
      expect(
        () => manageMediaCache.clear(mediaId: ''),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_ARGUMENT',
        )),
      );
    });

    test('getSize returns cache size in bytes', () async {
      when(() => mockRepository.getCacheSize())
          .thenAnswer((_) async => 1024 * 1024 * 50);

      final result = await manageMediaCache.getSize();

      expect(result, 50 * 1024 * 1024);
    });

    test('getFormattedSize returns human-readable size', () async {
      // Test bytes
      when(() => mockRepository.getCacheSize()).thenAnswer((_) async => 500);
      expect(await manageMediaCache.getFormattedSize(), '500 B');

      // Test KB
      when(() => mockRepository.getCacheSize()).thenAnswer((_) async => 1536);
      expect(await manageMediaCache.getFormattedSize(), '1.5 KB');

      // Test MB
      when(() => mockRepository.getCacheSize())
          .thenAnswer((_) async => 2621440);
      expect(await manageMediaCache.getFormattedSize(), '2.5 MB');

      // Test GB
      when(() => mockRepository.getCacheSize())
          .thenAnswer((_) async => 1610612736);
      expect(await manageMediaCache.getFormattedSize(), '1.50 GB');
    });

    test('isCached returns true when media is cached', () async {
      const mediaId = 'media-123';

      when(() => mockRepository.getCachedPath(mediaId: mediaId))
          .thenAnswer((_) async => '/cache/$mediaId.jpg');

      final result = await manageMediaCache.isCached(mediaId: mediaId);

      expect(result, true);
    });

    test('isCached returns false when media is not cached', () async {
      const mediaId = 'media-456';

      when(() => mockRepository.getCachedPath(mediaId: mediaId))
          .thenAnswer((_) async => null);

      final result = await manageMediaCache.isCached(mediaId: mediaId);

      expect(result, false);
    });
  });
}
