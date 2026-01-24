import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/media_entity.dart';
import '../bloc/media_bloc.dart';
import '../bloc/media_event.dart';
import '../bloc/media_state.dart';
import 'media_viewer_page.dart';

/// Media gallery page showing all media in a conversation
///
/// Features:
/// - Tab bar: Media (images/videos), Links, Documents
/// - Grid view for images/videos
/// - List view for documents
/// - Infinite scroll pagination
/// - Tap to open in viewer
class MediaGalleryPage extends StatefulWidget {
  /// Conversation ID to show media for
  final String conversationId;

  /// Conversation/group name for title
  final String title;

  /// Initial tab index
  final int initialTab;

  const MediaGalleryPage({
    super.key,
    required this.conversationId,
    this.title = 'Media',
    this.initialTab = 0,
  });

  /// Show media gallery as a route
  static Future<void> show(
    BuildContext context, {
    required String conversationId,
    String title = 'Media',
    int initialTab = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaGalleryPage(
          conversationId: conversationId,
          title: title,
          initialTab: initialTab,
        ),
      ),
    );
  }

  @override
  State<MediaGalleryPage> createState() => _MediaGalleryPageState();
}

class _MediaGalleryPageState extends State<MediaGalleryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    // Load initial media
    _loadMedia();

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMedia() {
    context.read<MediaBloc>().add(MediaListRequested(
          conversationId: widget.conversationId,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = context.read<MediaBloc>().state;
    if (state is MediaListLoaded && state.hasMore) {
      context.read<MediaBloc>().add(MediaLoadMoreRequested(
            conversationId: widget.conversationId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Links'),
            Tab(text: 'Docs'),
          ],
        ),
      ),
      body: BlocBuilder<MediaBloc, MediaState>(
        builder: (context, state) {
          if (state is MediaLoading && state.media.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MediaError && state.media.isEmpty) {
            return _buildErrorState(context, state.message);
          }

          final media = state is MediaListLoaded
              ? state.media
              : state is MediaLoading
                  ? state.media
                  : state is MediaError
                      ? state.media
                      : <MediaEntity>[];

          if (media.isEmpty) {
            return _buildEmptyState(context);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMediaGrid(context, media),
              _buildLinksTab(context, media),
              _buildDocsTab(context, media),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<MediaEntity> allMedia) {
    final media = allMedia
        .where((m) => m.type == MediaType.image || m.type == MediaType.video)
        .toList();

    if (media.isEmpty) {
      return _buildEmptyTabState(
        context,
        Icons.photo_library_outlined,
        'No photos or videos',
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: media.length,
      itemBuilder: (context, index) => _buildMediaGridItem(context, media, index),
    );
  }

  Widget _buildMediaGridItem(
    BuildContext context,
    List<MediaEntity> media,
    int index,
  ) {
    final item = media[index];
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _openViewer(context, media, index),
      child: Hero(
        tag: item.id,
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              if (item.localThumbnailPath != null)
                Image.asset(
                  item.localThumbnailPath!,
                  fit: BoxFit.cover,
                )
              else if (item.thumbnailId != null)
                CachedNetworkImage(
                  imageUrl: '', // Would need thumbnail URL
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(context),
                  errorWidget: (context, url, error) =>
                      _buildPlaceholder(context),
                )
              else
                _buildPlaceholder(context),

              // Video duration overlay
              if (item.type == MediaType.video) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 16,
                      ),
                      if (item.durationMs != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          item.formattedDuration ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinksTab(BuildContext context, List<MediaEntity> allMedia) {
    // For now, links are not a separate media type
    // This would typically filter by messages containing URLs
    return _buildEmptyTabState(
      context,
      Icons.link_outlined,
      'No links shared',
    );
  }

  Widget _buildDocsTab(BuildContext context, List<MediaEntity> allMedia) {
    final docs = allMedia.where((m) => m.type == MediaType.document).toList();

    if (docs.isEmpty) {
      return _buildEmptyTabState(
        context,
        Icons.folder_outlined,
        'No documents shared',
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: docs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => _buildDocItem(context, docs[index]),
    );
  }

  Widget _buildDocItem(BuildContext context, MediaEntity doc) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getDocIcon(doc.extension),
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        doc.filename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${doc.formattedSize} • ${doc.extension.toUpperCase()}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.download_rounded,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: () => _downloadAndOpen(context, doc),
    );
  }

  void _openViewer(
    BuildContext context,
    List<MediaEntity> media,
    int index,
  ) {
    MediaViewerPage.show(
      context,
      mediaItems: media,
      initialIndex: index,
      localPaths: {},
      thumbnailUrls: {},
      onDownloadRequested: (mediaId) {
        context.read<MediaBloc>().add(MediaDownloadRequested(mediaId: mediaId));
      },
    );
  }

  void _downloadAndOpen(BuildContext context, MediaEntity doc) {
    context.read<MediaBloc>().add(MediaDownloadRequested(mediaId: doc.id));
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_rounded,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No media shared yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTabState(
    BuildContext context,
    IconData icon,
    String message,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 56,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadMedia,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocIcon(String extension) {
    return switch (extension.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'doc' || 'docx' => Icons.description_rounded,
      'xls' || 'xlsx' => Icons.table_chart_rounded,
      'ppt' || 'pptx' => Icons.slideshow_rounded,
      'txt' => Icons.article_rounded,
      'zip' || 'rar' || '7z' => Icons.folder_zip_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }
}
