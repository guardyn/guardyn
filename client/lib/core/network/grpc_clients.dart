import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc/grpc_web.dart';
import 'package:guardyn_client/core/constants/config.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/messaging.pbgrpc.dart';

/// Manages gRPC client connections to backend services
class GrpcClients {
  late ClientChannelBase _authChannel;
  late ClientChannelBase _messagingChannel;

  late AuthServiceClient authClient;
  late MessagingServiceClient messagingClient;

  bool _initialized = false;

  /// Create platform-specific gRPC channel
  ClientChannelBase _createChannel(String host, int port, {Uri? webUri}) {
    if (kIsWeb) {
      // Web platforms (Chrome, Firefox) need gRPC-Web transport
      // This uses HTTP/1.1 or HTTP/2 via browser's fetch API
      if (webUri == null) {
        throw ArgumentError('webUri is required for web platforms');
      }
      return GrpcWebClientChannel.xhr(webUri);
    } else {
      // Native platforms (Android, iOS, Linux, macOS, Windows)
      return ClientChannel(
        host,
        port: port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );
    }
  }

  /// Initialize gRPC channels and clients
  Future<void> initialize() async {
    if (_initialized) return;

    // Create platform-specific channels
    _authChannel = _createChannel(
      AppConfig.authHost,
      AppConfig.authPort,
      webUri: kIsWeb ? AppConfig.getAuthUri() : null,
    );
    _messagingChannel = _createChannel(
      AppConfig.messagingHost,
      AppConfig.messagingPort,
      webUri: kIsWeb ? AppConfig.getMessagingUri() : null,
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
