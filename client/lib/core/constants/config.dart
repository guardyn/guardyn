/// Application configuration constants
class AppConfig {
  // gRPC service endpoints
  // For local development with k3d port-forwarding:
  //   kubectl port-forward -n apps svc/auth-service 50051:50051
  //   kubectl port-forward -n apps svc/messaging-service 50052:50052

  // IMPORTANT: Android Emulator uses 10.0.2.2 to access host machine
  // Use 'localhost' for iOS Simulator, Chrome, Desktop
  // Use '10.0.2.2' for Android Emulator
  static const String authHost =
      '10.0.2.2'; // Changed from 'localhost' for Android
  static const int authPort = 50051;

  static const String messagingHost =
      '10.0.2.2'; // Changed from 'localhost' for Android
  static const int messagingPort = 50052;

  // For production (with TLS):
  // static const String authHost = 'auth.guardyn.io';
  // static const int authPort = 443;
  // static const String messagingHost = 'messaging.guardyn.io';
  // static const int messagingPort = 443;

  // App metadata
  static const String appName = 'Guardyn';
  static const String appVersion = '0.1.0';
}
