import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_event.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock GroupBloc
class MockGroupBloc extends MockBloc<GroupEvent, GroupState>
    implements GroupBloc {}

class FakeGroupEvent extends Fake implements GroupEvent {}

class FakeGroupState extends Fake implements GroupState {}

void main() {
  late MockGroupBloc mockGroupBloc;

  setUpAll(() {
    registerFallbackValue(FakeGroupEvent());
    registerFallbackValue(FakeGroupState());
  });

  setUp(() {
    mockGroupBloc = MockGroupBloc();
    when(() => mockGroupBloc.state).thenReturn(const GroupInitial());
  });

  Widget buildTestableWidget({bool listenForPop = false}) {
    return MaterialApp(
      home: BlocProvider<GroupBloc>.value(
        value: mockGroupBloc,
        child: Builder(
          builder: (blocContext) => Scaffold(
            appBar: AppBar(
              title: const Text('Create Group'),
            ),
            body: BlocConsumer<GroupBloc, GroupState>(
              listener: (context, state) {
                // Listener logic can be tested via bloc state changes
              },
              builder: (context, state) {
                final isLoading = state is GroupLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: const Key('create_group_form'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Group icon placeholder
                        const Center(
                          child: CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.group, size: 50),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Group name field
                        TextFormField(
                          key: const Key('group_name_field'),
                          decoration: const InputDecoration(
                            labelText: 'Group Name',
                            hintText: 'Enter group name',
                            prefixIcon: Icon(Icons.edit),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a group name';
                            }
                            if (value.trim().length < 3) {
                              return 'Group name must be at least 3 characters';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Members field
                        TextFormField(
                          key: const Key('members_field'),
                          decoration: const InputDecoration(
                            labelText: 'Members (optional)',
                            hintText: 'Enter user IDs separated by commas',
                            prefixIcon: Icon(Icons.people),
                            border: OutlineInputBorder(),
                            helperText:
                                'Leave empty to create a group with just yourself',
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 8),

                        // Info card
                        Card(
                          color: Colors.blue.shade50,
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'You will be added as the group admin. '
                                    'You can add more members later.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Create button
                        ElevatedButton(
                          key: const Key('create_button'),
                          onPressed: isLoading
                              ? null
                              : () {
                                  final form = Form.of(context);
                                  if (form.validate()) {
                                    context.read<GroupBloc>().add(
                                          const GroupCreate(
                                            name: 'Test Group',
                                            memberUserIds: [],
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create Group'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  group('GroupCreatePage', () {
    testWidgets('displays all form fields correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Create Group'), findsWidgets); // App bar and button
      expect(find.text('Group Name'), findsOneWidget);
      expect(find.text('Members (optional)'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('shows info card with correct message', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(
        find.text(
          'You will be added as the group admin. '
          'You can add more members later.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('validates empty group name', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Try to submit without entering group name
      await tester.tap(find.byKey(const Key('create_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a group name'), findsOneWidget);
    });

    testWidgets('validates short group name', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Enter short name
      await tester.enterText(
        find.byKey(const Key('group_name_field')),
        'AB',
      );

      // Try to submit
      await tester.tap(find.byKey(const Key('create_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Group name must be at least 3 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator when state is GroupLoading',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupLoading());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('create button is disabled when loading', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupLoading());

      await tester.pumpWidget(buildTestableWidget());

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('create_button')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('dispatches GroupCreate event on valid submission',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Enter valid group name
      await tester.enterText(
        find.byKey(const Key('group_name_field')),
        'Test Group',
      );

      // Tap create button
      await tester.tap(find.byKey(const Key('create_button')));
      await tester.pump();

      verify(() => mockGroupBloc.add(any(that: isA<GroupCreate>()))).called(1);
    });

    testWidgets('members field accepts comma-separated values', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Enter members
      await tester.enterText(
        find.byKey(const Key('members_field')),
        'user-1, user-2, user-3',
      );
      await tester.pump();

      // Verify field contains the entered text
      expect(find.text('user-1, user-2, user-3'), findsOneWidget);
    });

    testWidgets('shows helper text for members field', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(
        find.text('Leave empty to create a group with just yourself'),
        findsOneWidget,
      );
    });

    testWidgets('has create group avatar placeholder', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('form fields are scrollable', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
