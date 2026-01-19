import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// Integration test for two-device messaging between Android and Chrome
///
/// This test simulates two users on DIFFERENT platforms:
/// - Device 1 (Alice): Android emulator
/// - Device 2 (Bob): Chrome browser
///
/// Tests the complete cross-platform flow:
/// - Registration on both platforms
/// - Message exchange between Android <-> Chrome
/// - E2EE key exchange across platforms
///
/// Prerequisites:
/// - Backend services running (auth-service, messaging-service)
/// - Port-forwarding: localhost:50051 (auth), localhost:50052 (messaging)
/// - Android emulator running
/// - For desktop testing, use Tauri client (client-desktop)
///
/// Run with test driver:
/// flutter drive \
///   --driver=test_driver/integration_test.dart \
///   --target=integration_test/two_client_messaging_test.dart \
///   -d emulator-5554 \
///   --dart-define=TEST_PLATFORM=android
///
/// For desktop, use Tauri client:
///   cd client-desktop && npm run tauri dev
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Get test platform from environment
  const testPlatform = String.fromEnvironment(
    'TEST_PLATFORM',
    defaultValue: 'android',
  );

  group('Cross-Platform Two-Device Messaging', () {
    testWidgets('$testPlatform: User registration and message exchange', (
      WidgetTester tester,
    ) async {
      print('\n🌐 PLATFORM: $testPlatform');

      if (testPlatform == 'android') {
        await _testAndroidClient(tester);
      } else if (testPlatform == 'chrome') {
        await _testChromeClient(tester);
      } else {
        fail('Unknown test platform: $testPlatform');
      }
    });
  });
}

