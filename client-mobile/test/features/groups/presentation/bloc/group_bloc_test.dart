import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/groups/domain/entities/group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/add_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/create_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_group_messages.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_groups.dart';
import 'package:guardyn_client/features/groups/domain/usecases/remove_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/send_group_message.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_event.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_state.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockCreateGroup extends Mock implements CreateGroup {}

class MockGetGroups extends Mock implements GetGroups {}

class MockSendGroupMessage extends Mock implements SendGroupMessage {}

class MockGetGroupMessages extends Mock implements GetGroupMessages {}

class MockAddGroupMember extends Mock implements AddGroupMember {}

class MockRemoveGroupMember extends Mock implements RemoveGroupMember {}

// Fake classes for argument matchers
class FakeCreateGroupParams extends Fake implements CreateGroupParams {}

class FakeSendGroupMessageParams extends Fake implements SendGroupMessageParams {}

class FakeGetGroupMessagesParams extends Fake implements GetGroupMessagesParams {}

class FakeAddGroupMemberParams extends Fake implements AddGroupMemberParams {}

class FakeRemoveGroupMemberParams extends Fake implements RemoveGroupMemberParams {}

void main() {
  late GroupBloc bloc;
  late MockCreateGroup mockCreateGroup;
  late MockGetGroups mockGetGroups;
  late MockSendGroupMessage mockSendGroupMessage;
  late MockGetGroupMessages mockGetGroupMessages;
  late MockAddGroupMember mockAddGroupMember;
  late MockRemoveGroupMember mockRemoveGroupMember;

  // Test data
  const tGroupId = 'group-001';
  const tGroupName = 'Test Group';
  const tCreatorUserId = 'user-123';

  final tGroup = Group(
    groupId: tGroupId,
    name: tGroupName,
    creatorUserId: tCreatorUserId,
    members: [
      GroupMember(
        userId: tCreatorUserId,
        username: 'alice',
        deviceId: 'device-123',
        role: GroupRole.admin,
        joinedAt: DateTime(2025, 11, 29),
      ),
    ],
    createdAt: DateTime(2025, 11, 29),
    memberCount: 1,
  );

  final tMessage = GroupMessage(
    messageId: 'msg-001',
    groupId: tGroupId,
    senderUserId: tCreatorUserId,
    senderDeviceId: 'device-123',
    senderUsername: 'alice',
    messageType: GroupMessageType.text,
    textContent: 'Hello group!',
    clientTimestamp: DateTime(2025, 11, 29, 10, 0),
    serverTimestamp: DateTime(2025, 11, 29, 10, 0),
    currentUserId: tCreatorUserId,
  );

  final tMessages = [tMessage];
  final tGroups = [tGroup];

  setUpAll(() {
    registerFallbackValue(FakeCreateGroupParams());
    registerFallbackValue(FakeSendGroupMessageParams());
    registerFallbackValue(FakeGetGroupMessagesParams());
    registerFallbackValue(FakeAddGroupMemberParams());
    registerFallbackValue(FakeRemoveGroupMemberParams());
  });

  setUp(() {
    mockCreateGroup = MockCreateGroup();
    mockGetGroups = MockGetGroups();
    mockSendGroupMessage = MockSendGroupMessage();
    mockGetGroupMessages = MockGetGroupMessages();
    mockAddGroupMember = MockAddGroupMember();
    mockRemoveGroupMember = MockRemoveGroupMember();

    bloc = GroupBloc(
      createGroup: mockCreateGroup,
      getGroups: mockGetGroups,
      sendGroupMessage: mockSendGroupMessage,
      getGroupMessages: mockGetGroupMessages,
      addGroupMember: mockAddGroupMember,
      removeGroupMember: mockRemoveGroupMember,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be GroupInitial', () {
    expect(bloc.state, isA<GroupInitial>());
  });

  group('GroupLoadAll', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupListLoaded] when GetGroups succeeds',
      build: () {
        when(() => mockGetGroups()).thenAnswer((_) async => Right(tGroups));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupLoadAll()),
      expect: () => [
        const GroupLoading(),
        GroupListLoaded(groups: tGroups),
      ],
      verify: (_) {
        verify(() => mockGetGroups()).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupError] when GetGroups fails',
      build: () {
        when(() => mockGetGroups())
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupLoadAll()),
      expect: () => [
        const GroupLoading(),
        const GroupError('Server error'),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupListLoaded] with empty list when no groups',
      build: () {
        when(() => mockGetGroups()).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupLoadAll()),
      expect: () => [
        const GroupLoading(),
        const GroupListLoaded(groups: []),
      ],
    );
  });

  group('GroupCreate', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupCreated, GroupListLoaded] when CreateGroup succeeds',
      build: () {
        when(() => mockCreateGroup(any())).thenAnswer((_) async => Right(tGroup));
        return bloc;
      },
      act: (bloc) => bloc.add(GroupCreate(
        name: tGroupName,
        memberUserIds: ['user-456'],
      )),
      expect: () => [
        const GroupLoading(),
        GroupCreated(group: tGroup),
        GroupListLoaded(groups: [tGroup]),
      ],
      verify: (_) {
        verify(() => mockCreateGroup(any())).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupError] when CreateGroup fails',
      build: () {
        when(() => mockCreateGroup(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Create failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(GroupCreate(
        name: tGroupName,
        memberUserIds: [],
      )),
      expect: () => [
        const GroupLoading(),
        const GroupError('Create failed'),
      ],
    );
  });

  group('GroupLoadMessages', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupMessagesLoaded] when GetGroupMessages succeeds',
      build: () {
        when(() => mockGetGroupMessages(any()))
            .thenAnswer((_) async => Right(tMessages));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupLoadMessages(groupId: tGroupId)),
      expect: () => [
        const GroupLoading(),
        GroupMessagesLoaded(groupId: tGroupId, messages: tMessages, hasMore: false),
      ],
      verify: (_) {
        verify(() => mockGetGroupMessages(any())).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupError] when GetGroupMessages fails',
      build: () {
        when(() => mockGetGroupMessages(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Load failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupLoadMessages(groupId: tGroupId)),
      expect: () => [
        const GroupLoading(),
        const GroupError('Load failed'),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits hasMore=true when message count equals limit',
      build: () {
        // Create 50 messages to match default limit
        final manyMessages = List.generate(
          50,
          (i) => GroupMessage(
            messageId: 'msg-$i',
            groupId: tGroupId,
            senderUserId: tCreatorUserId,
            senderDeviceId: 'device-123',
            senderUsername: 'alice',
            messageType: GroupMessageType.text,
            textContent: 'Message $i',
            clientTimestamp: DateTime(2025, 11, 29, 10, i),
            serverTimestamp: DateTime(2025, 11, 29, 10, i),
          ),
        );
        when(() => mockGetGroupMessages(any()))
            .thenAnswer((_) async => Right(manyMessages));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupLoadMessages(groupId: tGroupId)),
      expect: () => [
        const GroupLoading(),
        isA<GroupMessagesLoaded>()
            .having((s) => s.hasMore, 'hasMore', true)
            .having((s) => s.messages.length, 'messages count', 50),
      ],
    );
  });

  group('GroupSendMessage', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupMessageSending, GroupMessageSent, GroupMessagesLoaded] when SendGroupMessage succeeds',
      build: () {
        when(() => mockSendGroupMessage(any()))
            .thenAnswer((_) async => Right(tMessage));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupSendMessage(
        groupId: tGroupId,
        textContent: 'Hello group!',
      )),
      expect: () => [
        const GroupMessageSending(messages: []),
        GroupMessageSent(message: tMessage, messages: [tMessage]),
        GroupMessagesLoaded(groupId: tGroupId, messages: [tMessage]),
      ],
      verify: (_) {
        verify(() => mockSendGroupMessage(any())).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupMessageSending, GroupError] when SendGroupMessage fails',
      build: () {
        when(() => mockSendGroupMessage(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Send failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupSendMessage(
        groupId: tGroupId,
        textContent: 'Hello!',
      )),
      expect: () => [
        const GroupMessageSending(messages: []),
        const GroupError('Send failed'),
      ],
    );
  });

  group('GroupAddMember', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupMemberAdded] when AddGroupMember succeeds',
      build: () {
        when(() => mockAddGroupMember(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupAddMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
        memberDeviceId: 'device-456',
      )),
      expect: () => [
        const GroupMemberAdded(groupId: tGroupId, memberUserId: 'user-456'),
      ],
      verify: (_) {
        verify(() => mockAddGroupMember(any())).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupError] when AddGroupMember fails',
      build: () {
        when(() => mockAddGroupMember(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Add failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupAddMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
        memberDeviceId: 'device-456',
      )),
      expect: () => [
        const GroupError('Add failed'),
      ],
    );
  });

  group('GroupRemoveMember', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupMemberRemoved] when RemoveGroupMember succeeds',
      build: () {
        when(() => mockRemoveGroupMember(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupRemoveMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
      )),
      expect: () => [
        const GroupMemberRemoved(groupId: tGroupId, memberUserId: 'user-456'),
      ],
      verify: (_) {
        verify(() => mockRemoveGroupMember(any())).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupError] when RemoveGroupMember fails',
      build: () {
        when(() => mockRemoveGroupMember(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Remove failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GroupRemoveMember(
        groupId: tGroupId,
        memberUserId: 'user-456',
      )),
      expect: () => [
        const GroupError('Remove failed'),
      ],
    );
  });

  group('GroupLeave', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLeft, GroupListLoaded] when leave group succeeds',
      build: () => bloc,
      seed: () => GroupListLoaded(groups: [tGroup]),
      act: (bloc) => bloc.add(const GroupLeave(tGroupId)),
      expect: () => [
        const GroupLeft(groupId: tGroupId),
        const GroupListLoaded(groups: []),
      ],
    );
  });

  group('GroupMessageReceived', () {
    blocTest<GroupBloc, GroupState>(
      'adds message to existing messages when in GroupMessagesLoaded state',
      build: () => bloc,
      seed: () => GroupMessagesLoaded(groupId: tGroupId, messages: tMessages),
      act: (bloc) {
        final newMessage = GroupMessage(
          messageId: 'msg-new',
          groupId: tGroupId,
          senderUserId: 'user-456',
          senderDeviceId: 'device-456',
          senderUsername: 'bob',
          messageType: GroupMessageType.text,
          textContent: 'New message!',
          clientTimestamp: DateTime(2025, 11, 29, 11, 0),
          serverTimestamp: DateTime(2025, 11, 29, 11, 0),
        );
        bloc.add(GroupMessageReceived(newMessage));
      },
      expect: () => [
        isA<GroupMessagesLoaded>().having(
          (s) => s.messages.length,
          'messages count',
          2, // Original message + new message
        ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'does not add duplicate message',
      build: () => bloc,
      seed: () => GroupMessagesLoaded(groupId: tGroupId, messages: tMessages),
      act: (bloc) {
        // Add the same message again
        bloc.add(GroupMessageReceived(tMessage));
      },
      expect: () => [], // No state change expected for duplicate
    );
  });
}
