import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:guardyn_client/features/auth/domain/usecases/register_user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUser registerUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUser = RegisterUser(mockAuthRepository);
  });

  group('RegisterUser', () {
    const testUsername = 'testuser';
    const testPassword = 'password123';
    const testDeviceName = 'Test Device';

    const testUser = User(
      userId: 'user123',
      username: testUsername,
      deviceId: 'device456',
    );

    test('should call repository.register with trimmed inputs', () async {
      // Arrange
      when(() => mockAuthRepository.register(
            username: any(named: 'username'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await registerUser(
        username: '  $testUsername  ',
        password: testPassword,
        deviceName: '  $testDeviceName  ',
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockAuthRepository.register(
            username: testUsername,
            password: testPassword,
            deviceName: testDeviceName,
          )).called(1);
    });

    test('should return User when registration succeeds', () async {
      // Arrange
      when(() => mockAuthRepository.register(
            username: any(named: 'username'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await registerUser(
        username: testUsername,
        password: testPassword,
        deviceName: testDeviceName,
      );

      // Assert
      expect(result, equals(testUser));
      expect(result.username, equals(testUsername));
      expect(result.userId, equals('user123'));
    });

    test('should throw AuthException when username is empty', () async {
      // Act & Assert
      expect(
        () => registerUser(
          username: '',
          password: testPassword,
          deviceName: testDeviceName,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Username cannot be empty',
        )),
      );

      verifyNever(() => mockAuthRepository.register(
            username: any(named: 'username'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          ));
    });

    test('should throw AuthException when username is only whitespace',
        () async {
      // Act & Assert
      expect(
        () => registerUser(
          username: '   ',
          password: testPassword,
          deviceName: testDeviceName,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Username cannot be empty',
        )),
      );
    });

    test('should throw AuthException when password is less than 8 characters',
        () async {
      // Act & Assert
      expect(
        () => registerUser(
          username: testUsername,
          password: '1234567',
          deviceName: testDeviceName,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Password must be at least 8 characters',
        )),
      );
    });

    test('should throw AuthException when password is empty', () async {
      // Act & Assert
      expect(
        () => registerUser(
          username: testUsername,
          password: '',
          deviceName: testDeviceName,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Password must be at least 8 characters',
        )),
      );
    });

    test('should throw AuthException when device name is empty', () async {
      // Act & Assert
      expect(
        () => registerUser(
          username: testUsername,
          password: testPassword,
          deviceName: '',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Device name cannot be empty',
        )),
      );
    });

    test('should throw AuthException when device name is only whitespace',
        () async {
      // Act & Assert
      expect(
        () => registerUser(
          username: testUsername,
          password: testPassword,
          deviceName: '   ',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Device name cannot be empty',
        )),
      );
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      when(() => mockAuthRepository.register(
            username: any(named: 'username'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => registerUser(
          username: testUsername,
          password: testPassword,
          deviceName: testDeviceName,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should accept exactly 8 character password', () async {
      // Arrange
      const validPassword = '12345678';
      when(() => mockAuthRepository.register(
            username: any(named: 'username'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await registerUser(
        username: testUsername,
        password: validPassword,
        deviceName: testDeviceName,
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockAuthRepository.register(
            username: testUsername,
            password: validPassword,
            deviceName: testDeviceName,
          )).called(1);
    });
  });
}
