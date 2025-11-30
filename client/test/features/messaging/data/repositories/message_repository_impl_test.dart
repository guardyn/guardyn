import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/features/messaging/data/datasources/key_exchange_datasource.dart';
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/data/models/message_model.dart';
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:guardyn_client/features/messaging/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockMessageRemoteDatasource extends Mock
    implements MessageRemoteDatasource {}

class MockKeyExchangeDatasource extends Mock
    implements KeyExchangeDatasource {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockCryptoService extends Mock implements CryptoService {}

void main() {
  late MessageRepositoryImpl repository;
  late MockMessageRemoteDatasource mockDatasource;
  late MockKeyExchangeDatasource mockKeyExchangeDatasource;
  late MockSecureStorage mockSecureStorage;
  late MockCryptoService mockCryptoService;

  setUp(() {
    mockDatasource = MockMessageRemoteDatasource();
    mockKeyExchangeDatasource = MockKeyExchangeDatasource();
    mockSecureStorage = MockSecureStorage();
    mockCryptoService = MockCryptoService();
    repository = MessageRepositoryImpl(
      mockDatasource, 
      mockKeyExchangeDatasource,
      mockSecureStorage, 
      mockCryptoService,
    );
  });

  const tAccessToken = 'test-access-token';
  const tCurrentUserId = 'user-123';
  const tCurrentDeviceId = 'device-123';
  const tRecipientUserId = 'user-456';
  const tRecipientDeviceId = 'device-456';
  const tRecipientUsername = 'bob';
  const tTextContent = 'Hello, World!';

  final tMessageModel = MessageModel(
    messageId: 'msg-789',
    conversationId: 'conv-001',
    senderUserId: tCurrentUserId,
    senderDeviceId: tCurrentDeviceId,
    recipientUserId: tRecipientUserId,
    recipientDeviceId: tRecipientDeviceId,
    messageType: MessageType.text,
    textContent: tTextContent,
    metadata: const {},
    timestamp: DateTime(2025, 11, 29, 10, 0),
    deliveryStatus: DeliveryStatus.sent,
  );

  final tMessagesList = [
    MessageModel(
      messageId: 'msg-001',
      conversationId: 'conv-001',
      senderUserId: tCurrentUserId,
      senderDeviceId: tCurrentDeviceId,
      recipientUserId: tRecipientUserId,
      recipientDeviceId: tRecipientDeviceId,
      messageType: MessageType.text,
      textContent: 'Hello!',
      metadata: const {},
      timestamp: DateTime(2025, 11, 29, 10, 0),
      deliveryStatus: DeliveryStatus.read,
    ),
    MessageModel(
      messageId: 'msg-002',
      conversationId: 'conv-001',
      senderUserId: tRecipientUserId,
      senderDeviceId: tRecipientDeviceId,
      recipientUserId: tCurrentUserId,
      recipientDeviceId: tCurrentDeviceId,
      messageType: MessageType.text,
      textContent: 'Hi there!',
      metadata: const {},
      timestamp: DateTime(2025, 11, 29, 10, 5),
      deliveryStatus: DeliveryStatus.delivered,
    ),
  ];

  group('sendMessage', () {
    void setUpSuccessfulAuth() {
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockSecureStorage.getUserId())
          .thenAnswer((_) async => tCurrentUserId);
      when(() => mockSecureStorage.getDeviceId())
          .thenAnswer((_) async => tCurrentDeviceId);
      // E2EE: Return null session to trigger plaintext fallback (test simplicity)
      when(() => mockCryptoService.getSession(
            remoteUserId: any(named: 'remoteUserId'),
            remoteDeviceId: any(named: 'remoteDeviceId'),
          )).thenAnswer((_) async => null);
      // E2EE: Skip session creation for tests (would need KeyBundle mock)
      when(() => mockCryptoService.isInitialized).thenReturn(false);
    }

    test('should return message when send is successful', () async {
      // arrange
      setUpSuccessfulAuth();
      when(() => mockDatasource.sendMessage(
            accessToken: any(named: 'accessToken'),
            recipientUserId: any(named: 'recipientUserId'),
            recipientDeviceId: any(named: 'recipientDeviceId'),
            recipientUsername: any(named: 'recipientUsername'),
            textContent: any(named: 'textContent'),
            metadata: any(named: 'metadata'),
          )).thenAnswer((_) async => tMessageModel);

      // act
      final result = await repository.sendMessage(
        recipientUserId: tRecipientUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      );

      // assert
      expect(result.isRight(), true);
      // Called twice: once for sendMessage, once for E2EE session creation attempt
      verify(() => mockSecureStorage.getAccessToken()).called(2);
      verify(() => mockDatasource.sendMessage(
            accessToken: tAccessToken,
            recipientUserId: tRecipientUserId,
            recipientDeviceId: tRecipientDeviceId,
            recipientUsername: tRecipientUsername,
            textContent: tTextContent,
            metadata: null,
          )).called(1);
    });

    test('should return AuthFailure when no access token', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.sendMessage(
        recipientUserId: tRecipientUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      );

      // assert
      expect(result, const Left(AuthFailure('No access token found')));
      verifyNever(() => mockDatasource.sendMessage(
            accessToken: any(named: 'accessToken'),
            recipientUserId: any(named: 'recipientUserId'),
            recipientDeviceId: any(named: 'recipientDeviceId'),
            recipientUsername: any(named: 'recipientUsername'),
            textContent: any(named: 'textContent'),
            metadata: any(named: 'metadata'),
          ));
    });

    test('should return AuthFailure when user ID is null', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockSecureStorage.getUserId()).thenAnswer((_) async => null);
      when(() => mockSecureStorage.getDeviceId())
          .thenAnswer((_) async => tCurrentDeviceId);

      // act
      final result = await repository.sendMessage(
        recipientUserId: tRecipientUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      );

      // assert
      expect(result, const Left(AuthFailure('User not authenticated')));
    });

    test('should return NetworkFailure on GrpcError unavailable', () async {
      // arrange
      setUpSuccessfulAuth();
      when(() => mockDatasource.sendMessage(
            accessToken: any(named: 'accessToken'),
            recipientUserId: any(named: 'recipientUserId'),
            recipientDeviceId: any(named: 'recipientDeviceId'),
            recipientUsername: any(named: 'recipientUsername'),
            textContent: any(named: 'textContent'),
            metadata: any(named: 'metadata'),
          )).thenThrow(GrpcError.unavailable('Service unavailable'));

      // act
      final result = await repository.sendMessage(
        recipientUserId: tRecipientUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      );

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return AuthFailure on GrpcError unauthenticated', () async {
      // arrange
      setUpSuccessfulAuth();
      when(() => mockDatasource.sendMessage(
            accessToken: any(named: 'accessToken'),
            recipientUserId: any(named: 'recipientUserId'),
            recipientDeviceId: any(named: 'recipientDeviceId'),
            recipientUsername: any(named: 'recipientUsername'),
            textContent: any(named: 'textContent'),
            metadata: any(named: 'metadata'),
          )).thenThrow(GrpcError.unauthenticated('Token expired'));

      // act
      final result = await repository.sendMessage(
        recipientUserId: tRecipientUserId,
        recipientDeviceId: tRecipientDeviceId,
        recipientUsername: tRecipientUsername,
        textContent: tTextContent,
      );

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getMessages', () {
    void setUpCryptoMocks() {
      // E2EE: Return null session to skip decryption (messages returned as-is)
      when(() => mockCryptoService.getSession(
            remoteUserId: any(named: 'remoteUserId'),
            remoteDeviceId: any(named: 'remoteDeviceId'),
          )).thenAnswer((_) async => null);
    }

    test('should return list of messages when successful', () async {
      // arrange
      setUpCryptoMocks();
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockSecureStorage.getUserId())
          .thenAnswer((_) async => tCurrentUserId);
      when(() => mockDatasource.getMessages(
            accessToken: any(named: 'accessToken'),
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
            currentUserId: any(named: 'currentUserId'),
          )).thenAnswer((_) async => tMessagesList);

      // act
      final result = await repository.getMessages(
        conversationUserId: tRecipientUserId,
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r.length, 2),
      );
      verify(() => mockSecureStorage.getAccessToken()).called(1);
      verify(() => mockDatasource.getMessages(
            accessToken: tAccessToken,
            conversationUserId: tRecipientUserId,
            conversationId: any(named: 'conversationId'),
            limit: 50,
            beforeMessageId: null,
            currentUserId: tCurrentUserId,
          )).called(1);
    });

    test('should return AuthFailure when no access token', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getMessages(
        conversationUserId: tRecipientUserId,
      );

      // assert
      expect(result, const Left(AuthFailure('No access token found')));
    });

    test('should return empty list when no messages', () async {
      // arrange
      setUpCryptoMocks();
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockSecureStorage.getUserId())
          .thenAnswer((_) async => tCurrentUserId);
      when(() => mockDatasource.getMessages(
            accessToken: any(named: 'accessToken'),
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
            currentUserId: any(named: 'currentUserId'),
          )).thenAnswer((_) async => <MessageModel>[]);

      // act
      final result = await repository.getMessages(
        conversationUserId: tRecipientUserId,
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r.isEmpty, true),
      );
    });

    test('should use custom limit when provided', () async {
      // arrange
      setUpCryptoMocks();
      const customLimit = 25;
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockSecureStorage.getUserId())
          .thenAnswer((_) async => tCurrentUserId);
      when(() => mockDatasource.getMessages(
            accessToken: any(named: 'accessToken'),
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
            currentUserId: any(named: 'currentUserId'),
          )).thenAnswer((_) async => tMessagesList);

      // act
      final result = await repository.getMessages(
        conversationUserId: tRecipientUserId,
        limit: customLimit,
      );

      // assert
      expect(result.isRight(), true);
      verify(() => mockDatasource.getMessages(
            accessToken: tAccessToken,
            conversationUserId: tRecipientUserId,
            conversationId: any(named: 'conversationId'),
            limit: customLimit,
            beforeMessageId: null,
            currentUserId: tCurrentUserId,
          )).called(1);
    });

    test('should return ServerFailure on GrpcError notFound', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockSecureStorage.getUserId())
          .thenAnswer((_) async => tCurrentUserId);
      when(() => mockDatasource.getMessages(
            accessToken: any(named: 'accessToken'),
            conversationUserId: any(named: 'conversationUserId'),
            conversationId: any(named: 'conversationId'),
            limit: any(named: 'limit'),
            beforeMessageId: any(named: 'beforeMessageId'),
            currentUserId: any(named: 'currentUserId'),
          )).thenThrow(GrpcError.notFound('Conversation not found'));

      // act
      final result = await repository.getMessages(
        conversationUserId: tRecipientUserId,
      );

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('markAsRead', () {
    test('should return Right(null) when successful', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockDatasource.markAsRead(
            accessToken: any(named: 'accessToken'),
            messageIds: any(named: 'messageIds'),
          )).thenAnswer((_) async {});

      // act
      final result = await repository.markAsRead(messageId: 'msg-001');

      // assert
      expect(result, const Right(null));
      verify(() => mockDatasource.markAsRead(
            accessToken: tAccessToken,
            messageIds: ['msg-001'],
          )).called(1);
    });

    test('should return AuthFailure when no access token', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.markAsRead(messageId: 'msg-001');

      // assert
      expect(result, const Left(AuthFailure('No access token found')));
    });
  });

  group('deleteMessage', () {
    test('should return Right(null) when successful', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockDatasource.deleteMessage(
            accessToken: any(named: 'accessToken'),
            messageId: any(named: 'messageId'),
            conversationId: any(named: 'conversationId'),
            deleteForEveryone: any(named: 'deleteForEveryone'),
          )).thenAnswer((_) async {});

      // act
      final result = await repository.deleteMessage(messageId: 'msg-001');

      // assert
      expect(result, const Right(null));
      verify(() => mockDatasource.deleteMessage(
            accessToken: tAccessToken,
            messageId: 'msg-001',
            conversationId: 'temp-conversation-id',
            deleteForEveryone: false,
          )).called(1);
    });

    test('should return AuthFailure when no access token', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.deleteMessage(messageId: 'msg-001');

      // assert
      expect(result, const Left(AuthFailure('No access token found')));
    });

    test('should return NetworkFailure on timeout', () async {
      // arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockDatasource.deleteMessage(
            accessToken: any(named: 'accessToken'),
            messageId: any(named: 'messageId'),
            conversationId: any(named: 'conversationId'),
            deleteForEveryone: any(named: 'deleteForEveryone'),
          )).thenThrow(GrpcError.deadlineExceeded('Request timeout'));

      // act
      final result = await repository.deleteMessage(messageId: 'msg-001');

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });
}
