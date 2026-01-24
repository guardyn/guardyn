/// Contact entity representing a user's contact
class Contact {
  final String contactId;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarMediaId;
  final String? nickname;
  final String? notes;
  final DateTime addedAt;

  const Contact({
    required this.contactId,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarMediaId,
    this.nickname,
    this.notes,
    required this.addedAt,
  });

  /// Get the display text for the contact (nickname if set, otherwise displayName or username)
  String get displayText {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    if (displayName.isNotEmpty) {
      return displayName;
    }
    return username;
  }

  /// Get initials for avatar placeholder
  String get initials {
    final text = displayText;
    if (text.isEmpty) return '?';
    final parts = text.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return text[0].toUpperCase();
  }

  Contact copyWith({
    String? contactId,
    String? userId,
    String? username,
    String? displayName,
    String? avatarMediaId,
    String? nickname,
    String? notes,
    DateTime? addedAt,
  }) {
    return Contact(
      contactId: contactId ?? this.contactId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarMediaId: avatarMediaId ?? this.avatarMediaId,
      nickname: nickname ?? this.nickname,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.contactId == contactId;
  }

  @override
  int get hashCode => contactId.hashCode;
}
