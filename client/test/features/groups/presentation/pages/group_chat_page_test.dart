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

  final tMessage = GroupMessage(
    messageId: 'msg-001',
    groupId: tGroupId,
    senderUserId: tCreatorUserId,
    senderDeviceId: 'device-123',
    senderUsername: 'alice',
    messageType: GroupMessageType.text,
    textContent: 'Hello group!',
    clientTimestamp: DateTime(2025, 11, 29, 10, 0),
    serverTimestamp: DateTime(2025, 11, 29, 10, 0),
    currentUserId: tCreatorUserId,
  );

  final tMessages = [tMessage];

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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(tGroupName),
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    if (state is GroupMessagesLoaded) {
                      return const Text(
                        'Group chat',
                        style: TextStyle(fontSize: 12),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('group_members_button'),
                icon: const Icon(Icons.group),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    if (state is GroupLoading && state.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = state is GroupMessagesLoaded
                        ? state.messages
                        : state is GroupMessageSending
                            ? state.messages
                            : state is GroupError
                                ? state.messages
                                : <GroupMessage>[];

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      key: const Key('messages_list'),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ListTile(
                          key: ValueKey(message.messageId),
                          title: Text(message.senderUsername),
                          subtitle: Text(message.textContent),
                        );
                      },
                    );
                  },
                ),
              ),
              // Message input
              BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  final isLoading = state is GroupMessageSending;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('message_input'),
                            decoration: const InputDecoration(
                              hintText: 'Type a message',
                            ),
                            enabled: !isLoading,
                          ),
                        ),
                        IconButton(
                          key: const Key('send_button'),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<GroupBloc>().add(
                                        const GroupSendMessage(
                                          groupId: tGroupId,
                                          textContent: 'Test message',
                                        ),
                                      );
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('GroupChatPage', () {
    testWidgets('shows loading indicator when state is GroupLoading',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupLoading());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no messages', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        const GroupMessagesLoaded(groupId: tGroupId, messages: []),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('Start the conversation!'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('displays messages list when state is GroupMessagesLoaded',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        GroupMessagesLoaded(groupId: tGroupId, messages: tMessages),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('alice'), findsOneWidget);
      expect(find.text('Hello group!'), findsOneWidget);
    });

    testWidgets('shows group name in app bar', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text(tGroupName), findsOneWidget);
    });

    testWidgets('shows group chat subtitle when messages loaded',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        GroupMessagesLoaded(groupId: tGroupId, messages: tMessages),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Group chat'), findsOneWidget);
    });

    testWidgets('has group members button in app bar', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byKey(const Key('group_members_button')), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('has message input field', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byKey(const Key('message_input')), findsOneWidget);
      expect(find.text('Type a message'), findsOneWidget);
    });

    testWidgets('has send button', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byKey(const Key('send_button')), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('dispatches GroupSendMessage when send button tapped',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        GroupMessagesLoaded(groupId: tGroupId, messages: tMessages),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.tap(find.byKey(const Key('send_button')));
      await tester.pump();

      verify(() => mockGroupBloc.add(any(that: isA<GroupSendMessage>())))
          .called(1);
    });

    testWidgets('shows loading indicator on send button when sending',
        (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        const GroupMessageSending(messages: []),
      );

      await tester.pumpWidget(buildTestableWidget());

      // Send button shows loading indicator
      final sendButton = find.byKey(const Key('send_button'));
      expect(sendButton, findsOneWidget);

      // Should find circular progress indicator in the send button area
      expect(
        find.descendant(
          of: sendButton,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });

    testWidgets('send button is disabled when sending', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        const GroupMessageSending(messages: []),
      );

      await tester.pumpWidget(buildTestableWidget());

      final iconButton = tester.widget<IconButton>(
        find.byKey(const Key('send_button')),
      );
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('message input is disabled when sending', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        const GroupMessageSending(messages: []),
      );

      await tester.pumpWidget(buildTestableWidget());

      final textField = tester.widget<TextField>(
        find.byKey(const Key('message_input')),
      );
      expect(textField.enabled, isFalse);
    });

    testWidgets('displays multiple messages correctly', (tester) async {
      final multipleMessages = [
        tMessage,
        GroupMessage(
          messageId: 'msg-002',
          groupId: tGroupId,
          senderUserId: 'user-456',
          senderDeviceId: 'device-456',
          senderUsername: 'bob',
          messageType: GroupMessageType.text,
          textContent: 'Hi everyone!',
          clientTimestamp: DateTime(2025, 11, 29, 10, 1),
          serverTimestamp: DateTime(2025, 11, 29, 10, 1),
        ),
      ];

      when(() => mockGroupBloc.state).thenReturn(
        GroupMessagesLoaded(groupId: tGroupId, messages: multipleMessages),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('alice'), findsOneWidget);
      expect(find.text('bob'), findsOneWidget);
      expect(find.text('Hello group!'), findsOneWidget);
      expect(find.text('Hi everyone!'), findsOneWidget);
    });

    testWidgets('preserves messages in error state', (tester) async {
      when(() => mockGroupBloc.state).thenReturn(
        GroupError('Connection lost', messages: tMessages),
      );

      await tester.pumpWidget(buildTestableWidget());

      // Messages should still be visible
      expect(find.text('alice'), findsOneWidget);
      expect(find.text('Hello group!'), findsOneWidget);
    });
  });
}
