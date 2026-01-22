import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../media/presentation/bloc/media_bloc.dart';
import '../../../media/presentation/bloc/media_event.dart';
import '../../../media/presentation/bloc/media_state.dart';
import '../../../media/presentation/widgets/media_picker_sheet.dart';
import '../../domain/entities/group.dart';

/// Widget displaying group icon with optional editing capability
///
/// Features:
/// - Shows group icon if available, otherwise shows initial letter
/// - Camera overlay button for admins to change icon
/// - Handles media upload for new icon
/// - Loading and error states
class GroupIconAvatar extends StatefulWidget {
  /// The group to display icon for
  final Group group;

  /// Size of the avatar
  final double size;

  /// Whether the current user can edit the icon
  final bool canEdit;

  /// Callback when icon is updated
  final void Function(String mediaId)? onIconUpdated;

  const GroupIconAvatar({
    super.key,
    required this.group,
    this.size = 100,
    this.canEdit = false,
    this.onIconUpdated,
  });

  @override
  State<GroupIconAvatar> createState() => _GroupIconAvatarState();
}

class _GroupIconAvatarState extends State<GroupIconAvatar> {
  String? _iconUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    if (widget.group.hasIcon) {
      _loadIconUrl();
    }
  }

  @override
  void didUpdateWidget(GroupIconAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.iconMediaId != widget.group.iconMediaId) {
      if (widget.group.hasIcon) {
        _loadIconUrl();
      } else {
        setState(() {
          _iconUrl = null;
        });
      }
    }
  }

  Future<void> _loadIconUrl() async {
    if (!widget.group.hasIcon) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bloc = context.read<MediaBloc>();
      bloc.add(MediaThumbnailRequested(
        mediaId: widget.group.iconMediaId!,
        width: (widget.size * 2).toInt(),
        height: (widget.size * 2).toInt(),
      ));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMediaPicker() {
    if (!widget.canEdit) return;

    MediaPickerSheet.show(
      context,
      onMediaSelected: _handleMediaSelected,
    );
  }

  void _handleMediaSelected(MediaPickerResult result) {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    final bloc = context.read<MediaBloc>();
    bloc.add(MediaUploadRequested(
      filePath: result.filePath,
      mimeType: result.mimeType,
      conversationId: widget.group.groupId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaBloc, MediaState>(
      listener: (context, state) {
        if (state is MediaUploading) {
          setState(() {
            _uploadProgress = state.progress;
          });
        } else if (state is MediaUploadSuccess) {
          setState(() {
            _isUploading = false;
          });
          widget.onIconUpdated?.call(state.media.id);
        } else if (state is MediaThumbnailLoaded) {
          // Check if this is for our group icon
          if (state.mediaId == widget.group.iconMediaId) {
            setState(() {
              _iconUrl = state.thumbnailUrl;
              _isLoading = false;
            });
          }
        } else if (state is MediaError) {
          setState(() {
            _isLoading = false;
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: SemanticColors.error,
            ),
          );
        }
      },
      child: Stack(
        children: [
          // Main avatar
          GestureDetector(
            onTap: widget.canEdit ? _showMediaPicker : null,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _iconUrl == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GuardynColors.guardyn400,
                          GuardynColors.guardyn600,
                        ],
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: GuardynColors.guardyn500.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildContent(),
            ),
          ),

          // Edit button overlay
          if (widget.canEdit)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showMediaPicker,
                child: Container(
                  width: widget.size * 0.32,
                  height: widget.size * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GuardynColors.guardyn500,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: widget.size * 0.16,
                  ),
                ),
              ),
            ),

          // Upload progress overlay
          if (_isUploading)
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: Center(
                child: SizedBox(
                  width: widget.size * 0.4,
                  height: widget.size * 0.4,
                  child: CircularProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    if (_iconUrl != null) {
      return CachedNetworkImage(
        imageUrl: _iconUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialLetter(),
      );
    }

    return _buildInitialLetter();
  }

  Widget _buildInitialLetter() {
    return Center(
      child: Text(
        widget.group.name.isNotEmpty ? widget.group.name[0].toUpperCase() : 'G',
        style: AppTypography.headlineLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: widget.size * 0.4,
        ),
      ),
    );
  }
}
