import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/data/datasources/media_local_datasource.dart';
import 'package:guardyn_client/features/media/data/datasources/media_remote_datasource.dart';
import 'package:guardyn_client/features/media/data/repositories/media_repository_impl.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/generated/media.pb.dart' as pb;
import 'package:mocktail/mocktail.dart';

// Mocks
class MockMediaRemoteDatasource extends Mock implements MediaRemoteDatasource {}

class MockMediaLocalDatasource extends Mock implements MediaLocalDatasource {}

class MockFile extends Mock implements File {}

void main() {
  late MockMediaRemoteDatasource mockRemoteDatasource;
  late MockMediaLocalDatasource mockLocalDatasource;
  late MediaRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(pb.MediaType.MEDIA_TYPE_UNKNOWN);
  });

  setUp(() {
    mockRemoteDatasource = MockMediaRemoteDatasource();
    mockLocalDatasource = MockMediaLocalDatasource();

    repository = MediaRepositoryImpl(
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocalDatasource,
    );
  });

  group('MediaRepositoryImpl', () {
    group('getUploadUrl', () {
      test('returns UploadUrlResult on success', () async {
        // Arrange
        final response = pb.GetUploadUrlResponse()
          ..mediaId = 'media-123'
          ..uploadUrl = 'https://storage.example.com/upload'
          ..expiresAt = Int64(1700000000);

        when(() => mockRemoteDatasource.getUploadUrl(
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
              sizeBytes: any(named: 'sizeBytes'),
              conversationId: any(named: 'conversationId'),
            )).thenAnswer((_) async => response);

        // Act
        final result = await repository.getUploadUrl(
          filename: 'test.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1024,
        );

        // Assert
        expect(result.mediaId, 'media-123');
        expect(result.presignedUrl, 'https://storage.example.com/upload');
        expect(result.expiresAt, isNotNull);
      });

      test('passes conversationId to datasource', () async {
        // Arrange
        final response = pb.GetUploadUrlResponse()
          ..mediaId = 'media-123'
          ..uploadUrl = 'https://storage.example.com/upload'
          ..expiresAt = Int64(1700000000);

        when(() => mockRemoteDatasource.getUploadUrl(
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
              sizeBytes: any(named: 'sizeBytes'),
              conversationId: 'conv-456',
            )).thenAnswer((_) async => response);

        // Act
        await repository.getUploadUrl(
          filename: 'test.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1024,
          conversationId: 'conv-456',
        );

        // Assert
        verify(() => mockRemoteDatasource.getUploadUrl(
              filename: 'test.jpg',
              mimeType: 'image/jpeg',
              sizeBytes: 1024,
              conversationId: 'conv-456',
            )).called(1);
      });
    });

    group('uploadToPresignedUrl', () {
      test('delegates to remote datasource', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(() => mockRemoteDatasource.uploadToPresignedUrl(
              presignedUrl: any(named: 'presignedUrl'),
              data: any(named: 'data'),
              mimeType: any(named: 'mimeType'),
              headers: any(named: 'headers'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async {});

        // Act
        await repository.uploadToPresignedUrl(
          presignedUrl: 'https://storage.example.com/upload',
          data: testData,
          mimeType: 'image/jpeg',
        );

        // Assert
        verify(() => mockRemoteDatasource.uploadToPresignedUrl(
              presignedUrl: 'https://storage.example.com/upload',
              data: testData,
              mimeType: 'image/jpeg',
              headers: null,
              onProgress: null,
            )).called(1);
      });
    });

    group('getDownloadUrl', () {
      test('returns DownloadUrlResult on success', () async {
        // Arrange
        final response = pb.GetDownloadUrlResponse()
          ..downloadUrl = 'https://storage.example.com/download'
          ..expiresAt = Int64(1700000000);

        when(() => mockRemoteDatasource.getDownloadUrl(
              mediaId: any(named: 'mediaId'),
            )).thenAnswer((_) async => response);

        // Act
        final result = await repository.getDownloadUrl(mediaId: 'media-123');

        // Assert
        expect(result.mediaId, 'media-123');
        expect(result.presignedUrl, 'https://storage.example.com/download');
      });
    });

    group('downloadFromPresignedUrl', () {
      test('returns bytes from remote datasource', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(() => mockRemoteDatasource.downloadFromPresignedUrl(
              presignedUrl: any(named: 'presignedUrl'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => testData);

        // Act
        final result = await repository.downloadFromPresignedUrl(
          presignedUrl: 'https://storage.example.com/download',
        );

        // Assert
        expect(result, testData);
      });
    });

    group('getMetadata', () {
      test('returns MediaEntity on success', () async {
        // Arrange
        final metadata = pb.MediaMetadata()
          ..mediaId = 'media-123'
          ..ownerUserId = 'user-1'
          ..filename = 'test.jpg'
          ..mediaType = pb.MediaType.MEDIA_TYPE_IMAGE
          ..mimeType = 'image/jpeg'
          ..sizeBytes = Int64(1024)
          ..status = pb.UploadStatus.UPLOAD_STATUS_COMPLETED
          ..createdAt = Int64(1700000000);

        final response = pb.GetMediaMetadataResponse()..metadata = metadata;

        when(() => mockRemoteDatasource.getMetadata(
              mediaId: any(named: 'mediaId'),
            )).thenAnswer((_) async => response);

        // Act
        final result = await repository.getMetadata(mediaId: 'media-123');

        // Assert
        expect(result.id, 'media-123');
        expect(result.ownerUserId, 'user-1');
        expect(result.filename, 'test.jpg');
        expect(result.type, MediaType.image);
        expect(result.status, UploadStatus.completed);
      });
    });

    group('listMedia', () {
      test('returns MediaListResult on success', () async {
        // Arrange
        final media1 = pb.MediaMetadata()
          ..mediaId = 'media-1'
          ..ownerUserId = 'user-1'
          ..filename = 'image1.jpg'
          ..mediaType = pb.MediaType.MEDIA_TYPE_IMAGE
          ..mimeType = 'image/jpeg'
          ..sizeBytes = Int64(1024)
          ..createdAt = Int64(1700000000);

        final media2 = pb.MediaMetadata()
          ..mediaId = 'media-2'
          ..ownerUserId = 'user-1'
          ..filename = 'video1.mp4'
          ..mediaType = pb.MediaType.MEDIA_TYPE_VIDEO
          ..mimeType = 'video/mp4'
          ..sizeBytes = Int64(5000000)
          ..createdAt = Int64(1700000001);

        final response = pb.ListMediaResponse()
          ..items.addAll([media1, media2])
          ..nextCursor = 'cursor-123'
          ..totalCount = 10;

        when(() => mockRemoteDatasource.listMedia(
              conversationId: any(named: 'conversationId'),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
              cursor: any(named: 'cursor'),
            )).thenAnswer((_) async => response);

        // Act
        final result = await repository.listMedia(conversationId: 'conv-123');

        // Assert
        expect(result.media.length, 2);
        expect(result.media[0].id, 'media-1');
        expect(result.media[0].type, MediaType.image);
        expect(result.media[1].id, 'media-2');
        expect(result.media[1].type, MediaType.video);
        expect(result.nextCursor, 'cursor-123');
        expect(result.totalCount, 10);
        expect(result.hasMore, isTrue);
      });

      test('filters by media type', () async {
        // Arrange
        final response = pb.ListMediaResponse()..totalCount = 0;

        when(() => mockRemoteDatasource.listMedia(
              conversationId: any(named: 'conversationId'),
              type: pb.MediaType.MEDIA_TYPE_IMAGE,
              limit: any(named: 'limit'),
              cursor: any(named: 'cursor'),
            )).thenAnswer((_) async => response);

        // Act
        await repository.listMedia(
          conversationId: 'conv-123',
          type: MediaType.image,
        );

        // Assert
        verify(() => mockRemoteDatasource.listMedia(
              conversationId: 'conv-123',
              type: pb.MediaType.MEDIA_TYPE_IMAGE,
              limit: 50,
              cursor: null,
            )).called(1);
      });
    });

    group('deleteMedia', () {
      test('deletes from remote and local', () async {
        // Arrange
        when(() => mockRemoteDatasource.deleteMedia(
              mediaId: any(named: 'mediaId'),
            )).thenAnswer((_) async {});

        when(() => mockLocalDatasource.deleteCachedFile(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteMedia(mediaId: 'media-123');

        // Assert
        verify(() => mockRemoteDatasource.deleteMedia(mediaId: 'media-123'))
            .called(1);
        verify(() => mockLocalDatasource.deleteCachedFile('media-123'))
            .called(1);
      });
    });

    group('getThumbnailUrl', () {
      test('returns download URL for thumbnail', () async {
        // Arrange
        final thumbnailResponse = pb.GenerateThumbnailResponse()
          ..thumbnailId = 'thumb-123';

        final downloadResponse = pb.GetDownloadUrlResponse()
          ..downloadUrl = 'https://storage.example.com/thumb'
          ..expiresAt = Int64(1700000000);

        when(() => mockRemoteDatasource.generateThumbnail(
              mediaId: any(named: 'mediaId'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
            )).thenAnswer((_) async => thumbnailResponse);

        when(() => mockRemoteDatasource.getDownloadUrl(
              mediaId: 'thumb-123',
            )).thenAnswer((_) async => downloadResponse);

        // Act
        final result = await repository.getThumbnailUrl(mediaId: 'media-123');

        // Assert
        expect(result, 'https://storage.example.com/thumb');
      });

      test('returns null when no thumbnail', () async {
        // Arrange
        final thumbnailResponse = pb.GenerateThumbnailResponse()
          ..thumbnailId = '';

        when(() => mockRemoteDatasource.generateThumbnail(
              mediaId: any(named: 'mediaId'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
            )).thenAnswer((_) async => thumbnailResponse);

        // Act
        final result = await repository.getThumbnailUrl(mediaId: 'media-123');

        // Assert
        expect(result, isNull);
      });
    });

    group('cache operations', () {
      test('saveToCache delegates to local datasource', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3]);
        final mockFile = MockFile();

        when(() => mockFile.path).thenReturn('/cache/media-123');
        when(() => mockLocalDatasource.saveToCache(any(), any()))
            .thenAnswer((_) async => mockFile);

        // Act
        final result = await repository.saveToCache(
          mediaId: 'media-123',
          data: testData,
        );

        // Assert
        expect(result, '/cache/media-123');
        verify(() => mockLocalDatasource.saveToCache('media-123', testData))
            .called(1);
      });

      test('getFromCache returns cached data', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3]);

        when(() => mockLocalDatasource.getCachedFileData(any()))
            .thenAnswer((_) async => testData);

        // Act
        final result = await repository.getFromCache(mediaId: 'media-123');

        // Assert
        expect(result, testData);
      });

      test('getCachedPath returns path when cached', () async {
        // Arrange
        final mockFile = MockFile();

        when(() => mockFile.path).thenReturn('/cache/media-123');
        when(() => mockLocalDatasource.getCachedFile(any()))
            .thenAnswer((_) async => mockFile);

        // Act
        final result = await repository.getCachedPath(mediaId: 'media-123');

        // Assert
        expect(result, '/cache/media-123');
      });

      test('clearCache clears specific file', () async {
        // Arrange
        when(() => mockLocalDatasource.deleteCachedFile(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.clearCache(mediaId: 'media-123');

        // Assert
        verify(() => mockLocalDatasource.deleteCachedFile('media-123'))
            .called(1);
      });

      test('clearCache clears all when no mediaId', () async {
        // Arrange
        when(() => mockLocalDatasource.clearCache())
            .thenAnswer((_) async => 1000);

        // Act
        await repository.clearCache();

        // Assert
        verify(() => mockLocalDatasource.clearCache()).called(1);
      });

      test('getCacheSize returns size from local datasource', () async {
        // Arrange
        when(() => mockLocalDatasource.getCacheSize())
            .thenAnswer((_) async => 5000);

        // Act
        final result = await repository.getCacheSize();

        // Assert
        expect(result, 5000);
      });
    });

    group('type conversions', () {
      test('converts all media types correctly', () async {
        // Test conversion for each type
        final types = [
          (pb.MediaType.MEDIA_TYPE_IMAGE, MediaType.image),
          (pb.MediaType.MEDIA_TYPE_VIDEO, MediaType.video),
          (pb.MediaType.MEDIA_TYPE_AUDIO, MediaType.audio),
          (pb.MediaType.MEDIA_TYPE_DOCUMENT, MediaType.document),
          (pb.MediaType.MEDIA_TYPE_UNKNOWN, MediaType.other),
        ];

        for (final (pbType, expectedType) in types) {
          // Arrange
          final metadata = pb.MediaMetadata()
            ..mediaId = 'media-123'
            ..ownerUserId = 'user-1'
            ..filename = 'test'
            ..mediaType = pbType
            ..mimeType = 'test/test'
            ..sizeBytes = Int64(100)
            ..createdAt = Int64(1700000000);

          final response = pb.GetMediaMetadataResponse()..metadata = metadata;

          when(() => mockRemoteDatasource.getMetadata(
                mediaId: any(named: 'mediaId'),
              )).thenAnswer((_) async => response);

          // Act
          final result = await repository.getMetadata(mediaId: 'media-123');

          // Assert
          expect(result.type, expectedType,
              reason: 'Failed for $pbType -> $expectedType');
        }
      });

      test('converts all upload statuses correctly', () async {
        // Test conversion for each status
        final statuses = [
          (pb.UploadStatus.UPLOAD_STATUS_PENDING, UploadStatus.pending),
          (pb.UploadStatus.UPLOAD_STATUS_PROCESSING, UploadStatus.processing),
          (pb.UploadStatus.UPLOAD_STATUS_COMPLETED, UploadStatus.completed),
          (pb.UploadStatus.UPLOAD_STATUS_FAILED, UploadStatus.failed),
          (pb.UploadStatus.UPLOAD_STATUS_UNKNOWN, UploadStatus.pending),
        ];

        for (final (pbStatus, expectedStatus) in statuses) {
          // Arrange
          final metadata = pb.MediaMetadata()
            ..mediaId = 'media-123'
            ..ownerUserId = 'user-1'
            ..filename = 'test'
            ..mediaType = pb.MediaType.MEDIA_TYPE_IMAGE
            ..mimeType = 'image/jpeg'
            ..sizeBytes = Int64(100)
            ..status = pbStatus
            ..createdAt = Int64(1700000000);

          final response = pb.GetMediaMetadataResponse()..metadata = metadata;

          when(() => mockRemoteDatasource.getMetadata(
                mediaId: any(named: 'mediaId'),
              )).thenAnswer((_) async => response);

          // Act
          final result = await repository.getMetadata(mediaId: 'media-123');

          // Assert
          expect(result.status, expectedStatus,
              reason: 'Failed for $pbStatus -> $expectedStatus');
        }
      });
    });
  });
}
