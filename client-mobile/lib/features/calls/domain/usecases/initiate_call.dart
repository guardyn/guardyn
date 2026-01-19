/// Initiate Call Use Case
///
/// Initiates a new voice or video call to a user.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/call_repository.dart';

/// Parameters for initiating a call
class InitiateCallParams extends Equatable {
  final String userId;
  final CallType type;

  const InitiateCallParams({
    required this.userId,
    required this.type,
  });

  @override
  List<Object?> get props => [userId, type];
}

/// Use case for initiating a call
@injectable
class InitiateCall {
  final CallRepository repository;

  InitiateCall(this.repository);

  Future<Either<Failure, Call>> call(InitiateCallParams params) async {
    return repository.initiateCall(
      userId: params.userId,
      type: params.type,
    );
  }
}
