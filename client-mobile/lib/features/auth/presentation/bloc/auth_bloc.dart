import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/features/auth/domain/usecases/login_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/logout_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/register_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/update_profile.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardyn_client/features/calls/domain/repositories/call_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/upload_media.dart';
import 'package:logger/logger.dart';

/// BLoC for authentication state management
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final AuthRepository authRepository;
  final CryptoService cryptoService;
  final CallRepository? callRepository;
  final UpdateProfile? updateProfile;
  final UploadMedia? uploadMedia;
  final Logger logger = Logger();

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.authRepository,
    required this.cryptoService,
    this.callRepository,
    this.updateProfile,
    this.uploadMedia,
  }) : super(AuthInitial()) {
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthUploadAvatarRequested>(_onUploadAvatarRequested);
  }

  /// Trigger background key replenishment after successful auth
  /// 
  /// Uses isolate-based generation for true background processing
  /// without blocking the UI thread.
  void _triggerBackgroundKeyReplenishment() {
    // Fire and forget - don't await, let it run in background isolate
    Future.microtask(() async {
      try {
        // Use isolate-based replenishment for non-blocking operation
        final newKeys = await cryptoService
            .replenishOneTimePreKeysInIsolate();
        if (newKeys.isNotEmpty) {
          logger.i(
            'Generated ${newKeys.length} new one-time pre-keys in background isolate',
          );
          // TODO: Upload new keys to server when API is available
        }
      } catch (e) {
        logger.w('Background key replenishment failed: $e');
        // Non-fatal, keys can be replenished later
      }
    });
  }

  /// Restart call subscriptions after successful auth
  /// 
  /// This ensures incoming calls subscription is active with new token
  /// after re-login (e.g., after token expiry).
  void _restartCallSubscriptions() {
    // Fire and forget - let it run in background
    Future.microtask(() async {
      try {
        if (callRepository != null) {
          await callRepository!.restartIncomingCallsSubscription();
          logger.i('Restarted incoming calls subscription after login');
        }
      } catch (e) {
        logger.w('Failed to restart call subscriptions: $e');
        // Non-fatal, will be retried on next call attempt
      }
    });
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerUser(
        username: event.username,
        password: event.password,
        deviceName: event.deviceName,
      );
      logger.i('Registration successful: ${user.userId}');
      emit(AuthAuthenticated(user));

      // Restart incoming calls subscription with new token
      _restartCallSubscriptions();

      // Trigger background key replenishment after successful registration
      _triggerBackgroundKeyReplenishment();
    } on AuthException catch (e) {
      logger.e('Registration failed: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      logger.e('Unexpected error during registration: $e');
      emit(AuthError('Registration failed: $e'));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginUser(
        username: event.username,
        password: event.password,
      );
      logger.i('Login successful: ${user.userId}');
      emit(AuthAuthenticated(user));

      // Restart incoming calls subscription with new token
      _restartCallSubscriptions();

      // Trigger background key replenishment after successful login
      _triggerBackgroundKeyReplenishment();
    } on AuthException catch (e) {
      logger.e('Login failed: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      logger.e('Unexpected error during login: $e');
      emit(AuthError('Login failed: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await logoutUser();
      logger.i('Logout successful');
      emit(AuthUnauthenticated());
    } on AuthException catch (e) {
      logger.e('Logout failed: ${e.message}');
      emit(AuthError(e.message));
      // Still move to unauthenticated state since local data is cleared
      emit(AuthUnauthenticated());
    } catch (e) {
      logger.e('Unexpected error during logout: $e');
      emit(AuthError('Logout failed: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAccountDeleting());
    try {
      await authRepository.deleteAccount(password: event.password);
      logger.i('Account deleted successfully');
      // Emit AuthUnauthenticated with a message so UI can show success
      emit(
        AuthUnauthenticated(
          message: 'Your account has been permanently deleted',
        ),
      );
    } on AuthException catch (e) {
      logger.e('Account deletion failed: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      logger.e('Unexpected error during account deletion: $e');
      emit(AuthError('Account deletion failed: $e'));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          logger.i('User is authenticated: ${user.userId}');
          emit(AuthAuthenticated(user));
        } else {
          logger.w('Authenticated but no user data found');
          emit(AuthUnauthenticated());
        }
      } else {
        logger.i('User is not authenticated');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      logger.e('Error checking auth status: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Handle profile update request
  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Get current user from state
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthError('Must be authenticated to update profile'));
      return;
    }

    final currentUser = currentState.user;
    emit(AuthProfileUpdating(currentUser));

    try {
      String? avatarMediaId = event.avatarMediaId;

      // If there's a new avatar to upload, do it first
      if (event.newAvatarPath != null && uploadMedia != null) {
        logger.i('Uploading new avatar from: ${event.newAvatarPath}');
        emit(AuthProfileUpdating(currentUser, uploadProgress: 0.0));

        final mediaEntity = await uploadMedia!(
          filePath: event.newAvatarPath!,
          onProgress: (progress) {
            logger.d('Avatar upload progress: ${(progress * 100).toInt()}%');
          },
        );

        avatarMediaId = mediaEntity.id;
        logger.i('Avatar uploaded successfully: $avatarMediaId');
      }

      if (updateProfile != null) {
        // Use the UpdateProfile use case if available
        final updatedUser = await updateProfile!(
          avatarMediaId: event.removeAvatar ? null : avatarMediaId,
          displayName: event.displayName,
          bio: event.bio,
          clearAvatar: event.removeAvatar,
        );
        logger.i('Profile updated successfully');
        emit(AuthProfileUpdated(updatedUser));
        emit(AuthAuthenticated(updatedUser));
      } else {
        // Fallback: update locally only
        final updatedUser = currentUser.copyWith(
          avatarMediaId: avatarMediaId,
          displayName: event.displayName,
          bio: event.bio,
          clearAvatar: event.removeAvatar,
        );
        logger.i('Profile updated locally (no server sync)');
        emit(AuthProfileUpdated(updatedUser));
        emit(AuthAuthenticated(updatedUser));
      }
    } on AuthException catch (e) {
      logger.e('Profile update failed: ${e.message}');
      emit(AuthError(e.message));
      emit(AuthAuthenticated(currentUser));
    } catch (e) {
      logger.e('Unexpected error during profile update: $e');
      emit(AuthError('Profile update failed: $e'));
      emit(AuthAuthenticated(currentUser));
    }
  }

  /// Handle avatar upload and update
  Future<void> _onUploadAvatarRequested(
    AuthUploadAvatarRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Get current user from state
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthError('Must be authenticated to upload avatar'));
      return;
    }

    final currentUser = currentState.user;
    emit(AuthProfileUpdating(currentUser, uploadProgress: 0.0));

    try {
      if (uploadMedia == null) {
        throw AuthException('Media upload not available');
      }

      // Upload the avatar image
      final mediaEntity = await uploadMedia!(
        filePath: event.filePath,
        onProgress: (progress) {
          // We can't emit here directly due to async gaps
          // The UI should listen to MediaBloc for progress
          logger.d('Avatar upload progress: ${(progress * 100).toInt()}%');
        },
      );

      logger.i('Avatar uploaded: ${mediaEntity.id}');

      // Now update the profile with the new avatar
      if (updateProfile != null) {
        final updatedUser = await updateProfile!(
          avatarMediaId: mediaEntity.id,
        );
        emit(AuthProfileUpdated(updatedUser));
        emit(AuthAuthenticated(updatedUser));
      } else {
        // Fallback: update locally
        final updatedUser = currentUser.copyWith(
          avatarMediaId: mediaEntity.id,
        );
        emit(AuthProfileUpdated(updatedUser));
        emit(AuthAuthenticated(updatedUser));
      }

      logger.i('Avatar updated successfully');
    } on AuthException catch (e) {
      logger.e('Avatar upload failed: ${e.message}');
      emit(AuthError(e.message));
      emit(AuthAuthenticated(currentUser));
    } catch (e) {
      logger.e('Unexpected error during avatar upload: $e');
      emit(AuthError('Avatar upload failed: $e'));
      emit(AuthAuthenticated(currentUser));
    }
  }
}
