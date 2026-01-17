import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class User extends Equatable {
  final String userId;
  final String username;
  final String deviceId;
  final DateTime? createdAt;

  const User({
    required this.userId,
    required this.username,
    required this.deviceId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [userId, username, deviceId, createdAt];

  User copyWith({
    String? userId,
    String? username,
    String? deviceId,
    DateTime? createdAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
