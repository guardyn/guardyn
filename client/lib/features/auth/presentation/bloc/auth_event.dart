import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to register a new user
class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String deviceName;

  AuthRegisterRequested({
    required this.username,
    required this.password,
    required this.deviceName,
  });

  @override
  List<Object?> get props => [username, password, deviceName];
}

/// Event to login an existing user
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

/// Event to logout the current user
class AuthLogoutRequested extends AuthEvent {}

/// Event to delete user account permanently
class AuthDeleteAccountRequested extends AuthEvent {
  final String password;

  AuthDeleteAccountRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

/// Event to check authentication status (on app start)
class AuthCheckStatus extends AuthEvent {}
