import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../messaging/data/datasources/websocket_datasource.dart';
import '../../domain/entities/group.dart';
import '../../domain/usecases/add_group_member.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/get_group_by_id.dart';
import '../../domain/usecases/get_group_messages.dart';
import '../../domain/usecases/get_groups.dart';
import '../../domain/usecases/leave_group.dart';
import '../../domain/usecases/remove_group_member.dart';
import '../../domain/usecases/send_group_message.dart';
import 'group_event.dart';
import 'group_state.dart';

@injectable
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final CreateGroup createGroup;
  final GetGroups getGroups;
  final GetGroupById getGroupById;
  final SendGroupMessage sendGroupMessage;
  final GetGroupMessages getGroupMessages;
  final AddGroupMember addGroupMember;
  final RemoveGroupMember removeGroupMember;
  final LeaveGroup leaveGroup;

  Timer? _pollingTimer;
  String? _activeGroupId;
  
  /// WebSocket datasource for real-time messaging
  WebSocketDatasource? _webSocketDatasource;
  StreamSubscription<dynamic>? _wsMessageSubscription;
  StreamSubscription<dynamic>? _wsStateSubscription;
  bool _useWebSocket = true;

  GroupBloc({
    required this.createGroup,
    required this.getGroups,
    required this.getGroupById,
    required this.sendGroupMessage,
    required this.getGroupMessages,
    required this.addGroupMember,
    required this.removeGroupMember,
    required this.leaveGroup,
  }) : super(const GroupInitial()) {
    on<GroupLoadAll>(_onLoadAll);
    on<GroupCreate>(_onCreateGroup);
    on<GroupLoadDetails>(_onLoadDetails);
    on<GroupLoadMessages>(_onLoadMessages);
    on<GroupSendMessage>(_onSendMessage);
    on<GroupMessageReceived>(_onMessageReceived);
    on<GroupAddMember>(_onAddMember);
    on<GroupRemoveMember>(_onRemoveMember);
    on<GroupLeave>(_onLeaveGroup);
    on<GroupStartPolling>(_onStartPolling);
    on<GroupStopPolling>(_onStopPolling);
    on<GroupSetActive>(_onSetActive);
    // WebSocket events
    on<GroupConnectWebSocket>(_onConnectWebSocket);
    on<GroupDisconnectWebSocket>(_onDisconnectWebSocket);
    on<GroupSubscribeWebSocket>(_onSubscribeWebSocket);
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

  Future<void> _onLoadDetails(
    GroupLoadDetails event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());

    final result = await getGroupById(GetGroupByIdParams(groupId: event.groupId));

    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (group) => emit(GroupDetailsLoaded(group: group)),
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
    final currentGroups = state is GroupListLoaded
        ? (state as GroupListLoaded).groups
        : <Group>[];

    emit(GroupLoading(groups: currentGroups));

    final result = await leaveGroup(LeaveGroupParams(groupId: event.groupId));

    result.fold(
      (failure) => emit(GroupError(failure.message, groups: currentGroups)),
      (success) {
        if (success) {
          emit(GroupLeft(groupId: event.groupId));
          // Update groups list
          final updatedGroups = currentGroups
              .where((g) => g.groupId != event.groupId)
              .toList();
          emit(GroupListLoaded(groups: updatedGroups));
        }
      },
    );
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

  // ========================================================================
  // WebSocket Handlers
  // ========================================================================

  /// Connect to WebSocket for real-time group messaging
  Future<void> _onConnectWebSocket(
    GroupConnectWebSocket event,
    Emitter<GroupState> emit,
  ) async {
    try {
      _webSocketDatasource ??= getIt<WebSocketDatasource>();

      // Cancel existing subscriptions
      await _wsMessageSubscription?.cancel();
      await _wsStateSubscription?.cancel();

      // Stop any existing polling
      _pollingTimer?.cancel();

      // Connect to WebSocket
      await _webSocketDatasource!.connect(event.accessToken);

      // Mark WebSocket as active
      _useWebSocket = true;

      // Subscribe to incoming messages (group messages come through the same stream)
      _wsMessageSubscription = _webSocketDatasource!.messageStream.listen(
        (message) {
          // Convert to GroupMessage if it's for a group
          // For now, we use polling as the primary source for group messages
          // since WebSocket protocol needs to distinguish between DM and group messages
        },
        onError: (error) {
          // ignore: avoid_print
          print('🔌 Group WebSocket message stream error: $error');
          _handleWebSocketFailure();
        },
      );

      // Subscribe to connection state changes
      _wsStateSubscription = _webSocketDatasource!.stateStream.listen((
        wsState,
      ) {
        // ignore: avoid_print
        print('🔌 Group WebSocket state changed: $wsState');
        if (wsState == WebSocketState.disconnected && _useWebSocket) {
          _handleWebSocketFailure();
        }
      });

      // ignore: avoid_print
      print('🔌 Group WebSocket connected successfully');
    } catch (e) {
      // ignore: avoid_print
      print('🔌 Group WebSocket connection failed: $e');
      _handleWebSocketFailure();
    }
  }

  /// Handle WebSocket connection failure - fallback to polling
  void _handleWebSocketFailure() {
    if (!_useWebSocket) return; // Already in fallback mode

    _useWebSocket = false;
    // ignore: avoid_print
    print('📡 Falling back to polling for group message delivery');

    // Start polling if we have a group active
    if (_activeGroupId != null) {
      add(GroupStartPolling(groupId: _activeGroupId!));
    }
  }

  /// Disconnect from WebSocket
  Future<void> _onDisconnectWebSocket(
    GroupDisconnectWebSocket event,
    Emitter<GroupState> emit,
  ) async {
    await _wsMessageSubscription?.cancel();
    await _wsStateSubscription?.cancel();
    await _webSocketDatasource?.disconnect();
    // ignore: avoid_print
    print('🔌 Group WebSocket disconnected');
  }

  /// Subscribe to a group via WebSocket
  Future<void> _onSubscribeWebSocket(
    GroupSubscribeWebSocket event,
    Emitter<GroupState> emit,
  ) async {
    if (_webSocketDatasource?.isConnected ?? false) {
      try {
        // Subscribe to group conversation
        await _webSocketDatasource!.subscribeToConversation(event.groupId);
        // ignore: avoid_print
        print('🔌 Subscribed to group: ${event.groupId}');
      } catch (e) {
        // ignore: avoid_print
        print('🔌 Failed to subscribe to group: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _wsMessageSubscription?.cancel();
    _wsStateSubscription?.cancel();
    _webSocketDatasource?.disconnect();
    return super.close();
  }
}
