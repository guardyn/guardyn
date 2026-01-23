import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/auth/token_manager.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/generated/media.pb.dart' as pb;
import 'package:guardyn_client/generated/media.pbgrpc.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Remote data source for media operations via gRPC and HTTP
class MediaRemoteDatasource {
  final GrpcClients grpcClients;
  final http.Client httpClient;
  final TokenManager tokenManager;
  final Logger logger = Logger();

  MediaRemoteDatasource(this.grpcClients, this.httpClient, this.tokenManager);

  /// Get the media service client
  MediaServiceClient get _mediaClient => grpcClients.mediaClient;

  /// Get presigned upload URL from server
  ///
  /// Returns [pb.GetUploadUrlResponse] with mediaId and presigned URL
  /// Throws [MediaException] on failure
  Future<pb.GetUploadUrlResponse> getUploadUrl({
    required String filename,
    required String mimeType,
    required int sizeBytes,
    String? conversationId,
  }) async {
    try {
      final request = pb.GetUploadUrlRequest()
        ..filename = filename
        ..mimeType = mimeType
        ..sizeBytes = Int64(sizeBytes);

      if (conversationId != null) {
        request.conversationId = conversationId;
      }

      // Use executeWithAuth for automatic token refresh on 401
      final response = await tokenManager.executeWithAuth(
        (options) => _mediaClient.getUploadUrl(request, options: options),
      );

      if (response.hasError()) {
        throw MediaException(
          response.error.message,
          code: response.error.code.toString(),
        );
      }

      logger.d('Got upload URL for file: $filename, mediaId: ${response.mediaId}');
      return response;
    } on TokenException catch (e) {
      logger.e('Token error getting upload URL: ${e.message}');
      throw MediaException(e.message, code: 'UNAUTHENTICATED');
    } on GrpcError catch (e) {
      logger.e('gRPC error getting upload URL: ${e.message}');
      throw MediaException(
        'Network error: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error getting upload URL: $e');
      throw MediaException('Failed to get upload URL: $e', originalError: e);
    }
  }

  /// Upload file data to presigned URL via HTTP PUT
  ///
  /// [presignedUrl] - The presigned URL from getUploadUrl
  /// [data] - File data as bytes
  /// [mimeType] - MIME type for Content-Type header
  /// [headers] - Optional additional headers from server
  /// [onProgress] - Optional progress callback (0.0 - 1.0)
  ///
  /// Throws [MediaException] on failure
  Future<void> uploadToPresignedUrl({
    required String presignedUrl,
    required Uint8List data,
    required String mimeType,
    Map<String, String>? headers,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // The presigned URL from backend already contains the correct host
      // (S3_PUBLIC_ENDPOINT is set to 10.0.2.2:9000 for Android emulator)
      final uri = Uri.parse(presignedUrl);

      logger.d('Uploading to presigned URL: $presignedUrl');

      // Create request for upload
      final request = http.Request('PUT', uri);
      request.headers['Content-Type'] = mimeType;

      // Add any additional headers from server
      if (headers != null) {
        request.headers.addAll(headers);
      }

      request.bodyBytes = data;

      logger.d('Uploading ${data.length} bytes to presigned URL');

      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw MediaException(
          'Upload failed with status ${response.statusCode}: ${response.body}',
          code: 'HTTP_${response.statusCode}',
        );
      }

      onProgress?.call(1.0);
      logger.i('Upload completed successfully');
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error uploading to presigned URL: $e');
      throw MediaException(
        'Upload failed: $e',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    }
  }

  /// Get presigned download URL from server
  ///
  /// Returns [pb.GetDownloadUrlResponse] with presigned URL
  /// Throws [MediaException] on failure
  Future<pb.GetDownloadUrlResponse> getDownloadUrl({
    required String mediaId,
  }) async {
    try {
      final request = pb.GetDownloadUrlRequest()..mediaId = mediaId;

      // Use executeWithAuth for automatic token refresh on 401
      final response = await tokenManager.executeWithAuth(
        (options) => _mediaClient.getDownloadUrl(request, options: options),
      );

      if (response.hasError()) {
        throw MediaException(
          response.error.message,
          code: response.error.code.toString(),
        );
      }

      logger.d('Got download URL for mediaId: $mediaId');
      return response;
    } on TokenException catch (e) {
      logger.e('Token error getting download URL: ${e.message}');
      throw MediaException(e.message, code: 'UNAUTHENTICATED');
    } on GrpcError catch (e) {
      logger.e('gRPC error getting download URL: ${e.message}');
      throw MediaException(
        'Network error: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error getting download URL: $e');
      throw MediaException('Failed to get download URL: $e', originalError: e);
    }
  }

