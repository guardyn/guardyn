import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

/// Use case for changing a member's role in a group
/// Only the group owner can perform this action
@injectable
class ChangeMemberRole {
  final GroupRepository repository;

  ChangeMemberRole(this.repository);

  Future<Either<Failure, void>> call(ChangeMemberRoleParams params) {
    return repository.changeMemberRole(
      groupId: params.groupId,
      targetUserId: params.targetUserId,
      newRole: params.newRole,
    );
  }
}

/// Parameters for ChangeMemberRole use case
class ChangeMemberRoleParams {
  final String groupId;
  final String targetUserId;
  final String newRole;

  const ChangeMemberRoleParams({
    required this.groupId,
    required this.targetUserId,
    required this.newRole,
  });
}
