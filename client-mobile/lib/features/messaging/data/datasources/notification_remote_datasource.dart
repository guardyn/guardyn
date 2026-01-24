import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/grpc_clients.dart';
import '../../../../generated/notifications.pb.dart' as proto;
import '../../../../generated/notifications.pbgrpc.dart';

/// Mute duration options for conversations
enum MuteDuration {
  unmute,
  oneHour,
  eightHours,
  oneDay,
  sevenDays,
  forever,
}

/// Remote datasource for notification operations via gRPC
@injectable
class NotificationRemoteDatasource {
  final GrpcClients _grpcClients;

  NotificationRemoteDatasource(this._grpcClients);

  NotificationServiceClient get _notificationClient =>
      _grpcClients.notificationClient;

  /// Mute or unmute a conversation
  /// Returns mute status and optional muted_until timestamp
  Future<MuteResult> muteConversation({
    required String accessToken,
    required String conversationId,
    required bool isGroup,
    required MuteDuration duration,
  }) async {
    final request = proto.MuteConversationRequest(
      accessToken: accessToken,
      conversationId: conversationId,
      isGroup: isGroup,
      duration: _mapDuration(duration),
    );

    final response = await _notificationClient.muteConversation(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    final success = response.success;
    return MuteResult(
      muted: success.muted,
      mutedUntil: success.hasMutedUntil()
          ? DateTime.fromMillisecondsSinceEpoch(
              success.mutedUntil.seconds.toInt() * 1000,
            )
          : null,
    );
  }

  proto.MuteDuration _mapDuration(MuteDuration duration) {
    switch (duration) {
      case MuteDuration.unmute:
        return proto.MuteDuration.UNMUTE;
      case MuteDuration.oneHour:
        return proto.MuteDuration.ONE_HOUR;
      case MuteDuration.eightHours:
        return proto.MuteDuration.EIGHT_HOURS;
      case MuteDuration.oneDay:
        return proto.MuteDuration.ONE_DAY;
      case MuteDuration.sevenDays:
        return proto.MuteDuration.SEVEN_DAYS;
      case MuteDuration.forever:
        return proto.MuteDuration.FOREVER;
    }
  }
}

/// Result of mute operation
class MuteResult {
  final bool muted;
  final DateTime? mutedUntil;

  const MuteResult({
    required this.muted,
    this.mutedUntil,
  });
}
