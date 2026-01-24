import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/features/media/data/datasources/media_remote_datasource.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/generated/media.pbgrpc.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGrpcClients extends Mock implements GrpcClients {}

class MockMediaServiceClient extends Mock implements MediaServiceClient {}

class MockHttpClient extends Mock implements http.Client {}

// Fake classes for mocktail
class FakeHttpRequest extends Fake implements http.Request {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockGrpcClients mockGrpcClients;
  late MockMediaServiceClient mockMediaClient;
  late MockHttpClient mockHttpClient;
  late MediaRemoteDatasource datasource;

  setUpAll(() {
    registerFallbackValue(FakeHttpRequest());
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockGrpcClients = MockGrpcClients();
    mockMediaClient = MockMediaServiceClient();
    mockHttpClient = MockHttpClient();

    when(() => mockGrpcClients.mediaClient).thenReturn(mockMediaClient);

    datasource = MediaRemoteDatasource(mockGrpcClients, mockHttpClient);
  });

  group('MediaRemoteDatasource', () {
    group('uploadToPresignedUrl', () {
      test('uploads data successfully', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value([]),
          200,
        );

        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        // Act & Assert
        await expectLater(
          datasource.uploadToPresignedUrl(
            presignedUrl: 'https://storage.example.com/upload',
            data: testData,
            mimeType: 'image/jpeg',
          ),
          completes,
        );
      });

      test('throws MediaException on HTTP error', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value('Forbidden'.codeUnits),
          403,
          contentLength: 9,
        );

        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        // Act & Assert
        expect(
          () => datasource.uploadToPresignedUrl(
            presignedUrl: 'https://storage.example.com/upload',
            data: testData,
            mimeType: 'image/jpeg',
          ),
          throwsA(isA<MediaException>().having(
            (e) => e.code,
            'code',
            'HTTP_403',
          )),
        );
      });

      test('calls progress callback on completion', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value([]),
          200,
        );

        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        double? reportedProgress;

        // Act
        await datasource.uploadToPresignedUrl(
          presignedUrl: 'https://storage.example.com/upload',
          data: testData,
          mimeType: 'image/jpeg',
          onProgress: (progress) => reportedProgress = progress,
        );

        // Assert
        expect(reportedProgress, 1.0);
      });

      test('includes custom headers when provided', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value([]),
          200,
        );

        http.BaseRequest? capturedRequest;
        when(() => mockHttpClient.send(any())).thenAnswer((invocation) {
          capturedRequest = invocation.positionalArguments[0];
          return Future.value(mockStreamedResponse);
        });

        // Act
        await datasource.uploadToPresignedUrl(
          presignedUrl: 'https://storage.example.com/upload',
          data: testData,
          mimeType: 'image/jpeg',
          headers: {'x-custom-header': 'value'},
        );

        // Assert
        expect(capturedRequest?.headers['x-custom-header'], 'value');
      });
    });

    group('downloadFromPresignedUrl', () {
      test('downloads data successfully', () async {
        // Arrange
        final testData = [1, 2, 3, 4, 5];
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value(testData),
          200,
          contentLength: 5,
        );

        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        // Act
        final result = await datasource.downloadFromPresignedUrl(
          presignedUrl: 'https://storage.example.com/download',
        );

        // Assert
        expect(result, Uint8List.fromList(testData));
      });

      test('throws MediaException on HTTP error', () async {
        // Arrange
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value([]),
          404,
        );

        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        // Act & Assert
        expect(
          () => datasource.downloadFromPresignedUrl(
            presignedUrl: 'https://storage.example.com/download',
          ),
          throwsA(isA<MediaException>().having(
            (e) => e.code,
            'code',
            'HTTP_404',
          )),
        );
      });

      test('reports download progress', () async {
        // Arrange
        final chunk1 = [1, 2, 3];
        final chunk2 = [4, 5];
        final mockStreamedResponse = http.StreamedResponse(
          Stream.fromIterable([chunk1, chunk2]),
          200,
          contentLength: 5,
        );

        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        final progressValues = <double>[];

        // Act
        await datasource.downloadFromPresignedUrl(
          presignedUrl: 'https://storage.example.com/download',
          onProgress: (progress) => progressValues.add(progress),
        );

        // Assert
        expect(progressValues, [0.6, 1.0]); // 3/5 = 0.6, 5/5 = 1.0
      });

      test('handles download without content length', () async {
        // Arrange
        final testData = [1, 2, 3];
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value(testData),
          200,
          // No content length
        );

        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        // Act
        final result = await datasource.downloadFromPresignedUrl(
          presignedUrl: 'https://storage.example.com/download',
        );

        // Assert
        expect(result, Uint8List.fromList(testData));
      });

      test('handles network exception', () async {
        // Arrange
        when(() => mockHttpClient.send(any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => datasource.downloadFromPresignedUrl(
            presignedUrl: 'https://storage.example.com/download',
          ),
          throwsA(isA<MediaException>().having(
            (e) => e.code,
            'code',
            'NETWORK_ERROR',
          )),
        );
      });
    });

    group('constructor', () {
      test('creates datasource with dependencies', () {
        // Assert
        expect(datasource, isNotNull);
      });
    });
  });
}
