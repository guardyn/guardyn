import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardyn_client/features/messaging/domain/entities/message.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_state.dart';
import 'package:guardyn_client/features/messaging/presentation/pages/search_messages_page.dart';

class MockMessageBloc extends Mock implements MessageBloc {}

void main() {
  late MockMessageBloc mockMessageBloc;

  final testMessages = [
    Message(
      messageId: 'msg-1',
      conversationId: 'conv-123',
      senderUserId: 'user-1',
      senderDeviceId: 'device-1',
      recipientUserId: 'user-2',
      recipientDeviceId: 'device-2',
      messageType: MessageType.text,
      textContent: 'Hello world',
      metadata: const {},
      timestamp: DateTime(2026, 1, 23, 10, 0),
      deliveryStatus: DeliveryStatus.delivered,
      currentUserId: 'user-1',
    ),
    Message(
      messageId: 'msg-2',
      conversationId: 'conv-123',
      senderUserId: 'user-2',
      senderDeviceId: 'device-2',
      recipientUserId: 'user-1',
      recipientDeviceId: 'device-1',
      messageType: MessageType.text,
      textContent: 'Hello there',
      metadata: const {},
      timestamp: DateTime(2026, 1, 23, 10, 5),
      deliveryStatus: DeliveryStatus.read,
      currentUserId: 'user-1',
    ),
    Message(
      messageId: 'msg-3',
      conversationId: 'conv-123',
      senderUserId: 'user-1',
      senderDeviceId: 'device-1',
      recipientUserId: 'user-2',
      recipientDeviceId: 'device-2',
      messageType: MessageType.text,
      textContent: 'Goodbye world',
      metadata: const {},
      timestamp: DateTime(2026, 1, 23, 10, 10),
      deliveryStatus: DeliveryStatus.sent,
      currentUserId: 'user-1',
    ),
    Message(
      messageId: 'msg-4',
      conversationId: 'conv-123',
      senderUserId: 'user-2',
      senderDeviceId: 'device-2',
      recipientUserId: 'user-1',
      recipientDeviceId: 'device-1',
      messageType: MessageType.image,
      textContent: 'image.png',
      metadata: const {},
      timestamp: DateTime(2026, 1, 23, 10, 15),
      deliveryStatus: DeliveryStatus.delivered,
      currentUserId: 'user-1',
    ),
  ];

  setUp(() {
    mockMessageBloc = MockMessageBloc();
    when(() => mockMessageBloc.state).thenReturn(
      MessageLoaded(messages: testMessages),
    );
    when(() => mockMessageBloc.stream).thenAnswer(
      (_) => Stream.value(MessageLoaded(messages: testMessages)),
    );
    when(() => mockMessageBloc.isClosed).thenReturn(false);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<MessageBloc>.value(
        value: mockMessageBloc,
        child: const SearchMessagesPage(
          conversationId: 'conv-123',
          conversationUserName: 'Test User',
        ),
      ),
    );
  }

  group('SearchMessagesPage', () {
    testWidgets('should display search field with hint text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search in Test User...'), findsOneWidget);
    });

    testWidgets('should display empty state when no query', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Search messages'), findsOneWidget);
      expect(find.text('Type to search in this conversation'), findsOneWidget);
    });

    testWidgets('should search and display matching messages', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Type search query
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      // Should find 2 messages containing "Hello"
      expect(find.text('2 messages found'), findsOneWidget);
      // ListTiles should be present for each result
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('should search case-insensitively', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Type lowercase query
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pumpAndSettle();

      // Should still find 2 messages
      expect(find.text('2 messages found'), findsOneWidget);
    });

    testWidgets('should display no results message when query has no matches',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Type non-matching query
      await tester.enterText(find.byType(TextField), 'xyz123');
      await tester.pumpAndSettle();

      expect(find.text('No messages found'), findsOneWidget);
      expect(find.text('Try a different search term'), findsOneWidget);
    });

    testWidgets('should only search text messages, not images', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Search for image content
      await tester.enterText(find.byType(TextField), 'image');
      await tester.pumpAndSettle();

      // Should not find the image message
      expect(find.text('No messages found'), findsOneWidget);
    });

    testWidgets('should clear search when clear button is pressed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Type search query
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      // Find and tap clear button
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Should show empty state again
      expect(find.text('Search messages'), findsOneWidget);
    });

    testWidgets('should pop with messageId when result is tapped',
        (tester) async {
      String? poppedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MessageBloc>.value(
            value: mockMessageBloc,
            child: Navigator(
              onPopPage: (route, result) {
                poppedValue = result as String?;
                return route.didPop(result);
              },
              pages: [
                MaterialPage(
                  child: Builder(
                    builder: (context) => const SearchMessagesPage(
                      conversationId: 'conv-123',
                      conversationUserName: 'Test User',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type search query
      await tester.enterText(find.byType(TextField), 'world');
      await tester.pumpAndSettle();

      // Tap on result (should find "Hello world" and "Goodbye world")
      // Since we're using RichText, look for the ListTile differently
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsNWidgets(2)); // 2 messages with "world"
      
      await tester.tap(listTiles.first);
      await tester.pumpAndSettle();

      // Verify pop was called with message ID
      expect(poppedValue, isNotNull);
    });

    testWidgets('should search for specific message content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Search for unique content
      await tester.enterText(find.byType(TextField), 'Goodbye');
      await tester.pumpAndSettle();

      // Should find exactly 1 message
      expect(find.text('1 message found'), findsOneWidget);
    });
  });
}
