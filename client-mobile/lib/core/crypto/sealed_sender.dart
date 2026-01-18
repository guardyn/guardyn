// Sealed Sender Protocol for Flutter
//
// Provides metadata protection by hiding sender identity from server.
// Only the recipient can decrypt and verify who sent the message.
//
// Protocol based on Signal's Sealed Sender:
// https://signal.org/blog/sealed-sender/
//
// NOTE: This implementation uses CryptoPrimitives which can use either
// pure Dart or native Rust FFI depending on platform availability.

import 'dart:typed_data';

import 'crypto_primitives.dart';

/// Sender Certificate - proves sender identity to recipient
class SenderCertificate {
  /// Sender's user ID (UUID)
  final String senderUserId;

  /// Sender's device ID (UUID)
  final String senderDeviceId;

  /// Sender's Ed25519 public key (32 bytes)
  final Uint8List senderIdentityKey;

  /// Expiration timestamp (Unix epoch seconds)
  final int expiresAt;

  /// Ed25519 signature (64 bytes)
  final Uint8List signature;

  SenderCertificate({
    required this.senderUserId,
    required this.senderDeviceId,
    required this.senderIdentityKey,
    required this.expiresAt,
    required this.signature,
  });

  /// Create a new sender certificate
  ///
  /// [signingPrivateKey] - Ed25519 private key (32 bytes)
  /// [signingPublicKey] - Ed25519 public key (32 bytes)
  static Future<SenderCertificate> create({
    required String senderUserId,
    required String senderDeviceId,
    required Uint8List signingPrivateKey,
    required Uint8List signingPublicKey,
    required int expiresAt,
  }) async {
    // Create message to sign
    final message = _buildCertificateMessage(
      senderUserId,
      senderDeviceId,
      signingPublicKey,
      expiresAt,
    );

    // Sign the certificate using CryptoPrimitives
    final signatureBytes = await CryptoPrimitives.signEd25519(
      privateKey: signingPrivateKey,
      message: message,
    );

    return SenderCertificate(
      senderUserId: senderUserId,
      senderDeviceId: senderDeviceId,
      senderIdentityKey: signingPublicKey,
      expiresAt: expiresAt,
      signature: signatureBytes,
    );
  }

  /// Verify the certificate signature
  Future<bool> verify() async {
    final message = _buildCertificateMessage(
      senderUserId,
      senderDeviceId,
      senderIdentityKey,
      expiresAt,
    );

    return CryptoPrimitives.verifyEd25519(
      publicKey: senderIdentityKey,
      message: message,
      signature: signature,
    );
  }

