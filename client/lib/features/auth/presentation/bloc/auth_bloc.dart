import 'package:flutter_bloc/flutter_bloc.dart';
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
  final Logger logger = Logger();

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
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
