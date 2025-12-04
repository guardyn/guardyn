/// Double Ratchet algorithm for forward-secret E2EE messaging
///
/// Based on Signal Protocol specification
/// Compatible with Guardyn backend Rust implementation
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto_exceptions.dart';

// Constants for key derivation (must match backend)
const _chainKeyInfo = 'guardyn-chain-key';
const _messageKeyInfo = 'guardyn-message-key';
const _rootKeyInfo = 'guardyn-root-key';
const _maxSkip = 1000;

/// X25519 key pair for Diffie-Hellman operations
class X25519KeyPair {
  final Uint8List privateKey;
  final Uint8List publicKey;

  X25519KeyPair({required this.privateKey, required this.publicKey});

  /// Generate a new random X25519 key pair
  static Future<X25519KeyPair> generate() async {
    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();
    final privateKeyData = await keyPair.extractPrivateKeyBytes();
    final publicKeyData = (await keyPair.extractPublicKey()).bytes;

    return X25519KeyPair(
      privateKey: Uint8List.fromList(privateKeyData),
      publicKey: Uint8List.fromList(publicKeyData),
    );
  }

  /// Create key pair from existing bytes
  factory X25519KeyPair.fromBytes({
    required Uint8List privateKey,
    required Uint8List publicKey,
  }) {
    if (privateKey.length != 32 || publicKey.length != 32) {
      throw InvalidKeyException('X25519 keys must be 32 bytes');
    }
    return X25519KeyPair(privateKey: privateKey, publicKey: publicKey);
  }

  /// Perform Diffie-Hellman key exchange
  Future<Uint8List> diffieHellman(Uint8List remotePublicKey) async {
    if (remotePublicKey.length != 32) {
      throw InvalidKeyException('Remote public key must be 32 bytes');
    }

    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPairFromSeed(privateKey);
    final remoteKey = SimplePublicKey(remotePublicKey, type: KeyPairType.x25519);

    final sharedSecret = await algorithm.sharedSecretKey(
      keyPair: keyPair,
      remotePublicKey: remoteKey,
    );

    return Uint8List.fromList(await sharedSecret.extractBytes());
  }
}

/// Chain key for symmetric ratchet
class _ChainKey {
  final Uint8List key;

  _ChainKey(this.key) {
    if (key.length != 32) {
      throw InvalidKeyException('Chain key must be 32 bytes');
    }
  }

  /// Derive next chain key using HKDF
  Future<_ChainKey> next() async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final secretKey = SecretKey(key);
    final derived = await hkdf.deriveKey(
      secretKey: secretKey,
      info: utf8.encode(_chainKeyInfo),
      nonce: Uint8List(0),
    );
    return _ChainKey(Uint8List.fromList(await derived.extractBytes()));
  }

  /// Derive message key from current chain key
  Future<_MessageKey> messageKey() async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final secretKey = SecretKey(key);
    final derived = await hkdf.deriveKey(
      secretKey: secretKey,
      info: utf8.encode(_messageKeyInfo),
      nonce: Uint8List(0),
    );
    return _MessageKey(Uint8List.fromList(await derived.extractBytes()));
  }
}

/// Message key for encrypting/decrypting individual messages
class _MessageKey {
  final Uint8List key;

  _MessageKey(this.key) {
    if (key.length != 32) {
      throw InvalidKeyException('Message key must be 32 bytes');
    }
  }

  /// Encrypt plaintext with AES-256-GCM
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List associatedData) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);
    
    // Generate cryptographically secure random nonce (12 bytes)
    final random = Random.secure();
    final nonce = Uint8List.fromList(
      List<int>.generate(12, (_) => random.nextInt(256)),
    );

    final secretBox = await algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonce,
      aad: associatedData,
    );

    // Format: nonce (12 bytes) + ciphertext + mac (16 bytes)
    final result = Uint8List(12 + secretBox.cipherText.length + secretBox.mac.bytes.length);
    result.setRange(0, 12, nonce);
    result.setRange(12, 12 + secretBox.cipherText.length, secretBox.cipherText);
    result.setRange(12 + secretBox.cipherText.length, result.length, secretBox.mac.bytes);

    return result;
  }

  /// Decrypt ciphertext with AES-256-GCM
  Future<Uint8List> decrypt(Uint8List ciphertext, Uint8List associatedData) async {
    if (ciphertext.length < 28) {
      // 12 (nonce) + 16 (min auth tag)
      throw DecryptionException('Ciphertext too short');
    }

    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);

    final nonce = ciphertext.sublist(0, 12);
    final encryptedData = ciphertext.sublist(12, ciphertext.length - 16);
    final mac = Mac(ciphertext.sublist(ciphertext.length - 16));

    final secretBox = SecretBox(
      encryptedData,
      nonce: nonce,
      mac: mac,
    );

    try {
      final decrypted = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
        aad: associatedData,
      );
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw DecryptionException('AES-GCM decryption failed: $e');
    }
  }
}

