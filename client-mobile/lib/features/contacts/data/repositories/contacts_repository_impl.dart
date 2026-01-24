import 'package:dartz/dartz.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_remote_datasource.dart';

/// Implementation of ContactsRepository
/// Handles contacts data fetching and caching
@Injectable(as: ContactsRepository)
class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsRemoteDatasource remoteDatasource;
  final SecureStorage secureStorage;
  final Logger _logger = Logger();

  // In-memory cache for contacts
  final Map<String, Contact> _contactsCache = {};
  List<Contact>? _allContactsCache;

  ContactsRepositoryImpl(this.remoteDatasource, this.secureStorage);

  @override
  Future<Either<Failure, Contact>> addContact({
    required String userId,
    String? nickname,
    String? notes,
  }) async {
    try {
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      final contactModel = await remoteDatasource.addContact(
        accessToken: accessToken,
        userId: userId,
        nickname: nickname,
        notes: notes,
      );

      final contact = contactModel.toEntity();

      // Update cache
      _contactsCache[userId] = contact;
      _allContactsCache?.add(contact);

      _logger.i('Added contact: $userId');
      return Right(contact);
    } on GrpcError catch (e) {
      _logger.w('gRPC error adding contact: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error adding contact: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeContact(String userId) async {
    try {
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      await remoteDatasource.removeContact(
        accessToken: accessToken,
        userId: userId,
      );

      // Update cache
      _contactsCache.remove(userId);
      _allContactsCache?.removeWhere((c) => c.userId == userId);

      _logger.i('Removed contact: $userId');
      return const Right(null);
    } on GrpcError catch (e) {
      _logger.w('gRPC error removing contact: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error removing contact: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContactsListResult>> getContacts({
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      final response = await remoteDatasource.listContacts(
        accessToken: accessToken,
        limit: limit,
        cursor: cursor,
      );

      final contacts = response.contacts.map((m) => m.toEntity()).toList();

      // Update cache
      for (final contact in contacts) {
        _contactsCache[contact.userId] = contact;
      }

      // If this is the first page, update all contacts cache
      if (cursor == null) {
        _allContactsCache = List.from(contacts);
      } else {
        _allContactsCache?.addAll(contacts);
      }

      _logger.i('Fetched ${contacts.length} contacts');
      return Right(
        ContactsListResult(
          contacts: contacts,
          nextCursor: response.nextCursor,
          totalCount: response.totalCount,
        ),
      );
    } on GrpcError catch (e) {
      _logger.w('gRPC error fetching contacts: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error fetching contacts: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Contact>> getContact(String userId) async {
    try {
      // Check cache first
      if (_contactsCache.containsKey(userId)) {
        return Right(_contactsCache[userId]!);
      }

      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      final contactModel = await remoteDatasource.getContact(
        accessToken: accessToken,
        userId: userId,
      );

      final contact = contactModel.toEntity();

      // Update cache
      _contactsCache[userId] = contact;

      return Right(contact);
    } on GrpcError catch (e) {
      _logger.w('gRPC error getting contact: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error getting contact: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Contact>> updateContact({
    required String userId,
    String? nickname,
    String? notes,
    bool clearNickname = false,
    bool clearNotes = false,
  }) async {
    try {
      final accessToken = await secureStorage.getAccessToken();
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      final contactModel = await remoteDatasource.updateContact(
        accessToken: accessToken,
        userId: userId,
        nickname: nickname,
        notes: notes,
        clearNickname: clearNickname,
        clearNotes: clearNotes,
      );

      final contact = contactModel.toEntity();

      // Update cache
      _contactsCache[userId] = contact;
      final index = _allContactsCache?.indexWhere((c) => c.userId == userId);
      if (index != null && index >= 0) {
        _allContactsCache![index] = contact;
      }

      _logger.i('Updated contact: $userId');
      return Right(contact);
    } on GrpcError catch (e) {
      _logger.w('gRPC error updating contact: ${e.message}');
      return Left(_handleGrpcError(e));
    } catch (e) {
      _logger.e('Error updating contact: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isContact(String userId) async {
    // Check cache first
    if (_contactsCache.containsKey(userId)) {
      return const Right(true);
    }

    // Try to get from server
    final result = await getContact(userId);
    return result.fold((failure) {
      if (failure is NotFoundFailure) {
        return const Right(false);
      }
      return Left(failure);
    }, (contact) => const Right(true));
  }

  @override
  List<Contact> getCachedContacts() {
    return _allContactsCache ?? [];
  }

  @override
  Future<void> clearCache() async {
    _contactsCache.clear();
    _allContactsCache = null;
  }

  Failure _handleGrpcError(GrpcError error) {
    switch (error.code) {
      case StatusCode.unauthenticated:
        return const AuthFailure('Authentication required');
      case StatusCode.permissionDenied:
        return const AuthFailure('Permission denied');
      case StatusCode.notFound:
        return const NotFoundFailure('Contact not found');
      case StatusCode.alreadyExists:
        return const ConflictFailure('Contact already exists');
      case StatusCode.unavailable:
        return const NetworkFailure('Service unavailable');
      default:
        return ServerFailure(error.message ?? 'Unknown error');
    }
  }
}
