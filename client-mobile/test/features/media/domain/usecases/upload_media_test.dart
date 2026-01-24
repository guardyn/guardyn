import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/upload_media.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late UploadMedia uploadMedia;
  late MockMediaRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepository = MockMediaRepository();
    uploadMedia = UploadMedia(mockRepository);
  });

  group('UploadMedia', () {
    test('uploadData succeeds with valid data', () async {
      final testData = Uint8List.fromList(List.filled(1024, 0));
      const filename = 'test.jpg';
      const mimeType = 'image/jpeg';
      const mediaId = 'media-123';

      // Setup mocks
      when(() => mockRepository.getUploadUrl(
            filename: filename,
            mimeType: mimeType,
            sizeBytes: testData.length,
            conversationId: null,
          )).thenAnswer((_) async => UploadUrlResult(
            mediaId: mediaId,
            presignedUrl: 'https://storage.example.com/upload',
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ));

      when(() => mockRepository.uploadToPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            data: any(named: 'data'),
            mimeType: any(named: 'mimeType'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async {});

      when(() => mockRepository.confirmUpload(
            mediaId: mediaId,
            checksumSha256: any(named: 'checksumSha256'),
          )).thenAnswer((_) async => const MediaEntity(
            id: mediaId,
            ownerUserId: 'user-123',
            filename: filename,
            type: MediaType.image,
            mimeType: mimeType,
            sizeBytes: 1024,
            status: UploadStatus.completed,
          ));

      final result = await uploadMedia.uploadData(
        data: testData,
        filename: filename,
      );

      expect(result.id, mediaId);
      expect(result.status, UploadStatus.completed);

      verify(() => mockRepository.getUploadUrl(
            filename: filename,
            mimeType: mimeType,
            sizeBytes: testData.length,
            conversationId: null,
          )).called(1);

      verify(() => mockRepository.uploadToPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            data: any(named: 'data'),
            mimeType: mimeType,
            onProgress: any(named: 'onProgress'),
          )).called(1);

      verify(() => mockRepository.confirmUpload(
            mediaId: mediaId,
            checksumSha256: any(named: 'checksumSha256'),
          )).called(1);
    });

    test('uploadData throws when file is too large', () async {
      final largeData = Uint8List(UploadMedia.maxFileSizeBytes + 1);

      expect(
        () => uploadMedia.uploadData(data: largeData, filename: 'large.bin'),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'FILE_TOO_LARGE',
        )),
      );

      verifyNever(() => mockRepository.getUploadUrl(
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
            sizeBytes: any(named: 'sizeBytes'),
            conversationId: any(named: 'conversationId'),
          ));
    });

    test('uploadData throws for disallowed file types', () async {
      final testData = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);

      expect(
        () => uploadMedia.uploadData(data: testData, filename: 'test.exe'),
        throwsA(isA<MediaException>().having(
          (e) => e.code,
          'code',
          'INVALID_FILE_TYPE',
        )),
      );
    });

    test('uploadData accepts allowed MIME types', () async {
      // Test with valid image data (JPEG header)
      final jpegHeader = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(100, 0)]);
      const filename = 'test.jpg';
      const mimeType = 'image/jpeg';
      const mediaId = 'media-123';

      when(() => mockRepository.getUploadUrl(
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
            sizeBytes: any(named: 'sizeBytes'),
            conversationId: any(named: 'conversationId'),
          )).thenAnswer((_) async => UploadUrlResult(
            mediaId: mediaId,
            presignedUrl: 'https://storage.example.com/upload',
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ));

      when(() => mockRepository.uploadToPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            data: any(named: 'data'),
            mimeType: any(named: 'mimeType'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async {});

      when(() => mockRepository.confirmUpload(
            mediaId: any(named: 'mediaId'),
            checksumSha256: any(named: 'checksumSha256'),
          )).thenAnswer((_) async => const MediaEntity(
            id: mediaId,
            ownerUserId: 'user-123',
            filename: filename,
            type: MediaType.image,
            mimeType: mimeType,
            sizeBytes: 104,
            status: UploadStatus.completed,
          ));

      final result = await uploadMedia.uploadData(
        data: jpegHeader,
        filename: filename,
      );

      expect(result.id, mediaId);
    });

    test('uploadData passes conversationId when provided', () async {
      final testData = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(100, 0)]);
      const conversationId = 'conv-456';
      const mediaId = 'media-123';

      when(() => mockRepository.getUploadUrl(
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
            sizeBytes: any(named: 'sizeBytes'),
            conversationId: conversationId,
          )).thenAnswer((_) async => UploadUrlResult(
            mediaId: mediaId,
            presignedUrl: 'https://storage.example.com/upload',
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ));

      when(() => mockRepository.uploadToPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            data: any(named: 'data'),
            mimeType: any(named: 'mimeType'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async {});

      when(() => mockRepository.confirmUpload(
            mediaId: any(named: 'mediaId'),
            checksumSha256: any(named: 'checksumSha256'),
          )).thenAnswer((_) async => const MediaEntity(
            id: mediaId,
            ownerUserId: 'user-123',
            filename: 'test.jpg',
            type: MediaType.image,
            mimeType: 'image/jpeg',
            sizeBytes: 104,
            status: UploadStatus.completed,
          ));

      await uploadMedia.uploadData(
        data: testData,
        filename: 'test.jpg',
        conversationId: conversationId,
      );

      verify(() => mockRepository.getUploadUrl(
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
            sizeBytes: any(named: 'sizeBytes'),
            conversationId: conversationId,
          )).called(1);
    });

    test('maxFileSizeBytes is 100 MB', () {
      expect(UploadMedia.maxFileSizeBytes, 100 * 1024 * 1024);
    });

    test('allowedMimeTypes includes common types', () {
      expect(UploadMedia.allowedMimeTypes, contains('image/jpeg'));
      expect(UploadMedia.allowedMimeTypes, contains('image/png'));
      expect(UploadMedia.allowedMimeTypes, contains('video/mp4'));
      expect(UploadMedia.allowedMimeTypes, contains('audio/mpeg'));
      expect(UploadMedia.allowedMimeTypes, contains('application/pdf'));
    });
  });
}
