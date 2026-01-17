import 'dart:async';

import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final Function(bool)? onTypingChanged;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.enabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    // Send typing stopped when disposing
    if (_isTyping) {
      widget.onTypingChanged?.call(false);
    }
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    
    setState(() {
      _hasText = hasText;
    });

    // Handle typing indicator
    if (hasText && !_isTyping) {
      _isTyping = true;
      widget.onTypingChanged?.call(true);
    }

    // Reset typing timer - will stop typing indicator after 3 seconds of no input
    _typingTimer?.cancel();
    if (hasText) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (_isTyping && _controller.text.trim().isNotEmpty) {
          // Still has text but stopped typing - keep typing indicator for continuous typing
          // Re-send typing true to reset backend timeout
          widget.onTypingChanged?.call(true);
        }
      });
    } else if (_isTyping) {
      // Text cleared, stop typing
      _isTyping = false;
      widget.onTypingChanged?.call(false);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      setState(() {
        _hasText = false;
      });
      // Stop typing indicator on send
      _typingTimer?.cancel();
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: widget.enabled && _hasText ? (_) => _handleSend() : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Material(
              color: _hasText && widget.enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _hasText && widget.enabled ? _handleSend : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.send,
                    color: _hasText && widget.enabled
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
