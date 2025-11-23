import 'package:fixnum/fixnum.dart';

import '../../../../generated/common.pb.dart' as common_proto;
import '../../../../generated/messaging.pb.dart' as proto;
import '../../domain/entities/message.dart';

/// Data transfer object for Message
/// Converts between domain entity and proto/JSON
class MessageModel extends Message {
  const MessageModel({
    required super.messageId,
    required super.conversationId,
    required super.senderUserId,
    required super.senderDeviceId,
    required super.recipientUserId,
    required super.recipientDeviceId,
    required super.messageType,
    required super.textContent,
    required super.metadata,
    required super.timestamp,
    required super.deliveryStatus,
    super.currentUserId,
  });

  /// Create MessageModel from proto Message
  factory MessageModel.fromProto(proto.Message protoMessage, {String? currentUserId}) {
    return MessageModel(
      messageId: protoMessage.messageId,
      conversationId: _extractConversationId(protoMessage),
      senderUserId: protoMessage.senderUserId,
      senderDeviceId: protoMessage.senderDeviceId,
      recipientUserId: protoMessage.recipientUserId,
      recipientDeviceId: protoMessage.recipientDeviceId,
      messageType: _messageTypeFromProto(protoMessage.messageType),
      textContent: String.fromCharCodes(protoMessage.encryptedContent),
      metadata: _extractMetadata(protoMessage),
      timestamp: _timestampFromProto(protoMessage.serverTimestamp),
      deliveryStatus: _deliveryStatusFromProto(protoMessage.deliveryStatus),
      currentUserId: currentUserId,
    );
  }

  /// Convert to SendMessageRequest proto
  proto.SendMessageRequest toSendRequest({
    required String accessToken,
    required String clientMessageId,
  }) {
    return proto.SendMessageRequest(
      accessToken: accessToken,
      recipientUserId: recipientUserId,
      recipientDeviceId: recipientDeviceId,
      encryptedContent: textContent.codeUnits,
      messageType: _messageTypeToProto(messageType),
      clientMessageId: clientMessageId,
      clientTimestamp: _timestampToProto(timestamp),
    );
  }

  // Helper methods for enum conversions

  static MessageType _messageTypeFromProto(proto.MessageType protoType) {
    switch (protoType) {
      case proto.MessageType.TEXT:
        return MessageType.text;
      case proto.MessageType.IMAGE:
        return MessageType.image;
      case proto.MessageType.VIDEO:
        return MessageType.video;
      case proto.MessageType.AUDIO:
        return MessageType.audio;
      case proto.MessageType.FILE:
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  static proto.MessageType _messageTypeToProto(MessageType type) {
    switch (type) {
      case MessageType.text:
        return proto.MessageType.TEXT;
      case MessageType.image:
        return proto.MessageType.IMAGE;
      case MessageType.video:
        return proto.MessageType.VIDEO;
      case MessageType.audio:
        return proto.MessageType.AUDIO;
      case MessageType.file:
        return proto.MessageType.FILE;
    }
  }

  static DeliveryStatus _deliveryStatusFromProto(proto.DeliveryStatus protoStatus) {
    switch (protoStatus) {
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

  static DateTime _timestampFromProto(common_proto.Timestamp? timestamp) {
    if (timestamp == null) return DateTime.now();
    return DateTime.fromMillisecondsSinceEpoch(
      timestamp.seconds.toInt() * 1000 + (timestamp.nanos ~/ 1000000),
    );
  }

  static common_proto.Timestamp _timestampToProto(DateTime dateTime) {
    final milliseconds = dateTime.millisecondsSinceEpoch;
    return common_proto.Timestamp(
      seconds: Int64(milliseconds ~/ 1000),
      nanos: (milliseconds % 1000) * 1000000,
    );
  }

  static String _extractConversationId(proto.Message protoMessage) {
    // For 1-on-1 messaging, conversation ID is derived from user IDs
    // Format: <smaller_user_id>:<larger_user_id>
    final users = [protoMessage.senderUserId, protoMessage.recipientUserId]..sort();
    return '${users[0]}:${users[1]}';
  }

  static Map<String, String> _extractMetadata(proto.Message protoMessage) {
    return {
      'client_message_id': protoMessage.clientMessageId,
      'media_id': protoMessage.mediaId,
      'is_deleted': protoMessage.isDeleted.toString(),
    };
  }
}
