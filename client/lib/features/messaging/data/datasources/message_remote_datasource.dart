import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/grpc_clients.dart';
import '../../../../generated/common.pb.dart' as proto_common;
import '../../../../generated/messaging.pb.dart' as proto;
import '../../../../generated/messaging.pbgrpc.dart' hide MessageType, DeliveryStatus;
import '../../domain/entities/message.dart';
import '../models/message_model.dart';

/// Remote datasource for message operations via gRPC
@injectable
class MessageRemoteDatasource {
  final GrpcClients _grpcClients;

  MessageRemoteDatasource(this._grpcClients);

  MessagingServiceClient get _messagingClient => _grpcClients.messagingClient;

  /// Send a message via gRPC
  Future<MessageModel> sendMessage({
    required String accessToken,
    required String recipientUserId,
    required String recipientDeviceId,
    required String textContent,
    Map<String, String>? metadata,
  }) async {
    final request = proto.SendMessageRequest(
      accessToken: accessToken,
      recipientUserId: recipientUserId,
      recipientDeviceId: recipientDeviceId,
      encryptedContent: textContent.codeUnits,
      messageType: proto.MessageType.TEXT,
      clientMessageId: _generateMessageId(),
      clientTimestamp: _createTimestamp(DateTime.now()),
    );

    final response = await _messagingClient.sendMessage(request);

    if (response.hasError()) {
      throw GrpcError.custom(
        response.error.code.value,
        response.error.message,
      );
    }

    // Convert response to MessageModel
    return MessageModel(
      messageId: response.success.messageId,
      conversationId: _deriveConversationId(recipientUserId, ''), // Will be filled by repository
      senderUserId: '', // Will be filled by repository
      senderDeviceId: '', // Will be filled by repository
      recipientUserId: recipientUserId,
      recipientDeviceId: recipientDeviceId,
      messageType: MessageType.text,
      textContent: textContent,
      metadata: metadata ?? {},
      timestamp: _timestampFromProto(response.success.serverTimestamp),
      deliveryStatus: _deliveryStatusFromProto(response.success.deliveryStatus),
    );
  }

  /// Get message history via gRPC
  Future<List<MessageModel>> getMessages({
    required String accessToken,
    required String conversationUserId,
    String? conversationId,
    int limit = 50,
    String? beforeMessageId,
    String? currentUserId,
  }) async {
    final request = proto.GetMessagesRequest(
      accessToken: accessToken,
      conversationUserId: conversationUserId,
      limit: limit,
    );

    if (conversationId != null) {
      request.conversationId = conversationId;
    }

    final response = await _messagingClient.getMessages(request);

    if (response.hasError()) {
      throw GrpcError.custom(
        response.error.code.value,
        response.error.message,
      );
    }

    return response.success.messages
        .map((msg) => MessageModel.fromProto(msg, currentUserId: currentUserId))
        .toList();
  }

  /// Subscribe to incoming messages via gRPC streaming
  Stream<MessageModel> receiveMessages({
    required String accessToken,
    String? currentUserId,
  }) async* {
    final request = proto.ReceiveMessagesRequest(
      accessToken: accessToken,
      includeHistory: false,
    );

    final stream = _messagingClient.receiveMessages(request);

    await for (final message in stream) {
      yield MessageModel.fromProto(message, currentUserId: currentUserId);
    }
  }

  /// Mark messages as read via gRPC
  Future<void> markAsRead({
    required String accessToken,
    required List<String> messageIds,
  }) async {
    final request = proto.MarkAsReadRequest(
      accessToken: accessToken,
      messageIds: messageIds,
    );

    final response = await _messagingClient.markAsRead(request);

    if (response.hasError()) {
      throw GrpcError.custom(
        response.error.code.value,
        response.error.message,
      );
    }
  }

  /// Delete a message via gRPC
  Future<void> deleteMessage({
    required String accessToken,
    required String messageId,
    required String conversationId,
    bool deleteForEveryone = false,
  }) async {
    final request = proto.DeleteMessageRequest(
      accessToken: accessToken,
      messageId: messageId,
      conversationId: conversationId,
      deleteForEveryone: deleteForEveryone,
    );

    final response = await _messagingClient.deleteMessage(request);

    if (response.hasError()) {
      throw GrpcError.custom(
        response.error.code.value,
        response.error.message,
      );
    }
  }

  // Helper methods

  String _generateMessageId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  proto_common.Timestamp _createTimestamp(DateTime dateTime) {
    final milliseconds = dateTime.millisecondsSinceEpoch;
    return proto_common.Timestamp(
      seconds: Int64(milliseconds ~/ 1000),
      nanos: (milliseconds % 1000) * 1000000,
    );
  }

  DateTime _timestampFromProto(proto_common.Timestamp? timestamp) {
    if (timestamp == null) return DateTime.now();
    return DateTime.fromMillisecondsSinceEpoch(
      timestamp.seconds.toInt() * 1000 + (timestamp.nanos ~/ 1000000),
    );
  }

  DeliveryStatus _deliveryStatusFromProto(proto.DeliveryStatus status) {
    switch (status) {
      case proto.DeliveryStatus.PENDING:
        return DeliveryStatus.pending;
      case proto.DeliveryStatus.SENT:
        return DeliveryStatus.sent;
      case proto.DeliveryStatus.DELIVERED:
        return DeliveryStatus.delivered;
      case proto.DeliveryStatus.READ:
        return DeliveryStatus.read;
      case proto.DeliveryStatus.FAILED:
        return DeliveryStatus.failed;
      default:
        return DeliveryStatus.pending;
    }
  }

  String _deriveConversationId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}:${users[1]}';
  }
}
