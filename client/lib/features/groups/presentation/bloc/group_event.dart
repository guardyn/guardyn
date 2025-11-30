import 'package:equatable/equatable.dart';

import '../../domain/entities/group.dart';

/// Base class for all group events
abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

/// Load all groups for the current user
class GroupLoadAll extends GroupEvent {
  const GroupLoadAll();
}

/// Create a new group
class GroupCreate extends GroupEvent {
  final String name;
  final List<String> memberUserIds;

  const GroupCreate({
    required this.name,
    required this.memberUserIds,
  });

  @override
  List<Object?> get props => [name, memberUserIds];
}

/// Load messages for a specific group
class GroupLoadMessages extends GroupEvent {
  final String groupId;
  final int limit;

  const GroupLoadMessages({
    required this.groupId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [groupId, limit];
}

/// Send a message to a group
class GroupSendMessage extends GroupEvent {
  final String groupId;
  final String textContent;

  const GroupSendMessage({
    required this.groupId,
    required this.textContent,
  });

  @override
  List<Object?> get props => [groupId, textContent];
}

/// Receive a new message in a group (from stream/polling)
class GroupMessageReceived extends GroupEvent {
  final GroupMessage message;

  const GroupMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

/// Add a member to a group
class GroupAddMember extends GroupEvent {
  final String groupId;
  final String memberUserId;
  final String memberDeviceId;

  const GroupAddMember({
    required this.groupId,
    required this.memberUserId,
    required this.memberDeviceId,
  });

  @override
  List<Object?> get props => [groupId, memberUserId, memberDeviceId];
}

/// Remove a member from a group
class GroupRemoveMember extends GroupEvent {
  final String groupId;
  final String memberUserId;

  const GroupRemoveMember({
    required this.groupId,
    required this.memberUserId,
  });

  @override
  List<Object?> get props => [groupId, memberUserId];
}

/// Leave a group
class GroupLeave extends GroupEvent {
  final String groupId;

  const GroupLeave(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Load details of a specific group (for GroupInfoPage)
class GroupLoadDetails extends GroupEvent {
  final String groupId;

  const GroupLoadDetails(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Start polling for new messages in a group
class GroupStartPolling extends GroupEvent {
  final String groupId;
  final Duration interval;

  const GroupStartPolling({
    required this.groupId,
    this.interval = const Duration(seconds: 2),
  });

  @override
  List<Object?> get props => [groupId, interval];
}

/// Stop polling for new messages
class GroupStopPolling extends GroupEvent {
  const GroupStopPolling();
}

/// Set the currently active group (for suppressing notifications)
class GroupSetActive extends GroupEvent {
  final String? groupId;

  const GroupSetActive(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
