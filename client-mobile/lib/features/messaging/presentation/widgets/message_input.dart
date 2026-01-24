import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../media/presentation/widgets/media_picker_sheet.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final Function(bool)? onTypingChanged;
  final Function(MediaPickerResult)? onMediaSelected;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.onMediaSelected,
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

  void _handleAttach() {
    if (!widget.enabled || widget.onMediaSelected == null) return;

    MediaPickerSheet.show(
      context,
      onMediaSelected: (result) {
        widget.onMediaSelected?.call(result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? GrayColors.gray900.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: isDark
                ? GrayColors.gray800.withOpacity(0.5)
                : GrayColors.gray200.withOpacity(0.5),
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                if (widget.onMediaSelected != null)
                  IconButton(
                    onPressed: widget.enabled ? _handleAttach : null,
                    icon: Icon(
                      Icons.attach_file_rounded,
                      color: widget.enabled
                          ? (isDark ? GrayColors.gray400 : GrayColors.gray600)
                          : GrayColors.gray500,
                    ),
                    tooltip: 'Attach media',
                  ),
                // Text input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? GrayColors.gray800.withOpacity(0.6)
                          : GrayColors.gray100,
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                      border: Border.all(
                        color: isDark
                            ? GrayColors.gray700.withOpacity(0.5)
                            : GrayColors.gray200,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      style: TextStyle(
                        color: isDark ? Colors.white : GrayColors.gray900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: GrayColors.gray500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space4,
                          vertical: AppSpacing.space3,
                        ),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      enableIMEPersonalizedLearning: true,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: widget.enabled && _hasText ? (_) => _handleSend() : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                // Send button with neumorphic style
                Container(
                  decoration: BoxDecoration(
                    color: _hasText && widget.enabled
                        ? GuardynColors.guardyn500
                        : (isDark ? GrayColors.gray800 : GrayColors.gray200),
                    shape: BoxShape.circle,
                    boxShadow: _hasText && widget.enabled
                        ? AppShadows.sm
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _hasText && widget.enabled ? _handleSend : null,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.send_rounded,
                          color: _hasText && widget.enabled
                              ? Colors.white
                              : GrayColors.gray500,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
