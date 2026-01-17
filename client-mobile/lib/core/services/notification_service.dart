import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Cross-platform notification service for message alerts
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _notifications;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _initializationFailed = false;

  /// Check if notifications are supported on current platform
  bool get _isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized || _initializationFailed) return;

    // Skip initialization on unsupported platforms
    if (!_isSupported) {
      debugPrint(
        'NotificationService: Notifications not supported on this platform',
      );
      _isInitialized = true;
      return;
    }

    try {
      _notifications = FlutterLocalNotificationsPlugin();

      // Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS/macOS settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Linux settings
      final linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open',
        defaultIcon: AssetsLinuxIcon('assets/images/logo.svg'),
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      final initialized = await _notifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != true) {
        debugPrint('NotificationService: Plugin initialization returned false');
        _initializationFailed = true;
        _notifications = null;
        return;
      }

      // Request permissions on Android 13+
      if (Platform.isAndroid) {
        try {
          await _notifications!
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission();
        } catch (e) {
          debugPrint(
            'NotificationService: Failed to request Android permissions: $e',
          );
          // Continue - notifications might still work
        }
      }

      _isInitialized = true;
      debugPrint('NotificationService: Initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('NotificationService: Initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      _initializationFailed = true;
      _notifications = null;
      // Don't rethrow - app should work without notifications
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific conversation
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show a message notification with sound
  Future<void> showMessageNotification({
    required String senderName,
    required String messagePreview,
    String? conversationId,
  }) async {
    if (!_isInitialized && !_initializationFailed) await initialize();

    // Play notification sound
    await _playNotificationSound();

    // Show system notification (if available)
    if (_notifications != null) {
      await _showSystemNotification(
        title: senderName,
        body: messagePreview,
        payload: conversationId,
      );
    }
  }

  /// Play notification sound
  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Silently fail if audio playback fails
      debugPrint('Failed to play notification sound: $e');
    }
  }

  /// Show system notification
  Future<void> _showSystemNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (_notifications == null) return;

    const androidDetails = AndroidNotificationDetails(
      'messages',
      'Messages',
      channelDescription: 'New message notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: false, // We play our own sound
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false, // We play our own sound
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    try {
      await _notifications!.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
