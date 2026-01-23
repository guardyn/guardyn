import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/groups/presentation/widgets/group_typing_indicator.dart';

void main() {
  group('GroupTypingIndicator', () {
    testWidgets('should not render anything when typingUsernames is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTypingIndicator(typingUsernames: []),
          ),
        ),
      );

      // Should render SizedBox.shrink()
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('is typing...'), findsNothing);
    });

    testWidgets('should show single user typing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTypingIndicator(typingUsernames: ['Alice']),
          ),
        ),
      );

      expect(find.text('Alice is typing...'), findsOneWidget);
    });

    testWidgets('should show two users typing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTypingIndicator(typingUsernames: ['Alice', 'Bob']),
          ),
        ),
      );

      expect(find.text('Alice and Bob are typing...'), findsOneWidget);
    });

    testWidgets('should show "X and N others" for more than 2 users',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTypingIndicator(
              typingUsernames: ['Alice', 'Bob', 'Charlie'],
            ),
          ),
        ),
      );

      expect(find.text('Alice and 2 others are typing...'), findsOneWidget);
    });

    testWidgets('should show animated dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTypingIndicator(typingUsernames: ['Alice']),
          ),
        ),
      );

      // There should be 3 animated dots
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should update when typingUsernames changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTypingIndicator(typingUsernames: ['Alice']),
          ),
        ),
      );

      expect(find.text('Alice is typing...'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTypingIndicator(typingUsernames: ['Bob']),
          ),
        ),
      );

      expect(find.text('Bob is typing...'), findsOneWidget);
      expect(find.text('Alice is typing...'), findsNothing);
    });
  });
}
