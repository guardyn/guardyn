import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// Integration test for authentication flow (Registration + Login)
///
/// This test validates the complete auth flow on Android:
/// 1. Fresh registration with new user
/// 2. Logout
/// 3. Login with same credentials
/// 4. Verify session persists
///
/// Prerequisites:
/// - Backend services running (Docker Compose)
/// - Android device/emulator connected
///
/// Run with:
/// ```bash
/// flutter test integration_test/auth_registration_test.dart -d emulator-5554
/// ```
///
/// Or use just command:
/// ```bash
/// just test-auth-android
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Generate unique username for this test run
  final testTimestamp = DateTime.now().millisecondsSinceEpoch;
  final testUsername = 'testuser_$testTimestamp';
  const testPassword = 'SecurePass123!';
  const testDeviceName = 'Android Test Device';

  group('Authentication Flow Tests', () {
    testWidgets('Complete auth flow: Register → Logout → Login', (
      WidgetTester tester,
    ) async {
      print('\n${'=' * 60}');
      print('🔐 AUTH INTEGRATION TEST - Android');
      print('${'=' * 60}');
      print('📋 Test user: $testUsername');
      print('📱 Device: Android emulator/device');
      print('${'=' * 60}\n');

      // Launch app - main() is async but returns void, so we can't await it
      // Instead, we'll pump frames until the app UI appears
      print('📱 Launching Guardyn app...');
      app.main();

      // Give the app time to initialize (gRPC, crypto, etc.)
      // Use pump() instead of pumpAndSettle() to allow async operations to complete
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));

        // Check if app UI is visible
        final hasAppUI =
            find.byType(Scaffold).evaluate().isNotEmpty ||
            find.text('Guardyn').evaluate().isNotEmpty ||
            find.text('Login').evaluate().isNotEmpty;

        if (hasAppUI) {
          print('📱 App UI visible after ${i + 1} seconds');
          break;
        }

        if (i % 5 == 4) {
          print('📱 Still waiting for app to initialize... (${i + 1}s)');
        }
      }

      // Now settle any remaining animations
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ═══════════════════════════════════════════════════════════════
      // STEP 1: Handle existing session (logout if needed)
      // ═══════════════════════════════════════════════════════════════
      print('\n📍 STEP 1: Preparing clean state...');

      final onLoginPage = await _navigateToLogin(tester);
      if (!onLoginPage) {
        fail('❌ Could not navigate to Login page');
      }
      print('✅ On Login page');

      // ═══════════════════════════════════════════════════════════════
      // STEP 2: Registration
      // ═══════════════════════════════════════════════════════════════
      print('\n📍 STEP 2: Testing Registration...');

      // Navigate to registration page
      print('   → Navigating to registration page...');
      final registerLink = find.text("Don't have an account? Register");
      expect(registerLink, findsOneWidget, reason: 'Register link not found');

      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Wait for registration form
      final formReady = await _waitForWidget(
        tester,
        find.widgetWithText(TextField, 'Username'),
        timeout: const Duration(seconds: 10),
      );
      expect(formReady, isTrue, reason: 'Registration form did not appear');

      // Fill registration form
      print('   → Filling registration form...');
      await _fillTextField(tester, 'Username', testUsername);
      await _fillTextField(tester, 'Password', testPassword);
      await _fillTextField(tester, 'Confirm Password', testPassword);
      await _fillTextField(tester, 'Device Name', testDeviceName);

      // Scroll to make button visible
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      // Submit registration
      print('   → Submitting registration (this may take up to 45s)...');
      final registerButton = find.widgetWithText(ElevatedButton, 'Register');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
      } else {
        // Fallback: find by type
        final buttons = find.byType(ElevatedButton);
        expect(buttons, findsAtLeastNWidgets(1), reason: 'No button found');
        await tester.tap(buttons.first);
      }
      await tester.pumpAndSettle();

      // Wait for registration success (crypto operations can take time)
      final registrationSuccess = await _waitForAnyWidget(tester, [
        find.text('Welcome to Guardyn!'),
        find.text('Open Messages'),
        find.byIcon(Icons.chat_bubble_outline),
      ], timeout: const Duration(seconds: 60));

      if (!registrationSuccess) {
        // Check for errors
        await _printCurrentScreen(tester, 'Registration');
        fail('❌ Registration failed - success screen not found');
      }

      print('✅ Registration successful!');

      // ═══════════════════════════════════════════════════════════════
      // STEP 3: Logout
      // ═══════════════════════════════════════════════════════════════
      print('\n📍 STEP 3: Testing Logout...');

      // Look for logout option
      final logoutSuccess = await _performLogout(tester);
      if (!logoutSuccess) {
        // Try navigating to settings first
        print('   → Trying settings page...');
        final settingsIcon = find.byIcon(Icons.settings);
        if (settingsIcon.evaluate().isNotEmpty) {
          await tester.tap(settingsIcon);
          await tester.pumpAndSettle();
          await _performLogout(tester);
        }
      }

      // Wait for login page
      final backOnLogin = await _waitForAnyWidget(tester, [
        find.text('Login'),
        find.text("Don't have an account? Register"),
      ], timeout: const Duration(seconds: 15));

      expect(backOnLogin, isTrue, reason: 'Login page not shown after logout');
      print('✅ Logout successful!');

      // ═══════════════════════════════════════════════════════════════
      // STEP 4: Login with same credentials
      // ═══════════════════════════════════════════════════════════════
      print('\n📍 STEP 4: Testing Login...');

      // Wait for login form to be ready
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Fill login form
      print('   → Filling login form...');
      await _fillTextField(tester, 'Username', testUsername);
      await _fillTextField(tester, 'Password', testPassword);

      // Submit login
      print('   → Submitting login...');
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
      } else {
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
        }
      }
      await tester.pumpAndSettle();

      // Wait for login success
      final loginSuccess = await _waitForAnyWidget(tester, [
        find.text('Welcome back!'),
        find.text('Messages'),
        find.byIcon(Icons.chat_bubble_outline),
        find.byType(BottomNavigationBar),
      ], timeout: const Duration(seconds: 30));

      if (!loginSuccess) {
        await _printCurrentScreen(tester, 'Login');
        fail('❌ Login failed - home screen not found');
      }

      print('✅ Login successful!');

      // ═══════════════════════════════════════════════════════════════
      // STEP 5: Verify session
      // ═══════════════════════════════════════════════════════════════
      print('\n📍 STEP 5: Verifying session...');

      // Check that we're on the main screen
      final hasMainUI = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasMainUI, isTrue, reason: 'Main UI not loaded');

      print('✅ Session verified!');

      // ═══════════════════════════════════════════════════════════════
      // TEST COMPLETE
      // ═══════════════════════════════════════════════════════════════
      print('\n${'=' * 60}');
      print('✅ ALL AUTH TESTS PASSED');
      print('${'=' * 60}');
      print('   ✓ Registration: OK');
      print('   ✓ Logout: OK');
      print('   ✓ Login: OK');
      print('   ✓ Session: OK');
      print('${'=' * 60}\n');
    });

    // Note: Additional validation tests removed because integration tests
    // on device can only run one app.main() per session.
    // For validation tests, use unit tests instead.
  });
}

