import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/grpc_clients.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../generated/messaging.pb.dart' as proto;

/// Entity representing a blocked user
class BlockedUser {
  final String userId;
  final String username;
  final DateTime blockedAt;

  const BlockedUser({
    required this.userId,
    required this.username,
    required this.blockedAt,
  });

  factory BlockedUser.fromProto(proto.BlockedUser protoUser) {
    final timestamp = protoUser.hasBlockedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            protoUser.blockedAt.seconds.toInt() * 1000 +
                protoUser.blockedAt.nanos ~/ 1000000,
          )
        : DateTime.now();
    return BlockedUser(
      userId: protoUser.userId,
      username: protoUser.username,
      blockedAt: timestamp,
    );
  }
}

/// Use case for blocking a user
class BlockUser {
  final GrpcClients _grpcClients;
  final SecureStorage _secureStorage;

  BlockUser({
    required GrpcClients grpcClients,
    required SecureStorage secureStorage,
  }) : _grpcClients = grpcClients,
       _secureStorage = secureStorage;

  Future<Either<Failure, DateTime>> call(String blockedUserId) async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return Left(AuthFailure('No access token available'));
      }

      final request = proto.BlockUserRequest(
        accessToken: accessToken,
        blockedUserId: blockedUserId,
      );

      final response = await _grpcClients.messagingClient.blockUser(request);

      if (response.hasError()) {
        return Left(ServerFailure(response.error.message));
      }

      final blockedAt = response.success.hasBlockedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              response.success.blockedAt.seconds.toInt() * 1000 +
                  response.success.blockedAt.nanos ~/ 1000000,
            )
          : DateTime.now();

      return Right(blockedAt);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Use case for unblocking a user
class UnblockUser {
  final GrpcClients _grpcClients;
  final SecureStorage _secureStorage;

  UnblockUser({
    required GrpcClients grpcClients,
    required SecureStorage secureStorage,
  }) : _grpcClients = grpcClients,
       _secureStorage = secureStorage;

  Future<Either<Failure, void>> call(String userId) async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return Left(AuthFailure('No access token available'));
      }

      final request = proto.UnblockUserRequest(
        accessToken: accessToken,
        userId: userId,
      );

      final response = await _grpcClients.messagingClient.unblockUser(request);

      if (response.hasError()) {
        return Left(ServerFailure(response.error.message));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Use case for getting blocked users list
class GetBlockedUsers {
  final GrpcClients _grpcClients;
  final SecureStorage _secureStorage;

  GetBlockedUsers({
    required GrpcClients grpcClients,
    required SecureStorage secureStorage,
  }) : _grpcClients = grpcClients,
       _secureStorage = secureStorage;

  Future<Either<Failure, List<BlockedUser>>> call() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return Left(AuthFailure('No access token available'));
      }

      final request = proto.GetBlockedUsersRequest(accessToken: accessToken);

      final response = await _grpcClients.messagingClient.getBlockedUsers(
        request,
      );

      if (response.hasError()) {
        return Left(ServerFailure(response.error.message));
      }

      final blockedUsers = response.success.blockedUsers
          .map((u) => BlockedUser.fromProto(u))
          .toList();

      return Right(blockedUsers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
