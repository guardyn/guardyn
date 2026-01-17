import 'package:equatable/equatable.dart';

/// Core business entity representing a group chat
class Group extends Equatable {
  final String groupId;
  final String name;
  final String creatorUserId;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int memberCount;
  final GroupMessage? lastMessage;

  const Group({
    required this.groupId,
    required this.name,
    required this.creatorUserId,
    required this.members,
    required this.createdAt,
    this.updatedAt,
    required this.memberCount,
    this.lastMessage,
  });

  /// Check if user is the creator/admin of the group
  bool isAdmin(String userId) => creatorUserId == userId;

  /// Check if user is a member of the group
  bool isMember(String userId) => members.any((m) => m.userId == userId);

  @override
  List<Object?> get props => [
        groupId,
        name,
        creatorUserId,
        members,
        createdAt,
        updatedAt,
        memberCount,
        lastMessage,
      ];
}

/// Group member entity
class GroupMember extends Equatable {
  final String userId;
  final String username;
  final String deviceId;
  final GroupRole role;
  final DateTime joinedAt;

  const GroupMember({
    required this.userId,
    required this.username,
    required this.deviceId,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, username, deviceId, role, joinedAt];
}

/// Group roles
enum GroupRole {
  owner,
  admin,
  member,
}

/// Group message entity
class GroupMessage extends Equatable {
  final String messageId;
  final String groupId;
  final String senderUserId;
  final String senderDeviceId;
  final String senderUsername;
  final GroupMessageType messageType;
  final String textContent;
  final DateTime clientTimestamp;
  final DateTime serverTimestamp;
  final bool isDeleted;
  final String? currentUserId;

  const GroupMessage({
    required this.messageId,
    required this.groupId,
    required this.senderUserId,
    required this.senderDeviceId,
    required this.senderUsername,
    required this.messageType,
    required this.textContent,
    required this.clientTimestamp,
    required this.serverTimestamp,
    this.isDeleted = false,
    this.currentUserId,
  });

  /// Check if this message was sent by the current user
  bool get isSentByMe => currentUserId != null && senderUserId == currentUserId;

  /// Format timestamp for display
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(serverTimestamp);

    if (difference.inDays == 0) {
      return '${serverTimestamp.hour.toString().padLeft(2, '0')}:${serverTimestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[serverTimestamp.weekday - 1];
    } else {
      return '${serverTimestamp.day}/${serverTimestamp.month}/${serverTimestamp.year}';
    }
  }

  @override
  List<Object?> get props => [
        messageId,
        groupId,
        senderUserId,
        senderDeviceId,
        senderUsername,
        messageType,
        textContent,
        clientTimestamp,
        serverTimestamp,
        isDeleted,
        currentUserId,
      ];
}

enum GroupMessageType {
  text,
  image,
  video,
  audio,
  file,
}
