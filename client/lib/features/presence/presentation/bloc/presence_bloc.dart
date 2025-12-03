import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/presence_info.dart';
import '../../domain/repositories/presence_repository.dart';
import '../../domain/usecases/get_bulk_presence.dart';
import '../../domain/usecases/get_user_presence.dart';
import '../../domain/usecases/send_heartbeat.dart';
import '../../domain/usecases/send_typing_indicator.dart';
import '../../domain/usecases/update_my_status.dart';
import 'presence_event.dart';
import 'presence_state.dart';

/// BLoC for managing presence state across the application
@injectable
class PresenceBloc extends Bloc<PresenceEvent, PresenceState> {
  final GetUserPresence getUserPresence;
  final GetBulkPresence getBulkPresence;
  final UpdateMyStatus updateMyStatus;
  final SendTypingIndicator sendTypingIndicator;
  final SendHeartbeat sendHeartbeat;
  final PresenceRepository presenceRepository;

  Timer? _heartbeatTimer;
  StreamSubscription<PresenceInfo>? _presenceSubscription;

  /// In-memory cache of presence info
  final Map<String, PresenceInfo> _presenceCache = {};

  /// Typing users map (userId -> conversationId)
  final Map<String, String> _typingUsers = {};

  PresenceBloc({
    required this.getUserPresence,
    required this.getBulkPresence,
    required this.updateMyStatus,
    required this.sendTypingIndicator,
    required this.sendHeartbeat,
    required this.presenceRepository,
  }) : super(const PresenceInitial()) {
    on<PresenceFetchUser>(_onFetchUser);
    on<PresenceFetchBulk>(_onFetchBulk);
    on<PresenceUpdateMyStatus>(_onUpdateMyStatus);
    on<PresenceUserChanged>(_onUserChanged);
    on<PresenceSendTyping>(_onSendTyping);
    on<PresenceTypingChanged>(_onTypingChanged);
    on<PresenceStartHeartbeat>(_onStartHeartbeat);
    on<PresenceStopHeartbeat>(_onStopHeartbeat);
    on<PresenceSubscribe>(_onSubscribe);
    on<PresenceUnsubscribe>(_onUnsubscribe);
    on<PresenceClearCache>(_onClearCache);
    on<PresenceSetOnline>(_onSetOnline);
    on<PresenceSetOffline>(_onSetOffline);
  }

  /// Fetch presence for a single user
  Future<void> _onFetchUser(
    PresenceFetchUser event,
    Emitter<PresenceState> emit,
  ) async {
    final result = await getUserPresence(event.userId);

    result.fold(
      (failure) {
        // On failure, emit offline status for the user
        _presenceCache[event.userId] = PresenceInfo.offline(event.userId);
        emit(PresenceLoaded(
          presenceMap: Map.from(_presenceCache),
          typingUsers: Map.from(_typingUsers),
        ));
      },
      (presence) {
        _presenceCache[event.userId] = presence;
        emit(PresenceLoaded(
          presenceMap: Map.from(_presenceCache),
          typingUsers: Map.from(_typingUsers),
        ));
      },
    );
  }

  /// Fetch presence for multiple users
  Future<void> _onFetchBulk(
    PresenceFetchBulk event,
    Emitter<PresenceState> emit,
  ) async {
    if (event.userIds.isEmpty) return;

    emit(const PresenceLoading());

    final result = await getBulkPresence(event.userIds);

    result.fold(
      (failure) {
        // On failure, set all users as offline
        for (final userId in event.userIds) {
          _presenceCache[userId] = PresenceInfo.offline(userId);
        }
        emit(PresenceError(
          message: failure.message,
          presenceMap: Map.from(_presenceCache),
        ));
      },
      (presenceMap) {
        _presenceCache.addAll(presenceMap);
        emit(PresenceLoaded(
          presenceMap: Map.from(_presenceCache),
          typingUsers: Map.from(_typingUsers),
        ));
      },
    );
  }

  /// Update current user's status
  Future<void> _onUpdateMyStatus(
    PresenceUpdateMyStatus event,
    Emitter<PresenceState> emit,
  ) async {
    final result = await updateMyStatus(event.status);

    result.fold(
      (failure) {
        emit(PresenceError(
          message: failure.message,
          presenceMap: Map.from(_presenceCache),
        ));
      },
      (_) {
        final currentState = state;
        if (currentState is PresenceLoaded) {
          emit(currentState.copyWith(myStatus: event.status));
        } else {
          emit(PresenceLoaded(
            presenceMap: Map.from(_presenceCache),
            typingUsers: Map.from(_typingUsers),
            myStatus: event.status,
          ));
        }
      },
    );
  }

