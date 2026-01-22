import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/grpc_clients.dart';
import '../../../../generated/messaging.pb.dart' as proto;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../data/datasources/message_remote_datasource.dart';
import '../bloc/message_bloc.dart';
import 'chat_page.dart';
import 'user_search_page.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  final _secureStorage = const FlutterSecureStorage();
  List<proto.Conversation> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null || accessToken.isEmpty) {
        setState(() {
          _errorMessage = 'Not authenticated';
          _isLoading = false;
        });
        return;
      }

      final grpcClients = getIt<GrpcClients>();
      final datasource = MessageRemoteDatasource(grpcClients);

      final conversations = await datasource.getConversations(
        accessToken: accessToken,
        limit: 50,
      );

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load conversations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? GrayColors.gray950 : GrayColors.gray50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : GrayColors.gray900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? GrayColors.gray400 : GrayColors.gray600,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MessageBloc>(),
                    child: const UserSearchPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? GrayColors.gray400 : GrayColors.gray600,
            ),
            onPressed: _loadConversations,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? GrayColors.gray400 : GrayColors.gray600,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const ConversationShimmerList()
          : _errorMessage != null
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: SemanticColors.error,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: SemanticColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    ElevatedButton(
                      onPressed: _loadConversations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GuardynColors.guardyn500,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _conversations.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: GrayColors.gray400,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: GrayColors.gray600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'Start a new conversation by searching for users',
                      style: TextStyle(color: GrayColors.gray500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<MessageBloc>(),
                              child: const UserSearchPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Find Users'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GuardynColors.guardyn500,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _conversations.length,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                final lastMessage = conversation.lastMessage;
                // Server sends UTC timestamps, convert to local time for display
                final timestamp = lastMessage.hasServerTimestamp()
                    ? DateTime.fromMillisecondsSinceEpoch(
                        lastMessage.serverTimestamp.seconds.toInt() * 1000 +
                            (lastMessage.serverTimestamp.nanos ~/ 1000000),
                        isUtc: true,
                      ).toLocal()
                    : DateTime.now();

                return _ConversationItemCard(
                  conversation: conversation,
                  timestamp: timestamp,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<MessageBloc>(),
                          child: ChatPage(
                            conversationUserId: conversation.userId,
                            conversationUserName: conversation.username,
                            deviceId: '', // Will be resolved by chat page
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<MessageBloc>(),
                child: const UserSearchPage(),
              ),
            ),
          );
        },
        backgroundColor: GuardynColors.guardyn500,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

/// Glassmorphism conversation item card
class _ConversationItemCard extends StatelessWidget {
  final proto.Conversation conversation;
  final DateTime timestamp;
  final bool isDark;
  final VoidCallback onTap;

  const _ConversationItemCard({
    required this.conversation,
    required this.timestamp,
    required this.isDark,
    required this.onTap,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? GrayColors.gray800.withOpacity(0.6)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark
                ? GrayColors.gray700.withOpacity(0.3)
                : GrayColors.gray200.withOpacity(0.5),
          ),
          boxShadow: AppShadows.sm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          GuardynColors.guardyn400,
                          GuardynColors.guardyn600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        conversation.username.isNotEmpty
                            ? conversation.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.username.isNotEmpty
                              ? conversation.username
                              : conversation.userId,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : GrayColors.gray900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          String.fromCharCodes(lastMessage.encryptedContent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: GrayColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  // Timestamp and badge
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: GrayColors.gray500,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(height: AppSpacing.space1),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GuardynColors.guardyn500,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
