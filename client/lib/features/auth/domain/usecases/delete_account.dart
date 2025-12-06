import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';

/// Use case for deleting user account
class DeleteAccount {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  Future<void> call({required String password}) async {
    return await repository.deleteAccount(password: password);
  }
}
