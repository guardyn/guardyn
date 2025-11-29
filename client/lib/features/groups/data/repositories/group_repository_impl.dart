import 'package:dartz/dartz.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/group_model.dart';

/// Implementation of GroupRepository
@LazySingleton(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDatasource _remoteDatasource;
  final SecureStorage _secureStorage;

  // Local cache for groups (in-memory)
  final Map<String, GroupModel> _groupCache = {};

  GroupRepositoryImpl(this._remoteDatasource, this._secureStorage);

  Future<String?> _getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  Future<String?> _getCurrentUserId() async {
    return await _secureStorage.getUserId();
  }

  Future<String?> _getCurrentDeviceId() async {
    return await _secureStorage.getDeviceId();
  }

  @override
  Future<Either<Failure, Group>> createGroup({
    required String name,
    required List<String> memberUserIds,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final currentUserId = await _getCurrentUserId();

      final group = await _remoteDatasource.createGroup(
        accessToken: accessToken,
        name: name,
        memberUserIds: memberUserIds,
      );

      // Update group with creator info
      final updatedGroup = GroupModel(
        groupId: group.groupId,
        name: group.name,
        creatorUserId: currentUserId ?? '',
        members: [
          GroupMemberModel(
            userId: currentUserId ?? '',
            username: '', // Will be fetched from user cache
            deviceId: await _getCurrentDeviceId() ?? '',
            role: GroupRole.admin,
            joinedAt: group.createdAt,
          ),
        ],
        createdAt: group.createdAt,
        memberCount: group.memberCount,
      );

      // Cache the group
      _groupCache[updatedGroup.groupId] = updatedGroup;

      return Right(updatedGroup);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create group'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Group>>> getGroups() async {
    try {
      // For now, return cached groups
      // TODO: Implement GetGroups RPC on backend
      return Right(_groupCache.values.toList());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> getGroupById(String groupId) async {
    try {
      // Try to get from cache first
      final cached = _groupCache[groupId];
      if (cached != null) {
        return Right(cached);
      }

      // TODO: Implement GetGroupById RPC on backend
      return Left(ServerFailure('Group not found: $groupId'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupMessage>> sendGroupMessage({
    required String groupId,
    required String textContent,
    GroupMessageType messageType = GroupMessageType.text,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return const Left(AuthFailure('User ID not found'));
      }

      final currentDeviceId = await _getCurrentDeviceId();
      final username = await _secureStorage.getUsername();

      final message = await _remoteDatasource.sendGroupMessage(
        accessToken: accessToken,
        groupId: groupId,
        textContent: textContent,
        currentUserId: currentUserId,
      );

      // Return message with complete user info
      return Right(GroupMessageModel(
        messageId: message.messageId,
        groupId: message.groupId,
        senderUserId: currentUserId,
        senderDeviceId: currentDeviceId ?? '',
        senderUsername: username ?? currentUserId,
        messageType: message.messageType,
        textContent: textContent,
        clientTimestamp: message.clientTimestamp,
        serverTimestamp: message.serverTimestamp,
        currentUserId: currentUserId,
      ));
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to send group message'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupMessage>>> getGroupMessages({
    required String groupId,
    int limit = 50,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final currentUserId = await _getCurrentUserId();

      final messages = await _remoteDatasource.getGroupMessages(
        accessToken: accessToken,
        groupId: groupId,
        currentUserId: currentUserId,
        limit: limit,
        startTime: startTime,
        endTime: endTime,
      );

      return Right(messages);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get group messages'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addGroupMember({
    required String groupId,
    required String memberUserId,
    required String memberDeviceId,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final result = await _remoteDatasource.addGroupMember(
        accessToken: accessToken,
        groupId: groupId,
        memberUserId: memberUserId,
        memberDeviceId: memberDeviceId,
      );

      // Update local cache if group exists
      final cachedGroup = _groupCache[groupId];
      if (cachedGroup != null && result) {
        final updatedMembers = List<GroupMember>.from(cachedGroup.members)
          ..add(GroupMemberModel(
            userId: memberUserId,
            username: memberUserId, // TODO: Fetch username
            deviceId: memberDeviceId,
            role: GroupRole.member,
            joinedAt: DateTime.now(),
          ));
        _groupCache[groupId] = GroupModel(
          groupId: cachedGroup.groupId,
          name: cachedGroup.name,
          creatorUserId: cachedGroup.creatorUserId,
          members: updatedMembers,
          createdAt: cachedGroup.createdAt,
          updatedAt: DateTime.now(),
          memberCount: updatedMembers.length,
          lastMessage: cachedGroup.lastMessage,
        );
      }

      return Right(result);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to add group member'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeGroupMember({
    required String groupId,
    required String memberUserId,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final result = await _remoteDatasource.removeGroupMember(
        accessToken: accessToken,
        groupId: groupId,
        memberUserId: memberUserId,
      );

      // Update local cache if group exists
      final cachedGroup = _groupCache[groupId];
      if (cachedGroup != null && result) {
        final updatedMembers = cachedGroup.members
            .where((m) => m.userId != memberUserId)
            .toList();
        _groupCache[groupId] = GroupModel(
          groupId: cachedGroup.groupId,
          name: cachedGroup.name,
          creatorUserId: cachedGroup.creatorUserId,
          members: updatedMembers,
          createdAt: cachedGroup.createdAt,
          updatedAt: DateTime.now(),
          memberCount: updatedMembers.length,
          lastMessage: cachedGroup.lastMessage,
        );
      }

      return Right(result);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to remove group member'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> leaveGroup(String groupId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        return const Left(AuthFailure('User ID not found'));
      }

      final result = await removeGroupMember(
        groupId: groupId,
        memberUserId: currentUserId,
      );

      // Remove from cache if successful
      result.fold(
        (failure) => null,
        (success) {
          if (success) {
            _groupCache.remove(groupId);
          }
        },
      );

      return result;
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
