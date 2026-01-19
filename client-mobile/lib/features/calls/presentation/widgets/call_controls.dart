/// Call Controls Widget
///
/// Control buttons for an active call (mute, video, speaker, end call).
library;

import 'package:flutter/material.dart';

/// Call control buttons widget
class CallControls extends StatelessWidget {
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isSpeakerOn;
  final bool isVideoCall;
  final VoidCallback? onMutePressed;
  final VoidCallback? onVideoPressed;
  final VoidCallback? onSpeakerPressed;
  final VoidCallback? onSwitchCameraPressed;
  final VoidCallback? onEndCallPressed;

  const CallControls({
    super.key,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.isSpeakerOn,
    required this.isVideoCall,
    this.onMutePressed,
    this.onVideoPressed,
    this.onSpeakerPressed,
    this.onSwitchCameraPressed,
    this.onEndCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                _ControlButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic,
                  label: isMuted ? 'Unmute' : 'Mute',
                  isActive: isMuted,
                  onPressed: onMutePressed,
                ),
                // Video button (only for video calls)
                if (isVideoCall)
                  _ControlButton(
                    icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    label: isVideoEnabled ? 'Stop Video' : 'Start Video',
                    isActive: !isVideoEnabled,
                    onPressed: onVideoPressed,
                  ),
                // Speaker button
                _ControlButton(
                  icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  label: isSpeakerOn ? 'Speaker On' : 'Speaker Off',
                  isActive: isSpeakerOn,
                  onPressed: onSpeakerPressed,
                ),
                // Switch camera (only for video calls)
                if (isVideoCall)
                  _ControlButton(
                    icon: Icons.flip_camera_ios,
                    label: 'Flip',
                    isActive: false,
                    onPressed: onSwitchCameraPressed,
                  ),
              ],
            ),
            const SizedBox(height: 32),
            // End call button
            _EndCallButton(onPressed: onEndCallPressed),
          ],
        ),
      ),
    );
  }
}

/// Individual control button
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Button
        Material(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.2),
                ),
                // Neumorphic shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    offset: const Offset(-1, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.red.shade300 : Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// End call button (red, prominent)
class _EndCallButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _EndCallButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade600,
      shape: const StadiumBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.call_end,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'End Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
