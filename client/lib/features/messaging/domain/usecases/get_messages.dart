import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

@injectable
class GetMessages {
  final MessageRepository repository;

  GetMessages(this.repository);

  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      conversationUserId: params.conversationUserId,
      conversationId: params.conversationId,
      limit: params.limit,
      beforeMessageId: params.beforeMessageId,
    );
  }
}

class GetMessagesParams {
  final String conversationUserId;
  final String? conversationId;
  final int limit;
  final String? beforeMessageId;

  GetMessagesParams({
    required this.conversationUserId,
    this.conversationId,
    this.limit = 50,
    this.beforeMessageId,
  });
}
