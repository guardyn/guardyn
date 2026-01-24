import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';

void main() {
  group('MediaType', () {
    test('fromProtoValue converts proto values correctly', () {
      expect(MediaType.fromProtoValue(0), MediaType.unknown);
      expect(MediaType.fromProtoValue(1), MediaType.image);
      expect(MediaType.fromProtoValue(2), MediaType.video);
      expect(MediaType.fromProtoValue(3), MediaType.audio);
      expect(MediaType.fromProtoValue(4), MediaType.document);
      expect(MediaType.fromProtoValue(5), MediaType.other);
      expect(MediaType.fromProtoValue(99), MediaType.unknown);
    });

    test('toProtoValue converts to proto values correctly', () {
      expect(MediaType.unknown.toProtoValue(), 0);
      expect(MediaType.image.toProtoValue(), 1);
      expect(MediaType.video.toProtoValue(), 2);
      expect(MediaType.audio.toProtoValue(), 3);
      expect(MediaType.document.toProtoValue(), 4);
      expect(MediaType.other.toProtoValue(), 5);
    });

    test('displayName returns correct names', () {
      expect(MediaType.image.displayName, 'Image');
      expect(MediaType.video.displayName, 'Video');
      expect(MediaType.audio.displayName, 'Audio');
      expect(MediaType.document.displayName, 'Document');
    });

    test('type checks work correctly', () {
      expect(MediaType.image.isImage, true);
      expect(MediaType.image.isVideo, false);
      expect(MediaType.video.isVideo, true);
      expect(MediaType.audio.isAudio, true);
      expect(MediaType.document.isDocument, true);
    });

    test('canDisplayInline is true for images and videos', () {
      expect(MediaType.image.canDisplayInline, true);
      expect(MediaType.video.canDisplayInline, true);
      expect(MediaType.audio.canDisplayInline, false);
      expect(MediaType.document.canDisplayInline, false);
    });

    test('canHaveThumbnail is true for images and videos', () {
      expect(MediaType.image.canHaveThumbnail, true);
      expect(MediaType.video.canHaveThumbnail, true);
      expect(MediaType.audio.canHaveThumbnail, false);
      expect(MediaType.document.canHaveThumbnail, false);
    });
  });

  group('UploadStatus', () {
    test('fromProtoValue converts proto values correctly', () {
      expect(UploadStatus.fromProtoValue(0), UploadStatus.unknown);
      expect(UploadStatus.fromProtoValue(1), UploadStatus.pending);
      expect(UploadStatus.fromProtoValue(2), UploadStatus.processing);
      expect(UploadStatus.fromProtoValue(3), UploadStatus.completed);
      expect(UploadStatus.fromProtoValue(4), UploadStatus.failed);
      expect(UploadStatus.fromProtoValue(99), UploadStatus.unknown);
    });

    test('toProtoValue converts to proto values correctly', () {
      expect(UploadStatus.unknown.toProtoValue(), 0);
      expect(UploadStatus.pending.toProtoValue(), 1);
      expect(UploadStatus.processing.toProtoValue(), 2);
      expect(UploadStatus.completed.toProtoValue(), 3);
      expect(UploadStatus.failed.toProtoValue(), 4);
    });

    test('status checks work correctly', () {
      expect(UploadStatus.pending.isInProgress, true);
      expect(UploadStatus.processing.isInProgress, true);
      expect(UploadStatus.completed.isInProgress, false);
      expect(UploadStatus.completed.isCompleted, true);
      expect(UploadStatus.failed.isFailed, true);
    });
  });

  group('MediaEntity', () {
    const testMedia = MediaEntity(
      id: 'media-123',
      ownerUserId: 'user-456',
      filename: 'photo.jpg',
      type: MediaType.image,
      mimeType: 'image/jpeg',
      sizeBytes: 1024 * 1024, // 1 MB
      status: UploadStatus.completed,
      width: 1920,
      height: 1080,
    );

    test('props returns correct values for equality', () {
      const media1 = MediaEntity(
        id: 'media-123',
        ownerUserId: 'user-456',
        filename: 'photo.jpg',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      );
      const media2 = MediaEntity(
        id: 'media-123',
        ownerUserId: 'user-456',
        filename: 'photo.jpg',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      );
      const media3 = MediaEntity(
        id: 'media-different',
        ownerUserId: 'user-456',
        filename: 'photo.jpg',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      );

      expect(media1, equals(media2));
      expect(media1, isNot(equals(media3)));
    });

    test('copyWith creates a copy with updated fields', () {
      final updated = testMedia.copyWith(filename: 'new_photo.jpg');

      expect(updated.id, testMedia.id);
      expect(updated.filename, 'new_photo.jpg');
      expect(updated.type, testMedia.type);
    });

    test('formattedSize returns correct format', () {
      const bytes = MediaEntity(
        id: '1',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 500,
      );
      expect(bytes.formattedSize, '500 B');

      const kb = MediaEntity(
        id: '2',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1536, // 1.5 KB
      );
      expect(kb.formattedSize, '1.5 KB');

      const mb = MediaEntity(
        id: '3',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 2621440, // 2.5 MB
      );
      expect(mb.formattedSize, '2.5 MB');

      const gb = MediaEntity(
        id: '4',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.video,
        mimeType: 'video/mp4',
        sizeBytes: 1610612736, // 1.5 GB
      );
      expect(gb.formattedSize, '1.50 GB');
    });

    test('formattedDuration returns correct format', () {
      const seconds = MediaEntity(
        id: '1',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.video,
        mimeType: 'video/mp4',
        sizeBytes: 1024,
        durationMs: 45000, // 45 seconds
      );
      expect(seconds.formattedDuration, '00:45');

      const minutes = MediaEntity(
        id: '2',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.video,
        mimeType: 'video/mp4',
        sizeBytes: 1024,
        durationMs: 125000, // 2:05
      );
      expect(minutes.formattedDuration, '02:05');

      const hours = MediaEntity(
        id: '3',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.video,
        mimeType: 'video/mp4',
        sizeBytes: 1024,
        durationMs: 3725000, // 1:02:05
      );
      expect(hours.formattedDuration, '01:02:05');

      const noDuration = MediaEntity(
        id: '4',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      );
      expect(noDuration.formattedDuration, null);
    });

    test('aspectRatio calculates correctly', () {
      expect(testMedia.aspectRatio, closeTo(1.778, 0.001)); // 16:9

      const noSize = MediaEntity(
        id: '1',
        ownerUserId: 'u1',
        filename: 'f1',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      );
      expect(noSize.aspectRatio, null);
    });

    test('isAvailableLocally returns true when localPath is set', () {
      expect(testMedia.isAvailableLocally, false);

      final cached = testMedia.copyWith(localPath: '/path/to/file.jpg');
      expect(cached.isAvailableLocally, true);
    });

    test('isReady returns true when status is completed', () {
      expect(testMedia.isReady, true);

      final pending = testMedia.copyWith(status: UploadStatus.pending);
      expect(pending.isReady, false);
    });

    test('extension extracts file extension correctly', () {
      expect(testMedia.extension, 'jpg');

      const noExt = MediaEntity(
        id: '1',
        ownerUserId: 'u1',
        filename: 'noextension',
        type: MediaType.document,
        mimeType: 'application/octet-stream',
        sizeBytes: 1024,
      );
      expect(noExt.extension, '');

      const doubleExt = MediaEntity(
        id: '2',
        ownerUserId: 'u1',
        filename: 'file.tar.gz',
        type: MediaType.document,
        mimeType: 'application/gzip',
        sizeBytes: 1024,
      );
      expect(doubleExt.extension, 'gz');
    });
  });

  group('UploadUrlResult', () {
    test('isValid returns true when not expired', () {
      final result = UploadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://example.com/upload',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(result.isValid, true);
    });

    test('isValid returns false when expired', () {
      final result = UploadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://example.com/upload',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(result.isValid, false);
    });

    test('timeUntilExpiration returns correct duration', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 30));
      final result = UploadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://example.com/upload',
        expiresAt: expiresAt,
      );

      final remaining = result.timeUntilExpiration;
      expect(remaining.inMinutes, closeTo(30, 1));
    });

    test('contentType returns Content-Type from headers', () {
      final result = UploadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://example.com/upload',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        headers: {'Content-Type': 'image/jpeg'},
      );
      expect(result.contentType, 'image/jpeg');
    });

    test('contentType returns null when no headers', () {
      final result = UploadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://example.com/upload',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(result.contentType, isNull);
    });

    test('headers defaults to empty map', () {
      final result = UploadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://example.com/upload',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(result.headers, isEmpty);
    });
  });

  group('DownloadUrlResult', () {
    test('isValid returns true when not expired', () {
      final result = DownloadUrlResult(
        mediaId: 'media-123',
        presignedUrl: 'https://example.com/download',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(result.isValid, true);
    });
  });

  group('MediaListResult', () {
    test('hasMore returns true when nextCursor is set', () {
      const result = MediaListResult(
        media: [],
        nextCursor: 'cursor-abc',
      );
      expect(result.hasMore, true);

      const noMore = MediaListResult(
        media: [],
      );
      expect(noMore.hasMore, false);
    });
  });
}
