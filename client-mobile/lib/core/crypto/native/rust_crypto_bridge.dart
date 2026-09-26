/// Native Rust Crypto Bridge Implementation
///
/// This file provides the native Rust implementation of CryptoBridge
/// using flutter_rust_bridge to call guardyn-crypto FFI functions.
///
/// Supported platforms:
/// - Android (libguardyn_crypto_ffi.so)
/// - iOS (GuardynCrypto.framework)
/// - Linux (libguardyn_crypto_ffi.so)
/// - macOS (libguardyn_crypto_ffi.dylib)
/// - Windows (guardyn_crypto_ffi.dll)
///
/// IMPORTANT: Web platform is NOT supported for security reasons.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../generated/rust/api.dart' as rust_api;
import '../../../generated/rust/frb_generated.dart';
import '../native_crypto_bridge.dart';

/// Native Rust implementation of CryptoBridge
///
/// This implementation calls Rust code through FFI for:
/// - Post-quantum cryptography (ML-KEM-768)
/// - Hardware-accelerated encryption
/// - PADMÉ padding
class NativeRustCryptoBridge implements CryptoBridge {
  late NativeCryptoConfig _config;
  bool _initialized = false;
  bool _nativeAvailable = false;
  bool _pqAvailable = false;

  /// Whether `GuardynCrypto.init()` has run in this process.
  ///
  /// flutter_rust_bridge permits exactly one initialisation and throws
  /// `StateError('Should not initialize flutter_rust_bridge twice')` on the second. That is a
  /// property of the runtime rather than a failure, but [initialize] used to discover it by
  /// exception - and its own `catch` then concluded the *native library was unavailable*,
  /// leaving [isNativeAvailable] and [isPostQuantumAvailable] false on a device where both
  /// were true.
  ///
  /// That is what silently disabled every post-quantum assertion in
  /// `integration_test/crypto/rust_ffi_test.dart` (#363): a second bridge instance reported no
  /// native crypto, the tests' own guards skipped on that, and the run went green having
  /// asserted nothing. Tracking the one-shot explicitly makes a second instance initialise
  /// correctly instead of mislabelling a working library as missing.
  static bool _frbInitialized = false;

  // `checkNativeAvailable()` was here, and it was the whole of #366.
  //
  // It answered "is the native library present?" by *calling into it* - `rust_api.cryptoStatus()`
  // - which cannot succeed until flutter_rust_bridge is up, and the only thing that starts
  // flutter_rust_bridge is [initialize], which you reached through the factory that ran this
  // probe first. The first call in a process therefore could not succeed, and the answer was
  // cached, so one premature call pinned "unavailable" for the life of the process.
  //
  // Its `catch` could not tell `StateError('flutter_rust_bridge has not been initialized')`
  // apart from a genuinely missing `.so`, so both became a cached `false`. Nothing reset it:
  // `CryptoBridgeFactory.reset()` cleared the singleton but never this field.
  //
  // There is no probe now. [initialize] establishes availability by doing the thing, and
  // nothing negative is cached anywhere - see `CryptoBridgeFactory.ensureInstance`.

  static String? _getLibraryName() {
    if (Platform.isAndroid) {
      return 'libguardyn_crypto_ffi.so';
    } else if (Platform.isIOS) {
      return 'GuardynCrypto.framework/GuardynCrypto';
    } else if (Platform.isLinux) {
      return 'libguardyn_crypto_ffi.so';
    } else if (Platform.isMacOS) {
      return 'libguardyn_crypto_ffi.dylib';
    } else if (Platform.isWindows) {
      return 'guardyn_crypto_ffi.dll';
    }
    return null;
  }

  @override
  Future<void> initialize(NativeCryptoConfig config) async {
    _config = config;

    if (!config.preferNative) {
      debugPrint('🔐 Native crypto disabled by config');
      _nativeAvailable = false;
      _initialized = true;
      return;
    }

    try {
      // Initialize flutter_rust_bridge runtime - once per process, see [_frbInitialized].
      if (!_frbInitialized) {
        await GuardynCrypto.init();
        _frbInitialized = true;
      }

      // Initialize native crypto library
      rust_api.cryptoInit();
      final status = rust_api.cryptoStatus();
      _nativeAvailable = status.initialized;
      _pqAvailable = status.postQuantumAvailable && config.enablePostQuantum;

      debugPrint(
        '🔐 NativeRustCryptoBridge initialized: '
        'native=$_nativeAvailable, pq=$_pqAvailable, '
        'version=${status.version}',
      );
    } on Object catch (e, stackTrace) {
      // Deliberately rethrown, not recorded. Setting `_nativeAvailable = false` here was the
      // same defect as the probe one layer down: it turned "the native library failed to start"
      // into "the native library is absent", which is a silent downgrade of exactly the kind
      // #230 closed off - and it left the bridge `_initialized` and in use.
      //
      // Refusing loudly is the contract. The message keeps the sentence #230's regression test
      // asserts on, and `Error.throwWithStackTrace` preserves the original failure underneath.
      Error.throwWithStackTrace(
        UnsupportedError(
          'Native Rust crypto is required but could not be initialised: $e. '
          'Ensure ${_getLibraryName() ?? 'the native crypto library'} is built and bundled '
          'with the app. Refusing to fall back to the development-only Dart implementation.',
        ),
        stackTrace,
      );
    }

    _initialized = true;
  }

