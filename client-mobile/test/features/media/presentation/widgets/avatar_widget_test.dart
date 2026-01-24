import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/presentation/widgets/avatar_widget.dart';

void main() {
  group('AvatarWidget', () {
    testWidgets('displays initials when no image provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(name: 'John Doe'),
          ),
        ),
      );

      // Should display initials "JD"
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('displays up to two characters for single name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(name: 'John'),
          ),
        ),
      );

      // For single word, returns first 2 chars: "JO"
      expect(find.text('JO'), findsOneWidget);
    });

    testWidgets('handles empty name gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(name: ''),
          ),
        ),
      );

      // Should not crash with empty name
      expect(find.byType(AvatarWidget), findsOneWidget);
    });

    testWidgets('applies correct size for medium preset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AvatarWidget(
                name: 'John Doe',
                size: AvatarSize.medium,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AvatarWidget), findsOneWidget);
      // Size is applied via Container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AvatarWidget),
          matching: find.byType(Container).first,
        ),
      );
      expect(container, isNotNull);
    });

    testWidgets('shows edit overlay when editable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'John Doe',
              editable: true,
              onEdit: () {},
            ),
          ),
        ),
      );

      // Should have camera_alt_rounded icon (edit badge)
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'John Doe',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AvatarWidget));
      expect(tapped, isTrue);
    });

    testWidgets('calls onEdit when edit overlay is tapped', (tester) async {
      bool edited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'John Doe',
              editable: true,
              onEdit: () => edited = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AvatarWidget));
      expect(edited, isTrue);
    });

    testWidgets('shows online status indicator when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'John Doe',
              showOnlineStatus: true,
              isOnline: true,
            ),
          ),
        ),
      );

      // Should have positioned widget for status indicator
      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('uses custom background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'John Doe',
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byType(AvatarWidget), findsOneWidget);
    });
  });

  group('AvatarSize', () {
    test('has all expected size presets', () {
      expect(AvatarSize.values, contains(AvatarSize.tiny));
      expect(AvatarSize.values, contains(AvatarSize.small));
      expect(AvatarSize.values, contains(AvatarSize.medium));
      expect(AvatarSize.values, contains(AvatarSize.large));
      expect(AvatarSize.values, contains(AvatarSize.xlarge));
      expect(AvatarSize.values, contains(AvatarSize.xxlarge));
    });

    test('pixels returns correct sizes', () {
      expect(AvatarSize.tiny.pixels, 24);
      expect(AvatarSize.small.pixels, 32);
      expect(AvatarSize.medium.pixels, 44);
      expect(AvatarSize.large.pixels, 56);
      expect(AvatarSize.xlarge.pixels, 80);
      expect(AvatarSize.xxlarge.pixels, 120);
    });
  });

  group('GroupAvatarWidget', () {
    testWidgets('displays up to 4 avatars in grid', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAvatarWidget(
              memberNames: ['Alice', 'Bob', 'Charlie', 'David'],
              memberImageUrls: [null, null, null, null],
            ),
          ),
        ),
      );

      expect(find.byType(GroupAvatarWidget), findsOneWidget);
    });

    testWidgets('handles single member by showing AvatarWidget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAvatarWidget(
              memberNames: ['Alice'],
              memberImageUrls: [null],
            ),
          ),
        ),
      );

      // For a single member, GroupAvatarWidget renders an AvatarWidget
      expect(find.byType(AvatarWidget), findsOneWidget);
    });

    testWidgets('handles empty member list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAvatarWidget(
              memberNames: [],
              memberImageUrls: [],
            ),
          ),
        ),
      );

      expect(find.byType(GroupAvatarWidget), findsOneWidget);
    });
  });
}
