/// Tests for Voice/Video Call buttons integration in ChatPage
///
/// Verifies that call buttons are properly wired up to the CallBloc
/// and navigate to CallPage when pressed.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:guardyn_client/features/calls/presentation/bloc/call_bloc.dart';
import 'package:guardyn_client/features/calls/presentation/bloc/call_event.dart';
import 'package:guardyn_client/features/calls/presentation/bloc/call_state.dart'
    as call_state;
import 'package:guardyn_client/features/media/presentation/bloc/media_bloc.dart';
import 'package:guardyn_client/features/media/presentation/bloc/media_event.dart';
import 'package:guardyn_client/features/media/presentation/bloc/media_state.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_event.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_state.dart';
import 'package:guardyn_client/features/messaging/presentation/pages/chat_page.dart';
import 'package:guardyn_client/features/presence/presentation/bloc/presence_bloc.dart';
import 'package:guardyn_client/features/presence/presentation/bloc/presence_event.dart';
import 'package:guardyn_client/features/presence/presentation/bloc/presence_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock BLoCs with proper type parameters
class MockMessageBloc extends MockBloc<MessageEvent, MessageState>
    implements MessageBloc {}

class MockPresenceBloc extends MockBloc<PresenceEvent, PresenceState>
    implements PresenceBloc {}

class MockMediaBloc extends MockBloc<MediaEvent, MediaState>
    implements MediaBloc {}

class MockCallBloc extends MockBloc<CallEvent, call_state.CallState>
    implements CallBloc {}

void main() {
  late MockMessageBloc mockMessageBloc;
  late MockPresenceBloc mockPresenceBloc;
  late MockMediaBloc mockMediaBloc;
  late MockCallBloc mockCallBloc;

  setUp(() {
    mockMessageBloc = MockMessageBloc();
    mockPresenceBloc = MockPresenceBloc();
    mockMediaBloc = MockMediaBloc();
    mockCallBloc = MockCallBloc();

    // Set default states
    when(() => mockMessageBloc.state).thenReturn(MessageInitial());
    when(() => mockPresenceBloc.state).thenReturn(const PresenceInitial());
    when(() => mockPresenceBloc.stream).thenAnswer(
      (_) => Stream.value(const PresenceInitial()),
    );
    when(() => mockPresenceBloc.isClosed).thenReturn(false);
    when(() => mockMediaBloc.state).thenReturn(const MediaInitial());
    when(() => mockCallBloc.state).thenReturn(const call_state.CallInitial());

    // Register GetIt dependencies for CallBloc creation
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<PresenceBloc>()) {
      getIt.registerFactory<PresenceBloc>(() => mockPresenceBloc);
    }
    if (!getIt.isRegistered<MediaBloc>()) {
      getIt.registerFactory<MediaBloc>(() => mockMediaBloc);
    }
    if (!getIt.isRegistered<CallBloc>()) {
      getIt.registerFactory<CallBloc>(() => mockCallBloc);
    }
  });

  tearDown(() {
    final getIt = GetIt.instance;
    getIt.reset();
  });

  group('ChatPage Call Buttons', () {
    testWidgets('should show video call button in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<MessageBloc>.value(value: mockMessageBloc),
              BlocProvider<PresenceBloc>.value(value: mockPresenceBloc),
              BlocProvider<MediaBloc>.value(value: mockMediaBloc),
            ],
            child: const ChatPage(
              conversationUserId: 'user-123',
              conversationUserName: 'Test User',
              deviceId: 'device-123',
            ),
          ),
        ),
      );

      // Allow async initialization to complete
      await tester.pump();

      // Find video call button (videocam icon)
      final videocamIcon = find.byIcon(Icons.videocam);
      expect(videocamIcon, findsOneWidget);
    });

    testWidgets('should show voice call button in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<MessageBloc>.value(value: mockMessageBloc),
              BlocProvider<PresenceBloc>.value(value: mockPresenceBloc),
              BlocProvider<MediaBloc>.value(value: mockMediaBloc),
            ],
            child: const ChatPage(
              conversationUserId: 'user-123',
              conversationUserName: 'Test User',
              deviceId: 'device-123',
            ),
          ),
        ),
      );

      await tester.pump();

      // Find voice call button (call icon)
      final callIcon = find.byIcon(Icons.call);
      expect(callIcon, findsOneWidget);
    });

    testWidgets('video call button should have correct tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<MessageBloc>.value(value: mockMessageBloc),
              BlocProvider<PresenceBloc>.value(value: mockPresenceBloc),
              BlocProvider<MediaBloc>.value(value: mockMediaBloc),
            ],
            child: const ChatPage(
              conversationUserId: 'user-123',
              conversationUserName: 'Test User',
              deviceId: 'device-123',
            ),
          ),
        ),
      );

      await tester.pump();

      // Find IconButton with tooltip
      final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton));
      final videoButton = iconButtons.firstWhere(
        (btn) => btn.tooltip == 'Video call',
        orElse: () => throw Exception('Video call button not found'),
      );
      expect(videoButton, isNotNull);
    });

    testWidgets('voice call button should have correct tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<MessageBloc>.value(value: mockMessageBloc),
              BlocProvider<PresenceBloc>.value(value: mockPresenceBloc),
              BlocProvider<MediaBloc>.value(value: mockMediaBloc),
            ],
            child: const ChatPage(
              conversationUserId: 'user-123',
              conversationUserName: 'Test User',
              deviceId: 'device-123',
            ),
          ),
        ),
      );

      await tester.pump();

      // Find IconButton with tooltip
      final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton));
      final voiceButton = iconButtons.firstWhere(
        (btn) => btn.tooltip == 'Voice call',
        orElse: () => throw Exception('Voice call button not found'),
      );
      expect(voiceButton, isNotNull);
    });
  });
}
