import '../../domain/entities/contact.dart';

/// Contact data model for API responses
class ContactModel {
  final String contactId;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarMediaId;
  final String? nickname;
  final String? notes;
  final DateTime addedAt;

  const ContactModel({
    required this.contactId,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarMediaId,
    this.nickname,
    this.notes,
    required this.addedAt,
  });

  /// Create from protobuf Contact message
  factory ContactModel.fromProto(dynamic protoContact) {
    return ContactModel(
      contactId: protoContact.contactId as String,
      userId: protoContact.userId as String,
      username: protoContact.username as String,
      displayName: protoContact.displayName as String,
      avatarMediaId: (protoContact.avatarMediaId as String).isEmpty
          ? null
          : protoContact.avatarMediaId as String,
      nickname: (protoContact.nickname as String).isEmpty
          ? null
          : protoContact.nickname as String,
      notes: (protoContact.notes as String).isEmpty
          ? null
          : protoContact.notes as String,
      addedAt: protoContact.addedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              protoContact.addedAt.seconds.toInt() * 1000,
            )
          : DateTime.now(),
    );
  }

  /// Convert to domain entity
  Contact toEntity() {
    return Contact(
      contactId: contactId,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarMediaId: avatarMediaId,
      nickname: nickname,
      notes: notes,
      addedAt: addedAt,
    );
  }

  /// Create from JSON (for caching)
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      contactId: json['contactId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarMediaId: json['avatarMediaId'] as String?,
      nickname: json['nickname'] as String?,
      notes: json['notes'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  /// Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'contactId': contactId,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarMediaId': avatarMediaId,
      'nickname': nickname,
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
