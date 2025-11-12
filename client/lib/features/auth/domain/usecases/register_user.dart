import 'package:guardyn_client/features/auth/domain/entities/user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<User> call({
    required String username,
    required String password,
    required String deviceName,
  }) async {
    // Validation
    if (username.trim().isEmpty) {
      throw AuthException('Username cannot be empty');
    }
    if (password.length < 8) {
      throw AuthException('Password must be at least 8 characters');
    }
    if (deviceName.trim().isEmpty) {
      throw AuthException('Device name cannot be empty');
    }

    return await repository.register(
      username: username.trim(),
      password: password,
      deviceName: deviceName.trim(),
    );
  }
}
