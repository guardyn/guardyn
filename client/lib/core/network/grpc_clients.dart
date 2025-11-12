import 'package:grpc/grpc.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/messaging.pbgrpc.dart';
import 'package:guardyn_client/core/constants/config.dart';

/// Manages gRPC client connections to backend services
class GrpcClients {
  late ClientChannel _authChannel;
  late ClientChannel _messagingChannel;

  late AuthServiceClient authClient;
  late MessagingServiceClient messagingClient;

  bool _initialized = false;

  /// Initialize gRPC channels and clients
  Future<void> initialize() async {
    if (_initialized) return;

    // Create channels (insecure for local development with port-forwarding)
    _authChannel = ClientChannel(
      AppConfig.authHost,
      port: AppConfig.authPort,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    _messagingChannel = ClientChannel(
      AppConfig.messagingHost,
      port: AppConfig.messagingPort,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    // Create service clients
    authClient = AuthServiceClient(_authChannel);
    messagingClient = MessagingServiceClient(_messagingChannel);

    _initialized = true;
  }

  /// Close all gRPC channels
  Future<void> dispose() async {
    await Future.wait([_authChannel.shutdown(), _messagingChannel.shutdown()]);
    _initialized = false;
  }
}
