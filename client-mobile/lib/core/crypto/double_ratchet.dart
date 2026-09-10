/// Double Ratchet algorithm for forward-secret E2EE messaging
///
/// Based on Signal Protocol specification
/// Compatible with Guardyn backend Rust implementation
///
/// NOTE: This implementation uses CryptoPrimitives which can use either
/// pure Dart or native Rust FFI depending on platform availability.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'crypto_exceptions.dart';
import 'crypto_primitives.dart';

// Constants for key derivation (must match backend)
const _chainKeyInfo = 'guardyn-chain-key';
const _messageKeyInfo = 'guardyn-message-key';
const _rootKeyInfo = 'guardyn-root-key';
const _maxSkip = 1000;

/// Ratchet wire format version, emitted as byte 0 of every serialized message.
///
/// Must match `WIRE_VERSION` in `backend/crates/crypto/src/double_ratchet.rs`. The pre-v1
/// format had no version byte and began with the high byte of a big-endian u32 header
/// length - always 0x00 for a 40-byte header - so 0x01 cannot be mistaken for it.
/// See docs/adr/ADR-0011-ratchet-header-authentication.md.
const _wireVersion = 1;

/// X25519 key pair for Diffie-Hellman operations
class X25519KeyPair {
  final Uint8List privateKey;
  final Uint8List publicKey;

  X25519KeyPair({required this.privateKey, required this.publicKey});

  /// Generate a new random X25519 key pair
  static Future<X25519KeyPair> generate() async {
    final (publicKey, privateKey) =
        await CryptoPrimitives.generateX25519KeyPair();
    return X25519KeyPair(privateKey: privateKey, publicKey: publicKey);
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

    return CryptoPrimitives.x25519DiffieHellman(
      privateKey: privateKey,
      remotePublicKey: remotePublicKey,
    );
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
    final derived = await CryptoPrimitives.hkdf(
      inputKeyMaterial: key,
      info: utf8.encode(_chainKeyInfo),
      salt: null,
      outputLength: 32,
    );
    return _ChainKey(derived);
  }

  /// Derive message key from current chain key
  Future<_MessageKey> messageKey() async {
    final derived = await CryptoPrimitives.hkdf(
      inputKeyMaterial: key,
      info: utf8.encode(_messageKeyInfo),
      salt: null,
      outputLength: 32,
    );
    return _MessageKey(derived);
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
    // Use CryptoPrimitives for AES-GCM encryption
    final (ciphertext, nonce, tag) = await CryptoPrimitives.encryptAesGcm(
      plaintext: plaintext,
      key: key,
      nonce: null, // Auto-generate nonce
      associatedData: associatedData,
    );

    // Format: nonce (12 bytes) + ciphertext + tag (16 bytes)
    final result = Uint8List(nonce.length + ciphertext.length + tag.length);
    result.setRange(0, nonce.length, nonce);
    result.setRange(nonce.length, nonce.length + ciphertext.length, ciphertext);
    result.setRange(nonce.length + ciphertext.length, result.length, tag);

    return result;
  }

