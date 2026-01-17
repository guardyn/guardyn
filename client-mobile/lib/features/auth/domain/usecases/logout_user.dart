import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUser {
  final AuthRepository repository;

  LogoutUser(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
