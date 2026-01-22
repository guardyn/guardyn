import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class User extends Equatable {
  final String userId;
  final String username;
  final String deviceId;
  final DateTime? createdAt;

  /// Avatar media ID (references media in MediaService)
  final String? avatarMediaId;

  /// Optional display name (shown instead of username)
  final String? displayName;

  /// Optional user bio/status
  final String? bio;

  const User({
    required this.userId,
    required this.username,
    required this.deviceId,
    this.createdAt,
    this.avatarMediaId,
    this.displayName,
    this.bio,
  });

  /// Get the name to display (displayName if set, otherwise username)
  String get effectiveDisplayName => displayName?.isNotEmpty == true
      ? displayName!
      : username;

  /// Check if user has an avatar
  bool get hasAvatar => avatarMediaId?.isNotEmpty == true;

  @override
  List<Object?> get props => [
        userId,
        username,
        deviceId,
        createdAt,
        avatarMediaId,
        displayName,
        bio,
      ];

  User copyWith({
    String? userId,
    String? username,
    String? deviceId,
    DateTime? createdAt,
    String? avatarMediaId,
    String? displayName,
    String? bio,
    bool clearAvatar = false,
    bool clearDisplayName = false,
    bool clearBio = false,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      avatarMediaId: clearAvatar ? null : (avatarMediaId ?? this.avatarMediaId),
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      bio: clearBio ? null : (bio ?? this.bio),
    );
  }
}
