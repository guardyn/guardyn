import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/group.dart';
import '../../domain/usecases/add_group_member.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/get_group_messages.dart';
import '../../domain/usecases/get_groups.dart';
import '../../domain/usecases/remove_group_member.dart';
import '../../domain/usecases/send_group_message.dart';
import 'group_event.dart';
import 'group_state.dart';

@injectable
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final CreateGroup createGroup;
  final GetGroups getGroups;
  final SendGroupMessage sendGroupMessage;
  final GetGroupMessages getGroupMessages;
  final AddGroupMember addGroupMember;
  final RemoveGroupMember removeGroupMember;

  Timer? _pollingTimer;
  String? _activeGroupId;

  GroupBloc({
    required this.createGroup,
    required this.getGroups,
    required this.sendGroupMessage,
    required this.getGroupMessages,
    required this.addGroupMember,
    required this.removeGroupMember,
  }) : super(const GroupInitial()) {
    on<GroupLoadAll>(_onLoadAll);
    on<GroupCreate>(_onCreateGroup);
    on<GroupLoadMessages>(_onLoadMessages);
    on<GroupSendMessage>(_onSendMessage);
    on<GroupMessageReceived>(_onMessageReceived);
    on<GroupAddMember>(_onAddMember);
    on<GroupRemoveMember>(_onRemoveMember);
    on<GroupLeave>(_onLeaveGroup);
    on<GroupStartPolling>(_onStartPolling);
    on<GroupStopPolling>(_onStopPolling);
    on<GroupSetActive>(_onSetActive);
  }

  Future<void> _onLoadAll(
    GroupLoadAll event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());

    final result = await getGroups();

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (groups) => emit(GroupListLoaded(groups: groups)),
    );
  }

  Future<void> _onCreateGroup(
    GroupCreate event,
    Emitter<GroupState> emit,
  ) async {
    final currentGroups = state is GroupListLoaded
        ? (state as GroupListLoaded).groups
        : <Group>[];

    emit(GroupLoading(groups: currentGroups));

    final result = await createGroup(CreateGroupParams(
      name: event.name,
      memberUserIds: event.memberUserIds,
    ));

    result.fold(
      (failure) => emit(GroupError(failure.message, groups: currentGroups)),
      (group) {
        emit(GroupCreated(group: group));
        // Update the list with new group
        final updatedGroups = [group, ...currentGroups];
        emit(GroupListLoaded(groups: updatedGroups));
      },
    );
  }

  Future<void> _onLoadMessages(
    GroupLoadMessages event,
    Emitter<GroupState> emit,
  ) async {
    final currentMessages = state is GroupMessagesLoaded
        ? (state as GroupMessagesLoaded).messages
        : <GroupMessage>[];

    emit(GroupLoading(messages: currentMessages));

    final result = await getGroupMessages(GetGroupMessagesParams(
      groupId: event.groupId,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(GroupError(failure.message, messages: currentMessages)),
      (messages) => emit(GroupMessagesLoaded(
        groupId: event.groupId,
        messages: messages,
        hasMore: messages.length >= event.limit,
      )),
    );
  }

  Future<void> _onSendMessage(
    GroupSendMessage event,
    Emitter<GroupState> emit,
  ) async {
    final currentMessages = state is GroupMessagesLoaded
        ? (state as GroupMessagesLoaded).messages
        : <GroupMessage>[];

    emit(GroupMessageSending(messages: currentMessages));

    final result = await sendGroupMessage(SendGroupMessageParams(
      groupId: event.groupId,
      textContent: event.textContent,
    ));

    result.fold(
      (failure) => emit(GroupError(failure.message, messages: currentMessages)),
      (message) {
        final updatedMessages = [message, ...currentMessages];
        emit(GroupMessageSent(message: message, messages: updatedMessages));
        emit(GroupMessagesLoaded(
          groupId: event.groupId,
          messages: updatedMessages,
        ));
      },
    );
  }

  void _onMessageReceived(
    GroupMessageReceived event,
    Emitter<GroupState> emit,
  ) {
    final currentMessages = state is GroupMessagesLoaded
        ? (state as GroupMessagesLoaded).messages
        : <GroupMessage>[];

    // Check for duplicates
    final exists = currentMessages.any(
      (m) => m.messageId == event.message.messageId,
    );

    if (!exists) {
      final updatedMessages = [event.message, ...currentMessages];
      final currentGroupId = state is GroupMessagesLoaded
          ? (state as GroupMessagesLoaded).groupId
          : event.message.groupId;

      emit(GroupMessagesLoaded(
        groupId: currentGroupId,
        messages: updatedMessages,
      ));
    }
  }

  Future<void> _onAddMember(
    GroupAddMember event,
    Emitter<GroupState> emit,
  ) async {
    final result = await addGroupMember(AddGroupMemberParams(
      groupId: event.groupId,
      memberUserId: event.memberUserId,
      memberDeviceId: event.memberDeviceId,
    ));

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (success) {
        if (success) {
          emit(GroupMemberAdded(
            groupId: event.groupId,
            memberUserId: event.memberUserId,
          ));
        }
      },
    );
  }

  Future<void> _onRemoveMember(
    GroupRemoveMember event,
    Emitter<GroupState> emit,
  ) async {
    final result = await removeGroupMember(RemoveGroupMemberParams(
      groupId: event.groupId,
      memberUserId: event.memberUserId,
    ));

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (success) {
        if (success) {
          emit(GroupMemberRemoved(
            groupId: event.groupId,
            memberUserId: event.memberUserId,
          ));
        }
      },
    );
  }

  Future<void> _onLeaveGroup(
    GroupLeave event,
    Emitter<GroupState> emit,
  ) async {
    // Reuse remove member logic (remove self)
    final currentGroups = state is GroupListLoaded
        ? (state as GroupListLoaded).groups
        : <Group>[];

    // Note: Leave group is handled by repository.leaveGroup()
    // For now, we remove from local cache
    emit(GroupLeft(groupId: event.groupId));

    // Update groups list
    final updatedGroups = currentGroups
        .where((g) => g.groupId != event.groupId)
        .toList();
    emit(GroupListLoaded(groups: updatedGroups));
  }

  void _onStartPolling(
    GroupStartPolling event,
    Emitter<GroupState> emit,
  ) {
    _pollingTimer?.cancel();
    _activeGroupId = event.groupId;

    _pollingTimer = Timer.periodic(event.interval, (_) {
      _pollForNewMessages(event.groupId);
    });

    // Poll immediately
    _pollForNewMessages(event.groupId);
  }

  void _onStopPolling(
    GroupStopPolling event,
    Emitter<GroupState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _activeGroupId = null;
  }

  void _onSetActive(
    GroupSetActive event,
    Emitter<GroupState> emit,
  ) {
    _activeGroupId = event.groupId;
  }

  Future<void> _pollForNewMessages(String groupId) async {
    if (_activeGroupId != groupId) return;

    final result = await getGroupMessages(GetGroupMessagesParams(
      groupId: groupId,
      limit: 20,
    ));

    result.fold(
      (failure) {
        // Silent failure for polling
        // ignore: avoid_print
        print('📡 Group polling error: ${failure.message}');
      },
      (messages) {
        if (messages.isEmpty) return;

        // Get current messages
        final currentMessages = state is GroupMessagesLoaded
            ? (state as GroupMessagesLoaded).messages
            : <GroupMessage>[];

        // Find new messages
        final currentIds = currentMessages.map((m) => m.messageId).toSet();
        final newMessages = messages
            .where((m) => !currentIds.contains(m.messageId))
            .toList();

        if (newMessages.isNotEmpty) {
          // ignore: avoid_print
          print('📡 Found ${newMessages.length} new group messages via polling');
          for (final message in newMessages) {
            add(GroupMessageReceived(message));
          }
        }
      },
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
