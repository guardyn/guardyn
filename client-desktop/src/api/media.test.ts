/**
 * Media API Unit Tests
 *
 * Tests for the media API module with mocked Tauri invoke.
 */

import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { DownloadUrlResult, MediaListResult, MediaMetadata, ThumbnailResult, UploadUrlResult } from './media';
import {
    clearMediaCache,
    deleteMedia,
    downloadMedia,
    downloadMediaFile,
    formatDuration,
    formatFileSize,
    generateThumbnail,
    getCachedMediaPath,
    getDownloadUrl,
    getFileExtension,
    getMediaCacheDir,
    getMediaMetadata,
    getThumbnailUrl,
    getUploadUrl,
    isPreviewable,
    listMedia,
    mediaTypeFromMime,
    uploadMedia,
    uploadMediaFile,
} from './media';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

describe('Media API', () => {
  beforeEach(() => {
    mockInvoke.mockClear();
  });

  describe('getUploadUrl', () => {
    it('calls invoke with correct parameters', async () => {
      const mockResult: UploadUrlResult = {
        mediaId: 'media-123',
        uploadUrl: 'https://storage.example.com/upload?signed=abc',
        expiresAt: Date.now() + 3600000,
        headers: { 'Content-Type': 'image/jpeg' },
      };
      mockInvoke.mockResolvedValueOnce(mockResult);

      const result = await getUploadUrl({
        filename: 'photo.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1024000,
        conversationId: 'conv-456',
      });

      expect(mockInvoke).toHaveBeenCalledWith('get_media_upload_url', {
        filename: 'photo.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1024000,
        conversationId: 'conv-456',
      });
      expect(result.mediaId).toBe('media-123');
      expect(result.uploadUrl).toContain('https://storage.example.com');
    });

    it('handles missing conversationId', async () => {
      const mockResult: UploadUrlResult = {
        mediaId: 'media-789',
        uploadUrl: 'https://storage.example.com/upload',
        expiresAt: Date.now() + 3600000,
        headers: {},
      };
      mockInvoke.mockResolvedValueOnce(mockResult);

      await getUploadUrl({
        filename: 'doc.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 500000,
      });

      expect(mockInvoke).toHaveBeenCalledWith('get_media_upload_url', {
        filename: 'doc.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 500000,
        conversationId: undefined,
      });
    });
  });

  describe('uploadMediaFile', () => {
    it('calls invoke with correct parameters', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await uploadMediaFile({
        filePath: '/tmp/photo.jpg',
        presignedUrl: 'https://storage.example.com/upload?signed=xyz',
        mimeType: 'image/jpeg',
      });

      expect(mockInvoke).toHaveBeenCalledWith('upload_media_file', {
        filePath: '/tmp/photo.jpg',
        presignedUrl: 'https://storage.example.com/upload?signed=xyz',
        mimeType: 'image/jpeg',
      });
    });

    it('throws on upload error', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Upload failed'));

      await expect(
        uploadMediaFile({
          filePath: '/tmp/missing.jpg',
          presignedUrl: 'https://storage.example.com/upload',
          mimeType: 'image/jpeg',
        }),
      ).rejects.toThrow('Upload failed');
    });
  });

  describe('getDownloadUrl', () => {
    it('returns download URL with metadata', async () => {
      const mockResult: DownloadUrlResult = {
        downloadUrl: 'https://storage.example.com/download/media-123',
        expiresAt: Date.now() + 3600000,
        metadata: {
          id: 'media-123',
          ownerUserId: 'user-456',
          filename: 'photo.jpg',
          type: 'image',
          mimeType: 'image/jpeg',
          sizeBytes: 1024000,
          checksumSha256: 'abc123',
          createdAt: Date.now(),
          updatedAt: Date.now(),
          status: 'completed',
          width: 1920,
          height: 1080,
          isEncrypted: false,
        },
      };
      mockInvoke.mockResolvedValueOnce(mockResult);

      const result = await getDownloadUrl('media-123');

      expect(mockInvoke).toHaveBeenCalledWith('get_media_download_url', { mediaId: 'media-123' });
      expect(result.downloadUrl).toContain('media-123');
      expect(result.metadata?.width).toBe(1920);
    });
  });

  describe('downloadMediaFile', () => {
    it('downloads file to specified path', async () => {
      mockInvoke.mockResolvedValueOnce('/home/user/Downloads/photo.jpg');

      const result = await downloadMediaFile(
        'https://storage.example.com/download/media-123',
        '/home/user/Downloads/photo.jpg',
      );

      expect(mockInvoke).toHaveBeenCalledWith('download_media_file', {
        downloadUrl: 'https://storage.example.com/download/media-123',
        savePath: '/home/user/Downloads/photo.jpg',
      });
      expect(result).toBe('/home/user/Downloads/photo.jpg');
    });
  });

  describe('getMediaMetadata', () => {
    it('returns full metadata', async () => {
      const mockMetadata: MediaMetadata = {
        id: 'media-123',
        ownerUserId: 'user-456',
        filename: 'video.mp4',
        type: 'video',
        mimeType: 'video/mp4',
        sizeBytes: 52428800,
        checksumSha256: 'def456',
        createdAt: Date.now(),
        updatedAt: Date.now(),
        status: 'completed',
        width: 1920,
        height: 1080,
        durationMs: 120000,
        thumbnailId: 'thumb-789',
        isEncrypted: true,
        conversationId: 'conv-123',
      };
      mockInvoke.mockResolvedValueOnce(mockMetadata);

      const result = await getMediaMetadata('media-123');

      expect(mockInvoke).toHaveBeenCalledWith('get_media_metadata', { mediaId: 'media-123' });
      expect(result.type).toBe('video');
      expect(result.durationMs).toBe(120000);
      expect(result.thumbnailId).toBe('thumb-789');
    });
  });

  describe('deleteMedia', () => {
    it('deletes media successfully', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await deleteMedia('media-123');

      expect(mockInvoke).toHaveBeenCalledWith('delete_media', { mediaId: 'media-123' });
    });

    it('throws on delete error', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Media not found'));

      await expect(deleteMedia('nonexistent')).rejects.toThrow('Media not found');
    });
  });

  describe('generateThumbnail', () => {
    it('generates thumbnail with options', async () => {
      const mockResult: ThumbnailResult = {
        thumbnailId: 'thumb-456',
        metadata: {
          id: 'thumb-456',
          ownerUserId: 'user-123',
          filename: 'thumbnail.jpg',
          type: 'image',
          mimeType: 'image/jpeg',
          sizeBytes: 10240,
          checksumSha256: 'ghi789',
          createdAt: Date.now(),
          updatedAt: Date.now(),
          status: 'completed',
          width: 256,
          height: 144,
          isEncrypted: false,
        },
      };
      mockInvoke.mockResolvedValueOnce(mockResult);

      const result = await generateThumbnail({
        mediaId: 'media-123',
        maxWidth: 256,
        maxHeight: 256,
        format: 'webp',
        quality: 85,
      });

      expect(mockInvoke).toHaveBeenCalledWith('generate_thumbnail', {
        mediaId: 'media-123',
        maxWidth: 256,
        maxHeight: 256,
        format: 'webp',
        quality: 85,
      });
      expect(result.thumbnailId).toBe('thumb-456');
    });
  });

  describe('listMedia', () => {
    it('lists media with filters', async () => {
      const mockResult: MediaListResult = {
        items: [
          {
            id: 'media-1',
            ownerUserId: 'user-123',
            filename: 'photo1.jpg',
            type: 'image',
            mimeType: 'image/jpeg',
            sizeBytes: 1024000,
            checksumSha256: 'abc',
            createdAt: Date.now(),
            updatedAt: Date.now(),
            status: 'completed',
            isEncrypted: false,
          },
          {
            id: 'media-2',
            ownerUserId: 'user-123',
            filename: 'photo2.jpg',
            type: 'image',
            mimeType: 'image/jpeg',
            sizeBytes: 2048000,
            checksumSha256: 'def',
            createdAt: Date.now(),
            updatedAt: Date.now(),
            status: 'completed',
            isEncrypted: false,
          },
        ],
        nextCursor: 'cursor-abc',
        totalCount: 10,
      };
      mockInvoke.mockResolvedValueOnce(mockResult);

      const result = await listMedia({
        conversationId: 'conv-123',
        mediaTypes: ['image'],
        limit: 20,
      });

      expect(mockInvoke).toHaveBeenCalledWith('list_media', {
        userId: undefined,
        conversationId: 'conv-123',
        mediaTypes: ['image'],
        limit: 20,
        cursor: undefined,
        sortBy: undefined,
        ascending: undefined,
      });
      expect(result.items).toHaveLength(2);
      expect(result.totalCount).toBe(10);
    });

    it('handles empty list', async () => {
      const mockResult: MediaListResult = {
        items: [],
        totalCount: 0,
      };
      mockInvoke.mockResolvedValueOnce(mockResult);

      const result = await listMedia({});

      expect(result.items).toHaveLength(0);
      expect(result.nextCursor).toBeUndefined();
    });
  });

  describe('cache operations', () => {
    it('gets cache directory', async () => {
      mockInvoke.mockResolvedValueOnce('/home/user/.cache/guardyn/media');

      const result = await getMediaCacheDir();

      expect(mockInvoke).toHaveBeenCalledWith('get_media_cache_dir');
      expect(result).toContain('media');
    });

    it('clears cache', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await clearMediaCache();

      expect(mockInvoke).toHaveBeenCalledWith('clear_media_cache');
    });

    it('gets cached media path', async () => {
      mockInvoke.mockResolvedValueOnce('/home/user/.cache/guardyn/media/media-123.jpg');

      const result = await getCachedMediaPath('media-123');

      expect(mockInvoke).toHaveBeenCalledWith('get_cached_media_path', { mediaId: 'media-123' });
      expect(result).toContain('media-123');
    });

    it('returns null for uncached media', async () => {
      mockInvoke.mockResolvedValueOnce(null);

      const result = await getCachedMediaPath('media-999');

      expect(result).toBeNull();
    });
  });
});

