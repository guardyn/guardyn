import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

/// Use case for sending typing indicator to a group chat.
/// This notifies other members that the current user is typing.
@injectable
class SendGroupTypingIndicator {
  final GroupRepository repository;

  SendGroupTypingIndicator(this.repository);

  Future<Either<Failure, bool>> call(SendGroupTypingIndicatorParams params) {
    return repository.sendTypingIndicator(
      groupId: params.groupId,
      isTyping: params.isTyping,
    );
  }
}

class SendGroupTypingIndicatorParams {
  final String groupId;
  final bool isTyping;

  const SendGroupTypingIndicatorParams({
    required this.groupId,
    required this.isTyping,
  });
}
