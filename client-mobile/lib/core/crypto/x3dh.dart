/// X3DH (Extended Triple Diffie-Hellman) Key Agreement Protocol
///
/// Based on Signal Protocol specification
/// Compatible with Guardyn backend Rust implementation
///
/// Key conversion: Ed25519 identity keys are converted to X25519 for DH operations
/// using the birational equivalence between twisted Edwards curve (Ed25519) and
/// Montgomery curve (Curve25519/X25519). This is the same approach used by Signal Protocol.
///
/// NOTE: This implementation uses CryptoPrimitives which can use either
/// pure Dart or native Rust FFI depending on platform availability.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'crypto_exceptions.dart';
import 'crypto_primitives.dart';
import 'double_ratchet.dart';

/// Ed25519 identity key pair
class IdentityKeyPair {
  final Uint8List privateKey;
  final Uint8List publicKey;

  IdentityKeyPair({required this.privateKey, required this.publicKey});

  /// Generate a new random Ed25519 identity key pair
  static Future<IdentityKeyPair> generate() async {
    final (publicKey, privateKey) =
        await CryptoPrimitives.generateEd25519KeyPair();
    return IdentityKeyPair(privateKey: privateKey, publicKey: publicKey);
  }

  /// Create key pair from a 32-byte seed (deterministic).
  ///
  /// This is useful for testing with known test vectors to verify
  /// cross-platform compatibility between Rust and Dart implementations.
  ///
  /// Note: For deterministic key generation, we use the seed directly
  /// as the private key. The public key is derived from it.
  static Future<IdentityKeyPair> fromSeed(Uint8List seed) async {
    if (seed.length != 32) {
      throw ArgumentError('Seed must be exactly 32 bytes');
    }
    // Use deterministic key generation from seed
    final (publicKey, privateKey) =
        await CryptoPrimitives.generateEd25519KeyPairFromSeed(seed);
    return IdentityKeyPair(privateKey: privateKey, publicKey: publicKey);
  }

  /// Create key pair from existing bytes
  factory IdentityKeyPair.fromBytes({
    required Uint8List privateKey,
    required Uint8List publicKey,
  }) {
    return IdentityKeyPair(privateKey: privateKey, publicKey: publicKey);
  }

  /// Sign data with Ed25519
  Future<Uint8List> sign(Uint8List data) async {
    return CryptoPrimitives.signEd25519(privateKey: privateKey, message: data);
  }

  /// Verify signature with Ed25519
  static Future<bool> verify(
    Uint8List data,
    Uint8List signature,
    Uint8List publicKey,
  ) async {
    return CryptoPrimitives.verifyEd25519(
      publicKey: publicKey,
      message: data,
      signature: signature,
    );
  }

  /// Convert Ed25519 public key to X25519 for Diffie-Hellman operations.
  ///
  /// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
  /// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
  Future<Uint8List> toX25519PublicKey() async {
    return CryptoPrimitives.ed25519PublicToX25519(publicKey);
  }

  /// Convert Ed25519 signing key to X25519 StaticSecret for Diffie-Hellman operations.
  ///
  /// The Ed25519 secret key (64 bytes = 32 byte seed + 32 byte public) needs to be
  /// converted to X25519 secret key (32 bytes) using proper scalar derivation.
  ///
  /// Note: The Ed25519 seed (first 32 bytes) is hashed with SHA-512 to get the
  /// Ed25519 scalar. For X25519, we need to apply the same clamping as X25519.
  Future<Uint8List> toX25519SecretKey() async {
    return CryptoPrimitives.ed25519SecretToX25519(privateKey);
  }
}

/// Signed pre-key (X25519)
class SignedPreKey {
  final Uint8List privateKey;
  final Uint8List publicKey;
  final Uint8List signature;
  final int keyId;

  SignedPreKey({
    required this.privateKey,
    required this.publicKey,
    required this.signature,
    required this.keyId,
  });

  /// Generate a new signed pre-key
  static Future<SignedPreKey> generate({
    required IdentityKeyPair identityKey,
    required int keyId,
  }) async {
    final keyPair = await X25519KeyPair.generate();

    // Sign the public key with identity key
    final signature = await identityKey.sign(keyPair.publicKey);

    return SignedPreKey(
      privateKey: keyPair.privateKey,
      publicKey: keyPair.publicKey,
      signature: signature,
      keyId: keyId,
    );
  }

  /// Verify signature of signed pre-key
  Future<bool> verify(Uint8List identityPublicKey) async {
    return IdentityKeyPair.verify(publicKey, signature, identityPublicKey);
  }
}

