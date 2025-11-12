import 'package:get_it/get_it.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register core services
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());

  // Register gRPC clients
  final grpcClients = GrpcClients();
  await grpcClients.initialize();
  getIt.registerSingleton<GrpcClients>(grpcClients);

  // Note: Feature-specific dependencies will be registered by their modules
}
