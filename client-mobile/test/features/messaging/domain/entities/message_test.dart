import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/messaging/domain/entities/message.dart';

void main() {
  group('Message Entity', () {
    late Message baseMessage;

    setUp(() {
      baseMessage = Message(
        messageId: 'msg-123',
        conversationId: 'conv-456',
        senderUserId: 'user-abc123xyz789',
        senderDeviceId: 'device-1',
        recipientUserId: 'recipient-1',
        recipientDeviceId: 'device-2',
        messageType: MessageType.text,
        textContent: 'Hello, World!',
        metadata: const {},
        timestamp: DateTime(2024, 1, 15, 10, 30),
        deliveryStatus: DeliveryStatus.delivered,
        currentUserId: 'current-user',
      );
    });

    group('senderDisplayName', () {
      test('should return senderUsername when available', () {
        // Arrange
        final message = Message(
          messageId: 'msg-123',
          conversationId: 'conv-456',
          senderUserId: 'user-abc123xyz789',
          senderDeviceId: 'device-1',
          recipientUserId: 'recipient-1',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello!',
          metadata: const {},
          timestamp: DateTime.now(),
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'current-user',
          senderUsername: 'john_doe',
        );

        // Act & Assert
        expect(message.senderDisplayName, 'john_doe');
      });

      test('should return truncated userId when senderUsername is empty', () {
        // Arrange
        final message = Message(
          messageId: 'msg-123',
          conversationId: 'conv-456',
          senderUserId: 'user-abc123xyz789long',
          senderDeviceId: 'device-1',
          recipientUserId: 'recipient-1',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello!',
          metadata: const {},
          timestamp: DateTime.now(),
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'current-user',
          senderUsername: '', // Empty username
        );

        // Act & Assert
        expect(message.senderDisplayName, 'user-abc');
      });

      test('should return short userId as-is when less than 8 chars', () {
        // Arrange
        final message = Message(
          messageId: 'msg-123',
          conversationId: 'conv-456',
          senderUserId: 'usr123', // Short userId (6 chars)
          senderDeviceId: 'device-1',
          recipientUserId: 'recipient-1',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello!',
          metadata: const {},
          timestamp: DateTime.now(),
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'current-user',
          senderUsername: '',
        );

        // Act & Assert
        expect(message.senderDisplayName, 'usr123');
      });

      test('should truncate userId to exactly 8 chars for long ids', () {
        // Arrange
        final message = Message(
          messageId: 'msg-123',
          conversationId: 'conv-456',
          senderUserId: 'abcdefghijklmnop', // 16 chars
          senderDeviceId: 'device-1',
          recipientUserId: 'recipient-1',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello!',
          metadata: const {},
          timestamp: DateTime.now(),
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'current-user',
          senderUsername: '',
        );

        // Act & Assert
        expect(message.senderDisplayName, 'abcdefgh');
        expect(message.senderDisplayName.length, 8);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated senderUsername', () {
        // Act
        final updatedMessage = baseMessage.copyWith(
          senderUsername: 'updated_user',
        );

        // Assert
        expect(updatedMessage.senderUsername, 'updated_user');
        expect(updatedMessage.messageId, baseMessage.messageId);
        expect(updatedMessage.conversationId, baseMessage.conversationId);
        expect(updatedMessage.textContent, baseMessage.textContent);
      });

      test('should preserve all fields when no updates provided', () {
        // Act
        final copy = baseMessage.copyWith();

        // Assert
        expect(copy.messageId, baseMessage.messageId);
        expect(copy.conversationId, baseMessage.conversationId);
        expect(copy.senderUserId, baseMessage.senderUserId);
        expect(copy.senderDeviceId, baseMessage.senderDeviceId);
        expect(copy.recipientUserId, baseMessage.recipientUserId);
        expect(copy.recipientDeviceId, baseMessage.recipientDeviceId);
        expect(copy.textContent, baseMessage.textContent);
        expect(copy.timestamp, baseMessage.timestamp);
        expect(copy.deliveryStatus, baseMessage.deliveryStatus);
        expect(copy.messageType, baseMessage.messageType);
      });

      test('should update multiple fields at once', () {
        // Act
        final updatedMessage = baseMessage.copyWith(
          senderUsername: 'new_username',
          deliveryStatus: DeliveryStatus.read,
          textContent: 'Updated content',
        );

        // Assert
        expect(updatedMessage.senderUsername, 'new_username');
        expect(updatedMessage.deliveryStatus, DeliveryStatus.read);
        expect(updatedMessage.textContent, 'Updated content');
        // Other fields should remain unchanged
        expect(updatedMessage.messageId, baseMessage.messageId);
        expect(updatedMessage.conversationId, baseMessage.conversationId);
      });

      test('should create independent copy (immutability)', () {
        // Act
        final copy = baseMessage.copyWith(senderUsername: 'modified');

        // Assert - original should be unchanged
        expect(baseMessage.senderUsername, '');
        expect(copy.senderUsername, 'modified');
      });
    });

    group('isSentByMe', () {
      test('should return true when senderUserId matches currentUserId', () {
        // Arrange
        final message = Message(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          senderUserId: 'user-1',
          senderDeviceId: 'device-1',
          recipientUserId: 'user-2',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello',
          metadata: const {},
          timestamp: DateTime.now(),
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'user-1', // Same as senderUserId
        );

        // Assert
        expect(message.isSentByMe, true);
      });

      test('should return false when senderUserId differs from currentUserId', () {
        // Arrange
        final message = Message(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          senderUserId: 'user-1',
          senderDeviceId: 'device-1',
          recipientUserId: 'user-2',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello',
          metadata: const {},
          timestamp: DateTime.now(),
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'user-2', // Different from senderUserId
        );

        // Assert
        expect(message.isSentByMe, false);
      });

      test('should return false when currentUserId is null', () {
        // Arrange
        final message = Message(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          senderUserId: 'user-1',
          senderDeviceId: 'device-1',
          recipientUserId: 'user-2',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello',
          metadata: const {},
          timestamp: DateTime.now(),
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: null,
        );

        // Assert
        expect(message.isSentByMe, false);
      });
    });

    group('props (equality)', () {
      test('senderUsername should be included in props for equality', () {
        // Arrange
        final message1 = baseMessage.copyWith(senderUsername: 'user1');
        final message2 = baseMessage.copyWith(senderUsername: 'user2');

        // Assert - different usernames should make messages unequal
        expect(message1 == message2, false);
      });

      test('messages with same values should be equal', () {
        // Arrange
        final timestamp = DateTime(2024, 1, 1);
        final message1 = Message(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          senderUserId: 'sender-1',
          senderDeviceId: 'device-1',
          recipientUserId: 'recipient-1',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello',
          metadata: const {},
          timestamp: timestamp,
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'me',
          senderUsername: 'username',
        );
        final message2 = Message(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          senderUserId: 'sender-1',
          senderDeviceId: 'device-1',
          recipientUserId: 'recipient-1',
          recipientDeviceId: 'device-2',
          messageType: MessageType.text,
          textContent: 'Hello',
          metadata: const {},
          timestamp: timestamp,
          deliveryStatus: DeliveryStatus.sent,
          currentUserId: 'me',
          senderUsername: 'username',
        );

        // Assert
        expect(message1, message2);
      });
    });
  });
}