describe('Helper Functions', () => {
  beforeEach(() => {
    mockInvoke.mockClear();
  });

  describe('uploadMedia', () => {
    it('performs full upload flow', async () => {
      mockInvoke
        .mockResolvedValueOnce({
          mediaId: 'media-123',
          uploadUrl: 'https://storage.example.com/upload',
          expiresAt: Date.now() + 3600000,
          headers: {},
        })
        .mockResolvedValueOnce(undefined);

      const result = await uploadMedia(
        '/tmp/photo.jpg',
        'photo.jpg',
        'image/jpeg',
        1024000,
        'conv-456',
      );

      expect(mockInvoke).toHaveBeenCalledTimes(2);
      expect(result).toBe('media-123');
    });
  });

  describe('downloadMedia', () => {
    beforeEach(() => {
      mockInvoke.mockClear();
    });

    it('returns cached path if available', async () => {
      mockInvoke.mockResolvedValueOnce('/cache/media-123.jpg');

      const result = await downloadMedia('media-123', '/downloads/photo.jpg');

      expect(mockInvoke).toHaveBeenCalledTimes(1);
      expect(result.localPath).toBe('/cache/media-123.jpg');
    });

    it('downloads if not cached', async () => {
      mockInvoke
        .mockResolvedValueOnce(null) // getCachedMediaPath returns null
        .mockResolvedValueOnce({
          downloadUrl: 'https://storage.example.com/download',
          expiresAt: Date.now() + 3600000,
        })
        .mockResolvedValueOnce('/downloads/photo.jpg');

      const result = await downloadMedia('media-123', '/downloads/photo.jpg');

      expect(mockInvoke).toHaveBeenCalledTimes(3);
      expect(result.localPath).toBe('/downloads/photo.jpg');
    });
  });

  describe('getThumbnailUrl', () => {
    beforeEach(() => {
      mockInvoke.mockClear();
    });

    it('generates and returns thumbnail URL', async () => {
      mockInvoke
        .mockResolvedValueOnce({
          thumbnailId: 'thumb-123',
        })
        .mockResolvedValueOnce({
          downloadUrl: 'https://storage.example.com/thumb-123',
          expiresAt: Date.now() + 3600000,
        });

      const result = await getThumbnailUrl('media-123', { maxWidth: 128 });

      expect(mockInvoke).toHaveBeenCalledTimes(2);
      expect(result).toContain('thumb-123');
    });
  });

  describe('mediaTypeFromMime', () => {
    it('identifies image types', () => {
      expect(mediaTypeFromMime('image/jpeg')).toBe('image');
      expect(mediaTypeFromMime('image/png')).toBe('image');
      expect(mediaTypeFromMime('image/gif')).toBe('image');
      expect(mediaTypeFromMime('image/webp')).toBe('image');
    });

    it('identifies video types', () => {
      expect(mediaTypeFromMime('video/mp4')).toBe('video');
      expect(mediaTypeFromMime('video/webm')).toBe('video');
      expect(mediaTypeFromMime('video/quicktime')).toBe('video');
    });

    it('identifies audio types', () => {
      expect(mediaTypeFromMime('audio/mpeg')).toBe('audio');
      expect(mediaTypeFromMime('audio/wav')).toBe('audio');
      expect(mediaTypeFromMime('audio/ogg')).toBe('audio');
    });

    it('identifies document types', () => {
      expect(mediaTypeFromMime('application/pdf')).toBe('document');
      expect(mediaTypeFromMime('application/msword')).toBe('document');
      expect(mediaTypeFromMime('application/vnd.openxmlformats-officedocument.wordprocessingml.document')).toBe('document');
      expect(mediaTypeFromMime('text/plain')).toBe('document');
    });

    it('returns other for unknown types', () => {
      expect(mediaTypeFromMime('application/octet-stream')).toBe('other');
      expect(mediaTypeFromMime('unknown/type')).toBe('other');
    });
  });

  describe('formatFileSize', () => {
    it('formats bytes', () => {
      expect(formatFileSize(512)).toBe('512 B');
    });

    it('formats kilobytes', () => {
      expect(formatFileSize(1024)).toBe('1.0 KB');
      expect(formatFileSize(1536)).toBe('1.5 KB');
    });

    it('formats megabytes', () => {
      expect(formatFileSize(1048576)).toBe('1.0 MB');
      expect(formatFileSize(5242880)).toBe('5.0 MB');
    });

    it('formats gigabytes', () => {
      expect(formatFileSize(1073741824)).toBe('1.00 GB');
      expect(formatFileSize(2147483648)).toBe('2.00 GB');
    });
  });

  describe('formatDuration', () => {
    it('formats short durations', () => {
      expect(formatDuration(30000)).toBe('0:30');
      expect(formatDuration(90000)).toBe('1:30');
    });

    it('formats minutes', () => {
      expect(formatDuration(180000)).toBe('3:00');
      expect(formatDuration(330000)).toBe('5:30');
    });

    it('formats hours', () => {
      expect(formatDuration(3600000)).toBe('1:00:00');
      expect(formatDuration(5400000)).toBe('1:30:00');
    });
  });

  describe('getFileExtension', () => {
    it('extracts extension', () => {
      expect(getFileExtension('photo.jpg')).toBe('jpg');
      expect(getFileExtension('document.pdf')).toBe('pdf');
      expect(getFileExtension('video.mp4')).toBe('mp4');
    });

    it('handles multiple dots', () => {
      expect(getFileExtension('file.name.txt')).toBe('txt');
      expect(getFileExtension('archive.tar.gz')).toBe('gz');
    });

    it('returns empty for no extension', () => {
      expect(getFileExtension('README')).toBe('');
      expect(getFileExtension('Makefile')).toBe('');
    });

    it('lowercases extension', () => {
      expect(getFileExtension('PHOTO.JPG')).toBe('jpg');
      expect(getFileExtension('Doc.PDF')).toBe('pdf');
    });
  });

  describe('isPreviewable', () => {
    it('returns true for previewable types', () => {
      expect(isPreviewable('image')).toBe(true);
      expect(isPreviewable('video')).toBe(true);
      expect(isPreviewable('audio')).toBe(true);
    });

    it('returns false for non-previewable types', () => {
      expect(isPreviewable('document')).toBe(false);
      expect(isPreviewable('other')).toBe(false);
      expect(isPreviewable('unknown')).toBe(false);
    });
  });
});
