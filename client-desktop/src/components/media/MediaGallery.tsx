/**
 * MediaGallery Component
 *
 * Grid view for displaying all media in a conversation.
 * Supports tabs for Media/Links/Docs, infinite scroll, and lightbox preview.
 */

import { Component, createEffect, createResource, createSignal, For, Show } from 'solid-js';
import { listMedia, type MediaMetadata, type MediaType } from '../../api/media';

// =============================================================================
// TYPES
// =============================================================================

export type GalleryTab = 'media' | 'links' | 'docs';

export interface MediaGalleryProps {
  /** Conversation ID to fetch media for */
  conversationId: string;
  /** Initial tab to display */
  initialTab?: GalleryTab;
  /** Callback when media is selected */
  onMediaSelect?: (media: MediaMetadata, index: number, allMedia: MediaMetadata[]) => void;
  /** Callback when media download is requested */
  onDownload?: (media: MediaMetadata) => void;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const TAB_LABELS: Record<GalleryTab, string> = {
  media: 'Media',
  links: 'Links',
  docs: 'Docs',
};

const MEDIA_TYPES_PER_TAB: Record<GalleryTab, MediaType[]> = {
  media: ['image', 'video'],
  links: [], // Links are handled differently
  docs: ['document', 'audio', 'other'],
};

const PAGE_SIZE = 24;

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * MediaGallery displays all media for a conversation in a tabbed grid view.
 *
 * @example
 * ```tsx
 * <MediaGallery
 *   conversationId={conversationId}
 *   onMediaSelect={(media, index, all) => openViewer(all, index)}
 *   onDownload={handleDownload}
 * />
 * ```
 */
export const MediaGallery: Component<MediaGalleryProps> = (props) => {
  const [activeTab, setActiveTab] = createSignal<GalleryTab>(props.initialTab ?? 'media');
  const [cursor, setCursor] = createSignal<string | undefined>(undefined);
  const [allItems, setAllItems] = createSignal<MediaMetadata[]>([]);
  const [hasMore, setHasMore] = createSignal(true);
  let observerTarget: HTMLDivElement | undefined;

  // Fetch media for the current tab
  const fetchMedia = async (conversationId: string, tab: GalleryTab, pageCursor?: string) => {
    if (tab === 'links') {
      // Links are not yet implemented
      return { items: [], totalCount: 0 };
    }

    const mediaTypes = MEDIA_TYPES_PER_TAB[tab];
    if (mediaTypes.length === 0) {
      return { items: [], totalCount: 0 };
    }

    return await listMedia({
      conversationId,
      mediaTypes,
      limit: PAGE_SIZE,
      cursor: pageCursor,
      sortBy: 'created_at',
      ascending: false,
    });
  };

  // Initial fetch resource
  const [mediaResource] = createResource(
    () => ({ conversationId: props.conversationId, tab: activeTab() }),
    async (params) => {
      setAllItems([]);
      setCursor(undefined);
      setHasMore(true);
      return fetchMedia(params.conversationId, params.tab);
    }
  );

  // Update all items when resource changes
  createEffect(() => {
    const result = mediaResource();
    if (result) {
      setAllItems(result.items);
      setCursor(result.nextCursor);
      setHasMore(!!result.nextCursor);
    }
  });

  // Load more items
  const loadMore = async () => {
    if (!hasMore() || mediaResource.loading) return;

    const currentCursor = cursor();
    if (!currentCursor) return;

    const result = await fetchMedia(props.conversationId, activeTab(), currentCursor);
    setAllItems((prev) => [...prev, ...result.items]);
    setCursor(result.nextCursor);
    setHasMore(!!result.nextCursor);
  };

  // Intersection observer for infinite scroll
  createEffect(() => {
    if (!observerTarget) return;

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasMore() && !mediaResource.loading) {
          loadMore();
        }
      },
      { threshold: 0.1 }
    );

    observer.observe(observerTarget);

