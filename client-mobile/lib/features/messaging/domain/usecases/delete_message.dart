import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/message_repository.dart';

/// Use case for deleting a single message
@injectable
class DeleteMessage {
  final MessageRepository repository;

  DeleteMessage(this.repository);

  Future<Either<Failure, void>> call(DeleteMessageParams params) async {
    return await repository.deleteMessage(messageId: params.messageId);
  }
}

class DeleteMessageParams {
  final String messageId;

  DeleteMessageParams({required this.messageId});
}