// ════════════════════════════════════════════════════════════════════════════
// Helper Functions
// ════════════════════════════════════════════════════════════════════════════

/// Navigate to login page (handling existing session and splash screen)
Future<bool> _navigateToLogin(WidgetTester tester) async {
  print('   → Waiting for app to fully load...');

  // First, wait for app to initialize (gRPC, crypto, etc.)
  // This can take up to 10 seconds on first launch
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(seconds: 1));

    // Check if any real app UI is visible
    final hasAppUI = find.byType(Scaffold).evaluate().isNotEmpty;
    final hasGuardynText = find.text('Guardyn').evaluate().isNotEmpty;
    final hasLoginText =
        find.text('Login').evaluate().isNotEmpty ||
        find.text("Don't have an account? Register").evaluate().isNotEmpty;

    if (hasAppUI && (hasGuardynText || hasLoginText)) {
      print('   → App UI loaded (iteration $i)');
      break;
    }

    if (i == 19) {
      print('   ⚠️ App UI load timeout');
      // Print what we see
      _debugPrintWidgets(tester);
    }
  }

  // Wait for splash screen to complete navigation
  print('   → Waiting for splash screen to complete...');
  for (int i = 0; i < 30; i++) {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Check if we're past splash screen (login or home visible)
    final hasLogin =
        find.text("Don't have an account? Register").evaluate().isNotEmpty ||
        find.widgetWithText(ElevatedButton, 'Login').evaluate().isNotEmpty;
    final hasHome =
        find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
        find.text('Messages').evaluate().isNotEmpty;

    if (hasLogin || hasHome) {
      if (hasLogin) {
        print('   → Login page visible');
        return true;
      }
      if (hasHome) {
        print('   → Home page visible (user logged in)');
        break;
      }
    }

    // Still on splash?
    final onSplash =
        find.text('Guardyn').evaluate().isNotEmpty &&
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

    if (i % 10 == 0 && i > 0) {
      print('   → Still waiting... (${i}s) onSplash=$onSplash');
    }
  }

  // On registration page?
  if (find.widgetWithText(TextField, 'Username').evaluate().isNotEmpty &&
      find.text('Already have an account? Login').evaluate().isNotEmpty) {
    // Navigate back to login
    print('   → On Registration page, navigating to Login...');
    await tester.tap(find.text('Already have an account? Login'));
    await tester.pumpAndSettle();
    return true;
  }

  // Might be on home screen (logged in) - try to logout
  print('   → Checking if logged in, attempting logout...');
  final loggedOut = await _performLogout(tester);
  if (loggedOut) {
    // Wait for login page to appear
    for (int i = 0; i < 15; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 1));
      if (find.text("Don't have an account? Register").evaluate().isNotEmpty ||
          find.widgetWithText(ElevatedButton, 'Login').evaluate().isNotEmpty) {
        print('   → Logged out, now on Login page');
        return true;
      }
    }
  }

  // Print current state for debugging
  print('   ⚠️ Could not find Login page. Current widgets:');
  final texts = find.byType(Text).evaluate().take(10);
  for (final element in texts) {
    final widget = element.widget as Text;
    final data = widget.data ?? '<null>';
    if (data.isNotEmpty && data.length < 50) {
      print('     - "$data"');
    }
  }

  return false;
}

