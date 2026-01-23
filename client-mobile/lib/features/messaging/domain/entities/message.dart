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
  final String senderUsername; // Display name of the sender

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
    this.senderUsername = '',
  });

  /// Check if this message was sent by the current user
  bool get isSentByMe => currentUserId != null && senderUserId == currentUserId;

  /// Get display name for sender (username or fallback to truncated userId)
  String get senderDisplayName {
    if (senderUsername.isNotEmpty) {
      return senderUsername;
    }
    // Fallback to userId (show first 8 chars)
    return senderUserId.length > 8 
        ? senderUserId.substring(0, 8) 
        : senderUserId;
  }

  /// Create a copy with updated fields
  Message copyWith({
    String? messageId,
    String? conversationId,
    String? senderUserId,
    String? senderDeviceId,
    String? recipientUserId,
    String? recipientDeviceId,
    MessageType? messageType,
    String? textContent,
    Map<String, String>? metadata,
    DateTime? timestamp,
    DeliveryStatus? deliveryStatus,
    String? currentUserId,
    String? senderUsername,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderUserId: senderUserId ?? this.senderUserId,
      senderDeviceId: senderDeviceId ?? this.senderDeviceId,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      recipientDeviceId: recipientDeviceId ?? this.recipientDeviceId,
      messageType: messageType ?? this.messageType,
      textContent: textContent ?? this.textContent,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      currentUserId: currentUserId ?? this.currentUserId,
      senderUsername: senderUsername ?? this.senderUsername,
    );
  }

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
        senderUsername,
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
