import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/messaging/domain/entities/message.dart';
import 'package:guardyn_client/features/messaging/domain/repositories/message_repository.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late GetMessages usecase;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    usecase = GetMessages(mockRepository);
  });

  const tConversationUserId = 'user-456';
  const tConversationId = 'conv-001';

  final tMessages = [
    Message(
      messageId: 'msg-001',
      conversationId: tConversationId,
      senderUserId: 'user-123',
      senderDeviceId: 'device-123',
      recipientUserId: tConversationUserId,
      recipientDeviceId: 'device-456',
      messageType: MessageType.text,
      textContent: 'Hello!',
      metadata: const {},
      timestamp: DateTime(2025, 11, 29, 10, 0),
      deliveryStatus: DeliveryStatus.read,
    ),
    Message(
      messageId: 'msg-002',
      conversationId: tConversationId,
      senderUserId: tConversationUserId,
      senderDeviceId: 'device-456',
      recipientUserId: 'user-123',
      recipientDeviceId: 'device-123',
      messageType: MessageType.text,
      textContent: 'Hi there!',
      metadata: const {},
      timestamp: DateTime(2025, 11, 29, 10, 5),
      deliveryStatus: DeliveryStatus.sent,
    ),
    Message(
      messageId: 'msg-003',
      conversationId: tConversationId,
      senderUserId: 'user-123',
      senderDeviceId: 'device-123',
      recipientUserId: tConversationUserId,
      recipientDeviceId: 'device-456',
      messageType: MessageType.text,
      textContent: 'How are you?',
      metadata: const {},
      timestamp: DateTime(2025, 11, 29, 10, 10),
      deliveryStatus: DeliveryStatus.delivered,
    ),
  ];

  group('GetMessages', () {
    test('should get messages from repository when called with required params',
        () async {
      // arrange
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => Right(tMessages));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
      ));

      // assert
      expect(result, Right(tMessages));
      verify(() => mockRepository.getMessages(
            conversationUserId: tConversationUserId,
            conversationId: null,
            limit: 50,
            beforeMessageId: null,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get messages with conversation ID when provided', () async {
      // arrange
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => Right(tMessages));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
        conversationId: tConversationId,
      ));

      // assert
      expect(result, Right(tMessages));
      verify(() => mockRepository.getMessages(
            conversationUserId: tConversationUserId,
            conversationId: tConversationId,
            limit: 50,
            beforeMessageId: null,
          )).called(1);
    });

    test('should get messages with custom limit', () async {
      // arrange
      const customLimit = 20;
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => Right(tMessages));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
        limit: customLimit,
      ));

      // assert
      expect(result, Right(tMessages));
      verify(() => mockRepository.getMessages(
            conversationUserId: tConversationUserId,
            conversationId: null,
            limit: customLimit,
            beforeMessageId: null,
          )).called(1);
    });

    test('should get messages with pagination (beforeMessageId)', () async {
      // arrange
      const beforeMsgId = 'msg-002';
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => Right([tMessages[0]]));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
        beforeMessageId: beforeMsgId,
      ));

      // assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r.length, 1),
      );
      verify(() => mockRepository.getMessages(
            conversationUserId: tConversationUserId,
            conversationId: null,
            limit: 50,
            beforeMessageId: beforeMsgId,
          )).called(1);
    });

    test('should return empty list when no messages exist', () async {
      // arrange
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => const Right(<Message>[]));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
      ));

      // assert
      expect(result, const Right(<Message>[]));
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r.isEmpty, true),
      );
    });

    test('should return NetworkFailure when repository fails with network error',
        () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
      ));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getMessages(
            conversationUserId: tConversationUserId,
            conversationId: null,
            limit: 50,
            beforeMessageId: null,
          )).called(1);
    });

    test('should return ServerFailure when repository fails with server error',
        () async {
      // arrange
      const tFailure = ServerFailure('Internal server error');
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
      ));

      // assert
      expect(result, const Left(tFailure));
    });

    test('should return AuthFailure when not authenticated', () async {
      // arrange
      const tFailure = AuthFailure('Token expired');
      when(() => mockRepository.getMessages(
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(GetMessagesParams(
        conversationUserId: tConversationUserId,
      ));

      // assert
      expect(result, const Left(tFailure));
    });
  });

  group('GetMessagesParams', () {
    test('should create params with default limit of 50', () {
      // act
      final params = GetMessagesParams(
        conversationUserId: tConversationUserId,
      );

      // assert
      expect(params.conversationUserId, tConversationUserId);
      expect(params.conversationId, null);
      expect(params.limit, 50);
      expect(params.beforeMessageId, null);
    });

    test('should create params with all optional values', () {
      // act
      final params = GetMessagesParams(
        conversationUserId: tConversationUserId,
        conversationId: tConversationId,
        limit: 25,
        beforeMessageId: 'msg-100',
      );

      // assert
      expect(params.conversationUserId, tConversationUserId);
      expect(params.conversationId, tConversationId);
      expect(params.limit, 25);
      expect(params.beforeMessageId, 'msg-100');
    });
  });
}
