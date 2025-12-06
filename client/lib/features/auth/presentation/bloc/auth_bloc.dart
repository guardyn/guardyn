import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:guardyn_client/features/auth/domain/usecases/login_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/logout_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/register_user.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:logger/logger.dart';

/// BLoC for authentication state management
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final AuthRepository authRepository;
  final CryptoService cryptoService;
  final Logger logger = Logger();

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.authRepository,
    required this.cryptoService,
  }) : super(AuthInitial()) {
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthCheckStatus>(_onCheckStatus);
  }

  /// Trigger background key replenishment after successful auth
  void _triggerBackgroundKeyReplenishment() {
    // Fire and forget - don't await, let it run in background
    Future.microtask(() async {
      try {
        final newKeys = await cryptoService
            .replenishOneTimePreKeysInBackground();
        if (newKeys.isNotEmpty) {
          logger.i(
            'Generated ${newKeys.length} new one-time pre-keys in background',
          );
          // TODO: Upload new keys to server when API is available
        }
      } catch (e) {
        logger.w('Background key replenishment failed: $e');
        // Non-fatal, keys can be replenished later
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
      // Emit only AuthAccountDeleted - the UI will handle navigation to login
      // Do NOT emit AuthUnauthenticated here as it causes _dependents.isEmpty error
      emit(AuthAccountDeleted('Your account has been permanently deleted'));
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
}