/// One-time pre-key (X25519)
class OneTimePreKey {
  final Uint8List privateKey;
  final Uint8List publicKey;
  final int keyId;

  OneTimePreKey({
    required this.privateKey,
    required this.publicKey,
    required this.keyId,
  });

  /// Generate a new one-time pre-key
  static Future<OneTimePreKey> generate(int keyId) async {
    final keyPair = await X25519KeyPair.generate();
    return OneTimePreKey(
      privateKey: keyPair.privateKey,
      publicKey: keyPair.publicKey,
      keyId: keyId,
    );
  }
}

/// Key bundle for X3DH key exchange
class X3DHKeyBundle {
  final Uint8List identityKey;
  final Uint8List signedPreKey;
  final Uint8List signedPreKeySignature;
  final int signedPreKeyId;
  final Uint8List? oneTimePreKey;
  final int? oneTimePreKeyId;

  X3DHKeyBundle({
    required this.identityKey,
    required this.signedPreKey,
    required this.signedPreKeySignature,
    required this.signedPreKeyId,
    this.oneTimePreKey,
    this.oneTimePreKeyId,
  });

  /// Verify the key bundle
  Future<bool> verify() async {
    return IdentityKeyPair.verify(
      signedPreKey,
      signedPreKeySignature,
      identityKey,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'identity_key': base64Encode(identityKey),
      'signed_pre_key': base64Encode(signedPreKey),
      'signed_pre_key_signature': base64Encode(signedPreKeySignature),
      'signed_pre_key_id': signedPreKeyId,
      if (oneTimePreKey != null)
        'one_time_pre_key': base64Encode(oneTimePreKey!),
      if (oneTimePreKeyId != null) 'one_time_pre_key_id': oneTimePreKeyId,
    };
  }

  /// Deserialize from JSON
  factory X3DHKeyBundle.fromJson(Map<String, dynamic> json) {
    return X3DHKeyBundle(
      identityKey: base64Decode(json['identity_key']),
      signedPreKey: base64Decode(json['signed_pre_key']),
      signedPreKeySignature: base64Decode(json['signed_pre_key_signature']),
      signedPreKeyId: json['signed_pre_key_id'],
      oneTimePreKey: json['one_time_pre_key'] != null
          ? base64Decode(json['one_time_pre_key'])
          : null,
      oneTimePreKeyId: json['one_time_pre_key_id'],
    );
  }
}

/// Convert Ed25519 public key to X25519 using birational equivalence mapping.
///
/// This is a helper function for X3DH protocol that converts Ed25519 identity
/// public keys (used for signatures) to X25519 public keys (used for DH).
/// Uses the standard conversion from twisted Edwards to Montgomery curve.
Future<Uint8List> _ed25519PublicToX25519(Uint8List ed25519PublicKey) async {
  return CryptoPrimitives.ed25519PublicToX25519(ed25519PublicKey);
}

/// X3DH protocol implementation
class X3DHProtocol {
  final IdentityKeyPair identityKey;
  final SignedPreKey signedPreKey;
  final List<OneTimePreKey> oneTimePreKeys;

  X3DHProtocol({
    required this.identityKey,
    required this.signedPreKey,
    required this.oneTimePreKeys,
  });