/// Root key for DH ratchet
class _RootKey {
  final Uint8List key;

  _RootKey(this.key) {
    if (key.length != 32) {
      throw InvalidKeyException('Root key must be 32 bytes');
    }
  }

  /// Perform DH ratchet step: derive new root key and chain key
  Future<(_RootKey, _ChainKey)> dhRatchet(Uint8List dhOutput) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 64);
    final secretKey = SecretKey(dhOutput);

    final derived = await hkdf.deriveKey(
      secretKey: secretKey,
      info: utf8.encode(_rootKeyInfo),
      nonce: key,
    );

    final output = await derived.extractBytes();
    return (
      _RootKey(Uint8List.fromList(output.sublist(0, 32))),
      _ChainKey(Uint8List.fromList(output.sublist(32, 64))),
    );
  }
}

/// Message header containing DH public key and message counter
class MessageHeader {
  final Uint8List dhPublicKey;
  final int previousChainLength;
  final int messageNumber;

  MessageHeader({
    required this.dhPublicKey,
    required this.previousChainLength,
    required this.messageNumber,
  });

  /// Serialize header to bytes
  /// Uses Big-Endian (Network Byte Order) per RFC 1700
  Uint8List toBytes() {
    final bytes = Uint8List(40);
    bytes.setRange(0, 32, dhPublicKey);
    final byteData = ByteData.view(bytes.buffer);
    byteData.setUint32(32, previousChainLength, Endian.big);
    byteData.setUint32(36, messageNumber, Endian.big);
    return bytes;
  }

  /// Deserialize header from bytes
  /// Uses Big-Endian (Network Byte Order) per RFC 1700
  factory MessageHeader.fromBytes(Uint8List bytes) {
    if (bytes.length < 40) {
      throw ProtocolException('Invalid header length');
    }

    final dhPublicKey = Uint8List.fromList(bytes.sublist(0, 32));
    final byteData = ByteData.view(Uint8List.fromList(bytes.sublist(32, 40)).buffer);
    final previousChainLength = byteData.getUint32(0, Endian.big);
    final messageNumber = byteData.getUint32(4, Endian.big);

    return MessageHeader(
      dhPublicKey: dhPublicKey,
      previousChainLength: previousChainLength,
      messageNumber: messageNumber,
    );
  }
}

/// Encrypted message with header
class EncryptedMessage {
  final MessageHeader header;
  final Uint8List ciphertext;

  EncryptedMessage({required this.header, required this.ciphertext});

  /// Serialize message to bytes
  /// Uses Big-Endian (Network Byte Order) per RFC 1700
  Uint8List toBytes() {
    final headerBytes = header.toBytes();
    final result = Uint8List(4 + headerBytes.length + ciphertext.length);
    final byteData = ByteData.view(result.buffer);
    byteData.setUint32(0, headerBytes.length, Endian.big);
    result.setRange(4, 4 + headerBytes.length, headerBytes);
    result.setRange(4 + headerBytes.length, result.length, ciphertext);
    return result;
  }

  /// Deserialize message from bytes
  /// Uses Big-Endian (Network Byte Order) per RFC 1700
  factory EncryptedMessage.fromBytes(Uint8List bytes) {
    if (bytes.length < 4) {
      throw ProtocolException('Message too short');
    }

    final byteData = ByteData.view(bytes.buffer);
    final headerLen = byteData.getUint32(0, Endian.big);

    if (bytes.length < 4 + headerLen) {
      throw ProtocolException('Invalid message format');
    }

    final header = MessageHeader.fromBytes(
      Uint8List.fromList(bytes.sublist(4, 4 + headerLen)),
    );
    final ciphertext = Uint8List.fromList(bytes.sublist(4 + headerLen));

    return EncryptedMessage(header: header, ciphertext: ciphertext);
  }
}

