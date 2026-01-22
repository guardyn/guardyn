import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/delete_media.dart';
import 'package:guardyn_client/features/media/domain/usecases/download_media.dart';
import 'package:guardyn_client/features/media/domain/usecases/get_media_metadata.dart';
import 'package:guardyn_client/features/media/domain/usecases/get_thumbnail_url.dart';
import 'package:guardyn_client/features/media/domain/usecases/list_media.dart';
import 'package:guardyn_client/features/media/domain/usecases/manage_media_cache.dart';
import 'package:guardyn_client/features/media/domain/usecases/upload_media.dart';
import 'package:guardyn_client/features/media/presentation/bloc/media_bloc.dart';
import 'package:guardyn_client/features/media/presentation/bloc/media_event.dart';
import 'package:guardyn_client/features/media/presentation/bloc/media_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockUploadMedia extends Mock implements UploadMedia {}

class MockDownloadMedia extends Mock implements DownloadMedia {}

class MockListMedia extends Mock implements ListMedia {}

class MockGetMediaMetadata extends Mock implements GetMediaMetadata {}

class MockGetThumbnailUrl extends Mock implements GetThumbnailUrl {}

class MockDeleteMedia extends Mock implements DeleteMedia {}

class MockManageMediaCache extends Mock implements ManageMediaCache {}

