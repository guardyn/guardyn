import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/delete_media.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late DeleteMedia deleteMedia;
  late MockMediaRepository mockRepository;

  setUp(() {
    mockRepository = MockMediaRepository();
    deleteMedia = DeleteMedia(mockRepository);
  });

  group('DeleteMedia', () {
    const mediaId = 'media-123';

    test('deletes media from server and cache', () async {
      when(() => mockRepository.deleteMedia(mediaId: mediaId))
          .thenAnswer((_) async {});
      when(() => mockRepository.clearCache(mediaId: mediaId))
          .thenAnswer((_) async {});

      await deleteMedia(mediaId: mediaId);

      verify(() => mockRepository.deleteMedia(mediaId: mediaId)).called(1);
      verify(() => mockRepository.clearCache(mediaId: mediaId)).called(1);
    });

    test('throws for empty mediaId', () async {
      expect(
        () => deleteMedia(mediaId: ''),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_ARGUMENT',
        )),
      );
    });

    test('propagates repository exceptions', () async {
      when(() => mockRepository.deleteMedia(mediaId: mediaId))
          .thenThrow(MediaException('Not found', code: 'NOT_FOUND'));

      expect(
        () => deleteMedia(mediaId: mediaId),
        throwsA(isA<MediaException>().having(
          (e) => e.isNotFound,
          'isNotFound',
          true,
        )),
      );
    });
  });
}
