import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/get_media_metadata.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late GetMediaMetadata getMediaMetadata;
  late MockMediaRepository mockRepository;

  setUp(() {
    mockRepository = MockMediaRepository();
    getMediaMetadata = GetMediaMetadata(mockRepository);
  });

  group('GetMediaMetadata', () {
    const mediaId = 'media-123';

    test('returns media metadata', () async {
      const expectedMedia = MediaEntity(
        id: mediaId,
        ownerUserId: 'user-456',
        filename: 'photo.jpg',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
        status: UploadStatus.completed,
        width: 1920,
        height: 1080,
      );

      when(() => mockRepository.getMetadata(mediaId: mediaId))
          .thenAnswer((_) async => expectedMedia);

      final result = await getMediaMetadata(mediaId: mediaId);

      expect(result.id, mediaId);
      expect(result.type, MediaType.image);
      expect(result.width, 1920);
      expect(result.height, 1080);
    });

    test('throws for empty mediaId', () async {
      expect(
        () => getMediaMetadata(mediaId: ''),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_ARGUMENT',
        )),
      );
    });

    test('propagates repository exceptions', () async {
      when(() => mockRepository.getMetadata(mediaId: mediaId))
          .thenThrow(MediaException('Not found', code: 'NOT_FOUND'));

      expect(
        () => getMediaMetadata(mediaId: mediaId),
        throwsA(isA<MediaException>().having(
          (e) => e.isNotFound,
          'isNotFound',
          true,
        )),
      );
    });
  });
}
