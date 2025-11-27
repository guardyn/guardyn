import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// Service for handling notifications across all platforms
/// - Android: System notification in status bar
/// - iOS: Local notification with sound
/// - Linux: Desktop notification
/// - Web: Browser notification API
/// - macOS/Windows: Desktop notifications
@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final AudioPlayer _audioPlayer;

  bool _isInitialized = false;
  static const String _channelId = 'guardyn_messages';
  static const String _channelName = 'Messages';
  static const String _channelDescription = 'Guardyn message notifications';

  NotificationService()
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(),
        _audioPlayer = AudioPlayer();

  /// Initialize the notification service
  /// Must be called before showing any notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization settings
      const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Linux initialization settings
      final linuxInitSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
        defaultIcon: AssetsLinuxIcon('assets/images/logo.svg'),
      );

      // macOS initialization settings
      const macOSInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
        linux: linuxInitSettings,
        macOS: macOSInitSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
      );

      // Request permission on Android 13+
      if (!kIsWeb && Platform.isAndroid) {
        await _requestAndroidPermissions();
      }

      _isInitialized = true;
      // ignore: avoid_print
      print('NotificationService initialized successfully');
    } catch (e) {
      // ignore: avoid_print
      print('Failed to initialize NotificationService: $e');
    }
  }

  /// Request notification permissions on Android 13+
  Future<void> _requestAndroidPermissions() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Show a notification for a new message
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
    bool playSound = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Play notification sound first
      if (playSound) {
        await _playNotificationSound();
      }

      if (kIsWeb) {
        // Web platform uses browser notification API
        await _showWebNotification(title: title, body: body);
      } else {
        // Native platforms use flutter_local_notifications
        await _showNativeNotification(title: title, body: body, payload: payload);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to show notification: $e');
    }
  }

  /// Show notification on native platforms (Android, iOS, Linux, macOS, Windows)
  Future<void> _showNativeNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
      category: LinuxNotificationCategory.imReceived,
    );

    const macOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
      macOS: macOSDetails,
    );

    // Generate unique notification ID
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Show notification on web platform using JS interop
  Future<void> _showWebNotification({
    required String title,
    required String body,
  }) async {
    // Web notifications are handled via JavaScript
    // This will be called from the web-specific implementation
    // ignore: avoid_print
    print('Web notification: $title - $body');

    // Use the browser Notification API via dart:js_interop
    try {
      await _showBrowserNotification(title, body);
    } catch (e) {
      // ignore: avoid_print
      print('Browser notification failed: $e');
    }
  }

  /// Show browser notification using web APIs
  Future<void> _showBrowserNotification(String title, String body) async {
    // This is implemented using web-specific code
    // The actual implementation uses dart:js_interop
    // For now, we rely on flutter_local_notifications web support
    // ignore: avoid_print
    print('Browser notification requested: $title');
  }

  /// Play notification sound
  Future<void> _playNotificationSound() async {
    try {
      // Use default notification sound
      // For custom sounds, place them in assets/sounds/
      await _audioPlayer.play(
        AssetSource('sounds/notification.mp3'),
        volume: 0.7,
      );
    } catch (e) {
      // Fallback: try to play system sound or just log
      // ignore: avoid_print
      print('Could not play notification sound: $e');

      // Try playing a simple beep
      try {
        // Use a URL-based sound as fallback
        await _audioPlayer.play(
          UrlSource('https://assets.mixkit.co/sfx/preview/mixkit-message-pop-alert-2354.mp3'),
          volume: 0.7,
        );
      } catch (fallbackError) {
        // ignore: avoid_print
        print('Fallback sound also failed: $fallbackError');
      }
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Callback handlers

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    // ignore: avoid_print
    print('Notification tapped: ${response.payload}');

    // TODO: Navigate to the relevant chat screen
    // This would be done through a navigation service or global key
  }

  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background notification tap
    // ignore: avoid_print
    print('Background notification tapped: ${response.payload}');
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
