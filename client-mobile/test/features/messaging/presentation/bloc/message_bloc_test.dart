import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/messaging/domain/entities/message.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/mark_as_read.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/receive_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/send_message.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_event.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_state.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockSendMessage extends Mock implements SendMessage {}

class MockGetMessages extends Mock implements GetMessages {}

class MockReceiveMessages extends Mock implements ReceiveMessages {}

class MockMarkAsRead extends Mock implements MarkAsRead {}

// Fake classes for argument matchers
class FakeSendMessageParams extends Fake implements SendMessageParams {}

class FakeGetMessagesParams extends Fake implements GetMessagesParams {}

class FakeMarkAsReadParams extends Fake implements MarkAsReadParams {}

void main() {
  late MessageBloc bloc;
  late MockSendMessage mockSendMessage;
  late MockGetMessages mockGetMessages;
  late MockReceiveMessages mockReceiveMessages;
  late MockMarkAsRead mockMarkAsRead;

  // Test data
  const tConversationUserId = 'user-456';
  const tConversationId = 'conv-001';
  const tRecipientDeviceId = 'device-456';
  const tRecipientUsername = 'bob';
  const tTextContent = 'Hello, World!';

  final tMessage1 = Message(
    messageId: 'msg-001',
    conversationId: tConversationId,
    senderUserId: 'user-123',
    senderDeviceId: 'device-123',
    recipientUserId: tConversationUserId,
    recipientDeviceId: tRecipientDeviceId,
    messageType: MessageType.text,
    textContent: 'Hello!',
    metadata: const {},
    timestamp: DateTime(2025, 11, 29, 10, 0),
    deliveryStatus: DeliveryStatus.sent,
  );

  final tMessage2 = Message(
    messageId: 'msg-002',
    conversationId: tConversationId,
    senderUserId: tConversationUserId,
    senderDeviceId: tRecipientDeviceId,
    recipientUserId: 'user-123',
    recipientDeviceId: 'device-123',
    messageType: MessageType.text,
    textContent: 'Hi there!',
    metadata: const {},
    timestamp: DateTime(2025, 11, 29, 10, 5),
    deliveryStatus: DeliveryStatus.delivered,
  );

  final tMessages = [tMessage1, tMessage2];

  setUpAll(() {
    registerFallbackValue(FakeSendMessageParams());
    registerFallbackValue(FakeGetMessagesParams());
    registerFallbackValue(FakeMarkAsReadParams());
  });

  setUp(() {
    mockSendMessage = MockSendMessage();
    mockGetMessages = MockGetMessages();
    mockReceiveMessages = MockReceiveMessages();
    mockMarkAsRead = MockMarkAsRead();

    bloc = MessageBloc(
      sendMessage: mockSendMessage,
      getMessages: mockGetMessages,
      receiveMessages: mockReceiveMessages,
      markAsRead: mockMarkAsRead,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be MessageInitial', () {
    expect(bloc.state, isA<MessageInitial>());
  });

  group('MessageLoadHistory', () {
    blocTest<MessageBloc, MessageState>(
      'emits [MessageLoading, MessageLoaded] when loading history succeeds',
      build: () {
        when(() => mockGetMessages(any()))
            .thenAnswer((_) async => Right(tMessages));
        return bloc;
      },
      act: (bloc) => bloc.add(const MessageLoadHistory(
        conversationUserId: tConversationUserId,
      )),
      expect: () => [
        isA<MessageLoading>(),
        isA<MessageLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          2,
        ),
      ],
      verify: (_) {
        verify(() => mockGetMessages(any())).called(1);
      },
    );

    blocTest<MessageBloc, MessageState>(
      'emits [MessageLoading, MessageError] when loading history fails',
      build: () {
        when(() => mockGetMessages(any()))
            .thenAnswer((_) async => const Left(NetworkFailure('No internet')));
        return bloc;
      },
      act: (bloc) => bloc.add(const MessageLoadHistory(
        conversationUserId: tConversationUserId,
      )),
      expect: () => [
        isA<MessageLoading>(),
        isA<MessageError>().having(
          (s) => s.message,
          'error message',
          'No internet',
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [MessageLoading, MessageLoaded] with hasMore=true when limit reached',
      build: () {
        final messages = List.generate(
          50,
          (i) => Message(
            messageId: 'msg-$i',
            conversationId: tConversationId,
            senderUserId: 'user-123',
            senderDeviceId: 'device-123',
            recipientUserId: tConversationUserId,
            recipientDeviceId: tRecipientDeviceId,
            messageType: MessageType.text,
            textContent: 'Message $i',
            metadata: const {},
            timestamp: DateTime(2025, 11, 29, 10, i),
            deliveryStatus: DeliveryStatus.sent,
          ),
        );
        when(() => mockGetMessages(any()))
            .thenAnswer((_) async => Right(messages));
        return bloc;
      },
      act: (bloc) => bloc.add(const MessageLoadHistory(
        conversationUserId: tConversationUserId,
        limit: 50,
      )),
      expect: () => [
        isA<MessageLoading>(),
        isA<MessageLoaded>().having(
          (s) => s.hasMore,
          'hasMore',
          true,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [MessageLoading, MessageLoaded] with empty list when no messages',
      build: () {
        when(() => mockGetMessages(any()))
            .thenAnswer((_) async => const Right(<Message>[]));
        return bloc;
      },
      act: (bloc) => bloc.add(const MessageLoadHistory(
        conversationUserId: tConversationUserId,
      )),
      expect: () => [
        isA<MessageLoading>(),
        isA<MessageLoaded>().having(
          (s) => s.messages.isEmpty,
          'messages empty',
          true,
        ),
      ],
    );
  });

  group('MessageSend', () {
    blocTest<MessageBloc, MessageState>(
      'emits [MessageSending, MessageLoaded] when sending succeeds',
      build: () {
        when(() => mockSendMessage(any()))
            .thenAnswer((_) async => Right(tMessage1));
        return bloc;
      },
      act: (bloc) => bloc.add(const MessageSend(
        recipientUserId: tConversationUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      )),
      expect: () => [
        isA<MessageSending>(),
        isA<MessageLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          1,
        ),
      ],
      verify: (_) {
        verify(() => mockSendMessage(any())).called(1);
      },
    );

    blocTest<MessageBloc, MessageState>(
      'emits [MessageSending, MessageError] when sending fails',
      build: () {
        when(() => mockSendMessage(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Send failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const MessageSend(
        recipientUserId: tConversationUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      )),
      expect: () => [
        isA<MessageSending>(),
        isA<MessageError>().having(
          (s) => s.message,
          'error message',
          'Send failed',
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'preserves existing messages when sending a new one',
      build: () {
        when(() => mockSendMessage(any()))
            .thenAnswer((_) async => Right(tMessage2));
        return bloc;
      },
      seed: () => MessageLoaded(messages: [tMessage1]),
      act: (bloc) => bloc.add(const MessageSend(
        recipientUserId: tConversationUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      )),
      expect: () => [
        isA<MessageSending>().having(
          (s) => s.currentMessages.length,
          'current messages',
          1,
        ),
        isA<MessageLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          2,
        ),
      ],
    );
  });

  group('MessageReceived', () {
    blocTest<MessageBloc, MessageState>(
      'adds new message to empty state',
      build: () => bloc,
      act: (bloc) => bloc.add(MessageReceived(tMessage1)),
      expect: () => [
        isA<MessageLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          1,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'adds new message to existing messages',
      build: () => bloc,
      seed: () => MessageLoaded(messages: [tMessage1]),
      act: (bloc) => bloc.add(MessageReceived(tMessage2)),
      expect: () => [
        isA<MessageLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          2,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'does not add duplicate message',
      build: () => bloc,
      seed: () => MessageLoaded(messages: [tMessage1]),
      act: (bloc) => bloc.add(MessageReceived(tMessage1)),
      expect: () => [], // No state change expected
    );
  });

  group('MessageMarkAsRead', () {
    blocTest<MessageBloc, MessageState>(
      'updates message status to read when successful',
      build: () {
        when(() => mockMarkAsRead(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => MessageLoaded(messages: [tMessage1]),
      act: (bloc) => bloc.add(const MessageMarkAsRead('msg-001')),
      expect: () => [
        isA<MessageLoaded>().having(
          (s) => s.messages.first.deliveryStatus,
          'delivery status',
          DeliveryStatus.read,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'does nothing on mark as read failure (silent fail)',
      build: () {
        when(() => mockMarkAsRead(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Failed')));
        return bloc;
      },
      seed: () => MessageLoaded(messages: [tMessage1]),
      act: (bloc) => bloc.add(const MessageMarkAsRead('msg-001')),
      expect: () => [], // No state change expected on silent failure
    );
  });

  group('MessageDelete', () {
    blocTest<MessageBloc, MessageState>(
      'removes message from list',
      build: () => bloc,
      seed: () => MessageLoaded(messages: [tMessage1, tMessage2]),
      act: (bloc) => bloc.add(const MessageDelete('msg-001')),
      expect: () => [
        isA<MessageLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          1,
        ).having(
          (s) => s.messages.first.messageId,
          'remaining message ID',
          'msg-002',
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'does nothing when message not found',
      build: () => bloc,
      seed: () => MessageLoaded(messages: [tMessage1]),
      act: (bloc) => bloc.add(const MessageDelete('msg-nonexistent')),
      expect: () => [
        isA<MessageLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          1,
        ),
      ],
    );
  });

  group('MessageSetActiveConversation', () {
    blocTest<MessageBloc, MessageState>(
      'does not emit new state (internal tracking only)',
      build: () => bloc,
      act: (bloc) => bloc.add(const MessageSetActiveConversation('user-456')),
      expect: () => [],
    );
  });

  group('MessageStartPolling', () {
    blocTest<MessageBloc, MessageState>(
      'starts polling and fetches messages initially',
      build: () {
        when(() => mockGetMessages(any()))
            .thenAnswer((_) async => Right(tMessages));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const MessageStartPolling(
          conversationUserId: tConversationUserId,
          interval: Duration(seconds: 10),
        ));
        // Wait for initial poll
        await Future.delayed(const Duration(milliseconds: 100));
      },
      expect: () => [
        // New messages are added via MessageReceived events
        isA<MessageLoaded>(),
        isA<MessageLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetMessages(any())).called(greaterThan(0));
      },
    );
  });

  group('MessageStopPolling', () {
    blocTest<MessageBloc, MessageState>(
      'stops polling without emitting new state',
      build: () => bloc,
      act: (bloc) => bloc.add(const MessageStopPolling()),
      expect: () => [],
    );
  });
}