  /// Check if certificate has expired
  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now > expiresAt;
  }

  /// Build the message to sign/verify
  static Uint8List _buildCertificateMessage(
    String userId,
    String deviceId,
    Uint8List identityKey,
    int expiresAt,
  ) {
    final buffer = BytesBuilder();
    buffer.add(userId.codeUnits);
    buffer.addByte(0); // Null separator
    buffer.add(deviceId.codeUnits);
    buffer.addByte(0);
    buffer.add(identityKey);

    // expiresAt as big-endian 8 bytes
    final expiresBytes = ByteData(8)..setInt64(0, expiresAt, Endian.big);
    buffer.add(expiresBytes.buffer.asUint8List());

    return buffer.toBytes();
  }

  /// Serialize to bytes for transmission
  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // sender_user_id (length-prefixed)
    final userIdBytes = Uint8List.fromList(senderUserId.codeUnits);
    buffer.add(
      (ByteData(
        2,
      )..setUint16(0, userIdBytes.length, Endian.big)).buffer.asUint8List(),
    );
    buffer.add(userIdBytes);

    // sender_device_id (length-prefixed)
    final deviceIdBytes = Uint8List.fromList(senderDeviceId.codeUnits);
    buffer.add(
      (ByteData(
        2,
      )..setUint16(0, deviceIdBytes.length, Endian.big)).buffer.asUint8List(),
    );
    buffer.add(deviceIdBytes);

    // sender_identity_key (32 bytes)
    buffer.add(senderIdentityKey);

    // expires_at (8 bytes big-endian)
    buffer.add(
      (ByteData(8)..setInt64(0, expiresAt, Endian.big)).buffer.asUint8List(),
    );

    // signature (64 bytes)
    buffer.add(signature);

    return buffer.toBytes();
  }

  /// Deserialize from bytes
  static SenderCertificate fromBytes(Uint8List bytes) {
    if (bytes.length < 2) {
      throw FormatException('Certificate too short');
    }

    int offset = 0;

    // sender_user_id
    final userIdLen = ByteData.sublistView(
      bytes,
      offset,
      offset + 2,
    ).getUint16(0, Endian.big);
    offset += 2;
    if (bytes.length < offset + userIdLen) {
      throw FormatException('Invalid user_id length');
    }
    final senderUserId = String.fromCharCodes(
      bytes.sublist(offset, offset + userIdLen),
    );
    offset += userIdLen;

    // sender_device_id
    if (bytes.length < offset + 2) {
      throw FormatException('Missing device_id length');
    }
    final deviceIdLen = ByteData.sublistView(
      bytes,
      offset,
      offset + 2,
    ).getUint16(0, Endian.big);
    offset += 2;
    if (bytes.length < offset + deviceIdLen) {
      throw FormatException('Invalid device_id length');
    }
    final senderDeviceId = String.fromCharCodes(
      bytes.sublist(offset, offset + deviceIdLen),
    );
    offset += deviceIdLen;

    // sender_identity_key (32 bytes)
    if (bytes.length < offset + 32) {
      throw FormatException('Missing identity key');
    }
    final senderIdentityKey = Uint8List.fromList(
      bytes.sublist(offset, offset + 32),
    );
    offset += 32;

    // expires_at (8 bytes)
    if (bytes.length < offset + 8) {
      throw FormatException('Missing expires_at');
    }
    final expiresAt = ByteData.sublistView(
      bytes,
      offset,
      offset + 8,
    ).getInt64(0, Endian.big);
    offset += 8;

    // signature (64 bytes)
    if (bytes.length < offset + 64) {
      throw FormatException('Missing signature');
    }
    final signature = Uint8List.fromList(bytes.sublist(offset, offset + 64));

    return SenderCertificate(
      senderUserId: senderUserId,
      senderDeviceId: senderDeviceId,
      senderIdentityKey: senderIdentityKey,
      expiresAt: expiresAt,
      signature: signature,
    );
  }

  @override
  String toString() {
    return 'SenderCertificate(user: \$senderUserId, device: \$senderDeviceId, '
        'expires: \${DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)})';
  }
}

/// Sealed Sender Envelope - encrypted message with hidden sender
class SealedSenderEnvelope {
  /// Protocol version (currently 1)
  final int version;

  /// Ephemeral X25519 public key (32 bytes)
  final Uint8List ephemeralPublicKey;

  /// Encrypted payload: nonce (12) + ciphertext + tag (16)
  final Uint8List encryptedPayload;

  SealedSenderEnvelope({
    required this.version,
    required this.ephemeralPublicKey,
    required this.encryptedPayload,
  });

  /// Serialize to bytes
  Uint8List toBytes() {
    final buffer = BytesBuilder();
    buffer.addByte(version);
    buffer.add(ephemeralPublicKey);
    buffer.add(encryptedPayload);
    return buffer.toBytes();
  }

  /// Deserialize from bytes
  static SealedSenderEnvelope fromBytes(Uint8List bytes) {
    if (bytes.length < 1 + 32 + 12 + 16) {
      throw FormatException('Envelope too short');
    }

    final version = bytes[0];
    if (version != 1) {
      throw FormatException('Unsupported envelope version: \$version');
    }

    final ephemeralPublicKey = Uint8List.fromList(bytes.sublist(1, 33));
    final encryptedPayload = Uint8List.fromList(bytes.sublist(33));

    return SealedSenderEnvelope(
      version: version,
      ephemeralPublicKey: ephemeralPublicKey,
      encryptedPayload: encryptedPayload,
    );
  }

