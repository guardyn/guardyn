import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../generated/auth.pb.dart' show UserSearchResult;
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../media/domain/usecases/download_media.dart';
import '../bloc/message_bloc.dart';
import 'chat_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchResult> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    // Client-side validation for minimum query length
    if (trimmedQuery.length < 2) {
      setState(() {
        _searchResults = [];
        _errorMessage = 'Please enter at least 2 characters to search';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the auth state
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please log in to search for users';
        });
        return;
      }

      // Get access token from secure storage
      final secureStorage = getIt<SecureStorage>();
      final accessToken = await secureStorage.getAccessToken();
      
      if (accessToken == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please log in again';
        });
        return;
      }

      // Call the datasource
      final datasource = getIt<AuthRemoteDatasource>();
      final List<UserSearchResult> results = await datasource.searchUsers(
        accessToken: accessToken,
        query: trimmedQuery,
        limit: 50,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getUserFriendlyErrorMessage(e);
      });
    }
  }

  /// Converts technical error messages to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid') && errorString.contains('token')) {
      return 'Session expired. Please log in again';
    }
    if (errorString.contains('unauthorized') || errorString.contains('unauthenticated')) {
      return 'Please log in to search for users';
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection';
    }
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again';
    }
    if (errorString.contains('not found')) {
      return 'Service unavailable. Please try again later';
    }
    
    // Generic fallback - don't expose technical details
    return 'Something went wrong. Please try again';
  }

  void _openChat(UserSearchResult user) {
    // Use displayName if available, otherwise username
    final displayName = user.hasDisplayName() && user.displayName.isNotEmpty
        ? user.displayName
        : user.username;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<MessageBloc>(),
          child: ChatPage(
            conversationUserId: user.userId,
            conversationUserName: displayName,
            deviceId: '', // Will be determined by backend
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.text,
              enableIMEPersonalizedLearning: true,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              onSubmitted: _performSearch,
            ),
          ),

          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for users to start a conversation',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        // Use displayName if available, otherwise username
        final displayName = user.hasDisplayName() && user.displayName.isNotEmpty
            ? user.displayName
            : user.username;
        return ListTile(
          leading: _UserAvatarWidget(
            avatarMediaId: user.hasAvatarMediaId() && user.avatarMediaId.isNotEmpty
                ? user.avatarMediaId
                : null,
            displayName: displayName,
          ),
          title: Text(
            displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '@${user.username}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: const Icon(Icons.chat_bubble_outline),
          onTap: () => _openChat(user),
        );
      },
    );
  }
}

/// Widget to display user avatar with network image loading
class _UserAvatarWidget extends StatefulWidget {
  final String? avatarMediaId;
  final String displayName;

  const _UserAvatarWidget({
    required this.avatarMediaId,
    required this.displayName,
  });

  @override
  State<_UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<_UserAvatarWidget> {
  String? _avatarUrl;
  bool _loadingUrl = false;

  @override
  void initState() {
    super.initState();
    _loadAvatarUrl();
  }

  @override
  void didUpdateWidget(_UserAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarMediaId != widget.avatarMediaId) {
      _loadAvatarUrl();
    }
  }

  Future<void> _loadAvatarUrl() async {
    if (widget.avatarMediaId == null || widget.avatarMediaId!.isEmpty) {
      if (mounted) {
        setState(() {
          _avatarUrl = null;
        });
      }
      return;
    }

    setState(() {
      _loadingUrl = true;
    });

    try {
      final downloadMedia = getIt<DownloadMedia>();
      final result = await downloadMedia.getUrl(mediaId: widget.avatarMediaId!);
      if (mounted) {
        setState(() {
          _avatarUrl = result.presignedUrl;
          _loadingUrl = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _avatarUrl = null;
          _loadingUrl = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUrl) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_avatarUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_avatarUrl!),
        onBackgroundImageError: (_, __) {
          // Fall back to initials if image fails to load
        },
        child: null,
      );
    }

    // Default: show initials
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        widget.displayName.isNotEmpty ? widget.displayName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
