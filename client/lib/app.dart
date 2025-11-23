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
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/mark_as_read.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/receive_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/send_message.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';

class GuardynApp extends StatelessWidget {
  const GuardynApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup dependencies
    final grpcClients = getIt<GrpcClients>();
    final secureStorage = getIt<SecureStorage>();

    // Auth dependencies
    final remoteDatasource = AuthRemoteDatasource(grpcClients);
    final authRepository = AuthRepositoryImpl(
      remoteDatasource: remoteDatasource,
      secureStorage: secureStorage,
    );

    final registerUser = RegisterUser(authRepository);
    final loginUser = LoginUser(authRepository);
    final logoutUser = LogoutUser(authRepository);

    // Messaging dependencies
    final messageRemoteDatasource = MessageRemoteDatasource(grpcClients);
    final messageRepository = MessageRepositoryImpl(
      messageRemoteDatasource,
      secureStorage,
    );

    final sendMessage = SendMessage(messageRepository);
    final getMessages = GetMessages(messageRepository);
    final receiveMessages = ReceiveMessages(messageRepository);
    final markAsRead = MarkAsRead(messageRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            registerUser: registerUser,
            loginUser: loginUser,
            logoutUser: logoutUser,
            authRepository: authRepository,
          ),
        ),
        BlocProvider(
          create: (context) => MessageBloc(
            sendMessage: sendMessage,
            getMessages: getMessages,
            receiveMessages: receiveMessages,
            markAsRead: markAsRead,
          ),
        ),
      ],
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
