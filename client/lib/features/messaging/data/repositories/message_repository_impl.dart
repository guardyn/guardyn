import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/crypto/crypto_service.dart';
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
        return const Left(AuthFailure('No access token found'));
      }

      // Get current user info for conversation ID
      final currentUserId = await secureStorage.getUserId();
      final currentDeviceId = await secureStorage.getDeviceId();

      if (currentUserId == null || currentDeviceId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // E2EE: Encrypt message content with Double Ratchet
      final encryptedContent = await _encryptMessage(
        plaintext: textContent,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        currentUserId: currentUserId,
      );

      // Send encrypted message via datasource
      final messageModel = await remoteDatasource.sendMessage(
        accessToken: accessToken,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        recipientUsername: recipientUsername,
        textContent: encryptedContent, // Encrypted content
        metadata: metadata,
      );

      // Create complete message with sender info
      final conversationId = _deriveConversationId(currentUserId, recipientUserId);

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
      final effectiveConversationId = conversationId ?? 
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
          final decryptedContent = await _decryptMessage(
            encryptedContent: message.textContent,
            senderUserId: message.senderUserId,
            senderDeviceId: message.senderDeviceId,
            currentUserId: currentUserId,
          );
          decryptedMessages.add(MessageModel(
            messageId: message.messageId,
            conversationId: message.conversationId,
            senderUserId: message.senderUserId,
            senderDeviceId: message.senderDeviceId,
            recipientUserId: message.recipientUserId,
            recipientDeviceId: message.recipientDeviceId,
            messageType: message.messageType,
            textContent: decryptedContent,
            metadata: message.metadata,
            timestamp: message.timestamp,
            deliveryStatus: message.deliveryStatus,
            currentUserId: currentUserId,
          ));
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
          final decryptedContent = await _decryptMessage(
            encryptedContent: message.textContent,
            senderUserId: message.senderUserId,
            senderDeviceId: message.senderDeviceId,
            currentUserId: currentUserId,
          );
          yield Right(MessageModel(
            messageId: message.messageId,
            conversationId: message.conversationId,
            senderUserId: message.senderUserId,
            senderDeviceId: message.senderDeviceId,
            recipientUserId: message.recipientUserId,
            recipientDeviceId: message.recipientDeviceId,
            messageType: message.messageType,
            textContent: decryptedContent,
            metadata: message.metadata,
            timestamp: message.timestamp,
            deliveryStatus: message.deliveryStatus,
            currentUserId: currentUserId,
          ));
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
  Future<Either<Failure, void>> markAsRead({
    required String messageId,
  }) async {
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
  Future<Either<Failure, String>> decryptMessageContent({
    required String encryptedContent,
    required String senderUserId,
    required String senderDeviceId,
  }) async {
    try {
      final currentUserId = await secureStorage.getUserId();
      if (currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      final decryptedContent = await _decryptMessage(
        encryptedContent: encryptedContent,
        senderUserId: senderUserId,
        senderDeviceId: senderDeviceId,
        currentUserId: currentUserId,
      );

      return Right(decryptedContent);
    } catch (e) {
      _logger.e('Failed to decrypt message: $e');
      // Return original content on failure
      return Right(encryptedContent);
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
  /// If no session exists, creates one via X3DH key exchange
  Future<String> _encryptMessage({
    required String plaintext,
    required String recipientUserId,
    required String recipientDeviceId,
    required String currentUserId,
  }) async {
    // Check if E2EE session exists
    var session = await cryptoService.getSession(
      remoteUserId: recipientUserId,
      remoteDeviceId: recipientDeviceId,
    );

    // No session? Create one via X3DH key exchange
    if (session == null) {
      _logger.i('No E2EE session for $recipientUserId:$recipientDeviceId, initiating X3DH');
      try {
        await _createE2ESession(
          recipientUserId: recipientUserId,
          recipientDeviceId: recipientDeviceId,
        );
        // Re-fetch session after creation
        session = await cryptoService.getSession(
          remoteUserId: recipientUserId,
          remoteDeviceId: recipientDeviceId,
        );
        _logger.i('E2EE session created successfully');
      } catch (e) {
        _logger.w('Failed to create E2EE session: $e. Sending plaintext.');
        // Fall back to plaintext if session creation fails
        return plaintext;
      }
    }

    // Encrypt with Double Ratchet
    final plaintextBytes = Uint8List.fromList(plaintext.codeUnits);
    final associatedData = Uint8List.fromList(
      '$currentUserId|$recipientUserId'.codeUnits,
    );

    try {
      final encrypted = await cryptoService.encrypt(
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        plaintext: plaintextBytes,
        associatedData: associatedData,
      );
      _logger.d('Message encrypted successfully (${encrypted.length} bytes)');
      // Return as string representation of bytes
      return String.fromCharCodes(encrypted);
    } catch (e) {
      _logger.e('Encryption failed: $e. Sending plaintext.');
      // Encryption failed, fall back to plaintext
      return plaintext;
    }
  }

  /// Create E2EE session via X3DH key exchange
  Future<void> _createE2ESession({
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

    // Create E2EE session as initiator (Alice)
    await cryptoService.createSessionAsInitiator(
      recipientUserId: recipientUserId,
      recipientDeviceId: recipientDeviceId,
      remoteKeyBundle: remoteKeyBundle,
    );
  }

  /// Decrypt message content with Double Ratchet
  ///
  /// Returns plaintext if decryption successful, or original content if not encrypted.
  /// Handles both base64-encoded content (from WebSocket) and raw bytes (from gRPC).
  Future<String> _decryptMessage({
    required String encryptedContent,
    required String senderUserId,
    required String senderDeviceId,
    required String currentUserId,
  }) async {
    if (encryptedContent.isEmpty) {
      return encryptedContent;
    }
    
    // Check if E2EE session exists
    final session = await cryptoService.getSession(
      remoteUserId: senderUserId,
      remoteDeviceId: senderDeviceId,
    );

    if (session == null) {
      // No E2EE session - return content as-is (not encrypted or legacy message)
      _logger.d('No E2EE session for $senderUserId - returning content as-is');
      return encryptedContent;
    }

    // Try to detect if content is base64 encoded (from WebSocket)
    // Base64 uses only A-Za-z0-9+/= characters
    Uint8List ciphertextBytes;
    try {
      // Check if it looks like base64 (common pattern for encrypted messages)
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]+=*$');
      if (base64Regex.hasMatch(encryptedContent) &&
          encryptedContent.length > 20) {
        // Looks like base64 - try to decode
        ciphertextBytes = base64.decode(encryptedContent);
        _logger.d('Decoded base64 content: ${ciphertextBytes.length} bytes');
      } else {
        // Not base64 - use codeUnits (raw bytes encoded as string)
        ciphertextBytes = Uint8List.fromList(encryptedContent.codeUnits);
        _logger.d('Using raw codeUnits: ${ciphertextBytes.length} bytes');
      }
    } catch (e) {
      // Base64 decode failed - use codeUnits
      ciphertextBytes = Uint8List.fromList(encryptedContent.codeUnits);
      _logger.d('Base64 decode failed, using codeUnits: $e');
    }
    
    final associatedData = Uint8List.fromList(
      '$senderUserId|$currentUserId'.codeUnits,
    );

    try {
      final decrypted = await cryptoService.decrypt(
        senderUserId: senderUserId,
        senderDeviceId: senderDeviceId,
        ciphertext: ciphertextBytes,
        associatedData: associatedData,
      );
      final result = String.fromCharCodes(decrypted);
      _logger.d('Decryption successful: ${result.length} chars');
      return result;
    } catch (e) {
      // Decryption failed - message might not be encrypted
      _logger.w('Decryption failed: $e - returning original content');
      return encryptedContent;
    }
  }
}
