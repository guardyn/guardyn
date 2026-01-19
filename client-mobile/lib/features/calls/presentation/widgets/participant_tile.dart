/// Participant Tile Widget
///
/// Displays a call participant's video or avatar.
library;

import 'package:flutter/material.dart';

/// Widget to display a participant in a call
class ParticipantTile extends StatelessWidget {
  final bool isLocal;
  final bool isVideoEnabled;
  final String displayName;
  final String? avatarUrl;
  final bool isMuted;
  final bool isSpeaking;

  const ParticipantTile({
    super.key,
    required this.isLocal,
    required this.isVideoEnabled,
    required this.displayName,
    this.avatarUrl,
    required this.isMuted,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: isSpeaking
            ? Border.all(color: Colors.green, width: 3)
            : null,
      ),
      child: Stack(
        children: [
          // Video or avatar
          if (isVideoEnabled)
            _buildVideoPlaceholder()
          else
            _buildAvatarFallback(),

          // Name label
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLocal ? 'You' : displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMuted) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.mic_off,
                      color: Colors.red,
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build placeholder for video (actual WebRTC view would go here)
  Widget _buildVideoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            Colors.grey.shade900,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 48,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              'Video',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build avatar fallback for audio-only
  Widget _buildAvatarFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade700,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    _getInitials(displayName),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            isLocal ? 'You' : displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}
