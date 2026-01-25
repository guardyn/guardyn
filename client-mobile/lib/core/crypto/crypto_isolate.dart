/// Crypto Isolate - Background key generation for non-blocking UI
///
/// This module provides isolated cryptographic operations that run in
/// a separate Dart isolate using Flutter's `compute()` function,
/// preventing UI jank during key generation.
///
/// Key features:
/// - X3DH key bundle generation in background
/// - One-time pre-key batch generation
/// - Uses Flutter's compute() for isolate-safe operation
/// - Compatible with pinenacl for cryptographic operations
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pinenacl/ed25519.dart' as nacl_ed;
import 'package:pinenacl/x25519.dart' as nacl_x;

/// Result of X3DH key bundle generation
class KeyBundleResult {
  /// Identity key (Ed25519)
  final Uint8List identityPublicKey;
  final Uint8List identityPrivateKey;

  /// Signed pre-key (X25519)
  final Uint8List signedPreKeyPublic;
  final Uint8List signedPreKeyPrivate;
  final Uint8List signedPreKeySignature;
  final int signedPreKeyId;

  /// One-time pre-keys (X25519)
  final List<OneTimePreKeyData> oneTimePreKeys;

  const KeyBundleResult({
    required this.identityPublicKey,
    required this.identityPrivateKey,
    required this.signedPreKeyPublic,
    required this.signedPreKeyPrivate,
    required this.signedPreKeySignature,
    required this.signedPreKeyId,
    required this.oneTimePreKeys,
  });

  Map<String, dynamic> toJson() => {
    'identityPublicKey': base64Encode(identityPublicKey),
    'identityPrivateKey': base64Encode(identityPrivateKey),
    'signedPreKeyPublic': base64Encode(signedPreKeyPublic),
    'signedPreKeyPrivate': base64Encode(signedPreKeyPrivate),
    'signedPreKeySignature': base64Encode(signedPreKeySignature),
    'signedPreKeyId': signedPreKeyId,
    'oneTimePreKeys': oneTimePreKeys.map((k) => k.toJson()).toList(),
  };

