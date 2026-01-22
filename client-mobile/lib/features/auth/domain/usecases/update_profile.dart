import 'package:guardyn_client/features/auth/domain/entities/user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';

/// Use case for updating user profile (avatar, display name, bio)
class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  /// Update user profile
  ///
  /// - [avatarMediaId]: New avatar media ID (null = no change, empty = remove)
  /// - [displayName]: New display name (null = no change, empty = remove)
  /// - [bio]: New bio text (null = no change, empty = remove)
  ///
  /// Returns the updated [User] entity
  Future<User> call({
    String? avatarMediaId,
    String? displayName,
    String? bio,
  }) async {
    // Validate display name if provided
    if (displayName != null && displayName.isNotEmpty) {
      if (displayName.length > 50) {
        throw AuthException('Display name cannot exceed 50 characters');
      }
      // Check for invalid characters
      if (displayName.contains(RegExp(r'[\n\r\t]'))) {
        throw AuthException('Display name contains invalid characters');
      }
    }

    // Validate bio if provided
    if (bio != null && bio.isNotEmpty) {
      if (bio.length > 500) {
        throw AuthException('Bio cannot exceed 500 characters');
      }
    }

    return await repository.updateProfile(
      avatarMediaId: avatarMediaId,
      displayName: displayName,
      bio: bio,
    );
  }
}
