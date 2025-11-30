import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/presence_repository.dart';

/// Use case to send heartbeat to maintain online status
@injectable
class SendHeartbeat {
  final PresenceRepository repository;

  SendHeartbeat(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.sendHeartbeat();
  }
}
