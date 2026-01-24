part of 'contacts_bloc.dart';

/// Base class for all contacts events
abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial contacts list
class LoadContacts extends ContactsEvent {
  final int limit;

  const LoadContacts({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

/// Load more contacts (pagination)
class LoadMoreContacts extends ContactsEvent {
  final int limit;

  const LoadMoreContacts({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

/// Add a new contact
class AddContact extends ContactsEvent {
  final String userId;
  final String? nickname;
  final String? notes;

  const AddContact({required this.userId, this.nickname, this.notes});

  @override
  List<Object?> get props => [userId, nickname, notes];
}

/// Remove a contact
class RemoveContact extends ContactsEvent {
  final String userId;

  const RemoveContact(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Update contact details
class UpdateContact extends ContactsEvent {
  final String userId;
  final String? nickname;
  final String? notes;
  final bool clearNickname;
  final bool clearNotes;

  const UpdateContact({
    required this.userId,
    this.nickname,
    this.notes,
    this.clearNickname = false,
    this.clearNotes = false,
  });

  @override
  List<Object?> get props => [
    userId,
    nickname,
    notes,
    clearNickname,
    clearNotes,
  ];
}

/// Check if a user is in contacts
class CheckIsContact extends ContactsEvent {
  final String userId;

  const CheckIsContact(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Refresh contacts (clear cache and reload)
class RefreshContacts extends ContactsEvent {
  final int limit;

  const RefreshContacts({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}
