import 'package:dartz/dartz.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/conversation_utils.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';
import '../models/message_model.dart';

@Injectable(as: MessageRepository)
class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDatasource remoteDatasource;
  final SecureStorage secureStorage;

  MessageRepositoryImpl(this.remoteDatasource, this.secureStorage);

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String recipientUserId,
    required String recipientDeviceId,
    required String recipientUsername,
    required String textContent,
    Map<String, String>? metadata,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Get current user info for conversation ID
      final currentUserId = await secureStorage.getUserId();
      final currentDeviceId = await secureStorage.getDeviceId();

      if (currentUserId == null || currentDeviceId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Send message via datasource
      final messageModel = await remoteDatasource.sendMessage(
        accessToken: accessToken,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        recipientUsername: recipientUsername,
        textContent: textContent,
        metadata: metadata,
      );

      // Create complete message with sender info
      final conversationId = _deriveConversationId(currentUserId, recipientUserId);

      final completeMessage = MessageModel(
        messageId: messageModel.messageId,
        conversationId: conversationId,
        senderUserId: currentUserId,
        senderDeviceId: currentDeviceId,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        messageType: messageModel.messageType,
        textContent: textContent,
        metadata: metadata ?? {},
        timestamp: messageModel.timestamp,
        deliveryStatus: messageModel.deliveryStatus,
        currentUserId: currentUserId,
      );

      return Right(completeMessage);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationUserId,
    String? conversationId,
    int limit = 50,
    String? beforeMessageId,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Get current user ID for determining sent/received
      final currentUserId = await secureStorage.getUserId();
      
      // Generate conversation ID if not provided
      // Backend requires conversation_id for GetMessages
      final effectiveConversationId = conversationId ?? 
          (currentUserId != null 
              ? _deriveConversationId(currentUserId, conversationUserId)
              : null);

      // Fetch messages via datasource
      final messages = await remoteDatasource.getMessages(
        accessToken: accessToken,
        conversationUserId: conversationUserId,
        conversationId: effectiveConversationId,
        limit: limit,
        beforeMessageId: beforeMessageId,
        currentUserId: currentUserId,
      );

      return Right(messages);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Message>> receiveMessages() async* {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        yield const Left(AuthFailure('No access token found'));
        return;
      }

      // Get current user ID
      final currentUserId = await secureStorage.getUserId();

      // Subscribe to message stream
      final messageStream = remoteDatasource.receiveMessages(
        accessToken: accessToken,
        currentUserId: currentUserId,
      );

      await for (final message in messageStream) {
        yield Right(message);
      }
    } on GrpcError catch (e) {
      yield Left(_handleGrpcError(e));
    } catch (e) {
      yield Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String messageId,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Mark as read via datasource
      await remoteDatasource.markAsRead(
        accessToken: accessToken,
        messageIds: [messageId],
      );

      return const Right(null);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage({
    required String messageId,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // For delete, we need conversation ID (TODO: pass it from UI or fetch from local DB)
      const conversationId = 'temp-conversation-id';

      // Delete message via datasource
      await remoteDatasource.deleteMessage(
        accessToken: accessToken,
        messageId: messageId,
        conversationId: conversationId,
        deleteForEveryone: false,
      );

      return const Right(null);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Helper methods

  /// Generate deterministic conversation ID using UUID v5.
  /// This matches the backend implementation.
  String _deriveConversationId(String userId1, String userId2) {
    return ConversationUtils.generateConversationId(userId1, userId2);
  }

  Failure _handleGrpcError(GrpcError error) {
    switch (error.code) {
      case StatusCode.unauthenticated:
        return AuthFailure(error.message ?? 'Authentication failed');
      case StatusCode.unavailable:
        return const NetworkFailure('Service unavailable');
      case StatusCode.deadlineExceeded:
        return const NetworkFailure('Request timeout');
      case StatusCode.notFound:
        return ServerFailure(error.message ?? 'Resource not found');
      default:
        return ServerFailure(error.message ?? 'Server error');
    }
  }
}
