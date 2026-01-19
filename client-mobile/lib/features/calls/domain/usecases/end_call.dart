/// End Call Use Case
///
/// Ends an active call or rejects an incoming call.
library;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/call_repository.dart';

/// Use case for ending an active call
@injectable
class EndCall {
  final CallRepository repository;

  EndCall(this.repository);

  Future<Either<Failure, void>> call(String callId) async {
    return repository.endCall(callId);
  }
}

/// Use case for rejecting an incoming call
@injectable
class RejectCall {
  final CallRepository repository;

  RejectCall(this.repository);

  Future<Either<Failure, void>> call(String callId) async {
    return repository.rejectCall(callId);
  }
}
