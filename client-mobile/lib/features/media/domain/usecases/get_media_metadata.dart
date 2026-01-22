import 'package:injectable/injectable.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';

/// Use case for getting media metadata
@injectable
class GetMediaMetadata {
  final MediaRepository repository;

  GetMediaMetadata(this.repository);

  /// Get metadata for a media file
  ///
  /// [mediaId] - Media ID
  ///
  /// Returns [MediaEntity] with metadata
  /// Throws [MediaException] on failure
  Future<MediaEntity> call({
    required String mediaId,
  }) async {
    if (mediaId.isEmpty) {
      throw MediaException(
        'Media ID cannot be empty',
        code: 'INVALID_ARGUMENT',
      );
    }

    return repository.getMetadata(mediaId: mediaId);
  }
}
