/// Accept Call Use Case
///
/// Accepts an incoming call.
library;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/call_repository.dart';

/// Use case for accepting an incoming call
@injectable
class AcceptCall {
  final CallRepository repository;

  AcceptCall(this.repository);

  Future<Either<Failure, Call>> call(String callId) async {
    return repository.acceptCall(callId);
  }
}