    return () => observer.disconnect();
  });

  // Tab change handler
  const handleTabChange = (tab: GalleryTab) => {
    if (tab !== activeTab()) {
      setActiveTab(tab);
    }
  };

  // Media click handler
  const handleMediaClick = (media: MediaMetadata, index: number) => {
    props.onMediaSelect?.(media, index, allItems());
  };

  // Get file extension
  const getExtension = (filename: string) => {
    return filename.split('.').pop()?.toUpperCase() ?? '';
  };

  // Get extension color
  const getExtensionColor = (filename: string) => {
    const ext = filename.split('.').pop()?.toLowerCase() ?? '';
    switch (ext) {
      case 'pdf':
        return 'bg-red-500';
      case 'doc':
      case 'docx':
        return 'bg-blue-500';
      case 'xls':
      case 'xlsx':
        return 'bg-green-500';
      case 'ppt':
      case 'pptx':
        return 'bg-orange-500';
      default:
        return 'bg-gray-500';
    }
  };

  return (
    <div class={`flex flex-col h-full ${props.class ?? ''}`}>
      {/* Tabs */}
      <div class="flex border-b border-gray-200 dark:border-gray-700">
        <For each={Object.entries(TAB_LABELS)}>
          {([tab, label]) => (
            <button
              onClick={() => handleTabChange(tab as GalleryTab)}
              class={`flex-1 px-4 py-3 text-sm font-medium transition-colors ${
                activeTab() === tab
                  ? 'text-guardyn-600 dark:text-guardyn-400 border-b-2 border-guardyn-600 dark:border-guardyn-400'
                  : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
              }`}
            >
              {label}
            </button>
          )}
        </For>
      </div>

      {/* Content */}
      <div class="flex-1 overflow-y-auto p-4">
        {/* Loading state */}
        <Show when={mediaResource.loading && allItems().length === 0}>
          <div class="grid grid-cols-3 gap-2">
            <For each={Array(9).fill(0)}>
              {() => (
                <div class="aspect-square rounded-lg bg-gray-200 dark:bg-gray-700 animate-pulse" />
              )}
            </For>
          </div>
        </Show>

        {/* Empty state */}
        <Show when={!mediaResource.loading && allItems().length === 0}>
          <div class="flex flex-col items-center justify-center h-full text-gray-500 dark:text-gray-400">
            <svg class="w-16 h-16 mb-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <Show when={activeTab() === 'media'}>
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1.5"
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </Show>
              <Show when={activeTab() === 'links'}>
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1.5"
                  d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
                />
              </Show>
              <Show when={activeTab() === 'docs'}>
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1.5"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </Show>
            </svg>
            <p class="text-sm">No {TAB_LABELS[activeTab()].toLowerCase()} shared in this conversation</p>
          </div>
        </Show>

        {/* Media/Links grid */}
        <Show when={activeTab() === 'media' || activeTab() === 'links'}>
          <div class="grid grid-cols-3 gap-2">
            <For each={allItems()}>
              {(item, index) => (
                <button
                  onClick={() => handleMediaClick(item, index())}
                  class="relative aspect-square rounded-lg overflow-hidden bg-gray-200 dark:bg-gray-700 group"
                >
                  {/* Thumbnail */}
                  <Show
                    when={item.thumbnailId || item.type === 'image'}
                    fallback={
                      <div class="absolute inset-0 flex items-center justify-center">
                        <svg class="w-8 h-8 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M8 5v14l11-7z" />
                        </svg>
                      </div>
                    }
                  >
                    <img
                      src={`/api/media/thumbnail/${item.thumbnailId || item.id}`}
                      alt={item.filename}
                      class="w-full h-full object-cover"
                      loading="lazy"
                    />
                  </Show>

                  {/* Video indicator */}
                  <Show when={item.type === 'video'}>
                    <div class="absolute bottom-1 right-1 px-1.5 py-0.5 rounded bg-black/70 text-white text-xs">
                      <svg class="w-3 h-3 inline-block mr-0.5" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z" />
                      </svg>
                    </div>
                  </Show>

                  {/* Hover overlay */}
                  <div class="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors" />
                </button>
              )}
            </For>
          </div>
        </Show>

        {/* Documents list */}
        <Show when={activeTab() === 'docs'}>
          <div class="space-y-2">
            <For each={allItems()}>
              {(item, index) => (
                <div
                  onClick={() => handleMediaClick(item, index())}
                  class="flex items-center gap-3 p-3 rounded-lg bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 cursor-pointer transition-colors"
                >
                  <div class={`w-10 h-10 rounded-lg ${getExtensionColor(item.filename)} flex items-center justify-center text-white flex-shrink-0`}>
                    <span class="text-xs font-bold">{getExtension(item.filename)}</span>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 dark:text-white truncate">{item.filename}</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">
                      {(item.sizeBytes / 1024).toFixed(1)} KB
                    </p>
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      props.onDownload?.(item);
                    }}
                    class="p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-500 transition-colors"
                    aria-label="Download"
                  >
                    <svg class="w-5 h-5 text-gray-500 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                  </button>
                </div>
              )}
            </For>
          </div>
        </Show>

        {/* Infinite scroll trigger */}
        <Show when={hasMore() && allItems().length > 0}>
          <div ref={(el) => (observerTarget = el)} class="h-10 flex items-center justify-center">
            <Show when={mediaResource.loading}>
              <div class="w-6 h-6 border-2 border-guardyn-500 border-t-transparent rounded-full animate-spin" />
            </Show>
          </div>
        </Show>
      </div>
    </div>
  );
};

export default MediaGallery;
