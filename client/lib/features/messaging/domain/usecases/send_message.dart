import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

@injectable
class SendMessage {
  final MessageRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      recipientUserId: params.recipientUserId,
      recipientDeviceId: params.recipientDeviceId,
      recipientUsername: params.recipientUsername,
      textContent: params.textContent,
      metadata: params.metadata,
    );
  }
}

class SendMessageParams {
  final String recipientUserId;
  final String recipientDeviceId;
  final String recipientUsername;
  final String textContent;
  final Map<String, String>? metadata;

  SendMessageParams({
    required this.recipientUserId,
    required this.recipientDeviceId,
    required this.recipientUsername,
    required this.textContent,
    this.metadata,
  });
}
