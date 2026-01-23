import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardyn_client/features/auth/domain/entities/user.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardyn_client/features/media/presentation/widgets/avatar_widget.dart';
import 'package:guardyn_client/features/media/presentation/widgets/media_picker_sheet.dart';

/// Page for editing user profile (avatar, display name, bio)
class ProfileEditPage extends StatefulWidget {
  /// Current user to edit
  final User user;

  const ProfileEditPage({super.key, required this.user});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  String? _newAvatarPath;
  bool _removeAvatar = false;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName ?? '',
    );
    _bioController = TextEditingController(text: widget.user.bio ?? '');

    _displayNameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final hasDisplayNameChange =
        _displayNameController.text != (widget.user.displayName ?? '');
    final hasBioChange = _bioController.text != (widget.user.bio ?? '');
    final hasAvatarChange = _newAvatarPath != null || _removeAvatar;

    setState(() {
      _hasChanges = hasDisplayNameChange || hasBioChange || hasAvatarChange;
    });
  }

  Future<void> _pickAvatar() async {
    await MediaPickerSheet.show(
      context,
      onMediaSelected: (result) {
        // Only accept images
        if (result.type.name == 'image') {
          setState(() {
            _newAvatarPath = result.filePath;
            _removeAvatar = false;
            _hasChanges = true;
          });
        }
      },
    );
  }

  void _removeAvatarPressed() {
    setState(() {
      _newAvatarPath = null;
      _removeAvatar = true;
      _hasChanges = true;
    });
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    final authBloc = context.read<AuthBloc>();

    // Send a single event with all changes including the avatar path
    // The bloc will handle upload and profile update sequentially
    authBloc.add(AuthUpdateProfileRequested(
      displayName: _displayNameController.text.trim().isEmpty
          ? null
          : _displayNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      removeAvatar: _removeAvatar,
      newAvatarPath: _newAvatarPath,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdated) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is AuthError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthProfileUpdating) {
          setState(() => _isSaving = true);
        }
      },
      builder: (context, state) {
        final currentUser =
            state is AuthAuthenticated ? state.user : widget.user;
        final uploadProgress = state is AuthProfileUpdating
            ? state.uploadProgress
            : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            actions: [
              TextButton(
                onPressed: _hasChanges && !_isSaving ? _saveProfile : null,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar section
                  _buildAvatarSection(currentUser, uploadProgress),
                  const SizedBox(height: 32),

                  // Display name field
                  _buildDisplayNameField(),
                  const SizedBox(height: 16),

                  // Bio field
                  _buildBioField(),
                  const SizedBox(height: 24),

                  // Username (read-only)
                  _buildUsernameCard(currentUser),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(User user, double? uploadProgress) {
    Widget avatarWidget;

    if (_newAvatarPath != null) {
      // Show local file preview
      avatarWidget = CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(_newAvatarPath!)),
      );
    } else if (_removeAvatar) {
      // Show default avatar (no image)
      avatarWidget = AvatarWidget(
        name: user.effectiveDisplayName,
        size: AvatarSize.xxlarge,
      );
    } else {
      // Show current avatar
      avatarWidget = AvatarWidget(
        imageUrl: user.avatarMediaId != null
            ? _getAvatarUrl(user.avatarMediaId!)
            : null,
        name: user.effectiveDisplayName,
        size: AvatarSize.xxlarge,
      );
    }

    return Column(
      children: [
        Stack(
          children: [
            avatarWidget,
            if (uploadProgress != null && uploadProgress < 1.0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: uploadProgress,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickAvatar,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Change Photo'),
            ),
            if ((user.avatarMediaId != null || _newAvatarPath != null) &&
                !_removeAvatar) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _removeAvatarPressed,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      controller: _displayNameController,
      decoration: const InputDecoration(
        labelText: 'Display Name',
        hintText: 'Enter your display name',
        helperText: 'This is how others will see you',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
      maxLength: 50,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value != null && value.length > 50) {
          return 'Display name cannot exceed 50 characters';
        }
        if (value != null && value.contains(RegExp(r'[\n\r\t]'))) {
          return 'Display name contains invalid characters';
        }
        return null;
      },
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      decoration: const InputDecoration(
        labelText: 'Bio',
        hintText: 'Tell something about yourself...',
        helperText: 'Optional short description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.info_outline),
        alignLabelWithHint: true,
      ),
      maxLength: 500,
      maxLines: 4,
      minLines: 2,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value != null && value.length > 500) {
          return 'Bio cannot exceed 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameCard(User user) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.alternate_email),
        title: Text(user.username),
        subtitle: const Text('Username (cannot be changed)'),
      ),
    );
  }

  String? _getAvatarUrl(String mediaId) {
    // TODO: Implement proper URL generation via MediaService
    // For now, return null to fall back to initials
    return null;
  }
}
