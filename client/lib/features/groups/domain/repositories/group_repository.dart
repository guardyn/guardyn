import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';

/// Repository interface for group operations
abstract class GroupRepository {
  /// Create a new group with initial members
  Future<Either<Failure, Group>> createGroup({
    required String name,
    required List<String> memberUserIds,
  });

  /// Get list of groups the current user is a member of
  Future<Either<Failure, List<Group>>> getGroups();

  /// Get group details by ID
  Future<Either<Failure, Group>> getGroupById(String groupId);

  /// Send a message to a group
  Future<Either<Failure, GroupMessage>> sendGroupMessage({
    required String groupId,
    required String textContent,
    GroupMessageType messageType = GroupMessageType.text,
  });

  /// Get group message history
  Future<Either<Failure, List<GroupMessage>>> getGroupMessages({
    required String groupId,
    int limit = 50,
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Add a member to a group
  Future<Either<Failure, bool>> addGroupMember({
    required String groupId,
    required String memberUserId,
    required String memberDeviceId,
  });

  /// Remove a member from a group
  Future<Either<Failure, bool>> removeGroupMember({
    required String groupId,
    required String memberUserId,
  });

  /// Leave a group (current user)
  Future<Either<Failure, bool>> leaveGroup(String groupId);
}
