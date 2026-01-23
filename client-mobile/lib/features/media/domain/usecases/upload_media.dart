import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// Use case for uploading media files
///
/// This handles the complete upload flow:
/// 1. Get presigned URL from server
/// 2. Upload file to presigned URL
/// 3. Confirm upload completion
@injectable
class UploadMedia {
  final MediaRepository repository;

  /// Maximum file size allowed (100 MB)
  static const int maxFileSizeBytes = 100 * 1024 * 1024;

  /// Allowed MIME types
  static const List<String> allowedMimeTypes = [
    // Images
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/heic',
    'image/heif',
    // Videos
    'video/mp4',
    'video/webm',
    'video/quicktime',
    'video/x-msvideo',
    // Audio
    'audio/mpeg',
    'audio/mp4',
    'audio/wav',
    'audio/ogg',
    'audio/webm',
    'audio/x-m4a',
    // Documents
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain',
    'application/zip',
    'application/x-rar-compressed',
    'application/x-7z-compressed',
  ];

  UploadMedia(this.repository);

  /// Upload a media file from path
  ///
  /// [filePath] - Local file path
  /// [conversationId] - Optional conversation this media belongs to
  /// [onProgress] - Optional callback for upload progress (0.0 - 1.0)
  ///
  /// Returns [MediaEntity] with uploaded media details
  /// Throws [MediaException] on failure
  Future<MediaEntity> call({
    required String filePath,
    String? conversationId,
    void Function(double progress)? onProgress,
  }) async {
    // Read file
    final file = File(filePath);
    if (!await file.exists()) {
      throw MediaException('File not found: $filePath', code: 'FILE_NOT_FOUND');
    }

    final data = await file.readAsBytes();
    final filename = p.basename(filePath);

    return uploadData(
      data: data,
      filename: filename,
      conversationId: conversationId,
      onProgress: onProgress,
    );
  }

  /// Upload media from bytes
  ///
  /// [data] - File data as bytes
  /// [filename] - Filename with extension
  /// [conversationId] - Optional conversation this media belongs to
  /// [onProgress] - Optional callback for upload progress (0.0 - 1.0)
  ///
  /// Returns [MediaEntity] with uploaded media details
  /// Throws [MediaException] on failure
  Future<MediaEntity> uploadData({
    required Uint8List data,
    required String filename,
    String? conversationId,
    void Function(double progress)? onProgress,
  }) async {
    // Validate file size
    if (data.length > maxFileSizeBytes) {
      throw MediaException(
        'File size exceeds maximum allowed (${(maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB)',
        code: 'FILE_TOO_LARGE',
      );
    }

    // Detect MIME type
    final mimeType = lookupMimeType(filename, headerBytes: data) ?? 'application/octet-stream';

    // Validate MIME type
    if (!_isAllowedMimeType(mimeType)) {
      throw MediaException(
        'File type not allowed: $mimeType',
        code: 'INVALID_FILE_TYPE',
      );
    }

    // Calculate checksum
    final checksum = sha256.convert(data).toString();

    // Step 1: Get presigned upload URL
    final uploadUrl = await repository.getUploadUrl(
      filename: filename,
      mimeType: mimeType,
      sizeBytes: data.length,
      conversationId: conversationId,
    );

    // Step 2: Upload to presigned URL
    // Use Content-Type from server headers to ensure signature match
    // The presigned URL is signed with specific Content-Type, so we must use exactly that
    final uploadMimeType = uploadUrl.contentType ?? mimeType;
    await repository.uploadToPresignedUrl(
      presignedUrl: uploadUrl.presignedUrl,
      data: data,
      mimeType: uploadMimeType,
      onProgress: onProgress,
    );

    // Step 3: Confirm upload
    final media = await repository.confirmUpload(
      mediaId: uploadUrl.mediaId,
      checksumSha256: checksum,
    );

    return media;
  }

  bool _isAllowedMimeType(String mimeType) {
    // Allow all types if the list is empty (for flexibility)
    if (allowedMimeTypes.isEmpty) return true;
    
    // Check exact match
    if (allowedMimeTypes.contains(mimeType)) return true;
    
    // Check wildcard match (e.g., "image/*")
    final parts = mimeType.split('/');
    if (parts.length == 2) {
      final wildcardType = '${parts[0]}/*';
      if (allowedMimeTypes.contains(wildcardType)) return true;
    }
    
    return false;
  }
}
