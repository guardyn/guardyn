import 'package:injectable/injectable.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';

/// Use case for listing media in a conversation
@injectable
class ListMedia {
  final MediaRepository repository;

  ListMedia(this.repository);

  /// List media for a conversation
  ///
  /// [conversationId] - Conversation ID
  /// [type] - Optional filter by media type
  /// [limit] - Maximum number of results (default: 50)
  /// [cursor] - Pagination cursor from previous response
  ///
  /// Returns [MediaListResult] with media list and pagination
  /// Throws [MediaException] on failure
  Future<MediaListResult> call({
    required String conversationId,
    MediaType? type,
    int limit = 50,
    String? cursor,
  }) async {
    if (conversationId.isEmpty) {
      throw MediaException(
        'Conversation ID cannot be empty',
        code: 'INVALID_ARGUMENT',
      );
    }

    if (limit <= 0 || limit > 100) {
      throw MediaException(
        'Limit must be between 1 and 100',
        code: 'INVALID_ARGUMENT',
      );
    }

    return repository.listMedia(
      conversationId: conversationId,
      type: type,
      limit: limit,
      cursor: cursor,
    );
  }

  /// Get all media for a conversation (paginated internally)
  ///
  /// [conversationId] - Conversation ID
  /// [type] - Optional filter by media type
  /// [maxItems] - Maximum number of items to fetch (default: 500)
  ///
  /// Returns list of [MediaEntity]
  /// Throws [MediaException] on failure
  Future<List<MediaEntity>> getAll({
    required String conversationId,
    MediaType? type,
    int maxItems = 500,
  }) async {
    final result = <MediaEntity>[];
    String? cursor;

    do {
      final page = await call(
        conversationId: conversationId,
        type: type,
        limit: 50,
        cursor: cursor,
      );

      result.addAll(page.media);
      cursor = page.nextCursor;

      if (result.length >= maxItems) {
        break;
      }
    } while (cursor != null);

    return result.take(maxItems).toList();
  }
}
