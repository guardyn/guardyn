/**
 * MediaViewer Component
 *
 * Full-screen lightbox for viewing media files.
 * Supports image/video display, navigation, zoom, and keyboard controls.
 */

import { Component, createEffect, createSignal, For, onCleanup, Show } from 'solid-js';
import type { MediaMetadata } from '../../api/media';

// =============================================================================
// TYPES
// =============================================================================

export interface MediaViewerProps {
  /** Array of media items to display */
  media: MediaMetadata[];
  /** Initial index to display */
  initialIndex?: number;
  /** Whether viewer is open */
  isOpen: boolean;
  /** Close handler */
  onClose: () => void;
  /** Download handler */
  onDownload?: (media: MediaMetadata) => void;
  /** Share handler */
  onShare?: (media: MediaMetadata) => void;
  /** Get URL for a media item */
  getMediaUrl: (media: MediaMetadata) => string;
  /** Get thumbnail URL for a media item */
  getThumbnailUrl?: (media: MediaMetadata) => string | undefined;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const MIN_SCALE = 0.5;
const MAX_SCALE = 4;

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * MediaViewer provides a full-screen lightbox for viewing media.
 *
 * @example
 * ```tsx
 * <MediaViewer
 *   media={mediaItems}
 *   initialIndex={0}
 *   isOpen={isViewerOpen()}
 *   onClose={() => setIsViewerOpen(false)}
 *   onDownload={handleDownload}
 *   getMediaUrl={(m) => m.downloadUrl}
 * />
 * ```
 */
export const MediaViewer: Component<MediaViewerProps> = (props) => {
  const [currentIndex, setCurrentIndex] = createSignal(props.initialIndex ?? 0);
  const [scale, setScale] = createSignal(1);
  const [position, setPosition] = createSignal({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = createSignal(false);
  const [dragStart, setDragStart] = createSignal({ x: 0, y: 0 });
  const [isVideoPlaying, setIsVideoPlaying] = createSignal(false);

  // Reset state when viewer opens
  createEffect(() => {
    if (props.isOpen) {
      setCurrentIndex(props.initialIndex ?? 0);
      resetZoom();
    }
  });

  // Current media item
  const currentMedia = () => props.media[currentIndex()];
  const isImage = () => currentMedia()?.type === 'image';
  const isVideo = () => currentMedia()?.type === 'video';
  const hasMultiple = () => props.media.length > 1;
  const hasPrev = () => currentIndex() > 0;
  const hasNext = () => currentIndex() < props.media.length - 1;

  // Navigation
  const goToPrev = () => {
    if (hasPrev()) {
      setCurrentIndex((i) => i - 1);
      resetZoom();
    }
  };

  const goToNext = () => {
    if (hasNext()) {
      setCurrentIndex((i) => i + 1);
      resetZoom();
    }
  };

  // Zoom controls
  const zoomIn = () => {
    setScale((prev) => Math.min(prev + 0.25, MAX_SCALE));
  };

  const zoomOut = () => {
    setScale((prev) => Math.max(prev - 0.25, MIN_SCALE));
    if (scale() <= 1.25) {
      setPosition({ x: 0, y: 0 });
    }
  };

  const resetZoom = () => {
    setScale(1);
    setPosition({ x: 0, y: 0 });
  };

  // Wheel zoom
  const handleWheel = (e: WheelEvent) => {
    if (!isImage()) return;
    e.preventDefault();
    if (e.deltaY < 0) {
      zoomIn();
    } else {
      zoomOut();
    }
  };

  // Drag handlers
  const handleMouseDown = (e: MouseEvent) => {
    if (scale() > 1 && isImage()) {
      setIsDragging(true);
      setDragStart({ x: e.clientX - position().x, y: e.clientY - position().y });
    }
  };

  const handleMouseMove = (e: MouseEvent) => {
    if (isDragging() && scale() > 1) {
      setPosition({
        x: e.clientX - dragStart().x,
        y: e.clientY - dragStart().y,
      });
    }
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  // Keyboard handler
  const handleKeyDown = (e: KeyboardEvent) => {
    if (!props.isOpen) return;

    switch (e.key) {
      case 'Escape':
        props.onClose();
        break;
      case 'ArrowLeft':
        goToPrev();
        break;
      case 'ArrowRight':
        goToNext();
        break;
      case '+':
      case '=':
        zoomIn();
        break;
      case '-':
        zoomOut();
        break;
      case '0':
        resetZoom();
        break;
      case ' ':
        if (isVideo()) {
          e.preventDefault();
          setIsVideoPlaying(!isVideoPlaying());
        }
        break;
    }
  };

  // Global keyboard listener
  createEffect(() => {
    if (props.isOpen) {
      document.addEventListener('keydown', handleKeyDown);
      document.body.style.overflow = 'hidden';
    }

    onCleanup(() => {
      document.removeEventListener('keydown', handleKeyDown);
      document.body.style.overflow = '';
    });
  });

  // Backdrop click
  const handleBackdropClick = (e: MouseEvent) => {
    if (e.target === e.currentTarget) {
      props.onClose();
    }
  };

  // Download handler
  const handleDownload = () => {
    const media = currentMedia();
    if (media && props.onDownload) {
      props.onDownload(media);
    }
  };

  // Share handler
  const handleShare = () => {
    const media = currentMedia();
    if (media && props.onShare) {
      props.onShare(media);
    }
  };

  return (
    <Show when={props.isOpen}>
      <div
        class="fixed inset-0 z-50 bg-black/95 flex items-center justify-center"
        onClick={handleBackdropClick}
        onWheel={handleWheel}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
      >
        {/* Top bar */}
        <div class="absolute top-0 left-0 right-0 h-16 bg-gradient-to-b from-black/50 to-transparent flex items-center justify-between px-4 z-10">
          <div class="flex items-center gap-3">
            <span class="text-white font-medium truncate max-w-md">
              {currentMedia()?.filename ?? 'Media Preview'}
            </span>
            <Show when={hasMultiple()}>
              <span class="text-white/60 text-sm">
                {currentIndex() + 1} / {props.media.length}
              </span>
            </Show>
            <Show when={isImage()}>
              <span class="text-white/60 text-sm">{Math.round(scale() * 100)}%</span>
            </Show>
          </div>

          <button
            onClick={() => props.onClose()}
            class="p-2 rounded-lg bg-white/10 hover:bg-white/20 transition-colors"
            aria-label="Close"
          >
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Navigation arrows */}
        <Show when={hasMultiple()}>
          <Show when={hasPrev()}>
            <button
              onClick={goToPrev}
              class="absolute left-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-black/50 hover:bg-black/70 transition-colors z-10"
              aria-label="Previous"
            >
              <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
          </Show>
          <Show when={hasNext()}>
            <button
              onClick={goToNext}
              class="absolute right-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-black/50 hover:bg-black/70 transition-colors z-10"
              aria-label="Next"
            >
              <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </Show>
        </Show>

        {/* Media content */}
        <Show when={currentMedia()}>
          <div
            class={`select-none ${isImage() && scale() > 1 ? 'cursor-grab' : 'cursor-default'} ${isDragging() ? 'cursor-grabbing' : ''}`}
            onMouseDown={handleMouseDown}
          >
            <Show when={isImage()}>
              <img
                src={props.getMediaUrl(currentMedia()!)}
                alt={currentMedia()?.filename}
                class="max-h-[85vh] max-w-[90vw] object-contain transition-transform duration-200"
                style={{
                  transform: `scale(${scale()}) translate(${position().x / scale()}px, ${position().y / scale()}px)`,
                }}
                draggable={false}
              />
            </Show>
            <Show when={isVideo()}>
              <video
                src={props.getMediaUrl(currentMedia()!)}
                poster={props.getThumbnailUrl?.(currentMedia()!)}
                controls
                autoplay={isVideoPlaying()}
                class="max-h-[85vh] max-w-[90vw] object-contain"
              />
            </Show>
          </div>
        </Show>

        {/* Bottom bar */}
        <div class="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-black/50 to-transparent flex items-center justify-center gap-4 z-10">
          {/* Zoom controls (images only) */}
          <Show when={isImage()}>
            <div class="flex items-center gap-2 bg-white/10 rounded-lg p-1">
              <button
                onClick={zoomOut}
                disabled={scale() <= MIN_SCALE}
                class="p-2 rounded hover:bg-white/10 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                aria-label="Zoom out"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
                </svg>
              </button>

              <button onClick={resetZoom} class="px-3 py-1 text-white text-sm hover:bg-white/10 rounded transition-colors">
                {Math.round(scale() * 100)}%
              </button>

              <button
                onClick={zoomIn}
                disabled={scale() >= MAX_SCALE}
                class="p-2 rounded hover:bg-white/10 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                aria-label="Zoom in"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
              </button>
            </div>

            <div class="h-8 w-px bg-white/20" />
          </Show>

          {/* Action buttons */}
          <div class="flex items-center gap-2">
            <Show when={props.onDownload}>
              <button
                onClick={handleDownload}
                class="p-2 rounded-lg bg-white/10 hover:bg-white/20 transition-colors"
                aria-label="Download"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                  />
                </svg>
              </button>
            </Show>

            <Show when={props.onShare}>
              <button
                onClick={handleShare}
                class="p-2 rounded-lg bg-white/10 hover:bg-white/20 transition-colors"
                aria-label="Share"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z"
                  />
                </svg>
              </button>
            </Show>
          </div>
        </div>

        {/* Keyboard hints */}
        <div class="absolute bottom-24 left-1/2 -translate-x-1/2 text-white/40 text-xs flex gap-4">
          <span>ESC to close</span>
          <Show when={hasMultiple()}>
            <span>← → to navigate</span>
          </Show>
          <Show when={isImage()}>
            <span>+/- to zoom</span>
            <span>Scroll to zoom</span>
            <span>Drag to pan</span>
          </Show>
          <Show when={isVideo()}>
            <span>Space to play/pause</span>
          </Show>
        </div>

        {/* Thumbnail strip (for multiple items) */}
        <Show when={hasMultiple() && props.media.length <= 20}>
          <div class="absolute bottom-28 left-1/2 -translate-x-1/2 flex gap-2 p-2 bg-black/50 rounded-lg max-w-[80vw] overflow-x-auto">
            <For each={props.media}>
              {(item, index) => (
                <button
                  onClick={() => {
                    setCurrentIndex(index());
                    resetZoom();
                  }}
                  class={`w-12 h-12 rounded overflow-hidden flex-shrink-0 border-2 transition-colors ${
                    index() === currentIndex() ? 'border-guardyn-500' : 'border-transparent hover:border-white/50'
                  }`}
                >
                  <Show
                    when={props.getThumbnailUrl?.(item) || item.type === 'image'}
                    fallback={
                      <div class="w-full h-full bg-gray-700 flex items-center justify-center">
                        <svg class="w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M8 5v14l11-7z" />
                        </svg>
                      </div>
                    }
                  >
                    <img
                      src={props.getThumbnailUrl?.(item) || props.getMediaUrl(item)}
                      alt={item.filename}
                      class="w-full h-full object-cover"
                    />
                  </Show>
                </button>
              )}
            </For>
          </div>
        </Show>
      </div>
    </Show>
  );
};

export default MediaViewer;
