/**
 * Media API
 *
 * Handles media upload, download, thumbnails, and metadata operations.
 */

import { invoke } from '@tauri-apps/api/core';

// ============================================================================
// Types
// ============================================================================

/**
 * Media type enumeration
 */
export type MediaType = 'unknown' | 'image' | 'video' | 'audio' | 'document' | 'other';

/**
 * Upload status enumeration
 */
export type UploadStatus = 'unknown' | 'pending' | 'processing' | 'completed' | 'failed';

/**
 * Media metadata from the server
 */
export interface MediaMetadata {
  id: string;
  ownerUserId: string;
  filename: string;
  type: MediaType;
  mimeType: string;
  sizeBytes: number;
  checksumSha256: string;
  createdAt: number;
  updatedAt: number;
  status: UploadStatus;
  width?: number;
  height?: number;
  durationMs?: number;
  thumbnailId?: string;
  isEncrypted: boolean;
  conversationId?: string;
  messageId?: string;
}

/**
 * Upload URL result from getUploadUrl
 */
export interface UploadUrlResult {
  mediaId: string;
  uploadUrl: string;
  expiresAt: number;
  headers: Record<string, string>;
}

/**
 * Download URL result from getDownloadUrl
 */
export interface DownloadUrlResult {
  downloadUrl: string;
  expiresAt: number;
  metadata?: MediaMetadata;
}

/**
 * Thumbnail generation result
 */
export interface ThumbnailResult {
  thumbnailId: string;
  metadata?: MediaMetadata;
}

/**
 * Media list result with pagination
 */
export interface MediaListResult {
  items: MediaMetadata[];
  nextCursor?: string;
  totalCount: number;
}

/**
 * Parameters for getUploadUrl
 */
export interface GetUploadUrlParams {
  filename: string;
  mimeType: string;
  sizeBytes: number;
  conversationId?: string;
}

/**
 * Parameters for uploadMediaFile
 */
export interface UploadMediaFileParams {
  filePath: string;
  presignedUrl: string;
  mimeType: string;
}

/**
 * Parameters for generateThumbnail
 */
export interface GenerateThumbnailParams {
  mediaId: string;
  maxWidth?: number;
  maxHeight?: number;
  format?: 'jpeg' | 'png' | 'webp';
  quality?: number;
}

/**
 * Parameters for listMedia
 */
export interface ListMediaParams {
  userId?: string;
  conversationId?: string;
  mediaTypes?: MediaType[];
  limit?: number;
  cursor?: string;
  sortBy?: 'created_at' | 'size_bytes' | 'filename';
  ascending?: boolean;
}

// ============================================================================
// API Functions
// ============================================================================

/**
 * Get a presigned URL for uploading media
 */
export async function getUploadUrl(params: GetUploadUrlParams): Promise<UploadUrlResult> {
  return invoke<UploadUrlResult>('get_media_upload_url', {
    filename: params.filename,
    mimeType: params.mimeType,
    sizeBytes: params.sizeBytes,
    conversationId: params.conversationId,
  });
}

/**
 * Upload a file to a presigned URL
 */
export async function uploadMediaFile(params: UploadMediaFileParams): Promise<void> {
  return invoke('upload_media_file', {
    filePath: params.filePath,
    presignedUrl: params.presignedUrl,
    mimeType: params.mimeType,
  });
}

/**
 * Get a presigned URL for downloading media
 */
export async function getDownloadUrl(mediaId: string): Promise<DownloadUrlResult> {
  return invoke<DownloadUrlResult>('get_media_download_url', { mediaId });
}

/**
 * Download a file from a presigned URL and save to disk
 */
export async function downloadMediaFile(downloadUrl: string, savePath: string): Promise<string> {
  return invoke<string>('download_media_file', { downloadUrl, savePath });
}

/**
 * Get media metadata
 */
export async function getMediaMetadata(mediaId: string): Promise<MediaMetadata> {
  return invoke<MediaMetadata>('get_media_metadata', { mediaId });
}

/**
 * Delete media
 */
export async function deleteMedia(mediaId: string): Promise<void> {
  return invoke('delete_media', { mediaId });
}

/**
 * Generate a thumbnail for media
 */
export async function generateThumbnail(params: GenerateThumbnailParams): Promise<ThumbnailResult> {
  return invoke<ThumbnailResult>('generate_thumbnail', {
    mediaId: params.mediaId,
    maxWidth: params.maxWidth,
    maxHeight: params.maxHeight,
    format: params.format,
    quality: params.quality,
  });
}

/**
 * List media with optional filters and pagination
 */
