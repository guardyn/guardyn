import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/message_repository.dart';

@injectable
class ClearChat {
  final MessageRepository repository;

  ClearChat(this.repository);

  Future<Either<Failure, int>> call(ClearChatParams params) async {
    return await repository.clearChat(conversationId: params.conversationId);
  }
}

class ClearChatParams {
  final String conversationId;

  ClearChatParams({required this.conversationId});
}
