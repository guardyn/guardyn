/// E2EE Crypto Service for managing encryption sessions
///
/// Handles X3DH key exchange and Double Ratchet sessions
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../generated/rust/api.dart' as rust_api;
import 'crypto_exceptions.dart';
import 'crypto_isolate.dart';
import 'crypto_primitives.dart';
import 'double_ratchet.dart';
import 'padme.dart' as padme;
import 'x3dh.dart';

/// Configuration for one-time pre-key management
class OneTimePreKeyConfig {
  /// Number of keys to generate on initial registration (fast startup)
  /// Set to 1 for instant login - more keys are generated in background
  static const int initialKeyCount = 1;

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

  /// The 64-byte `(d || z)` seed this device's ML-KEM-768 pre-key is regenerated from.
  ///
  /// The keypair itself is never stored. FIPS 203 defines key generation as
  /// `ML-KEM.KeyGen_internal(d, z)` over this seed, so it is the specified compact private-key
  /// form rather than a trick to save space - and the 2400-byte decapsulation key it expands to
  /// never crosses the FFI boundary at all. `client-desktop` persists the same 64 bytes under
  /// its own `ml_kem_seed` key (`services/secure_storage.rs`); this is the mobile counterpart.
  ///
  /// Stored base64 rather than desktop's hex, matching how every other secret in this file is
  /// encoded. The value never crosses a client boundary, so the two encodings cannot disagree
  /// about anything that matters.
  static const _mlKemSeedKey = 'guardyn_ml_kem_seed';

  /// Bytes in an ML-KEM seed, per FIPS 203. Mirrors `pqxdh::MLKEM_SEED_SIZE`.
  static const _mlKemSeedLength = 64;

  final FlutterSecureStorage _storage;
  X3DHProtocol? _x3dh;
  final Map<String, DoubleRatchet> _sessions = {};

  /// Flag to prevent multiple simultaneous replenishment operations
  bool _isReplenishing = false;
  
  /// Completer for pending key bundle generation (non-blocking)
  Completer<X3DHKeyBundle>? _pendingKeyBundle;

