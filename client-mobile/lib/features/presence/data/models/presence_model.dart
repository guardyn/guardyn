import '../../../../generated/presence.pb.dart' as proto;
import '../../../../generated/presence.pbenum.dart' as proto_enum;
import '../../domain/entities/presence_info.dart';

/// Data transfer object for PresenceInfo
/// Converts between domain entity and proto
class PresenceModel extends PresenceInfo {
  const PresenceModel({
    required super.userId,
    required super.status,
    super.lastSeen,
    super.isTyping,
    super.typingInConversationId,
    super.customStatusText,
  });

  /// Create PresenceModel from GetStatusSuccess proto
  factory PresenceModel.fromGetStatusSuccess(proto.GetStatusSuccess protoStatus) {
    return PresenceModel(
      userId: protoStatus.userId,
      status: _statusFromProto(protoStatus.status),
      lastSeen: protoStatus.hasLastSeen()
          ? DateTime.fromMillisecondsSinceEpoch(
              protoStatus.lastSeen.seconds.toInt() * 1000,
              isUtc: true,
            ).toLocal()
          : null,
      isTyping: protoStatus.isTyping,
      customStatusText: protoStatus.hasCustomStatusText()
          ? protoStatus.customStatusText
          : null,
    );
  }

  /// Create PresenceModel from PresenceUpdate proto (streaming)
  factory PresenceModel.fromPresenceUpdate(proto.PresenceUpdate protoUpdate) {
    return PresenceModel(
      userId: protoUpdate.userId,
      status: _statusFromProto(protoUpdate.status),
      lastSeen: protoUpdate.hasLastSeen()
          ? DateTime.fromMillisecondsSinceEpoch(
              protoUpdate.lastSeen.seconds.toInt() * 1000,
              isUtc: true,
            ).toLocal()
          : null,
      isTyping: protoUpdate.isTyping,
      typingInConversationId: protoUpdate.hasTypingInConversationWith()
          ? protoUpdate.typingInConversationWith
          : null,
      customStatusText: protoUpdate.hasCustomStatusText()
          ? protoUpdate.customStatusText
          : null,
    );
  }

  /// Convert domain PresenceStatus to proto UserStatus
  static proto_enum.UserStatus statusToProto(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.online:
        return proto_enum.UserStatus.ONLINE;
      case PresenceStatus.offline:
        return proto_enum.UserStatus.OFFLINE;
      case PresenceStatus.away:
        return proto_enum.UserStatus.AWAY;
      case PresenceStatus.doNotDisturb:
        return proto_enum.UserStatus.DO_NOT_DISTURB;
      case PresenceStatus.invisible:
        return proto_enum.UserStatus.INVISIBLE;
    }
  }

  /// Convert proto UserStatus to domain PresenceStatus
  static PresenceStatus _statusFromProto(proto_enum.UserStatus protoStatus) {
    switch (protoStatus) {
      case proto_enum.UserStatus.ONLINE:
        return PresenceStatus.online;
      case proto_enum.UserStatus.OFFLINE:
        return PresenceStatus.offline;
      case proto_enum.UserStatus.AWAY:
        return PresenceStatus.away;
      case proto_enum.UserStatus.DO_NOT_DISTURB:
        return PresenceStatus.doNotDisturb;
      case proto_enum.UserStatus.INVISIBLE:
        return PresenceStatus.invisible;
      default:
        return PresenceStatus.offline;
    }
  }

  /// Convert to domain entity
  PresenceInfo toEntity() {
    return PresenceInfo(
      userId: userId,
      status: status,
      lastSeen: lastSeen,
      isTyping: isTyping,
      typingInConversationId: typingInConversationId,
      customStatusText: customStatusText,
    );
  }
}
