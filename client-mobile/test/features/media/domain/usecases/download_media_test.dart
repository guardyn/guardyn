import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/download_media.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late DownloadMedia downloadMedia;
  late MockMediaRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepository = MockMediaRepository();
    downloadMedia = DownloadMedia(mockRepository);
  });

  group('DownloadMedia', () {
    const mediaId = 'media-123';
    final testData = Uint8List.fromList([1, 2, 3, 4, 5]);

    test('returns cached data when available', () async {
      when(() => mockRepository.getFromCache(mediaId: mediaId))
          .thenAnswer((_) async => testData);

      double? reportedProgress;
      final result = await downloadMedia(
        mediaId: mediaId,
        onProgress: (p) => reportedProgress = p,
      );

      expect(result, testData);
      expect(reportedProgress, 1.0);

      verify(() => mockRepository.getFromCache(mediaId: mediaId)).called(1);
      verifyNever(() => mockRepository.getDownloadUrl(mediaId: any(named: 'mediaId')));
    });

    test('downloads when not cached', () async {
      when(() => mockRepository.getFromCache(mediaId: mediaId))
          .thenAnswer((_) async => null);

      when(() => mockRepository.getDownloadUrl(mediaId: mediaId))
          .thenAnswer((_) async => DownloadUrlResult(
                mediaId: mediaId,
                presignedUrl: 'https://storage.example.com/download',
                expiresAt: DateTime.now().add(const Duration(hours: 1)),
              ));

      when(() => mockRepository.downloadFromPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async => testData);

      when(() => mockRepository.saveToCache(
            mediaId: mediaId,
            data: testData,
            filename: any(named: 'filename'),
          )).thenAnswer((_) async => '/cache/$mediaId');

      final result = await downloadMedia(mediaId: mediaId);

      expect(result, testData);

      verify(() => mockRepository.getFromCache(mediaId: mediaId)).called(1);
      verify(() => mockRepository.getDownloadUrl(mediaId: mediaId)).called(1);
      verify(() => mockRepository.downloadFromPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            onProgress: any(named: 'onProgress'),
          )).called(1);
      verify(() => mockRepository.saveToCache(
            mediaId: mediaId,
            data: testData,
            filename: any(named: 'filename'),
          )).called(1);
    });

    test('skips cache when skipCache is true', () async {
      when(() => mockRepository.getDownloadUrl(mediaId: mediaId))
          .thenAnswer((_) async => DownloadUrlResult(
                mediaId: mediaId,
                presignedUrl: 'https://storage.example.com/download',
                expiresAt: DateTime.now().add(const Duration(hours: 1)),
              ));

      when(() => mockRepository.downloadFromPresignedUrl(
            presignedUrl: any(named: 'presignedUrl'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async => testData);

      when(() => mockRepository.saveToCache(
            mediaId: mediaId,
            data: testData,
            filename: any(named: 'filename'),
          )).thenAnswer((_) async => '/cache/$mediaId');

      await downloadMedia(mediaId: mediaId, skipCache: true);

      verifyNever(() => mockRepository.getFromCache(mediaId: any(named: 'mediaId')));
      verify(() => mockRepository.getDownloadUrl(mediaId: mediaId)).called(1);
    });

    test('getUrl returns download URL result', () async {
      final expectedResult = DownloadUrlResult(
        mediaId: mediaId,
        presignedUrl: 'https://storage.example.com/download',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRepository.getDownloadUrl(mediaId: mediaId))
          .thenAnswer((_) async => expectedResult);

      final result = await downloadMedia.getUrl(mediaId: mediaId);

      expect(result.mediaId, mediaId);
      expect(result.presignedUrl, contains('download'));
    });

    test('getLocalPath returns cached path', () async {
      when(() => mockRepository.getCachedPath(mediaId: mediaId))
          .thenAnswer((_) async => '/cache/$mediaId.jpg');

      final result = await downloadMedia.getLocalPath(mediaId: mediaId);

      expect(result, '/cache/$mediaId.jpg');
    });

    test('getLocalPath returns null when not cached', () async {
      when(() => mockRepository.getCachedPath(mediaId: mediaId))
          .thenAnswer((_) async => null);

      final result = await downloadMedia.getLocalPath(mediaId: mediaId);

      expect(result, isNull);
    });
  });
}