  CryptoService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Initialize the crypto service
  ///
  /// This initializes the underlying CryptoPrimitives (Rust FFI on mobile/desktop,
  /// Dart on web) and loads any previously saved X3DH state from secure storage.
  Future<void> initialize() async {
    // ignore: avoid_print
    print('🔐 CryptoService.initialize() called');

    // Initialize CryptoPrimitives (Rust FFI) FIRST before any crypto operations
    if (!CryptoPrimitives.isInitialized) {
      debugPrint('🔐 CryptoService: initializing CryptoPrimitives...');
      await CryptoPrimitives.initialize();
      debugPrint(
        '🔐 CryptoService: CryptoPrimitives initialized, '
        'native=${CryptoPrimitives.isNativeAvailable}, '
        'pq=${CryptoPrimitives.isPostQuantumAvailable}',
      );
    }

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
  
  // =========================================================================
  // FAST ASYNC KEY GENERATION (Isolate-based)
  // =========================================================================

  /// Generate X3DH key bundle asynchronously in background isolate
  /// 
  /// This method is NON-BLOCKING and returns immediately.
  /// Keys are generated in a separate Dart isolate.
  /// 
  /// Returns a Future that completes when keys are ready.
  Future<X3DHKeyBundle> generateKeyBundleAsync({
    int oneTimePreKeyCount = 1,
  }) async {
    // If already initialized, return existing bundle immediately
    if (isInitialized) {
      final bundle = exportKeyBundle(oneTimePreKeyIndex: 0);
      if (bundle != null) {
        debugPrint('🔐 generateKeyBundleAsync: using existing keys');
        return bundle;
      }
    }
    
    // If generation is already in progress, wait for it
    if (_pendingKeyBundle != null && !_pendingKeyBundle!.isCompleted) {
      debugPrint('🔐 generateKeyBundleAsync: waiting for pending generation');
      return _pendingKeyBundle!.future;
    }
    
    _pendingKeyBundle = Completer<X3DHKeyBundle>();
    
    debugPrint('🔐 generateKeyBundleAsync: starting isolate generation');
    final stopwatch = Stopwatch()..start();
    
    try {
      // Generate keys in background isolate
      final result = await CryptoIsolateManager.instance.generateKeyBundle(
        oneTimePreKeyCount: oneTimePreKeyCount,
        onProgress: (current, total) {
          debugPrint('🔐 Key generation progress: $current/$total');
        },
      );
      
      stopwatch.stop();
      debugPrint('🔐 generateKeyBundleAsync: isolate completed in ${stopwatch.elapsedMilliseconds}ms');
      
      // Convert isolate result to X3DHProtocol
      _x3dh = X3DHProtocol(
        identityKey: IdentityKeyPair.fromBytes(
          privateKey: result.identityPrivateKey,
          publicKey: result.identityPublicKey,
        ),
        signedPreKey: SignedPreKey(
          privateKey: result.signedPreKeyPrivate,
          publicKey: result.signedPreKeyPublic,
          signature: result.signedPreKeySignature,
          keyId: result.signedPreKeyId,
        ),
        oneTimePreKeys: result.oneTimePreKeys.map((k) => OneTimePreKey(
          privateKey: k.privateKey,
          publicKey: k.publicKey,
          keyId: k.keyId,
        )).toList(),
      );
      
      // Save to secure storage
      await _saveX3DHState();
      // See initializeX3DH: one seed per device, persisted before anything reads it.
      await _loadOrCreateMlKemSeed();

      final bundle = exportKeyBundle(oneTimePreKeyIndex: 0)!;
      _pendingKeyBundle!.complete(bundle);
      
      return bundle;
    } catch (e, stack) {
      debugPrint('🔐 generateKeyBundleAsync error: $e\n$stack');
      _pendingKeyBundle!.completeError(e);
      rethrow;
    }
  }
  
  /// Replenish one-time pre-keys in background isolate
  /// 
  /// This is truly non-blocking and runs in a separate isolate.
  Future<List<Uint8List>> replenishOneTimePreKeysInIsolate({
    int? targetCount,
  }) async {
    if (_x3dh == null) {
      debugPrint('🔐 replenishInIsolate: X3DH not initialized');
      return [];
    }

    if (_isReplenishing) {
      debugPrint('🔐 replenishInIsolate: already in progress');
      return [];
    }

    final target = targetCount ?? OneTimePreKeyConfig.targetKeyCount;
    final currentCount = availableOneTimePreKeyCount;

    if (currentCount >= target) {
      debugPrint(
        '🔐 replenishInIsolate: already have $currentCount keys (target: $target)',
      );
      return [];
    }

    _isReplenishing = true;
    final stopwatch = Stopwatch()..start();
    
    try {
      final keysToGenerate = target - currentCount;
      final startKeyId = _x3dh!.oneTimePreKeys.isEmpty
          ? 0
          : _x3dh!.oneTimePreKeys
                    .map((k) => k.keyId)
                    .reduce((a, b) => a > b ? a : b) +
                1;
      
      debugPrint('🔐 replenishInIsolate: generating $keysToGenerate keys in isolate');
      
      // Generate in background isolate
      final newKeys = await CryptoIsolateManager.instance.generateOneTimePreKeys(
        count: keysToGenerate,
        startKeyId: startKeyId,
        onProgress: (current, total) {
          if (current % 20 == 0 || current == total) {
            debugPrint('🔐 Replenish progress: $current/$total');
          }
        },
      );
      
      // Add to X3DH protocol
      for (final keyData in newKeys) {
        _x3dh!.oneTimePreKeys.add(OneTimePreKey(
          privateKey: keyData.privateKey,
          publicKey: keyData.publicKey,
          keyId: keyData.keyId,
        ));
      }
      
      // Save updated state
      await _saveX3DHState();
      
      stopwatch.stop();
      debugPrint(
        '🔐 replenishInIsolate: complete in ${stopwatch.elapsedMilliseconds}ms, '
        'now have $availableOneTimePreKeyCount keys',
      );
      
      return newKeys.map((k) => k.publicKey).toList();
    } finally {
      _isReplenishing = false;
    }
  }

  /// Initialize X3DH protocol (first time setup)
  /// Uses minimal keys for fast startup, replenish in background after login
  Future<void> initializeX3DH({int? oneTimePreKeyCount}) async {
    final keyCount = oneTimePreKeyCount ?? OneTimePreKeyConfig.initialKeyCount;
    debugPrint(
      '🔐 CryptoService.initializeX3DH: generating $keyCount one-time pre-keys',
    );

    _x3dh = await X3DHProtocol.initialize(oneTimePreKeyCount: keyCount);
    await _saveX3DHState();
    // Minted alongside the classical pre-keys so the device has one before anything needs it.
    // PR-98c is what publishes the encapsulation key it stands for; until then it is only read
    // back by the responder path.
    await _loadOrCreateMlKemSeed();

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
    Uint8List? pqCiphertext,
  }) async {
    if (_x3dh == null) {
      throw ProtocolException('X3DH not initialized');
    }

    // The `0x02` flags bit of the prekey message is the whole of the negotiation: an initiator
    // sets it exactly when the bundle it fetched carried an ML-KEM pre-key, and its presence is
    // what selects the hybrid KDF here. The two derivations use different HKDF `info` strings -
    // `X3DH` and `PQXDH_SharedSecret` - so they are separate domains over the same DH inputs,
    // and answering under the wrong one yields a secret that differs from the initiator's. See
    // docs/adr/ADR-0005-hybrid-pqxdh.md and SRS rules 4b and 4c.
    final Uint8List sharedSecret;
    if (pqCiphertext != null) {
      sharedSecret = await _completeHybridKeyAgreement(
        remoteIdentityKey: remoteIdentityKey,
        remoteEphemeralKey: remoteEphemeralKey,
        usedOneTimePreKeyId: usedOneTimePreKeyId,
        pqCiphertext: pqCiphertext,
      );
    } else {
      // Classical X3DH. Classical strength is the floor, so a peer with no ML-KEM pre-key still
      // establishes a session; this path is unchanged.
      sharedSecret = await _x3dh!.completeKeyAgreement(
        remoteIdentityKey: remoteIdentityKey,
        remoteEphemeralKey: remoteEphemeralKey,
        usedOneTimePreKeyId: usedOneTimePreKeyId,
      );
    }

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

    // PADME first, then the ratchet: the padding must be inside the AEAD, or an observer
    // reads the true plaintext length straight off the ciphertext. This mirrors the desktop
    // pipeline (client-desktop/src-tauri/src/commands/crypto.rs), which pads before
    // encrypting and unpads after decrypting.
    final padded = padme.padMessage(plaintext);
    final encrypted = await session.encrypt(padded, associatedData);
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
    final padded = await session.decrypt(encrypted, associatedData);
    final sessionId = _makeSessionId(senderUserId, senderDeviceId);
    await _saveSession(sessionId, session);

    return padme.unpadMessage(padded);
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
    // The ML-KEM seed is device key material like any other pre-key secret, and a seed that
    // outlived its identity would let a re-registered device answer handshakes addressed to
    // the encapsulation key the previous one published.
    await _storage.delete(key: _mlKemSeedKey);
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

  /// Answer a hybrid PQXDH handshake as the responder.
  ///
  /// Everything cryptographic happens inside Rust: the same four Diffie-Hellman operations the
  /// classical path performs, plus ML-KEM decapsulation, mixed into one HKDF with the
  /// `PQXDH_SharedSecret` info string. The 2400-byte decapsulation key is derived from the seed
  /// on the far side of the FFI boundary and never reaches Dart.
  ///
  /// The asymmetric shapes - a ciphertext this device cannot open, or a seed with no ciphertext
  /// - are refused by `pqxdh::derive_recipient_shared_secret` before any DH runs, and that
  /// refusal is deliberately not re-implemented here. What this method must not do is swallow
  /// it: degrading to the classical halves would yield a secret that merely *differs*, and the
  /// disagreement would surface later as an AEAD tag rejection blamed on the wrong thing.
  Future<Uint8List> _completeHybridKeyAgreement({
    required Uint8List remoteIdentityKey,
    required Uint8List remoteEphemeralKey,
    required int? usedOneTimePreKeyId,
    required Uint8List pqCiphertext,
  }) async {
    final seed = await _storedMlKemSeed();
    final x3dh = _x3dh!;

    // The initiator names the one-time key it used. Answering with a different one - or with
    // none - derives a different secret, so a key this device does not hold is a hard failure
    // rather than a silent drop to the three-DH variant.
    Uint8List? oneTimePreKeySecret;
    if (usedOneTimePreKeyId != null) {
      final otpk = x3dh.oneTimePreKeys.firstWhere(
        (k) => k.keyId == usedOneTimePreKeyId,
        orElse: () => throw ProtocolException(
          'One-time pre-key $usedOneTimePreKeyId is not held by this device, '
          'so the handshake it was used in cannot be answered',
        ),
      );
      oneTimePreKeySecret = otpk.privateKey;
    }

    try {
      // The Ed25519 SEED, not its X25519 form: the conversion happens inside Rust, and handing
      // it a pre-converted key derives a secret the initiator never matches.
      return rust_api.cryptoDeriveRecipientSharedSecret(
        identitySeed: x3dh.identityKey.privateKey,
        signedPrekeySecret: x3dh.signedPreKey.privateKey,
        oneTimePrekeySecret: oneTimePreKeySecret,
        mlKemSeed: seed,
        senderIdentityKey: remoteIdentityKey,
        senderEphemeralKey: remoteEphemeralKey,
        pqCiphertext: pqCiphertext,
      );
    } on CryptoException {
      rethrow;
    } catch (e) {
      // AnyhowException from the bridge, or a missing native library. Either way the handshake
      // is unanswerable - it must not fall through to the classical derivation.
      throw ProtocolException('Hybrid PQXDH respond failed: $e');
    }
  }

  /// Decode a stored ML-KEM seed.
  ///
  /// Shared by the create-on-demand path and the read-only one, so the two cannot disagree
  /// about what a valid seed is.
  Uint8List _decodeMlKemSeed(String encoded) {
    final Uint8List bytes;
    try {
      bytes = base64Decode(encoded);
    } on FormatException {
      throw const InvalidKeyException('Stored ML-KEM seed is not valid base64');
    }
    if (bytes.length != _mlKemSeedLength) {
      throw InvalidKeyException(
        'Stored ML-KEM seed is ${bytes.length} bytes, expected $_mlKemSeedLength',
      );
    }
    return bytes;
  }

  /// This device's ML-KEM seed, creating and persisting one the first time.
  ///
  /// Persisted before it is returned, not after: a seed used to publish an encapsulation key
  /// that then fails to store leaves the server advertising a key this device can never
  /// decapsulate to, which is worse than having published nothing.
  ///
  /// Minting needs the native library - `randomBytes` is deliberately not on the [CryptoBridge]
  /// interface, and a seed is key material that belongs to the Rust CSPRNG rather than Dart's.
  /// Without it this returns `null` instead of throwing: a build with no FFI cannot do
  /// post-quantum anything, and failing here would take key-bundle generation down with it.
  /// Nothing degrades silently as a result - [_storedMlKemSeed] still refuses to answer a
  /// hybrid handshake this device holds no key for.
  Future<Uint8List?> _loadOrCreateMlKemSeed() async {
    final existing = await _storage.read(key: _mlKemSeedKey);
    if (existing != null) {
      return _decodeMlKemSeed(existing);
    }

    if (!CryptoPrimitives.isNativeAvailable) {
      debugPrint(
        '🔐 ML-KEM seed not generated: native crypto unavailable. '
        'This device cannot answer a hybrid handshake.',
      );
      return null;
    }

    final seed = rust_api.cryptoRandomBytes(length: _mlKemSeedLength);
    await _storage.write(key: _mlKemSeedKey, value: base64Encode(seed));
    debugPrint('🔐 Generated a new ML-KEM pre-key seed');
    return seed;
  }

  /// This device's ML-KEM seed, throwing when it has never been generated.
  ///
  /// A responder must **not** fall back to creating one. ML-KEM decapsulation never fails:
  /// FIPS 203 specifies implicit rejection, so a wrong decapsulation key yields a pseudorandom
  /// shared secret rather than an error. Minting a seed here would answer the handshake with a
  /// secret the initiator cannot match, and the mismatch would surface only as an AEAD tag
  /// rejection with both ends looking healthy - the failure this step exists to avoid.
  ///
  /// A ciphertext addressed to a device that never published an encapsulation key is a protocol
  /// error, and it has to be reported as one.
  Future<Uint8List> _storedMlKemSeed() async {
    final encoded = await _storage.read(key: _mlKemSeedKey);
    if (encoded == null) {
      throw const ProtocolException(
        'This device holds no ML-KEM seed and cannot answer a hybrid handshake. '
        'Re-publish the key bundle to generate one.',
      );
    }
    return _decodeMlKemSeed(encoded);
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
