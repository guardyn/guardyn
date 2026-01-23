/// Tests for BlockUser, UnblockUser, and GetBlockedUsers use cases
///
/// Verifies block/unblock user functionality works correctly.
library;

import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/block_user.dart'
    as usecase;
import 'package:guardyn_client/generated/common.pb.dart' as common;
import 'package:guardyn_client/generated/messaging.pb.dart' as proto;
import 'package:guardyn_client/generated/messaging.pbgrpc.dart';
import 'package:mocktail/mocktail.dart';

class MockGrpcClients extends Mock implements GrpcClients {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockMessagingServiceClient extends Mock
    implements MessagingServiceClient {}

void main() {
  late usecase.BlockUser blockUserUseCase;
  late usecase.UnblockUser unblockUserUseCase;
  late usecase.GetBlockedUsers getBlockedUsersUseCase;
  late MockGrpcClients mockGrpcClients;
  late MockSecureStorage mockSecureStorage;
  late MockMessagingServiceClient mockMessagingClient;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(proto.BlockUserRequest());
    registerFallbackValue(proto.UnblockUserRequest());
    registerFallbackValue(proto.GetBlockedUsersRequest());
  });

  setUp(() {
    mockGrpcClients = MockGrpcClients();
    mockSecureStorage = MockSecureStorage();
    mockMessagingClient = MockMessagingServiceClient();

    when(() => mockGrpcClients.messagingClient).thenReturn(mockMessagingClient);

    blockUserUseCase = usecase.BlockUser(
      grpcClients: mockGrpcClients,
      secureStorage: mockSecureStorage,
    );

    unblockUserUseCase = usecase.UnblockUser(
      grpcClients: mockGrpcClients,
      secureStorage: mockSecureStorage,
    );

    getBlockedUsersUseCase = usecase.GetBlockedUsers(
      grpcClients: mockGrpcClients,
      secureStorage: mockSecureStorage,
    );
  });

  const tAccessToken = 'valid-access-token';
  const tBlockedUserId = 'user-to-block-123';

  group('BlockUser', () {
    test(
      'should block user successfully when valid token and userId provided',
      () async {
        // Arrange
        when(
          () => mockSecureStorage.getAccessToken(),
        ).thenAnswer((_) async => tAccessToken);

        final successResponse = proto.BlockUserResponse()
          ..success = (proto.BlockUserSuccess()
            ..blockedUserId = tBlockedUserId
            ..blockedAt = (common.Timestamp()
              ..seconds = Int64(1705000000)
              ..nanos = 0));

        when(
          () => mockMessagingClient.blockUser(any()),
        ).thenAnswer((_) => MockResponseFuture(successResponse));

        // Act
        final result = await blockUserUseCase(tBlockedUserId);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          blockedAt,
        ) {
          expect(blockedAt, isA<DateTime>());
        });
      },
    );

    test('should return AuthFailure when no access token available', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => null);

      // Act
      final result = await blockUserUseCase(tBlockedUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ServerFailure when API returns error', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => tAccessToken);

      final errorResponse = proto.BlockUserResponse()
        ..error = (common.ErrorResponse()
          ..code = common.ErrorResponse_ErrorCode.INTERNAL_ERROR
          ..message = 'Internal server error');

      when(
        () => mockMessagingClient.blockUser(any()),
      ).thenAnswer((_) => MockResponseFuture(errorResponse));

      // Act
      final result = await blockUserUseCase(tBlockedUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('UnblockUser', () {
    test('should unblock user successfully', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => tAccessToken);

      final successResponse = proto.UnblockUserResponse()
        ..success = (proto.UnblockUserSuccess()..userId = tBlockedUserId);

      when(
        () => mockMessagingClient.unblockUser(any()),
      ).thenAnswer((_) => MockResponseFuture(successResponse));

      // Act
      final result = await unblockUserUseCase(tBlockedUserId);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return AuthFailure when no access token available', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => '');

      // Act
      final result = await unblockUserUseCase(tBlockedUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('GetBlockedUsers', () {
    test('should return list of blocked users successfully', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => tAccessToken);

      final blockedUser = proto.BlockedUser()
        ..userId = 'user-1'
        ..username = 'BlockedUser1'
        ..blockedAt = (common.Timestamp()
          ..seconds = Int64(1705000000)
          ..nanos = 0);

      final successResponse = proto.GetBlockedUsersResponse()
        ..success = (proto.GetBlockedUsersSuccess()
          ..blockedUsers.add(blockedUser));

      when(
        () => mockMessagingClient.getBlockedUsers(any()),
      ).thenAnswer((_) => MockResponseFuture(successResponse));

      // Act
      final result = await getBlockedUsersUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        blockedUsers,
      ) {
        expect(blockedUsers.length, 1);
        expect(blockedUsers.first.userId, 'user-1');
        expect(blockedUsers.first.username, 'BlockedUser1');
      });
    });

    test('should return empty list when no users blocked', () async {
      // Arrange
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => tAccessToken);

      final successResponse = proto.GetBlockedUsersResponse()
        ..success = proto.GetBlockedUsersSuccess();

      when(
        () => mockMessagingClient.getBlockedUsers(any()),
      ).thenAnswer((_) => MockResponseFuture(successResponse));

      // Act
      final result = await getBlockedUsersUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (blockedUsers) => expect(blockedUsers, isEmpty),
      );
    });
  });

  group('BlockedUser entity', () {
    test('should create BlockedUser from proto correctly', () {
      // Arrange
      final protoUser = proto.BlockedUser()
        ..userId = 'test-user-id'
        ..username = 'TestUser'
        ..blockedAt = (common.Timestamp()
          ..seconds = Int64(1705000000)
          ..nanos = 500000000);

      // Act
      final blockedUser = usecase.BlockedUser.fromProto(protoUser);

      // Assert
      expect(blockedUser.userId, 'test-user-id');
      expect(blockedUser.username, 'TestUser');
      expect(blockedUser.blockedAt, isA<DateTime>());
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