  /// Initialize X3DH with new keys
  ///
  /// Key replenishment strategy:
  /// - Initial: 5 keys for fast startup (< 1 second)
  /// - Background: Replenish to 100 keys after successful auth
  /// - Threshold: Trigger replenishment when < 20 keys remain
  ///
  /// See [OneTimePreKeyConfig] in crypto_service.dart for configuration.
  static Future<X3DHProtocol> initialize({int oneTimePreKeyCount = 5}) async {
    final identity = await IdentityKeyPair.generate();
    final signedPreKey = await SignedPreKey.generate(
      identityKey: identity,
      keyId: 1,
    );

    final oneTimePreKeys = <OneTimePreKey>[];
    for (int i = 0; i < oneTimePreKeyCount; i++) {
      oneTimePreKeys.add(
        await OneTimePreKey.generate(i),
      ); // Use 0-based keyId to match server storage
      // Yield to allow UI to remain responsive
      if (i % 5 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    return X3DHProtocol(
      identityKey: identity,
      signedPreKey: signedPreKey,
      oneTimePreKeys: oneTimePreKeys,
    );
  }

  /// Export key bundle for distribution
  X3DHKeyBundle exportKeyBundle({int? oneTimePreKeyIndex}) {
    return X3DHKeyBundle(
      identityKey: identityKey.publicKey,
      signedPreKey: signedPreKey.publicKey,
      signedPreKeySignature: signedPreKey.signature,
      signedPreKeyId: signedPreKey.keyId,
      oneTimePreKey:
          oneTimePreKeyIndex != null &&
              oneTimePreKeyIndex < oneTimePreKeys.length
          ? oneTimePreKeys[oneTimePreKeyIndex].publicKey
          : null,
      oneTimePreKeyId:
          oneTimePreKeyIndex != null &&
              oneTimePreKeyIndex < oneTimePreKeys.length
          ? oneTimePreKeys[oneTimePreKeyIndex].keyId
          : null,
    );
  }

  /// Perform X3DH key agreement as initiator (Alice)
  ///
  /// X3DH computes:
  /// - DH1 = DH(IKa, SPKb) - Alice's identity key with Bob's signed prekey
  /// - DH2 = DH(EKa, IKb) - Alice's ephemeral key with Bob's identity key
  /// - DH3 = DH(EKa, SPKb) - Alice's ephemeral key with Bob's signed prekey
  /// - DH4 = DH(EKa, OPKb) - Alice's ephemeral key with Bob's one-time prekey (optional)
  ///
  /// Note: Ed25519 identity keys are converted to X25519 using birational equivalence
  /// mapping between twisted Edwards curve and Montgomery curve. This is the Signal Protocol approach.
  ///
  /// Returns shared secret and ephemeral public key
  static Future<(Uint8List sharedSecret, Uint8List ephemeralPublicKey)>
  initiateKeyAgreement(
    IdentityKeyPair localIdentity,
    X3DHKeyBundle remoteBundle,
  ) async {
    // Verify the key bundle
    if (!await remoteBundle.verify()) {
      throw ProtocolException('Invalid key bundle signature');
    }

    // Generate ephemeral key pair for this session
    final ephemeralKeyPair = await X25519KeyPair.generate();

    // Convert Ed25519 identity keys to X25519 for DH operations
    // This uses birational equivalence mapping between curves
    final localX25519Secret = await localIdentity.toX25519SecretKey();
    final remoteX25519Identity = await _ed25519PublicToX25519(
      remoteBundle.identityKey,
    );

    // DH1 = DH(IKa, SPKb) - Alice's identity with Bob's signed prekey
    final dh1 = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: localX25519Secret,
      remotePublicKey: remoteBundle.signedPreKey,
    );

    // DH2 = DH(EKa, IKb) - Alice's ephemeral with Bob's identity
    final dh2 = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: ephemeralKeyPair.privateKey,
      remotePublicKey: remoteX25519Identity,
    );

    // DH3 = DH(EKa, SPKb) - Alice's ephemeral with Bob's signed prekey
    final dh3 = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: ephemeralKeyPair.privateKey,
      remotePublicKey: remoteBundle.signedPreKey,
    );

    // Combine DH outputs: DH1 || DH2 || DH3 [|| DH4]
    final dhOutputs = <int>[];
    dhOutputs.addAll(dh1);
    dhOutputs.addAll(dh2);
    dhOutputs.addAll(dh3);

    // DH4 = DH(EKa, OPKb) - Optional, if one-time prekey available
    if (remoteBundle.oneTimePreKey != null) {
      final dh4 = await CryptoPrimitives.x25519DiffieHellman(
        privateKey: ephemeralKeyPair.privateKey,
        remotePublicKey: remoteBundle.oneTimePreKey!,
      );
      dhOutputs.addAll(dh4);
    }

    // Derive shared secret using HKDF
    // IMPORTANT: info must be 'X3DH' to match Rust backend implementation
    final sharedSecret = await CryptoPrimitives.hkdf(
      inputKeyMaterial: Uint8List.fromList(dhOutputs),
      info: utf8.encode('X3DH'),
      salt: null,
      outputLength: 32,
    );

