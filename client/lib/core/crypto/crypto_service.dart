/// E2EE Crypto Service for managing encryption sessions
///
/// Handles X3DH key exchange and Double Ratchet sessions
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'crypto_exceptions.dart';
import 'double_ratchet.dart';
import 'x3dh.dart';

/// Configuration for one-time pre-key management
class OneTimePreKeyConfig {
  /// Number of keys to generate on initial registration (fast startup)
  static const int initialKeyCount = 5;

  /// Target number of keys to maintain on server
  static const int targetKeyCount = 100;

  /// Threshold below which to trigger replenishment
  static const int replenishThreshold = 20;

  /// Number of keys to generate in each background batch
  static const int batchSize = 20;
}

/// Service for E2EE cryptographic operations
class CryptoService {
  static const _x3dhStateKey = 'guardyn_x3dh_state';
  static const _sessionPrefix = 'guardyn_session_';

  final FlutterSecureStorage _storage;
  X3DHProtocol? _x3dh;
  final Map<String, DoubleRatchet> _sessions = {};

  /// Flag to prevent multiple simultaneous replenishment operations
  bool _isReplenishing = false;

  CryptoService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Initialize the crypto service
  Future<void> initialize() async {
    // ignore: avoid_print
    print('🔐 CryptoService.initialize() called');
    await _loadX3DHState();
    // ignore: avoid_print
    print(
      '🔐 CryptoService after _loadX3DHState: isInitialized=$isInitialized',
    );
  }

  /// Check if X3DH protocol is initialized
  bool get isInitialized => _x3dh != null;

  /// Get the identity public key
  Uint8List? get identityPublicKey => _x3dh?.identityKey.publicKey;

  /// Initialize X3DH protocol (first time setup)
  /// Uses minimal keys for fast startup, replenish in background after login
  Future<void> initializeX3DH({int? oneTimePreKeyCount}) async {
    final keyCount = oneTimePreKeyCount ?? OneTimePreKeyConfig.initialKeyCount;
    debugPrint(
      '🔐 CryptoService.initializeX3DH: generating $keyCount one-time pre-keys',
    );

    _x3dh = await X3DHProtocol.initialize(oneTimePreKeyCount: keyCount);
    await _saveX3DHState();

    debugPrint('🔐 CryptoService.initializeX3DH: complete');
  }

  /// Get current number of available one-time pre-keys
  int get availableOneTimePreKeyCount => _x3dh?.oneTimePreKeys.length ?? 0;

  /// Check if one-time pre-keys need replenishment
  bool get needsKeyReplenishment =>
      availableOneTimePreKeyCount < OneTimePreKeyConfig.replenishThreshold;

  /// Replenish one-time pre-keys in background
  ///
  /// Call this after successful login to ensure sufficient keys are available.
  /// Returns the list of new public keys to upload to server.
  Future<List<Uint8List>> replenishOneTimePreKeysInBackground({
    int? targetCount,
  }) async {
    if (_x3dh == null) {
      debugPrint('🔐 replenishOneTimePreKeys: X3DH not initialized');
      return [];
    }

    if (_isReplenishing) {
      debugPrint('🔐 replenishOneTimePreKeys: already in progress');
      return [];
    }

    final target = targetCount ?? OneTimePreKeyConfig.targetKeyCount;
    final currentCount = availableOneTimePreKeyCount;

    if (currentCount >= target) {
      debugPrint(
        '🔐 replenishOneTimePreKeys: already have $currentCount keys (target: $target)',
      );
      return [];
    }

    _isReplenishing = true;
    final newPublicKeys = <Uint8List>[];

    try {
      final keysToGenerate = target - currentCount;
      debugPrint(
        '🔐 replenishOneTimePreKeys: generating $keysToGenerate new keys',
      );

      // Generate in batches to keep UI responsive
      // Use 0-based keyId to match server storage
      final startId = _x3dh!.oneTimePreKeys.isEmpty
          ? 0
          : _x3dh!.oneTimePreKeys
                    .map((k) => k.keyId)
                    .reduce((a, b) => a > b ? a : b) +
                1;

      for (int i = 0; i < keysToGenerate; i++) {
        final newKey = await OneTimePreKey.generate(startId + i);
        _x3dh!.oneTimePreKeys.add(newKey);
        newPublicKeys.add(newKey.publicKey);

        // Yield to UI every batch
        if (i % OneTimePreKeyConfig.batchSize == 0 && i > 0) {
          await Future<void>.delayed(Duration.zero);
          debugPrint(
            '🔐 replenishOneTimePreKeys: generated ${i + 1}/$keysToGenerate keys',
          );
        }
      }

      // Save updated state
      await _saveX3DHState();
      debugPrint(
        '🔐 replenishOneTimePreKeys: complete, now have $availableOneTimePreKeyCount keys',
      );
    } finally {
      _isReplenishing = false;
    }

    return newPublicKeys;
  }

  /// Handle server notification about remaining key count
  ///
  /// Call this when server reports remaining one-time pre-key count.
  /// If below threshold, triggers background replenishment.
  Future<List<Uint8List>> handleServerKeyCountNotification(
    int remainingCount,
  ) async {
    debugPrint('🔐 Server reports $remainingCount one-time pre-keys remaining');

    if (remainingCount < OneTimePreKeyConfig.replenishThreshold) {
      debugPrint(
        '🔐 Below threshold (${OneTimePreKeyConfig.replenishThreshold}), triggering replenishment',
      );
      return replenishOneTimePreKeysInBackground();
    }

    return [];
  }

