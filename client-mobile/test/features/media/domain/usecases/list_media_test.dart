import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/list_media.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late ListMedia listMedia;
  late MockMediaRepository mockRepository;

  setUp(() {
    mockRepository = MockMediaRepository();
    listMedia = ListMedia(mockRepository);
  });

  group('ListMedia', () {
    const conversationId = 'conv-123';

    test('returns media list for conversation', () async {
      const expectedResult = MediaListResult(
        media: [
          MediaEntity(
            id: 'media-1',
            ownerUserId: 'user-1',
            filename: 'photo1.jpg',
            type: MediaType.image,
            mimeType: 'image/jpeg',
            sizeBytes: 1024,
          ),
          MediaEntity(
            id: 'media-2',
            ownerUserId: 'user-1',
            filename: 'photo2.jpg',
            type: MediaType.image,
            mimeType: 'image/jpeg',
            sizeBytes: 2048,
          ),
        ],
        nextCursor: 'cursor-abc',
      );

      when(() => mockRepository.listMedia(
            conversationId: conversationId,
            type: null,
            limit: 50,
            cursor: null,
          )).thenAnswer((_) async => expectedResult);

      final result = await listMedia(conversationId: conversationId);

      expect(result.media.length, 2);
      expect(result.hasMore, true);
    });

    test('filters by media type', () async {
      const expectedResult = MediaListResult(
        media: [
          MediaEntity(
            id: 'media-1',
            ownerUserId: 'user-1',
            filename: 'photo1.jpg',
            type: MediaType.image,
            mimeType: 'image/jpeg',
            sizeBytes: 1024,
          ),
        ],
      );

      when(() => mockRepository.listMedia(
            conversationId: conversationId,
            type: MediaType.image,
            limit: 50,
            cursor: null,
          )).thenAnswer((_) async => expectedResult);

      final result = await listMedia(
        conversationId: conversationId,
        type: MediaType.image,
      );

      expect(result.media.length, 1);
      expect(result.media.first.type, MediaType.image);
    });

    test('uses cursor for pagination', () async {
      const cursor = 'cursor-abc';
      const expectedResult = MediaListResult(
        media: [
          MediaEntity(
            id: 'media-3',
            ownerUserId: 'user-1',
            filename: 'photo3.jpg',
            type: MediaType.image,
            mimeType: 'image/jpeg',
            sizeBytes: 3072,
          ),
        ],
      );

      when(() => mockRepository.listMedia(
            conversationId: conversationId,
            type: null,
            limit: 50,
            cursor: cursor,
          )).thenAnswer((_) async => expectedResult);

      final result = await listMedia(
        conversationId: conversationId,
        cursor: cursor,
      );

      expect(result.media.length, 1);
      expect(result.hasMore, false);
    });

    test('throws for empty conversationId', () async {
      expect(
        () => listMedia(conversationId: ''),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_ARGUMENT',
        )),
      );
    });

    test('throws for invalid limit', () async {
      expect(
        () => listMedia(conversationId: conversationId, limit: 0),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_ARGUMENT',
        )),
      );

      expect(
        () => listMedia(conversationId: conversationId, limit: 101),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_ARGUMENT',
        )),
      );
    });

    test('getAll fetches all pages up to maxItems', () async {
      // First page
      when(() => mockRepository.listMedia(
            conversationId: conversationId,
            type: null,
            limit: 50,
            cursor: null,
          )).thenAnswer((_) async => MediaListResult(
            media: List.generate(
              50,
              (i) => MediaEntity(
                id: 'media-$i',
                ownerUserId: 'user-1',
                filename: 'photo$i.jpg',
                type: MediaType.image,
                mimeType: 'image/jpeg',
                sizeBytes: 1024,
              ),
            ),
            nextCursor: 'cursor-page2',
          ));

      // Second page
      when(() => mockRepository.listMedia(
            conversationId: conversationId,
            type: null,
            limit: 50,
            cursor: 'cursor-page2',
          )).thenAnswer((_) async => MediaListResult(
            media: List.generate(
              30,
              (i) => MediaEntity(
                id: 'media-${50 + i}',
                ownerUserId: 'user-1',
                filename: 'photo${50 + i}.jpg',
                type: MediaType.image,
                mimeType: 'image/jpeg',
                sizeBytes: 1024,
              ),
            ),
          ));

      final result = await listMedia.getAll(
        conversationId: conversationId,
        maxItems: 100,
      );

      expect(result.length, 80); // 50 + 30
    });

    test('getAll respects maxItems limit', () async {
      // First page with lots of items
      when(() => mockRepository.listMedia(
            conversationId: conversationId,
            type: null,
            limit: 50,
            cursor: null,
          )).thenAnswer((_) async => MediaListResult(
            media: List.generate(
              50,
              (i) => MediaEntity(
                id: 'media-$i',
                ownerUserId: 'user-1',
                filename: 'photo$i.jpg',
                type: MediaType.image,
                mimeType: 'image/jpeg',
                sizeBytes: 1024,
              ),
            ),
            nextCursor: 'cursor-page2',
          ));

      final result = await listMedia.getAll(
        conversationId: conversationId,
        maxItems: 25,
      );

      // Should return at most 25 items
      expect(result.length, 25);
    });
  });
}
