import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/groups/presentation/pages/user_profile_page.dart';

void main() {
  group('UserProfilePage', () {
    testWidgets('displays user information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfilePage(
            userId: 'user-123',
            username: 'alice',
            displayName: 'Alice Smith',
            role: 'admin',
          ),
        ),
      );

      // Verify username is displayed
      expect(find.text('@alice'), findsOneWidget);

      // Verify display name is displayed
      expect(find.text('Alice Smith'), findsOneWidget);

      // Verify role badge is displayed
      expect(find.text('Admin'), findsOneWidget);

      // Verify avatar shows first letter
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('uses username when displayName is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfilePage(
            userId: 'user-456',
            username: 'bob',
          ),
        ),
      );

      // Verify username is used as display name
      expect(find.text('bob'), findsOneWidget);
      expect(find.text('@bob'), findsOneWidget);
    });

    testWidgets('shows owner badge for owner role', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfilePage(
            userId: 'user-789',
            username: 'charlie',
            role: 'owner',
          ),
        ),
      );

      expect(find.text('Owner'), findsOneWidget);
    });

    testWidgets('shows member badge for member role', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfilePage(
            userId: 'user-000',
            username: 'dave',
            role: 'member',
          ),
        ),
      );

      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('Send Message returns start_dm action', (tester) async {
      String? returnedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(
                      userId: 'user-123',
                      username: 'alice',
                    ),
                  ),
                );
                returnedAction = result;
              },
              child: const Text('Open Profile'),
            ),
          ),
        ),
      );

      // Open the profile page
      await tester.tap(find.text('Open Profile'));
      await tester.pumpAndSettle();

      // Tap "Send Message"
      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      // Verify the action is returned
      expect(returnedAction, 'start_dm');
    });

    testWidgets('shows action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfilePage(
            userId: 'user-123',
            username: 'alice',
          ),
        ),
      );

      // Verify action buttons are displayed
      expect(find.text('Send Message'), findsOneWidget);
      expect(find.text('Add to Contacts'), findsOneWidget);
      expect(find.text('Block User'), findsOneWidget);
    });

    testWidgets('displays user ID section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfilePage(
            userId: 'user-abc-123',
            username: 'alice',
          ),
        ),
      );

      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('user-abc-123'), findsOneWidget);
    });

    testWidgets('AppBar title is Profile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfilePage(
            userId: 'user-123',
            username: 'alice',
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
