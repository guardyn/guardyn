import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/message_repository.dart';
import '../../../../core/error/failures.dart';

@injectable
class MarkAsRead {
  final MessageRepository repository;

  MarkAsRead(this.repository);

  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    return await repository.markAsRead(
      messageId: params.messageId,
    );
  }
}

class MarkAsReadParams {
  final String messageId;

  MarkAsReadParams({
    required this.messageId,
  });
}
