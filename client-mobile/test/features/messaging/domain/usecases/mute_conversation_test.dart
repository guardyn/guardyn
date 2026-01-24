/// Tests for MuteConversation use case
///
/// Verifies mute/unmute conversation functionality works correctly.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/messaging/data/datasources/notification_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/mute_conversation.dart';
import 'package:mocktail/mocktail.dart';

class MockMuteConversationRepository extends Mock
    implements MuteConversationRepository {}

void main() {
  late MuteConversation useCase;
  late MockMuteConversationRepository mockRepository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(MuteDuration.forever);
  });

  setUp(() {
    mockRepository = MockMuteConversationRepository();
    useCase = MuteConversation(mockRepository);
  });

  const tConversationId = 'conv-123';

  group('MuteConversation', () {
    test('should mute conversation successfully when called with FOREVER duration',
        () async {
      // Arrange
      final expectedResult = MuteConversationResult(
        muted: true,
        mutedUntil: null, // Forever means no end time
      );

      when(() => mockRepository.muteConversation(
            conversationId: any(named: 'conversationId'),
            isGroup: any(named: 'isGroup'),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase(const MuteConversationParams(
        conversationId: tConversationId,
        isGroup: false,
        duration: MuteDuration.forever,
      ));

      // Assert
      expect(result, Right(expectedResult));
      verify(() => mockRepository.muteConversation(
            conversationId: tConversationId,
            isGroup: false,
            duration: MuteDuration.forever,
          )).called(1);
    });

    test('should unmute conversation successfully when called with UNMUTE duration',
        () async {
      // Arrange
      const expectedResult = MuteConversationResult(
        muted: false,
        mutedUntil: null,
      );

      when(() => mockRepository.muteConversation(
            conversationId: any(named: 'conversationId'),
            isGroup: any(named: 'isGroup'),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async => const Right(expectedResult));

      // Act
      final result = await useCase(const MuteConversationParams(
        conversationId: tConversationId,
        isGroup: false,
        duration: MuteDuration.unmute,
      ));

      // Assert
      expect(result, const Right(expectedResult));
      verify(() => mockRepository.muteConversation(
            conversationId: tConversationId,
            isGroup: false,
            duration: MuteDuration.unmute,
          )).called(1);
    });

    test('should return failure when repository returns failure', () async {
      // Arrange
      const failure = ServerFailure('Connection failed');

      when(() => mockRepository.muteConversation(
            conversationId: any(named: 'conversationId'),
            isGroup: any(named: 'isGroup'),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const MuteConversationParams(
        conversationId: tConversationId,
        isGroup: false,
        duration: MuteDuration.forever,
      ));

      // Assert
      expect(result, const Left(failure));
    });

    test('should mute conversation for specific duration with mutedUntil timestamp',
        () async {
      // Arrange
      final mutedUntil = DateTime.now().add(const Duration(hours: 1));
      final expectedResult = MuteConversationResult(
        muted: true,
        mutedUntil: mutedUntil,
      );

      when(() => mockRepository.muteConversation(
            conversationId: any(named: 'conversationId'),
            isGroup: any(named: 'isGroup'),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase(const MuteConversationParams(
        conversationId: tConversationId,
        isGroup: false,
        duration: MuteDuration.oneHour,
      ));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) {
          expect(r.muted, true);
          expect(r.mutedUntil, mutedUntil);
        },
      );
    });

    test('MuteConversationParams should have correct props', () {
      // Arrange
      const params1 = MuteConversationParams(
        conversationId: 'conv-1',
        isGroup: false,
        duration: MuteDuration.forever,
      );
      const params2 = MuteConversationParams(
        conversationId: 'conv-1',
        isGroup: false,
        duration: MuteDuration.forever,
      );
      const params3 = MuteConversationParams(
        conversationId: 'conv-2',
        isGroup: false,
        duration: MuteDuration.forever,
      );

      // Assert
      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('MuteConversationResult should have correct props', () {
      // Arrange
      final now = DateTime.now();
      final result1 = MuteConversationResult(muted: true, mutedUntil: now);
      final result2 = MuteConversationResult(muted: true, mutedUntil: now);
      const result3 = MuteConversationResult(muted: false, mutedUntil: null);

      // Assert
      expect(result1, equals(result2));
      expect(result1, isNot(equals(result3)));
    });
  });
}
