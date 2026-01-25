/// Permissions utilities for requesting camera and microphone access
library;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling runtime permissions
class PermissionUtils {
  PermissionUtils._();

  /// Request camera and microphone permissions for video calls
  /// Returns true if all permissions are granted
  static Future<bool> requestVideoCallPermissions(BuildContext context) async {
    final permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraStatus = permissions[Permission.camera];
    final micStatus = permissions[Permission.microphone];

    if (cameraStatus?.isGranted == true && micStatus?.isGranted == true) {
      return true;
    }

    // Show dialog if permissions are permanently denied
    if (cameraStatus?.isPermanentlyDenied == true ||
        micStatus?.isPermanentlyDenied == true) {
      if (context.mounted) {
        await _showPermissionSettingsDialog(
          context,
          'Camera and Microphone Required',
          'To make video calls, please enable camera and microphone '
              'permissions in your device settings.',
        );
      }
      return false;
    }

    // Show dialog for denied permissions
    if (cameraStatus?.isDenied == true || micStatus?.isDenied == true) {
      if (context.mounted) {
        final retry = await _showPermissionDeniedDialog(
          context,
          'Permissions Required',
          'Camera and microphone permissions are required for video calls. '
              'Would you like to try again?',
        );
        if (retry) {
          return requestVideoCallPermissions(context);
        }
      }
      return false;
    }

    return false;
  }

  /// Request microphone permission for voice calls
  /// Returns true if permission is granted
  static Future<bool> requestVoiceCallPermissions(BuildContext context) async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    }

    // Show dialog if permission is permanently denied
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionSettingsDialog(
          context,
          'Microphone Required',
          'To make voice calls, please enable microphone permission '
              'in your device settings.',
        );
      }
      return false;
    }

    // Show dialog for denied permission
    if (status.isDenied) {
      if (context.mounted) {
        final retry = await _showPermissionDeniedDialog(
          context,
          'Permission Required',
          'Microphone permission is required for voice calls. '
              'Would you like to try again?',
        );
        if (retry) {
          return requestVoiceCallPermissions(context);
        }
      }
      return false;
    }

    return false;
  }

  /// Request permissions based on call type
  static Future<bool> requestCallPermissions(
    BuildContext context, {
    required bool isVideoCall,
  }) async {
    if (isVideoCall) {
      return requestVideoCallPermissions(context);
    } else {
      return requestVoiceCallPermissions(context);
    }
  }

  /// Show dialog prompting user to open settings
  static Future<void> _showPermissionSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show dialog for denied permissions with retry option
  static Future<bool> _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
