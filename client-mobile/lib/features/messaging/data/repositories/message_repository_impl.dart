import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/crypto/crypto_exceptions.dart';
import '../../../../core/crypto/message_aad.dart';
import '../../../../core/crypto/undecryptable_message.dart';
import '../../../../core/crypto/crypto_service.dart';
import '../../../../core/crypto/x3dh.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/conversation_utils.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/key_exchange_datasource.dart';
import '../datasources/message_remote_datasource.dart';
import '../models/message_model.dart';

@Injectable(as: MessageRepository)
class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDatasource remoteDatasource;
  final KeyExchangeDatasource keyExchangeDatasource;
  final SecureStorage secureStorage;
  final CryptoService cryptoService;
  final Logger _logger = Logger();

  MessageRepositoryImpl(
    this.remoteDatasource,
    this.keyExchangeDatasource,
    this.secureStorage,
    this.cryptoService,
  );

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String recipientUserId,
    required String recipientDeviceId,
    required String recipientUsername,
    required String textContent,
    Map<String, String>? metadata,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        _logger.e('sendMessage: No access token found');
        return const Left(AuthFailure('No access token found'));
      }

      // Get current user info for conversation ID
      final currentUserId = await secureStorage.getUserId();
      final currentDeviceId = await secureStorage.getDeviceId();

      if (currentUserId == null || currentDeviceId == null) {
        _logger.e(
          'sendMessage: User not authenticated - userId: $currentUserId, deviceId: $currentDeviceId',
        );
        return const Left(AuthFailure('User not authenticated'));
      }

      // For media messages with empty textContent, use JSON with media metadata as content
      // This ensures encrypted_content is never empty for the backend
      String contentToEncrypt = textContent;
      if (textContent.isEmpty && metadata != null && metadata['media_id'] != null) {
        contentToEncrypt = json.encode({
          'type': 'media',
          'media_id': metadata['media_id'],
          'media_type': metadata['media_type'] ?? 'image',
          'filename': metadata['filename'] ?? '',
          'mime_type': metadata['mime_type'] ?? '',
        });
        _logger.i('Created media message content: $contentToEncrypt');
      }

      // E2EE: Encrypt message content with Double Ratchet
      // This also returns X3DH prekey data if this is the first message
      final (encryptedContent, x3dhPrekey) = await _encryptMessageWithPrekey(
        plaintext: contentToEncrypt,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        currentUserId: currentUserId,
      );

      // Include X3DH prekey in metadata for first message
      final messageMetadata = Map<String, String>.from(metadata ?? {});
      if (x3dhPrekey != null) {
        messageMetadata['x3dh_prekey'] = x3dhPrekey;
        _logger.i('Including X3DH prekey in first message');
      }

      // Send encrypted message via datasource (with X3DH prekey via proto field)
      final messageModel = await remoteDatasource.sendMessage(
        accessToken: accessToken,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        recipientUsername: recipientUsername,
        textContent: encryptedContent, // Encrypted content
        metadata: messageMetadata,
        x3dhPrekey: x3dhPrekey, // Pass via dedicated proto field
      );

      // Create complete message with sender info
      final conversationId = _deriveConversationId(
        currentUserId,
        recipientUserId,
      );

      final completeMessage = MessageModel(
        messageId: messageModel.messageId,
        conversationId: conversationId,
        senderUserId: currentUserId,
        senderDeviceId: currentDeviceId,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        messageType: messageModel.messageType,
        textContent: textContent, // Store plaintext locally for display
        metadata: metadata ?? {},
        timestamp: messageModel.timestamp,
        deliveryStatus: messageModel.deliveryStatus,
        currentUserId: currentUserId,
      );

      return Right(completeMessage);
    } on EncryptionUnavailableException catch (e) {
      // Nothing was sent. The caller must surface this: a message that cannot be encrypted is
      // not sent at all.
      return Left(CryptoFailure(e.message));
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationUserId,
    String? conversationId,
    int limit = 50,
    String? beforeMessageId,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Get current user ID for determining sent/received
      final currentUserId = await secureStorage.getUserId();

      // Generate conversation ID if not provided
      // Backend requires conversation_id for GetMessages
      final effectiveConversationId =
          conversationId ??
          (currentUserId != null
              ? _deriveConversationId(currentUserId, conversationUserId)
              : null);

      // Fetch messages via datasource
      final messages = await remoteDatasource.getMessages(
        accessToken: accessToken,
        conversationUserId: conversationUserId,
        conversationId: effectiveConversationId,
        limit: limit,
        beforeMessageId: beforeMessageId,
        currentUserId: currentUserId,
      );

      // E2EE: Decrypt received messages
      if (currentUserId != null) {
        final decryptedMessages = <Message>[];
        for (final message in messages) {
          // Extract X3DH prekey from message metadata (for first message in session)
          final x3dhPrekey = message.metadata['x3dh_prekey'];

          final decrypted = await _decryptMessage(
            encryptedContent: message.textContent,
            senderUserId: message.senderUserId,
            senderDeviceId: message.senderDeviceId,
            currentUserId: currentUserId,
            x3dhPrekey: x3dhPrekey,
          );
          decryptedMessages.add(
            MessageModel(
              messageId: message.messageId,
              conversationId: message.conversationId,
              senderUserId: message.senderUserId,
              senderDeviceId: message.senderDeviceId,
              recipientUserId: message.recipientUserId,
              recipientDeviceId: message.recipientDeviceId,
              messageType: message.messageType,
              textContent: decrypted.text,
              metadata: decrypted.metadataFrom(message.metadata),
              timestamp: message.timestamp,
              deliveryStatus: message.deliveryStatus,
              currentUserId: currentUserId,
            ),
          );
        }
        return Right(decryptedMessages);
      }

      return Right(messages);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Message>> receiveMessages() async* {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        yield const Left(AuthFailure('No access token found'));
        return;
      }

      // Get current user ID
      final currentUserId = await secureStorage.getUserId();

      // Subscribe to message stream
      final messageStream = remoteDatasource.receiveMessages(
        accessToken: accessToken,
        currentUserId: currentUserId,
      );

      await for (final message in messageStream) {
        // E2EE: Decrypt received message
        if (currentUserId != null) {
          // Extract X3DH prekey from message metadata (for first message in session)
          final x3dhPrekey = message.metadata['x3dh_prekey'];

          final decrypted = await _decryptMessage(
            encryptedContent: message.textContent,
            senderUserId: message.senderUserId,
            senderDeviceId: message.senderDeviceId,
            currentUserId: currentUserId,
            x3dhPrekey: x3dhPrekey,
          );
          yield Right(
            MessageModel(
              messageId: message.messageId,
              conversationId: message.conversationId,
              senderUserId: message.senderUserId,
              senderDeviceId: message.senderDeviceId,
              recipientUserId: message.recipientUserId,
              recipientDeviceId: message.recipientDeviceId,
              messageType: message.messageType,
              textContent: decrypted.text,
              metadata: decrypted.metadataFrom(message.metadata),
              timestamp: message.timestamp,
              deliveryStatus: message.deliveryStatus,
              currentUserId: currentUserId,
            ),
          );
        } else {
          yield Right(message);
        }
      }
    } on GrpcError catch (e) {
      yield Left(_handleGrpcError(e));
    } catch (e) {
      yield Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({required String messageId}) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Mark as read via datasource
      await remoteDatasource.markAsRead(
        accessToken: accessToken,
        messageIds: [messageId],
      );

      return const Right(null);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage({
    required String messageId,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // For delete, we need conversation ID (TODO: pass it from UI or fetch from local DB)
      const conversationId = 'temp-conversation-id';

      // Delete message via datasource
      await remoteDatasource.deleteMessage(
        accessToken: accessToken,
        messageId: messageId,
        conversationId: conversationId,
        deleteForEveryone: false,
      );

      return const Right(null);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> clearChat({
    required String conversationId,
  }) async {
    try {
      // Get access token
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Clear chat via datasource
      final deletedCount = await remoteDatasource.clearChat(
        accessToken: accessToken,
        conversationId: conversationId,
      );

      return Right(deletedCount);
    } on GrpcError catch (e) {
      return Left(_handleGrpcError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> decryptMessageContent({
    required String encryptedContent,
    required String senderUserId,
    required String senderDeviceId,
    String? x3dhPrekey,
  }) async {
    try {
      final currentUserId = await secureStorage.getUserId();
      if (currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      final decrypted = await _decryptMessage(
        encryptedContent: encryptedContent,
        senderUserId: senderUserId,
        senderDeviceId: senderDeviceId,
        currentUserId: currentUserId,
        x3dhPrekey: x3dhPrekey,
      );

      // Returns the placeholder rather than the content it could not decrypt. _decryptMessage
      // already handles the expected failures, so reaching this as a Right with the original
      // content - which is what used to happen - meant handing the caller ciphertext labelled
      // as plaintext.
      return Right(decrypted.text);
    } catch (e) {
      _logger.e('Failed to decrypt message: $e');
      return const Right(undecryptableMessagePlaceholder);
    }
  }

  // Helper methods

  /// Generate deterministic conversation ID using UUID v5.
  /// This matches the backend implementation.
  String _deriveConversationId(String userId1, String userId2) {
    return ConversationUtils.generateConversationId(userId1, userId2);
  }

  Failure _handleGrpcError(GrpcError error) {
    switch (error.code) {
      case StatusCode.unauthenticated:
        return AuthFailure(error.message ?? 'Authentication failed');
      case StatusCode.unavailable:
        return const NetworkFailure('Service unavailable');
      case StatusCode.deadlineExceeded:
        return const NetworkFailure('Request timeout');
      case StatusCode.notFound:
        return ServerFailure(error.message ?? 'Resource not found');
      default:
        return ServerFailure(error.message ?? 'Server error');
    }
  }

  // E2EE encryption/decryption methods

  /// Encrypt message content with Double Ratchet
  ///
  /// If no session exists, creates one via X3DH key exchange.
  /// Returns a tuple of (encrypted content, X3DH prekey data for first message)
  Future<(String encryptedContent, String? x3dhPrekey)>
  _encryptMessageWithPrekey({
    required String plaintext,
    required String recipientUserId,
    required String recipientDeviceId,
    required String currentUserId,
  }) async {
    String? x3dhPrekey;

    // Check if E2EE session exists
    var session = await cryptoService.getSession(
      remoteUserId: recipientUserId,
      remoteDeviceId: recipientDeviceId,
    );

    // No session? Create one via X3DH key exchange
    if (session == null) {
      _logger.i(
        'No E2EE session for $recipientUserId:$recipientDeviceId, initiating X3DH',
      );
      try {
        final prekeyMessage = await _createE2ESessionWithPrekey(
          recipientUserId: recipientUserId,
          recipientDeviceId: recipientDeviceId,
        );
        // Re-fetch session after creation
        session = await cryptoService.getSession(
          remoteUserId: recipientUserId,
          remoteDeviceId: recipientDeviceId,
        );
        // Get X3DH prekey data for first message
        x3dhPrekey = prekeyMessage?.toBase64();
        _logger.i(
          'E2EE session created successfully, prekey: ${x3dhPrekey != null}',
        );
      } on Object catch (e) {
        // Fail closed. This used to return the plaintext, which handed the server the
        // message in the clear precisely when encryption was least healthy - and returned
        // Right(), so the UI showed an ordinary sent bubble and nobody could tell.
        _logger.e('Failed to create E2EE session for $recipientUserId');
        throw EncryptionUnavailableException(
          'Could not establish an encrypted session with the recipient: $e',
        );
      }
    }

    // Encrypt with Double Ratchet
    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final associatedData = messageAssociatedData(
      senderUserId: currentUserId,
      recipientUserId: recipientUserId,
    );

    try {
      final encrypted = await cryptoService.encrypt(
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        plaintext: plaintextBytes,
        associatedData: associatedData,
      );
      _logger.d('Message encrypted successfully (${encrypted.length} bytes)');
      // Return as base64 for safe transmission
      final encryptedBase64 = base64.encode(encrypted);
      return (encryptedBase64, x3dhPrekey);
    } on Object catch (e) {
      // Fail closed - see the session-creation branch above.
      _logger.e('Encryption failed for $recipientUserId');
      throw EncryptionUnavailableException('Could not encrypt the message: $e');
    }
  }

  /// Create E2EE session via X3DH key exchange
  /// Returns X3DH prekey message to include in first message
  Future<X3DHPrekeyMessage?> _createE2ESessionWithPrekey({
    required String recipientUserId,
    required String recipientDeviceId,
  }) async {
    // Get access token for fetching key bundle
    final accessToken = await secureStorage.getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token for key exchange');
    }

    // Fetch recipient's X3DH KeyBundle from server
    final remoteKeyBundle = await keyExchangeDatasource.getKeyBundle(
      accessToken: accessToken,
      userId: recipientUserId,
      deviceId: recipientDeviceId.isNotEmpty ? recipientDeviceId : null,
    );

    // Create E2EE session as initiator (Alice) - now returns prekey message
    final (_, prekeyMessage) = await cryptoService.createSessionAsInitiator(
      recipientUserId: recipientUserId,
      recipientDeviceId: recipientDeviceId,
      remoteKeyBundle: remoteKeyBundle,
    );

    return prekeyMessage;
  }

  /// Decrypt message content with Double Ratchet
  ///
  /// Returns plaintext if decryption successful, or original content if not encrypted.
  /// Handles both base64-encoded content (from WebSocket) and raw bytes (from gRPC).
  /// If X3DH prekey data is provided, creates responder session first.
  Future<_DecryptedContent> _decryptMessage({
    required String encryptedContent,
    required String senderUserId,
    required String senderDeviceId,
    required String currentUserId,
    String? x3dhPrekey,
  }) async {
    // An empty payload is a media-only message, not a failure - there is nothing to decrypt
    // and nothing to warn about.
    if (encryptedContent.isEmpty) {
      return const _DecryptedContent.plaintext('');
    }

    // Check if E2EE session exists
    var session = await cryptoService.getSession(
      remoteUserId: senderUserId,
      remoteDeviceId: senderDeviceId,
    );

    // If no session but we have X3DH prekey data, create responder session
    if (session == null && x3dhPrekey != null && x3dhPrekey.isNotEmpty) {
      _logger.i('Creating responder session with X3DH prekey data');
      try {
        await _createResponderSession(
          senderUserId: senderUserId,
          senderDeviceId: senderDeviceId,
          x3dhPrekey: x3dhPrekey,
        );
        // Re-fetch session after creation (from memory cache, not storage)
        session = await cryptoService.getSession(
          remoteUserId: senderUserId,
          remoteDeviceId: senderDeviceId,
        );
        _logger.i('Responder session created successfully');
      } catch (e) {
        // Leaves `session` null, so the check below returns the placeholder. Previously that
        // path returned the raw content instead.
        _logger.e('Failed to create responder session: $e');
      }
    }

    if (session == null) {
      // No session, so there is nothing to decrypt with. Returning the content as-is here is
      // what let ciphertext render as message text.
      _logger.d('No E2EE session for $senderUserId');
      return const _DecryptedContent.undecryptable();
    }

    // Ciphertext arrives base64-encoded. This used to sniff for base64 with a regex and fall
    // back to `encryptedContent.codeUnits`, which is wrong twice over: codeUnits yields UTF-16
    // units that Uint8List.fromList truncates above 0xFF - the same defect #218 fixed in the
    // AAD - and the regex was a guess about which transport produced the string. A payload that
    // does not decode is one this client cannot read, which is the undecryptable case, not a
    // reason to invent bytes.
    final Uint8List ciphertextBytes;
    try {
      ciphertextBytes = base64.decode(encryptedContent);
    } on FormatException catch (e) {
      _logger.w('Content is not valid base64: $e');
      return const _DecryptedContent.undecryptable();
    }

    final associatedData = messageAssociatedData(
      senderUserId: senderUserId,
      recipientUserId: currentUserId,
    );

    try {
      final decrypted = await cryptoService.decrypt(
        senderUserId: senderUserId,
        senderDeviceId: senderDeviceId,
        ciphertext: ciphertextBytes,
        associatedData: associatedData,
      );
      final result = utf8.decode(decrypted);
      _logger.d('Decryption successful: ${result.length} chars');
      return _DecryptedContent.plaintext(result);
    } catch (e) {
      // A failed tag is indistinguishable from tampering, a desynchronised ratchet and an
      // unsupported wire version. None of them makes the payload safe to display.
      _logger.w('Decryption failed: $e');
      return const _DecryptedContent.undecryptable();
    }
  }

  /// Create responder session from X3DH prekey data
  Future<void> _createResponderSession({
    required String senderUserId,
    required String senderDeviceId,
    required String x3dhPrekey,
  }) async {
    try {
      // Ensure X3DH is initialized
      if (!cryptoService.isInitialized) {
        _logger.w('X3DH not initialized, cannot create responder session');
        throw Exception('X3DH not initialized');
      }

      _logger.d('Creating responder session for $senderUserId:$senderDeviceId');
      final prekeyMessage = X3DHPrekeyMessage.fromBase64(x3dhPrekey);
      _logger.d(
        'Parsed prekey message: identityKey=${prekeyMessage.senderIdentityKey.length} bytes, ephemeralKey=${prekeyMessage.ephemeralKey.length} bytes',
      );

      await cryptoService.createSessionAsResponder(
        senderUserId: senderUserId,
        senderDeviceId: senderDeviceId,
        remoteIdentityKey: prekeyMessage.senderIdentityKey,
        remoteEphemeralKey: prekeyMessage.ephemeralKey,
        usedOneTimePreKeyId: prekeyMessage.usedOneTimePreKeyId,
      );
      _logger.i('Responder session created successfully for $senderUserId');
    } catch (e) {
      _logger.e('Failed to create responder session: $e');
      rethrow;
    }
  }
}

/// The outcome of trying to decrypt one received message.
///
/// A plain `String` return could not distinguish "this is the message" from "this is what I
/// could not decrypt", which is why the receive path used to render the latter as the former.
class _DecryptedContent {
  const _DecryptedContent.plaintext(this.text) : undecryptable = false;

  const _DecryptedContent.undecryptable()
      : text = undecryptableMessagePlaceholder,
        undecryptable = true;

  /// What to display. For the undecryptable case this is the placeholder, never the bytes.
  final String text;

  /// Whether [text] is the placeholder rather than the sender's content.
  final bool undecryptable;

  /// Metadata for the resulting message, carrying the marker when it applies.
  Map<String, String> metadataFrom(Map<String, String> original) =>
      undecryptable ? markUndecryptable(original) : original;
}