  /// Handle presence change from server
  void _onUserChanged(
    PresenceUserChanged event,
    Emitter<PresenceState> emit,
  ) {
    _presenceCache[event.presenceInfo.userId] = event.presenceInfo;
    
    // Update typing users from presence info
    if (event.presenceInfo.isTyping &&
        event.presenceInfo.typingInConversationId != null) {
      _typingUsers[event.presenceInfo.userId] =
          event.presenceInfo.typingInConversationId!;
    } else {
      _typingUsers.remove(event.presenceInfo.userId);
    }
    
    emit(PresenceLoaded(
      presenceMap: Map.from(_presenceCache),
      typingUsers: Map.from(_typingUsers),
    ));
  }

  /// Send typing indicator
  Future<void> _onSendTyping(
    PresenceSendTyping event,
    Emitter<PresenceState> emit,
  ) async {
    await sendTypingIndicator(SendTypingParams(
      conversationId: event.conversationId,
      isTyping: event.isTyping,
    ));
  }

  /// Handle typing indicator change
  void _onTypingChanged(
    PresenceTypingChanged event,
    Emitter<PresenceState> emit,
  ) {
    if (event.isTyping) {
      _typingUsers[event.userId] = event.conversationId;
    } else {
      _typingUsers.remove(event.userId);
    }

    emit(PresenceLoaded(
      presenceMap: Map.from(_presenceCache),
      typingUsers: Map.from(_typingUsers),
    ));
  }

  /// Start heartbeat timer
  void _onStartHeartbeat(
    PresenceStartHeartbeat event,
    Emitter<PresenceState> emit,
  ) {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => sendHeartbeat(),
    );

    // Send immediate heartbeat
    sendHeartbeat();
  }

  /// Stop heartbeat timer
  void _onStopHeartbeat(
    PresenceStopHeartbeat event,
    Emitter<PresenceState> emit,
  ) {
    _stopHeartbeat();
  }

  /// Subscribe to presence updates
  void _onSubscribe(
    PresenceSubscribe event,
    Emitter<PresenceState> emit,
  ) {
    // Cancel existing subscription if any
    _presenceSubscription?.cancel();

    // Subscribe to real-time presence updates from repository
    _presenceSubscription = presenceRepository
        .subscribeToPresence(event.userIds)
        .listen(
          (presenceInfo) {
            // Update cache and typing status from the update
            _presenceCache[presenceInfo.userId] = presenceInfo;

            // Handle typing indicator from presence update
            if (presenceInfo.isTyping &&
                presenceInfo.typingInConversationId != null) {
              _typingUsers[presenceInfo.userId] =
                  presenceInfo.typingInConversationId!;
            } else {
              _typingUsers.remove(presenceInfo.userId);
            }

            // Emit updated state
            add(PresenceUserChanged(presenceInfo));
          },
          onError: (error) {
            // Log error but don't crash
            // ignore: avoid_print
            print('Presence subscription error: $error');
          },
          cancelOnError: false,
        );

    // Update state to show subscription is active
    final currentState = state;
    if (currentState is PresenceLoaded) {
      emit(currentState.copyWith(isSubscribed: true));
    } else {
      emit(
        PresenceLoaded(
          presenceMap: Map.from(_presenceCache),
          typingUsers: Map.from(_typingUsers),
          isSubscribed: true,
        ),
      );
    }
  }

  /// Unsubscribe from presence updates
  void _onUnsubscribe(
    PresenceUnsubscribe event,
    Emitter<PresenceState> emit,
  ) {
    _presenceSubscription?.cancel();
    _presenceSubscription = null;

    final currentState = state;
    if (currentState is PresenceLoaded) {
      emit(currentState.copyWith(isSubscribed: false));
    }
  }

  /// Clear presence cache
  void _onClearCache(
    PresenceClearCache event,
    Emitter<PresenceState> emit,
  ) {
    _presenceCache.clear();
    _typingUsers.clear();
    emit(const PresenceInitial());
  }

  /// Set current user as online
  Future<void> _onSetOnline(
    PresenceSetOnline event,
    Emitter<PresenceState> emit,
  ) async {
    add(const PresenceUpdateMyStatus(PresenceStatus.online));
    add(const PresenceStartHeartbeat());
  }

  /// Set current user as offline
  Future<void> _onSetOffline(
    PresenceSetOffline event,
    Emitter<PresenceState> emit,
  ) async {
    add(const PresenceUpdateMyStatus(PresenceStatus.offline));
    add(const PresenceStopHeartbeat());
  }

  /// Stop heartbeat timer (internal)
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Get cached presence for a user (synchronous)
  PresenceInfo? getCachedPresence(String userId) {
    return _presenceCache[userId];
  }

  /// Check if a user is online (synchronous)
  bool isUserOnline(String userId) {
    return _presenceCache[userId]?.isOnline ?? false;
  }

  @override
  Future<void> close() {
    _stopHeartbeat();
    _presenceSubscription?.cancel();
    return super.close();
  }
}
