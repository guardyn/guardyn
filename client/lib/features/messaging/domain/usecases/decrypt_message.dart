import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/message_repository.dart';

/// Use case for decrypting E2EE encrypted message content
/// Used primarily for WebSocket messages that arrive encrypted
@injectable
class DecryptMessage {
  final MessageRepository repository;

  DecryptMessage(this.repository);

  Future<Either<Failure, String>> call(DecryptMessageParams params) async {
    return await repository.decryptMessageContent(
      encryptedContent: params.encryptedContent,
      senderUserId: params.senderUserId,
      senderDeviceId: params.senderDeviceId,
    );
  }
}

class DecryptMessageParams {
  final String encryptedContent;
  final String senderUserId;
  final String senderDeviceId;

  DecryptMessageParams({
    required this.encryptedContent,
    required this.senderUserId,
    required this.senderDeviceId,
  });
}
