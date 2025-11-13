import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardyn_client/features/auth/domain/usecases/register_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/login_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/logout_user.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';
import 'package:guardyn_client/features/auth/domain/repositories/auth_repository.dart';

// Mock classes
class MockRegisterUser extends Mock implements RegisterUser {}
class MockLoginUser extends Mock implements LoginUser {}
class MockLogoutUser extends Mock implements LogoutUser {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockRegisterUser mockRegisterUser;
  late MockLoginUser mockLoginUser;
  late MockLogoutUser mockLogoutUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockRegisterUser = MockRegisterUser();
    mockLoginUser = MockLoginUser();
    mockLogoutUser = MockLogoutUser();
    mockAuthRepository = MockAuthRepository();
    
    authBloc = AuthBloc(
      registerUser: mockRegisterUser,
      loginUser: mockLoginUser,
      logoutUser: mockLogoutUser,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testUser = User(
      userId: 'user123',
      username: 'testuser',
      deviceId: 'device456',
    );

    group('AuthCheckStatus', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is authenticated',
        build: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckStatus()),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when not authenticated',
        build: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckStatus()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when authenticated but no user data',
        build: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckStatus()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on error',
        build: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenThrow(Exception('Storage error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckStatus()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when registration succeeds',
        build: () {
          when(() => mockRegisterUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
                deviceName: any(named: 'deviceName'),
              )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthRegisterRequested(
          username: 'testuser',
          password: 'password123',
          deviceName: 'Test Device',
        )),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when registration fails',
        build: () {
          when(() => mockRegisterUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
                deviceName: any(named: 'deviceName'),
              )).thenThrow(AuthException('Registration failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthRegisterRequested(
          username: 'testuser',
          password: 'password123',
          deviceName: 'Test Device',
        )),
        expect: () => [
          AuthLoading(),
          AuthError('Registration failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when username already exists',
        build: () {
          when(() => mockRegisterUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
                deviceName: any(named: 'deviceName'),
              )).thenThrow(AuthException('Username already exists'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthRegisterRequested(
          username: 'existinguser',
          password: 'password123',
          deviceName: 'Test Device',
        )),
        expect: () => [
          AuthLoading(),
          AuthError('Username already exists'),
        ],
      );
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login succeeds',
        build: () {
          when(() => mockLoginUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLoginRequested(
          username: 'testuser',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails',
        build: () {
          when(() => mockLoginUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenThrow(AuthException('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLoginRequested(
          username: 'testuser',
          password: 'wrongpassword',
        )),
        expect: () => [
          AuthLoading(),
          AuthError('Invalid credentials'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when network error occurs',
        build: () {
          when(() => mockLoginUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenThrow(Exception('Connection failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLoginRequested(
          username: 'testuser',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
        build: () {
          when(() => mockLogoutUser()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError, AuthUnauthenticated] when logout fails',
        build: () {
          when(() => mockLogoutUser())
              .thenThrow(Exception('Logout failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [
          AuthLoading(),
          isA<AuthError>(),
          AuthUnauthenticated(),
        ],
      );
    });

    group('State Transitions', () {
      test('initial state is AuthInitial', () {
        expect(authBloc.state, equals(AuthInitial()));
      });

      blocTest<AuthBloc, AuthState>(
        'maintains user data after successful login',
        build: () {
          when(() => mockLoginUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLoginRequested(
          username: 'testuser',
          password: 'password123',
        )),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<AuthAuthenticated>());
          expect((state as AuthAuthenticated).user.userId, equals('user123'));
          expect(state.user.username, equals('testuser'));
          expect(state.user.deviceId, equals('device456'));
        },
      );
    });

    group('Edge Cases', () {
      blocTest<AuthBloc, AuthState>(
        'handles empty username in registration',
        build: () {
          when(() => mockRegisterUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
                deviceName: any(named: 'deviceName'),
              )).thenThrow(AuthException('Username cannot be empty'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthRegisterRequested(
          username: '',
          password: 'password123',
          deviceName: 'Test Device',
        )),
        expect: () => [
          AuthLoading(),
          AuthError('Username cannot be empty'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles empty password in login',
        build: () {
          when(() => mockLoginUser(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenThrow(AuthException('Password cannot be empty'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLoginRequested(
          username: 'testuser',
          password: '',
        )),
        expect: () => [
          AuthLoading(),
          AuthError('Password cannot be empty'),
        ],
      );
    });
  });
}

