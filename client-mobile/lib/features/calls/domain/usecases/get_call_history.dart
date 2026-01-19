/// Get Call History Use Case
///
/// Retrieves the call history for the current user.
library;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/call_repository.dart';

/// Parameters for getting call history
class GetCallHistoryParams {
  final int limit;
  final int offset;
  final CallType? type;

  const GetCallHistoryParams({
    this.limit = 50,
    this.offset = 0,
    this.type,
  });
}

/// Use case for getting call history
@injectable
class GetCallHistory {
  final CallRepository repository;

  GetCallHistory(this.repository);

  Future<Either<Failure, List<Call>>> call(GetCallHistoryParams params) async {
    return repository.getCallHistory(
      limit: params.limit,
      offset: params.offset,
      type: params.type,
    );
  }
}
