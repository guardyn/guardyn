import 'package:guardyn_client/features/auth/domain/entities/user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user login
class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<User> call({
    required String username,
    required String password,
  }) async {
    // Validation
    if (username.trim().isEmpty) {
      throw AuthException('Username cannot be empty');
    }
    if (password.isEmpty) {
      throw AuthException('Password cannot be empty');
    }

    return await repository.login(
      username: username.trim(),
      password: password,
    );
  }
}
