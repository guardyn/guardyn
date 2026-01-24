import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/shared/widgets/e2ee_indicator.dart';

void main() {
  group('E2EEIndicator', () {
    testWidgets('shows lock icon for encrypted status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: E2EEIndicator(status: E2EEStatus.encrypted),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('E2EE'), findsOneWidget);
    });

    testWidgets('shows enhanced_encryption icon for MLS encrypted status',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: E2EEIndicator(status: E2EEStatus.mlsEncrypted),
          ),
        ),
      );

      expect(find.byIcon(Icons.enhanced_encryption), findsOneWidget);
      expect(find.text('MLS'), findsOneWidget);
    });

    testWidgets('shows lock_open icon for not encrypted status',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: E2EEIndicator(status: E2EEStatus.notEncrypted),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.text('Not secure'), findsOneWidget);
    });

    testWidgets('shows hourglass_empty icon for verifying status',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: E2EEIndicator(status: E2EEStatus.verifying),
          ),
        ),
      );

      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.text('Verifying...'), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: E2EEIndicator(
              status: E2EEStatus.mlsEncrypted,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.enhanced_encryption), findsOneWidget);
      expect(find.text('MLS'), findsNothing);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: E2EEIndicator(
              status: E2EEStatus.mlsEncrypted,
              size: 24,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.enhanced_encryption));
      expect(icon.size, equals(24));
    });

    testWidgets('shows tooltip on long press', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: E2EEIndicator(status: E2EEStatus.mlsEncrypted),
            ),
          ),
        ),
      );

      // Find the tooltip
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      // Long press to show tooltip
      await tester.longPress(find.byIcon(Icons.enhanced_encryption));
      await tester.pump(const Duration(seconds: 1));

      // Verify tooltip message is correct
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message,
          'Group messages are end-to-end encrypted using MLS (RFC 9420)');
    });

    testWidgets('all status types have unique tooltips', (tester) async {
      final tooltips = <String>{};

      for (final status in E2EEStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: E2EEIndicator(status: status),
            ),
          ),
        );

        final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
        tooltips.add(tooltip.message!);
      }

      // Each status should have a unique tooltip
      expect(tooltips.length, equals(E2EEStatus.values.length));
    });
  });
}
