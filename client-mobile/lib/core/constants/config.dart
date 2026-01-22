import 'dart:io' show Platform;

/// Application configuration constants
///
/// Guardyn supports ONLY native platforms:
/// - Mobile: Android, iOS
/// - Desktop: Linux, macOS, Windows (via Tauri client-desktop/)
///
/// Web platform is NOT supported for security reasons:
/// - No Rust FFI for post-quantum cryptography
/// - No secure key storage (localStorage is vulnerable)
/// - XSS and browser extension attacks possible
class AppConfig {
  // gRPC service endpoints
  // For local development with Docker Compose:
  //   docker compose -f docker-compose.dev.yml up -d
  //   Services available on localhost:50051, localhost:50052, etc.

  /// Get platform-specific gRPC host
  /// - Android Emulator: 10.0.2.2 (host machine from emulator)
  /// - iOS Simulator, Desktop: localhost
  /// Can be overridden with --dart-define=GRPC_HOST=<host>
  static String get authHost {
    // Allow override via dart-define for testing
    const testHost = String.fromEnvironment('GRPC_HOST');
    if (testHost.isNotEmpty) {
      return testHost;
    }

    if (Platform.isAndroid) {
      // Android emulator - use special host address to reach host machine
      return '10.0.2.2';
    } else {
      // iOS Simulator, Linux, macOS, Windows - use localhost
      return 'localhost';
    }
  }

  static const int authPort = 50051;

  static String get messagingHost => authHost; // Same logic as authHost
  static const int messagingPort = 50052;

  static String get presenceHost => authHost; // Same logic as authHost
  static const int presencePort = 50053;

  static String get mediaHost => authHost; // Same logic as authHost
  static const int mediaPort = 50054;

  // WebSocket configuration
  static String get websocketHost => authHost; // Same logic as gRPC hosts
  static const int websocketPort = 8081;
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