    return (sharedSecret, ephemeralKeyPair.publicKey);
  }

  /// Complete X3DH key agreement as responder (Bob)
  ///
  /// X3DH computes (symmetric with initiator):
  /// - DH1 = DH(SPKb, IKa) - Bob's signed prekey with Alice's identity key
  /// - DH2 = DH(IKb, EKa) - Bob's identity key with Alice's ephemeral key
  /// - DH3 = DH(SPKb, EKa) - Bob's signed prekey with Alice's ephemeral key
  /// - DH4 = DH(OPKb, EKa) - Bob's one-time prekey with Alice's ephemeral key (optional)
  ///
  /// Note: Ed25519 identity keys are converted to X25519 using birational equivalence
  /// mapping between twisted Edwards curve and Montgomery curve. This is the Signal Protocol approach.
  ///
  /// Returns shared secret
  Future<Uint8List> completeKeyAgreement({
    required Uint8List remoteIdentityKey,
    required Uint8List remoteEphemeralKey,
    int? usedOneTimePreKeyId,
  }) async {
    // Convert Ed25519 identity keys to X25519 for DH operations
    final localX25519Secret = await identityKey.toX25519SecretKey();
    final remoteX25519Identity = await _ed25519PublicToX25519(
      remoteIdentityKey,
    );

    // DH1 = DH(SPKb, IKa) - Bob's signed prekey with Alice's identity
    final dh1 = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: signedPreKey.privateKey,
      remotePublicKey: remoteX25519Identity,
    );

    // DH2 = DH(IKb, EKa) - Bob's identity with Alice's ephemeral
    final dh2 = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: localX25519Secret,
      remotePublicKey: remoteEphemeralKey,
    );

    // DH3 = DH(SPKb, EKa) - Bob's signed prekey with Alice's ephemeral
    final dh3 = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: signedPreKey.privateKey,
      remotePublicKey: remoteEphemeralKey,
    );

    // Combine DH outputs: DH1 || DH2 || DH3 [|| DH4]
    final dhOutputs = <int>[];
    dhOutputs.addAll(dh1);
    dhOutputs.addAll(dh2);
    dhOutputs.addAll(dh3);

    // DH4 = DH(OPKb, EKa) - Optional, if one-time prekey was used
    if (usedOneTimePreKeyId != null) {
      final otpk = oneTimePreKeys.firstWhere(
        (k) => k.keyId == usedOneTimePreKeyId,
        orElse: () => throw ProtocolException('One-time prekey not found'),
      );
      final dh4 = await CryptoPrimitives.x25519DiffieHellman(
        privateKey: otpk.privateKey,
        remotePublicKey: remoteEphemeralKey,
      );
      dhOutputs.addAll(dh4);
    }

    // Derive shared secret using HKDF
    // IMPORTANT: info must be 'X3DH' to match Rust backend implementation
    final sharedSecret = await CryptoPrimitives.hkdf(
      inputKeyMaterial: Uint8List.fromList(dhOutputs),
      info: utf8.encode('X3DH'),
      salt: null,
      outputLength: 32,
    );

    return sharedSecret;
  }

  /// Serialize protocol state for storage
  Map<String, dynamic> serialize() {
    return {
      'identity_key': {
        'private': base64Encode(identityKey.privateKey),
        'public': base64Encode(identityKey.publicKey),
      },
      'signed_pre_key': {
        'private': base64Encode(signedPreKey.privateKey),
        'public': base64Encode(signedPreKey.publicKey),
        'signature': base64Encode(signedPreKey.signature),
        'key_id': signedPreKey.keyId,
      },
      'one_time_pre_keys': oneTimePreKeys
          .map(
            (k) => {
              'private': base64Encode(k.privateKey),
              'public': base64Encode(k.publicKey),
              'key_id': k.keyId,
            },
          )
          .toList(),
    };
  }

  /// Deserialize protocol state from storage
  factory X3DHProtocol.deserialize(Map<String, dynamic> data) {
    final identityData = data['identity_key'] as Map<String, dynamic>;
    final signedPreKeyData = data['signed_pre_key'] as Map<String, dynamic>;
    final oneTimePreKeysData = data['one_time_pre_keys'] as List;

    return X3DHProtocol(
      identityKey: IdentityKeyPair.fromBytes(
        privateKey: base64Decode(identityData['private']),
        publicKey: base64Decode(identityData['public']),
      ),
      signedPreKey: SignedPreKey(
        privateKey: base64Decode(signedPreKeyData['private']),
        publicKey: base64Decode(signedPreKeyData['public']),
        signature: base64Decode(signedPreKeyData['signature']),
        keyId: signedPreKeyData['key_id'],
      ),
      oneTimePreKeys: oneTimePreKeysData
          .map(
            (k) => OneTimePreKey(
              privateKey: base64Decode(k['private']),
              publicKey: base64Decode(k['public']),
              keyId: k['key_id'],
            ),
          )
          .toList(),
    );
  }
}

