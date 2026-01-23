import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/message.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_state.dart';

/// Search Messages Page for searching within a conversation
/// Performs client-side search on decrypted messages (E2EE)
class SearchMessagesPage extends StatefulWidget {
  final String conversationId;
  final String conversationUserName;

  const SearchMessagesPage({
    super.key,
    required this.conversationId,
    required this.conversationUserName,
  });

  @override
  State<SearchMessagesPage> createState() => _SearchMessagesPageState();
}

class _SearchMessagesPageState extends State<SearchMessagesPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Message> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query == _lastQuery) return;
    _lastQuery = query;

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // E2EE: Search happens client-side on decrypted messages
    // Get messages from BLoC state
    final state = context.read<MessageBloc>().state;
    List<Message> allMessages = [];

    if (state is MessageLoaded) {
      allMessages = state.messages;
    } else if (state is MessageSending) {
      allMessages = state.currentMessages;
    } else if (state is MessageError) {
      allMessages = state.currentMessages;
    }

    // Filter messages containing the query (case-insensitive)
    final queryLower = query.toLowerCase();
    final filtered = allMessages.where((message) {
      // Only search text content
      if (message.messageType != MessageType.text) return false;
      return message.textContent.toLowerCase().contains(queryLower);
    }).toList();

    // Sort by timestamp (newest first for search results)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _results = filtered;
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _search('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search in ${widget.conversationUserName}...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: _search,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return _buildNoResults();
    }

    return _buildResultsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Search messages',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type to search in this conversation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: [
        // Results count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            '${_results.length} ${_results.length == 1 ? 'message' : 'messages'} found',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final message = _results[index];
              return _buildResultItem(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(Message message) {
    final query = _searchController.text.toLowerCase();
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: message.isSentByMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        child: Icon(
          message.isSentByMe ? Icons.arrow_upward : Icons.arrow_downward,
          color: message.isSentByMe
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSecondary,
          size: 20,
        ),
      ),
      title: _buildHighlightedText(message.textContent, query),
      subtitle: Text(
        _formatTimestamp(message.timestamp),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Return the message ID to navigate to in chat
        Navigator.pop(context, message.messageId);
      },
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final textLower = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = textLower.indexOf(query, start);
      if (index == -1) {
        // Add remaining text
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: spans,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat.jm().format(timestamp);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${DateFormat.jm().format(timestamp)}';
    } else if (difference.inDays < 7) {
      // This week
      return DateFormat('EEEE').format(timestamp);
    } else {
      // Older
      return DateFormat.yMMMd().format(timestamp);
    }
  }
}
