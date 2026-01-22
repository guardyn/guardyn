import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/get_thumbnail_url.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late GetThumbnailUrl getThumbnailUrl;
  late MockMediaRepository mockRepository;

  setUp(() {
    mockRepository = MockMediaRepository();
    getThumbnailUrl = GetThumbnailUrl(mockRepository);
  });

  group('GetThumbnailUrl', () {
    const mediaId = 'media-123';

    test('returns thumbnail URL when available', () async {
      const expectedUrl = 'https://storage.example.com/thumb.jpg';

      when(() => mockRepository.getThumbnailUrl(mediaId: mediaId))
          .thenAnswer((_) async => expectedUrl);

      final result = await getThumbnailUrl(mediaId: mediaId);

      expect(result, expectedUrl);
    });

    test('returns null when no thumbnail available', () async {
      when(() => mockRepository.getThumbnailUrl(mediaId: mediaId))
          .thenAnswer((_) async => null);

      final result = await getThumbnailUrl(mediaId: mediaId);

      expect(result, isNull);
    });

    test('throws for empty mediaId', () async {
      expect(
        () => getThumbnailUrl(mediaId: ''),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_ARGUMENT',
        )),
      );
    });
  });
}
