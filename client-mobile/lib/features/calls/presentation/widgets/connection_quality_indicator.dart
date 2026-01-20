/// Connection Quality Indicator Widget
///
/// Displays the current call connection quality with animated bars.
library;

import 'package:flutter/material.dart';

/// Connection quality levels
enum ConnectionQuality {
  /// No connection or very poor
  poor,

  /// Unstable connection
  fair,

  /// Good connection
  good,

  /// Excellent connection
  excellent,
}

/// Converts quality score (0-100) to ConnectionQuality
ConnectionQuality qualityFromScore(int? score) {
  if (score == null || score < 25) return ConnectionQuality.poor;
  if (score < 50) return ConnectionQuality.fair;
  if (score < 75) return ConnectionQuality.good;
  return ConnectionQuality.excellent;
}

/// Widget that displays connection quality as animated bars
class ConnectionQualityIndicator extends StatelessWidget {
  /// Creates a connection quality indicator
  const ConnectionQualityIndicator({
    super.key,
    this.qualityScore,
    this.showLabel = false,
    this.size = ConnectionQualitySize.medium,
  });

  /// Quality score from 0-100
  final int? qualityScore;

  /// Whether to show text label
  final bool showLabel;

  /// Size of the indicator
  final ConnectionQualitySize size;

  @override
  Widget build(BuildContext context) {
    final quality = qualityFromScore(qualityScore);
    final barColor = _getColorForQuality(quality);
    final dimensions = _getDimensions();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Signal bars
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (index) {
            final isActive = _isBarActive(quality, index);
            return Padding(
              padding: EdgeInsets.only(
                right: index < 3 ? dimensions.barSpacing : 0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: dimensions.barWidth,
                height: dimensions.barBaseHeight + (index * dimensions.barHeightIncrement),
                decoration: BoxDecoration(
                  color: isActive ? barColor : barColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(dimensions.barRadius),
                ),
              ),
            );
          }),
        ),
        // Label
        if (showLabel) ...[
          SizedBox(width: dimensions.labelSpacing),
          Text(
            _getLabelForQuality(quality),
            style: TextStyle(
              fontSize: dimensions.labelFontSize,
              color: barColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Get color based on quality
  Color _getColorForQuality(ConnectionQuality quality) {
    return switch (quality) {
      ConnectionQuality.excellent => const Color(0xFF22c55e), // Guardyn green
      ConnectionQuality.good => const Color(0xFF84cc16), // Lime
      ConnectionQuality.fair => const Color(0xFFfbbf24), // Amber
      ConnectionQuality.poor => const Color(0xFFef4444), // Red
    };
  }

  /// Check if bar at index should be active
  bool _isBarActive(ConnectionQuality quality, int index) {
    final activeCount = switch (quality) {
      ConnectionQuality.excellent => 4,
      ConnectionQuality.good => 3,
      ConnectionQuality.fair => 2,
      ConnectionQuality.poor => 1,
    };
    return index < activeCount;
  }

  /// Get label text for quality
  String _getLabelForQuality(ConnectionQuality quality) {
    return switch (quality) {
      ConnectionQuality.excellent => 'Excellent',
      ConnectionQuality.good => 'Good',
      ConnectionQuality.fair => 'Fair',
      ConnectionQuality.poor => 'Poor',
    };
  }

  /// Get dimensions based on size
  _IndicatorDimensions _getDimensions() {
    return switch (size) {
      ConnectionQualitySize.small => const _IndicatorDimensions(
            barWidth: 3,
            barBaseHeight: 4,
            barHeightIncrement: 3,
            barSpacing: 2,
            barRadius: 1,
            labelSpacing: 4,
            labelFontSize: 10,
          ),
      ConnectionQualitySize.medium => const _IndicatorDimensions(
            barWidth: 4,
            barBaseHeight: 6,
            barHeightIncrement: 4,
            barSpacing: 2,
            barRadius: 1.5,
            labelSpacing: 6,
            labelFontSize: 12,
          ),
      ConnectionQualitySize.large => const _IndicatorDimensions(
            barWidth: 6,
            barBaseHeight: 8,
            barHeightIncrement: 6,
            barSpacing: 3,
            barRadius: 2,
            labelSpacing: 8,
            labelFontSize: 14,
          ),
    };
  }
}

/// Size variants for the indicator
enum ConnectionQualitySize {
  small,
  medium,
  large,
}

/// Dimensions configuration for the indicator
class _IndicatorDimensions {
  const _IndicatorDimensions({
    required this.barWidth,
    required this.barBaseHeight,
    required this.barHeightIncrement,
    required this.barSpacing,
    required this.barRadius,
    required this.labelSpacing,
    required this.labelFontSize,
  });

  final double barWidth;
  final double barBaseHeight;
  final double barHeightIncrement;
  final double barSpacing;
  final double barRadius;
  final double labelSpacing;
  final double labelFontSize;
}