  /// Download file from presigned URL via HTTP GET
  ///
  /// [presignedUrl] - The presigned URL from getDownloadUrl
  /// [onProgress] - Optional progress callback (0.0 - 1.0)
  ///
  /// Returns downloaded data as bytes
  /// Throws [MediaException] on failure
  Future<Uint8List> downloadFromPresignedUrl({
    required String presignedUrl,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // The presigned URL from backend already contains the correct host
      // (S3_PUBLIC_ENDPOINT is set to 10.0.2.2:9000 for Android emulator)
      final uri = Uri.parse(presignedUrl);

      logger.d('Downloading from presigned URL: $presignedUrl');

      final request = http.Request('GET', uri);
      final streamedResponse = await httpClient.send(request);

      if (streamedResponse.statusCode != 200) {
        throw MediaException(
          'Download failed with status ${streamedResponse.statusCode}',
          code: 'HTTP_${streamedResponse.statusCode}',
        );
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      final bytes = <int>[];
      var received = 0;

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        received += chunk.length;

        if (contentLength > 0 && onProgress != null) {
          onProgress(received / contentLength);
        }
      }

      logger.i('Download completed: ${bytes.length} bytes');
      return Uint8List.fromList(bytes);
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error downloading from presigned URL: $e');
      throw MediaException(
        'Download failed: $e',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    }
  }

  /// Get media metadata from server
  ///
  /// Returns [pb.GetMediaMetadataResponse] with metadata
  /// Throws [MediaException] on failure
  Future<pb.GetMediaMetadataResponse> getMetadata({
    required String mediaId,
  }) async {
    try {
      final request = pb.GetMediaMetadataRequest()..mediaId = mediaId;

      // Use executeWithAuth for automatic token refresh on 401
      final response = await tokenManager.executeWithAuth(
        (options) => _mediaClient.getMediaMetadata(request, options: options),
      );

      if (response.hasError()) {
        throw MediaException(
          response.error.message,
          code: response.error.code.toString(),
        );
      }

      logger.d('Got metadata for mediaId: $mediaId');
      return response;
    } on TokenException catch (e) {
      logger.e('Token error getting metadata: ${e.message}');
      throw MediaException(e.message, code: 'UNAUTHENTICATED');
    } on GrpcError catch (e) {
      logger.e('gRPC error getting metadata: ${e.message}');
      throw MediaException(
        'Network error: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error getting metadata: $e');
      throw MediaException('Failed to get metadata: $e', originalError: e);
    }
  }

  /// List media for a conversation
  ///
  /// Returns [pb.ListMediaResponse] with media list
  /// Throws [MediaException] on failure
  Future<pb.ListMediaResponse> listMedia({
    required String conversationId,
    pb.MediaType? type,
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final request = pb.ListMediaRequest()
        ..conversationId = conversationId
        ..limit = limit;

      if (type != null) {
        request.mediaTypes.add(type);
      }
      if (cursor != null) {
        request.cursor = cursor;
      }

      // Use executeWithAuth for automatic token refresh on 401
      final response = await tokenManager.executeWithAuth(
        (options) => _mediaClient.listMedia(request, options: options),
      );

      if (response.hasError()) {
        throw MediaException(
          response.error.message,
          code: response.error.code.toString(),
        );
      }

      logger.d('Listed ${response.items.length} media items for conversation: $conversationId');
      return response;
    } on TokenException catch (e) {
      logger.e('Token error listing media: ${e.message}');
      throw MediaException(e.message, code: 'UNAUTHENTICATED');
    } on GrpcError catch (e) {
      logger.e('gRPC error listing media: ${e.message}');
      throw MediaException(
        'Network error: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error listing media: $e');
      throw MediaException('Failed to list media: $e', originalError: e);
    }
  }

  /// Delete media from server
  ///
  /// Throws [MediaException] on failure
  Future<void> deleteMedia({
    required String mediaId,
  }) async {
    try {
      final request = pb.DeleteMediaRequest()..mediaId = mediaId;

      // Use executeWithAuth for automatic token refresh on 401
      final response = await tokenManager.executeWithAuth(
        (options) => _mediaClient.deleteMedia(request, options: options),
      );

      if (response.hasError()) {
        throw MediaException(
          response.error.message,
          code: response.error.code.toString(),
        );
      }

      logger.i('Deleted media: $mediaId');
    } on TokenException catch (e) {
      logger.e('Token error deleting media: ${e.message}');
      throw MediaException(e.message, code: 'UNAUTHENTICATED');
    } on GrpcError catch (e) {
      logger.e('gRPC error deleting media: ${e.message}');
      throw MediaException(
        'Network error: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error deleting media: $e');
      throw MediaException('Failed to delete media: $e', originalError: e);
    }
  }

  /// Generate thumbnail for media
  ///
  /// Returns [pb.GenerateThumbnailResponse] with thumbnail info
  /// Throws [MediaException] on failure
  Future<pb.GenerateThumbnailResponse> generateThumbnail({
    required String mediaId,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final request = pb.GenerateThumbnailRequest()..mediaId = mediaId;

      if (maxWidth != null) {
        request.maxWidth = maxWidth;
      }
      if (maxHeight != null) {
        request.maxHeight = maxHeight;
      }

      // Use executeWithAuth for automatic token refresh on 401
      final response = await tokenManager.executeWithAuth(
        (options) => _mediaClient.generateThumbnail(request, options: options),
        timeout: const Duration(seconds: 30),
      );

      if (response.hasError()) {
        throw MediaException(
          response.error.message,
          code: response.error.code.toString(),
        );
      }

      logger.d('Generated thumbnail for mediaId: $mediaId');
      return response;
    } on TokenException catch (e) {
      logger.e('Token error generating thumbnail: ${e.message}');
      throw MediaException(e.message, code: 'UNAUTHENTICATED');
    } on GrpcError catch (e) {
      logger.e('gRPC error generating thumbnail: ${e.message}');
      throw MediaException(
        'Network error: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      logger.e('Error generating thumbnail: $e');
      throw MediaException('Failed to generate thumbnail: $e', originalError: e);
    }
  }
}
