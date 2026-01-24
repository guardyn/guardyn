import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

/// Use case for getting list of user's groups
@injectable
class GetGroups {
  final GroupRepository repository;

  GetGroups(this.repository);

  Future<Either<Failure, List<Group>>> call() {
    return repository.getGroups();
  }
}
