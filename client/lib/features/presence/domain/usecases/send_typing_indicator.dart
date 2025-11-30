import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/presence_repository.dart';

/// Use case to send typing indicator
@injectable
class SendTypingIndicator {
  final PresenceRepository repository;

  SendTypingIndicator(this.repository);

  Future<Either<Failure, void>> call(SendTypingParams params) {
    return repository.sendTypingIndicator(
      conversationId: params.conversationId,
      isTyping: params.isTyping,
    );
  }
}

class SendTypingParams {
  final String conversationId;
  final bool isTyping;

  SendTypingParams({
    required this.conversationId,
    required this.isTyping,
  });
}
