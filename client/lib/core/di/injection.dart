import 'package:get_it/get_it.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/services/notification_service.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
// Auth feature imports
import 'package:guardyn_client/features/auth/data/datasources/auth_remote_datasource.dart';
// Groups feature imports
import 'package:guardyn_client/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:guardyn_client/features/groups/data/repositories/group_repository_impl.dart';
import 'package:guardyn_client/features/groups/domain/repositories/group_repository.dart';
import 'package:guardyn_client/features/groups/domain/usecases/add_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/create_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_group_by_id.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_group_messages.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_groups.dart';
import 'package:guardyn_client/features/groups/domain/usecases/leave_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/remove_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/send_group_message.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart';
// Messaging feature imports
import 'package:guardyn_client/features/messaging/data/datasources/key_exchange_datasource.dart';
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/data/datasources/websocket_datasource.dart';
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:guardyn_client/features/messaging/domain/repositories/message_repository.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/mark_as_read.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/receive_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/send_message.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';
// Presence feature imports
import 'package:guardyn_client/features/presence/data/datasources/presence_remote_datasource.dart';
import 'package:guardyn_client/features/presence/data/repositories/presence_repository_impl.dart';
import 'package:guardyn_client/features/presence/domain/repositories/presence_repository.dart';
import 'package:guardyn_client/features/presence/domain/usecases/get_bulk_presence.dart';
import 'package:guardyn_client/features/presence/domain/usecases/get_user_presence.dart';
import 'package:guardyn_client/features/presence/domain/usecases/send_heartbeat.dart';
import 'package:guardyn_client/features/presence/domain/usecases/send_typing_indicator.dart';
import 'package:guardyn_client/features/presence/domain/usecases/update_my_status.dart';
import 'package:guardyn_client/features/presence/presentation/bloc/presence_bloc.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register core services
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());

  // Register crypto service for E2EE
  final cryptoService = CryptoService();
  await cryptoService.initialize();
  getIt.registerSingleton<CryptoService>(cryptoService);

  // Register notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  getIt.registerSingleton<NotificationService>(notificationService);

  // Register gRPC clients
  final grpcClients = GrpcClients();
  await grpcClients.initialize();
  getIt.registerSingleton<GrpcClients>(grpcClients);

  // Register auth feature dependencies
  _registerAuthDependencies();

  // Register messaging feature dependencies
  _registerMessagingDependencies();

  // Register groups feature dependencies
  _registerGroupsDependencies();

  // Register presence feature dependencies
  _registerPresenceDependencies();
}

void _registerAuthDependencies() {
  // Data layer
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(
      getIt<GrpcClients>(),
      getIt<CryptoService>(),
    ),
  );
}

void _registerMessagingDependencies() {
  // Data layer
  getIt.registerLazySingleton<MessageRemoteDatasource>(
    () => MessageRemoteDatasource(getIt<GrpcClients>()),
  );

  getIt.registerLazySingleton<KeyExchangeDatasource>(
    () => KeyExchangeDatasource(getIt<GrpcClients>()),
  );

  // WebSocket datasource for real-time messaging
  getIt.registerLazySingleton<WebSocketDatasource>(
    () => WebSocketDatasource(),
  );

  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(
      getIt<MessageRemoteDatasource>(),
      getIt<KeyExchangeDatasource>(),
      getIt<SecureStorage>(),
      getIt<CryptoService>(),
    ),
  );

  // Domain layer - Use cases
  getIt.registerLazySingleton<SendMessage>(
    () => SendMessage(getIt<MessageRepository>()),
  );

  getIt.registerLazySingleton<GetMessages>(
    () => GetMessages(getIt<MessageRepository>()),
  );

  getIt.registerLazySingleton<ReceiveMessages>(
    () => ReceiveMessages(getIt<MessageRepository>()),
  );

  getIt.registerLazySingleton<MarkAsRead>(
    () => MarkAsRead(getIt<MessageRepository>()),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<MessageBloc>(
    () => MessageBloc(
      sendMessage: getIt<SendMessage>(),
      getMessages: getIt<GetMessages>(),
      receiveMessages: getIt<ReceiveMessages>(),
      markAsRead: getIt<MarkAsRead>(),
    ),
  );
}

void _registerGroupsDependencies() {
  // Data layer
  getIt.registerLazySingleton<GroupRemoteDatasource>(
    () => GroupRemoteDatasource(getIt<GrpcClients>()),
  );

  getIt.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      getIt<GroupRemoteDatasource>(),
      getIt<SecureStorage>(),
    ),
  );

  // Domain layer - Use cases
  getIt.registerLazySingleton<CreateGroup>(
    () => CreateGroup(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<GetGroups>(
    () => GetGroups(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<GetGroupById>(
    () => GetGroupById(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<SendGroupMessage>(
    () => SendGroupMessage(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<GetGroupMessages>(
    () => GetGroupMessages(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<AddGroupMember>(
    () => AddGroupMember(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<RemoveGroupMember>(
    () => RemoveGroupMember(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<LeaveGroup>(
    () => LeaveGroup(getIt<GroupRepository>()),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<GroupBloc>(
    () => GroupBloc(
      createGroup: getIt<CreateGroup>(),
      getGroups: getIt<GetGroups>(),
      getGroupById: getIt<GetGroupById>(),
      sendGroupMessage: getIt<SendGroupMessage>(),
      getGroupMessages: getIt<GetGroupMessages>(),
      addGroupMember: getIt<AddGroupMember>(),
      removeGroupMember: getIt<RemoveGroupMember>(),
      leaveGroup: getIt<LeaveGroup>(),
    ),
  );
}

void _registerPresenceDependencies() {
  // Data layer
  getIt.registerLazySingleton<PresenceRemoteDatasource>(
    () => PresenceRemoteDatasource(getIt<GrpcClients>()),
  );

  getIt.registerLazySingleton<PresenceRepository>(
    () => PresenceRepositoryImpl(
      getIt<PresenceRemoteDatasource>(),
      getIt<SecureStorage>(),
    ),
  );

  // Domain layer - Use cases
  getIt.registerLazySingleton<GetUserPresence>(
    () => GetUserPresence(getIt<PresenceRepository>()),
  );

  getIt.registerLazySingleton<GetBulkPresence>(
    () => GetBulkPresence(getIt<PresenceRepository>()),
  );

  getIt.registerLazySingleton<UpdateMyStatus>(
    () => UpdateMyStatus(getIt<PresenceRepository>()),
  );

  getIt.registerLazySingleton<SendTypingIndicator>(
    () => SendTypingIndicator(getIt<PresenceRepository>()),
  );

  getIt.registerLazySingleton<SendHeartbeat>(
    () => SendHeartbeat(getIt<PresenceRepository>()),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<PresenceBloc>(
    () => PresenceBloc(
      getUserPresence: getIt<GetUserPresence>(),
      getBulkPresence: getIt<GetBulkPresence>(),
      updateMyStatus: getIt<UpdateMyStatus>(),
      sendTypingIndicator: getIt<SendTypingIndicator>(),
      sendHeartbeat: getIt<SendHeartbeat>(),
    ),
  );
}