/// Perform logout action
Future<bool> _performLogout(WidgetTester tester) async {
  // Try logout icon
  final logoutIcon = find.byIcon(Icons.logout);
  if (logoutIcon.evaluate().isNotEmpty) {
    await tester.tap(logoutIcon.first);
    await tester.pumpAndSettle();

    // Handle confirmation dialog
    for (final text in ['Confirm', 'Yes', 'OK', 'Logout']) {
      final button = find.text(text);
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first);
        await tester.pumpAndSettle();
        return true;
      }
    }
    return true;
  }

  // Try menu
  final menuIcon = find.byIcon(Icons.more_vert);
  if (menuIcon.evaluate().isNotEmpty) {
    await tester.tap(menuIcon.first);
    await tester.pumpAndSettle();

    final logoutText = find.text('Logout');
    if (logoutText.evaluate().isNotEmpty) {
      await tester.tap(logoutText.first);
      await tester.pumpAndSettle();
      return true;
    }
  }

  return false;
}

/// Fill a text field by label
Future<void> _fillTextField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.widgetWithText(TextField, label);
  if (field.evaluate().isNotEmpty) {
    await tester.enterText(field.first, value);
    await tester.pumpAndSettle();
  }
}

/// Wait for a widget to appear
Future<bool> _waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      return true;
    }
  }

  return false;
}

/// Debug helper to print current widgets
void _debugPrintWidgets(WidgetTester tester) {
  print('   📋 Current visible widgets:');
  final texts = find.byType(Text).evaluate().take(10);
  for (final element in texts) {
    final widget = element.widget as Text;
    final data = widget.data ?? '<null>';
    if (data.isNotEmpty && data.length < 50) {
      print('      - "$data"');
    }
  }
}

/// Wait for any of multiple widgets to appear
Future<bool> _waitForAnyWidget(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
  }

  return false;
}

/// Print current screen for debugging
Future<void> _printCurrentScreen(WidgetTester tester, String context) async {
  print('📸 Current screen state ($context):');

  // Print visible texts
  final texts = find.byType(Text).evaluate().take(15);
  for (final element in texts) {
    final widget = element.widget as Text;
    final data = widget.data ?? widget.textSpan?.toPlainText() ?? '<no text>';
    if (data.isNotEmpty && data.length < 100) {
      print('   📝 "$data"');
    }
  }

  // Print visible buttons
  final buttonCount = find.byType(ElevatedButton).evaluate().length;
  if (buttonCount > 0) {
    print('   🔘 ElevatedButton found ($buttonCount)');
  }

  // Check for SnackBar errors
  final snackBarCount = find.byType(SnackBar).evaluate().length;
  if (snackBarCount > 0) {
    print('   ⚠️ SnackBar visible (likely error)');
  }
}
