import 'package:equatable/equatable.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - auth status unknown
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state (during register/login/logout)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

/// Authentication error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Account deletion in progress
class AuthAccountDeleting extends AuthState {
  const AuthAccountDeleting();
}