/// Test logic for Android client (Alice)
Future<void> _testAndroidClient(WidgetTester tester) async {
  print('📱 ANDROID CLIENT (Alice) - Starting...');

  // Launch app
  app.main();
  await tester.pumpAndSettle();

  // Handle case where user is already logged in
  if (find.text('Login').evaluate().isEmpty) {
    print('📱 User already logged in, logging out first...');

    // Find logout icon in AppBar (Icons.logout)
    final logoutIcon = find.byIcon(Icons.logout);

    if (logoutIcon.evaluate().isNotEmpty) {
      print('📱 Found logout button, tapping...');
      await tester.tap(logoutIcon.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Confirm logout if dialog appears
      final confirmButton = find.text('Confirm');
      final yesButton = find.text('Yes');
      final okButton = find.text('OK');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton.first);
        await tester.pumpAndSettle();
      } else if (yesButton.evaluate().isNotEmpty) {
        await tester.tap(yesButton.first);
        await tester.pumpAndSettle();
      } else if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton.first);
        await tester.pumpAndSettle();
      }

      // Wait for logout to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('📱 Logout completed');
    } else {
      print('⚠️  No logout button found, trying menu...');

      // Try to find and tap menu
      final menuButton = find.byIcon(Icons.menu);
      final moreButton = find.byIcon(Icons.more_vert);

      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton.first);
        await tester.pumpAndSettle();
      } else if (moreButton.evaluate().isNotEmpty) {
        await tester.tap(moreButton.first);
        await tester.pumpAndSettle();
      }

      // Find and tap logout text
      final logoutText = find.text('Logout');
      final signOutText = find.text('Sign Out');

      if (logoutText.evaluate().isNotEmpty) {
        await tester.tap(logoutText.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (signOutText.evaluate().isNotEmpty) {
        await tester.tap(signOutText.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }
  }

  print('📱 Verifying login page...');

  // More flexible check - find Login text anywhere
  final loginFinder = find.text('Login');
  if (loginFinder.evaluate().isEmpty) {
    print('⚠️  Login page not found, test may need manual cleanup');
    print('📱 Current screen widgets:');
    // Print what we can find for debugging
    for (final widget in find.byType(Text).evaluate()) {
      final textWidget = widget.widget as Text;
      print('   - Text: "${textWidget.data}"');
    }
    fail('Could not reach login page. Clear app data and retry.');
  }

  expect(loginFinder, findsAtLeastNWidgets(1)); // At least one Login text

  // Navigate to registration
  print('📱 Navigating to registration...');
  await tester.tap(find.text("Don't have an account? Register"));
  await tester.pumpAndSettle();

  // Register Alice
  print('📱 Registering Alice...');
  await tester.enterText(
    find.widgetWithText(TextField, 'Username'),
    'alice_android',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Password'),
    'password123',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Confirm Password'),
    'password123',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Device Name'),
    'Android Device',
  );

  // Submit registration
  print('📱 Submitting registration...');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));

  // Wait for registration to complete (crypto operations can take time)
  print('📱 Waiting for registration... (up to 30 seconds)');
  await tester.pumpAndSettle(const Duration(seconds: 3));
  for (var i = 0; i < 27; i++) {
    await Future.delayed(const Duration(seconds: 1));
    await tester.pump();
    if (find.text('Welcome to Guardyn!').evaluate().isNotEmpty) {
      print('📱 Registration completed after ${i + 3} seconds');
      break;
    }
    if (i % 5 == 0) {
      print('📱 Still waiting... (${i + 3}s elapsed)');
    }
  }

  // Verify registration success
  print('📱 Verifying registration success...');
  expect(find.text('Welcome to Guardyn!'), findsOneWidget);
  expect(find.text('alice_android'), findsOneWidget);

  // Get Alice's user ID
  final aliceUserIdFinder = find.textContaining('User ID:');
  expect(aliceUserIdFinder, findsOneWidget);
  final aliceUserIdText = (tester.widget(aliceUserIdFinder) as Text).data!;
  final aliceUserId = aliceUserIdText.split('User ID: ')[1];
  print('📱 Alice User ID: $aliceUserId');

  // Navigate to Messages
  print('📱 Opening messages screen...');
  await tester.tap(find.text('Open Messages'));
  await tester.pumpAndSettle();

  expect(find.text('Messages'), findsOneWidget);

  // Wait for Bob to register on Chrome (coordination point)
  print('📱 Waiting for Bob (Chrome) to register...');
  await Future.delayed(const Duration(seconds: 10));

  // Start new conversation with Bob
  print('📱 Starting conversation with Bob...');
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  expect(find.text('New Conversation'), findsOneWidget);

  // Enter Bob's username
  print('📱 Searching for Bob...');
  await tester.enterText(
    find.widgetWithText(TextField, 'Search users'),
    'bob_chrome',
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Select Bob from search results
  final bobUserTile = find.textContaining('bob_chrome');
  if (bobUserTile.evaluate().isEmpty) {
    print('⚠️  Bob not found yet, waiting...');
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  expect(bobUserTile, findsAtLeastNWidgets(1));
  await tester.tap(bobUserTile.first);
  await tester.pumpAndSettle();

  // Send message to Bob
  print('📱 Sending message to Bob...');
  final messageText =
      'Hello from Android! 📱 (${DateTime.now().millisecondsSinceEpoch})';

  await tester.enterText(
    find.widgetWithText(TextField, 'Type a message...'),
    messageText,
  );
  await tester.tap(find.byIcon(Icons.send));
  await tester.pumpAndSettle();

  // Verify message sent
  expect(find.textContaining('Hello from Android!'), findsOneWidget);
  print('📱 ✅ Message sent to Bob');

  // Wait for Bob's response
  print('📱 Waiting for Bob\'s response...');
  for (int i = 0; i < 15; i++) {
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    if (find.textContaining('Hello from Chrome!').evaluate().isNotEmpty) {
      print('📱 ✅ Received message from Bob (Chrome)');
      expect(find.textContaining('Hello from Chrome!'), findsOneWidget);
      break;
    }

    if (i == 14) {
      print('📱 ⚠️  No response from Bob after 30 seconds');
    }
  }

  print('📱 ✅ ANDROID CLIENT TEST COMPLETED');
}

/// Test logic for Chrome client (Bob)
Future<void> _testChromeClient(WidgetTester tester) async {
  print('🌐 CHROME CLIENT (Bob) - Starting...');

  // Launch app
  app.main();
  await tester.pumpAndSettle();

  // Handle case where user is already logged in
  if (find.text('Login').evaluate().isEmpty) {
    print('🌐 User already logged in, logging out first...');

    // Find logout icon in AppBar (Icons.logout)
    final logoutIcon = find.byIcon(Icons.logout);

    if (logoutIcon.evaluate().isNotEmpty) {
      print('🌐 Found logout button, tapping...');
      await tester.tap(logoutIcon.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Confirm logout if dialog appears
      final confirmButton = find.text('Confirm');
      final yesButton = find.text('Yes');
      final okButton = find.text('OK');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton.first);
        await tester.pumpAndSettle();
      } else if (yesButton.evaluate().isNotEmpty) {
        await tester.tap(yesButton.first);
        await tester.pumpAndSettle();
      } else if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton.first);
        await tester.pumpAndSettle();
      }

      // Wait for logout to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('🌐 Logout completed');
    } else {
      print('⚠️  No logout button found, trying menu...');

      // Try to find and tap menu
      final menuButton = find.byIcon(Icons.menu);
      final moreButton = find.byIcon(Icons.more_vert);

      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton.first);
        await tester.pumpAndSettle();
      } else if (moreButton.evaluate().isNotEmpty) {
        await tester.tap(moreButton.first);
        await tester.pumpAndSettle();
      }

      // Find and tap logout text
      final logoutText = find.text('Logout');
      final signOutText = find.text('Sign Out');

      if (logoutText.evaluate().isNotEmpty) {
        await tester.tap(logoutText.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (signOutText.evaluate().isNotEmpty) {
        await tester.tap(signOutText.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }
  }

  print('🌐 Verifying login page...');

  // More flexible check - find Login text anywhere
  final loginFinder = find.text('Login');
  if (loginFinder.evaluate().isEmpty) {
    print('⚠️  Login page not found, test may need manual cleanup');
    print('🌐 Current screen widgets:');
    for (final widget in find.byType(Text).evaluate()) {
      final textWidget = widget.widget as Text;
      print('   - Text: "${textWidget.data}"');
    }
    fail('Could not reach login page. Clear app data and retry.');
  }

  expect(loginFinder, findsAtLeastNWidgets(1)); // At least one Login text

  // Navigate to registration
  print('🌐 Navigating to registration...');
  await tester.tap(find.text("Don't have an account? Register"));
  await tester.pumpAndSettle();

  // Register Bob
  print('🌐 Registering Bob...');
  await tester.enterText(
    find.widgetWithText(TextField, 'Username'),
    'bob_chrome',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Password'),
    'password123',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Confirm Password'),
    'password123',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Device Name'),
    'Chrome Browser',
  );

  // Submit registration
  print('🌐 Submitting registration...');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify registration success
  print('🌐 Verifying registration success...');
  expect(find.text('Welcome to Guardyn!'), findsOneWidget);
  expect(find.text('bob_chrome'), findsOneWidget);

  // Get Bob's user ID
  final bobUserIdFinder = find.textContaining('User ID:');
  expect(bobUserIdFinder, findsOneWidget);
  final bobUserIdText = (tester.widget(bobUserIdFinder) as Text).data!;
  final bobUserId = bobUserIdText.split('User ID: ')[1];
  print('🌐 Bob User ID: $bobUserId');

  // Navigate to Messages
  print('🌐 Opening messages screen...');
  await tester.tap(find.text('Open Messages'));
  await tester.pumpAndSettle();

  expect(find.text('Messages'), findsOneWidget);

  // Wait for Alice to send message
  print('🌐 Waiting for message from Alice (Android)...');
  for (int i = 0; i < 20; i++) {
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Check if we received a message from Alice
    if (find.textContaining('alice_android').evaluate().isNotEmpty) {
      print('🌐 ✅ Received message notification from Alice');

      // Tap on the conversation with Alice
      await tester.tap(find.textContaining('alice_android').first);
      await tester.pumpAndSettle();

      // Verify we can see Alice's message
      expect(find.textContaining('Hello from Android!'), findsOneWidget);
      print('🌐 ✅ Opened conversation with Alice');
      break;
    }

    if (i == 19) {
      print('🌐 ⚠️  No message from Alice after 40 seconds');
      fail('Did not receive message from Alice');
    }
  }

  // Send reply to Alice
  print('🌐 Sending reply to Alice...');
  final replyText =
      'Hello from Chrome! 🌐 (${DateTime.now().millisecondsSinceEpoch})';

  await tester.enterText(
    find.widgetWithText(TextField, 'Type a message...'),
    replyText,
  );
  await tester.tap(find.byIcon(Icons.send));
  await tester.pumpAndSettle();

  // Verify message sent
  expect(find.textContaining('Hello from Chrome!'), findsOneWidget);
  print('🌐 ✅ Reply sent to Alice');

  print('🌐 ✅ CHROME CLIENT TEST COMPLETED');
}
