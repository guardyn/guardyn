import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/message.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_state.dart';

/// Media Gallery Page showing shared media, links, and documents
/// Filters messages from the current conversation by type
class MediaGalleryPage extends StatelessWidget {
  final String conversationId;
  final String conversationUserName;

  const MediaGalleryPage({
    super.key,
    required this.conversationId,
    required this.conversationUserName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Media with $conversationUserName'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo), text: 'Media'),
              Tab(icon: Icon(Icons.link), text: 'Links'),
              Tab(icon: Icon(Icons.insert_drive_file), text: 'Docs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MediaTab(conversationId: conversationId),
            LinksTab(conversationId: conversationId),
            DocsTab(conversationId: conversationId),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Helper Functions
// ============================================================================

/// Get messages from any MessageState
List<Message> getMessagesFromState(MessageState state) {
  if (state is MessageLoaded) {
    return state.messages;
  } else if (state is MessageSending) {
    return state.currentMessages;
  } else if (state is MessageError) {
    return state.currentMessages;
  }
  return [];
}

/// Build empty state widget
Widget buildEmptyState(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle,
) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    ),
  );
}

// ============================================================================
// Media Tab
// ============================================================================

/// Tab for displaying images and videos
class MediaTab extends StatelessWidget {
  final String conversationId;

  const MediaTab({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        final messages = getMessagesFromState(state);

        final mediaMessages = messages
            .where((m) =>
                m.messageType == MessageType.image ||
                m.messageType == MessageType.video)
            .toList();

        // Sort by newest first
        mediaMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (mediaMessages.isEmpty) {
          return buildEmptyState(
            context,
            Icons.photo_library_outlined,
            'No shared media',
            'Photos and videos you share will appear here',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: mediaMessages.length,
          itemBuilder: (context, index) {
            final message = mediaMessages[index];
            return MediaThumbnail(
              message: message,
              onTap: () => _openMediaViewer(context, message, mediaMessages),
            );
          },
        );
      },
    );
  }

  void _openMediaViewer(
      BuildContext context, Message message, List<Message> allMedia) {
    final index = allMedia.indexOf(message);
    showDialog(
      context: context,
      builder: (ctx) => MediaViewerDialog(
        messages: allMedia,
        initialIndex: index,
      ),
    );
  }
}

// ============================================================================
// Links Tab
// ============================================================================

/// Tab for displaying shared links
class LinksTab extends StatelessWidget {
  final String conversationId;

  const LinksTab({super.key, required this.conversationId});

  static final _urlRegex = RegExp(
    r'https?://[^\s<>\[\]{}|\\^`"]+',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        final messages = getMessagesFromState(state);

        // Find messages with URLs in text content
        final linkMessages = messages.where((m) {
          if (m.messageType != MessageType.text) return false;
          return _urlRegex.hasMatch(m.textContent);
        }).toList();

        // Sort by newest first
        linkMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (linkMessages.isEmpty) {
          return buildEmptyState(
            context,
            Icons.link_off,
            'No shared links',
            'Links you share will appear here',
          );
        }

        return ListView.builder(
          itemCount: linkMessages.length,
          itemBuilder: (context, index) {
            final message = linkMessages[index];
            final urls = _extractUrls(message.textContent);

            return Column(
              children:
                  urls.map((url) => LinkTile(url: url, message: message)).toList(),
            );
          },
        );
      },
    );
  }

  List<String> _extractUrls(String text) {
    return _urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }
}

// ============================================================================
// Docs Tab
// ============================================================================

/// Tab for displaying shared documents
class DocsTab extends StatelessWidget {
  final String conversationId;

  const DocsTab({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        final messages = getMessagesFromState(state);

        final docMessages = messages
            .where((m) =>
                m.messageType == MessageType.file ||
                m.messageType == MessageType.audio)
            .toList();

        // Sort by newest first
        docMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (docMessages.isEmpty) {
          return buildEmptyState(
            context,
            Icons.folder_open,
            'No shared documents',
            'Documents you share will appear here',
          );
        }

        return ListView.builder(
          itemCount: docMessages.length,
          itemBuilder: (context, index) {
            final message = docMessages[index];
            return DocumentTile(message: message);
          },
        );
      },
    );
  }
}

// ============================================================================
// Media Thumbnail Widget
// ============================================================================

/// Media thumbnail widget for grid display
class MediaThumbnail extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const MediaThumbnail({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder or actual image
            _buildMediaPreview(context),
            // Video indicator
            if (message.messageType == MessageType.video)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context) {
    // Try to get media URL from metadata
    final mediaUrl =
        message.metadata['url'] ?? message.metadata['thumbnail_url'];

    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      return Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        message.messageType == MessageType.video ? Icons.videocam : Icons.image,
        size: 32,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

// ============================================================================
// Link Tile Widget
// ============================================================================

/// Link tile widget for list display
class LinkTile extends StatelessWidget {
  final String url;
  final Message message;

  const LinkTile({
    super.key,
    required this.url,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Extract domain for display
    final uri = Uri.tryParse(url);
    final domain = uri?.host ?? url;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.link,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        domain,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            url,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat.yMMMd().format(message.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
      isThreeLine: true,
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open: $url')),
            );
          }
        }
      },
    );
  }
}

