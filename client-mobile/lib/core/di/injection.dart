import 'package:get_it/get_it.dart';
import 'package:guardyn_client/core/auth/token_manager.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/services/notification_service.dart';
import 'package:guardyn_client/core/services/user_provider.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
// Auth feature imports
import 'package:guardyn_client/features/auth/data/datasources/auth_remote_datasource.dart';
// Calls feature imports
import 'package:guardyn_client/features/calls/data/datasources/datasources.dart';
import 'package:guardyn_client/features/calls/data/repositories/call_repository_impl.dart';
import 'package:guardyn_client/features/calls/domain/repositories/call_repository.dart';
import 'package:guardyn_client/features/calls/domain/usecases/usecases.dart';
import 'package:guardyn_client/features/calls/presentation/bloc/bloc.dart';
// Contacts feature imports
import 'package:guardyn_client/features/contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:guardyn_client/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:guardyn_client/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:guardyn_client/features/contacts/presentation/bloc/contacts_bloc.dart';
// Groups feature imports
import 'package:guardyn_client/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:guardyn_client/features/groups/data/repositories/group_repository_impl.dart';
import 'package:guardyn_client/features/groups/domain/repositories/group_repository.dart';
import 'package:guardyn_client/features/groups/domain/usecases/add_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/change_member_role.dart';
import 'package:guardyn_client/features/groups/domain/usecases/create_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/delete_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_group_by_id.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_group_messages.dart';
import 'package:guardyn_client/features/groups/domain/usecases/get_groups.dart';
import 'package:guardyn_client/features/groups/domain/usecases/leave_group.dart';
import 'package:guardyn_client/features/groups/domain/usecases/remove_group_member.dart';
import 'package:guardyn_client/features/groups/domain/usecases/send_group_message.dart';
import 'package:guardyn_client/features/groups/domain/usecases/send_group_typing_indicator.dart';
import 'package:guardyn_client/features/groups/domain/usecases/update_group.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart';
// Media feature imports
import 'package:guardyn_client/features/media/data/datasources/media_local_datasource.dart';
import 'package:guardyn_client/features/media/data/datasources/media_remote_datasource.dart';
import 'package:guardyn_client/features/media/data/repositories/media_repository_impl.dart';
import 'package:guardyn_client/features/media/domain/repositories/media_repository.dart';
import 'package:guardyn_client/features/media/domain/usecases/delete_media.dart';
import 'package:guardyn_client/features/media/domain/usecases/download_media.dart';
import 'package:guardyn_client/features/media/domain/usecases/get_media_metadata.dart';
import 'package:guardyn_client/features/media/domain/usecases/get_thumbnail_url.dart';
import 'package:guardyn_client/features/media/domain/usecases/list_media.dart';
import 'package:guardyn_client/features/media/domain/usecases/manage_media_cache.dart';
import 'package:guardyn_client/features/media/domain/usecases/upload_media.dart';
import 'package:guardyn_client/features/media/presentation/bloc/media_bloc.dart';
// Messaging feature imports
import 'package:guardyn_client/features/messaging/data/datasources/key_exchange_datasource.dart';
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/data/datasources/notification_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/data/datasources/websocket_datasource.dart';
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:guardyn_client/features/messaging/data/repositories/notification_repository_impl.dart';
import 'package:guardyn_client/features/messaging/domain/repositories/message_repository.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/block_user.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/clear_chat.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/decrypt_message.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/delete_conversation.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/delete_message.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_user_display_name.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/mark_as_read.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/mute_conversation.dart';
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
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register core services
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());

  // Register user provider for current user access
  getIt.registerLazySingleton<UserProvider>(
    () => UserProvider(getIt<SecureStorage>()),
  );

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

  // Register TokenManager for automatic token refresh
  final tokenManager = TokenManager(
    getIt<SecureStorage>(),
    getIt<GrpcClients>(),
  );
  await tokenManager.initialize();
  getIt.registerSingleton<TokenManager>(tokenManager);

  // Register auth feature dependencies
  _registerAuthDependencies();

  // Register messaging feature dependencies
  _registerMessagingDependencies();

  // Register groups feature dependencies
  _registerGroupsDependencies();

  // Register presence feature dependencies
  _registerPresenceDependencies();

  // Register calls feature dependencies
  _registerCallsDependencies();

  // Register media feature dependencies
  _registerMediaDependencies();

  // Register contacts feature dependencies
  _registerContactsDependencies();
}

