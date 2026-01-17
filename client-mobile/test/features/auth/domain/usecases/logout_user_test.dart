import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/features/auth/domain/usecases/logout_user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUser logoutUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUser = LogoutUser(mockAuthRepository);
  });

  group('LogoutUser', () {
    test('should call repository.logout', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => Future.value());

      // Act
      await logoutUser();

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should complete successfully when repository succeeds', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => Future.value());

      // Act
      await expectLater(
        logoutUser(),
        completes,
      );
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenThrow(Exception('Logout failed'));

      // Act & Assert
      expect(
        () => logoutUser(),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagate AuthException from repository', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenThrow(AuthException('Session expired'));

      // Act & Assert
      expect(
        () => logoutUser(),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Session expired',
        )),
      );
    });

    test('should handle network errors gracefully', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => logoutUser(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should be callable multiple times', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => Future.value());

      // Act
      await logoutUser();
      await logoutUser();
      await logoutUser();

      // Assert
      verify(() => mockAuthRepository.logout()).called(3);
    });
  });
}
