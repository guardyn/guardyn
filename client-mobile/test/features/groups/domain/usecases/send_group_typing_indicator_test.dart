import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/groups/domain/repositories/group_repository.dart';
import 'package:guardyn_client/features/groups/domain/usecases/send_group_typing_indicator.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late SendGroupTypingIndicator usecase;
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    usecase = SendGroupTypingIndicator(mockRepository);
  });

  const tGroupId = 'group-123';
  const tIsTyping = true;

  test('should send typing indicator through the repository', () async {
    // Arrange
    when(() => mockRepository.sendTypingIndicator(
          groupId: any(named: 'groupId'),
          isTyping: any(named: 'isTyping'),
        )).thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(SendGroupTypingIndicatorParams(
      groupId: tGroupId,
      isTyping: tIsTyping,
    ));

    // Assert
    expect(result, const Right(true));
    verify(() => mockRepository.sendTypingIndicator(
          groupId: tGroupId,
          isTyping: tIsTyping,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    const failure = ServerFailure('Network error');
    when(() => mockRepository.sendTypingIndicator(
          groupId: any(named: 'groupId'),
          isTyping: any(named: 'isTyping'),
        )).thenAnswer((_) async => const Left(failure));

    // Act
    final result = await usecase(SendGroupTypingIndicatorParams(
      groupId: tGroupId,
      isTyping: tIsTyping,
    ));

    // Assert
    expect(result, const Left(failure));
    verify(() => mockRepository.sendTypingIndicator(
          groupId: tGroupId,
          isTyping: tIsTyping,
        )).called(1);
  });

  test('should send stopped typing indicator', () async {
    // Arrange
    when(() => mockRepository.sendTypingIndicator(
          groupId: any(named: 'groupId'),
          isTyping: any(named: 'isTyping'),
        )).thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(SendGroupTypingIndicatorParams(
      groupId: tGroupId,
      isTyping: false,
    ));

    // Assert
    expect(result, const Right(true));
    verify(() => mockRepository.sendTypingIndicator(
          groupId: tGroupId,
          isTyping: false,
        )).called(1);
  });
}