void _registerAuthDependencies() {
  // Data layer
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(getIt<GrpcClients>(), getIt<CryptoService>()),
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
  getIt.registerLazySingleton<WebSocketDatasource>(() => WebSocketDatasource());

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

  getIt.registerLazySingleton<DecryptMessage>(
    () => DecryptMessage(getIt<MessageRepository>()),
  );

  getIt.registerLazySingleton<ClearChat>(
    () => ClearChat(getIt<MessageRepository>()),
  );

  getIt.registerLazySingleton<DeleteMessage>(
    () => DeleteMessage(getIt<MessageRepository>()),
  );

  // Notification-related dependencies for messaging
  getIt.registerLazySingleton<NotificationRemoteDatasource>(
    () => NotificationRemoteDatasource(getIt<GrpcClients>()),
  );

  getIt.registerLazySingleton<MuteConversationRepository>(
    () => NotificationRepositoryImpl(
      getIt<NotificationRemoteDatasource>(),
      getIt<SecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<MuteConversation>(
    () => MuteConversation(getIt<MuteConversationRepository>()),
  );

  getIt.registerLazySingleton<GetUserDisplayName>(
    () => GetUserDisplayName(
      grpcClients: getIt<GrpcClients>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  // Block/Unblock user use cases
  getIt.registerLazySingleton<BlockUser>(
    () => BlockUser(
      grpcClients: getIt<GrpcClients>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<UnblockUser>(
    () => UnblockUser(
      grpcClients: getIt<GrpcClients>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<GetBlockedUsers>(
    () => GetBlockedUsers(
      grpcClients: getIt<GrpcClients>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  // Delete conversation use case
  getIt.registerLazySingleton<DeleteConversation>(
    () => DeleteConversation(
      grpcClients: getIt<GrpcClients>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<MessageBloc>(
    () => MessageBloc(
      sendMessage: getIt<SendMessage>(),
      getMessages: getIt<GetMessages>(),
      receiveMessages: getIt<ReceiveMessages>(),
      markAsRead: getIt<MarkAsRead>(),
      decryptMessage: getIt<DecryptMessage>(),
      clearChat: getIt<ClearChat>(),
      deleteMessage: getIt<DeleteMessage>(),
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
      getIt<GetUserDisplayName>(),
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

  getIt.registerLazySingleton<DeleteGroup>(
    () => DeleteGroup(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<UpdateGroup>(
    () => UpdateGroup(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<SendGroupTypingIndicator>(
    () => SendGroupTypingIndicator(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<ChangeMemberRole>(
    () => ChangeMemberRole(getIt<GroupRepository>()),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<GroupBloc>(
    () => GroupBloc(
      createGroup: getIt<CreateGroup>(),
      deleteGroup: getIt<DeleteGroup>(),
      getGroups: getIt<GetGroups>(),
      getGroupById: getIt<GetGroupById>(),
      sendGroupMessage: getIt<SendGroupMessage>(),
      getGroupMessages: getIt<GetGroupMessages>(),
      addGroupMember: getIt<AddGroupMember>(),
      removeGroupMember: getIt<RemoveGroupMember>(),
      leaveGroup: getIt<LeaveGroup>(),
      updateGroup: getIt<UpdateGroup>(),
      sendGroupTypingIndicator: getIt<SendGroupTypingIndicator>(),
      changeMemberRole: getIt<ChangeMemberRole>(),
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
      presenceRepository: getIt<PresenceRepository>(),
    ),
  );
}

void _registerCallsDependencies() {
  // Logger for calls
  final callLogger = Logger(
    printer: PrettyPrinter(methodCount: 0),
    filter: ProductionFilter(),
  );

  // Data layer - Data Sources
  getIt.registerLazySingleton<WebRTCDataSource>(
    () => WebRTCDataSourceImpl(logger: callLogger),
  );

  getIt.registerLazySingleton<SignalingDataSource>(
    () => SignalingDataSourceImpl(logger: callLogger),
  );

  // Repository
  getIt.registerLazySingleton<CallRepository>(
    () => CallRepositoryImpl(
      webrtcDataSource: getIt<WebRTCDataSource>(),
      signalingDataSource: getIt<SignalingDataSource>(),
      logger: callLogger,
      userProvider: getIt<UserProvider>(),
    ),
  );

  // Domain layer - Use cases
  getIt.registerLazySingleton<InitiateCall>(
    () => InitiateCall(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<AcceptCall>(
    () => AcceptCall(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<RejectCall>(
    () => RejectCall(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<EndCall>(
    () => EndCall(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<ToggleMute>(
    () => ToggleMute(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<ToggleVideo>(
    () => ToggleVideo(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<ToggleSpeaker>(
    () => ToggleSpeaker(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<SwitchCamera>(
    () => SwitchCamera(getIt<CallRepository>()),
  );

  getIt.registerLazySingleton<GetCallHistory>(
    () => GetCallHistory(getIt<CallRepository>()),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<CallBloc>(
    () => CallBloc(
      initiateCall: getIt<InitiateCall>(),
      acceptCall: getIt<AcceptCall>(),
      endCall: getIt<EndCall>(),
      rejectCall: getIt<RejectCall>(),
      toggleMute: getIt<ToggleMute>(),
      toggleVideo: getIt<ToggleVideo>(),
      toggleSpeaker: getIt<ToggleSpeaker>(),
      switchCamera: getIt<SwitchCamera>(),
    ),
  );

  getIt.registerFactory<CallHistoryBloc>(
    () => CallHistoryBloc(
      getCallHistory: getIt<GetCallHistory>(),
      callRepository: getIt<CallRepository>(),
    ),
  );
}

void _registerMediaDependencies() {
  // HTTP client for presigned URL uploads/downloads
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Data layer
  getIt.registerLazySingleton<MediaLocalDatasource>(
    () => MediaLocalDatasource(),
  );

  getIt.registerLazySingleton<MediaRemoteDatasource>(
    () => MediaRemoteDatasource(
      getIt<GrpcClients>(),
      getIt<http.Client>(),
      getIt<TokenManager>(),
    ),
  );

  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(
      remoteDatasource: getIt<MediaRemoteDatasource>(),
      localDatasource: getIt<MediaLocalDatasource>(),
    ),
  );

  // Domain layer - Use cases
  getIt.registerLazySingleton<UploadMedia>(
    () => UploadMedia(getIt<MediaRepository>()),
  );

  getIt.registerLazySingleton<DownloadMedia>(
    () => DownloadMedia(getIt<MediaRepository>()),
  );

  getIt.registerLazySingleton<ListMedia>(
    () => ListMedia(getIt<MediaRepository>()),
  );

  getIt.registerLazySingleton<GetMediaMetadata>(
    () => GetMediaMetadata(getIt<MediaRepository>()),
  );

  getIt.registerLazySingleton<GetThumbnailUrl>(
    () => GetThumbnailUrl(getIt<MediaRepository>()),
  );

  getIt.registerLazySingleton<DeleteMedia>(
    () => DeleteMedia(getIt<MediaRepository>()),
  );

  getIt.registerLazySingleton<ManageMediaCache>(
    () => ManageMediaCache(getIt<MediaRepository>()),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<MediaBloc>(
    () => MediaBloc(
      uploadMedia: getIt<UploadMedia>(),
      downloadMedia: getIt<DownloadMedia>(),
      listMedia: getIt<ListMedia>(),
      getMediaMetadata: getIt<GetMediaMetadata>(),
      getThumbnailUrl: getIt<GetThumbnailUrl>(),
      deleteMedia: getIt<DeleteMedia>(),
      manageMediaCache: getIt<ManageMediaCache>(),
    ),
  );
}

void _registerContactsDependencies() {
  // Data layer
  getIt.registerLazySingleton<ContactsRemoteDatasource>(
    () => ContactsRemoteDatasource(getIt<GrpcClients>()),
  );

  getIt.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(
      getIt<ContactsRemoteDatasource>(),
      getIt<SecureStorage>(),
    ),
  );

  // Presentation layer - BLoC
  getIt.registerFactory<ContactsBloc>(
    () => ContactsBloc(getIt<ContactsRepository>()),
  );
}
