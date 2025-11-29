import 'package:equatable/equatable.dart';

import '../../domain/entities/group.dart';

/// Base class for all group states
abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class GroupInitial extends GroupState {
  const GroupInitial();
}

/// Loading state for any async operation
class GroupLoading extends GroupState {
  final List<Group> groups;
  final List<GroupMessage> messages;

  const GroupLoading({
    this.groups = const [],
    this.messages = const [],
  });

  @override
  List<Object?> get props => [groups, messages];
}

/// Groups list loaded successfully
class GroupListLoaded extends GroupState {
  final List<Group> groups;

  const GroupListLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

/// Group messages loaded successfully
class GroupMessagesLoaded extends GroupState {
  final String groupId;
  final List<GroupMessage> messages;
  final bool hasMore;

  const GroupMessagesLoaded({
    required this.groupId,
    required this.messages,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [groupId, messages, hasMore];
}

/// Group created successfully
class GroupCreated extends GroupState {
  final Group group;

  const GroupCreated({required this.group});

  @override
  List<Object?> get props => [group];
}

/// Message sent successfully
class GroupMessageSent extends GroupState {
  final GroupMessage message;
  final List<GroupMessage> messages;

  const GroupMessageSent({
    required this.message,
    required this.messages,
  });

  @override
  List<Object?> get props => [message, messages];
}

/// Message sending in progress
class GroupMessageSending extends GroupState {
  final List<GroupMessage> messages;

  const GroupMessageSending({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// Member added successfully
class GroupMemberAdded extends GroupState {
  final String groupId;
  final String memberUserId;

  const GroupMemberAdded({
    required this.groupId,
    required this.memberUserId,
  });

  @override
  List<Object?> get props => [groupId, memberUserId];
}

/// Member removed successfully
class GroupMemberRemoved extends GroupState {
  final String groupId;
  final String memberUserId;

  const GroupMemberRemoved({
    required this.groupId,
    required this.memberUserId,
  });

  @override
  List<Object?> get props => [groupId, memberUserId];
}

/// Left group successfully
class GroupLeft extends GroupState {
  final String groupId;

  const GroupLeft({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Error state
class GroupError extends GroupState {
  final String message;
  final List<Group> groups;
  final List<GroupMessage> messages;

  const GroupError(
    this.message, {
    this.groups = const [],
    this.messages = const [],
  });

  @override
  List<Object?> get props => [message, groups, messages];
}
