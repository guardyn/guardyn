import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/presence_info.dart';
import '../repositories/presence_repository.dart';

/// Use case to get presence for multiple users at once (batch)
@injectable
class GetBulkPresence {
  final PresenceRepository repository;

  GetBulkPresence(this.repository);

  Future<Either<Failure, Map<String, PresenceInfo>>> call(
    List<String> userIds,
  ) {
    return repository.getBulkPresence(userIds);
  }
}
