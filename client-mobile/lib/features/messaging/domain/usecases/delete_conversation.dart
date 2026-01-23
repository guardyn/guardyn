import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/grpc_clients.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../generated/messaging.pb.dart' as proto;

/// Use case for deleting a conversation
/// This removes the conversation from the user's list but keeps it for the other party
class DeleteConversation {
  final GrpcClients _grpcClients;
  final SecureStorage _secureStorage;

  DeleteConversation({
    required GrpcClients grpcClients,
    required SecureStorage secureStorage,
  }) : _grpcClients = grpcClients,
       _secureStorage = secureStorage;

  Future<Either<Failure, void>> call(String conversationId) async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return Left(AuthFailure('No access token available'));
      }

      final request = proto.DeleteConversationRequest(
        accessToken: accessToken,
        conversationId: conversationId,
      );

      final response = await _grpcClients.messagingClient.deleteConversation(
        request,
      );

      if (response.hasError()) {
        return Left(ServerFailure(response.error.message));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