  /// Export multiple key bundles for batch upload to server
  List<X3DHKeyBundle> exportKeyBundles({int count = 1}) {
    if (_x3dh == null) return [];

    final bundles = <X3DHKeyBundle>[];
    final availableCount = _x3dh!.oneTimePreKeys.length;
    final exportCount = count.clamp(0, availableCount);

    for (int i = 0; i < exportCount; i++) {
      bundles.add(_x3dh!.exportKeyBundle(oneTimePreKeyIndex: i));
    }

    return bundles;
  }

  /// Export key bundle for server registration
  X3DHKeyBundle? exportKeyBundle({int? oneTimePreKeyIndex}) {
    return _x3dh?.exportKeyBundle(oneTimePreKeyIndex: oneTimePreKeyIndex);
  }

  /// X3DH prekey data to include in first message
  /// Key: sessionId, Value: X3DHPrekeyMessage
  final Map<String, X3DHPrekeyMessage> _pendingPrekeyMessages = {};

  /// Create a new session as initiator (Alice)
  /// Returns the ratchet and X3DH prekey data to include in first message
  Future<(DoubleRatchet, X3DHPrekeyMessage)> createSessionAsInitiator({
    required String recipientUserId,
    required String recipientDeviceId,
    required X3DHKeyBundle remoteKeyBundle,
  }) async {
    if (_x3dh == null) {
      throw ProtocolException('X3DH not initialized');
    }

    // Perform X3DH key agreement
    final (
      sharedSecret,
      ephemeralPublicKey,
    ) = await X3DHProtocol.initiateKeyAgreement(
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

    // Create X3DH prekey message data
    final prekeyMessage = X3DHPrekeyMessage(
      senderIdentityKey: _x3dh!.identityKey.publicKey,
      ephemeralKey: ephemeralPublicKey,
      usedOneTimePreKeyId: remoteKeyBundle.oneTimePreKeyId,
    );

    // Store for first message
    _pendingPrekeyMessages[sessionId] = prekeyMessage;

    return (ratchet, prekeyMessage);
  }

  /// Get pending X3DH prekey message for a session (for first message)
  X3DHPrekeyMessage? getPendingPrekeyMessage({
    required String remoteUserId,
    required String remoteDeviceId,
  }) {
    final sessionId = _makeSessionId(remoteUserId, remoteDeviceId);
    return _pendingPrekeyMessages.remove(sessionId);
  }

  /// Check if this is a new session (first message needs prekey data)
  bool isNewSession({
    required String remoteUserId,
    required String remoteDeviceId,
  }) {
    final sessionId = _makeSessionId(remoteUserId, remoteDeviceId);
    return _pendingPrekeyMessages.containsKey(sessionId);
  }

  /// Create a new session as responder (Bob)
  /// 
  /// NOTE: Session is NOT saved to persistent storage here!
  /// This is intentional: the responder session starts without a sending chain key.
  /// The sending chain key is established during the first decrypt() call when
  /// the DH ratchet is performed. Only after successful decrypt() the session
  /// is saved with a valid sending chain key.
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

    // Store session in memory ONLY (not in persistent storage)
    // Session will be saved after successful decrypt() which performs DH ratchet
    // and establishes the sending chain key
    final sessionId = _makeSessionId(senderUserId, senderDeviceId);
    _sessions[sessionId] = ratchet;
    // ignore: avoid_print
    print(
      '🔐 createSessionAsResponder: session created in memory (NOT saved to storage yet)',
    );

    return ratchet;
  }

  /// Get or load an existing session
  Future<DoubleRatchet?> getSession({
    required String remoteUserId,
    required String remoteDeviceId,
  }) async {
    final sessionId = _makeSessionId(remoteUserId, remoteDeviceId);
    // ignore: avoid_print
    print('🔐 CryptoService.getSession: sessionId=$sessionId');

    if (_sessions.containsKey(sessionId)) {
      final cachedSession = _sessions[sessionId]!;
      // Check if session is valid for encryption
      if (!cachedSession.isFullyEstablished) {
        // ignore: avoid_print
        print(
          '🔐 CryptoService.getSession: cached session has no sending chain key, keeping for decrypt',
        );
      }
      // ignore: avoid_print
      print('🔐 CryptoService.getSession: found in memory cache');
      return cachedSession;
    }

    // Try to load from storage
    final ratchet = await _loadSession(sessionId);
    if (ratchet != null) {
      // Check if loaded session has sending chain key
      // Sessions without sending chain key were saved incorrectly (bug fix)
      // They should be discarded so a new X3DH exchange can happen
      if (!ratchet.isFullyEstablished) {
        // ignore: avoid_print
        print(
          '🔐 CryptoService.getSession: loaded session has no sending chain key - deleting corrupted session',
        );
        await _storage.delete(key: '$_sessionPrefix$sessionId');
        return null;
      }
      // ignore: avoid_print
      print('🔐 CryptoService.getSession: loaded from storage');
      _sessions[sessionId] = ratchet;
      return ratchet;
    } else {
      // ignore: avoid_print
      print('🔐 CryptoService.getSession: not found');
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
    // ignore: avoid_print
    print('🔐 CryptoService.deleteSession: deleted session $sessionId');
  }

  /// Clear all sessions (for testing new key exchange)
  Future<void> clearAllSessions() async {
    // ignore: avoid_print
    print('🔐 CryptoService.clearAllSessions: clearing all sessions');
    _sessions.clear();
    _pendingPrekeyMessages.clear();
    // Delete all sessions from storage
    final allKeys = await _storage.readAll();
    int count = 0;
    for (final key in allKeys.keys) {
      if (key.startsWith(_sessionPrefix)) {
        await _storage.delete(key: key);
        count++;
      }
    }
    // ignore: avoid_print
    print('🔐 CryptoService.clearAllSessions: deleted $count sessions');
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