/// X3DH prekey message data to include with first encrypted message
///
/// This allows the recipient to derive the shared secret and
/// create their Double Ratchet session as responder
///
/// The wire format is v1, defined in `docs/spec/SRS.md` and implemented in
/// `backend/crates/crypto/src/x3dh.rs`. That is the reference: this class must produce and
/// accept exactly the same bytes, and `test/core/crypto/wire_vectors_test.dart` pins it to
/// known-answer vectors generated by the Rust implementation rather than by this one.
class X3DHPrekeyMessage {
  /// Wire format version. v1 is a hard break from the unversioned v0 with no fallback:
  /// byte 0 of a v0 frame was the first byte of an Ed25519 public key, which is
  /// unconstrained, so 0x01 is a value v0 could legitimately emit and the two are not
  /// distinguishable. Guessing would reintroduce the ambiguity the version byte removes.
  static const int _version = 0x01;

  /// `flags` bit 0: a big-endian uint32 one-time pre-key id follows.
  static const int _flagOneTimeKey = 0x01;

  /// `flags` bit 1: a length-prefixed ML-KEM ciphertext follows.
  static const int _flagPqCiphertext = 0x02;

  /// Every bit outside this mask is reserved and must be zero, so that a future field
  /// cannot be silently ignored the way v0's `has_otpk != 1` was read as "no one-time key".
  static const int _flagsKnown = _flagOneTimeKey | _flagPqCiphertext;

  /// Smallest legal v1 frame: version, both keys, and the flags byte.
  static const int _minLength = 1 + 32 + 32 + 1;

  /// Largest ciphertext a uint16 length prefix can describe. ML-KEM-768 is 1088 bytes and
  /// ML-KEM-1024 is 1568, so this is far above any parameter set in use.
  static const int _maxPqCiphertextLength = 0xffff;

  /// Sender's identity public key (Ed25519)
  final Uint8List senderIdentityKey;

  /// Ephemeral public key used for X3DH (X25519)
  final Uint8List ephemeralKey;

  /// ID of the one-time prekey that was used (if any)
  final int? usedOneTimePreKeyId;

  /// ML-KEM ciphertext for the responder to decapsulate, when the handshake is hybrid.
  ///
  /// `null` is a classical X3DH handshake. Classical strength is the floor, so a peer bundle
  /// with no ML-KEM key still establishes a session.
  ///
  /// Nothing populates this yet on mobile - that is #262 (PR-98), which exports the hybrid
  /// agreement through `crypto-ffi`. This class only has to carry it across the wire.
  final Uint8List? pqCiphertext;

  X3DHPrekeyMessage({
    required this.senderIdentityKey,
    required this.ephemeralKey,
    this.usedOneTimePreKeyId,
    this.pqCiphertext,
  });

  /// Serialize to bytes for transmission.
  ///
  /// ```text
  /// version(1)=0x01 || identity_key(32) || ephemeral_key(32) || flags(1)
  ///                 || [otk_id:u32 BE (4)]
  ///                 || [ct_len:u16 BE (2) || ct]
  /// ```
  ///
  /// 66 bytes minimum, 70 with a one-time key id, `+ 2 + ct_len` with an ML-KEM ciphertext;
  /// when both optional fields are present the id comes first.
  ///
  /// Every multi-byte integer is big-endian (network byte order, RFC 1700), as in every
  /// format that crosses the Rust/Dart boundary. `ct_len` is a length prefix rather than a
  /// fixed 1088 so the frame is independent of the ML-KEM parameter set.
  Uint8List toBytes() {
    final ct = pqCiphertext;
    if (ct != null && (ct.isEmpty || ct.length > _maxPqCiphertextLength)) {
      // Unlike Rust, which cannot fail here because `to_bytes` returns a plain Vec, Dart can
      // refuse outright. An empty ciphertext would give "no ciphertext" a second encoding and
      // break canonicality; an over-long one cannot be length-prefixed at all.
      throw ProtocolException(
        'ML-KEM ciphertext must be 1..$_maxPqCiphertextLength bytes, got ${ct.length}',
      );
    }

    final hasOtpk = usedOneTimePreKeyId != null;
    final length =
        _minLength + (hasOtpk ? 4 : 0) + (ct != null ? 2 + ct.length : 0);
    final bytes = Uint8List(length);
    final byteData = ByteData.view(bytes.buffer);

    bytes[0] = _version;
    bytes.setRange(1, 33, senderIdentityKey);
    bytes.setRange(33, 65, ephemeralKey);
    bytes[65] =
        (hasOtpk ? _flagOneTimeKey : 0) | (ct != null ? _flagPqCiphertext : 0);

    var offset = _minLength;
    if (hasOtpk) {
      byteData.setUint32(offset, usedOneTimePreKeyId!, Endian.big);
      offset += 4;
    }
    if (ct != null) {
      byteData.setUint16(offset, ct.length, Endian.big);
      offset += 2;
      bytes.setRange(offset, offset + ct.length, ct);
    }

    return bytes;
  }

