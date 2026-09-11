/// Widget tests for [MessageBubble], covering how a message that could not be decrypted is
/// presented.
///
/// The receive path used to hand the bubble whatever it failed to decrypt, so the bubble
/// rendered those bytes as ordinary message text. The repository now substitutes a placeholder
/// and marks the message in metadata; these tests pin the half the user actually sees.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/undecryptable_message.dart';
import 'package:guardyn_client/features/messaging/domain/entities/message.dart';
import 'package:guardyn_client/features/messaging/presentation/widgets/message_bubble.dart';

void main() {
  const tCurrentUserId = 'user-123';
  const tSenderUserId = 'user-456';
  final tTimestamp = DateTime(2026, 1, 1, 10, 30);

  Message buildMessage({
    required String textContent,
    Map<String, String> metadata = const {},
  }) {
    return Message(
      messageId: 'msg-001',
      conversationId: 'conv-001',
      senderUserId: tSenderUserId,
      senderDeviceId: 'device-456',
      senderUsername: 'alice',
      recipientUserId: tCurrentUserId,
      recipientDeviceId: 'device-123',
      messageType: MessageType.text,
      textContent: textContent,
      metadata: metadata,
      timestamp: tTimestamp,
      deliveryStatus: DeliveryStatus.delivered,
      currentUserId: tCurrentUserId,
    );
  }

  Widget wrap(Message message) => MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      );

  testWidgets('an ordinary message renders as plain text', (tester) async {
    await tester.pumpWidget(wrap(buildMessage(textContent: 'Hello there')));

    expect(find.text('Hello there'), findsOneWidget);
    expect(find.byIcon(Icons.lock_open), findsNothing);

    final text = tester.widget<Text>(find.text('Hello there'));
    expect(text.style?.fontStyle, isNot(FontStyle.italic));
  });

  testWidgets('an undecryptable message is marked apart from real content',
      (tester) async {
    await tester.pumpWidget(wrap(buildMessage(
      textContent: undecryptableMessagePlaceholder,
      metadata: markUndecryptable(const {}),
    )));

    expect(find.text(undecryptableMessagePlaceholder), findsOneWidget);
    expect(find.byIcon(Icons.lock_open), findsOneWidget);

    final text = tester.widget<Text>(find.text(undecryptableMessagePlaceholder));
    expect(
      text.style?.fontStyle,
      FontStyle.italic,
      reason: 'the placeholder must not be mistakable for something the sender wrote',
    );
  });

  testWidgets('a user typing the placeholder text is not styled as undecryptable',
      (tester) async {
    // The marker lives in metadata rather than in the text, precisely so that content which
    // happens to match the placeholder is still rendered as what the sender wrote.
    await tester.pumpWidget(wrap(buildMessage(
      textContent: undecryptableMessagePlaceholder,
    )));

    expect(find.byIcon(Icons.lock_open), findsNothing);

    final text = tester.widget<Text>(find.text(undecryptableMessagePlaceholder));
    expect(text.style?.fontStyle, isNot(FontStyle.italic));
  });
}
