import 'package:get_it/get_it.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:injectable/injectable.dart';

// Messaging feature imports
import 'package:guardyn_client/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:guardyn_client/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:guardyn_client/features/messaging/domain/repositories/message_repository.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/send_message.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/get_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/receive_messages.dart';
import 'package:guardyn_client/features/messaging/domain/usecases/mark_as_read.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register core services
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());

  // Register gRPC clients
  final grpcClients = GrpcClients();
  await grpcClients.initialize();
  getIt.registerSingleton<GrpcClients>(grpcClients);

  // Register messaging feature dependencies
  _registerMessagingDependencies();
}

void _registerMessagingDependencies() {
  // Data layer
  getIt.registerLazySingleton<MessageRemoteDatasource>(
    () => MessageRemoteDatasource(getIt<GrpcClients>()),
  );

  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(
      getIt<MessageRemoteDatasource>(),
      getIt<SecureStorage>(),
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

