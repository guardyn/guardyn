import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

/// Use case for sending a message to a group
class SendGroupMessage {
  final GroupRepository repository;

  SendGroupMessage(this.repository);

  Future<Either<Failure, GroupMessage>> call(SendGroupMessageParams params) {
    return repository.sendGroupMessage(
      groupId: params.groupId,
      textContent: params.textContent,
      messageType: params.messageType,
    );
  }
}

class SendGroupMessageParams {
  final String groupId;
  final String textContent;
  final GroupMessageType messageType;

  const SendGroupMessageParams({
    required this.groupId,
    required this.textContent,
    this.messageType = GroupMessageType.text,
  });
}