/// Double Ratchet state for E2EE messaging
class DoubleRatchet {
  // DH ratchet state
  late X25519KeyPair _dhSelf;
  Uint8List? _dhRemote;

  // Root key
  late _RootKey _rootKey;

  // Sending chain
  _ChainKey? _sendingChainKey;
  int _sendingMessageNumber = 0;

  // Receiving chain
  _ChainKey? _receivingChainKey;
  int _receivingMessageNumber = 0;

  // Previous sending chain length
  int _previousChainLength = 0;

  // Skipped message keys for out-of-order handling
  final Map<String, _MessageKey> _skippedMessageKeys = {};

  DoubleRatchet._();

  /// Initialize Double Ratchet as sender (Alice)
  static Future<DoubleRatchet> initAlice(
    Uint8List sharedSecret,
    Uint8List bobPublicKey,
  ) async {
    if (sharedSecret.length != 32) {
      throw InvalidKeyException('Shared secret must be 32 bytes');
    }

    final ratchet = DoubleRatchet._();
    ratchet._dhSelf = await X25519KeyPair.generate();
    ratchet._dhRemote = bobPublicKey;

    // Derive initial root key from X3DH shared secret
    ratchet._rootKey = _RootKey(Uint8List.fromList(sharedSecret));

    // Perform initial DH ratchet
    final dhOutput = await ratchet._dhSelf.diffieHellman(bobPublicKey);
    final (newRootKey, sendingChainKey) = await ratchet._rootKey.dhRatchet(dhOutput);
    ratchet._rootKey = newRootKey;
    ratchet._sendingChainKey = sendingChainKey;

    return ratchet;
  }

  /// Initialize Double Ratchet as receiver (Bob)
  static Future<DoubleRatchet> initBob(Uint8List sharedSecret) async {
    if (sharedSecret.length != 32) {
      throw InvalidKeyException('Shared secret must be 32 bytes');
    }

    final ratchet = DoubleRatchet._();
    ratchet._dhSelf = await X25519KeyPair.generate();
    ratchet._rootKey = _RootKey(Uint8List.fromList(sharedSecret));

    return ratchet;
  }

  /// Get current DH public key
  Uint8List get publicKey => _dhSelf.publicKey;

  /// Encrypt a message
  Future<EncryptedMessage> encrypt(
    Uint8List plaintext,
    Uint8List associatedData,
  ) async {
    final chainKey = _sendingChainKey;
    if (chainKey == null) {
      throw ProtocolException('No sending chain key');
    }

    final messageKey = await chainKey.messageKey();
    final ciphertext = await messageKey.encrypt(plaintext, associatedData);

    final header = MessageHeader(
      dhPublicKey: publicKey,
      previousChainLength: _previousChainLength,
      messageNumber: _sendingMessageNumber,
    );

    // Advance sending chain
    _sendingChainKey = await chainKey.next();
    _sendingMessageNumber++;

    return EncryptedMessage(header: header, ciphertext: ciphertext);
  }

  /// Decrypt a message
  Future<Uint8List> decrypt(
    EncryptedMessage message,
    Uint8List associatedData,
  ) async {
    // Check if we have a skipped message key
    final skipKey = _makeSkipKey(message.header.dhPublicKey, message.header.messageNumber);
    if (_skippedMessageKeys.containsKey(skipKey)) {
      final messageKey = _skippedMessageKeys.remove(skipKey)!;
      return messageKey.decrypt(message.ciphertext, associatedData);
    }

    // Check if we need to perform DH ratchet
    if (_dhRemote != null) {
      if (!_bytesEqual(message.header.dhPublicKey, _dhRemote!)) {
        await _dhRatchetReceive(message.header);
      }
    } else {
      // First message from remote
      await _dhRatchetReceive(message.header);
    }

    // Skip messages if needed
    await _skipMessageKeys(message.header.messageNumber);

    // Decrypt the message
    final chainKey = _receivingChainKey;
    if (chainKey == null) {
      throw ProtocolException('No receiving chain key');
    }

    final messageKey = await chainKey.messageKey();
    final plaintext = await messageKey.decrypt(message.ciphertext, associatedData);

    // Advance receiving chain
    _receivingChainKey = await chainKey.next();
    _receivingMessageNumber++;

    return plaintext;
  }

