/// Call Timer Widget
///
/// Displays the duration of an active call in MM:SS format.
library;

import 'package:flutter/material.dart';

/// Widget to display call duration
class CallTimer extends StatelessWidget {
  final Duration duration;
  final TextStyle? style;

  const CallTimer({
    super.key,
    required this.duration,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(duration),
      style: style ??
          TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }

  /// Format duration as HH:MM:SS or MM:SS
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