void main() {
  late MediaBloc mediaBloc;
  late MockUploadMedia mockUploadMedia;
  late MockDownloadMedia mockDownloadMedia;
  late MockListMedia mockListMedia;
  late MockGetMediaMetadata mockGetMediaMetadata;
  late MockGetThumbnailUrl mockGetThumbnailUrl;
  late MockDeleteMedia mockDeleteMedia;
  late MockManageMediaCache mockManageMediaCache;

  // Test fixtures
  const testMediaId = 'media-123';
  const testFilename = 'test-image.jpg';
  const testMimeType = 'image/jpeg';
  const testConversationId = 'conv-456';

  final testMedia = const MediaEntity(
    id: testMediaId,
    ownerUserId: 'user-123',
    filename: testFilename,
    type: MediaType.image,
    mimeType: testMimeType,
    sizeBytes: 1024,
    status: UploadStatus.completed,
  );

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(MediaType.image);
  });

  setUp(() {
    mockUploadMedia = MockUploadMedia();
    mockDownloadMedia = MockDownloadMedia();
    mockListMedia = MockListMedia();
    mockGetMediaMetadata = MockGetMediaMetadata();
    mockGetThumbnailUrl = MockGetThumbnailUrl();
    mockDeleteMedia = MockDeleteMedia();
    mockManageMediaCache = MockManageMediaCache();

    mediaBloc = MediaBloc(
      uploadMedia: mockUploadMedia,
      downloadMedia: mockDownloadMedia,
      listMedia: mockListMedia,
      getMediaMetadata: mockGetMediaMetadata,
      getThumbnailUrl: mockGetThumbnailUrl,
      deleteMedia: mockDeleteMedia,
      manageMediaCache: mockManageMediaCache,
    );
  });

  tearDown(() {
    mediaBloc.close();
  });

  group('MediaBloc', () {
    test('initial state is MediaInitial', () {
      expect(mediaBloc.state, const MediaInitial());
    });

    group('MediaUploadFromBytesRequested', () {
      final testData = Uint8List.fromList(List.filled(1024, 0));

      blocTest<MediaBloc, MediaState>(
        'emits [MediaUploading, MediaUploadSuccess] when upload succeeds',
        build: () {
          when(() => mockUploadMedia.uploadData(
                data: any(named: 'data'),
                filename: testFilename,
                conversationId: any(named: 'conversationId'),
                onProgress: any(named: 'onProgress'),
              )).thenAnswer((_) async => testMedia);

          return mediaBloc;
        },
        act: (bloc) => bloc.add(MediaUploadFromBytesRequested(
          data: testData,
          filename: testFilename,
          mimeType: testMimeType,
        )),
        expect: () => [
          isA<MediaUploading>().having((s) => s.filename, 'filename', testFilename),
          isA<MediaUploadSuccess>().having((s) => s.media.id, 'media.id', testMediaId),
        ],
        verify: (_) {
          verify(() => mockUploadMedia.uploadData(
                data: any(named: 'data'),
                filename: testFilename,
                conversationId: any(named: 'conversationId'),
                onProgress: any(named: 'onProgress'),
              )).called(1);
        },
      );

      blocTest<MediaBloc, MediaState>(
        'emits [MediaUploading, MediaError] when upload fails',
        build: () {
          when(() => mockUploadMedia.uploadData(
                data: any(named: 'data'),
                filename: testFilename,
                conversationId: any(named: 'conversationId'),
                onProgress: any(named: 'onProgress'),
              )).thenThrow(MediaException(
            'Upload failed',
            code: 'UPLOAD_ERROR',
          ));

          return mediaBloc;
        },
        act: (bloc) => bloc.add(MediaUploadFromBytesRequested(
          data: testData,
          filename: testFilename,
          mimeType: testMimeType,
        )),
        expect: () => [
          isA<MediaUploading>(),
          isA<MediaError>()
              .having((s) => s.code, 'code', 'UPLOAD_ERROR')
              .having((s) => s.message, 'message', 'Upload failed'),
        ],
      );
    });

    group('MediaDownloadRequested', () {
      final testDownloadData = Uint8List.fromList(List.filled(1024, 0));

      blocTest<MediaBloc, MediaState>(
        'emits [MediaDownloading, MediaDownloadSuccess] when download succeeds',
        build: () {
          // Mock metadata fetch first
          when(() => mockGetMediaMetadata(mediaId: testMediaId))
              .thenAnswer((_) async => testMedia);

          // Mock download
          when(() => mockDownloadMedia(
                mediaId: testMediaId,
                onProgress: any(named: 'onProgress'),
                skipCache: any(named: 'skipCache'),
              )).thenAnswer((_) async => testDownloadData);

          // Mock getLocalPath
          when(() => mockDownloadMedia.getLocalPath(mediaId: testMediaId))
              .thenAnswer((_) async => '/path/to/cached/file.jpg');

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaDownloadRequested(
          mediaId: testMediaId,
        )),
        expect: () => [
          isA<MediaDownloading>().having((s) => s.mediaId, 'mediaId', testMediaId),
          isA<MediaDownloadSuccess>(),
        ],
      );

      blocTest<MediaBloc, MediaState>(
        'emits [MediaDownloading, MediaError] when download fails',
        build: () {
          // Mock metadata fetch - it's called first before download
          when(() => mockGetMediaMetadata(mediaId: testMediaId))
              .thenThrow(MediaException(
            'Download failed',
            code: 'DOWNLOAD_ERROR',
          ));

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaDownloadRequested(
          mediaId: testMediaId,
        )),
        expect: () => [
          isA<MediaDownloading>(),
          isA<MediaError>().having((s) => s.code, 'code', 'DOWNLOAD_ERROR'),
        ],
      );
    });

    group('MediaListRequested', () {
      final testMediaList = [testMedia];

      blocTest<MediaBloc, MediaState>(
        'emits [MediaLoading, MediaListLoaded] when list succeeds',
        build: () {
          when(() => mockListMedia(
                conversationId: testConversationId,
                type: any(named: 'type'),
                cursor: any(named: 'cursor'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => MediaListResult(
            media: testMediaList,
            nextCursor: null,
          ));

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaListRequested(
          conversationId: testConversationId,
        )),
        expect: () => [
          isA<MediaLoading>(),
          isA<MediaListLoaded>()
              .having((s) => s.media.length, 'media.length', 1)
              .having((s) => s.hasMore, 'hasMore', false),
        ],
      );

      blocTest<MediaBloc, MediaState>(
        'filters by media type when specified',
        build: () {
          when(() => mockListMedia(
                conversationId: testConversationId,
                type: MediaType.image,
                cursor: any(named: 'cursor'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => MediaListResult(
            media: testMediaList,
            nextCursor: 'next-cursor',
          ));

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaListRequested(
          conversationId: testConversationId,
          filterType: MediaType.image,
        )),
        expect: () => [
          isA<MediaLoading>(),
          isA<MediaListLoaded>()
              .having((s) => s.media.length, 'media.length', 1)
              .having((s) => s.hasMore, 'hasMore', true),
        ],
        verify: (_) {
          verify(() => mockListMedia(
                conversationId: testConversationId,
                type: MediaType.image,
                cursor: any(named: 'cursor'),
                limit: any(named: 'limit'),
              )).called(1);
        },
      );
    });

    group('MediaLoadMoreRequested', () {
      final testMediaList = [testMedia];

      blocTest<MediaBloc, MediaState>(
        'does not load more when state is not MediaListLoaded',
        build: () => mediaBloc,
        act: (bloc) => bloc.add(const MediaLoadMoreRequested(
          conversationId: testConversationId,
        )),
        expect: () => [],
      );

      blocTest<MediaBloc, MediaState>(
        'loads more items when there is a next cursor',
        build: () {
          // Set up the mock for listMedia to return new items
          when(() => mockListMedia(
                conversationId: testConversationId,
                type: any(named: 'type'),
                cursor: 'cursor-1',
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => MediaListResult(
            media: testMediaList,
            nextCursor: 'cursor-2',
          ));

          return mediaBloc;
        },
        seed: () => MediaListLoaded(
          media: testMediaList,
          hasMore: true,
          conversationId: testConversationId,
          nextCursor: 'cursor-1',
        ),
        act: (bloc) => bloc.add(const MediaLoadMoreRequested(
          conversationId: testConversationId,
        )),
        // loadMore uses copyWithMore which appends new items
        expect: () => [
          isA<MediaListLoaded>().having((s) => s.media.length, 'media.length', 2),
        ],
      );
    });

    group('MediaDeleteRequested', () {
      blocTest<MediaBloc, MediaState>(
        'emits [MediaLoading, MediaDeleteSuccess] when delete succeeds',
        build: () {
          when(() => mockDeleteMedia(mediaId: testMediaId))
              .thenAnswer((_) async {});

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaDeleteRequested(mediaId: testMediaId)),
        expect: () => [
          isA<MediaLoading>(),
          isA<MediaDeleteSuccess>().having((s) => s.mediaId, 'mediaId', testMediaId),
        ],
      );

      blocTest<MediaBloc, MediaState>(
        'emits [MediaLoading, MediaError] when delete fails',
        build: () {
          when(() => mockDeleteMedia(mediaId: testMediaId)).thenThrow(
            MediaException(
              'Delete failed',
              code: 'DELETE_ERROR',
            ),
          );

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaDeleteRequested(mediaId: testMediaId)),
        expect: () => [
          isA<MediaLoading>(),
          isA<MediaError>().having((s) => s.code, 'code', 'DELETE_ERROR'),
        ],
      );
    });

    group('MediaThumbnailRequested', () {
      blocTest<MediaBloc, MediaState>(
        'emits MediaThumbnailLoaded when thumbnail URL is retrieved',
        build: () {
          when(() => mockGetThumbnailUrl(
                mediaId: testMediaId,
              )).thenAnswer((_) async => 'https://cdn.example.com/thumb.jpg');

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaThumbnailRequested(
          mediaId: testMediaId,
        )),
        expect: () => [
          isA<MediaThumbnailLoaded>()
              .having((s) => s.mediaId, 'mediaId', testMediaId)
              .having(
                  (s) => s.thumbnailUrl, 'thumbnailUrl', 'https://cdn.example.com/thumb.jpg'),
        ],
      );
    });

    group('MediaCacheClearRequested', () {
      blocTest<MediaBloc, MediaState>(
        'emits MediaCacheCleared when cache is cleared',
        build: () {
          when(() => mockManageMediaCache.clearAll())
              .thenAnswer((_) async {});

          return mediaBloc;
        },
        act: (bloc) => bloc.add(const MediaCacheClearRequested()),
        expect: () => [
          isA<MediaCacheCleared>(),
        ],
      );
    });

    group('MediaReset', () {
      blocTest<MediaBloc, MediaState>(
        'resets to MediaInitial state',
        build: () => mediaBloc,
        seed: () => const MediaLoading(),
        act: (bloc) => bloc.add(const MediaReset()),
        expect: () => [isA<MediaInitial>()],
      );
    });

    group('Progress updates', () {
      blocTest<MediaBloc, MediaState>(
        'MediaUploadProgressUpdated updates progress in MediaUploading state',
        build: () => mediaBloc,
        seed: () => const MediaUploading(progress: 0.0, filename: testFilename),
        act: (bloc) => bloc.add(const MediaUploadProgressUpdated(progress: 0.5)),
        expect: () => [
          isA<MediaUploading>()
              .having((s) => s.progress, 'progress', 0.5)
              .having((s) => s.filename, 'filename', testFilename),
        ],
      );

      blocTest<MediaBloc, MediaState>(
        'MediaDownloadProgressUpdated updates progress in MediaDownloading state',
        build: () => mediaBloc,
        seed: () => const MediaDownloading(mediaId: testMediaId, progress: 0.0),
        act: (bloc) => bloc.add(const MediaDownloadProgressUpdated(
          progress: 0.75,
          mediaId: testMediaId,
        )),
        expect: () => [
          isA<MediaDownloading>()
              .having((s) => s.progress, 'progress', 0.75)
              .having((s) => s.mediaId, 'mediaId', testMediaId),
        ],
      );
    });
  });
}

