import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/groups/presentation/widgets/group_message_input.dart';

void main() {
  group('GroupMessageInput', () {
    testWidgets('displays text input field with hint text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
          ),
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Type a message...'), findsOneWidget);
    });

    testWidgets('has send button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('has attachment button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });

    testWidgets('calls onSend when send button pressed with text',
        (tester) async {
      String? sentText;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (text) => sentText = text,
          ),
        ),
      ));

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();

      // Tap send button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(sentText, 'Hello world');
    });

    testWidgets('does not call onSend when text is empty', (tester) async {
      bool wasCalled = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) => wasCalled = true,
          ),
        ),
      ));

      // Tap send without entering text
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(wasCalled, false);
    });

    testWidgets('does not call onSend when text is only whitespace',
        (tester) async {
      bool wasCalled = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) => wasCalled = true,
          ),
        ),
      ));

      // Enter only whitespace
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      // Tap send
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(wasCalled, false);
    });

    testWidgets('clears text field after sending', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
          ),
        ),
      ));

      // Enter text
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      // Verify text is entered
      expect(find.text('Test message'), findsOneWidget);

      // Tap send
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Text should be cleared
      expect(find.text('Test message'), findsNothing);
    });

    testWidgets('does not call onSend when loading', (tester) async {
      bool wasCalled = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) => wasCalled = true,
            isLoading: true,
          ),
        ),
      ));

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Tap send
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(wasCalled, false);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
            isLoading: true,
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show loading indicator when isLoading is false',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
            isLoading: false,
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('allows multi-line input', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
          ),
        ),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, greaterThan(1));
    });

    testWidgets('shows snackbar when attachment button pressed',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (_) {},
          ),
        ),
      ));

      // Tap attachment button
      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pump();

      expect(find.text('Attachments coming soon'), findsOneWidget);
    });

    testWidgets('trims whitespace from sent text', (tester) async {
      String? sentText;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GroupMessageInput(
            onSend: (text) => sentText = text,
          ),
        ),
      ));

      // Enter text with extra whitespace
      await tester.enterText(find.byType(TextField), '  Hello  ');
      await tester.pump();

      // Tap send
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(sentText, 'Hello');
    });
  });
}