  factory KeyBundleResult.fromJson(Map<String, dynamic> json) {
    return KeyBundleResult(
      identityPublicKey: base64Decode(json['identityPublicKey'] as String),
      identityPrivateKey: base64Decode(json['identityPrivateKey'] as String),
      signedPreKeyPublic: base64Decode(json['signedPreKeyPublic'] as String),
      signedPreKeyPrivate: base64Decode(json['signedPreKeyPrivate'] as String),
      signedPreKeySignature: base64Decode(json['signedPreKeySignature'] as String),
      signedPreKeyId: json['signedPreKeyId'] as int,
      oneTimePreKeys: (json['oneTimePreKeys'] as List)
          .map((k) => OneTimePreKeyData.fromJson(k as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// One-time pre-key data
class OneTimePreKeyData {
  final Uint8List publicKey;
  final Uint8List privateKey;
  final int keyId;

  const OneTimePreKeyData({
    required this.publicKey,
    required this.privateKey,
    required this.keyId,
  });

  Map<String, dynamic> toJson() => {
    'publicKey': base64Encode(publicKey),
    'privateKey': base64Encode(privateKey),
    'keyId': keyId,
  };

  factory OneTimePreKeyData.fromJson(Map<String, dynamic> json) {
    return OneTimePreKeyData(
      publicKey: base64Decode(json['publicKey'] as String),
      privateKey: base64Decode(json['privateKey'] as String),
      keyId: json['keyId'] as int,
    );
  }
}

/// Progress callback for key generation
typedef KeyGenerationProgressCallback = void Function(int current, int total);

/// Parameters for key bundle generation in isolate
class _KeyBundleParams {
  final int oneTimePreKeyCount;

  const _KeyBundleParams({required this.oneTimePreKeyCount});
}

/// Parameters for one-time pre-key generation in isolate
class _OneTimePreKeyParams {
  final int count;
  final int startKeyId;

  const _OneTimePreKeyParams({
    required this.count,
    required this.startKeyId,
  });
}

/// Manager for crypto isolate operations
///
/// Provides a high-level API for running cryptographic operations
/// in a background isolate without blocking the main thread.
class CryptoIsolateManager {
  /// Singleton instance
  static final CryptoIsolateManager _instance = CryptoIsolateManager._();
  static CryptoIsolateManager get instance => _instance;

  CryptoIsolateManager._();

  /// Generate X3DH key bundle in background isolate
  ///
  /// Uses Flutter's compute() for isolate-safe operation.
  /// This method is NON-BLOCKING and runs in a separate isolate.
  Future<KeyBundleResult> generateKeyBundle({
    int oneTimePreKeyCount = 1,
    KeyGenerationProgressCallback? onProgress,
  }) async {
    debugPrint('🔐 CryptoIsolateManager: starting key bundle generation');
    final stopwatch = Stopwatch()..start();

    // Use compute() for isolate-safe operation
    final result = await compute(
      _generateKeyBundleInIsolate,
      _KeyBundleParams(oneTimePreKeyCount: oneTimePreKeyCount),
    );

    stopwatch.stop();
    debugPrint('🔐 CryptoIsolateManager: key bundle generated in ${stopwatch.elapsedMilliseconds}ms');

    return result;
  }

  /// Generate additional one-time pre-keys in background isolate
  ///
  /// Use this to replenish keys after successful authentication.
  Future<List<OneTimePreKeyData>> generateOneTimePreKeys({
    required int count,
    required int startKeyId,
    KeyGenerationProgressCallback? onProgress,
  }) async {
    debugPrint('🔐 CryptoIsolateManager: generating $count one-time pre-keys');
    final stopwatch = Stopwatch()..start();

    // Use compute() for isolate-safe operation
    final result = await compute(
      _generateOneTimePreKeysInIsolate,
      _OneTimePreKeyParams(count: count, startKeyId: startKeyId),
    );

    stopwatch.stop();
    debugPrint('🔐 CryptoIsolateManager: generated ${result.length} keys in ${stopwatch.elapsedMilliseconds}ms');

    return result;
  }
}

/// Generate key bundle in isolate (top-level function for compute())
///
/// Uses pinenacl for Ed25519/X25519 cryptographic operations.
KeyBundleResult _generateKeyBundleInIsolate(_KeyBundleParams params) {
  // 1. Generate identity key (Ed25519)
  final signingKey = nacl_ed.SigningKey.generate();

  // 2. Generate signed pre-key (X25519) and sign it
  final signedPreKeyPair = nacl_x.PrivateKey.generate();
  final signedPreKeyPublic = Uint8List.fromList(signedPreKeyPair.publicKey.toList());
  final signature = signingKey.sign(signedPreKeyPublic).signature;

  // 3. Generate one-time pre-keys
  final oneTimePreKeys = <OneTimePreKeyData>[];
  for (int i = 0; i < params.oneTimePreKeyCount; i++) {
    final keyPair = nacl_x.PrivateKey.generate();
    oneTimePreKeys.add(OneTimePreKeyData(
      publicKey: Uint8List.fromList(keyPair.publicKey.toList()),
      privateKey: Uint8List.fromList(keyPair.toList()),
      keyId: i,
    ));
  }

  return KeyBundleResult(
    identityPublicKey: Uint8List.fromList(signingKey.verifyKey.toList()),
    identityPrivateKey: Uint8List.fromList(signingKey.seed.toList()),
    signedPreKeyPublic: signedPreKeyPublic,
    signedPreKeyPrivate: Uint8List.fromList(signedPreKeyPair.toList()),
    signedPreKeySignature: Uint8List.fromList(signature.toList()),
    signedPreKeyId: 1,
    oneTimePreKeys: oneTimePreKeys,
  );
}

/// Generate one-time pre-keys in isolate (top-level function for compute())
///
/// Uses pinenacl for X25519 key generation.
List<OneTimePreKeyData> _generateOneTimePreKeysInIsolate(_OneTimePreKeyParams params) {
  final keys = <OneTimePreKeyData>[];

  for (int i = 0; i < params.count; i++) {
    final keyPair = nacl_x.PrivateKey.generate();
    keys.add(OneTimePreKeyData(
      publicKey: Uint8List.fromList(keyPair.publicKey.toList()),
      privateKey: Uint8List.fromList(keyPair.toList()),
      keyId: params.startKeyId + i,
    ));
  }

  return keys;
}
