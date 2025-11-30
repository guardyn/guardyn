import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/groups/domain/entities/group.dart';
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

  // Test data
  const tGroupId = 'group-001';
  const tGroupName = 'Test Group';
  const tCreatorUserId = 'user-123';

  final tGroup = Group(
    groupId: tGroupId,
    name: tGroupName,
    creatorUserId: tCreatorUserId,
    members: [
      GroupMember(
        userId: tCreatorUserId,
        username: 'alice',
        deviceId: 'device-123',
        role: GroupRole.admin,
        joinedAt: DateTime(2025, 11, 29),
      ),
    ],
    createdAt: DateTime(2025, 11, 29),
    memberCount: 3,
  );

  final tGroups = [tGroup];

  setUpAll(() {
    registerFallbackValue(FakeGroupEvent());
    registerFallbackValue(FakeGroupState());
  });

  setUp(() {
    mockGroupBloc = MockGroupBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<GroupBloc>.value(
        value: mockGroupBloc,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Groups'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
          body: BlocBuilder<GroupBloc, GroupState>(
            builder: (context, state) {
              if (state is GroupLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GroupError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GroupBloc>().add(const GroupLoadAll());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is GroupListLoaded) {
                if (state.groups.isEmpty) {
                  return const Center(child: Text('No groups yet'));
                }
                return ListView.builder(
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    return ListTile(
                      key: ValueKey(group.groupId),
                      leading: CircleAvatar(
                        child: Text(group.name[0].toUpperCase()),
                      ),
                      title: Text(group.name),
                      subtitle: Text('${group.memberCount} members'),
                    );
                  },
                );
              }

              return const Center(child: Text('No groups yet'));
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.group_add),
          ),
        ),
      ),
    );
  }

  group('GroupListPage', () {
    testWidgets('shows loading indicator when state is GroupLoading',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupLoading());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is GroupError', (tester) async {
      when(() => mockGroupBloc.state)
          .thenReturn(const GroupError('Failed to load groups'));

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Error: Failed to load groups'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when groups list is empty', (tester) async {
      when(() => mockGroupBloc.state)
          .thenReturn(const GroupListLoaded(groups: []));

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('No groups yet'), findsOneWidget);
    });

    testWidgets('displays groups list when state is GroupListLoaded',
        (tester) async {
      when(() => mockGroupBloc.state)
          .thenReturn(GroupListLoaded(groups: tGroups));

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text(tGroupName), findsOneWidget);
      expect(find.text('3 members'), findsOneWidget);
    });

    testWidgets('displays multiple groups correctly', (tester) async {
      final multipleGroups = [
        tGroup,
        Group(
          groupId: 'group-002',
          name: 'Second Group',
          creatorUserId: 'user-456',
          members: [],
          createdAt: DateTime(2025, 11, 29),
          memberCount: 5,
        ),
      ];
      when(() => mockGroupBloc.state)
          .thenReturn(GroupListLoaded(groups: multipleGroups));

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Test Group'), findsOneWidget);
      expect(find.text('Second Group'), findsOneWidget);
      expect(find.text('3 members'), findsOneWidget);
      expect(find.text('5 members'), findsOneWidget);
    });

    testWidgets('shows group avatar with first letter', (tester) async {
      when(() => mockGroupBloc.state)
          .thenReturn(GroupListLoaded(groups: tGroups));

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('T'), findsOneWidget); // First letter of 'Test Group'
    });

    testWidgets('tapping retry button dispatches GroupLoadAll event',
        (tester) async {
      when(() => mockGroupBloc.state)
          .thenReturn(const GroupError('Load failed'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockGroupBloc.add(const GroupLoadAll())).called(1);
    });

    testWidgets('has floating action button for creating groups',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.group_add), findsOneWidget);
    });

    testWidgets('has add button in app bar', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows app bar with Groups title', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Groups'), findsOneWidget);
    });
  });
}
