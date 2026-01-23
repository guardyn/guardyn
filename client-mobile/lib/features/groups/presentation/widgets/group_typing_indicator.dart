import 'package:flutter/material.dart';

/// Displays "X is typing..." indicator for group chats
class GroupTypingIndicator extends StatelessWidget {
  final List<String> typingUsernames;

  const GroupTypingIndicator({
    super.key,
    required this.typingUsernames,
  });

  @override
  Widget build(BuildContext context) {
    if (typingUsernames.isEmpty) {
      return const SizedBox.shrink();
    }

    final text = _buildTypingText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const _TypingDotsAnimation(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _buildTypingText() {
    if (typingUsernames.length == 1) {
      return '${typingUsernames[0]} is typing...';
    } else if (typingUsernames.length == 2) {
      return '${typingUsernames[0]} and ${typingUsernames[1]} are typing...';
    } else {
      return '${typingUsernames[0]} and ${typingUsernames.length - 1} others are typing...';
    }
  }
}

class _TypingDotsAnimation extends StatefulWidget {
  const _TypingDotsAnimation();

  @override
  State<_TypingDotsAnimation> createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<_TypingDotsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (value < 0.5) ? value * 2 : (1.0 - value) * 2;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
