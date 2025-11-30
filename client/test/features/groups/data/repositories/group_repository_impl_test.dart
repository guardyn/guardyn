import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:guardyn_client/features/groups/data/models/group_model.dart';
import 'package:guardyn_client/features/groups/data/repositories/group_repository_impl.dart';
import 'package:guardyn_client/features/groups/domain/entities/group.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGroupRemoteDatasource extends Mock implements GroupRemoteDatasource {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late GroupRepositoryImpl repository;
  late MockGroupRemoteDatasource mockDatasource;
  late MockSecureStorage mockSecureStorage;

  // Test data
  const tAccessToken = 'test-access-token';
  const tUserId = 'user-123';
  const tDeviceId = 'device-123';
  const tUsername = 'alice';
  const tGroupId = 'group-001';
  const tGroupName = 'Test Group';

  final tGroupModel = GroupModel(
    groupId: tGroupId,
    name: tGroupName,
    creatorUserId: tUserId,
    members: [],
    createdAt: DateTime(2025, 11, 29),
    memberCount: 1,
  );

  final tMessageModel = GroupMessageModel(
    messageId: 'msg-001',
    groupId: tGroupId,
    senderUserId: tUserId,
    senderDeviceId: tDeviceId,
    senderUsername: tUsername,
    messageType: GroupMessageType.text,
    textContent: 'Hello group!',
    clientTimestamp: DateTime(2025, 11, 29, 10, 0),
    serverTimestamp: DateTime(2025, 11, 29, 10, 0),
    currentUserId: tUserId,
  );

  setUp(() {
    mockDatasource = MockGroupRemoteDatasource();
    mockSecureStorage = MockSecureStorage();
    repository = GroupRepositoryImpl(mockDatasource, mockSecureStorage);
  });

  void setUpAuthenticatedUser() {
    when(() => mockSecureStorage.getAccessToken())
        .thenAnswer((_) async => tAccessToken);
    when(() => mockSecureStorage.getUserId()).thenAnswer((_) async => tUserId);
    when(() => mockSecureStorage.getDeviceId())
        .thenAnswer((_) async => tDeviceId);
    when(() => mockSecureStorage.getUsername())
        .thenAnswer((_) async => tUsername);
  }

  void setUpUnauthenticatedUser() {
    when(() => mockSecureStorage.getAccessToken())
        .thenAnswer((_) async => null);
  }

  group('createGroup', () {
    test('returns Group when datasource call is successful', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.createGroup(
            accessToken: tAccessToken,
            name: tGroupName,
            memberUserIds: const [],
          )).thenAnswer((_) async => tGroupModel);

      // Act
      final result = await repository.createGroup(
        name: tGroupName,
        memberUserIds: const [],
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (group) {
          expect(group.groupId, tGroupId);
          expect(group.name, tGroupName);
        },
      );
      verify(() => mockDatasource.createGroup(
            accessToken: tAccessToken,
            name: tGroupName,
            memberUserIds: const [],
          )).called(1);
    });

    test('returns AuthFailure when not authenticated', () async {
      // Arrange
      setUpUnauthenticatedUser();

      // Act
      final result = await repository.createGroup(
        name: tGroupName,
        memberUserIds: const [],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(() => mockDatasource.createGroup(
            accessToken: any(named: 'accessToken'),
            name: any(named: 'name'),
            memberUserIds: any(named: 'memberUserIds'),
          ));
    });

    test('returns ServerFailure when GrpcError occurs', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.createGroup(
            accessToken: tAccessToken,
            name: tGroupName,
            memberUserIds: const [],
          )).thenThrow(GrpcError.unavailable('Server unavailable'));

      // Act
      final result = await repository.createGroup(
        name: tGroupName,
        memberUserIds: const [],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getGroups', () {
    test('returns empty list initially', () async {
      // Act
      final result = await repository.getGroups();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (groups) => expect(groups, isEmpty),
      );
    });

    test('returns cached groups after creating one', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.createGroup(
            accessToken: tAccessToken,
            name: tGroupName,
            memberUserIds: const [],
          )).thenAnswer((_) async => tGroupModel);

      // Create a group first
      await repository.createGroup(name: tGroupName, memberUserIds: const []);

      // Act
      final result = await repository.getGroups();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (groups) {
          expect(groups.length, 1);
          expect(groups.first.groupId, tGroupId);
        },
      );
    });
  });

  group('getGroupById', () {
    test('returns ServerFailure when group not found', () async {
      // Act
      final result = await repository.getGroupById('non-existent');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns cached group when found', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.createGroup(
            accessToken: tAccessToken,
            name: tGroupName,
            memberUserIds: const [],
          )).thenAnswer((_) async => tGroupModel);

      // Create a group first
      await repository.createGroup(name: tGroupName, memberUserIds: const []);

      // Act
      final result = await repository.getGroupById(tGroupId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (group) => expect(group.groupId, tGroupId),
      );
    });
  });

  group('sendGroupMessage', () {
    test('returns GroupMessage when datasource call is successful', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.sendGroupMessage(
            accessToken: tAccessToken,
            groupId: tGroupId,
            textContent: 'Hello group!',
            currentUserId: tUserId,
          )).thenAnswer((_) async => tMessageModel);

      // Act
      final result = await repository.sendGroupMessage(
        groupId: tGroupId,
        textContent: 'Hello group!',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (message) {
          expect(message.textContent, 'Hello group!');
          expect(message.groupId, tGroupId);
        },
      );
    });

    test('returns AuthFailure when not authenticated', () async {
      // Arrange
      setUpUnauthenticatedUser();

      // Act
      final result = await repository.sendGroupMessage(
        groupId: tGroupId,
        textContent: 'Hello!',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns AuthFailure when user ID is null', () async {
      // Arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(() => mockSecureStorage.getUserId()).thenAnswer((_) async => null);

      // Act
      final result = await repository.sendGroupMessage(
        groupId: tGroupId,
        textContent: 'Hello!',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns ServerFailure when GrpcError occurs', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.sendGroupMessage(
            accessToken: tAccessToken,
            groupId: tGroupId,
            textContent: 'Hello!',
            currentUserId: tUserId,
          )).thenThrow(GrpcError.unavailable('Server unavailable'));

      // Act
      final result = await repository.sendGroupMessage(
        groupId: tGroupId,
        textContent: 'Hello!',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getGroupMessages', () {
    test('returns list of messages when datasource call is successful',
        () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.getGroupMessages(
            accessToken: any(named: 'accessToken'),
            groupId: any(named: 'groupId'),
            currentUserId: any(named: 'currentUserId'),
            limit: any(named: 'limit'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => [tMessageModel]);

      // Act
      final result = await repository.getGroupMessages(groupId: tGroupId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (messages) {
          expect(messages.length, 1);
          expect(messages.first.textContent, 'Hello group!');
        },
      );
    });

    test('returns AuthFailure when not authenticated', () async {
      // Arrange
      setUpUnauthenticatedUser();

      // Act
      final result = await repository.getGroupMessages(groupId: tGroupId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns ServerFailure when GrpcError occurs', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.getGroupMessages(
            accessToken: any(named: 'accessToken'),
            groupId: any(named: 'groupId'),
            currentUserId: any(named: 'currentUserId'),
            limit: any(named: 'limit'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenThrow(GrpcError.unavailable('Server unavailable'));

      // Act
      final result = await repository.getGroupMessages(groupId: tGroupId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('addGroupMember', () {
    test('returns true when datasource call is successful', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.addGroupMember(
            accessToken: tAccessToken,
            groupId: tGroupId,
            memberUserId: 'user-456',
            memberDeviceId: 'device-456',
          )).thenAnswer((_) async => true);

      // Act
      final result = await repository.addGroupMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
        memberDeviceId: 'device-456',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (success) => expect(success, true),
      );
    });

    test('returns AuthFailure when not authenticated', () async {
      // Arrange
      setUpUnauthenticatedUser();

      // Act
      final result = await repository.addGroupMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
        memberDeviceId: 'device-456',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('removeGroupMember', () {
    test('returns true when datasource call is successful', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.removeGroupMember(
            accessToken: tAccessToken,
            groupId: tGroupId,
            memberUserId: 'user-456',
          )).thenAnswer((_) async => true);

      // Act
      final result = await repository.removeGroupMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (success) => expect(success, true),
      );
    });

    test('returns AuthFailure when not authenticated', () async {
      // Arrange
      setUpUnauthenticatedUser();

      // Act
      final result = await repository.removeGroupMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('leaveGroup', () {
    test('returns true when successfully left group', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.removeGroupMember(
            accessToken: tAccessToken,
            groupId: tGroupId,
            memberUserId: tUserId,
          )).thenAnswer((_) async => true);

      // Act
      final result = await repository.leaveGroup(tGroupId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (success) => expect(success, true),
      );
    });

    test('returns AuthFailure when user ID is null', () async {
      // Arrange
      when(() => mockSecureStorage.getUserId()).thenAnswer((_) async => null);

      // Act
      final result = await repository.leaveGroup(tGroupId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('removes group from cache after leaving', () async {
      // Arrange
      setUpAuthenticatedUser();
      when(() => mockDatasource.createGroup(
            accessToken: tAccessToken,
            name: tGroupName,
            memberUserIds: const [],
          )).thenAnswer((_) async => tGroupModel);
      when(() => mockDatasource.removeGroupMember(
            accessToken: tAccessToken,
            groupId: tGroupId,
            memberUserId: tUserId,
          )).thenAnswer((_) async => true);

      // Create group first
      await repository.createGroup(name: tGroupName, memberUserIds: const []);

      // Verify group exists
      var groupsResult = await repository.getGroups();
      expect(
        groupsResult.fold((l) => 0, (groups) => groups.length),
        1,
      );

      // Act - leave the group
      await repository.leaveGroup(tGroupId);

      // Assert - group should be removed from cache
      groupsResult = await repository.getGroups();
      expect(
        groupsResult.fold((l) => 0, (groups) => groups.length),
        0,
      );
    });
  });
}
