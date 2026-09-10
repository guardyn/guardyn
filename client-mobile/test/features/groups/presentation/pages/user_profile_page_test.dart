import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:guardyn_client/core/error/failures.dart';
import 'package:guardyn_client/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:guardyn_client/features/groups/presentation/pages/user_profile_page.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/block_user.dart';
import 'package:mocktail/mocktail.dart';

class MockContactsBloc extends MockBloc<ContactsEvent, ContactsState>
    implements ContactsBloc {}

class MockBlockUser extends Mock implements BlockUser {}

class MockUnblockUser extends Mock implements UnblockUser {}

class MockGetBlockedUsers extends Mock implements GetBlockedUsers {}

void main() {
  late MockContactsBloc mockContactsBloc;
  late MockBlockUser mockBlockUser;
  late MockUnblockUser mockUnblockUser;
  late MockGetBlockedUsers mockGetBlockedUsers;

  // UserProfilePage resolves all four of these from GetIt in initState, so the
  // page cannot build at all without them. Before this registration every test
  // in the file failed with "GetIt: Object/factory with type ContactsBloc is
  // not registered", and every finder reported 0 widgets as a consequence.
  setUp(() {
    mockContactsBloc = MockContactsBloc();
    mockBlockUser = MockBlockUser();
    mockUnblockUser = MockUnblockUser();
    mockGetBlockedUsers = MockGetBlockedUsers();

    whenListen(
      mockContactsBloc,
      const Stream<ContactsState>.empty(),
      initialState: ContactsInitial(),
    );

    // _checkIsBlocked() awaits this during initState.
    when(() => mockGetBlockedUsers()).thenAnswer(
      (_) async => const Right<Failure, List<BlockedUser>>(<BlockedUser>[]),
    );

    final getIt = GetIt.instance;
    getIt.registerFactory<ContactsBloc>(() => mockContactsBloc);
    getIt.registerFactory<BlockUser>(() => mockBlockUser);
    getIt.registerFactory<UnblockUser>(() => mockUnblockUser);
    getIt.registerFactory<GetBlockedUsers>(() => mockGetBlockedUsers);
  });

  tearDown(() => GetIt.instance.reset());

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
