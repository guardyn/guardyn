import 'dart:typed_data';

import 'package:guardyn_client/features/media/data/datasources/media_local_datasource.dart';
import 'package:guardyn_client/features/media/data/datasources/media_remote_datasource.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/generated/media.pb.dart' as pb;
import 'package:logger/logger.dart';

/// Implementation of MediaRepository
///
/// Coordinates between remote and local data sources
/// to provide a unified API for media operations.
class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource remoteDatasource;
  final MediaLocalDatasource localDatasource;
  final Logger logger = Logger();

  MediaRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<UploadUrlResult> getUploadUrl({
    required String filename,
    required String mimeType,
    required int sizeBytes,
    String? conversationId,
  }) async {
    final response = await remoteDatasource.getUploadUrl(
      filename: filename,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      conversationId: conversationId,
    );

    // Convert PbMap to regular Map and log for debugging
    final headersMap = Map<String, String>.from(response.headers);
    logger.d('getUploadUrl headers from server: $headersMap');

    return UploadUrlResult(
      mediaId: response.mediaId,
      presignedUrl: response.uploadUrl,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        response.expiresAt.toInt() * 1000,
      ),
      headers: headersMap,
    );
  }

  @override
  Future<void> uploadToPresignedUrl({
    required String presignedUrl,
    required Uint8List data,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    // Convert headers from proto to Map<String, String>
    await remoteDatasource.uploadToPresignedUrl(
      presignedUrl: presignedUrl,
      data: data,
      mimeType: mimeType,
      onProgress: onProgress,
    );
  }

  @override
  Future<MediaEntity> confirmUpload({
    required String mediaId,
    required String checksumSha256,
  }) async {
    // Get metadata to confirm the upload was successful
    final response = await remoteDatasource.getMetadata(mediaId: mediaId);
    return _metadataToEntity(response.metadata);
  }

  @override
  Future<DownloadUrlResult> getDownloadUrl({
    required String mediaId,
  }) async {
    final response = await remoteDatasource.getDownloadUrl(mediaId: mediaId);

    return DownloadUrlResult(
      mediaId: mediaId,
      presignedUrl: response.downloadUrl,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        response.expiresAt.toInt() * 1000,
      ),
    );
  }

  @override
  Future<Uint8List> downloadFromPresignedUrl({
    required String presignedUrl,
    void Function(double progress)? onProgress,
  }) async {
    return await remoteDatasource.downloadFromPresignedUrl(
      presignedUrl: presignedUrl,
      onProgress: onProgress,
    );
  }

  @override
  Future<MediaEntity> getMetadata({
    required String mediaId,
  }) async {
    final response = await remoteDatasource.getMetadata(mediaId: mediaId);
    return _metadataToEntity(response.metadata);
  }

  @override
  Future<MediaListResult> listMedia({
    required String conversationId,
    MediaType? type,
    int limit = 50,
    String? cursor,
  }) async {
    final pbType = type != null ? _mediaTypeToPb(type) : null;

    final response = await remoteDatasource.listMedia(
      conversationId: conversationId,
      type: pbType,
      limit: limit,
      cursor: cursor,
    );

    final items =
        response.items.map((metadata) => _metadataToEntity(metadata)).toList();

    return MediaListResult(
      media: items,
      totalCount: response.totalCount,
      nextCursor: response.hasNextCursor() ? response.nextCursor : null,
    );
  }

  @override
  Future<void> deleteMedia({
    required String mediaId,
  }) async {
    await remoteDatasource.deleteMedia(mediaId: mediaId);

    // Also remove from local cache
    await localDatasource.deleteCachedFile(mediaId);
  }

  @override
  Future<String?> getThumbnailUrl({
    required String mediaId,
  }) async {
    final response =
        await remoteDatasource.generateThumbnail(mediaId: mediaId);
    // Get download URL for thumbnail using the thumbnailId
    if (response.thumbnailId.isNotEmpty) {
      final downloadResponse = await remoteDatasource.getDownloadUrl(
        mediaId: response.thumbnailId,
      );
      return downloadResponse.downloadUrl;
    }
    return null;
  }

  @override
  Future<String> saveToCache({
    required String mediaId,
    required Uint8List data,
    String? filename,
  }) async {
    final file = await localDatasource.saveToCache(mediaId, data);
    return file.path;
  }

  @override
  Future<Uint8List?> getFromCache({
    required String mediaId,
  }) async {
    return await localDatasource.getCachedFileData(mediaId);
  }

  @override
  Future<String?> getCachedPath({
    required String mediaId,
  }) async {
    final file = await localDatasource.getCachedFile(mediaId);
    return file?.path;
  }

  @override
  Future<void> clearCache({String? mediaId}) async {
    if (mediaId != null) {
      await localDatasource.deleteCachedFile(mediaId);
    } else {
      await localDatasource.clearCache();
    }
  }

  @override
  Future<int> getCacheSize() async {
    return await localDatasource.getCacheSize();
  }

  // ========== Private Helpers ==========

  /// Convert protobuf MediaMetadata to domain MediaEntity
  MediaEntity _metadataToEntity(pb.MediaMetadata metadata) {
    return MediaEntity(
      id: metadata.mediaId,
      ownerUserId: metadata.ownerUserId,
      filename: metadata.filename,
      type: _pbToMediaType(metadata.mediaType),
      mimeType: metadata.mimeType,
      sizeBytes: metadata.sizeBytes.toInt(),
      status: _pbToUploadStatus(metadata.status),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        metadata.createdAt.toInt() * 1000,
      ),
      updatedAt: metadata.hasUpdatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              metadata.updatedAt.toInt() * 1000,
            )
          : null,
      width: metadata.hasWidth() ? metadata.width : null,
      height: metadata.hasHeight() ? metadata.height : null,
      durationMs: metadata.hasDurationMs() ? metadata.durationMs : null,
      thumbnailId:
          metadata.hasThumbnailId() ? metadata.thumbnailId : null,
      isEncrypted: metadata.isEncrypted,
      conversationId:
          metadata.hasConversationId() ? metadata.conversationId : null,
      messageId: metadata.hasMessageId() ? metadata.messageId : null,
      checksumSha256:
          metadata.hasChecksumSha256() ? metadata.checksumSha256 : null,
    );
  }

  /// Convert protobuf MediaType to domain MediaType
  MediaType _pbToMediaType(pb.MediaType pbType) {
    switch (pbType) {
      case pb.MediaType.MEDIA_TYPE_IMAGE:
        return MediaType.image;
      case pb.MediaType.MEDIA_TYPE_VIDEO:
        return MediaType.video;
      case pb.MediaType.MEDIA_TYPE_AUDIO:
        return MediaType.audio;
      case pb.MediaType.MEDIA_TYPE_DOCUMENT:
        return MediaType.document;
      case pb.MediaType.MEDIA_TYPE_UNKNOWN:
      default:
        return MediaType.other;
    }
  }

  /// Convert domain MediaType to protobuf MediaType
  pb.MediaType _mediaTypeToPb(MediaType type) {
    switch (type) {
      case MediaType.image:
        return pb.MediaType.MEDIA_TYPE_IMAGE;
      case MediaType.video:
        return pb.MediaType.MEDIA_TYPE_VIDEO;
      case MediaType.audio:
        return pb.MediaType.MEDIA_TYPE_AUDIO;
      case MediaType.document:
        return pb.MediaType.MEDIA_TYPE_DOCUMENT;
      case MediaType.other:
      case MediaType.unknown:
        return pb.MediaType.MEDIA_TYPE_UNKNOWN;
    }
  }

  /// Convert protobuf UploadStatus to domain UploadStatus
  UploadStatus _pbToUploadStatus(pb.UploadStatus pbStatus) {
    switch (pbStatus) {
      case pb.UploadStatus.UPLOAD_STATUS_PENDING:
        return UploadStatus.pending;
      case pb.UploadStatus.UPLOAD_STATUS_PROCESSING:
        return UploadStatus.processing;
      case pb.UploadStatus.UPLOAD_STATUS_COMPLETED:
        return UploadStatus.completed;
      case pb.UploadStatus.UPLOAD_STATUS_FAILED:
        return UploadStatus.failed;
      case pb.UploadStatus.UPLOAD_STATUS_UNKNOWN:
      default:
        return UploadStatus.pending;
    }
  }
}
