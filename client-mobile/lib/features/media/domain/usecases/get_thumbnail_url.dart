import 'package:injectable/injectable.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';

/// Use case for getting thumbnail URL
@injectable
class GetThumbnailUrl {
  final MediaRepository repository;

  GetThumbnailUrl(this.repository);

  /// Get thumbnail URL for a media file
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns thumbnail presigned URL or null if not available
  /// Throws [MediaException] on failure
  Future<String?> call({
    required String mediaId,
  }) async {
    if (mediaId.isEmpty) {
      throw MediaException(
        'Media ID cannot be empty',
        code: 'INVALID_ARGUMENT',
      );
    }

    return repository.getThumbnailUrl(mediaId: mediaId);
  }
}