export async function listMedia(params: ListMediaParams = {}): Promise<MediaListResult> {
  return invoke<MediaListResult>('list_media', {
    userId: params.userId,
    conversationId: params.conversationId,
    mediaTypes: params.mediaTypes,
    limit: params.limit,
    cursor: params.cursor,
    sortBy: params.sortBy,
    ascending: params.ascending,
  });
}

/**
 * Get the media cache directory path
 */
export async function getMediaCacheDir(): Promise<string> {
  return invoke<string>('get_media_cache_dir');
}

/**
 * Clear all cached media files
 */
export async function clearMediaCache(): Promise<void> {
  return invoke('clear_media_cache');
}

/**
 * Get cached media file path if it exists
 */
export async function getCachedMediaPath(mediaId: string): Promise<string | null> {
  return invoke<string | null>('get_cached_media_path', { mediaId });
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Complete media upload flow: get URL, upload file
 * @returns The media ID of the uploaded file
 */
export async function uploadMedia(
  filePath: string,
  filename: string,
  mimeType: string,
  sizeBytes: number,
  conversationId?: string,
): Promise<string> {
  // Get presigned upload URL
  const uploadResult = await getUploadUrl({
    filename,
    mimeType,
    sizeBytes,
    conversationId,
  });

  // Upload file to presigned URL
  await uploadMediaFile({
    filePath,
    presignedUrl: uploadResult.uploadUrl,
    mimeType,
  });

  return uploadResult.mediaId;
}

/**
 * Complete media download flow: get URL, download file
 * @returns The local path of the downloaded file
 */
export async function downloadMedia(
  mediaId: string,
  savePath: string,
): Promise<{ localPath: string; metadata?: MediaMetadata }> {
  // Check cache first
  const cachedPath = await getCachedMediaPath(mediaId);
  if (cachedPath) {
    return { localPath: cachedPath };
  }

  // Get presigned download URL
  const downloadResult = await getDownloadUrl(mediaId);

  // Download file
  const localPath = await downloadMediaFile(downloadResult.downloadUrl, savePath);

  return {
    localPath,
    metadata: downloadResult.metadata,
  };
}

/**
 * Get thumbnail URL for media, generating if needed
 */
export async function getThumbnailUrl(
  mediaId: string,
  options?: {
    maxWidth?: number;
    maxHeight?: number;
    format?: 'jpeg' | 'png' | 'webp';
    quality?: number;
  },
): Promise<string> {
  // Generate thumbnail
  const result = await generateThumbnail({
    mediaId,
    ...options,
  });

  // Get download URL for thumbnail
  const downloadResult = await getDownloadUrl(result.thumbnailId);

  return downloadResult.downloadUrl;
}

/**
 * Determine MediaType from MIME type string
 */
export function mediaTypeFromMime(mimeType: string): MediaType {
  if (mimeType.startsWith('image/')) {
    return 'image';
  } else if (mimeType.startsWith('video/')) {
    return 'video';
  } else if (mimeType.startsWith('audio/')) {
    return 'audio';
  } else if (
    mimeType.startsWith('application/pdf') ||
    mimeType.startsWith('application/msword') ||
    mimeType.startsWith('application/vnd.') ||
    mimeType.startsWith('text/')
  ) {
    return 'document';
  }
  return 'other';
}

/**
 * Format file size in human-readable format
 */
export function formatFileSize(bytes: number): string {
  if (bytes < 1024) {
    return `${bytes} B`;
  } else if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  } else if (bytes < 1024 * 1024 * 1024) {
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  } else {
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
  }
}

/**
 * Format duration in human-readable format (for audio/video)
 */
export function formatDuration(ms: number): string {
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);

  if (hours > 0) {
    return `${hours}:${(minutes % 60).toString().padStart(2, '0')}:${(seconds % 60)
      .toString()
      .padStart(2, '0')}`;
  }
  return `${minutes}:${(seconds % 60).toString().padStart(2, '0')}`;
}

/**
 * Get file extension from filename
 */
export function getFileExtension(filename: string): string {
  const parts = filename.split('.');
  return parts.length > 1 ? parts[parts.length - 1].toLowerCase() : '';
}

/**
 * Check if a media type is previewable in the app
 */
export function isPreviewable(mediaType: MediaType): boolean {
  return mediaType === 'image' || mediaType === 'video' || mediaType === 'audio';
}

/**
 * Build a media URL for local display.
 * This returns a placeholder URL that will be resolved by the backend.
 * In production, URLs are fetched asynchronously via getDownloadUrl().
 */
export function buildMediaUrl(mediaId: string): string {
  // Return a URL that can be used to fetch media through the backend
  // The actual presigned URL will be fetched when needed
  return `/api/media/${mediaId}/download`;
}
