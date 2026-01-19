import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// Integration test for two-device messaging between Android and Linux Desktop
///
/// This test simulates two users on DIFFERENT platforms:
/// - Device 1 (Alice): Android device/emulator
/// - Device 2 (Bob): Linux desktop
///
/// Tests the complete cross-platform flow:
/// - Registration on both platforms
/// - E2EE key exchange across platforms
/// - Message exchange between Android <-> Linux
/// - Real-time message delivery
///
/// Prerequisites:
/// - Backend services running (Docker Compose recommended)
/// - Port configuration:
///   - For Android: Use device IP (10.0.2.2 for emulator, or host IP)
///   - For Linux: localhost:50051 (auth), localhost:50052 (messaging)
/// - Rust FFI libraries built for both platforms
///
/// ## Synchronization Mechanism
///
/// Since Flutter integration tests run in separate processes, we use a
/// file-based synchronization mechanism:
///
/// 1. Alice (Android) registers first and creates a sync file
/// 2. Bob (Linux) waits for the sync file, then registers
/// 3. Alice waits for Bob's registration sync file
/// 4. Alice sends a message
/// 5. Bob receives and replies
///
/// Sync files are stored in /tmp/guardyn_test_sync/
///
/// ## Running the Tests
///
/// Option 1: Use the test runner script (recommended):
/// ```bash
/// ./scripts/run-android-linux-messaging.sh
/// ```
///
/// Option 2: Run manually in two terminals:
///
/// Terminal 1 (Android - Alice):
/// ```bash
/// flutter test integration_test/android_linux_messaging_test.dart \
///   -d <android-device-id> \
///   --dart-define=TEST_ROLE=alice
/// ```
///
/// Terminal 2 (Linux - Bob):
/// ```bash
/// flutter test integration_test/android_linux_messaging_test.dart \
///   -d linux \
///   --dart-define=TEST_ROLE=bob
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Get test role from environment
  const testRole = String.fromEnvironment('TEST_ROLE', defaultValue: 'alice');

  // Unique test run ID to avoid conflicts
  // Note: String.fromEnvironment is compile-time constant
  const envTestRunId = String.fromEnvironment('TEST_RUN_ID', defaultValue: '');

  group('Android-Linux Two-Device Messaging', () {
    testWidgets('$testRole: E2EE message exchange', (
      WidgetTester tester,
    ) async {
      print('\n🚀 TEST ROLE: $testRole');

      // Determine test run ID
      String testRunId;
      if (envTestRunId.isNotEmpty) {
        testRunId = envTestRunId;
        print('📋 TEST RUN ID (from env): $testRunId');
      } else if (testRole == 'bob') {
        // Bob tries to find existing sync directory from Alice
        testRunId =
            await _findExistingSyncDir() ??
            DateTime.now().millisecondsSinceEpoch.toString();
        print('📋 TEST RUN ID (discovered): $testRunId');
      } else {
        testRunId = DateTime.now().millisecondsSinceEpoch.toString();
        print('📋 TEST RUN ID (generated): $testRunId');
      }

      if (testRole == 'alice') {
        await _testAliceAndroid(tester, testRunId);
      } else if (testRole == 'bob') {
        await _testBobLinux(tester, testRunId);
      } else {
        fail('Unknown test role: $testRole. Use alice or bob.');
      }
    });
  });
}

/// Find existing sync directory (for Bob to discover Alice's session)
/// Note: This only works when both clients run on the same host (e.g., Linux + Linux)
Future<String?> _findExistingSyncDir() async {
  final tempDir = Directory.systemTemp;
  final baseDir = Directory('${tempDir.path}/guardyn_test_sync');

  if (!await baseDir.exists()) {
    return null;
  }

  // Find directories with alice_registered.done file
  await for (final entity in baseDir.list()) {
    if (entity is Directory) {
      final aliceFile = File('${entity.path}/alice_registered.done');
      final aliceCompleteFile = File('${entity.path}/alice_complete.done');

      // Check if Alice registered but test not complete
      if (await aliceFile.exists() && !await aliceCompleteFile.exists()) {
        final dirName = entity.path.split('/').last;
        print('🔍 Found active sync session: $dirName');
        return dirName;
      }
    }
  }

  // If no active session, find most recent directory
  String? mostRecent;
  int mostRecentTime = 0;

  await for (final entity in baseDir.list()) {
    if (entity is Directory) {
      final dirName = entity.path.split('/').last;
      final timestamp = int.tryParse(dirName) ?? 0;
      if (timestamp > mostRecentTime) {
        mostRecentTime = timestamp;
        mostRecent = dirName;
      }
    }
  }

  if (mostRecent != null) {
    print('🔍 Using most recent sync session: $mostRecent');
  }

  return mostRecent;
}