// ============================================================================
// Document Tile Widget
// ============================================================================

/// Document tile widget for list display
class DocumentTile extends StatefulWidget {
  final Message message;

  const DocumentTile({super.key, required this.message});

  @override
  State<DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<DocumentTile> {
  bool _isDownloading = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _checkLocalFile();
  }

  Future<void> _checkLocalFile() async {
    final fileName = widget.message.metadata['file_name'] ??
        widget.message.textContent.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/downloads/$fileName');
    if (await file.exists()) {
      setState(() => _localPath = file.path);
    }
  }

  Future<void> _downloadFile() async {
    final fileName = widget.message.metadata['file_name'] ??
        widget.message.textContent.split('/').last;
    final fileUrl = widget.message.metadata['file_url'] ??
        widget.message.textContent;

    setState(() => _isDownloading = true);

    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${dir.path}/downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        final file = File('${downloadDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _localPath = file.path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded: $fileName')),
          );
        }
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _openFile() async {
    if (_localPath != null) {
      final result = await OpenFilex.open(_localPath!);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    } else {
      // Download first, then open
      await _downloadFile();
      if (_localPath != null) {
        await OpenFilex.open(_localPath!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.message.metadata['file_name'] ??
        widget.message.textContent.split('/').last;
    final fileSize = widget.message.metadata['file_size'];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          _getFileIcon(),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatFileInfo(fileSize, widget.message.timestamp),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
      trailing: _isDownloading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: Icon(_localPath != null ? Icons.folder_open : Icons.download),
              onPressed: _isDownloading ? null : _downloadFile,
            ),
      onTap: _isDownloading ? null : _openFile,
    );
  }

  IconData _getFileIcon() {
    if (widget.message.messageType == MessageType.audio) {
      return Icons.audiotrack;
    }

    final fileName = widget.message.metadata['file_name']?.toLowerCase() ?? '';
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icons.description;
    }
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    if (fileName.endsWith('.zip') || fileName.endsWith('.rar')) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }

  String _formatFileInfo(String? fileSize, DateTime timestamp) {
    final date = DateFormat.yMMMd().format(timestamp);
    if (fileSize != null) {
      return '$fileSize • $date';
    }
    return date;
  }
}

// ============================================================================
// Media Viewer Dialog
// ============================================================================

/// Full-screen media viewer dialog
class MediaViewerDialog extends StatefulWidget {
  final List<Message> messages;
  final int initialIndex;

  const MediaViewerDialog({
    super.key,
    required this.messages,
    required this.initialIndex,
  });

  @override
  State<MediaViewerDialog> createState() => _MediaViewerDialogState();
}

class _MediaViewerDialogState extends State<MediaViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Message get _currentMessage => widget.messages[_currentIndex];

  Future<void> _shareMedia() async {
    final message = _currentMessage;
    final mediaUrl = message.metadata['url'];
    if (mediaUrl == null || mediaUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media to share')),
      );
      return;
    }

    try {
      // Download file to temp directory first
      final response = await http.get(Uri.parse(mediaUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = mediaUrl.split('/').last.split('?').first;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: message.textContent,
        );
      } else {
        throw Exception('Failed to download media');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  Future<void> _downloadMedia() async {
    final message = _currentMessage;
    final mediaUrl = message.metadata['url'];
    if (mediaUrl == null || mediaUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media to download')),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final response = await http.get(Uri.parse(mediaUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${directory.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final fileName = mediaUrl.split('/').last.split('?').first;
        final file = File('${downloadDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to ${file.path}')),
          );
        }
      } else {
        throw Exception('Failed to download');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // Media viewer
          PageView.builder(
            controller: _pageController,
            itemCount: widget.messages.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return _buildMediaView(message);
            },
          ),
          // App bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black54,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                '${_currentIndex + 1} of ${widget.messages.length}',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareMedia,
                ),
                if (_isDownloading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: _downloadMedia,
                  ),
              ],
            ),
          ),
          // Date indicator
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat.yMMMMd().add_jm().format(
                        widget.messages[_currentIndex].timestamp,
                      ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaView(Message message) {
    final mediaUrl = message.metadata['url'];

    if (message.messageType == MessageType.video) {
      // Video placeholder - actual video player would go here
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Video playback',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      );
    }

    // Image viewer
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      return InteractiveViewer(
        child: Center(
          child: Image.network(
            mediaUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text(
            'Unable to load media',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