  /// Perform DH ratchet when receiving new public key
  Future<void> _dhRatchetReceive(MessageHeader header) async {
    // Store previous chain length
    _previousChainLength = _sendingMessageNumber;
    _sendingMessageNumber = 0;
    _receivingMessageNumber = 0;

    // Update remote DH key
    _dhRemote = header.dhPublicKey;

    // Perform DH and derive new receiving chain
    final dhOutput = await _dhSelf.diffieHellman(header.dhPublicKey);
    final (newRootKey, receivingChainKey) = await _rootKey.dhRatchet(dhOutput);
    _rootKey = newRootKey;
    _receivingChainKey = receivingChainKey;

    // Generate new DH key pair and derive new sending chain
    _dhSelf = await X25519KeyPair.generate();
    final dhOutput2 = await _dhSelf.diffieHellman(header.dhPublicKey);
    final (finalRootKey, sendingChainKey) = await _rootKey.dhRatchet(dhOutput2);
    _rootKey = finalRootKey;
    _sendingChainKey = sendingChainKey;
  }

  /// Skip message keys for out-of-order handling
  Future<void> _skipMessageKeys(int until) async {
    if (_receivingMessageNumber + _maxSkip < until) {
      throw ProtocolException('Too many skipped messages');
    }

    final chainKey = _receivingChainKey;
    if (chainKey == null) return;

    var currentKey = chainKey;
    while (_receivingMessageNumber < until) {
      final messageKey = await currentKey.messageKey();
      final skipKey = _makeSkipKey(_dhRemote!, _receivingMessageNumber);
      _skippedMessageKeys[skipKey] = messageKey;
      currentKey = await currentKey.next();
      _receivingMessageNumber++;
    }
    _receivingChainKey = currentKey;
    _receivingMessageNumber = 0;
  }

  String _makeSkipKey(Uint8List dhKey, int messageNumber) {
    return '${base64Encode(dhKey)}:$messageNumber';
  }

  bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Serialize ratchet state for storage
  Map<String, dynamic> serialize() {
    return {
      'dh_self_private': base64Encode(_dhSelf.privateKey),
      'dh_self_public': base64Encode(_dhSelf.publicKey),
      'dh_remote': _dhRemote != null ? base64Encode(_dhRemote!) : null,
      'root_key': base64Encode(_rootKey.key),
      'sending_chain_key':
          _sendingChainKey != null ? base64Encode(_sendingChainKey!.key) : null,
      'sending_message_number': _sendingMessageNumber,
      'receiving_chain_key':
          _receivingChainKey != null ? base64Encode(_receivingChainKey!.key) : null,
      'receiving_message_number': _receivingMessageNumber,
      'previous_chain_length': _previousChainLength,
      'skipped_keys': _skippedMessageKeys.map(
        (key, value) => MapEntry(key, base64Encode(value.key)),
      ),
    };
  }

  /// Deserialize ratchet state from storage
  static DoubleRatchet deserialize(Map<String, dynamic> data) {
    final ratchet = DoubleRatchet._();

    ratchet._dhSelf = X25519KeyPair.fromBytes(
      privateKey: base64Decode(data['dh_self_private']),
      publicKey: base64Decode(data['dh_self_public']),
    );

    if (data['dh_remote'] != null) {
      ratchet._dhRemote = base64Decode(data['dh_remote']);
    }

    ratchet._rootKey = _RootKey(base64Decode(data['root_key']));

    if (data['sending_chain_key'] != null) {
      ratchet._sendingChainKey = _ChainKey(base64Decode(data['sending_chain_key']));
    }
    ratchet._sendingMessageNumber = data['sending_message_number'] ?? 0;

    if (data['receiving_chain_key'] != null) {
      ratchet._receivingChainKey = _ChainKey(base64Decode(data['receiving_chain_key']));
    }
    ratchet._receivingMessageNumber = data['receiving_message_number'] ?? 0;

    ratchet._previousChainLength = data['previous_chain_length'] ?? 0;

    final skippedKeys = data['skipped_keys'] as Map<String, dynamic>? ?? {};
    for (final entry in skippedKeys.entries) {
      ratchet._skippedMessageKeys[entry.key] =
          _MessageKey(base64Decode(entry.value as String));
    }

    return ratchet;
  }
}
