import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/notification_remote_datasource.dart';

/// Use case for muting/unmuting a conversation
class MuteConversation {
  final MuteConversationRepository repository;

  MuteConversation(this.repository);

  Future<Either<Failure, MuteConversationResult>> call(
    MuteConversationParams params,
  ) {
    return repository.muteConversation(
      conversationId: params.conversationId,
      isGroup: params.isGroup,
      duration: params.duration,
    );
  }
}

/// Parameters for mute conversation use case
class MuteConversationParams extends Equatable {
  final String conversationId;
  final bool isGroup;
  final MuteDuration duration;

  const MuteConversationParams({
    required this.conversationId,
    this.isGroup = false,
    required this.duration,
  });

  @override
  List<Object?> get props => [conversationId, isGroup, duration];
}

/// Result of mute conversation operation
class MuteConversationResult extends Equatable {
  final bool muted;
  final DateTime? mutedUntil;

  const MuteConversationResult({
    required this.muted,
    this.mutedUntil,
  });

  @override
  List<Object?> get props => [muted, mutedUntil];
}

/// Repository interface for mute conversation
abstract class MuteConversationRepository {
  Future<Either<Failure, MuteConversationResult>> muteConversation({
    required String conversationId,
    required bool isGroup,
    required MuteDuration duration,
  });
}
