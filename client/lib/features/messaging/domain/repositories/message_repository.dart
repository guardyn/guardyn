import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';

/// Repository interface for message operations
/// (Implementation will be in data layer)
abstract class MessageRepository {
  /// Send a message to a recipient
  /// Returns the sent message with server-assigned ID on success
  Future<Either<Failure, Message>> sendMessage({
    required String recipientUserId,
    required String recipientDeviceId,
    required String recipientUsername,
    required String textContent,
    Map<String, String>? metadata,
  });

  /// Get message history for a conversation
  /// Returns list of messages sorted by timestamp (newest first)
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationUserId,
    String? conversationId,
    int limit = 50,
    String? beforeMessageId,
  });

  /// Subscribe to real-time incoming messages
  /// Returns a stream that emits new messages as they arrive
  Stream<Either<Failure, Message>> receiveMessages();

  /// Mark a message as read
  /// Updates delivery status to 'read'
  Future<Either<Failure, void>> markAsRead({
    required String messageId,
  });

  /// Delete a message
  /// Removes message from local storage and server
  Future<Either<Failure, void>> deleteMessage({
    required String messageId,
  });

  /// Decrypt an encrypted message content
  /// Used for WebSocket messages that arrive encrypted
  Future<Either<Failure, String>> decryptMessageContent({
    required String encryptedContent,
    required String senderUserId,
    required String senderDeviceId,
  });
}
