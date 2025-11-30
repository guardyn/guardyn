import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/groups/domain/entities/group.dart';
import 'package:guardyn_client/features/groups/presentation/widgets/group_message_bubble.dart';

void main() {
  // Test data
  const tGroupId = 'group-001';
  const tUserId = 'user-123';

  final tSentMessage = GroupMessage(
    messageId: 'msg-001',
    groupId: tGroupId,
    senderUserId: tUserId,
    senderDeviceId: 'device-123',
    senderUsername: 'alice',
    messageType: GroupMessageType.text,
    textContent: 'Hello group!',
    clientTimestamp: DateTime(2025, 11, 29, 10, 0),
    serverTimestamp: DateTime(2025, 11, 29, 10, 0),
    currentUserId: tUserId, // Same as sender - message was sent by me
  );

  final tReceivedMessage = GroupMessage(
    messageId: 'msg-002',
    groupId: tGroupId,
    senderUserId: 'user-456',
    senderDeviceId: 'device-456',
    senderUsername: 'bob',
    messageType: GroupMessageType.text,
    textContent: 'Hi everyone!',
    clientTimestamp: DateTime(2025, 11, 29, 10, 1),
    serverTimestamp: DateTime(2025, 11, 29, 10, 1),
    currentUserId: tUserId, // Different from sender - message was received
  );

  Widget buildTestableWidget(GroupMessage message, {bool showSenderName = true}) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GroupMessageBubble(
            message: message,
            showSenderName: showSenderName,
          ),
        ),
      ),
    );
  }

  group('GroupMessageBubble', () {
    testWidgets('displays message text content', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tSentMessage));

      expect(find.text('Hello group!'), findsOneWidget);
    });

    testWidgets('displays message timestamp', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tSentMessage));

      // Check if time is displayed (format may vary)
      expect(find.textContaining(RegExp(r'\d{1,2}:\d{2}')), findsWidgets);
    });

    testWidgets('shows sender name for received messages when enabled',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(tReceivedMessage));

      expect(find.text('bob'), findsOneWidget);
    });

    testWidgets('hides sender name for received messages when disabled',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        tReceivedMessage,
        showSenderName: false,
      ));

      expect(find.text('bob'), findsNothing);
    });

    testWidgets('does not show sender name for sent messages', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tSentMessage));

      // alice is the sender's name, but should not appear for own messages
      // because showSenderName is only shown for received messages
      expect(find.text('alice'), findsNothing);
    });

    testWidgets('has correct alignment for sent messages', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tSentMessage));

      // For sent messages, the Row should have MainAxisAlignment.end
      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('has correct alignment for received messages', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tReceivedMessage));

      // For received messages, the Row should have MainAxisAlignment.start
      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
    });

    testWidgets('shows avatar for received messages', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tReceivedMessage));

      // Avatar should be present for received messages
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('has bubble with rounded corners', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tSentMessage));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GroupMessageBubble),
          matching: find.byType(Container).first,
        ),
      );
      
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('displays received message content', (tester) async {
      await tester.pumpWidget(buildTestableWidget(tReceivedMessage));

      expect(find.text('Hi everyone!'), findsOneWidget);
    });
  });
}
