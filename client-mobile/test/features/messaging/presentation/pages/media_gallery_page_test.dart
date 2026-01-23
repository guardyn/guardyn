import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardyn_client/features/messaging/domain/entities/message.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_state.dart';
import 'package:guardyn_client/features/messaging/presentation/pages/media_gallery_page.dart';

class MockMessageBloc extends Mock implements MessageBloc {}

void main() {
  late MockMessageBloc mockMessageBloc;

  final testMessages = [
    // Text message
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
    // Image message
    Message(
      messageId: 'msg-2',
      conversationId: 'conv-123',
      senderUserId: 'user-2',
      senderDeviceId: 'device-2',
      recipientUserId: 'user-1',
      recipientDeviceId: 'device-1',
      messageType: MessageType.image,
      textContent: 'photo.jpg',
      metadata: const {'url': 'https://example.com/photo.jpg'},
      timestamp: DateTime(2026, 1, 23, 10, 5),
      deliveryStatus: DeliveryStatus.read,
      currentUserId: 'user-1',
    ),
    // Video message
    Message(
      messageId: 'msg-3',
      conversationId: 'conv-123',
      senderUserId: 'user-1',
      senderDeviceId: 'device-1',
      recipientUserId: 'user-2',
      recipientDeviceId: 'device-2',
      messageType: MessageType.video,
      textContent: 'video.mp4',
      metadata: const {'url': 'https://example.com/video.mp4'},
      timestamp: DateTime(2026, 1, 23, 10, 10),
      deliveryStatus: DeliveryStatus.sent,
      currentUserId: 'user-1',
    ),
    // Text with link
    Message(
      messageId: 'msg-4',
      conversationId: 'conv-123',
      senderUserId: 'user-2',
      senderDeviceId: 'device-2',
      recipientUserId: 'user-1',
      recipientDeviceId: 'device-1',
      messageType: MessageType.text,
      textContent: 'Check out https://flutter.dev for more info',
      metadata: const {},
      timestamp: DateTime(2026, 1, 23, 10, 15),
      deliveryStatus: DeliveryStatus.delivered,
      currentUserId: 'user-1',
    ),
    // File message
    Message(
      messageId: 'msg-5',
      conversationId: 'conv-123',
      senderUserId: 'user-1',
      senderDeviceId: 'device-1',
      recipientUserId: 'user-2',
      recipientDeviceId: 'device-2',
      messageType: MessageType.file,
      textContent: 'document.pdf',
      metadata: const {'file_name': 'document.pdf', 'file_size': '2.5 MB'},
      timestamp: DateTime(2026, 1, 23, 10, 20),
      deliveryStatus: DeliveryStatus.delivered,
      currentUserId: 'user-1',
    ),
    // Audio message
    Message(
      messageId: 'msg-6',
      conversationId: 'conv-123',
      senderUserId: 'user-2',
      senderDeviceId: 'device-2',
      recipientUserId: 'user-1',
      recipientDeviceId: 'device-1',
      messageType: MessageType.audio,
      textContent: 'voice_message.m4a',
      metadata: const {'file_name': 'voice_message.m4a'},
      timestamp: DateTime(2026, 1, 23, 10, 25),
      deliveryStatus: DeliveryStatus.read,
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
        child: const MediaGalleryPage(
          conversationId: 'conv-123',
          conversationUserName: 'Test User',
        ),
      ),
    );
  }

  group('MediaGalleryPage', () {
    testWidgets('should display app bar with username', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Media with Test User'), findsOneWidget);
    });

    testWidgets('should display three tabs', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Media'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
      expect(find.text('Docs'), findsOneWidget);
    });

    testWidgets('should display Media tab by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Media tab should show grid with 2 items (1 image + 1 video)
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should switch to Links tab', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Links tab
      await tester.tap(find.text('Links'));
      await tester.pumpAndSettle();

      // Should show link from message
      expect(find.text('flutter.dev'), findsOneWidget);
    });

    testWidgets('should switch to Docs tab', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Docs tab
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      // Should show document file
      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.text('voice_message.m4a'), findsOneWidget);
    });

    testWidgets('should display empty state when no media', (tester) async {
      when(() => mockMessageBloc.state).thenReturn(
        const MessageLoaded(messages: []),
      );
      when(() => mockMessageBloc.stream).thenAnswer(
        (_) => Stream.value(const MessageLoaded(messages: [])),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No shared media'), findsOneWidget);
      expect(
        find.text('Photos and videos you share will appear here'),
        findsOneWidget,
      );
    });

    testWidgets('should display empty state when no links', (tester) async {
      // Only text message without links
      final messagesWithoutLinks = [
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
      ];

      when(() => mockMessageBloc.state).thenReturn(
        MessageLoaded(messages: messagesWithoutLinks),
      );
      when(() => mockMessageBloc.stream).thenAnswer(
        (_) => Stream.value(MessageLoaded(messages: messagesWithoutLinks)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Links tab
      await tester.tap(find.text('Links'));
      await tester.pumpAndSettle();

      expect(find.text('No shared links'), findsOneWidget);
    });

    testWidgets('should display empty state when no docs', (tester) async {
      // Only text message
      final messagesWithoutDocs = [
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
      ];

      when(() => mockMessageBloc.state).thenReturn(
        MessageLoaded(messages: messagesWithoutDocs),
      );
      when(() => mockMessageBloc.stream).thenAnswer(
        (_) => Stream.value(MessageLoaded(messages: messagesWithoutDocs)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Docs tab
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      expect(find.text('No shared documents'), findsOneWidget);
    });
  });

  group('MediaTab', () {
    testWidgets('should display video indicator on video messages',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Video should have play icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });

  group('DocumentTile', () {
    testWidgets('should display file size and download button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Docs tab
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      // Should show file size
      expect(find.textContaining('2.5 MB'), findsOneWidget);
      // Should show download button
      expect(find.byIcon(Icons.download), findsNWidgets(2)); // 2 docs
    });
  });
}