  @override
  bool get isNativeAvailable => _nativeAvailable;

  @override
  bool get isPostQuantumAvailable => _pqAvailable;

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('NativeRustCryptoBridge not initialized');
    }
  }

  void _ensureNativeAvailable() {
    _ensureInitialized();
    if (!_nativeAvailable) {
      throw UnsupportedError('Native crypto not available on this platform');
    }
  }

  // ===== Key Generation =====

  @override
  Future<KeyPair> generateIdentityKey() async {
    _ensureNativeAvailable();

    final kp = rust_api.cryptoGenerateEd25519Keypair();
    return KeyPair(
      publicKey: Uint8List.fromList(kp.publicKey),
      privateKey: Uint8List.fromList(kp.privateKey),
      keyType: kp.keyType,
    );
  }

  /// Generate Ed25519 key pair from 32-byte seed (deterministic)
  Future<KeyPair> generateEd25519KeyPairFromSeed(Uint8List seed) async {
    _ensureNativeAvailable();

    final kp = rust_api.cryptoGenerateEd25519KeypairFromSeed(seed: seed);
    return KeyPair(
      publicKey: Uint8List.fromList(kp.publicKey),
      privateKey: Uint8List.fromList(kp.privateKey),
      keyType: kp.keyType,
    );
  }

  @override
  Future<KeyPair> generateSignedPreKey() async {
    _ensureNativeAvailable();

    final kp = rust_api.cryptoGenerateX25519Keypair();
    return KeyPair(
      publicKey: Uint8List.fromList(kp.publicKey),
      privateKey: Uint8List.fromList(kp.privateKey),
      keyType: kp.keyType,
    );
  }

  @override
  Future<List<KeyPair>> generateOneTimePreKeys(int count) async {
    _ensureNativeAvailable();

    final keys = <KeyPair>[];
    for (var i = 0; i < count; i++) {
      keys.add(await generateSignedPreKey());
    }
    return keys;
  }

  // ===== PQXDH (Hybrid Post-Quantum Key Exchange) =====

  @override
  Future<HybridKeyBundle?> generateHybridKeyBundle() async {
    _ensureNativeAvailable();

    if (!_pqAvailable) {
      return null;
    }

    final bundle = rust_api.cryptoGenerateHybridKeyBundle();
    if (bundle == null) return null;

    return HybridKeyBundle(
      x25519PublicKey: Uint8List.fromList(bundle.x25519Public),
      x25519PrivateKey: Uint8List.fromList(bundle.x25519Private),
      mlKemPublicKey: Uint8List.fromList(bundle.mlKemPublic),
      mlKemPrivateKey: Uint8List.fromList(bundle.mlKemPrivate),
    );
  }

  @override
  Future<Uint8List> deriveHybridSharedSecret({
    required Uint8List localPrivateKey,
    required Uint8List remotePublicKey,
    required Uint8List? remotePqPublicKey,
  }) async {
    _ensureNativeAvailable();

    final sharedSecret = rust_api.cryptoX25519Dh(
      privateKey: localPrivateKey.toList(),
      publicKey: remotePublicKey.toList(),
    );

    // TODO: When PQ is enabled, combine with ML-KEM shared secret
    // For now, return just the X25519 shared secret
    return sharedSecret;
  }

  // ===== Symmetric Encryption =====

  @override
  Future<EncryptedData> encryptAesGcm({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  }) async {
    _ensureNativeAvailable();

    final encrypted = await rust_api.cryptoEncryptAesGcm(
      plaintext: plaintext.toList(),
      key: key.toList(),
      nonce: nonce,
      associatedData: associatedData,
    );

    return EncryptedData(
      ciphertext: encrypted.ciphertext,
      nonce: encrypted.nonce,
      tag: encrypted.tag,
    );
  }

  @override
  Future<Uint8List> decryptAesGcm({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  }) async {
    _ensureNativeAvailable();

    final plaintext = await rust_api.cryptoDecryptAesGcm(
      encrypted: rust_api.EncryptedData(
        ciphertext: encrypted.ciphertext,
        nonce: encrypted.nonce,
        tag: encrypted.tag,
      ),
      key: key.toList(),
      associatedData: associatedData,
    );

    return plaintext;
  }

  @override
  Future<EncryptedData> encryptChaCha20Poly1305({
    required Uint8List plaintext,
    required Uint8List key,
    Uint8List? nonce,
    Uint8List? associatedData,
  }) async {
    _ensureNativeAvailable();

    final encrypted = await rust_api.cryptoEncryptChacha20(
      plaintext: plaintext.toList(),
      key: key.toList(),
      nonce: nonce,
      associatedData: associatedData,
    );

    return EncryptedData(
      ciphertext: encrypted.ciphertext,
      nonce: encrypted.nonce,
      tag: encrypted.tag,
    );
  }

  @override
  Future<Uint8List> decryptChaCha20Poly1305({
    required EncryptedData encrypted,
    required Uint8List key,
    Uint8List? associatedData,
  }) async {
    _ensureNativeAvailable();

    final plaintext = await rust_api.cryptoDecryptChacha20(
      encrypted: rust_api.EncryptedData(
        ciphertext: encrypted.ciphertext,
        nonce: encrypted.nonce,
        tag: encrypted.tag,
      ),
      key: key.toList(),
      associatedData: associatedData,
    );

    return plaintext;
  }

  // ===== PADMÉ Padding =====

  @override
  Future<Uint8List> padMessage(Uint8List message) async {
    if (!_config.enablePadme) {
      return message;
    }

    _ensureNativeAvailable();

    final padded = await rust_api.cryptoPadMessage(message: message.toList());
    return padded;
  }

  @override
  Future<Uint8List> unpadMessage(Uint8List paddedMessage) async {
    if (!_config.enablePadme) {
      return paddedMessage;
    }

    _ensureNativeAvailable();

    final unpadded = await rust_api.cryptoUnpadMessage(
      paddedMessage: paddedMessage.toList(),
    );
    return unpadded;
  }

  // ===== Key Derivation =====

  @override
  Future<Uint8List> hkdfDerive({
    required Uint8List inputKeyMaterial,
    required Uint8List info,
    Uint8List? salt,
    int outputLength = 32,
  }) async {
    _ensureNativeAvailable();

    final derived = await rust_api.cryptoHkdf(
      inputKeyMaterial: inputKeyMaterial.toList(),
      salt: salt,
      info: info.toList(),
      outputLength: outputLength,
    );

    return derived;
  }

  // ===== Signatures =====

  @override
  Future<Uint8List> signEd25519({
    required Uint8List privateKey,
    required Uint8List message,
  }) async {
    _ensureNativeAvailable();

    final signature = rust_api.cryptoSignEd25519(
      privateKey: privateKey.toList(),
      message: message.toList(),
    );

    return signature;
  }

  @override
  Future<bool> verifyEd25519({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  }) async {
    _ensureNativeAvailable();

    return rust_api.cryptoVerifyEd25519(
      publicKey: publicKey.toList(),
      message: message.toList(),
      signature: signature.toList(),
    );
  }

  // ===== Key Conversion (Ed25519 ↔ X25519) =====

  @override
  Future<Uint8List> ed25519PublicToX25519(Uint8List ed25519Public) async {
    _ensureNativeAvailable();

    return rust_api.cryptoEd25519PublicToX25519(
      ed25519Public: ed25519Public.toList(),
    );
  }

  @override
  Future<Uint8List> ed25519SecretToX25519(Uint8List ed25519Seed) async {
    _ensureNativeAvailable();

    return rust_api.cryptoEd25519SecretToX25519(
      ed25519Seed: ed25519Seed.toList(),
    );
  }

  // ===== Utility Methods (non-interface, for direct usage) =====

  /// Generate cryptographically secure random bytes
  Future<Uint8List> randomBytes(int length) async {
    _ensureNativeAvailable();
    return rust_api.cryptoRandomBytes(length: length);
  }

  /// Constant-time byte comparison (prevents timing attacks)
  Future<bool> constantTimeEquals(Uint8List a, Uint8List b) async {
    _ensureNativeAvailable();
    return rust_api.cryptoConstantTimeEq(a: a.toList(), b: b.toList());
  }
}

// ExtendedCryptoBridgeFactory was removed here.
//
// It was the fail-closed factory - it threw UnsupportedError when the native library was
// missing, which is the correct behaviour - and it had zero call sites anywhere in lib/, test/
// or integration_test/. Production went through CryptoBridgeFactory, which fell back silently
// instead. The right code was written and never wired up.
//
// CryptoBridgeFactory now refuses too, so keeping a second copy of that logic would be exactly
// the arrangement that let the two drift apart in the first place.
