/// X3DH (Extended Triple Diffie-Hellman) Key Agreement Protocol
///
/// Based on Signal Protocol specification
/// Compatible with Guardyn backend Rust implementation
///
/// Key conversion: Ed25519 identity keys are converted to X25519 for DH operations
/// using the birational equivalence between twisted Edwards curve (Ed25519) and
/// Montgomery curve (Curve25519/X25519). This is the same approach used by Signal Protocol.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pinenacl/tweetnacl.dart' show TweetNaClExt;

import 'crypto_exceptions.dart';
import 'double_ratchet.dart';

/// Ed25519 identity key pair
class IdentityKeyPair {
  final Uint8List privateKey;
  final Uint8List publicKey;

  IdentityKeyPair({required this.privateKey, required this.publicKey});

  /// Generate a new random Ed25519 identity key pair
  static Future<IdentityKeyPair> generate() async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final privateKeyData = await keyPair.extractPrivateKeyBytes();
    final publicKeyData = (await keyPair.extractPublicKey()).bytes;

    return IdentityKeyPair(
      privateKey: Uint8List.fromList(privateKeyData),
      publicKey: Uint8List.fromList(publicKeyData),
    );
  }

  /// Create key pair from a 32-byte seed (deterministic).
  ///
  /// This is useful for testing with known test vectors to verify
  /// cross-platform compatibility between Rust and Dart implementations.
  static Future<IdentityKeyPair> fromSeed(Uint8List seed) async {
    if (seed.length != 32) {
      throw ArgumentError('Seed must be exactly 32 bytes');
    }
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(seed);
    final privateKeyData = await keyPair.extractPrivateKeyBytes();
    final publicKeyData = (await keyPair.extractPublicKey()).bytes;

    return IdentityKeyPair(
      privateKey: Uint8List.fromList(privateKeyData),
      publicKey: Uint8List.fromList(publicKeyData),
    );
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
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(privateKey);
    final signature = await algorithm.sign(data, keyPair: keyPair);
    return Uint8List.fromList(signature.bytes);
  }

  /// Verify signature with Ed25519
  static Future<bool> verify(
    Uint8List data,
    Uint8List signature,
    Uint8List publicKey,
  ) async {
    final algorithm = Ed25519();
    final pubKey = SimplePublicKey(publicKey, type: KeyPairType.ed25519);
    final sig = Signature(signature, publicKey: pubKey);

    try {
      return await algorithm.verify(data, signature: sig);
    } catch (e) {
      return false;
    }
  }

  /// Convert Ed25519 public key to X25519 for Diffie-Hellman operations.
  ///
  /// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
  /// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
  Uint8List toX25519PublicKey() {
    final x25519Pk = Uint8List(32);
    // Use TweetNaClExt's crypto_sign_ed25519_pk_to_x25519_pk
    TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(x25519Pk, publicKey);
    return x25519Pk;
  }

  /// Convert Ed25519 signing key to X25519 StaticSecret for Diffie-Hellman operations.
  ///
  /// The Ed25519 secret key (64 bytes = 32 byte seed + 32 byte public) needs to be
  /// converted to X25519 secret key (32 bytes) using proper scalar derivation.
  ///
  /// Note: The Ed25519 seed (first 32 bytes) is hashed with SHA-512 to get the
  /// Ed25519 scalar. For X25519, we need to apply the same clamping as X25519.
  Uint8List toX25519SecretKey() {
    // Ed25519 uses: scalar = SHA512(seed)[0:32] with clamping
    // For X25519 conversion, we need the full 64-byte Ed25519 secret key
    // which is: seed (32 bytes) + public key (32 bytes)
    final ed25519Sk = Uint8List(64);
    ed25519Sk.setRange(0, 32, privateKey);
    ed25519Sk.setRange(32, 64, publicKey);

    final x25519Sk = Uint8List(32);
    TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(x25519Sk, ed25519Sk);
    return x25519Sk;
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
Uint8List _ed25519PublicToX25519(Uint8List ed25519PublicKey) {
  final x25519Pk = Uint8List(32);
  TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(x25519Pk, ed25519PublicKey);
  return x25519Pk;
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
  /// Note: Reduced default oneTimePreKeyCount to 10 for faster initialization.
  /// In production, keys can be replenished in background after login.
  static Future<X3DHProtocol> initialize({int oneTimePreKeyCount = 10}) async {
    final identity = await IdentityKeyPair.generate();
    final signedPreKey = await SignedPreKey.generate(
      identityKey: identity,
      keyId: 1,
    );

    final oneTimePreKeys = <OneTimePreKey>[];
    for (int i = 0; i < oneTimePreKeyCount; i++) {
      oneTimePreKeys.add(await OneTimePreKey.generate(i + 1));
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

    final algorithm = X25519();

    // Convert Ed25519 identity keys to X25519 for DH operations
    // This uses birational equivalence mapping between curves
    final localX25519Secret = localIdentity.toX25519SecretKey();
    final remoteX25519Identity = _ed25519PublicToX25519(
      remoteBundle.identityKey,
    );

    // Create X25519 key pairs
    final localIdentityPair = await algorithm.newKeyPairFromSeed(
      localX25519Secret,
    );
    final localEphemeralPair = await algorithm.newKeyPairFromSeed(
      ephemeralKeyPair.privateKey,
    );

    // Remote public keys (signed prekey and one-time prekey are already X25519)
    final remoteIdentityKey = SimplePublicKey(
      remoteX25519Identity,
      type: KeyPairType.x25519,
    );
    final remoteSignedPreKey = SimplePublicKey(
      remoteBundle.signedPreKey,
      type: KeyPairType.x25519,
    );

    // DH1 = DH(IKa, SPKb) - Alice's identity with Bob's signed prekey
    final dh1 = await algorithm.sharedSecretKey(
      keyPair: localIdentityPair,
      remotePublicKey: remoteSignedPreKey,
    );

    // DH2 = DH(EKa, IKb) - Alice's ephemeral with Bob's identity
    final dh2 = await algorithm.sharedSecretKey(
      keyPair: localEphemeralPair,
      remotePublicKey: remoteIdentityKey,
    );

    // DH3 = DH(EKa, SPKb) - Alice's ephemeral with Bob's signed prekey
    final dh3 = await algorithm.sharedSecretKey(
      keyPair: localEphemeralPair,
      remotePublicKey: remoteSignedPreKey,
    );

    // Combine DH outputs: DH1 || DH2 || DH3 [|| DH4]
    final dhOutputs = <int>[];
    dhOutputs.addAll(await dh1.extractBytes());
    dhOutputs.addAll(await dh2.extractBytes());
    dhOutputs.addAll(await dh3.extractBytes());

    // DH4 = DH(EKa, OPKb) - Optional, if one-time prekey available
    if (remoteBundle.oneTimePreKey != null) {
      final remoteOneTimeKey = SimplePublicKey(
        remoteBundle.oneTimePreKey!,
        type: KeyPairType.x25519,
      );
      final dh4 = await algorithm.sharedSecretKey(
        keyPair: localEphemeralPair,
        remotePublicKey: remoteOneTimeKey,
      );
      dhOutputs.addAll(await dh4.extractBytes());
    }

    // Derive shared secret using HKDF
    // IMPORTANT: info must be 'X3DH' to match Rust backend implementation
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final sharedSecret = await hkdf.deriveKey(
      secretKey: SecretKey(dhOutputs),
      info: utf8.encode('X3DH'),
      nonce: Uint8List(0),
    );

    return (
      Uint8List.fromList(await sharedSecret.extractBytes()),
      ephemeralKeyPair.publicKey,
    );
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
    final algorithm = X25519();

    // Convert Ed25519 identity keys to X25519 for DH operations
    final localX25519Secret = identityKey.toX25519SecretKey();
    final remoteX25519Identity = _ed25519PublicToX25519(remoteIdentityKey);

    // Create X25519 key pairs
    final localIdentityPair = await algorithm.newKeyPairFromSeed(
      localX25519Secret,
    );
    final localSignedPreKeyPair = await algorithm.newKeyPairFromSeed(
      signedPreKey.privateKey,
    );

    // Remote public keys (ephemeral key is already X25519)
    final remoteIdentity = SimplePublicKey(
      remoteX25519Identity,
      type: KeyPairType.x25519,
    );
    final remoteEphemeral = SimplePublicKey(
      remoteEphemeralKey,
      type: KeyPairType.x25519,
    );

    // DH1 = DH(SPKb, IKa) - Bob's signed prekey with Alice's identity
    final dh1 = await algorithm.sharedSecretKey(
      keyPair: localSignedPreKeyPair,
      remotePublicKey: remoteIdentity,
    );

    // DH2 = DH(IKb, EKa) - Bob's identity with Alice's ephemeral
    final dh2 = await algorithm.sharedSecretKey(
      keyPair: localIdentityPair,
      remotePublicKey: remoteEphemeral,
    );

    // DH3 = DH(SPKb, EKa) - Bob's signed prekey with Alice's ephemeral
    final dh3 = await algorithm.sharedSecretKey(
      keyPair: localSignedPreKeyPair,
      remotePublicKey: remoteEphemeral,
    );

    // Combine DH outputs: DH1 || DH2 || DH3 [|| DH4]
    final dhOutputs = <int>[];
    dhOutputs.addAll(await dh1.extractBytes());
    dhOutputs.addAll(await dh2.extractBytes());
    dhOutputs.addAll(await dh3.extractBytes());

    // DH4 = DH(OPKb, EKa) - Optional, if one-time prekey was used
    if (usedOneTimePreKeyId != null) {
      final otpk = oneTimePreKeys.firstWhere(
        (k) => k.keyId == usedOneTimePreKeyId,
        orElse: () => throw ProtocolException('One-time prekey not found'),
      );
      final localOneTimeKeyPair = await algorithm.newKeyPairFromSeed(
        otpk.privateKey,
      );
      final dh4 = await algorithm.sharedSecretKey(
        keyPair: localOneTimeKeyPair,
        remotePublicKey: remoteEphemeral,
      );
      dhOutputs.addAll(await dh4.extractBytes());
    }

    // Derive shared secret using HKDF
    // IMPORTANT: info must be 'X3DH' to match Rust backend implementation
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final sharedSecret = await hkdf.deriveKey(
      secretKey: SecretKey(dhOutputs),
      info: utf8.encode('X3DH'),
      nonce: Uint8List(0),
    );

    return Uint8List.fromList(await sharedSecret.extractBytes());
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
class X3DHPrekeyMessage {
  /// Sender's identity public key (Ed25519)
  final Uint8List senderIdentityKey;

  /// Ephemeral public key used for X3DH (X25519)
  final Uint8List ephemeralKey;

  /// ID of the one-time prekey that was used (if any)
  final int? usedOneTimePreKeyId;

  X3DHPrekeyMessage({
    required this.senderIdentityKey,
    required this.ephemeralKey,
    this.usedOneTimePreKeyId,
  });

  /// Serialize to bytes for transmission
  /// Uses Big-Endian (Network Byte Order) per RFC 1700 for cross-platform compatibility
  Uint8List toBytes() {
    // Format: identity_key (32) + ephemeral_key (32) + has_otpk (1) + otpk_id (4 if has_otpk)
    final hasOtpk = usedOneTimePreKeyId != null;
    final length = 32 + 32 + 1 + (hasOtpk ? 4 : 0);
    final bytes = Uint8List(length);

    bytes.setRange(0, 32, senderIdentityKey);
    bytes.setRange(32, 64, ephemeralKey);
    bytes[64] = hasOtpk ? 1 : 0;

    if (hasOtpk) {
      final byteData = ByteData.view(bytes.buffer);
      byteData.setUint32(65, usedOneTimePreKeyId!, Endian.big);
    }

    return bytes;
  }

  /// Deserialize from bytes
  /// Uses Big-Endian (Network Byte Order) per RFC 1700 for cross-platform compatibility
  factory X3DHPrekeyMessage.fromBytes(Uint8List bytes) {
    if (bytes.length < 65) {
      throw ProtocolException('Invalid X3DH prekey message length');
    }

    final senderIdentityKey = Uint8List.fromList(bytes.sublist(0, 32));
    final ephemeralKey = Uint8List.fromList(bytes.sublist(32, 64));
    final hasOtpk = bytes[64] == 1;

    int? usedOneTimePreKeyId;
    if (hasOtpk) {
      if (bytes.length < 69) {
        throw ProtocolException('Invalid X3DH prekey message: missing OTPK ID');
      }
      final byteData = ByteData.view(
        Uint8List.fromList(bytes.sublist(65, 69)).buffer,
      );
      usedOneTimePreKeyId = byteData.getUint32(0, Endian.big);
    }

    return X3DHPrekeyMessage(
      senderIdentityKey: senderIdentityKey,
      ephemeralKey: ephemeralKey,
      usedOneTimePreKeyId: usedOneTimePreKeyId,
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
