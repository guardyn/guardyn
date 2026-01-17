// Sealed Sender Protocol for Flutter
//
// Provides metadata protection by hiding sender identity from server.
// Only the recipient can decrypt and verify who sent the message.
//
// Protocol based on Signal's Sealed Sender:
// https://signal.org/blog/sealed-sender/

import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

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
  static Future<SenderCertificate> create({
    required String senderUserId,
    required String senderDeviceId,
    required SimpleKeyPair signingKeyPair,
    required int expiresAt,
  }) async {
    final ed25519 = Ed25519();
    final publicKey = await signingKeyPair.extractPublicKey();
    final identityKey = Uint8List.fromList(publicKey.bytes);

    // Create message to sign
    final message = _buildCertificateMessage(
      senderUserId,
      senderDeviceId,
      identityKey,
      expiresAt,
    );

    // Sign the certificate
    final signatureResult = await ed25519.sign(
      message,
      keyPair: signingKeyPair,
    );

    return SenderCertificate(
      senderUserId: senderUserId,
      senderDeviceId: senderDeviceId,
      senderIdentityKey: identityKey,
      expiresAt: expiresAt,
      signature: Uint8List.fromList(signatureResult.bytes),
    );
  }

  /// Verify the certificate signature
  Future<bool> verify() async {
    final ed25519 = Ed25519();
    final publicKey = SimplePublicKey(
      senderIdentityKey.toList(),
      type: KeyPairType.ed25519,
    );

    final message = _buildCertificateMessage(
      senderUserId,
      senderDeviceId,
      senderIdentityKey,
      expiresAt,
    );

    final sig = Signature(signature.toList(), publicKey: publicKey);

    return ed25519.verify(message, signature: sig);
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
    return 'SenderCertificate(user: $senderUserId, device: $senderDeviceId, '
        'expires: ${DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)})';
  }
}

/// Sealed Sender Envelope - encrypted message with hidden sender
class SealedSenderEnvelope {
  /// Protocol version (currently 1)
  final int version;

  /// Ephemeral X25519 public key (32 bytes)
  final Uint8List ephemeralPublicKey;

  /// Encrypted payload: nonce (12) + ciphertext (certificate + message)
  final Uint8List encryptedPayload;

  SealedSenderEnvelope({
    required this.version,
    required this.ephemeralPublicKey,
    required this.encryptedPayload,
  });

  /// Serialize to bytes
  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // Version (1 byte)
    buffer.addByte(version);

    // Ephemeral public key (32 bytes)
    buffer.add(ephemeralPublicKey);

    // Encrypted payload
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
      throw FormatException('Unsupported envelope version: $version');
    }

    final ephemeralPublicKey = Uint8List.fromList(bytes.sublist(1, 33));
    final encryptedPayload = Uint8List.fromList(bytes.sublist(33));

    return SealedSenderEnvelope(
      version: version,
      ephemeralPublicKey: ephemeralPublicKey,
      encryptedPayload: encryptedPayload,
    );
  }

  /// Get hex representation for debugging
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
  /// HKDF label for key derivation
  static const _hkdfLabel = 'Guardyn-SealedSender-v1';

  /// Seal a message with hidden sender identity
  ///
  /// [certificate] - Sender's certificate proving identity
  /// [recipientPublicKey] - Recipient's X25519 public key (32 bytes)
  /// [innerMessage] - The actual message to encrypt
  static Future<SealedSenderEnvelope> seal({
    required SenderCertificate certificate,
    required Uint8List recipientPublicKey,
    required Uint8List innerMessage,
  }) async {
    final x25519 = X25519();
    final aesGcm = AesGcm.with256bits();

    // 1. Generate ephemeral key pair
    final ephemeralKeyPair = await x25519.newKeyPair();
    final ephemeralPublicKey = await ephemeralKeyPair.extractPublicKey();

    // 2. Perform ECDH with recipient's identity key
    final recipientKey = SimplePublicKey(
      recipientPublicKey.toList(),
      type: KeyPairType.x25519,
    );
    final sharedSecret = await x25519.sharedSecretKey(
      keyPair: ephemeralKeyPair,
      remotePublicKey: recipientKey,
    );

    // 3. Derive encryption key using HKDF
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derivedKey = await hkdf.deriveKey(
      secretKey: sharedSecret,
      info: _hkdfLabel.codeUnits,
      nonce: const [],
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
    final secretBox = await aesGcm.encrypt(
      payload.toBytes(),
      secretKey: derivedKey,
    );

    // 6. Build encrypted payload: nonce || ciphertext || mac
    final encryptedPayload = BytesBuilder();
    encryptedPayload.add(secretBox.nonce);
    encryptedPayload.add(secretBox.cipherText);
    encryptedPayload.add(secretBox.mac.bytes);

    return SealedSenderEnvelope(
      version: 1,
      ephemeralPublicKey: Uint8List.fromList(ephemeralPublicKey.bytes),
      encryptedPayload: encryptedPayload.toBytes(),
    );
  }

  /// Unseal a message and reveal sender identity
  ///
  /// [envelope] - The sealed envelope to decrypt
  /// [recipientKeyPair] - Recipient's X25519 key pair
  static Future<UnsealResult> unseal({
    required SealedSenderEnvelope envelope,
    required SimpleKeyPair recipientKeyPair,
  }) async {
    if (envelope.version != 1) {
      throw FormatException(
        'Unsupported envelope version: ${envelope.version}',
      );
    }

    final x25519 = X25519();
    final aesGcm = AesGcm.with256bits();

    // 1. Parse ephemeral public key
    final ephemeralPublicKey = SimplePublicKey(
      envelope.ephemeralPublicKey.toList(),
      type: KeyPairType.x25519,
    );

    // 2. Perform ECDH
    final sharedSecret = await x25519.sharedSecretKey(
      keyPair: recipientKeyPair,
      remotePublicKey: ephemeralPublicKey,
    );

    // 3. Derive decryption key
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derivedKey = await hkdf.deriveKey(
      secretKey: sharedSecret,
      info: _hkdfLabel.codeUnits,
      nonce: const [],
    );

    // 4. Parse encrypted payload: nonce (12) || ciphertext || mac (16)
    final encPayload = envelope.encryptedPayload;
    if (encPayload.length < 12 + 16) {
      throw FormatException('Encrypted payload too short');
    }

    final nonce = encPayload.sublist(0, 12);
    final ciphertextWithMac = encPayload.sublist(12);
    final macBytes = ciphertextWithMac.sublist(ciphertextWithMac.length - 16);
    final cipherText = ciphertextWithMac.sublist(
      0,
      ciphertextWithMac.length - 16,
    );

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

    // 5. Decrypt
    final payload = await aesGcm.decrypt(secretBox, secretKey: derivedKey);

    // 6. Parse payload: cert_length (4) || certificate || inner_message
    if (payload.length < 4) {
      throw FormatException('Payload too short');
    }

    final certLen = ByteData.sublistView(
      Uint8List.fromList(payload),
      0,
      4,
    ).getUint32(0, Endian.big);
    if (payload.length < 4 + certLen) {
      throw FormatException('Invalid certificate length');
    }

    final certBytes = Uint8List.fromList(payload.sublist(4, 4 + certLen));
    final innerMessage = Uint8List.fromList(payload.sublist(4 + certLen));

    final certificate = SenderCertificate.fromBytes(certBytes);

    // 7. Verify certificate signature
    final isValid = await certificate.verify();
    if (!isValid) {
      throw SecurityException('Invalid sender certificate signature');
    }

    // 8. Check certificate expiration
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
  String toString() => 'SecurityException: $message';
}