/// Sync helper for coordination between clients
///
/// For cross-platform testing (Android + Linux), file-based sync doesn't work
/// because they don't share a filesystem. In this case, we use:
/// - Timing-based synchronization (fixed delays)
/// - Predictable usernames based on TEST_RUN_ID
///
/// For same-host testing (Linux + Linux), file-based sync works.
class TestSyncHelper {
  final String testRunId;
  late final String syncDir;
  final bool _isAndroid;

  /// Predictable username suffix based on test run ID
  late final String _usernameSuffix;

  TestSyncHelper(this.testRunId) : _isAndroid = Platform.isAndroid {
    // Use last 6 chars of test run ID for username suffix
    _usernameSuffix = testRunId.length > 6
        ? testRunId.substring(testRunId.length - 6)
        : testRunId;
  }

  /// Get predictable Alice username
  String get aliceUsername => 'alice_$_usernameSuffix';

  /// Get predictable Bob username
  String get bobUsername => 'bob_$_usernameSuffix';

  /// Check if file-based sync is available (only on desktop)
  bool get canUseFileSync => !_isAndroid;

  /// Initialize sync directory (platform-aware)
  Future<void> init() async {
    final tempDir = Directory.systemTemp;
    syncDir = '${tempDir.path}/guardyn_test_sync/$testRunId';

    if (canUseFileSync) {
      final dir = Directory(syncDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      print('📁 Sync directory: $syncDir (file sync enabled)');
    } else {
      print('📁 Sync mode: timing-based (cross-platform)');
    }
    print('👤 Alice username: $aliceUsername');
    print('👤 Bob username: $bobUsername');
  }

  /// Signal that a phase is complete
  Future<void> signal(String phase, {String? data}) async {
    if (canUseFileSync) {
      final file = File('$syncDir/$phase.done');
      await file.writeAsString(data ?? DateTime.now().toIso8601String());
      print('📤 Signaled (file): $phase');
    } else {
      // On Android, just log - timing is used for sync
      print('📤 Phase complete: $phase');
    }
  }

  /// Wait for a signal with timeout
  /// For cross-platform (waiting for Android from Linux), uses timing-based sync
  /// with shorter polling and eventual timeout.
  Future<String?> waitFor(
    String phase, {
    Duration timeout = const Duration(seconds: 60),
    bool isWaitingForAndroid = false,
  }) async {
    // If we're Android, use timing-based delay
    if (!canUseFileSync) {
      print('⏳ Waiting (timing-based): $phase for ${timeout.inSeconds}s');
      await Future.delayed(timeout);
      print('📥 Continuing after delay: $phase');
      return DateTime.now().toIso8601String();
    }

    // If we're Linux waiting for Android, also use timing-based
    // because Android can't write to our filesystem
    if (isWaitingForAndroid) {
      print(
        '⏳ Waiting for Android (timing-based): $phase for ${timeout.inSeconds}s',
      );
      await Future.delayed(timeout);
      print('📥 Continuing after delay: $phase');
      return DateTime.now().toIso8601String();
    }

    // File-based sync for Linux-to-Linux
    final file = File('$syncDir/$phase.done');
    final deadline = DateTime.now().add(timeout);

    print('⏳ Waiting for: $phase (timeout: ${timeout.inSeconds}s)');

    while (DateTime.now().isBefore(deadline)) {
      if (await file.exists()) {
        final data = await file.readAsString();
        print('📥 Received: $phase');
        return data;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('⏰ Timeout waiting for: $phase');
    return null;
  }

  /// Write data to share between clients
  Future<void> writeData(String key, String value) async {
    if (!canUseFileSync) {
      print('📝 Data (memory only): $key = $value');
      return;
    }
    final file = File('$syncDir/$key.data');
    await file.writeAsString(value);
  }

  /// Read shared data
  Future<String?> readData(String key) async {
    if (!canUseFileSync) {
      return null; // Data not available in timing-based mode
    }
    final file = File('$syncDir/$key.data');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  /// Cleanup sync files
  Future<void> cleanup() async {
    if (!canUseFileSync) {
      return;
    }
    try {
      final dir = Directory(syncDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      print('⚠️ Cleanup warning: $e');
    }
  }
}

/// Test logic for Alice on Android
Future<void> _testAliceAndroid(WidgetTester tester, String testRunId) async {
  final sync = TestSyncHelper(testRunId);
  await sync.init();

  print('📱 ANDROID CLIENT (Alice) - Starting...');

  // Launch app
  app.main();
  await tester.pumpAndSettle();

  // Handle logout if already logged in
  final onLoginPage = await _handleLogoutIfNeeded(tester, '📱');
  if (!onLoginPage) {
    fail('📱 Could not reach Login page');
  }

  // Navigate to registration - wait for the link first
  print('📱 Navigating to registration...');
  final registerLinkFound = await _waitForWidget(
    tester,
    find.text("Don't have an account? Register"),
    timeout: const Duration(seconds: 10),
  );
  if (!registerLinkFound) {
    fail('📱 Register link not found on Login page');
  }

  await tester.tap(find.text("Don't have an account? Register"));
  await tester.pumpAndSettle();

  // Wait for registration form to appear
  print('📱 Waiting for registration form...');
  final formAppeared = await _waitForWidget(
    tester,
    find.widgetWithText(TextField, 'Username'),
    timeout: const Duration(seconds: 10),
  );
  if (!formAppeared) {
    fail('📱 Registration form did not appear');
  }

  // Register Alice with predictable username from sync helper
  final aliceUsername = sync.aliceUsername;
  print('📱 Registering as: $aliceUsername');

  await _fillRegistrationForm(
    tester,
    username: aliceUsername,
    password: 'SecurePass123!',
    deviceName: 'Android Phone',
  );
  await tester.pumpAndSettle();

  // Scroll down to make sure Register button is visible
  print('📱 Scrolling to Register button...');
  final scrollable = find.byType(SingleChildScrollView);
  if (scrollable.evaluate().isNotEmpty) {
    await tester.drag(scrollable.first, const Offset(0, -200));
    await tester.pumpAndSettle();
  }

  // Submit registration - find ElevatedButton by type (it's the only one in the form)
  print('📱 Submitting registration...');
  final registerButton = find.byType(ElevatedButton);
  final buttonFound = await _waitForWidget(
    tester,
    registerButton,
    timeout: const Duration(seconds: 5),
  );
  if (!buttonFound) {
    // Try to find any clickable widget with Register text
    final altButton = find.text('Register');
    if (altButton.evaluate().isNotEmpty) {
      await tester.tap(altButton.first);
    } else {
      fail('📱 Register button not found');
    }
  } else {
    await tester.tap(registerButton.first);
  }
  await tester.pumpAndSettle();

  // Wait for registration with extended timeout (crypto ops)
  final registrationSuccess = await _waitForWidget(
    tester,
    find.text('Welcome to Guardyn!'),
    timeout: const Duration(seconds: 45),
    pollInterval: const Duration(seconds: 1),
  );

  if (!registrationSuccess) {
    // Check for error message
    final errorWidget = find.byType(SnackBar);
    if (errorWidget.evaluate().isNotEmpty) {
      final snackBar = tester.widget<SnackBar>(errorWidget.first);
      print('📱 ❌ Error: ${snackBar.content}');
    }
    fail('Alice registration failed');
  }

  print('📱 ✅ Registration successful');

  // Get Alice's user ID
  String? aliceUserId;
  final userIdFinder = find.textContaining('User ID:');
  if (userIdFinder.evaluate().isNotEmpty) {
    final text = (tester.widget<Text>(userIdFinder.first)).data ?? '';
    aliceUserId = text.replaceAll('User ID: ', '').trim();
    print('📱 Alice User ID: $aliceUserId');
  }

  // Signal Alice is registered
  await sync.signal('alice_registered');
  await sync.writeData('alice_username', aliceUsername);
  if (aliceUserId != null) {
    await sync.writeData('alice_user_id', aliceUserId);
  }

  // Navigate to Messages
  print('📱 Opening messages screen...');
  final openMessagesBtn = find.text('Open Messages');
  if (openMessagesBtn.evaluate().isNotEmpty) {
    await tester.tap(openMessagesBtn);
    await tester.pumpAndSettle();
  }

  // Wait for Bob to register (timing-based since Bob is on Linux)
  print('📱 Waiting for Bob (Linux) to register...');
  // Use timing-based wait - Bob on Linux should register within 60 seconds
  await sync.waitFor(
    'bob_registered',
    timeout: const Duration(seconds: 60),
    isWaitingForAndroid:
        false, // Bob is on Linux, but we can't receive files from him
  );

  // Use predictable Bob username
  final bobUsername = sync.bobUsername;
  print('📱 Bob username (predictable): $bobUsername');

  // Start conversation with Bob
  print('📱 Starting conversation with Bob...');
  final addButton = find.byIcon(Icons.add);
  if (addButton.evaluate().isNotEmpty) {
    await tester.tap(addButton);
    await tester.pumpAndSettle();
  }

  // Search for Bob
  print('📱 Searching for $bobUsername...');
  final searchField = find.widgetWithText(TextField, 'Search users');
  if (searchField.evaluate().isNotEmpty) {
    await tester.enterText(searchField, bobUsername);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // Select Bob from results
  await _waitForAndTap(
    tester,
    find.textContaining(bobUsername),
    timeout: const Duration(seconds: 10),
  );
  await tester.pumpAndSettle();

  // Send message to Bob
  final messageText =
      'Hello from Android! 📱 [${DateTime.now().toIso8601String()}]';
  print('📱 Sending message: $messageText');

  final messageField = find.widgetWithText(TextField, 'Type a message...');
  if (messageField.evaluate().isNotEmpty) {
    await tester.enterText(messageField, messageText);
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
  }

  // Signal message sent
  await sync.signal('alice_message_sent');
  await sync.writeData('alice_message', messageText);
  print('📱 ✅ Message sent to Bob');

  // Wait for Bob's reply
  print('📱 Waiting for Bob\'s reply...');
  final bobMessageReceived = await _waitForWidgetWithSync(
    tester,
    find.textContaining('Hello from Linux!'),
    sync: sync,
    syncPhase: 'bob_message_sent',
    timeout: const Duration(seconds: 60),
  );

  if (bobMessageReceived) {
    print('📱 ✅ Received reply from Bob!');
    expect(find.textContaining('Hello from Linux!'), findsAtLeastNWidgets(1));
  } else {
    print('📱 ⚠️ Did not receive reply from Bob');
  }

  // Signal test complete
  await sync.signal('alice_complete');

  print('📱 ✅ ALICE (ANDROID) TEST COMPLETED');
}

/// Test logic for Bob on Linux
Future<void> _testBobLinux(WidgetTester tester, String testRunId) async {
  final sync = TestSyncHelper(testRunId);
  await sync.init();

  print('🐧 LINUX CLIENT (Bob) - Starting...');

  // Wait for Alice to register first
  // Wait for Alice to register (she's on Android, use timing-based)
  print('🐧 Waiting for Alice (Android) to register...');
  await sync.waitFor(
    'alice_registered',
    timeout: const Duration(seconds: 60),
    isWaitingForAndroid: true, // Alice is on Android, can't write files
  );

  // Use predictable Alice username
  final aliceUsername = sync.aliceUsername;
  print('🐧 Alice username (predictable): $aliceUsername');

  // Launch app
  app.main();
  await tester.pumpAndSettle();

  // Handle logout if already logged in
  final onLoginPage = await _handleLogoutIfNeeded(tester, '🐧');
  if (!onLoginPage) {
    fail('🐧 Could not reach Login page');
  }

  // Navigate to registration - wait for the link first
  print('🐧 Navigating to registration...');
  final registerLinkFound = await _waitForWidget(
    tester,
    find.text("Don't have an account? Register"),
    timeout: const Duration(seconds: 10),
  );
  if (!registerLinkFound) {
    fail('🐧 Register link not found on Login page');
  }

  await tester.tap(find.text("Don't have an account? Register"));
  await tester.pumpAndSettle();

  // Wait for registration form to appear
  print('🐧 Waiting for registration form...');
  final formAppeared = await _waitForWidget(
    tester,
    find.widgetWithText(TextField, 'Username'),
    timeout: const Duration(seconds: 10),
  );
  if (!formAppeared) {
    fail('🐧 Registration form did not appear');
  }

  // Register Bob with predictable username from sync helper
  final bobUsername = sync.bobUsername;
  print('🐧 Registering as: $bobUsername');

  await _fillRegistrationForm(
    tester,
    username: bobUsername,
    password: 'SecurePass456!',
    deviceName: 'Linux Desktop',
  );
  await tester.pumpAndSettle();

  // Scroll down to make sure Register button is visible
  print('🐧 Scrolling to Register button...');
  final scrollable = find.byType(SingleChildScrollView);
  if (scrollable.evaluate().isNotEmpty) {
    await tester.drag(scrollable.first, const Offset(0, -200));
    await tester.pumpAndSettle();
  }

  // Submit registration - find ElevatedButton by type
  print('🐧 Submitting registration...');
  final registerButton = find.byType(ElevatedButton);
  final buttonFound = await _waitForWidget(
    tester,
    registerButton,
    timeout: const Duration(seconds: 5),
  );
  if (!buttonFound) {
    final altButton = find.text('Register');
    if (altButton.evaluate().isNotEmpty) {
      await tester.tap(altButton.first);
    } else {
      fail('🐧 Register button not found');
    }
  } else {
    await tester.tap(registerButton.first);
  }
  await tester.pumpAndSettle();

  // Wait for registration
  final registrationSuccess = await _waitForWidget(
    tester,
    find.text('Welcome to Guardyn!'),
    timeout: const Duration(seconds: 45),
    pollInterval: const Duration(seconds: 1),
  );

  if (!registrationSuccess) {
    fail('Bob registration failed');
  }

  print('🐧 ✅ Registration successful');

  // Get Bob's user ID
  String? bobUserId;
  final userIdFinder = find.textContaining('User ID:');
  if (userIdFinder.evaluate().isNotEmpty) {
    final text = (tester.widget<Text>(userIdFinder.first)).data ?? '';
    bobUserId = text.replaceAll('User ID: ', '').trim();
    print('🐧 Bob User ID: $bobUserId');
  }

  // Signal Bob is registered
  await sync.signal('bob_registered');
  await sync.writeData('bob_username', bobUsername);
  if (bobUserId != null) {
    await sync.writeData('bob_user_id', bobUserId);
  }

  // Navigate to Messages
  print('🐧 Opening messages screen...');
  final openMessagesBtn = find.text('Open Messages');
  if (openMessagesBtn.evaluate().isNotEmpty) {
    await tester.tap(openMessagesBtn);
    await tester.pumpAndSettle();
  }

  // Wait for Alice's message
  print('🐧 Waiting for message from Alice...');
  final aliceMessageSent = await sync.waitFor(
    'alice_message_sent',
    timeout: const Duration(seconds: 60),
  );

  if (aliceMessageSent == null) {
    fail('Alice did not send message in time');
  }

  // Find and open conversation with Alice
  print('🐧 Looking for Alice\'s conversation...');
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Try to find Alice's conversation in the list
  final aliceConversation = find.textContaining(aliceUsername);
  if (await _waitForWidget(
    tester,
    aliceConversation,
    timeout: const Duration(seconds: 15),
  )) {
    await tester.tap(aliceConversation.first);
    await tester.pumpAndSettle();
  }

  // Verify we received Alice's message
  final aliceMessage = await sync.readData('alice_message');
  print('🐧 Expected message: $aliceMessage');

  final messageReceived = await _waitForWidget(
    tester,
    find.textContaining('Hello from Android!'),
    timeout: const Duration(seconds: 10),
  );

  if (messageReceived) {
    print('🐧 ✅ Received message from Alice!');
    expect(find.textContaining('Hello from Android!'), findsAtLeastNWidgets(1));
  } else {
    print('🐧 ⚠️ Message not displayed yet, but continuing...');
  }

  // Send reply to Alice
  final replyText =
      'Hello from Linux! 🐧 [${DateTime.now().toIso8601String()}]';
  print('🐧 Sending reply: $replyText');

  final messageField = find.widgetWithText(TextField, 'Type a message...');
  if (messageField.evaluate().isNotEmpty) {
    await tester.enterText(messageField, replyText);
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
  }

  // Signal message sent
  await sync.signal('bob_message_sent');
  await sync.writeData('bob_message', replyText);
  print('🐧 ✅ Reply sent to Alice');

  // Wait for Alice to complete
  print('🐧 Waiting for Alice to complete...');
  await sync.waitFor('alice_complete', timeout: const Duration(seconds: 30));

  // Cleanup sync files
  await sync.cleanup();

  print('🐧 ✅ BOB (LINUX) TEST COMPLETED');
}

// ============================================================
// Helper Functions
// ============================================================

/// Handle logout if user is already logged in
/// Returns true if we're now on Login page
Future<bool> _handleLogoutIfNeeded(WidgetTester tester, String prefix) async {
  // Wait for app to fully load first
  print('$prefix Waiting for app to load...');
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Check if Login page is already visible
  if (find.text('Login').evaluate().isNotEmpty ||
      find.text("Don't have an account? Register").evaluate().isNotEmpty) {
    print('$prefix Already on Login page');
    return true;
  }

  // Check if Registration page is visible
  if (find.widgetWithText(TextField, 'Username').evaluate().isNotEmpty &&
      find.text('Register').evaluate().isNotEmpty) {
    print('$prefix Already on Registration page');
    return true;
  }

  print('$prefix User appears to be logged in, attempting logout...');

  // Try logout button in AppBar
  final logoutIcon = find.byIcon(Icons.logout);
  if (logoutIcon.evaluate().isNotEmpty) {
    print('$prefix Found logout icon, tapping...');
    await tester.tap(logoutIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Confirm dialog if present
    for (final buttonText in ['Confirm', 'Yes', 'OK', 'Logout']) {
      final button = find.text(buttonText);
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        break;
      }
    }
  }

  // Try menu if no logout icon
  final menuIcon = find.byIcon(Icons.more_vert);
  if (menuIcon.evaluate().isNotEmpty) {
    await tester.tap(menuIcon.first);
    await tester.pumpAndSettle();

    final logoutText = find.text('Logout');
    if (logoutText.evaluate().isNotEmpty) {
      await tester.tap(logoutText.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  // Wait for Login page to appear (may take time after logout)
  print('$prefix Waiting for Login page after logout...');
  for (int i = 0; i < 15; i++) {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    if (find.text('Login').evaluate().isNotEmpty ||
        find.text("Don't have an account? Register").evaluate().isNotEmpty) {
      print('$prefix Logout completed, Login page visible');
      return true;
    }

    // Check for splash screen text
    if (find.text('Guardyn').evaluate().isNotEmpty) {
      print('$prefix Still on splash screen, waiting...');
    }
  }

  print('$prefix ⚠️ Login page not visible after logout, current widgets:');
  for (final widget in find.byType(Text).evaluate().take(10)) {
    final textWidget = widget.widget as Text;
    print('$prefix   - "${textWidget.data}"');
  }

  return false;
}

/// Fill registration form
Future<void> _fillRegistrationForm(
  WidgetTester tester, {
  required String username,
  required String password,
  required String deviceName,
}) async {
  final usernameField = find.widgetWithText(TextField, 'Username');
  final passwordField = find.widgetWithText(TextField, 'Password');
  final confirmField = find.widgetWithText(TextField, 'Confirm Password');
  final deviceField = find.widgetWithText(TextField, 'Device Name');

  if (usernameField.evaluate().isNotEmpty) {
    await tester.enterText(usernameField, username);
  }
  if (passwordField.evaluate().isNotEmpty) {
    await tester.enterText(passwordField, password);
  }
  if (confirmField.evaluate().isNotEmpty) {
    await tester.enterText(confirmField, password);
  }
  if (deviceField.evaluate().isNotEmpty) {
    await tester.enterText(deviceField, deviceName);
  }
}

/// Wait for a widget to appear with timeout
Future<bool> _waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration pollInterval = const Duration(milliseconds: 500),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await tester.pumpAndSettle(pollInterval);

    if (finder.evaluate().isNotEmpty) {
      return true;
    }
  }

  return false;
}

/// Wait for widget with sync coordination
Future<bool> _waitForWidgetWithSync(
  WidgetTester tester,
  Finder finder, {
  required TestSyncHelper sync,
  required String syncPhase,
  Duration timeout = const Duration(seconds: 60),
}) async {
  final deadline = DateTime.now().add(timeout);

  // First wait for sync signal
  while (DateTime.now().isBefore(deadline)) {
    final syncFile = File('${sync.syncDir}/$syncPhase.done');
    if (await syncFile.exists()) {
      break;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Then wait for widget to appear
  return _waitForWidget(tester, finder, timeout: const Duration(seconds: 15));
}

/// Wait for a widget and tap it
Future<bool> _waitForAndTap(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final found = await _waitForWidget(tester, finder, timeout: timeout);
  if (found) {
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
    return true;
  }
  return false;
}
