import 'package:dartz/dartz.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../messaging/domain/usecases/get_user_display_name.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/group_model.dart';

/// Implementation of GroupRepository
@LazySingleton(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDatasource _remoteDatasource;
  final SecureStorage _secureStorage;
  final GetUserDisplayName _getUserDisplayName;

  // Local cache for groups (in-memory)
  final Map<String, GroupModel> _groupCache = {};

  GroupRepositoryImpl(
    this._remoteDatasource,
    this._secureStorage,
    this._getUserDisplayName,
  );

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

      // Resolve creator's username
      final creatorId = currentUserId ?? '';
      final creatorUsernameResult = await _getUserDisplayName(creatorId);
      final creatorUsername = creatorUsernameResult.fold(
        (_) => creatorId,
        (name) => name,
      );

      // Update group with creator info
      final updatedGroup = GroupModel(
        groupId: group.groupId,
        name: group.name,
        creatorUserId: creatorId,
        members: [
          GroupMemberModel(
            userId: creatorId,
            username: creatorUsername,
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
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final groups = await _remoteDatasource.getGroups(
        accessToken: accessToken,
      );

      // Update cache with fetched groups
      for (final group in groups) {
        _groupCache[group.groupId] = group;
      }

      return Right(groups);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch groups'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> getGroupById(String groupId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final group = await _remoteDatasource.getGroupById(
        accessToken: accessToken,
        groupId: groupId,
      );

      // Update cache
      _groupCache[groupId] = group;

      return Right(group);
    } on GrpcError catch (e) {
      // Return cached version if available and server error
      final cached = _groupCache[groupId];
      if (cached != null) {
        return Right(cached);
      }
      return Left(ServerFailure(e.message ?? 'Failed to fetch group'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Refuses to send. This client cannot encrypt a group message.
  ///
  /// There is no MLS implementation on mobile: `GroupRemoteDatasource.sendGroupMessage` put
  /// `utf8.encode(textContent)` straight into the field named `encryptedContent`, and this
  /// repository has no [CryptoService] injected at all - unlike the one-to-one
  /// `MessageRepositoryImpl`, which does.
  ///
  /// While the server encrypted on the client's behalf that was merely dishonest. It is now a
  /// pure relay (`docs/adr/ADR-0010-pure-relay-server.md`) and stores what it is handed
  /// byte-for-byte, so every group message was plaintext at rest - beneath a chat header that
  /// displayed an "MLS" badge claiming the opposite.
  ///
  /// Invariant I-2 is that encryption cannot be turned off, so the only correct behaviour is to
  /// refuse, exactly as the one-to-one path now does (#226). Restoring the send is the job of
  /// whichever step implements MLS; until then this failure is the honest answer, and the
  /// group UI reports `E2EEStatus.notEncrypted` to match.
  @override
  Future<Either<Failure, GroupMessage>> sendGroupMessage({
    required String groupId,
    required String textContent,
    GroupMessageType messageType = GroupMessageType.text,
    Map<String, String>? metadata,
  }) async {
    return const Left(
      CryptoFailure(
        'Group encryption is unavailable: this client has no MLS implementation, '
        'so sending would transmit the message unencrypted.',
      ),
    );
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
        // Resolve username from cache or fetch from server
        final usernameResult = await _getUserDisplayName(memberUserId);
        final username = usernameResult.fold(
          (_) => memberUserId,
          (name) => name,
        );
        
        final updatedMembers = List<GroupMember>.from(cachedGroup.members)
          ..add(GroupMemberModel(
            userId: memberUserId,
            username: username,
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
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final result = await _remoteDatasource.leaveGroup(
        accessToken: accessToken,
        groupId: groupId,
      );

      // Remove from cache if successful
      if (result) {
        _groupCache.remove(groupId);
      }

      return Right(result);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to leave group'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteGroup(String groupId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final result = await _remoteDatasource.deleteGroup(
        accessToken: accessToken,
        groupId: groupId,
      );

      // Remove from cache if successful
      if (result) {
        _groupCache.remove(groupId);
      }

      return Right(result);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete group'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> updateGroup({
    required String groupId,
    String? name,
    String? iconMediaId,
    String? description,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final group = await _remoteDatasource.updateGroup(
        accessToken: accessToken,
        groupId: groupId,
        name: name,
        iconMediaId: iconMediaId,
        description: description,
      );

      // Update cache
      _groupCache[group.groupId] = group;

      return Right(group);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update group'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendTypingIndicator({
    required String groupId,
    required bool isTyping,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final result = await _remoteDatasource.sendTypingIndicator(
        accessToken: accessToken,
        groupId: groupId,
        isTyping: isTyping,
      );

      return Right(result);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to send typing indicator'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changeMemberRole({
    required String groupId,
    required String targetUserId,
    required String newRole,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      await _remoteDatasource.changeMemberRole(
        accessToken: accessToken,
        groupId: groupId,
        targetUserId: targetUserId,
        newRole: newRole,
      );

      return const Right(null);
    } on GrpcError catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to change member role'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
