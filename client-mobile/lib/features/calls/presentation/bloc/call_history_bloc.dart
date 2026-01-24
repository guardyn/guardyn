/// Call History BLoC
///
/// Manages the call history list and filtering.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/call_repository.dart';
import '../../domain/usecases/get_call_history.dart';

// =============================================================================
// EVENTS
// =============================================================================

sealed class CallHistoryEvent extends Equatable {
  const CallHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load call history
class LoadCallHistoryEvent extends CallHistoryEvent {
  final CallHistoryFilter filter;

  const LoadCallHistoryEvent({this.filter = CallHistoryFilter.all});

  @override
  List<Object?> get props => [filter];
}

/// Load more calls (pagination)
class LoadMoreCallsEvent extends CallHistoryEvent {
  const LoadMoreCallsEvent();
}

/// Refresh call history
class RefreshCallHistoryEvent extends CallHistoryEvent {
  const RefreshCallHistoryEvent();
}

/// Change filter
class ChangeFilterEvent extends CallHistoryEvent {
  final CallHistoryFilter filter;

  const ChangeFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Delete call from history
class DeleteCallEvent extends CallHistoryEvent {
  final String callId;

  const DeleteCallEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// Clear all history
class ClearHistoryEvent extends CallHistoryEvent {
  const ClearHistoryEvent();
}

// =============================================================================
// FILTER
// =============================================================================

/// Filter for call history
enum CallHistoryFilter {
  all,
  missed,
  incoming,
  outgoing,
}

// =============================================================================
// STATE
// =============================================================================

sealed class CallHistoryState extends Equatable {
  const CallHistoryState();

  @override
  List<Object?> get props => [];
}

class CallHistoryInitial extends CallHistoryState {
  const CallHistoryInitial();
}

class CallHistoryLoading extends CallHistoryState {
  const CallHistoryLoading();
}

class CallHistoryLoaded extends CallHistoryState {
  final List<Call> calls;
  final CallHistoryFilter filter;
  final bool hasMore;
  final bool isLoadingMore;

  const CallHistoryLoaded({
    required this.calls,
    required this.filter,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  CallHistoryLoaded copyWith({
    List<Call>? calls,
    CallHistoryFilter? filter,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CallHistoryLoaded(
      calls: calls ?? this.calls,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  /// Get filtered calls based on current filter
  List<Call> get filteredCalls {
    switch (filter) {
      case CallHistoryFilter.all:
        return calls;
      case CallHistoryFilter.missed:
        return calls
            .where((c) =>
                c.direction == CallDirection.incoming &&
                c.endReason == CallEndReason.noAnswer)
            .toList();
      case CallHistoryFilter.incoming:
        return calls
            .where((c) => c.direction == CallDirection.incoming)
            .toList();
      case CallHistoryFilter.outgoing:
        return calls
            .where((c) => c.direction == CallDirection.outgoing)
            .toList();
    }
  }

  @override
  List<Object?> get props => [calls, filter, hasMore, isLoadingMore];
}

class CallHistoryError extends CallHistoryState {
  final String message;

  const CallHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// BLOC
// =============================================================================

@injectable
class CallHistoryBloc extends Bloc<CallHistoryEvent, CallHistoryState> {
  final GetCallHistory _getCallHistory;
  final CallRepository _callRepository;
  static const _pageSize = 20;

  CallHistoryBloc({
    required GetCallHistory getCallHistory,
    required CallRepository callRepository,
  })  : _getCallHistory = getCallHistory,
        _callRepository = callRepository,
        super(const CallHistoryInitial()) {
    on<LoadCallHistoryEvent>(_onLoadHistory);
    on<LoadMoreCallsEvent>(_onLoadMore);
    on<RefreshCallHistoryEvent>(_onRefresh);
    on<ChangeFilterEvent>(_onChangeFilter);
    on<DeleteCallEvent>(_onDelete);
    on<ClearHistoryEvent>(_onClear);
  }

  Future<void> _onLoadHistory(
    LoadCallHistoryEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    emit(const CallHistoryLoading());

    final result = await _getCallHistory(
      GetCallHistoryParams(limit: _pageSize, offset: 0),
    );

    result.fold(
      (failure) => emit(CallHistoryError(failure.message)),
      (calls) => emit(CallHistoryLoaded(
        calls: calls,
        filter: event.filter,
        hasMore: calls.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreCallsEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CallHistoryLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await _getCallHistory(
      GetCallHistoryParams(
        limit: _pageSize,
        offset: currentState.calls.length,
      ),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newCalls) => emit(currentState.copyWith(
        calls: [...currentState.calls, ...newCalls],
        hasMore: newCalls.length >= _pageSize,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onRefresh(
    RefreshCallHistoryEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    final currentState = state;
    final filter = currentState is CallHistoryLoaded
        ? currentState.filter
        : CallHistoryFilter.all;

    add(LoadCallHistoryEvent(filter: filter));
  }

  Future<void> _onChangeFilter(
    ChangeFilterEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CallHistoryLoaded) {
      emit(currentState.copyWith(filter: event.filter));
    } else {
      add(LoadCallHistoryEvent(filter: event.filter));
    }
  }

  Future<void> _onDelete(
    DeleteCallEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CallHistoryLoaded) return;

    // Optimistically remove from list
    final updated =
        currentState.calls.where((c) => c.id != event.callId).toList();
    emit(currentState.copyWith(calls: updated));

    // Call repository to delete
    final result = await _callRepository.deleteCallFromHistory(event.callId);
    result.fold(
      (failure) {
        // Revert on failure
        emit(currentState);
      },
      (_) {
        // Success - already updated optimistically
      },
    );
  }

  Future<void> _onClear(
    ClearHistoryEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    final currentState = state;
    
    emit(const CallHistoryLoaded(
      calls: [],
      filter: CallHistoryFilter.all,
      hasMore: false,
    ));

    // Call repository to clear
    final result = await _callRepository.clearCallHistory();
    result.fold(
      (failure) {
        // Revert on failure
        if (currentState is CallHistoryLoaded) {
          emit(currentState);
        }
      },
      (_) {
        // Success - already cleared optimistically
      },
    );
  }
}
