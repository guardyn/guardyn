import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';

void main() {
  group('User entity', () {
    test('should create User with all fields', () {
      const user = User(
        userId: 'user-123',
        username: 'testuser',
        deviceId: 'device-123',
        avatarMediaId: 'media-123',
        displayName: 'Test User',
        bio: 'Hello, I am a test user!',
      );

      expect(user.userId, 'user-123');
      expect(user.username, 'testuser');
      expect(user.deviceId, 'device-123');
      expect(user.avatarMediaId, 'media-123');
      expect(user.displayName, 'Test User');
      expect(user.bio, 'Hello, I am a test user!');
    });

    test('should create User with minimal fields', () {
      const user = User(
        userId: 'user-123',
        username: 'testuser',
        deviceId: 'device-123',
      );

      expect(user.userId, 'user-123');
      expect(user.username, 'testuser');
      expect(user.deviceId, 'device-123');
      expect(user.avatarMediaId, isNull);
      expect(user.displayName, isNull);
      expect(user.bio, isNull);
      expect(user.createdAt, isNull);
    });

    group('effectiveDisplayName', () {
      test('should return displayName when set', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          displayName: 'Test User',
        );

        expect(user.effectiveDisplayName, 'Test User');
      });

      test('should return username when displayName is null', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
        );

        expect(user.effectiveDisplayName, 'testuser');
      });

      test('should return username when displayName is empty', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          displayName: '',
        );

        expect(user.effectiveDisplayName, 'testuser');
      });
    });

    group('hasAvatar', () {
      test('should return true when avatarMediaId is set', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: 'media-123',
        );

        expect(user.hasAvatar, isTrue);
      });

      test('should return false when avatarMediaId is null', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
        );

        expect(user.hasAvatar, isFalse);
      });

      test('should return false when avatarMediaId is empty', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: '',
        );

        expect(user.hasAvatar, isFalse);
      });
    });

    group('copyWith', () {
      test('should copy with new avatarMediaId', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
        );

        final updated = user.copyWith(avatarMediaId: 'new-media-123');

        expect(updated.avatarMediaId, 'new-media-123');
        expect(updated.userId, user.userId);
        expect(updated.username, user.username);
      });

      test('should copy with new displayName', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
        );

        final updated = user.copyWith(displayName: 'New Name');

        expect(updated.displayName, 'New Name');
      });

      test('should copy with new bio', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
        );

        final updated = user.copyWith(bio: 'New bio text');

        expect(updated.bio, 'New bio text');
      });

      test('should clear avatar when clearAvatar is true', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: 'media-123',
        );

        final updated = user.copyWith(clearAvatar: true);

        expect(updated.avatarMediaId, isNull);
      });

      test('should clear displayName when clearDisplayName is true', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          displayName: 'Test User',
        );

        final updated = user.copyWith(clearDisplayName: true);

        expect(updated.displayName, isNull);
      });

      test('should clear bio when clearBio is true', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          bio: 'Test bio',
        );

        final updated = user.copyWith(clearBio: true);

        expect(updated.bio, isNull);
      });

      test('clearAvatar should take precedence over new value', () {
        const user = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: 'old-media',
        );

        final updated = user.copyWith(
          avatarMediaId: 'new-media',
          clearAvatar: true,
        );

        expect(updated.avatarMediaId, isNull);
      });
    });

    group('equality', () {
      test('two users with same properties should be equal', () {
        const user1 = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: 'media-123',
          displayName: 'Test User',
          bio: 'Bio',
        );

        const user2 = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: 'media-123',
          displayName: 'Test User',
          bio: 'Bio',
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('users with different avatarMediaId should not be equal', () {
        const user1 = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: 'media-123',
        );

        const user2 = User(
          userId: 'user-123',
          username: 'testuser',
          deviceId: 'device-123',
          avatarMediaId: 'media-456',
        );

        expect(user1, isNot(equals(user2)));
      });
    });
  });
}
