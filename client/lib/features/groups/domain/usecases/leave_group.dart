import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/group_repository.dart';

/// Use case for leaving a group
class LeaveGroup {
  final GroupRepository repository;

  LeaveGroup(this.repository);

  Future<Either<Failure, bool>> call(LeaveGroupParams params) {
    return repository.leaveGroup(params.groupId);
  }
}

/// Parameters for LeaveGroup use case
class LeaveGroupParams extends Equatable {
  final String groupId;

  const LeaveGroupParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}