  /// Decrypt ciphertext with AES-256-GCM
  Future<Uint8List> decrypt(
    Uint8List ciphertextWithNonceAndTag,
    Uint8List associatedData,
  ) async {
    if (ciphertextWithNonceAndTag.length < 28) {
      // 12 (nonce) + 16 (min auth tag)
      throw DecryptionException('Ciphertext too short');
    }

    // Parse: nonce (12 bytes) + ciphertext + tag (16 bytes)
    final nonce = Uint8List.fromList(ciphertextWithNonceAndTag.sublist(0, 12));
    final ciphertext = Uint8List.fromList(
      ciphertextWithNonceAndTag.sublist(
        12,
        ciphertextWithNonceAndTag.length - 16,
      ),
    );
    final tag = Uint8List.fromList(
      ciphertextWithNonceAndTag.sublist(ciphertextWithNonceAndTag.length - 16),
    );

    try {
      return await CryptoPrimitives.decryptAesGcm(
        ciphertext: ciphertext,
        nonce: nonce,
        tag: tag,
        key: key,
        associatedData: associatedData,
      );
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
  ///
  /// Uses HKDF with the current root key as salt and DH output as input
  Future<(_RootKey, _ChainKey)> dhRatchet(Uint8List dhOutput) async {
    // Derive 64 bytes: first 32 for new root key, last 32 for chain key
    final derived = await CryptoPrimitives.hkdf(
      inputKeyMaterial: dhOutput,
      info: utf8.encode(_rootKeyInfo),
      salt: key, // Use current root key as salt
      outputLength: 64,
    );

    return (
      _RootKey(Uint8List.fromList(derived.sublist(0, 32))),
      _ChainKey(Uint8List.fromList(derived.sublist(32, 64))),
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
    final result = Uint8List(5 + headerBytes.length + ciphertext.length);
    result[0] = _wireVersion;
    final byteData = ByteData.view(result.buffer);
    byteData.setUint32(1, headerBytes.length, Endian.big);
    result.setRange(5, 5 + headerBytes.length, headerBytes);
    result.setRange(5 + headerBytes.length, result.length, ciphertext);
    return result;
  }

  /// Deserialize message from bytes
  /// Uses Big-Endian (Network Byte Order) per RFC 1700
  factory EncryptedMessage.fromBytes(Uint8List bytes) {
    if (bytes.length < 5) {
      throw ProtocolException('Message too short: ${bytes.length} bytes');
    }

    if (bytes[0] != _wireVersion) {
      throw ProtocolException(
        'Unsupported ratchet message version ${bytes[0]} (expected $_wireVersion)',
      );
    }

    // IMPORTANT: Use offsetInBytes to handle bytes created from base64.decode
    // which may have non-zero offset in the underlying buffer
    final byteData = ByteData.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    final headerLen = byteData.getUint32(1, Endian.big);

    final bodyStart = 5 + headerLen;
    if (bytes.length < bodyStart) {
      throw ProtocolException(
        'Invalid message format: need $bodyStart bytes, got ${bytes.length}',
      );
    }

    final header = MessageHeader.fromBytes(
      Uint8List.fromList(bytes.sublist(5, bodyStart)),
    );
    final ciphertext = Uint8List.fromList(bytes.sublist(bodyStart));

    return EncryptedMessage(header: header, ciphertext: ciphertext);
  }
}

/// Associated data for the AEAD: the caller's context, then the wire header.
///
/// Mirrors `aad_with_header` in `backend/crates/crypto/src/double_ratchet.rs`. The Signal
/// Double Ratchet binds the header into the associated data (`AD = AD_initial || header`)
/// so that an attacker who can modify a message in flight cannot rewrite `dhPublicKey`,
/// `previousChainLength` or `messageNumber` without invalidating the tag. Those 40 bytes
/// were previously unauthenticated on this client, and `messageNumber` in particular drives
/// [DoubleRatchet._skipMessageKeys].
///
/// Note the version byte and the length prefix are deliberately NOT included - only the 40
/// header bytes - because that is what the Rust side binds.
Uint8List _aadWithHeader(Uint8List associatedData, MessageHeader header) {
  final headerBytes = header.toBytes();
  final aad = Uint8List(associatedData.length + headerBytes.length);
  aad.setRange(0, associatedData.length, associatedData);
  aad.setRange(associatedData.length, aad.length, headerBytes);
  return aad;
}

String _makeSkipKey(Uint8List dhKey, int messageNumber) =>
    '${base64Encode(dhKey)}:$messageNumber';

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// A pending receive-side ratchet transition, applied only once the tag verifies.
///
/// Mirrors `ReceiveStaging` in `backend/crates/crypto/src/double_ratchet.rs`.
///
/// Receiving a message can advance the DH ratchet and derive skipped message keys, and both
/// used to happen before the AEAD tag was checked. A forged header naming an unknown DH
/// public key therefore rotated the root key and both chain keys, which walks the chain past
/// every genuine message and leaves the session unrecoverable without a new handshake.
///
/// Staging the transition and swapping it in only on success makes decryption atomic.
/// Copying the ratchet wholesale would have been simpler, but it carries
/// [DoubleRatchet._skippedMessageKeys] - up to `_maxSkip` entries - and allocating that on
/// every message to guard against a rare failure is the wrong trade. Every field here is
/// fixed-size, and the key types are immutable value objects, so copying references is a
/// genuine snapshot rather than shared state.
class _ReceiveStaging {
  X25519KeyPair dhSelf;
  Uint8List? dhRemote;
  _RootKey rootKey;
  _ChainKey? sendingChainKey;
  int sendingMessageNumber;
  _ChainKey? receivingChainKey;
  int receivingMessageNumber;
  int previousChainLength;

  _ReceiveStaging({
    required this.dhSelf,
    required this.dhRemote,
    required this.rootKey,
    required this.sendingChainKey,
    required this.sendingMessageNumber,
    required this.receivingChainKey,
    required this.receivingMessageNumber,
    required this.previousChainLength,
  });

  factory _ReceiveStaging.fromRatchet(DoubleRatchet r) => _ReceiveStaging(
        dhSelf: r._dhSelf,
        dhRemote: r._dhRemote,
        rootKey: r._rootKey,
        sendingChainKey: r._sendingChainKey,
        sendingMessageNumber: r._sendingMessageNumber,
        receivingChainKey: r._receivingChainKey,
        receivingMessageNumber: r._receivingMessageNumber,
        previousChainLength: r._previousChainLength,
      );

  void commitInto(DoubleRatchet r) {
    r._dhSelf = dhSelf;
    r._dhRemote = dhRemote;
    r._rootKey = rootKey;
    r._sendingChainKey = sendingChainKey;
    r._sendingMessageNumber = sendingMessageNumber;
    r._receivingChainKey = receivingChainKey;
    r._receivingMessageNumber = receivingMessageNumber;
    r._previousChainLength = previousChainLength;
  }

  /// Perform the DH ratchet step for a newly seen remote public key.
  Future<void> dhRatchetReceive(MessageHeader header) async {
    previousChainLength = sendingMessageNumber;
    sendingMessageNumber = 0;
    receivingMessageNumber = 0;

    dhRemote = header.dhPublicKey;

    final dhOutput = await dhSelf.diffieHellman(header.dhPublicKey);
    final (newRootKey, newReceivingChainKey) = await rootKey.dhRatchet(dhOutput);
    rootKey = newRootKey;
    receivingChainKey = newReceivingChainKey;

    dhSelf = await X25519KeyPair.generate();
    final dhOutput2 = await dhSelf.diffieHellman(header.dhPublicKey);
    final (finalRootKey, newSendingChainKey) = await rootKey.dhRatchet(dhOutput2);
    rootKey = finalRootKey;
    sendingChainKey = newSendingChainKey;
  }

  /// Derive message keys for messages that arrived out of order.
  ///
  /// Keys are collected into [out] rather than inserted, so the caller can discard them if
  /// the tag then fails. [alreadyStored] is the committed map's length, which the `_maxSkip`
  /// bound counts against - otherwise each forged message could stage up to the limit afresh
  /// and the bound would mean nothing.
  ///
  /// On return [receivingMessageNumber] is `until`, so the caller's own increment leaves it
  /// at `until + 1`.
  Future<void> skipMessageKeys(
    int until,
    int alreadyStored,
    Map<String, _MessageKey> out,
  ) async {
    final chainKey = receivingChainKey;
    if (chainKey == null) return;

    var currentKey = chainKey;
    while (receivingMessageNumber < until) {
      if (alreadyStored + out.length >= _maxSkip) {
        throw ProtocolException('Too many skipped messages (max: $_maxSkip)');
      }

      final messageKey = await currentKey.messageKey();
      out[_makeSkipKey(dhRemote!, receivingMessageNumber)] = messageKey;
      currentKey = await currentKey.next();
      receivingMessageNumber++;
    }
    receivingChainKey = currentKey;
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

  /// Check if session has a sending chain key (can encrypt)
  bool get hasSendingChainKey => _sendingChainKey != null;

  /// Check if session has a receiving chain key (has received messages)
  bool get hasReceivingChainKey => _receivingChainKey != null;

  /// Check if session is fully established (can both send and receive)
  bool get isFullyEstablished => hasSendingChainKey;

  /// Encrypt a message
  Future<EncryptedMessage> encrypt(
    Uint8List plaintext,
    Uint8List associatedData,
  ) async {
    final chainKey = _sendingChainKey;
    if (chainKey == null) {
      throw ProtocolException('No sending chain key');
    }

    // The header must exist before encryption now, because it is part of the AAD.
    final header = MessageHeader(
      dhPublicKey: publicKey,
      previousChainLength: _previousChainLength,
      messageNumber: _sendingMessageNumber,
    );

    final messageKey = await chainKey.messageKey();
    final ciphertext = await messageKey.encrypt(
      plaintext,
      _aadWithHeader(associatedData, header),
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
    final aad = _aadWithHeader(associatedData, message.header);

    // Check if we have a skipped message key
    final skipKey = _makeSkipKey(
      message.header.dhPublicKey,
      message.header.messageNumber,
    );
    final skipped = _skippedMessageKeys[skipKey];
    if (skipped != null) {
      // Decrypt first: a failure must not consume the stored key, or one forged message
      // would destroy the ability to read the genuine one it names.
      final plaintext = await skipped.decrypt(message.ciphertext, aad);
      _skippedMessageKeys.remove(skipKey);
      return plaintext;
    }

    // Everything below is staged. `this` is not touched until the tag verifies, so an
    // authentication failure - or a forged header that trips _maxSkip - leaves the session
    // exactly as it was.
    final staged = _ReceiveStaging.fromRatchet(this);
    final newlySkipped = <String, _MessageKey>{};

    // Check if we need to perform DH ratchet
    final remote = staged.dhRemote;
    if (remote == null || !_bytesEqual(message.header.dhPublicKey, remote)) {
      // Either the remote rotated its key, or this is the first message from it.
      await staged.dhRatchetReceive(message.header);
    }

    // Skip messages if needed
    await staged.skipMessageKeys(
      message.header.messageNumber,
      _skippedMessageKeys.length,
      newlySkipped,
    );

    // Decrypt the message
    final chainKey = staged.receivingChainKey;
    if (chainKey == null) {
      throw ProtocolException('No receiving chain key');
    }

    final messageKey = await chainKey.messageKey();

    // The gate. Nothing above this line has been committed.
    final plaintext = await messageKey.decrypt(message.ciphertext, aad);

    // Advance receiving chain, then commit.
    staged.receivingChainKey = await chainKey.next();
    staged.receivingMessageNumber++;
    staged.commitInto(this);
    _skippedMessageKeys.addAll(newlySkipped);

    return plaintext;
  }

  /// Number of skipped message keys currently held.
  ///
  /// Mirrors `skipped_messages_count` in the Rust implementation. Useful for asserting that
  /// a rejected message left no partial state behind.
  int get skippedMessagesCount => _skippedMessageKeys.length;

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
