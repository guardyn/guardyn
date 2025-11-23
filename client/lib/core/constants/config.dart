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
  static String get authHost {
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
  static const int webProxyPort = 8080;

  /// Get platform-specific gRPC URI for web
  /// Web platforms need http:// or https:// URIs for gRPC-Web via Envoy proxy
  static Uri getAuthUri() {
    if (kIsWeb) {
      // Use Envoy proxy on port 8080 which translates gRPC-Web to gRPC
      return Uri.parse('http://$authHost:$webProxyPort');
    }
    throw UnsupportedError('getAuthUri is only for web platforms');
  }

  static Uri getMessagingUri() {
    if (kIsWeb) {
      // Use Envoy proxy on port 8080 which translates gRPC-Web to gRPC
      return Uri.parse('http://$messagingHost:$webProxyPort');
    }
    throw UnsupportedError('getMessagingUri is only for web platforms');
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
