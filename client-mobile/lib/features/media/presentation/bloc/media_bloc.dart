import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/media_entity.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/usecases/delete_media.dart';
import '../../domain/usecases/download_media.dart';
import '../../domain/usecases/get_media_metadata.dart';
import '../../domain/usecases/get_thumbnail_url.dart';
import '../../domain/usecases/list_media.dart';
import '../../domain/usecases/manage_media_cache.dart';
import '../../domain/usecases/upload_media.dart';
import 'media_event.dart';
import 'media_state.dart';

/// BLoC for managing media operations
///
/// Handles:
/// - File upload with progress tracking
/// - File download with progress tracking
/// - Media listing and pagination
/// - Thumbnail retrieval
/// - Cache management
@injectable
class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final UploadMedia uploadMedia;
  final DownloadMedia downloadMedia;
  final ListMedia listMedia;
  final GetMediaMetadata getMediaMetadata;
  final GetThumbnailUrl getThumbnailUrl;
  final DeleteMedia deleteMedia;
  final ManageMediaCache manageMediaCache;

  // Pagination state - stored for potential future use (e.g., recovery)
  // ignore: unused_field
  String? _currentCursor;
  String? _currentConversationId;
  MediaType? _currentFilterType;

  MediaBloc({
    required this.uploadMedia,
    required this.downloadMedia,
    required this.listMedia,
    required this.getMediaMetadata,
    required this.getThumbnailUrl,
    required this.deleteMedia,
    required this.manageMediaCache,
  }) : super(const MediaInitial()) {
    on<MediaUploadRequested>(_onUploadRequested);
    on<MediaUploadFromBytesRequested>(_onUploadFromBytesRequested);
    on<MediaDownloadRequested>(_onDownloadRequested);
    on<MediaListRequested>(_onListRequested);
    on<MediaLoadMoreRequested>(_onLoadMoreRequested);
    on<MediaMetadataRequested>(_onMetadataRequested);
    on<MediaDeleteRequested>(_onDeleteRequested);
    on<MediaThumbnailRequested>(_onThumbnailRequested);
    on<MediaCacheClearRequested>(_onCacheClearRequested);
    on<MediaReset>(_onReset);
    on<MediaUploadProgressUpdated>(_onUploadProgressUpdated);
    on<MediaDownloadProgressUpdated>(_onDownloadProgressUpdated);
  }

  /// Handle file upload from path
  Future<void> _onUploadRequested(
    MediaUploadRequested event,
    Emitter<MediaState> emit,
  ) async {
    final filename = p.basename(event.filePath);
    emit(MediaUploading(progress: 0.0, filename: filename));

    try {
      final media = await uploadMedia(
        filePath: event.filePath,
        conversationId: event.conversationId,
        onProgress: (progress) {
          // Emit progress updates via event to maintain bloc pattern
          add(MediaUploadProgressUpdated(progress: progress));
        },
      );

      emit(MediaUploadSuccess(media: media));
    } on MediaException catch (e) {
      emit(MediaError(message: e.message, code: e.code));
    } catch (e) {
      emit(MediaError(message: 'Upload failed: ${e.toString()}'));
    }
  }

  /// Handle file upload from bytes
  Future<void> _onUploadFromBytesRequested(
    MediaUploadFromBytesRequested event,
    Emitter<MediaState> emit,
  ) async {
    emit(MediaUploading(progress: 0.0, filename: event.filename));

    try {
      final media = await uploadMedia.uploadData(
        data: event.data,
        filename: event.filename,
        conversationId: event.conversationId,
        onProgress: (progress) {
          add(MediaUploadProgressUpdated(progress: progress));
        },
      );

      emit(MediaUploadSuccess(media: media));
    } on MediaException catch (e) {
      emit(MediaError(message: e.message, code: e.code));
    } catch (e) {
      emit(MediaError(message: 'Upload failed: ${e.toString()}'));
    }
  }

  /// Handle file download
  Future<void> _onDownloadRequested(
    MediaDownloadRequested event,
    Emitter<MediaState> emit,
  ) async {
    emit(MediaDownloading(progress: 0.0, mediaId: event.mediaId));

    try {
      // First get metadata
      final metadata = await getMediaMetadata(mediaId: event.mediaId);

      // Then download (data is stored in cache)
      await downloadMedia(
        mediaId: event.mediaId,
        skipCache: event.forceDownload,
        onProgress: (progress) {
          add(MediaDownloadProgressUpdated(
            progress: progress,
            mediaId: event.mediaId,
          ));
        },
      );

      // Get local path
      final localPath = await downloadMedia.getLocalPath(mediaId: event.mediaId);

      emit(MediaDownloadSuccess(
        localPath: localPath ?? '',
        media: metadata,
      ));
    } on MediaException catch (e) {
      emit(MediaError(message: e.message, code: e.code));
    } catch (e) {
      emit(MediaError(message: 'Download failed: ${e.toString()}'));
    }
  }

  /// Handle media list request
  Future<void> _onListRequested(
    MediaListRequested event,
    Emitter<MediaState> emit,
  ) async {
    final currentMedia = state is MediaListLoaded
        ? (state as MediaListLoaded).media
        : <MediaEntity>[];

    emit(MediaLoading(media: currentMedia));

    try {
      final result = await listMedia(
        conversationId: event.conversationId,
        type: event.filterType,
        limit: event.limit,
        cursor: event.cursor,
      );

      // Store pagination state
      _currentCursor = result.nextCursor;
      _currentConversationId = event.conversationId;
      _currentFilterType = event.filterType;

      emit(MediaListLoaded(
        media: result.media,
        conversationId: event.conversationId,
        hasMore: result.hasMore,
        nextCursor: result.nextCursor,
        filterType: event.filterType,
      ));
    } on MediaException catch (e) {
      emit(MediaError(message: e.message, code: e.code, media: currentMedia));
    } catch (e) {
      emit(MediaError(message: 'Failed to load media: ${e.toString()}', media: currentMedia));
    }
  }

  /// Handle pagination (load more)
  Future<void> _onLoadMoreRequested(
    MediaLoadMoreRequested event,
    Emitter<MediaState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MediaListLoaded || !currentState.hasMore) {
      return;
    }

    try {
      final result = await listMedia(
        conversationId: event.conversationId,
        type: event.filterType,
        limit: 50,
        cursor: currentState.nextCursor,
      );

      _currentCursor = result.nextCursor;

      emit(currentState.copyWithMore(
        newMedia: result.media,
        hasMore: result.hasMore,
        nextCursor: result.nextCursor,
      ));
    } on MediaException catch (e) {
      emit(MediaError(
        message: e.message,
        code: e.code,
        media: currentState.media,
      ));
    } catch (e) {
      emit(MediaError(
        message: 'Failed to load more media: ${e.toString()}',
        media: currentState.media,
      ));
    }
  }

  /// Handle metadata request
  Future<void> _onMetadataRequested(
    MediaMetadataRequested event,
    Emitter<MediaState> emit,
  ) async {
    emit(const MediaLoading());

    try {
      final metadata = await getMediaMetadata(mediaId: event.mediaId);
      emit(MediaMetadataLoaded(media: metadata));
    } on MediaException catch (e) {
      emit(MediaError(message: e.message, code: e.code));
    } catch (e) {
      emit(MediaError(message: 'Failed to get metadata: ${e.toString()}'));
    }
  }

  /// Handle delete request
  Future<void> _onDeleteRequested(
    MediaDeleteRequested event,
    Emitter<MediaState> emit,
  ) async {
    final currentMedia = state is MediaListLoaded
        ? (state as MediaListLoaded).media
        : <MediaEntity>[];

    emit(MediaLoading(media: currentMedia));

    try {
      await deleteMedia(mediaId: event.mediaId);
      emit(MediaDeleteSuccess(mediaId: event.mediaId));

      // If we had a list loaded, remove the deleted item
      if (currentMedia.isNotEmpty) {
        final updatedMedia = currentMedia
            .where((m) => m.id != event.mediaId)
            .toList();
        emit(MediaListLoaded(
          media: updatedMedia,
          conversationId: _currentConversationId ?? '',
          hasMore: false,
          filterType: _currentFilterType,
        ));
      }
    } on MediaException catch (e) {
      emit(MediaError(message: e.message, code: e.code, media: currentMedia));
    } catch (e) {
      emit(MediaError(message: 'Failed to delete: ${e.toString()}', media: currentMedia));
    }
  }

  /// Handle thumbnail request
  Future<void> _onThumbnailRequested(
    MediaThumbnailRequested event,
    Emitter<MediaState> emit,
  ) async {
    try {
      final url = await getThumbnailUrl(mediaId: event.mediaId);
      if (url != null) {
        emit(MediaThumbnailLoaded(
          mediaId: event.mediaId,
          thumbnailUrl: url,
        ));
      } else {
        emit(MediaError(message: 'Thumbnail not available'));
      }
    } on MediaException catch (e) {
      emit(MediaError(message: e.message, code: e.code));
    } catch (e) {
      emit(MediaError(message: 'Failed to get thumbnail: ${e.toString()}'));
    }
  }

  /// Handle cache clear request
  Future<void> _onCacheClearRequested(
    MediaCacheClearRequested event,
    Emitter<MediaState> emit,
  ) async {
    try {
      await manageMediaCache.clearAll();
      emit(const MediaCacheCleared());
    } catch (e) {
      emit(MediaError(message: 'Failed to clear cache: ${e.toString()}'));
    }
  }

  /// Handle reset
  void _onReset(
    MediaReset event,
    Emitter<MediaState> emit,
  ) {
    _currentCursor = null;
    _currentConversationId = null;
    _currentFilterType = null;
    emit(const MediaInitial());
  }

  /// Handle upload progress update
  void _onUploadProgressUpdated(
    MediaUploadProgressUpdated event,
    Emitter<MediaState> emit,
  ) {
    final currentState = state;
    if (currentState is MediaUploading) {
      emit(currentState.copyWith(
        progress: event.progress,
        mediaId: event.mediaId,
      ));
    }
  }

  /// Handle download progress update
  void _onDownloadProgressUpdated(
    MediaDownloadProgressUpdated event,
    Emitter<MediaState> emit,
  ) {
    final currentState = state;
    if (currentState is MediaDownloading) {
      emit(currentState.copyWith(progress: event.progress));
    }
  }

  @override
  Future<void> close() {
    _currentCursor = null;
    _currentConversationId = null;
    _currentFilterType = null;
    return super.close();
  }
}
