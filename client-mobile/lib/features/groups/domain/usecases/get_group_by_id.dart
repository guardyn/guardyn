import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

/// Use case for getting group details by ID
class GetGroupById {
  final GroupRepository repository;

  GetGroupById(this.repository);

  Future<Either<Failure, Group>> call(GetGroupByIdParams params) {
    return repository.getGroupById(params.groupId);
  }
}

/// Parameters for GetGroupById use case
class GetGroupByIdParams extends Equatable {
  final String groupId;

  const GetGroupByIdParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}
