import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

/// Use case for removing a member from a group
@injectable
class RemoveGroupMember {
  final GroupRepository repository;

  RemoveGroupMember(this.repository);

  Future<Either<Failure, bool>> call(RemoveGroupMemberParams params) {
    return repository.removeGroupMember(
      groupId: params.groupId,
      memberUserId: params.memberUserId,
    );
  }
}

class RemoveGroupMemberParams {
  final String groupId;
  final String memberUserId;

  const RemoveGroupMemberParams({
    required this.groupId,
    required this.memberUserId,
  });
}
