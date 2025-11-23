import 'package:equatable/equatable.dart';

/// Core business entity representing a message
class Message extends Equatable {
  final String messageId;
  final String conversationId;
  final String senderUserId;
  final String senderDeviceId;
  final String recipientUserId;
  final String recipientDeviceId;
  final MessageType messageType;
  final String textContent;
  final Map<String, String> metadata;
  final DateTime timestamp;
  final DeliveryStatus deliveryStatus;
  final String? currentUserId; // For determining if message is sent by current user

  const Message({
    required this.messageId,
    required this.conversationId,
    required this.senderUserId,
    required this.senderDeviceId,
    required this.recipientUserId,
    required this.recipientDeviceId,
    required this.messageType,
    required this.textContent,
    required this.metadata,
    required this.timestamp,
    required this.deliveryStatus,
    this.currentUserId,
  });

  /// Check if this message was sent by the current user
  bool get isSentByMe => currentUserId != null && senderUserId == currentUserId;

  /// Format timestamp for display
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time only
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week - show day name
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1];
    } else {
      // Older - show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  List<Object?> get props => [
        messageId,
        conversationId,
        senderUserId,
        senderDeviceId,
        recipientUserId,
        recipientDeviceId,
        messageType,
        textContent,
        metadata,
        timestamp,
        deliveryStatus,
        currentUserId,
      ];
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
}

enum DeliveryStatus {
  pending,
  sent,
  delivered,
  read,
  failed,
}
