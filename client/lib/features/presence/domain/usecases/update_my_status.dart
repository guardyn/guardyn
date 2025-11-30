import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/presence_info.dart';
import '../repositories/presence_repository.dart';

/// Use case to update current user's status
@injectable
class UpdateMyStatus {
  final PresenceRepository repository;

  UpdateMyStatus(this.repository);

  Future<Either<Failure, void>> call(PresenceStatus status) {
    return repository.updateMyStatus(status);
  }
}
