import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(MediaType.unknown);
  });

  group('MediaRepository interface', () {
    late MockMediaRepository mockRepository;

    setUp(() {
      mockRepository = MockMediaRepository();
    });

    test('getUploadUrl returns UploadUrlResult', () async {
      final expectedResult = UploadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://storage.example.com/upload',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRepository.getUploadUrl(
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
            sizeBytes: any(named: 'sizeBytes'),
            conversationId: any(named: 'conversationId'),
          )).thenAnswer((_) async => expectedResult);

      final result = await mockRepository.getUploadUrl(
        filename: 'test.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      );

      expect(result.mediaId, 'media-123');
      expect(result.isValid, true);
    });

    test('uploadToPresignedUrl completes successfully', () async {
      when(() => mockRepository.uploadToPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            data: any(named: 'data'),
            mimeType: any(named: 'mimeType'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async {});

      await expectLater(
        mockRepository.uploadToPresignedUrl(
          presignedUrl: 'https://storage.example.com/upload',
          data: Uint8List.fromList([1, 2, 3]),
          mimeType: 'image/jpeg',
        ),
        completes,
      );
    });

    test('getMetadata returns MediaEntity', () async {
      const expectedMedia = MediaEntity(
        id: 'media-123',
        ownerUserId: 'user-456',
        filename: 'photo.jpg',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
        status: UploadStatus.completed,
      );

      when(() => mockRepository.getMetadata(mediaId: any(named: 'mediaId')))
          .thenAnswer((_) async => expectedMedia);

      final result = await mockRepository.getMetadata(mediaId: 'media-123');

      expect(result.id, 'media-123');
      expect(result.type, MediaType.image);
      expect(result.status, UploadStatus.completed);
    });

    test('listMedia returns MediaListResult', () async {
      const expectedList = MediaListResult(
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
        totalCount: 10,
      );

      when(() => mockRepository.listMedia(
            conversationId: any(named: 'conversationId'),
            type: any(named: 'type'),
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          )).thenAnswer((_) async => expectedList);

      final result = await mockRepository.listMedia(
        conversationId: 'conv-123',
        type: MediaType.image,
        limit: 50,
      );

      expect(result.media.length, 2);
      expect(result.hasMore, true);
      expect(result.totalCount, 10);
    });

    test('deleteMedia completes successfully', () async {
      when(() => mockRepository.deleteMedia(mediaId: any(named: 'mediaId')))
          .thenAnswer((_) async {});

      await expectLater(
        mockRepository.deleteMedia(mediaId: 'media-123'),
        completes,
      );
    });

    test('getThumbnailUrl returns URL or null', () async {
      when(() => mockRepository.getThumbnailUrl(mediaId: 'media-with-thumb'))
          .thenAnswer((_) async => 'https://storage.example.com/thumb.jpg');
      when(() => mockRepository.getThumbnailUrl(mediaId: 'media-no-thumb'))
          .thenAnswer((_) async => null);

      final result1 = await mockRepository.getThumbnailUrl(
        mediaId: 'media-with-thumb',
      );
      expect(result1, isNotNull);

      final result2 = await mockRepository.getThumbnailUrl(
        mediaId: 'media-no-thumb',
      );
      expect(result2, isNull);
    });

    test('saveToCache returns local path', () async {
      when(() => mockRepository.saveToCache(
            mediaId: any(named: 'mediaId'),
            data: any(named: 'data'),
            filename: any(named: 'filename'),
          )).thenAnswer((_) async => '/cache/media-123.jpg');

      final result = await mockRepository.saveToCache(
        mediaId: 'media-123',
        data: Uint8List.fromList([1, 2, 3]),
      );

      expect(result, '/cache/media-123.jpg');
    });

    test('getFromCache returns cached data or null', () async {
      when(() => mockRepository.getFromCache(mediaId: 'cached'))
          .thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => mockRepository.getFromCache(mediaId: 'not-cached'))
          .thenAnswer((_) async => null);

      final result1 = await mockRepository.getFromCache(mediaId: 'cached');
      expect(result1, isNotNull);

      final result2 = await mockRepository.getFromCache(mediaId: 'not-cached');
      expect(result2, isNull);
    });

    test('getCacheSize returns size in bytes', () async {
      when(() => mockRepository.getCacheSize())
          .thenAnswer((_) async => 1024 * 1024 * 50); // 50 MB

      final result = await mockRepository.getCacheSize();
      expect(result, 50 * 1024 * 1024);
    });
  });

  group('MediaException', () {
    test('toString includes message and code', () {
      final exception = MediaException('Test error', code: 'TEST_CODE');
      expect(exception.toString(), 'MediaException: Test error (code: TEST_CODE)');
    });

    test('toString works without code', () {
      final exception = MediaException('Test error');
      expect(exception.toString(), 'MediaException: Test error');
    });

    test('isNotFound returns true for NOT_FOUND code', () {
      final exception = MediaException('Not found', code: 'NOT_FOUND');
      expect(exception.isNotFound, true);
      expect(exception.isUnauthorized, false);
    });

    test('isUnauthorized returns true for auth codes', () {
      final exception1 = MediaException('Unauthorized', code: 'UNAUTHORIZED');
      expect(exception1.isUnauthorized, true);

      final exception2 = MediaException('Unauthenticated', code: 'UNAUTHENTICATED');
      expect(exception2.isUnauthorized, true);
    });

    test('isFileTooLarge returns true for FILE_TOO_LARGE code', () {
      final exception = MediaException('File too large', code: 'FILE_TOO_LARGE');
      expect(exception.isFileTooLarge, true);
    });

    test('isInvalidFileType returns true for INVALID_FILE_TYPE code', () {
      final exception = MediaException('Invalid file type', code: 'INVALID_FILE_TYPE');
      expect(exception.isInvalidFileType, true);
    });

    test('isNetworkError returns true for network codes', () {
      final exception1 = MediaException('Network error', code: 'NETWORK_ERROR');
      expect(exception1.isNetworkError, true);

      final exception2 = MediaException('Unavailable', code: 'UNAVAILABLE');
      expect(exception2.isNetworkError, true);
    });

    test('isQuotaExceeded returns true for QUOTA_EXCEEDED code', () {
      final exception = MediaException('Quota exceeded', code: 'QUOTA_EXCEEDED');
      expect(exception.isQuotaExceeded, true);
    });
  });
}
