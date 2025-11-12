import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardyn_client/core/di/injection.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:guardyn_client/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:guardyn_client/features/auth/domain/usecases/login_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/logout_user.dart';
import 'package:guardyn_client/features/auth/domain/usecases/register_user.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardyn_client/features/auth/presentation/pages/login_page.dart';
import 'package:guardyn_client/features/auth/presentation/pages/registration_page.dart';
import 'package:guardyn_client/features/auth/presentation/pages/splash_page.dart';
import 'package:guardyn_client/features/chat/presentation/pages/home_page.dart';

class GuardynApp extends StatelessWidget {
  const GuardynApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup dependencies
    final grpcClients = getIt<GrpcClients>();
    final secureStorage = getIt<SecureStorage>();

    final remoteDatasource = AuthRemoteDatasource(grpcClients);
    final authRepository = AuthRepositoryImpl(
      remoteDatasource: remoteDatasource,
      secureStorage: secureStorage,
    );

    final registerUser = RegisterUser(authRepository);
    final loginUser = LoginUser(authRepository);
    final logoutUser = LogoutUser(authRepository);

    return BlocProvider(
      create: (context) => AuthBloc(
        registerUser: registerUser,
        loginUser: loginUser,
        logoutUser: logoutUser,
        authRepository: authRepository,
      ),
      child: MaterialApp(
        title: 'Guardyn',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegistrationPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
