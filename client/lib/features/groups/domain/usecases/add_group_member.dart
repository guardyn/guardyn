import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

/// Use case for adding a member to a group
class AddGroupMember {
  final GroupRepository repository;

  AddGroupMember(this.repository);

  Future<Either<Failure, bool>> call(AddGroupMemberParams params) {
    return repository.addGroupMember(
      groupId: params.groupId,
      memberUserId: params.memberUserId,
      memberDeviceId: params.memberDeviceId,
    );
  }
}

class AddGroupMemberParams {
  final String groupId;
  final String memberUserId;
  final String memberDeviceId;

  const AddGroupMemberParams({
    required this.groupId,
    required this.memberUserId,
    required this.memberDeviceId,
  });
}
