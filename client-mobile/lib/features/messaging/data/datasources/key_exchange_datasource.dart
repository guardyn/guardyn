/// Datasource for fetching E2EE key bundles from auth service
library;

import 'dart:typed_data';

import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/crypto/x3dh.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:logger/logger.dart';

/// Exception thrown when key exchange operations fail
class KeyExchangeException implements Exception {
  final String message;
  final String? code;

  KeyExchangeException(this.message, {this.code});

  @override
  String toString() => 'KeyExchangeException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Datasource for fetching X3DH key bundles for E2EE session establishment
class KeyExchangeDatasource {
  final GrpcClients grpcClients;
  final Logger _logger = Logger();

  KeyExchangeDatasource(this.grpcClients);

  /// Fetch recipient's X3DH KeyBundle from server
  ///
  /// Used when initiating an E2EE session with a new contact
  Future<X3DHKeyBundle> getKeyBundle({
    required String accessToken,
    required String userId,
    String? deviceId,
  }) async {
    try {
      _logger.i('Fetching key bundle for user: $userId, device: ${deviceId ?? "any"}');

      final request = GetKeyBundleRequest()
        ..userId = userId;

      if (deviceId != null && deviceId.isNotEmpty) {
        request.deviceId = deviceId;
      }

      final response = await grpcClients.authClient.getKeyBundle(
        request,
        options: CallOptions(metadata: {'authorization': 'Bearer $accessToken'}),
      );

      if (response.hasSuccess()) {
        final success = response.success;
        final keyBundle = success.keyBundle;

        _logger.i('Successfully fetched key bundle for user: $userId, device: ${success.deviceId}');

        // Convert proto KeyBundle to X3DHKeyBundle
        return X3DHKeyBundle(
          identityKey: Uint8List.fromList(keyBundle.identityKey),
          signedPreKey: Uint8List.fromList(keyBundle.signedPreKey),
          signedPreKeySignature: Uint8List.fromList(keyBundle.signedPreKeySignature),
          signedPreKeyId: 1, // Proto doesn't include keyId, using default
          oneTimePreKey: keyBundle.oneTimePreKeys.isNotEmpty
              ? Uint8List.fromList(keyBundle.oneTimePreKeys.first)
              : null,
          oneTimePreKeyId: keyBundle.oneTimePreKeys.isNotEmpty ? 0 : null,
        );
      } else if (response.hasError()) {
        throw KeyExchangeException(
          response.error.message,
          code: response.error.code.toString(),
        );
      } else {
        throw KeyExchangeException('Unknown error fetching key bundle');
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error fetching key bundle: ${e.message}');
      throw KeyExchangeException(
        'Network error: ${e.message}',
        code: e.code.toString(),
      );
    } catch (e) {
      if (e is KeyExchangeException) rethrow;
      _logger.e('Unexpected error fetching key bundle: $e');
      throw KeyExchangeException('Failed to fetch key bundle: $e');
    }
  }

  /// Fetch key bundles for multiple devices of a user
  ///
  /// Used when a user has multiple devices to send E2EE messages to all
  Future<List<(String deviceId, X3DHKeyBundle keyBundle)>> getKeyBundlesForUser({
    required String accessToken,
    required String userId,
  }) async {
    // For MVP, we just fetch one key bundle per user
    // In production, this should enumerate all user devices
    try {
      final keyBundle = await getKeyBundle(
        accessToken: accessToken,
        userId: userId,
      );
      return [('default', keyBundle)];
    } catch (e) {
      _logger.e('Failed to fetch key bundles for user $userId: $e');
      rethrow;
    }
  }
}
