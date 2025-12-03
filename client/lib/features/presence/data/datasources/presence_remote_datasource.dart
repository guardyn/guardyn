import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/grpc_clients.dart';
import '../../../../generated/presence.pb.dart' as proto;
import '../../../../generated/presence.pbgrpc.dart';
import '../../domain/entities/presence_info.dart';
import '../models/presence_model.dart';

/// Remote datasource for presence operations via gRPC
@injectable
class PresenceRemoteDatasource {
  final GrpcClients _grpcClients;

  PresenceRemoteDatasource(this._grpcClients);

  PresenceServiceClient get _presenceClient => _grpcClients.presenceClient;

  /// Get single user presence
  Future<PresenceModel> getUserPresence({
    required String accessToken,
    required String userId,
  }) async {
    final request = proto.GetStatusRequest(
      accessToken: accessToken,
      userId: userId,
    );

    final response = await _presenceClient.getStatus(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return PresenceModel.fromGetStatusSuccess(response.success);
  }

  /// Update current user's status
  Future<void> updateStatus({
    required String accessToken,
    required PresenceStatus status,
    String? customStatusText,
  }) async {
    final request = proto.UpdateStatusRequest(
      accessToken: accessToken,
      status: PresenceModel.statusToProto(status),
    );

    if (customStatusText != null) {
      request.customStatusText = customStatusText;
    }

    final response = await _presenceClient.updateStatus(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }
  }

  /// Send heartbeat to update last seen
  Future<void> updateLastSeen({
    required String accessToken,
  }) async {
    final request = proto.UpdateLastSeenRequest(
      accessToken: accessToken,
    );

    final response = await _presenceClient.updateLastSeen(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }
  }

  /// Send typing indicator
  Future<void> setTyping({
    required String accessToken,
    required String conversationUserId,
    required bool isTyping,
  }) async {
    final request = proto.SetTypingRequest(
      accessToken: accessToken,
      conversationUserId: conversationUserId,
      isTyping: isTyping,
    );

    final response = await _presenceClient.setTyping(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }
  }

  /// Subscribe to presence updates (streaming)
  Stream<PresenceModel> subscribe({
    required String accessToken,
    required List<String> userIds,
  }) {
    final request = proto.SubscribeRequest(
      accessToken: accessToken,
      userIds: userIds,
    );

    return _presenceClient.subscribe(request).map(
          (update) => PresenceModel.fromPresenceUpdate(update),
        );
  }
}
