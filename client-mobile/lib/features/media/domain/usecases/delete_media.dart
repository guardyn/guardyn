import 'package:injectable/injectable.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';

/// Use case for deleting media
@injectable
class DeleteMedia {
  final MediaRepository repository;

  DeleteMedia(this.repository);

  /// Delete a media file
  ///
  /// [mediaId] - Media ID to delete
  ///
  /// Throws [MediaException] on failure
  Future<void> call({
    required String mediaId,
  }) async {
    if (mediaId.isEmpty) {
      throw MediaException(
        'Media ID cannot be empty',
        code: 'INVALID_ARGUMENT',
      );
    }

    // Delete from server
    await repository.deleteMedia(mediaId: mediaId);

    // Clear local cache
    await repository.clearCache(mediaId: mediaId);
  }
}
