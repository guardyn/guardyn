import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/contact.dart';
import '../../domain/repositories/contacts_repository.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

/// BLoC for managing contacts
@injectable
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactsRepository contactsRepository;

  ContactsBloc(this.contactsRepository) : super(ContactsInitial()) {
    on<LoadContacts>(_onLoadContacts);
    on<LoadMoreContacts>(_onLoadMoreContacts);
    on<AddContact>(_onAddContact);
    on<RemoveContact>(_onRemoveContact);
    on<UpdateContact>(_onUpdateContact);
    on<CheckIsContact>(_onCheckIsContact);
    on<RefreshContacts>(_onRefreshContacts);
  }

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading());

    final result = await contactsRepository.getContacts(limit: event.limit);

    result.fold(
      (failure) => emit(ContactsError(failure.message)),
      (contactsResult) => emit(
        ContactsLoaded(
          contacts: contactsResult.contacts,
          hasMore: contactsResult.hasMore,
          nextCursor: contactsResult.nextCursor,
          totalCount: contactsResult.totalCount,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreContacts(
    LoadMoreContacts event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ContactsLoaded || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await contactsRepository.getContacts(
      limit: event.limit,
      cursor: currentState.nextCursor,
    );

    result.fold(
      (failure) => emit(
        currentState.copyWith(isLoadingMore: false, error: failure.message),
      ),
      (contactsResult) => emit(
        currentState.copyWith(
          contacts: [...currentState.contacts, ...contactsResult.contacts],
          hasMore: contactsResult.hasMore,
          nextCursor: contactsResult.nextCursor,
          totalCount: contactsResult.totalCount,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onAddContact(
    AddContact event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;

    final result = await contactsRepository.addContact(
      userId: event.userId,
      nickname: event.nickname,
      notes: event.notes,
    );

    result.fold(
      (failure) {
        emit(ContactAddError(failure.message));
        // Restore previous state
        if (currentState is ContactsLoaded) {
          emit(currentState);
        }
      },
      (contact) {
        emit(ContactAdded(contact));
        // Update list if we have one
        if (currentState is ContactsLoaded) {
          emit(
            currentState.copyWith(
              contacts: [contact, ...currentState.contacts],
              totalCount: currentState.totalCount + 1,
            ),
          );
        }
      },
    );
  }

  Future<void> _onRemoveContact(
    RemoveContact event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;

    final result = await contactsRepository.removeContact(event.userId);

    result.fold(
      (failure) {
        emit(ContactRemoveError(failure.message));
        if (currentState is ContactsLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(ContactRemoved(event.userId));
        if (currentState is ContactsLoaded) {
          emit(
            currentState.copyWith(
              contacts: currentState.contacts
                  .where((c) => c.userId != event.userId)
                  .toList(),
              totalCount: currentState.totalCount - 1,
            ),
          );
        }
      },
    );
  }

  Future<void> _onUpdateContact(
    UpdateContact event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;

    final result = await contactsRepository.updateContact(
      userId: event.userId,
      nickname: event.nickname,
      notes: event.notes,
      clearNickname: event.clearNickname,
      clearNotes: event.clearNotes,
    );

    result.fold(
      (failure) {
        emit(ContactUpdateError(failure.message));
        if (currentState is ContactsLoaded) {
          emit(currentState);
        }
      },
      (contact) {
        emit(ContactUpdated(contact));
        if (currentState is ContactsLoaded) {
          final updatedContacts = currentState.contacts.map((c) {
            return c.userId == event.userId ? contact : c;
          }).toList();
          emit(currentState.copyWith(contacts: updatedContacts));
        }
      },
    );
  }

  Future<void> _onCheckIsContact(
    CheckIsContact event,
    Emitter<ContactsState> emit,
  ) async {
    final result = await contactsRepository.isContact(event.userId);

    result.fold(
      (failure) => emit(IsContactResult(event.userId, false)),
      (isContact) => emit(IsContactResult(event.userId, isContact)),
    );
  }

  Future<void> _onRefreshContacts(
    RefreshContacts event,
    Emitter<ContactsState> emit,
  ) async {
    await contactsRepository.clearCache();
    add(LoadContacts(limit: event.limit));
  }
}
