import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/media_entity.dart';

/// Full-screen media viewer page
///
/// Supports:
/// - Image viewing with zoom/pan via PhotoView
/// - Video playback with controls
/// - Gallery navigation when multiple items
/// - Share and download actions
class MediaViewerPage extends StatefulWidget {
  /// List of media items to view
  final List<MediaEntity> mediaItems;

  /// Initial index in the list
  final int initialIndex;

  /// Map of media ID to local file path
  final Map<String, String> localPaths;

  /// Map of media ID to thumbnail URL
  final Map<String, String> thumbnailUrls;

  /// Callback to request download
  final void Function(String mediaId)? onDownloadRequested;

  const MediaViewerPage({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.localPaths = const {},
    this.thumbnailUrls = const {},
    this.onDownloadRequested,
  });

  /// Show media viewer as full-screen route
  static Future<void> show(
    BuildContext context, {
    required List<MediaEntity> mediaItems,
    int initialIndex = 0,
    Map<String, String> localPaths = const {},
    Map<String, String> thumbnailUrls = const {},
    void Function(String mediaId)? onDownloadRequested,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaViewerPage(
          mediaItems: mediaItems,
          initialIndex: initialIndex,
          localPaths: localPaths,
          thumbnailUrls: thumbnailUrls,
          onDownloadRequested: onDownloadRequested,
        ),
      ),
    );
  }

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initializeCurrentMedia();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _initializeCurrentMedia() {
    final media = widget.mediaItems[_currentIndex];
    if (media.type == MediaType.video) {
      _initializeVideo(media);
    }
  }

  Future<void> _initializeVideo(MediaEntity media) async {
    _videoController?.dispose();
    _isVideoInitialized = false;

    final localPath = widget.localPaths[media.id];
    if (localPath != null && File(localPath).existsSync()) {
      _videoController = VideoPlayerController.file(File(localPath));
    } else {
      // Request download
      widget.onDownloadRequested?.call(media.id);
      return;
    }

    try {
      await _videoController!.initialize();
      setState(() => _isVideoInitialized = true);
    } catch (e) {
      debugPrint('Failed to initialize video: $e');
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _initializeCurrentMedia();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          GestureDetector(
            onTap: _toggleControls,
            child: _buildContent(),
          ),

          // Top bar with controls
          if (_showControls) _buildTopBar(),

          // Bottom bar for video controls
          if (_showControls && _currentMedia.type == MediaType.video)
            _buildVideoControls(),

          // Page indicator
          if (widget.mediaItems.length > 1 && _showControls)
            _buildPageIndicator(),
        ],
      ),
    );
  }

  MediaEntity get _currentMedia => widget.mediaItems[_currentIndex];

  Widget _buildContent() {
    final media = _currentMedia;

    switch (media.type) {
      case MediaType.image:
        return _buildImageViewer();
      case MediaType.video:
        return _buildVideoPlayer();
      case MediaType.audio:
      case MediaType.document:
      default:
        return _buildDocumentView();
    }
  }

  Widget _buildImageViewer() {
    if (widget.mediaItems.length == 1) {
      return _buildSingleImage(_currentMedia);
    }

    // Gallery for multiple images
    final imageItems = widget.mediaItems
        .where((m) => m.type == MediaType.image)
        .toList();

    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (context, index) {
        final media = imageItems[index];
        return _buildPhotoViewItem(media);
      },
      itemCount: imageItems.length,
      loadingBuilder: (context, event) => Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: event == null
                ? null
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      pageController: _pageController,
      onPageChanged: _onPageChanged,
    );
  }

  PhotoViewGalleryPageOptions _buildPhotoViewItem(MediaEntity media) {
    final localPath = widget.localPaths[media.id];
    final thumbnailUrl = widget.thumbnailUrls[media.id];

    ImageProvider imageProvider;

    if (localPath != null && File(localPath).existsSync()) {
      imageProvider = FileImage(File(localPath));
    } else if (thumbnailUrl != null) {
      imageProvider = CachedNetworkImageProvider(thumbnailUrl);
    } else {
      imageProvider = const AssetImage('assets/images/placeholder.png');
    }

    return PhotoViewGalleryPageOptions(
      imageProvider: imageProvider,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      heroAttributes: PhotoViewHeroAttributes(tag: media.id),
    );
  }

  Widget _buildSingleImage(MediaEntity media) {
    final localPath = widget.localPaths[media.id];
    final thumbnailUrl = widget.thumbnailUrls[media.id];

    ImageProvider imageProvider;

    if (localPath != null && File(localPath).existsSync()) {
      imageProvider = FileImage(File(localPath));
    } else if (thumbnailUrl != null) {
      imageProvider = CachedNetworkImageProvider(thumbnailUrl);
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            if (widget.onDownloadRequested != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => widget.onDownloadRequested?.call(media.id),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ],
          ],
        ),
      );
    }

    return PhotoView(
      imageProvider: imageProvider,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      heroAttributes: PhotoViewHeroAttributes(tag: media.id),
      loadingBuilder: (context, event) => Center(
        child: CircularProgressIndicator(
          value: event == null
              ? null
              : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildDocumentView() {
    final media = _currentMedia;
    final localPath = widget.localPaths[media.id];

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getDocumentIcon(media.extension),
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              media.filename,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${media.formattedSize} • ${media.extension.toUpperCase()}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            if (localPath != null)
              ElevatedButton.icon(
                onPressed: () => OpenFilex.open(localPath),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            else if (widget.onDownloadRequested != null)
              ElevatedButton.icon(
                onPressed: () => widget.onDownloadRequested?.call(media.id),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                const Spacer(),
                // Download button
                if (widget.onDownloadRequested != null &&
                    !widget.localPaths.containsKey(_currentMedia.id))
                  IconButton(
                    onPressed: () =>
                        widget.onDownloadRequested?.call(_currentMedia.id),
                    icon: const Icon(Icons.download, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    if (!_isVideoInitialized || _videoController == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _videoController!,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Slider(
                        value: value.position.inMilliseconds.toDouble(),
                        min: 0,
                        max: value.duration.inMilliseconds.toDouble(),
                        onChanged: (newValue) {
                          _videoController!.seekTo(
                            Duration(milliseconds: newValue.toInt()),
                          );
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(value.position),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(value.duration),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Play/pause button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      _videoController!.seekTo(
                        _videoController!.value.position -
                            const Duration(seconds: 10),
                      );
                    },
                    icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _videoController!,
                    builder: (context, value, child) {
                      return IconButton(
                        onPressed: () {
                          if (value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        },
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      _videoController!.seekTo(
                        _videoController!.value.position +
                            const Duration(seconds: 10),
                      );
                    },
                    icon:
                        const Icon(Icons.forward_10, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: _currentMedia.type == MediaType.video ? 140 : 32,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_currentIndex + 1} / ${widget.mediaItems.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  IconData _getDocumentIcon(String extension) {
    return switch (extension.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'doc' || 'docx' => Icons.description_rounded,
      'xls' || 'xlsx' => Icons.table_chart_rounded,
      'ppt' || 'pptx' => Icons.slideshow_rounded,
      'txt' => Icons.article_rounded,
      'zip' || 'rar' || '7z' => Icons.folder_zip_rounded,
      'mp3' || 'm4a' || 'wav' || 'ogg' => Icons.audiotrack_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }
}
