import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

/// Use case for deleting a group (admin only)
@injectable
class DeleteGroup {
  final GroupRepository repository;

  DeleteGroup(this.repository);

  Future<Either<Failure, bool>> call(DeleteGroupParams params) {
    return repository.deleteGroup(params.groupId);
  }
}

/// Parameters for DeleteGroup use case
class DeleteGroupParams extends Equatable {
  final String groupId;

  const DeleteGroupParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}
