import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/contact.dart';

/// Repository interface for contacts operations
abstract class ContactsRepository {
  /// Add a user to contacts
  Future<Either<Failure, Contact>> addContact({
    required String userId,
    String? nickname,
    String? notes,
  });

  /// Remove a user from contacts
  Future<Either<Failure, void>> removeContact(String userId);

  /// Get list of all contacts with pagination
  Future<Either<Failure, ContactsListResult>> getContacts({
    int limit = 50,
    String? cursor,
  });

  /// Get a specific contact by user ID
  Future<Either<Failure, Contact>> getContact(String userId);

  /// Update contact details (nickname, notes)
  Future<Either<Failure, Contact>> updateContact({
    required String userId,
    String? nickname,
    String? notes,
    bool clearNickname = false,
    bool clearNotes = false,
  });

  /// Check if a user is in contacts
  Future<Either<Failure, bool>> isContact(String userId);

  /// Get cached contacts (synchronous, for UI)
  List<Contact> getCachedContacts();

  /// Clear contacts cache
  Future<void> clearCache();
}

/// Result of contacts list query with pagination info
class ContactsListResult {
  final List<Contact> contacts;
  final String? nextCursor;
  final int totalCount;

  const ContactsListResult({
    required this.contacts,
    this.nextCursor,
    required this.totalCount,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
