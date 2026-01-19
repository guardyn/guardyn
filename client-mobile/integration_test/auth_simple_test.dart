/// Simplified Auth Integration Test
///
/// Tests registration and login flow on Android.
/// Uses direct initialization to avoid async main() issues.
///
/// Run with:
/// ```bash
/// flutter test integration_test/auth_simple_test.dart -d emulator-5554
/// ```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:guardyn_client/app.dart';
import 'package:guardyn_client/core/crypto/crypto_primitives.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/services/notification_service.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Unique username per test run
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testUser = 'test_$timestamp';
  const testPass = 'SecurePass123!';
  const deviceName = 'Android Test';

  setUpAll(() async {
    print('\n🚀 Setting up integration tests...');
    print('📱 Initializing app dependencies...');

    // Reset GetIt if already initialized
    final getIt = GetIt.instance;
    if (getIt.isRegistered<GrpcClients>()) {
      print('⚠️ Resetting existing GetIt registrations...');
      await getIt.reset();
    }

    // Initialize dependencies manually with timeout
    try {
      // Initialize CryptoPrimitives FIRST (Rust FFI crypto)
      print('  🔐 Initializing CryptoPrimitives (Rust FFI)...');
      await CryptoPrimitives.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('CryptoPrimitives initialization timed out');
        },
      );
      print(
        '  ✅ CryptoPrimitives ready (native=${CryptoPrimitives.isNativeAvailable})',
      );

      // SecureStorage
      getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
      print('  ✅ SecureStorage registered');

      // CryptoService with timeout
      print('  🔐 Initializing CryptoService...');
      final cryptoService = CryptoService();
      await cryptoService.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('CryptoService initialization timed out');
        },
      );
      getIt.registerSingleton<CryptoService>(cryptoService);
      print('  ✅ CryptoService ready');

      // NotificationService - skip full init in tests (permission dialogs block)
      print('  🔔 Registering NotificationService (skip init in tests)...');
      final notificationService = NotificationService();
      // Don't await initialize() - it may block on permission dialogs
      getIt.registerSingleton<NotificationService>(notificationService);
      print('  ✅ NotificationService registered (not initialized)');

      // GrpcClients with timeout
      print('  🌐 Initializing GrpcClients...');
      final grpcClients = GrpcClients();
      await grpcClients.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('GrpcClients initialization timed out');
        },
      );
      getIt.registerSingleton<GrpcClients>(grpcClients);
      print('  ✅ GrpcClients ready');

      print('✅ All dependencies initialized!\n');
    } catch (e, stack) {
      print('❌ Dependency initialization failed: $e');
      print('Stack: $stack');
      rethrow;
    }
  });

  tearDownAll(() async {
    print('\n🧹 Cleaning up...');
    final getIt = GetIt.instance;
    if (getIt.isRegistered<GrpcClients>()) {
      await getIt<GrpcClients>().dispose();
    }
    await getIt.reset();
    print('✅ Cleanup complete\n');
  });

  group('Auth Tests', () {
    testWidgets('Register new user', (WidgetTester tester) async {
      print('\n${'=' * 50}');
      print('📝 TEST: Register new user');
      print('   Username: $testUser');
      print('${'=' * 50}\n');

      // Launch app (dependencies already initialized)
      await tester.pumpWidget(const GuardynApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Debug: print current screen state
      print('📱 Current screen widgets:');
      _debugPrintWidgets(tester);

      // Wait for Login page
      final loginPageReady = await _waitForWidget(
        tester,
        find.text('Login'),
        timeout: const Duration(seconds: 15),
      );

      if (!loginPageReady) {
        print('❌ Login page not found, checking for other screens...');
        _debugPrintWidgets(tester);
        fail('Login page did not appear');
      }

      print('✅ Login page loaded');

      // Navigate to Registration
      final registerLink = find.text("Don't have an account? Register");
      if (registerLink.evaluate().isEmpty) {
        print('Looking for alternative register link...');
        final altLink = find.textContaining('Register');
        expect(altLink, findsAtLeastNWidgets(1), reason: 'No register link');
        await tester.tap(altLink.first);
      } else {
        await tester.tap(registerLink);
      }
      await tester.pumpAndSettle();

      print('📱 On Registration page');

      // Fill form
      await _enterText(tester, 'Username', testUser);
      await _enterText(tester, 'Password', testPass);
      await _enterText(tester, 'Confirm Password', testPass);
      await _enterText(tester, 'Device Name', deviceName);

      print('   ✅ Form filled');

      // Scroll to button if needed
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
        await tester.pumpAndSettle();
      }

      // Submit
      print('   🔄 Submitting registration...');
      final registerBtn = find.widgetWithText(ElevatedButton, 'Register');
      if (registerBtn.evaluate().isEmpty) {
        final anyBtn = find.byType(ElevatedButton);
        expect(anyBtn, findsAtLeastNWidgets(1));
        await tester.tap(anyBtn.first);
      } else {
        await tester.tap(registerBtn);
      }
      await tester.pump(); // Start processing

      // Wait for success (crypto can take 30-60s)
      print('   ⏳ Waiting for registration (up to 60s)...');
      final success = await _waitForAnyWidget(tester, [
        find.text('Welcome to Guardyn!'),
        find.byIcon(Icons.chat_bubble_outline),
        find.text('Open Messages'),
        find.text('Messages'),
        find.byType(BottomNavigationBar),
      ], timeout: const Duration(seconds: 60));

      if (success) {
        print('✅ Registration successful!');
      } else {
        print('❌ Registration failed');
        _debugPrintWidgets(tester);

        // Check for error messages
        final errorFinder = find.textContaining('error', skipOffstage: false);
        if (errorFinder.evaluate().isNotEmpty) {
          final errorElement = errorFinder.evaluate().first;
          print('Error found: ${_getWidgetText(errorElement)}');
        }
        fail('Registration did not complete successfully');
      }
    });

    testWidgets('Login with registered user', (WidgetTester tester) async {
      print('\n${'=' * 50}');
      print('🔐 TEST: Login with existing user');
      print('   Username: $testUser');
      print('${'=' * 50}\n');

      // Force logout by clearing storage first
      print('   Clearing storage for clean login test...');
      final storage = GetIt.instance<SecureStorage>();
      await storage.clearAll();

      // Launch app fresh
      await tester.pumpWidget(const GuardynApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for Login page
      final loginReady = await _waitForWidget(
        tester,
        find.text('Login'),
        timeout: const Duration(seconds: 10),
      );

      if (!loginReady) {
        print('❌ Login page not found');
        _debugPrintWidgets(tester);
        fail('Login page not found after storage clear');
      }

      print('✅ Login page loaded');

      // Fill login form
      await _enterText(tester, 'Username', testUser);
      await _enterText(tester, 'Password', testPass);
      print('   ✅ Credentials entered');

      // Submit
      final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginBtn);
      await tester.pump();

      print('   🔄 Logging in...');

      // Wait for home screen
      final loggedIn = await _waitForAnyWidget(tester, [
        find.text('Welcome to Guardyn!'),
        find.byIcon(Icons.chat_bubble_outline),
        find.text('Messages'),
        find.text('Open Messages'),
        find.byType(BottomNavigationBar),
      ], timeout: const Duration(seconds: 30));

      if (loggedIn) {
        print('✅ Login successful!');
      } else {
        print('❌ Login failed');
        _debugPrintWidgets(tester);
        fail('Login did not complete');
      }
    });
  });
}

