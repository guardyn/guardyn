import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

/// Use case for updating group information (name, icon, description)
/// Only group owner and admins can perform this action
@injectable
class UpdateGroup {
  final GroupRepository repository;

  UpdateGroup(this.repository);

  Future<Either<Failure, Group>> call(UpdateGroupParams params) {
    return repository.updateGroup(
      groupId: params.groupId,
      name: params.name,
      iconMediaId: params.iconMediaId,
      description: params.description,
    );
  }
}

class UpdateGroupParams {
  final String groupId;
  final String? name;
  final String? iconMediaId;
  final String? description;

  const UpdateGroupParams({
    required this.groupId,
    this.name,
    this.iconMediaId,
    this.description,
  });
}
