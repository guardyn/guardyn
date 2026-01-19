/// Incoming Call Dialog Widget
///
/// Full-screen dialog for incoming calls with accept/reject buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/entities.dart';

/// Full-screen incoming call dialog
class IncomingCallDialog extends StatefulWidget {
  final Call call;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const IncomingCallDialog({
    super.key,
    required this.call,
    this.onAccept,
    this.onReject,
  });

  /// Show as a full-screen modal
  static Future<bool?> show(
    BuildContext context, {
    required Call call,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingCallDialog(
        call: call,
        onAccept: () => Navigator.of(context).pop(true),
        onReject: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Vibration pattern for incoming call
    HapticFeedback.heavyImpact();

    // Pulsing animation for the avatar ring
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final call = widget.call;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Call type label
                Text(
                  call.isVideoCall ? 'Incoming Video Call' : 'Incoming Call',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),

                // Avatar with pulsing ring
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.blue.shade700,
                    backgroundImage: call.remoteUserAvatar != null
                        ? NetworkImage(call.remoteUserAvatar!)
                        : null,
                    child: call.remoteUserAvatar == null
                        ? Text(
                            _getInitials(call.remoteUserName ?? 'Unknown'),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Caller name
                Text(
                  call.remoteUserName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Status
                Text(
                  'is calling...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),

                const Spacer(flex: 2),

                // Accept/Reject buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reject button
                    _CallActionButton(
                      icon: Icons.call_end,
                      label: 'Decline',
                      color: Colors.red.shade600,
                      onPressed: widget.onReject,
                    ),
                    // Accept button
                    _CallActionButton(
                      icon: call.isVideoCall ? Icons.videocam : Icons.call,
                      label: 'Accept',
                      color: Colors.green.shade600,
                      onPressed: widget.onAccept,
                    ),
                  ],
                ),

                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

/// Accept/Reject action button
class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
