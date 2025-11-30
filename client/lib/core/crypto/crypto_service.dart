/// E2EE Crypto Service for managing encryption sessions
///
/// Handles X3DH key exchange and Double Ratchet sessions
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'crypto_exceptions.dart';
import 'double_ratchet.dart';
import 'x3dh.dart';

/// Service for E2EE cryptographic operations
class CryptoService {
  static const _x3dhStateKey = 'guardyn_x3dh_state';
  static const _sessionPrefix = 'guardyn_session_';

  final FlutterSecureStorage _storage;
  X3DHProtocol? _x3dh;
  final Map<String, DoubleRatchet> _sessions = {};

  CryptoService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Initialize the crypto service
  Future<void> initialize() async {
    await _loadX3DHState();
  }

  /// Check if X3DH protocol is initialized
  bool get isInitialized => _x3dh != null;

  /// Get the identity public key
  Uint8List? get identityPublicKey => _x3dh?.identityKey.publicKey;

  /// Initialize X3DH protocol (first time setup)
  Future<void> initializeX3DH({int oneTimePreKeyCount = 100}) async {
    _x3dh = await X3DHProtocol.initialize(
      oneTimePreKeyCount: oneTimePreKeyCount,
    );
    await _saveX3DHState();
  }

  /// Export key bundle for server registration
  X3DHKeyBundle? exportKeyBundle({int? oneTimePreKeyIndex}) {
    return _x3dh?.exportKeyBundle(oneTimePreKeyIndex: oneTimePreKeyIndex);
  }

  /// Create a new session as initiator (Alice)
  Future<DoubleRatchet> createSessionAsInitiator({
    required String recipientUserId,
    required String recipientDeviceId,
    required X3DHKeyBundle remoteKeyBundle,
  }) async {
    if (_x3dh == null) {
      throw ProtocolException('X3DH not initialized');
    }

    // Perform X3DH key agreement
    final (sharedSecret, ephemeralPublicKey) =
        await X3DHProtocol.initiateKeyAgreement(
      _x3dh!.identityKey,
      remoteKeyBundle,
    );

    // Initialize Double Ratchet as Alice
    final ratchet = await DoubleRatchet.initAlice(
      sharedSecret,
      remoteKeyBundle.signedPreKey, // Bob's public key for first message
    );

    // Store session
    final sessionId = _makeSessionId(recipientUserId, recipientDeviceId);
    _sessions[sessionId] = ratchet;
    await _saveSession(sessionId, ratchet);

    return ratchet;
  }

  /// Create a new session as responder (Bob)
  Future<DoubleRatchet> createSessionAsResponder({
    required String senderUserId,
    required String senderDeviceId,
    required Uint8List remoteIdentityKey,
    required Uint8List remoteEphemeralKey,
    int? usedOneTimePreKeyId,
  }) async {
    if (_x3dh == null) {
      throw ProtocolException('X3DH not initialized');
    }

    // Complete X3DH key agreement
    final sharedSecret = await _x3dh!.completeKeyAgreement(
      remoteIdentityKey: remoteIdentityKey,
      remoteEphemeralKey: remoteEphemeralKey,
      usedOneTimePreKeyId: usedOneTimePreKeyId,
    );

    // Initialize Double Ratchet as Bob
    final ratchet = await DoubleRatchet.initBob(sharedSecret);

    // Store session
    final sessionId = _makeSessionId(senderUserId, senderDeviceId);
    _sessions[sessionId] = ratchet;
    await _saveSession(sessionId, ratchet);

    return ratchet;
  }

  /// Get or load an existing session
  Future<DoubleRatchet?> getSession({
    required String remoteUserId,
    required String remoteDeviceId,
  }) async {
    final sessionId = _makeSessionId(remoteUserId, remoteDeviceId);

    if (_sessions.containsKey(sessionId)) {
      return _sessions[sessionId];
    }

    // Try to load from storage
    final ratchet = await _loadSession(sessionId);
    if (ratchet != null) {
      _sessions[sessionId] = ratchet;
    }
    return ratchet;
  }

  /// Encrypt a message for a recipient
  Future<Uint8List> encrypt({
    required String recipientUserId,
    required String recipientDeviceId,
    required Uint8List plaintext,
    required Uint8List associatedData,
  }) async {
    final session = await getSession(
      remoteUserId: recipientUserId,
      remoteDeviceId: recipientDeviceId,
    );

    if (session == null) {
      throw ProtocolException(
        'No session found for $recipientUserId:$recipientDeviceId',
      );
    }

    final encrypted = await session.encrypt(plaintext, associatedData);
    final sessionId = _makeSessionId(recipientUserId, recipientDeviceId);
    await _saveSession(sessionId, session);

    return encrypted.toBytes();
  }

  /// Decrypt a message from a sender
  Future<Uint8List> decrypt({
    required String senderUserId,
    required String senderDeviceId,
    required Uint8List ciphertext,
    required Uint8List associatedData,
  }) async {
    final session = await getSession(
      remoteUserId: senderUserId,
      remoteDeviceId: senderDeviceId,
    );

    if (session == null) {
      throw ProtocolException(
        'No session found for $senderUserId:$senderDeviceId',
      );
    }

    final encrypted = EncryptedMessage.fromBytes(ciphertext);
    final decrypted = await session.decrypt(encrypted, associatedData);
    final sessionId = _makeSessionId(senderUserId, senderDeviceId);
    await _saveSession(sessionId, session);

    return decrypted;
  }

  /// Delete a session
  Future<void> deleteSession({
    required String remoteUserId,
    required String remoteDeviceId,
  }) async {
    final sessionId = _makeSessionId(remoteUserId, remoteDeviceId);
    _sessions.remove(sessionId);
    await _storage.delete(key: '$_sessionPrefix$sessionId');
  }

  /// Clear all crypto state (logout)
  Future<void> clearAll() async {
    _x3dh = null;
    _sessions.clear();
    await _storage.delete(key: _x3dhStateKey);
    // Delete all sessions
    final allKeys = await _storage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith(_sessionPrefix)) {
        await _storage.delete(key: key);
      }
    }
  }

  // Private methods

  String _makeSessionId(String userId, String deviceId) {
    return '$userId:$deviceId';
  }

  Future<void> _loadX3DHState() async {
    final data = await _storage.read(key: _x3dhStateKey);
    if (data != null) {
      final json = jsonDecode(data) as Map<String, dynamic>;
      _x3dh = X3DHProtocol.deserialize(json);
    }
  }

  Future<void> _saveX3DHState() async {
    if (_x3dh != null) {
      final json = jsonEncode(_x3dh!.serialize());
      await _storage.write(key: _x3dhStateKey, value: json);
    }
  }

  Future<DoubleRatchet?> _loadSession(String sessionId) async {
    final data = await _storage.read(key: '$_sessionPrefix$sessionId');
    if (data != null) {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return DoubleRatchet.deserialize(json);
    }
    return null;
  }

  Future<void> _saveSession(String sessionId, DoubleRatchet ratchet) async {
    final json = jsonEncode(ratchet.serialize());
    await _storage.write(key: '$_sessionPrefix$sessionId', value: json);
  }
}
