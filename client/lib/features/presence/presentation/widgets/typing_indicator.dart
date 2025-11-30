import 'package:flutter/material.dart';

/// Widget that shows an animated "typing..." indicator
class TypingIndicator extends StatefulWidget {
  /// Text to show (e.g., "John is typing..." or just "typing...")
  final String? text;

  /// Color of the dots
  final Color? dotColor;

  /// Size of each dot
  final double dotSize;

  /// Whether to show the indicator
  final bool isVisible;

  const TypingIndicator({
    super.key,
    this.text,
    this.dotColor,
    this.dotSize = 6.0,
    this.isVisible = true,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Create staggered animations for each dot
    _animations = List.generate(3, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final dotColor = widget.dotColor ?? Colors.grey[400];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.text != null) ...[
          Text(
            widget.text!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
        ],
        // Animated dots
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.dotSize / 4),
                child: Transform.translate(
                  offset: Offset(0, -_animations[index].value * 4),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor?.withOpacity(
                        0.5 + _animations[index].value * 0.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

/// Simple inline typing indicator (just dots)
class InlineTypingIndicator extends StatelessWidget {
  final bool isTyping;
  final String? username;

  const InlineTypingIndicator({
    super.key,
    required this.isTyping,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTyping) {
      return const SizedBox.shrink();
    }

    final text = username != null ? '$username is typing' : 'typing';

    return TypingIndicator(text: text);
  }
}
