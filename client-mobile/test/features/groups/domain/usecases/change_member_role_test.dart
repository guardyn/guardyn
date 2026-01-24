import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/groups/domain/repositories/group_repository.dart';
import 'package:guardyn_client/features/groups/domain/usecases/change_member_role.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late ChangeMemberRole useCase;
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    useCase = ChangeMemberRole(mockRepository);
  });

  const tGroupId = 'group-123';
  const tTargetUserId = 'user-456';
  const tNewRole = 'Admin';

  group('ChangeMemberRole', () {
    test('should call repository.changeMemberRole with correct parameters', () async {
      // Arrange
      when(() => mockRepository.changeMemberRole(
            groupId: any(named: 'groupId'),
            targetUserId: any(named: 'targetUserId'),
            newRole: any(named: 'newRole'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      await useCase(const ChangeMemberRoleParams(
        groupId: tGroupId,
        targetUserId: tTargetUserId,
        newRole: tNewRole,
      ));

      // Assert
      verify(() => mockRepository.changeMemberRole(
            groupId: tGroupId,
            targetUserId: tTargetUserId,
            newRole: tNewRole,
          )).called(1);
    });

    test('should return Right(null) when role change is successful', () async {
      // Arrange
      when(() => mockRepository.changeMemberRole(
            groupId: any(named: 'groupId'),
            targetUserId: any(named: 'targetUserId'),
            newRole: any(named: 'newRole'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const ChangeMemberRoleParams(
        groupId: tGroupId,
        targetUserId: tTargetUserId,
        newRole: tNewRole,
      ));

      // Assert
      expect(result, const Right<Failure, void>(null));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.changeMemberRole(
            groupId: any(named: 'groupId'),
            targetUserId: any(named: 'targetUserId'),
            newRole: any(named: 'newRole'),
          )).thenAnswer(
              (_) async => const Left(ServerFailure('Permission denied')));

      // Act
      final result = await useCase(const ChangeMemberRoleParams(
        groupId: tGroupId,
        targetUserId: tTargetUserId,
        newRole: tNewRole,
      ));

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure.message, 'Permission denied'),
        (_) => fail('Expected failure'),
      );
    });

    test('should return AuthFailure when not authenticated', () async {
      // Arrange
      when(() => mockRepository.changeMemberRole(
            groupId: any(named: 'groupId'),
            targetUserId: any(named: 'targetUserId'),
            newRole: any(named: 'newRole'),
          )).thenAnswer(
              (_) async => const Left(AuthFailure('Not authenticated')));

      // Act
      final result = await useCase(const ChangeMemberRoleParams(
        groupId: tGroupId,
        targetUserId: tTargetUserId,
        newRole: tNewRole,
      ));

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });

  group('ChangeMemberRoleParams', () {
    test('should create params with correct properties', () {
      const params = ChangeMemberRoleParams(
        groupId: tGroupId,
        targetUserId: tTargetUserId,
        newRole: tNewRole,
      );

      expect(params.groupId, tGroupId);
      expect(params.targetUserId, tTargetUserId);
      expect(params.newRole, tNewRole);
    });
  });
}
