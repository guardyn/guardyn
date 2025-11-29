import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

/// Use case for creating a new group
class CreateGroup {
  final GroupRepository repository;

  CreateGroup(this.repository);

  Future<Either<Failure, Group>> call(CreateGroupParams params) {
    return repository.createGroup(
      name: params.name,
      memberUserIds: params.memberUserIds,
    );
  }
}

class CreateGroupParams {
  final String name;
  final List<String> memberUserIds;

  const CreateGroupParams({
    required this.name,
    required this.memberUserIds,
  });
}
