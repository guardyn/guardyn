import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/constants/config.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/media.pbgrpc.dart';
import 'package:guardyn_client/generated/messaging.pbgrpc.dart';
import 'package:guardyn_client/generated/notifications.pbgrpc.dart';
import 'package:guardyn_client/generated/presence.pbgrpc.dart';

/// Manages gRPC client connections to backend services
///
/// Supported platforms: Android, iOS, Linux, macOS, Windows
/// Web is NOT supported for security reasons.
class GrpcClients {
  late ClientChannel _authChannel;
  late ClientChannel _messagingChannel;
  late ClientChannel _presenceChannel;
  late ClientChannel _mediaChannel;
  late ClientChannel _notificationChannel;

  late AuthServiceClient authClient;
  late MessagingServiceClient messagingClient;
  late PresenceServiceClient presenceClient;
  late MediaServiceClient mediaClient;
  late NotificationServiceClient notificationClient;

  bool _initialized = false;

  /// Create gRPC channel for native platforms with keepalive settings
  /// Keepalive prevents "Connection is being forcefully terminated" errors
  ClientChannel _createChannel(String host, int port) {
    return ClientChannel(
      host,
      port: port,
      options: ChannelOptions(
        credentials: const ChannelCredentials.insecure(),
        // Connection timeout for initial connection
        connectionTimeout: const Duration(seconds: 10),
        // Idle timeout to close unused connections
        idleTimeout: const Duration(minutes: 5),
        // Keepalive settings to prevent connection drops
        // Send keepalive pings every 30 seconds when there's no activity
        keepAlive: const ClientKeepAliveOptions(
          // Send ping after 30 seconds of inactivity
          pingInterval: Duration(seconds: 30),
          // Wait 20 seconds for ping response
          timeout: Duration(seconds: 20),
          // Send keepalive even without active calls
          permitWithoutCalls: true,
        ),
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
    _mediaChannel = _createChannel(
      AppConfig.mediaHost,
      AppConfig.mediaPort,
    );
    _notificationChannel = _createChannel(
      AppConfig.notificationHost,
      AppConfig.notificationPort,
    );

    // Create service clients
    authClient = AuthServiceClient(_authChannel);
    messagingClient = MessagingServiceClient(_messagingChannel);
    presenceClient = PresenceServiceClient(_presenceChannel);
    mediaClient = MediaServiceClient(_mediaChannel);
    notificationClient = NotificationServiceClient(_notificationChannel);

    _initialized = true;
  }

  /// Close all gRPC channels
  Future<void> dispose() async {
    await Future.wait([
      _authChannel.shutdown(),
      _messagingChannel.shutdown(),
      _presenceChannel.shutdown(),
      _mediaChannel.shutdown(),
      _notificationChannel.shutdown(),
    ]);
    _initialized = false;
  }
}