  /// Deserialize from bytes.
  ///
  /// **Strict**, and deliberately so: it rejects an unsupported version, any reserved flag
  /// bit, a declared-but-empty ciphertext, and any trailing byte. Rejecting trailing bytes
  /// makes the encoding canonical - every accepted frame re-encodes to itself.
  ///
  /// v0 checked `bytes.length < 65` and `< 69` but never an exact length, so a frame with an
  /// ML-KEM ciphertext appended parsed as a valid-looking classical message and the
  /// ciphertext vanished: the responder would derive a classical secret while the initiator
  /// derived a hybrid one, and the mismatch would surface as an AEAD tag rejection with both
  /// sides looking healthy. Closing that is the point of the version byte.
  ///
  /// Reachable from attacker-controlled bytes, since the server relays the prekey message
  /// without inspecting it, so every length is checked before it is used to slice.
  factory X3DHPrekeyMessage.fromBytes(Uint8List bytes) {
    if (bytes.length < _minLength) {
      throw ProtocolException('Invalid X3DH prekey message length');
    }
    if (bytes[0] != _version) {
      throw ProtocolException(
        'Unsupported X3DH prekey message version ${bytes[0]}',
      );
    }

    final senderIdentityKey = Uint8List.fromList(bytes.sublist(1, 33));
    final ephemeralKey = Uint8List.fromList(bytes.sublist(33, 65));
    final flags = bytes[65];

    final unknown = flags & ~_flagsKnown & 0xff;
    if (unknown != 0) {
      throw ProtocolException(
        'Unknown X3DH prekey message flag bits 0x${unknown.toRadixString(16).padLeft(2, '0')}',
      );
    }

    // A single ByteData over the whole frame, so multi-byte reads never go through an
    // intermediate sublist - `ByteData.view(sublist.buffer)` silently reads from offset 0 of
    // the *copy's* buffer and is an easy way to read the wrong bytes.
    final byteData = ByteData.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.length,
    );
    var offset = _minLength;

    int? usedOneTimePreKeyId;
    if (flags & _flagOneTimeKey != 0) {
      if (bytes.length < offset + 4) {
        throw ProtocolException('X3DH prekey message missing OTK ID');
      }
      usedOneTimePreKeyId = byteData.getUint32(offset, Endian.big);
      offset += 4;
    }

    Uint8List? pqCiphertext;
    if (flags & _flagPqCiphertext != 0) {
      if (bytes.length < offset + 2) {
        throw ProtocolException(
          'X3DH prekey message missing ML-KEM ciphertext length',
        );
      }
      final ctLength = byteData.getUint16(offset, Endian.big);
      offset += 2;

      if (ctLength == 0) {
        // Otherwise "no ciphertext" would have two encodings - the flag clear, and the flag
        // set with a zero length - and the frame would not be canonical.
        throw ProtocolException(
          'X3DH prekey message declares an empty ML-KEM ciphertext',
        );
      }
      if (bytes.length < offset + ctLength) {
        throw ProtocolException(
          'X3DH prekey message ML-KEM ciphertext is truncated',
        );
      }
      pqCiphertext = Uint8List.fromList(
        bytes.sublist(offset, offset + ctLength),
      );
      offset += ctLength;
    }

    if (offset != bytes.length) {
      throw ProtocolException(
        'X3DH prekey message has ${bytes.length - offset} trailing byte(s)',
      );
    }

    return X3DHPrekeyMessage(
      senderIdentityKey: senderIdentityKey,
      ephemeralKey: ephemeralKey,
      usedOneTimePreKeyId: usedOneTimePreKeyId,
      pqCiphertext: pqCiphertext,
    );
  }

  /// Encode to base64 for inclusion in message metadata
  String toBase64() {
    return base64Encode(toBytes());
  }

  /// Decode from base64
  factory X3DHPrekeyMessage.fromBase64(String encoded) {
    return X3DHPrekeyMessage.fromBytes(base64Decode(encoded));
  }
}
