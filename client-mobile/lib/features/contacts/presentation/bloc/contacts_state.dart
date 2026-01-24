part of 'contacts_bloc.dart';

/// Base class for all contacts states
abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ContactsInitial extends ContactsState {}

/// Loading contacts
class ContactsLoading extends ContactsState {}

/// Contacts loaded successfully
class ContactsLoaded extends ContactsState {
  final List<Contact> contacts;
  final bool hasMore;
  final String? nextCursor;
  final int totalCount;
  final bool isLoadingMore;
  final String? error;

  const ContactsLoaded({
    required this.contacts,
    this.hasMore = false,
    this.nextCursor,
    this.totalCount = 0,
    this.isLoadingMore = false,
    this.error,
  });

  ContactsLoaded copyWith({
    List<Contact>? contacts,
    bool? hasMore,
    String? nextCursor,
    int? totalCount,
    bool? isLoadingMore,
    String? error,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    contacts,
    hasMore,
    nextCursor,
    totalCount,
    isLoadingMore,
    error,
  ];
}

/// Error loading contacts
class ContactsError extends ContactsState {
  final String message;

  const ContactsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Contact added successfully
class ContactAdded extends ContactsState {
  final Contact contact;

  const ContactAdded(this.contact);

  @override
  List<Object?> get props => [contact];
}

/// Error adding contact
class ContactAddError extends ContactsState {
  final String message;

  const ContactAddError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Contact removed successfully
class ContactRemoved extends ContactsState {
  final String userId;

  const ContactRemoved(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Error removing contact
class ContactRemoveError extends ContactsState {
  final String message;

  const ContactRemoveError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Contact updated successfully
class ContactUpdated extends ContactsState {
  final Contact contact;

  const ContactUpdated(this.contact);

  @override
  List<Object?> get props => [contact];
}

/// Error updating contact
class ContactUpdateError extends ContactsState {
  final String message;

  const ContactUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Result of checking if user is contact
class IsContactResult extends ContactsState {
  final String userId;
  final bool isContact;

  const IsContactResult(this.userId, this.isContact);

  @override
  List<Object?> get props => [userId, isContact];
}
