import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../media/presentation/widgets/media_picker_sheet.dart';

/// Widget for inputting group messages with glassmorphism styling
class GroupMessageInput extends StatefulWidget {
  final void Function(String text) onSend;
  final void Function(MediaPickerResult result)? onMediaSelected;
  final void Function(bool isTyping)? onTypingChanged;
  final bool isLoading;

  const GroupMessageInput({
    super.key,
    required this.onSend,
    this.onMediaSelected,
    this.onTypingChanged,
    this.isLoading = false,
  });

  @override
  State<GroupMessageInput> createState() => _GroupMessageInputState();
}

class _GroupMessageInputState extends State<GroupMessageInput> {
  final _controller = TextEditingController();
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
    _controller.removeListener(_onTextChanged);
    _typingTimer?.cancel();
    // Send stopped typing on dispose
    if (_isTyping) {
      widget.onTypingChanged?.call(false);
    }
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    
    // Handle typing indicator
    if (hasText && !_isTyping) {
      _isTyping = true;
      widget.onTypingChanged?.call(true);
    }
    
    // Reset the typing timer
    _typingTimer?.cancel();
    if (hasText) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (_isTyping) {
          _isTyping = false;
          widget.onTypingChanged?.call(false);
        }
      });
    } else if (_isTyping) {
      _isTyping = false;
      widget.onTypingChanged?.call(false);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    // Stop typing indicator when sending
    _typingTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      widget.onTypingChanged?.call(false);
    }

    widget.onSend(text);
    _controller.clear();
  }

  void _handleAttach() {
    if (widget.isLoading || widget.onMediaSelected == null) return;

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

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
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
                    ? Colors.white.withOpacity(0.1)
                    : GrayColors.gray200,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? GrayColors.gray800
                        : GrayColors.gray100,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.attach_file, size: 20),
                    onPressed: widget.onMediaSelected != null && !widget.isLoading
                        ? _handleAttach
                        : null,
                    color: widget.onMediaSelected != null
                        ? (isDark ? GrayColors.gray400 : GrayColors.gray600)
                        : GrayColors.gray500,
                    padding: EdgeInsets.zero,
                    tooltip: 'Attach media',
                  ),
                ),

                const SizedBox(width: AppSpacing.space2),

                // Text input with glassmorphism
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? GrayColors.gray800.withOpacity(0.6)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : GrayColors.gray300.withOpacity(0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.white : GrayColors.gray900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: GrayColors.gray400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space4,
                          vertical: AppSpacing.space3,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      enableIMEPersonalizedLearning: true,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.space2),

                // Send button with neumorphic style
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.space3),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: GuardynColors.guardyn500,
                            ),
                          ),
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _hasText
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      GuardynColors.guardyn400,
                                      GuardynColors.guardyn600,
                                    ],
                                  )
                                : null,
                            color: _hasText
                                ? null
                                : (isDark
                                    ? GrayColors.gray800
                                    : GrayColors.gray100),
                            boxShadow: _hasText
                                ? [
                                    BoxShadow(
                                      color: GuardynColors.guardyn500
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, size: 20),
                            onPressed: _hasText ? _handleSend : null,
                            color:
                                _hasText ? Colors.white : GrayColors.gray400,
                            padding: EdgeInsets.zero,
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