  String toHex() {
    final bytes = toBytes();
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

/// Result of unsealing an envelope
class UnsealResult {
  final SenderCertificate senderCertificate;
  final Uint8List innerMessage;

  UnsealResult({required this.senderCertificate, required this.innerMessage});
}

/// Sealed Sender Protocol Implementation
class SealedSender {
  static const _hkdfLabel = 'Guardyn-SealedSender-v1';

  /// Seal a message with hidden sender identity
  static Future<SealedSenderEnvelope> seal({
    required SenderCertificate certificate,
    required Uint8List recipientPublicKey,
    required Uint8List innerMessage,
  }) async {
    // 1. Generate ephemeral X25519 key pair
    final (ephemeralPublic, ephemeralPrivate) =
        await CryptoPrimitives.generateX25519KeyPair();

    // 2. Perform ECDH with recipient's public key
    final sharedSecret = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: ephemeralPrivate,
      remotePublicKey: recipientPublicKey,
    );

    // 3. Derive encryption key using HKDF
    final derivedKey = await CryptoPrimitives.hkdf(
      inputKeyMaterial: sharedSecret,
      info: Uint8List.fromList(_hkdfLabel.codeUnits),
      outputLength: 32,
    );

    // 4. Create payload: certificate_length || certificate || inner_message
    final certBytes = certificate.toBytes();
    final payload = BytesBuilder();
    payload.add(
      (ByteData(
        4,
      )..setUint32(0, certBytes.length, Endian.big)).buffer.asUint8List(),
    );
    payload.add(certBytes);
    payload.add(innerMessage);

    // 5. Encrypt with AES-GCM
    final (ciphertext, nonce, tag) = await CryptoPrimitives.encryptAesGcm(
      plaintext: payload.toBytes(),
      key: derivedKey,
    );

    // 6. Build encrypted payload: nonce || ciphertext || tag
    final encryptedPayload = BytesBuilder();
    encryptedPayload.add(nonce);
    encryptedPayload.add(ciphertext);
    encryptedPayload.add(tag);

    return SealedSenderEnvelope(
      version: 1,
      ephemeralPublicKey: ephemeralPublic,
      encryptedPayload: encryptedPayload.toBytes(),
    );
  }

  /// Unseal a message and reveal sender identity
  static Future<UnsealResult> unseal({
    required SealedSenderEnvelope envelope,
    required Uint8List recipientPrivateKey,
  }) async {
    if (envelope.version != 1) {
      throw FormatException(
        'Unsupported envelope version: \${envelope.version}',
      );
    }

    // 1. Perform ECDH with ephemeral public key
    final sharedSecret = await CryptoPrimitives.x25519DiffieHellman(
      privateKey: recipientPrivateKey,
      remotePublicKey: envelope.ephemeralPublicKey,
    );

    // 2. Derive decryption key
    final derivedKey = await CryptoPrimitives.hkdf(
      inputKeyMaterial: sharedSecret,
      info: Uint8List.fromList(_hkdfLabel.codeUnits),
      outputLength: 32,
    );

    // 3. Parse encrypted payload: nonce (12) || ciphertext || tag (16)
    final encPayload = envelope.encryptedPayload;
    if (encPayload.length < 12 + 16) {
      throw FormatException('Encrypted payload too short');
    }

    final nonce = Uint8List.fromList(encPayload.sublist(0, 12));
    final ciphertextWithTag = encPayload.sublist(12);
    final tag = Uint8List.fromList(
      ciphertextWithTag.sublist(ciphertextWithTag.length - 16),
    );
    final ciphertext = Uint8List.fromList(
      ciphertextWithTag.sublist(0, ciphertextWithTag.length - 16),
    );

    // 4. Decrypt with AES-GCM
    final payload = await CryptoPrimitives.decryptAesGcm(
      ciphertext: ciphertext,
      key: derivedKey,
      nonce: nonce,
      tag: tag,
    );

    // 5. Parse payload: cert_length (4) || certificate || inner_message
    if (payload.length < 4) {
      throw FormatException('Payload too short');
    }

    final certLen = ByteData.sublistView(
      payload,
      0,
      4,
    ).getUint32(0, Endian.big);
    if (payload.length < 4 + certLen) {
      throw FormatException('Invalid certificate length');
    }

    final certBytes = Uint8List.fromList(payload.sublist(4, 4 + certLen));
    final innerMessage = Uint8List.fromList(payload.sublist(4 + certLen));

    final certificate = SenderCertificate.fromBytes(certBytes);

    // 6. Verify certificate signature
    final isValid = await certificate.verify();
    if (!isValid) {
      throw SecurityException('Invalid sender certificate signature');
    }

    // 7. Check certificate expiration
    if (certificate.isExpired) {
      throw SecurityException('Sender certificate has expired');
    }

    return UnsealResult(
      senderCertificate: certificate,
      innerMessage: innerMessage,
    );
  }
}

/// Security exception for cryptographic failures
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: \$message';
}
