import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/constants/config.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/messaging.pbgrpc.dart';
import 'package:guardyn_client/generated/presence.pbgrpc.dart';

/// Manages gRPC client connections to backend services
///
/// Supported platforms: Android, iOS, Linux, macOS, Windows
/// Web is NOT supported for security reasons.
class GrpcClients {
  late ClientChannel _authChannel;
  late ClientChannel _messagingChannel;
  late ClientChannel _presenceChannel;

  late AuthServiceClient authClient;
  late MessagingServiceClient messagingClient;
  late PresenceServiceClient presenceClient;

  bool _initialized = false;

  /// Create gRPC channel for native platforms
  ClientChannel _createChannel(String host, int port) {
    return ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        // Connection timeout for initial connection
        connectionTimeout: Duration(seconds: 10),
        // Idle timeout to close unused connections
        idleTimeout: Duration(minutes: 5),
      ),
    );
  }

  /// Initialize gRPC channels and clients
  Future<void> initialize() async {
    if (_initialized) return;

    // Create native gRPC channels
    _authChannel = _createChannel(
      AppConfig.authHost,
      AppConfig.authPort,
    );
    _messagingChannel = _createChannel(
      AppConfig.messagingHost,
      AppConfig.messagingPort,
    );
    _presenceChannel = _createChannel(
      AppConfig.presenceHost,
      AppConfig.presencePort,
    );

    // Create service clients
    authClient = AuthServiceClient(_authChannel);
    messagingClient = MessagingServiceClient(_messagingChannel);
    presenceClient = PresenceServiceClient(_presenceChannel);

    _initialized = true;
  }

  /// Close all gRPC channels
  Future<void> dispose() async {
    await Future.wait([
      _authChannel.shutdown(),
      _messagingChannel.shutdown(),
      _presenceChannel.shutdown(),
    ]);
    _initialized = false;
  }
}
