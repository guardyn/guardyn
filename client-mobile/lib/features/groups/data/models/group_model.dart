import '../../domain/entities/group.dart';

/// Data model for Group with serialization support
class GroupModel extends Group {
  const GroupModel({
    required super.groupId,
    required super.name,
    required super.creatorUserId,
    required super.members,
    required super.createdAt,
    super.updatedAt,
    required super.memberCount,
    super.lastMessage,
  });

  /// Create from domain entity
  factory GroupModel.fromEntity(Group entity) {
    return GroupModel(
      groupId: entity.groupId,
      name: entity.name,
      creatorUserId: entity.creatorUserId,
      members: entity.members,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      memberCount: entity.memberCount,
      lastMessage: entity.lastMessage,
    );
  }

  /// Create from local JSON storage (for caching)
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json['group_id'] as String,
      name: json['name'] as String,
      creatorUserId: json['creator_user_id'] as String,
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      memberCount: json['member_count'] as int? ?? 0,
      lastMessage: json['last_message'] != null
          ? GroupMessageModel.fromJson(
              json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'name': name,
      'creator_user_id': creatorUserId,
      'members': members
          .map((m) => GroupMemberModel.fromEntity(m).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'member_count': memberCount,
      'last_message': lastMessage != null
          ? GroupMessageModel.fromEntity(lastMessage!).toJson()
          : null,
    };
  }
}

/// Data model for GroupMember
class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.userId,
    required super.username,
    required super.deviceId,
    required super.role,
    required super.joinedAt,
  });

  factory GroupMemberModel.fromEntity(GroupMember entity) {
    return GroupMemberModel(
      userId: entity.userId,
      username: entity.username,
      deviceId: entity.deviceId,
      role: entity.role,
      joinedAt: entity.joinedAt,
    );
  }

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      deviceId: json['device_id'] as String,
      role: GroupRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => GroupRole.member,
      ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'device_id': deviceId,
      'role': role.name,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

/// Data model for GroupMessage with proto serialization
class GroupMessageModel extends GroupMessage {
  const GroupMessageModel({
    required super.messageId,
    required super.groupId,
    required super.senderUserId,
    required super.senderDeviceId,
    required super.senderUsername,
    required super.messageType,
    required super.textContent,
    required super.clientTimestamp,
    required super.serverTimestamp,
    super.isDeleted = false,
    super.currentUserId,
  });

  factory GroupMessageModel.fromEntity(GroupMessage entity) {
    return GroupMessageModel(
      messageId: entity.messageId,
      groupId: entity.groupId,
      senderUserId: entity.senderUserId,
      senderDeviceId: entity.senderDeviceId,
      senderUsername: entity.senderUsername,
      messageType: entity.messageType,
      textContent: entity.textContent,
      clientTimestamp: entity.clientTimestamp,
      serverTimestamp: entity.serverTimestamp,
      isDeleted: entity.isDeleted,
      currentUserId: entity.currentUserId,
    );
  }

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageModel(
      messageId: json['message_id'] as String,
      groupId: json['group_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      senderDeviceId: json['sender_device_id'] as String,
      senderUsername: json['sender_username'] as String? ?? 'Unknown',
      messageType: GroupMessageType.values.firstWhere(
        (t) => t.name == json['message_type'],
        orElse: () => GroupMessageType.text,
      ),
      textContent: json['text_content'] as String,
      clientTimestamp: DateTime.parse(json['client_timestamp'] as String),
      serverTimestamp: DateTime.parse(json['server_timestamp'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
      currentUserId: json['current_user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'group_id': groupId,
      'sender_user_id': senderUserId,
      'sender_device_id': senderDeviceId,
      'sender_username': senderUsername,
      'message_type': messageType.name,
      'text_content': textContent,
      'client_timestamp': clientTimestamp.toIso8601String(),
      'server_timestamp': serverTimestamp.toIso8601String(),
      'is_deleted': isDeleted,
      'current_user_id': currentUserId,
    };
  }
}
