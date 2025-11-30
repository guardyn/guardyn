import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/presence_info.dart';
import '../repositories/presence_repository.dart';

/// Use case to get presence for a single user
@injectable
class GetUserPresence {
  final PresenceRepository repository;

  GetUserPresence(this.repository);

  Future<Either<Failure, PresenceInfo>> call(String userId) {
    return repository.getUserPresence(userId);
  }
}
