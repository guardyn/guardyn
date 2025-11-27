import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/messaging/domain/entities/message.dart';
import 'package:guardyn_client/features/messaging/domain/repositories/message_repository.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/send_message.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late SendMessage usecase;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    usecase = SendMessage(mockRepository);
  });

  final tRecipientUserId = 'user-123';
  final tRecipientDeviceId = 'device-456';
  final tRecipientUsername = 'testuser';
  final tTextContent = 'Hello, World!';

  final tMessage = Message(
    messageId: 'msg-789',
    conversationId: 'conv-001',
    senderUserId: 'user-sender',
    senderDeviceId: 'device-sender',
    recipientUserId: tRecipientUserId,
    recipientDeviceId: tRecipientDeviceId,
    messageType: MessageType.text,
    textContent: tTextContent,
    metadata: const {},
    timestamp: DateTime.now(),
    deliveryStatus: DeliveryStatus.sent,
  );

  test('should send message via repository', () async {
    // arrange
    when(() => mockRepository.sendMessage(
          recipientUserId: any(named: 'recipientUserId'),
          recipientDeviceId: any(named: 'recipientDeviceId'),
          recipientUsername: any(named: 'recipientUsername'),
          textContent: any(named: 'textContent'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async => Right(tMessage));

    // act
    final result = await usecase(SendMessageParams(
      recipientUserId: tRecipientUserId,
      recipientDeviceId: tRecipientDeviceId,
      recipientUsername: tRecipientUsername,
      textContent: tTextContent,
    ));

    // assert
    expect(result, Right(tMessage));
    verify(() => mockRepository.sendMessage(
          recipientUserId: tRecipientUserId,
          recipientDeviceId: tRecipientDeviceId,
          recipientUsername: tRecipientUsername,
          textContent: tTextContent,
          metadata: null,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = NetworkFailure('Network error');
    when(() => mockRepository.sendMessage(
          recipientUserId: any(named: 'recipientUserId'),
          recipientDeviceId: any(named: 'recipientDeviceId'),
          recipientUsername: any(named: 'recipientUsername'),
          textContent: any(named: 'textContent'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(SendMessageParams(
      recipientUserId: tRecipientUserId,
      recipientDeviceId: tRecipientDeviceId,
      recipientUsername: tRecipientUsername,
      textContent: tTextContent,
    ));

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.sendMessage(
          recipientUserId: tRecipientUserId,
          recipientDeviceId: tRecipientDeviceId,
          recipientUsername: tRecipientUsername,
          textContent: tTextContent,
          metadata: null,
        )).called(1);
  });
}
