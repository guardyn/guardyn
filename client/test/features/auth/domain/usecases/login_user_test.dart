import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:guardyn_client/features/auth/domain/usecases/login_user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser loginUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUser = LoginUser(mockAuthRepository);
  });

  group('LoginUser', () {
    const testUsername = 'testuser';
    const testPassword = 'password123';

    const testUser = User(
      userId: 'user123',
      username: testUsername,
      deviceId: 'device456',
    );

    test('should call repository.login with provided inputs', () async {
      // Arrange
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await loginUser(
        username: testUsername,
        password: testPassword,
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockAuthRepository.login(
            username: testUsername,
            password: testPassword,
          )).called(1);
    });

    test('should return User when login succeeds', () async {
      // Arrange
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await loginUser(
        username: testUsername,
        password: testPassword,
      );

      // Assert
      expect(result, equals(testUser));
      expect(result.username, equals(testUsername));
      expect(result.userId, equals('user123'));
      expect(result.deviceId, equals('device456'));
    });

    test('should throw AuthException when username is empty', () async {
      // Act & Assert
      expect(
        () => loginUser(
          username: '',
          password: testPassword,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Username cannot be empty',
        )),
      );

      verifyNever(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ));
    });

    test('should throw AuthException when password is empty', () async {
      // Act & Assert
      expect(
        () => loginUser(
          username: testUsername,
          password: '',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Password cannot be empty',
        )),
      );
    });

    test('should propagate AuthException from repository', () async {
      // Arrange
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenThrow(AuthException('Invalid credentials'));

      // Act & Assert
      expect(
        () => loginUser(
          username: testUsername,
          password: testPassword,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Invalid credentials',
        )),
      );
    });

    test('should propagate network exceptions', () async {
      // Arrange
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => loginUser(
          username: testUsername,
          password: testPassword,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle long username', () async {
      // Arrange
      final longUsername = 'a' * 100;
      final userWithLongName = User(
        userId: 'user123',
        username: longUsername,
        deviceId: 'device456',
      );

      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => userWithLongName);

      // Act
      final result = await loginUser(
        username: longUsername,
        password: testPassword,
      );

      // Assert
      expect(result, equals(userWithLongName));
      expect(result.username.length, equals(100));
    });

    test('should handle special characters in password', () async {
      // Arrange
      const specialPassword = 'Pass@123!#\$%^&*()';
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await loginUser(
        username: testUsername,
        password: specialPassword,
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockAuthRepository.login(
            username: testUsername,
            password: specialPassword,
          )).called(1);
    });
  });
}
