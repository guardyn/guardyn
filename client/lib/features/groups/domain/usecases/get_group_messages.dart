import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

/// Use case for getting group messages
class GetGroupMessages {
  final GroupRepository repository;

  GetGroupMessages(this.repository);

  Future<Either<Failure, List<GroupMessage>>> call(GetGroupMessagesParams params) {
    return repository.getGroupMessages(
      groupId: params.groupId,
      limit: params.limit,
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}

class GetGroupMessagesParams {
  final String groupId;
  final int limit;
  final DateTime? startTime;
  final DateTime? endTime;

  const GetGroupMessagesParams({
    required this.groupId,
    this.limit = 50,
    this.startTime,
    this.endTime,
  });
}
