import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
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
import 'package:guardyn_client/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:guardyn_client/features/groups/data/repositories/group_repository_impl.dart';
import 'package:guardyn_client/features/groups/domain/usecases/add_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/create_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_group_by_id.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_group_messages.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_groups.dart';
import 'package:guardyn_client/features/groups/domain/usecases/leave_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/remove_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/send_group_message.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart';
import 'package:guardyn_client/features/groups/presentation/pages/group_chat_page.dart';
import 'package:guardyn_client/features/groups/presentation/pages/group_create_page.dart';
import 'package:guardyn_client/features/groups/presentation/pages/group_list_page.dart';
import 'package:guardyn_client/features/messaging/data/datasources/key_exchange_datasource.dart';
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/decrypt_message.dart';
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
    final cryptoService = getIt<CryptoService>();

    // Auth dependencies
    final remoteDatasource = AuthRemoteDatasource(grpcClients, cryptoService);
    final authRepository = AuthRepositoryImpl(
      remoteDatasource: remoteDatasource,
      secureStorage: secureStorage,
    );

    final registerUser = RegisterUser(authRepository);
    final loginUser = LoginUser(authRepository);
    final logoutUser = LogoutUser(authRepository);

    // Messaging dependencies
    final messageRemoteDatasource = MessageRemoteDatasource(grpcClients);
    final keyExchangeDatasource = KeyExchangeDatasource(grpcClients);
    final messageRepository = MessageRepositoryImpl(
      messageRemoteDatasource,
      keyExchangeDatasource,
      secureStorage,
      cryptoService,
    );

    final sendMessage = SendMessage(messageRepository);
    final getMessages = GetMessages(messageRepository);
    final receiveMessages = ReceiveMessages(messageRepository);
    final markAsRead = MarkAsRead(messageRepository);
    final decryptMessage = DecryptMessage(messageRepository);

    // Groups dependencies
    final groupRemoteDatasource = GroupRemoteDatasource(grpcClients);
    final groupRepository = GroupRepositoryImpl(
      groupRemoteDatasource,
      secureStorage,
    );

    final createGroup = CreateGroup(groupRepository);
    final getGroups = GetGroups(groupRepository);
    final getGroupById = GetGroupById(groupRepository);
    final sendGroupMessage = SendGroupMessage(groupRepository);
    final getGroupMessages = GetGroupMessages(groupRepository);
    final addGroupMember = AddGroupMember(groupRepository);
    final removeGroupMember = RemoveGroupMember(groupRepository);
    final leaveGroup = LeaveGroup(groupRepository);

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
            decryptMessage: decryptMessage,
          ),
        ),
        BlocProvider(
          create: (context) => GroupBloc(
            createGroup: createGroup,
            getGroups: getGroups,
            getGroupById: getGroupById,
            sendGroupMessage: sendGroupMessage,
            getGroupMessages: getGroupMessages,
            addGroupMember: addGroupMember,
            removeGroupMember: removeGroupMember,
            leaveGroup: leaveGroup,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Guardyn',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        // Localization support for international keyboard input
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ru'),
          Locale('uk'),
          Locale('de'),
          Locale('fr'),
          Locale('es'),
          Locale('zh'),
          Locale('ja'),
          Locale('ko'),
          Locale('ar'),
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegistrationPage(),
          '/home': (context) => const HomePage(),
          '/groups': (context) => const GroupListPage(),
          '/groups/create': (context) => const GroupCreatePage(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes for group chat
          if (settings.name == '/groups/chat') {
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (context) => GroupChatPage(
                groupId: args['groupId']!,
                groupName: args['groupName']!,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
