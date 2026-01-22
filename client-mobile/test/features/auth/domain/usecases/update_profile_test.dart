import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/features/auth/domain/usecases/update_profile.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late UpdateProfile updateProfile;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    updateProfile = UpdateProfile(mockRepository);
  });

  const testUser = User(
    userId: 'user-123',
    username: 'testuser',
    deviceId: 'device-123',
    avatarMediaId: 'media-123',
    displayName: 'Test User',
    bio: 'Test bio',
  );

  group('UpdateProfile', () {
    test('should update profile with new display name', () async {
      // Arrange
      when(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await updateProfile(displayName: 'New Name');

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.updateProfile(
            avatarMediaId: null,
            displayName: 'New Name',
            bio: null,
          )).called(1);
    });

    test('should update profile with new avatar', () async {
      // Arrange
      when(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await updateProfile(avatarMediaId: 'new-avatar-123');

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.updateProfile(
            avatarMediaId: 'new-avatar-123',
            displayName: null,
            bio: null,
          )).called(1);
    });

    test('should update profile with new bio', () async {
      // Arrange
      when(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await updateProfile(bio: 'New bio text');

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.updateProfile(
            avatarMediaId: null,
            displayName: null,
            bio: 'New bio text',
          )).called(1);
    });

    test('should throw exception when display name exceeds 50 characters', () async {
      // Arrange
      final longName = 'A' * 51;

      // Act & Assert
      expect(
        () => updateProfile(displayName: longName),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Display name cannot exceed 50 characters',
        )),
      );
      verifyNever(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          ));
    });

    test('should throw exception when bio exceeds 500 characters', () async {
      // Arrange
      final longBio = 'A' * 501;

      // Act & Assert
      expect(
        () => updateProfile(bio: longBio),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Bio cannot exceed 500 characters',
        )),
      );
      verifyNever(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          ));
    });

    test('should throw exception when display name contains invalid characters', () async {
      // Arrange - display name with newline
      const invalidName = 'Test\nUser';

      // Act & Assert
      expect(
        () => updateProfile(displayName: invalidName),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Display name contains invalid characters',
        )),
      );
    });

    test('should allow empty display name (removes it)', () async {
      // Arrange
      when(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          )).thenAnswer((_) async => testUser);

      // Act - empty string should pass validation and be sent to remove
      final result = await updateProfile(displayName: '');

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.updateProfile(
            avatarMediaId: null,
            displayName: '',
            bio: null,
          )).called(1);
    });

    test('should allow all fields to be updated at once', () async {
      // Arrange
      when(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await updateProfile(
        avatarMediaId: 'new-avatar-456',
        displayName: 'New Name',
        bio: 'New bio',
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.updateProfile(
            avatarMediaId: 'new-avatar-456',
            displayName: 'New Name',
            bio: 'New bio',
          )).called(1);
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      when(() => mockRepository.updateProfile(
            avatarMediaId: any(named: 'avatarMediaId'),
            displayName: any(named: 'displayName'),
            bio: any(named: 'bio'),
          )).thenThrow(AuthException('Network error'));

      // Act & Assert
      expect(
        () => updateProfile(displayName: 'Test'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
