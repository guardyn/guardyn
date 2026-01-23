/// Tests for DeleteConversation use case
///
/// Verifies conversation deletion functionality works correctly.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/delete_conversation.dart';
import 'package:guardyn_client/generated/messaging.pb.dart' as proto;
import 'package:guardyn_client/generated/messaging.pbgrpc.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockGrpcClients extends Mock implements GrpcClients {}

class MockMessagingServiceClient extends Mock
    implements MessagingServiceClient {}

class MockSecureStorage extends Mock implements SecureStorage {}

// Fake classes for registerFallbackValue
class FakeDeleteConversationRequest extends Fake
    implements proto.DeleteConversationRequest {}

void main() {
  late DeleteConversation deleteConversation;
  late MockGrpcClients mockGrpcClients;
  late MockMessagingServiceClient mockMessagingClient;
  late MockSecureStorage mockSecureStorage;

  setUpAll(() {
    registerFallbackValue(FakeDeleteConversationRequest());
    registerFallbackValue(CallOptions());
  });

  setUp(() {
    mockGrpcClients = MockGrpcClients();
    mockMessagingClient = MockMessagingServiceClient();
    mockSecureStorage = MockSecureStorage();

    when(() => mockGrpcClients.messagingClient).thenReturn(mockMessagingClient);

    deleteConversation = DeleteConversation(
      grpcClients: mockGrpcClients,
      secureStorage: mockSecureStorage,
    );
  });

  group('DeleteConversation', () {
    const testConversationId = 'conv-123';
    const testToken = 'valid-jwt-token';

    test('should delete conversation successfully', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => testToken);

      final successResult = proto.DeleteConversationSuccess()
        ..conversationId = testConversationId;
      final response = proto.DeleteConversationResponse()
        ..success = successResult;

      when(
        () => mockMessagingClient.deleteConversation(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) => MockResponseFuture(response));

      // Act
      final result = await deleteConversation(testConversationId);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockSecureStorage.getAccessToken()).called(1);
      verify(
        () => mockMessagingClient.deleteConversation(
          any(),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('should return AuthFailure when token is null', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => null);

      // Act
      final result = await deleteConversation(testConversationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );

      verify(() => mockSecureStorage.getAccessToken()).called(1);
      verifyNever(
        () => mockMessagingClient.deleteConversation(
          any(),
          options: any(named: 'options'),
        ),
      );
    });

    test('should return AuthFailure when token is empty', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => '');

      // Act
      final result = await deleteConversation(testConversationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return ServerFailure when response has error', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => testToken);

      when(
        () => mockMessagingClient.deleteConversation(
          any(),
          options: any(named: 'options'),
        ),
      ).thenThrow(GrpcError.notFound('Conversation not found'));

      // Act
      final result = await deleteConversation(testConversationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(
          (failure as ServerFailure).message,
          contains('Conversation not found'),
        );
      }, (_) => fail('Expected Left but got Right'));
    });

    test('should return ServerFailure on generic exception', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => testToken);

      when(
        () => mockMessagingClient.deleteConversation(
          any(),
          options: any(named: 'options'),
        ),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await deleteConversation(testConversationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).message, contains('Network error'));
      }, (_) => fail('Expected Left but got Right'));
    });

    test('should send correct request parameters', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => testToken);

      final successResult = proto.DeleteConversationSuccess()
        ..conversationId = testConversationId;
      final response = proto.DeleteConversationResponse()
        ..success = successResult;

      proto.DeleteConversationRequest? capturedRequest;
      when(
        () => mockMessagingClient.deleteConversation(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer((invocation) {
        capturedRequest =
            invocation.positionalArguments[0]
                as proto.DeleteConversationRequest;
        return MockResponseFuture(response);
      });

      // Act
      await deleteConversation(testConversationId);

      // Assert
      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.conversationId, testConversationId);
      expect(capturedRequest!.accessToken, testToken);
    });
  });
}

/// Mock ResponseFuture for gRPC calls
class MockResponseFuture<T> extends Mock implements ResponseFuture<T> {
  final T _value;

  MockResponseFuture(this._value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future.value(_value).then(onValue, onError: onError);
  }

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) {
    return Future.value(_value).catchError(onError, test: test);
  }

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) {
    return Future.value(_value).whenComplete(action);
  }

  @override
  Stream<T> asStream() => Stream.value(_value);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) {
    return Future.value(_value).timeout(timeLimit, onTimeout: onTimeout);
  }
}
