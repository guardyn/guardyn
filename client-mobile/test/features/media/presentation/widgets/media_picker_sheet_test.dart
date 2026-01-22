import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/features/media/domain/entities/media_entity.dart';
import 'package:guardyn_client/features/media/presentation/widgets/media_picker_sheet.dart';

void main() {
  group('MediaPickerSheet', () {
    testWidgets('displays all picker options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  MediaPickerSheet.show(
                    context,
                    onMediaSelected: (result) {},
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the sheet
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Verify all options are displayed with correct labels
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Record Video'), findsOneWidget);
      expect(find.text('Photo Library'), findsOneWidget);
      expect(find.text('Video Library'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
      expect(find.byIcon(Icons.insert_drive_file_rounded), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  MediaPickerSheet.show(
                    context,
                    onMediaSelected: (result) {},
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Attach Media'), findsOneWidget);
    });
  });

  group('MediaPickerResult', () {
    test('constructs correctly with all properties', () {
      const result = MediaPickerResult(
        filePath: '/path/to/file.jpg',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
        filename: 'file.jpg',
      );

      expect(result.filePath, '/path/to/file.jpg');
      expect(result.mimeType, 'image/jpeg');
      expect(result.sizeBytes, 1024);
      expect(result.filename, 'file.jpg');
      expect(result.type, MediaType.image);
    });

    test('type is image for image files', () {
      const imageResult = MediaPickerResult(
        filePath: '/path/to/file.jpg',
        type: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
        filename: 'file.jpg',
      );

      expect(imageResult.type, MediaType.image);
    });

    test('type is video for video files', () {
      const videoResult = MediaPickerResult(
        filePath: '/path/to/video.mp4',
        type: MediaType.video,
        mimeType: 'video/mp4',
        sizeBytes: 10240,
        filename: 'video.mp4',
      );

      expect(videoResult.type, MediaType.video);
    });

    test('type is document for document files', () {
      const docResult = MediaPickerResult(
        filePath: '/path/to/document.pdf',
        type: MediaType.document,
        mimeType: 'application/pdf',
        sizeBytes: 2048,
        filename: 'document.pdf',
      );

      expect(docResult.type, MediaType.document);
    });
  });
}

