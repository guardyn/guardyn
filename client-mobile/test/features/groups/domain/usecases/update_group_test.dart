import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/groups/domain/entities/group.dart';
import 'package:guardyn_client/features/groups/domain/repositories/group_repository.dart';
import 'package:guardyn_client/features/groups/domain/usecases/update_group.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late UpdateGroup useCase;
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    useCase = UpdateGroup(mockRepository);
  });

  group('UpdateGroup', () {
    const testGroupId = 'test-group-id';
    const testName = 'Updated Group Name';
    const testIconMediaId = 'new-icon-media-id';
    const testDescription = 'New description';

    final testGroup = Group(
      groupId: testGroupId,
      name: testName,
      creatorUserId: 'creator-id',
      members: const [],
      createdAt: DateTime.now(),
      memberCount: 3,
    );

    test('should update group name successfully', () async {
      // Arrange
      when(() => mockRepository.updateGroup(
        groupId: any(named: 'groupId'),
        name: any(named: 'name'),
        iconMediaId: any(named: 'iconMediaId'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => Right(testGroup));

      // Act
      final result = await useCase(const UpdateGroupParams(
        groupId: testGroupId,
        name: testName,
      ));

      // Assert
      expect(result, isA<Right<Failure, Group>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (group) => expect(group.name, equals(testName)),
      );

      verify(() => mockRepository.updateGroup(
        groupId: testGroupId,
        name: testName,
        iconMediaId: null,
        description: null,
      )).called(1);
    });

    test('should update group icon successfully', () async {
      // Arrange
      when(() => mockRepository.updateGroup(
        groupId: any(named: 'groupId'),
        name: any(named: 'name'),
        iconMediaId: any(named: 'iconMediaId'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => Right(testGroup));

      // Act
      final result = await useCase(const UpdateGroupParams(
        groupId: testGroupId,
        iconMediaId: testIconMediaId,
      ));

      // Assert
      expect(result, isA<Right<Failure, Group>>());

      verify(() => mockRepository.updateGroup(
        groupId: testGroupId,
        name: null,
        iconMediaId: testIconMediaId,
        description: null,
      )).called(1);
    });

    test('should update group description successfully', () async {
      // Arrange
      when(() => mockRepository.updateGroup(
        groupId: any(named: 'groupId'),
        name: any(named: 'name'),
        iconMediaId: any(named: 'iconMediaId'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => Right(testGroup));

      // Act
      final result = await useCase(const UpdateGroupParams(
        groupId: testGroupId,
        description: testDescription,
      ));

      // Assert
      expect(result, isA<Right<Failure, Group>>());

      verify(() => mockRepository.updateGroup(
        groupId: testGroupId,
        name: null,
        iconMediaId: null,
        description: testDescription,
      )).called(1);
    });

    test('should update multiple fields at once', () async {
      // Arrange
      when(() => mockRepository.updateGroup(
        groupId: any(named: 'groupId'),
        name: any(named: 'name'),
        iconMediaId: any(named: 'iconMediaId'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => Right(testGroup));

      // Act
      final result = await useCase(const UpdateGroupParams(
        groupId: testGroupId,
        name: testName,
        iconMediaId: testIconMediaId,
        description: testDescription,
      ));

      // Assert
      expect(result, isA<Right<Failure, Group>>());

      verify(() => mockRepository.updateGroup(
        groupId: testGroupId,
        name: testName,
        iconMediaId: testIconMediaId,
        description: testDescription,
      )).called(1);
    });

    test('should return failure when update fails', () async {
      // Arrange
      const failure = ServerFailure('Permission denied');
      when(() => mockRepository.updateGroup(
        groupId: any(named: 'groupId'),
        name: any(named: 'name'),
        iconMediaId: any(named: 'iconMediaId'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const UpdateGroupParams(
        groupId: testGroupId,
        name: testName,
      ));

      // Assert
      expect(result, isA<Left<Failure, Group>>());
      result.fold(
        (failure) => expect(failure.message, equals('Permission denied')),
        (group) => fail('Should return failure'),
      );
    });

    test('should return failure when not authenticated', () async {
      // Arrange
      const failure = AuthFailure('Not authenticated');
      when(() => mockRepository.updateGroup(
        groupId: any(named: 'groupId'),
        name: any(named: 'name'),
        iconMediaId: any(named: 'iconMediaId'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const UpdateGroupParams(
        groupId: testGroupId,
        name: testName,
      ));

      // Assert
      expect(result, isA<Left<Failure, Group>>());
      result.fold(
        (failure) => expect(failure.message, equals('Not authenticated')),
        (group) => fail('Should return failure'),
      );
    });
  });
}
