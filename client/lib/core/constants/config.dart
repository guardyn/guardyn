import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Application configuration constants
class AppConfig {
  // gRPC service endpoints
  // For local development with k3d port-forwarding:
  //   kubectl port-forward -n apps svc/auth-service 50051:50051
  //   kubectl port-forward -n apps svc/messaging-service 50052:50052

  /// Get platform-specific gRPC host
  /// - Android Emulator: 10.0.2.2 (host machine from emulator)
  /// - iOS Simulator, Chrome, Desktop: localhost
  /// Can be overridden with --dart-define=GRPC_HOST=<host>
  static String get authHost {
    // Allow override via dart-define for testing
    const testHost = String.fromEnvironment('GRPC_HOST');
    if (testHost.isNotEmpty) {
      return testHost;
    }
    
    if (kIsWeb) {
      // Web (Chrome, Firefox, etc.) - use localhost
      return 'localhost';
    } else if (Platform.isAndroid) {
      // Android emulator - use special host address
      return '10.0.2.2';
    } else {
      // iOS Simulator, Linux, macOS, Windows - use localhost
      return 'localhost';
    }
  }

  static const int authPort = 50051;

  static String get messagingHost => authHost; // Same logic as authHost
  static const int messagingPort = 50052;

  // Web-specific ports for Envoy gRPC-Web proxy
  // Note: Using port 18080 to avoid conflict with k3d loadbalancer on 8080
  static const int webProxyPort = 18080;

  /// Get platform-specific gRPC URI for web
  /// Web platforms need http:// or https:// URIs for gRPC-Web via Envoy proxy
  static Uri getAuthUri() {
    if (kIsWeb) {
      // Use Envoy proxy on port 18080 which translates gRPC-Web to gRPC
      return Uri.parse('http://$authHost:$webProxyPort');
    }
    throw UnsupportedError('getAuthUri is only for web platforms');
  }

  static Uri getMessagingUri() {
    if (kIsWeb) {
      // Use Envoy proxy on port 18080 which translates gRPC-Web to gRPC
      return Uri.parse('http://$messagingHost:$webProxyPort');
    }
    throw UnsupportedError('getMessagingUri is only for web platforms');
  }

  // WebSocket configuration
  static String get websocketHost => authHost; // Same logic as gRPC hosts
  static const int websocketPort = 8080;
  static const bool websocketSecure = false; // Use 'ws://' for local dev

  /// Get WebSocket URL with authentication token
  static String getWebSocketUrl(String token) {
    final protocol = websocketSecure ? 'wss' : 'ws';
    return '$protocol://$websocketHost:$websocketPort/ws?token=$token';
  }

  // For production (with TLS):
  // static const String authHost = 'auth.guardyn.io';
  // static const int authPort = 443;
  // static const String messagingHost = 'messaging.guardyn.io';
  // static const int messagingPort = 443;

  // App metadata
  static const String appName = 'Guardyn';
  static const String appVersion = '0.1.0';
}
