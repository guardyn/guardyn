import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_user_display_name.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:mocktail/mocktail.dart';

class MockGrpcClients extends Mock implements GrpcClients {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockAuthServiceClient extends Mock implements AuthServiceClient {}

class FakeGetUserProfileRequest extends Fake implements GetUserProfileRequest {}

void main() {
  late GetUserDisplayName useCase;
  late MockGrpcClients mockGrpcClients;
  late MockSecureStorage mockSecureStorage;
  late MockAuthServiceClient mockAuthClient;

  setUpAll(() {
    registerFallbackValue(FakeGetUserProfileRequest());
  });

  setUp(() {
    mockGrpcClients = MockGrpcClients();
    mockSecureStorage = MockSecureStorage();
    mockAuthClient = MockAuthServiceClient();

    when(() => mockGrpcClients.authClient).thenReturn(mockAuthClient);

    useCase = GetUserDisplayName(
      grpcClients: mockGrpcClients,
      secureStorage: mockSecureStorage,
    );
  });

  group('GetUserDisplayName', () {
    const testUserId = 'user-123';
    const testDisplayName = 'Test User';

    test('should return cached display name if available', () async {
      // Arrange
      useCase.cacheUsername(testUserId, testDisplayName);

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (displayName) => expect(displayName, testDisplayName),
      );

      // Verify no API calls were made
      verifyNever(() => mockSecureStorage.getAccessToken());
      verifyNever(() => mockAuthClient.getUserProfile(any()));
    });

    test('should return failure when no access token is available', () async {
      // Arrange
      when(() => mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.toString(), contains('No access token')),
        (_) => fail('Should return failure'),
      );
    });

    test('getCached should return null for uncached user', () {
      // Act
      final result = useCase.getCached('unknown-user');

      // Assert
      expect(result, isNull);
    });

    test('cacheUsername should store display name', () {
      // Act
      useCase.cacheUsername(testUserId, testDisplayName);

      // Assert
      expect(useCase.getCached(testUserId), testDisplayName);
    });

    test('clearCache should remove all cached entries', () {
      // Arrange
      useCase.cacheUsername('user-1', 'Name 1');
      useCase.cacheUsername('user-2', 'Name 2');

      // Act
      useCase.clearCache();

      // Assert
      expect(useCase.getCached('user-1'), isNull);
      expect(useCase.getCached('user-2'), isNull);
    });
  });
}