// Helper functions

Future<bool> _waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      return true;
    }
  }
  return false;
}

Future<bool> _waitForAnyWidget(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
  }
  return false;
}

Future<void> _enterText(
  WidgetTester tester,
  String fieldLabel,
  String text,
) async {
  // Try by label first
  var field = find.widgetWithText(TextField, fieldLabel);
  if (field.evaluate().isEmpty) {
    field = find.widgetWithText(TextFormField, fieldLabel);
  }
  if (field.evaluate().isEmpty) {
    // Try finding by hint text
    final allFields = find.byType(TextField);
    for (final element in allFields.evaluate()) {
      final widget = element.widget as TextField;
      if (widget.decoration?.labelText == fieldLabel ||
          widget.decoration?.hintText == fieldLabel) {
        field = find.byWidget(widget);
        break;
      }
    }
  }

  if (field.evaluate().isEmpty) {
    print('   ⚠️ Field "$fieldLabel" not found');
    return;
  }

  await tester.tap(field.first);
  await tester.pump();
  await tester.enterText(field.first, text);
  await tester.pump();
}

void _debugPrintWidgets(WidgetTester tester) {
  final scaffold = find.byType(Scaffold);
  if (scaffold.evaluate().isEmpty) {
    print('   No Scaffold found');
    return;
  }

  final texts = find.byType(Text);
  print('   Text widgets found: ${texts.evaluate().length}');
  for (final element in texts.evaluate().take(10)) {
    final widget = element.widget as Text;
    if (widget.data != null && widget.data!.isNotEmpty) {
      print('     - "${widget.data}"');
    }
  }

  final buttons = find.byType(ElevatedButton);
  print('   Buttons found: ${buttons.evaluate().length}');

  final fields = find.byType(TextField);
  print('   TextFields found: ${fields.evaluate().length}');
}

String? _getWidgetText(Element element) {
  final widget = element.widget;
  if (widget is Text) {
    return widget.data;
  }
  return null;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
