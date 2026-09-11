import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/crypto/double_ratchet.dart';
import 'package:guardyn_client/core/crypto/undecryptable_message.dart';
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

class MockDoubleRatchet extends Mock implements DoubleRatchet {}

void main() {
  late MessageRepositoryImpl repository;
  late MockMessageRemoteDatasource mockDatasource;
  late MockKeyExchangeDatasource mockKeyExchangeDatasource;
  late MockSecureStorage mockSecureStorage;
  late MockCryptoService mockCryptoService;

  setUpAll(() {
    // `any(named: 'plaintext')` / `any(named: 'associatedData')` are Uint8List parameters.
    registerFallbackValue(Uint8List(0));
  });

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
  final tCiphertext = Uint8List.fromList(List.generate(64, (i) => i));

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
      // An established E2EE session. This used to stub `getSession` to null and let the
      // plaintext fallback carry the test - which meant the suite asserted that an
      // unencryptable message is sent in the clear.
      final session = MockDoubleRatchet();
      when(() => session.hasSendingChainKey).thenReturn(true);
      when(() => mockCryptoService.getSession(
            remoteUserId: any(named: 'remoteUserId'),
            remoteDeviceId: any(named: 'remoteDeviceId'),
          )).thenAnswer((_) async => session);
      when(() => mockCryptoService.encrypt(
            recipientUserId: any(named: 'recipientUserId'),
            recipientDeviceId: any(named: 'recipientDeviceId'),
            plaintext: any(named: 'plaintext'),
            associatedData: any(named: 'associatedData'),
          )).thenAnswer((_) async => tCiphertext);
      when(() => mockCryptoService.isInitialized).thenReturn(true);
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
            x3dhPrekey: any(named: 'x3dhPrekey'),
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
      verify(() => mockSecureStorage.getAccessToken()).called(1);
      // What goes on the wire is the base64 ciphertext, never the plaintext. The previous
      // version of this test asserted `textContent: tTextContent` - the plaintext - which is
      // the behaviour the fallback produced.
      verify(() => mockDatasource.sendMessage(
            accessToken: tAccessToken,
            recipientUserId: tRecipientUserId,
            recipientDeviceId: tRecipientDeviceId,
            recipientUsername: tRecipientUsername,
            textContent: base64.encode(tCiphertext),
            metadata: any(named: 'metadata'),
            x3dhPrekey: any(named: 'x3dhPrekey'),
          )).called(1);
    });

    group('fails closed', () {
      // I-2: encryption that can be skipped when inconvenient is not always-on encryption.
      // These used to be the "plaintext fallback": the repository returned the unencrypted
      // message, the datasource sent it, and sendMessage still returned Right() - so the UI
      // showed an ordinary sent bubble and nothing anywhere said the message had left the
      // device in the clear.

      void expectNothingSent() {
        verifyNever(() => mockDatasource.sendMessage(
              accessToken: any(named: 'accessToken'),
              recipientUserId: any(named: 'recipientUserId'),
              recipientDeviceId: any(named: 'recipientDeviceId'),
              recipientUsername: any(named: 'recipientUsername'),
              textContent: any(named: 'textContent'),
              metadata: any(named: 'metadata'),
              x3dhPrekey: any(named: 'x3dhPrekey'),
            ));
      }

      test('does not send when the ratchet fails to encrypt', () async {
        setUpSuccessfulAuth();
        when(() => mockCryptoService.encrypt(
              recipientUserId: any(named: 'recipientUserId'),
              recipientDeviceId: any(named: 'recipientDeviceId'),
              plaintext: any(named: 'plaintext'),
              associatedData: any(named: 'associatedData'),
            )).thenThrow(Exception('ratchet unavailable'));

        final result = await repository.sendMessage(
          recipientUserId: tRecipientUserId,
          recipientDeviceId: tRecipientDeviceId,
          recipientUsername: tRecipientUsername,
          textContent: tTextContent,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CryptoFailure>()),
          (_) => fail('a message that cannot be encrypted must not be sent'),
        );
        expectNothingSent();
      });

      test('does not send when no session can be established', () async {
        setUpSuccessfulAuth();
        // No existing session, and X3DH cannot complete.
        when(() => mockCryptoService.getSession(
              remoteUserId: any(named: 'remoteUserId'),
              remoteDeviceId: any(named: 'remoteDeviceId'),
            )).thenAnswer((_) async => null);
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => tAccessToken);
        when(() => mockKeyExchangeDatasource.getKeyBundle(
              accessToken: any(named: 'accessToken'),
              userId: any(named: 'userId'),
              deviceId: any(named: 'deviceId'),
            )).thenThrow(Exception('peer has no key bundle'));

        final result = await repository.sendMessage(
          recipientUserId: tRecipientUserId,
          recipientDeviceId: tRecipientDeviceId,
          recipientUsername: tRecipientUsername,
          textContent: tTextContent,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CryptoFailure>()),
          (_) => fail('a message with no session must not be sent'),
        );
        expectNothingSent();
      });

      test('the plaintext never reaches the datasource', () async {
        setUpSuccessfulAuth();
        when(() => mockCryptoService.encrypt(
              recipientUserId: any(named: 'recipientUserId'),
              recipientDeviceId: any(named: 'recipientDeviceId'),
              plaintext: any(named: 'plaintext'),
              associatedData: any(named: 'associatedData'),
            )).thenThrow(Exception('boom'));

        await repository.sendMessage(
          recipientUserId: tRecipientUserId,
          recipientDeviceId: tRecipientDeviceId,
          recipientUsername: tRecipientUsername,
          textContent: tTextContent,
        );

        // Stated separately from expectNothingSent(): the property that matters is not merely
        // "no call happened", it is "this string did not leave the device".
        verifyNever(() => mockDatasource.sendMessage(
              accessToken: any(named: 'accessToken'),
              recipientUserId: any(named: 'recipientUserId'),
              recipientDeviceId: any(named: 'recipientDeviceId'),
              recipientUsername: any(named: 'recipientUsername'),
              textContent: tTextContent,
              metadata: any(named: 'metadata'),
              x3dhPrekey: any(named: 'x3dhPrekey'),
            ));
      });
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

  group('undecryptable messages', () {
    // The receive path used to return whatever it could not decrypt, so ciphertext - or any
    // other bytes that arrived - was rendered to the user as the message. A payload that could
    // not be authenticated was presented as though it had been.

    void noSession() {
      when(() => mockCryptoService.getSession(
            remoteUserId: any(named: 'remoteUserId'),
            remoteDeviceId: any(named: 'remoteDeviceId'),
          )).thenAnswer((_) async => null);
    }

    test('decryptMessageContent returns the placeholder, not the ciphertext', () async {
      noSession();
      when(() => mockSecureStorage.getUserId())
          .thenAnswer((_) async => tCurrentUserId);
      const ciphertext = 'AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRo=';

      final result = await repository.decryptMessageContent(
        encryptedContent: ciphertext,
        senderUserId: tRecipientUserId,
        senderDeviceId: tRecipientDeviceId,
      );

      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (content) {
          expect(content, undecryptableMessagePlaceholder);
          expect(content, isNot(ciphertext));
        },
      );
    });

    test('content that is not valid base64 is undecryptable, not reinterpreted', () async {
      // This used to fall through to `encryptedContent.codeUnits`, which truncates every unit
      // above 0xFF - the same defect #218 fixed in the AAD - and then attempted decryption on
      // bytes it had invented.
      noSession();
      when(() => mockSecureStorage.getUserId())
          .thenAnswer((_) async => tCurrentUserId);

      final result = await repository.decryptMessageContent(
        encryptedContent: 'привет — not base64 at all',
        senderUserId: tRecipientUserId,
        senderDeviceId: tRecipientDeviceId,
      );

      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (content) => expect(content, undecryptableMessagePlaceholder),
      );
    });

    test('getMessages marks undecryptable messages in metadata', () async {
      noSession();
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

      final result = await repository.getMessages(
        conversationUserId: tRecipientUserId,
      );

      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (messages) {
          for (final message in messages) {
            expect(isUndecryptable(message.metadata), isTrue,
                reason: 'the UI keys off this marker to render the placeholder');
            expect(message.textContent, undecryptableMessagePlaceholder);
          }
        },
      );
    });
  });

  group('getMessages', () {
    void setUpCryptoMocks() {
      // No session, so nothing can be decrypted. Content therefore comes back as the
      // undecryptable placeholder rather than as the stored bytes.
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
