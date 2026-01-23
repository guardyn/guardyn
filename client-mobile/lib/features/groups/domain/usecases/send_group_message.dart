import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

/// Use case for sending a message to a group
@injectable
class SendGroupMessage {
  final GroupRepository repository;

  SendGroupMessage(this.repository);

  Future<Either<Failure, GroupMessage>> call(SendGroupMessageParams params) {
    return repository.sendGroupMessage(
      groupId: params.groupId,
      textContent: params.textContent,
      messageType: params.messageType,
      metadata: params.metadata,
    );
  }
}

class SendGroupMessageParams {
  final String groupId;
  final String textContent;
  final GroupMessageType messageType;
  final Map<String, String>? metadata;

  const SendGroupMessageParams({
    required this.groupId,
    required this.textContent,
    this.messageType = GroupMessageType.text,
    this.metadata,
  });
}
