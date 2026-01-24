import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/usecases/mute_conversation.dart';
import '../datasources/notification_remote_datasource.dart';

/// Implementation of notification-related repository methods
@Injectable(as: MuteConversationRepository)
class NotificationRepositoryImpl implements MuteConversationRepository {
  final NotificationRemoteDatasource _remoteDatasource;
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();

  NotificationRepositoryImpl(
    this._remoteDatasource,
    this._secureStorage,
  );

  @override
  Future<Either<Failure, MuteConversationResult>> muteConversation({
    required String conversationId,
    required bool isGroup,
    required MuteDuration duration,
  }) async {
    try {
      // Get access token
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        _logger.e('muteConversation: No access token found');
        return const Left(AuthFailure('No access token found'));
      }

      final result = await _remoteDatasource.muteConversation(
        accessToken: accessToken,
        conversationId: conversationId,
        isGroup: isGroup,
        duration: duration,
      );

      _logger.i(
        'Conversation $conversationId muted: ${result.muted}, until: ${result.mutedUntil}',
      );

      return Right(MuteConversationResult(
        muted: result.muted,
        mutedUntil: result.mutedUntil,
      ));
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to mute conversation',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(e.toString()));
    }
  }
}
