/**
 * MediaPreview Component
 *
 * Inline preview for media in chat bubbles.
 * Renders appropriate preview based on media type.
 */

import { Component, createSignal, Match, Show, Switch } from 'solid-js';
import type { MediaMetadata, MediaType } from '../../api/media';
import { formatDuration, formatFileSize } from '../../api/media';

// =============================================================================
// TYPES
// =============================================================================

export type PreviewSize = 'sm' | 'md' | 'lg';

export interface MediaPreviewProps {
  /** Media metadata */
  media: MediaMetadata;
  /** Thumbnail URL (if available) */
  thumbnailUrl?: string;
  /** Download URL for the media */
  downloadUrl?: string;
  /** Preview size */
  size?: PreviewSize;
  /** Click handler for preview */
  onClick?: () => void;
  /** Download handler */
  onDownload?: () => void;
  /** Whether media is currently uploading */
  isUploading?: boolean;
  /** Upload progress (0-100) */
  uploadProgress?: number;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const SIZE_CLASSES: Record<PreviewSize, { container: string; thumbnail: string }> = {
  sm: { container: 'max-w-[160px]', thumbnail: 'max-h-[120px]' },
  md: { container: 'max-w-[240px]', thumbnail: 'max-h-[180px]' },
  lg: { container: 'max-w-[320px]', thumbnail: 'max-h-[240px]' },
};

const FILE_TYPE_COLORS: Record<string, string> = {
  pdf: 'bg-red-500',
  doc: 'bg-blue-500',
  docx: 'bg-blue-500',
  xls: 'bg-green-500',
  xlsx: 'bg-green-500',
  ppt: 'bg-orange-500',
  pptx: 'bg-orange-500',
  zip: 'bg-yellow-600',
  rar: 'bg-yellow-600',
  default: 'bg-gray-500',
};

// =============================================================================
// ICONS
// =============================================================================

const PlayIcon: Component<{ class?: string }> = (props) => (
  <svg
    class={props.class ?? 'w-12 h-12'}
    fill="currentColor"
    viewBox="0 0 24 24"
  >
    <path d="M8 5v14l11-7z" />
  </svg>
);

const DocumentIcon: Component<{ class?: string }> = (props) => (
  <svg
    class={props.class ?? 'w-6 h-6'}
    fill="none"
    stroke="currentColor"
    viewBox="0 0 24 24"
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="2"
      d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
    />
  </svg>
);

const DownloadIcon: Component<{ class?: string }> = (props) => (
  <svg
    class={props.class ?? 'w-5 h-5'}
    fill="none"
    stroke="currentColor"
    viewBox="0 0 24 24"
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="2"
      d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
    />
  </svg>
);

// =============================================================================
// HELPER COMPONENTS
// =============================================================================

/**
 * Image preview with lazy loading
 */
const ImagePreview: Component<{
  src: string;
  alt: string;
  size: PreviewSize;
  onClick?: () => void;
}> = (props) => {
  const [isLoading, setIsLoading] = createSignal(true);
  const [hasError, setHasError] = createSignal(false);
  const sizeClasses = () => SIZE_CLASSES[props.size];

  return (
    <div
      class={`relative rounded-lg overflow-hidden cursor-pointer ${sizeClasses().container}`}
      onClick={() => props.onClick?.()}
    >
      <Show when={isLoading()}>
        <div class={`absolute inset-0 bg-gray-200 dark:bg-gray-700 animate-pulse`} />
      </Show>
      <Show when={hasError()}>
        <div class="flex items-center justify-center h-24 bg-gray-200 dark:bg-gray-700">
          <span class="text-gray-500 text-sm">Failed to load</span>
        </div>
      </Show>
      <Show when={!hasError()}>
        <img
          src={props.src}
          alt={props.alt}
          class={`w-full object-cover transition-transform hover:scale-[1.02] ${sizeClasses().thumbnail} ${isLoading() ? 'opacity-0' : 'opacity-100'}`}
          onLoad={() => setIsLoading(false)}
          onError={() => {
            setIsLoading(false);
            setHasError(true);
          }}
        />
      </Show>
    </div>
  );
};

/**
 * Video preview with play button overlay
 */
const VideoPreview: Component<{
  thumbnailUrl?: string;
  duration?: number;
  filename: string;
  size: PreviewSize;
  onClick?: () => void;
}> = (props) => {
  const sizeClasses = () => SIZE_CLASSES[props.size];

  return (
    <div
      class={`relative rounded-lg overflow-hidden cursor-pointer group ${sizeClasses().container}`}
      onClick={() => props.onClick?.()}
    >
      <Show
        when={props.thumbnailUrl}
        fallback={
          <div class={`flex items-center justify-center bg-gray-800 ${sizeClasses().thumbnail} min-h-[100px]`}>
            <PlayIcon class="w-12 h-12 text-white/60" />
          </div>
        }
      >
        <img
          src={props.thumbnailUrl}
          alt={props.filename}
          class={`w-full object-cover ${sizeClasses().thumbnail}`}
        />
        <div class="absolute inset-0 flex items-center justify-center bg-black/30 group-hover:bg-black/40 transition-colors">
          <div class="w-14 h-14 rounded-full bg-black/60 flex items-center justify-center group-hover:bg-black/80 transition-colors">
            <PlayIcon class="w-8 h-8 text-white ml-1" />
          </div>
        </div>
      </Show>
      <Show when={props.duration}>
        <div class="absolute bottom-2 right-2 px-1.5 py-0.5 rounded bg-black/70 text-white text-xs">
          {formatDuration(props.duration!)}
        </div>
      </Show>
    </div>
  );
};

/**
 * Audio preview with waveform visualization
 */
const AudioPreview: Component<{
  filename: string;
  sizeBytes: number;
  duration?: number;
  onClick?: () => void;
  onDownload?: () => void;
}> = (props) => {
  return (
    <div class="flex items-center gap-3 p-3 bg-gray-100 dark:bg-gray-700 rounded-lg min-w-[200px] max-w-[280px]">
      <div class="w-10 h-10 rounded-full bg-guardyn-500 flex items-center justify-center text-white flex-shrink-0">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"
          />
        </svg>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
          {props.filename}
        </p>
        <div class="flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400">
          <span>{formatFileSize(props.sizeBytes)}</span>
          <Show when={props.duration}>
            <span>•</span>
            <span>{formatDuration(props.duration!)}</span>
          </Show>
        </div>
      </div>
      <button
        onClick={(e) => {
          e.stopPropagation();
          props.onDownload?.();
        }}
        class="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
        aria-label="Download"
      >
        <DownloadIcon class="w-5 h-5 text-gray-500 dark:text-gray-400" />
      </button>
    </div>
  );
};

/**
 * Document preview with icon and metadata
 */
const DocumentPreview: Component<{
  filename: string;
  sizeBytes: number;
  onClick?: () => void;
  onDownload?: () => void;
}> = (props) => {
  const extension = () => props.filename.split('.').pop()?.toLowerCase() ?? '';
  const iconColor = () => FILE_TYPE_COLORS[extension()] ?? FILE_TYPE_COLORS.default;

  return (
    <div
      class="flex items-center gap-3 p-3 bg-gray-100 dark:bg-gray-700 rounded-lg min-w-[200px] max-w-[280px] cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
      onClick={() => props.onDownload?.()}
    >
      <div class={`w-10 h-10 rounded-lg ${iconColor()} flex items-center justify-center text-white flex-shrink-0`}>
        <DocumentIcon class="w-5 h-5" />
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
          {props.filename}
        </p>
        <p class="text-xs text-gray-500 dark:text-gray-400">
          {formatFileSize(props.sizeBytes)}
        </p>
      </div>
      <DownloadIcon class="w-5 h-5 text-gray-400 flex-shrink-0" />
    </div>
  );
};

// =============================================================================
// MAIN COMPONENT
// =============================================================================

/**
 * MediaPreview renders an appropriate preview based on media type.
 *
 * @example
 * ```tsx
 * <MediaPreview
 *   media={mediaMetadata}
 *   thumbnailUrl={thumbnailUrl}
 *   onClick={() => openViewer(mediaMetadata)}
 *   onDownload={() => downloadMedia(mediaMetadata)}
 * />
 * ```
 */
export const MediaPreview: Component<MediaPreviewProps> = (props) => {
  const size = () => props.size ?? 'md';

  const getMediaTypeForSwitch = (): MediaType => {
    return props.media.type;
  };

  return (
    <div class={`relative ${props.class ?? ''}`}>
      <Switch>
        <Match when={getMediaTypeForSwitch() === 'image'}>
          <ImagePreview
            src={props.thumbnailUrl || props.downloadUrl || ''}
            alt={props.media.filename}
            size={size()}
            onClick={props.onClick}
          />
        </Match>
        <Match when={getMediaTypeForSwitch() === 'video'}>
          <VideoPreview
            thumbnailUrl={props.thumbnailUrl}
            duration={props.media.durationMs}
            filename={props.media.filename}
            size={size()}
            onClick={props.onClick}
          />
        </Match>
        <Match when={getMediaTypeForSwitch() === 'audio'}>
          <AudioPreview
            filename={props.media.filename}
            sizeBytes={props.media.sizeBytes}
            duration={props.media.durationMs}
            onClick={props.onClick}
            onDownload={props.onDownload}
          />
        </Match>
        <Match when={getMediaTypeForSwitch() === 'document' || getMediaTypeForSwitch() === 'other' || getMediaTypeForSwitch() === 'unknown'}>
          <DocumentPreview
            filename={props.media.filename}
            sizeBytes={props.media.sizeBytes}
            onClick={props.onClick}
            onDownload={props.onDownload}
          />
        </Match>
      </Switch>

      {/* Upload progress overlay */}
      <Show when={props.isUploading}>
        <div class="absolute inset-0 bg-black/60 flex flex-col items-center justify-center rounded-lg">
          <div class="w-3/4 h-1 bg-white/20 rounded-full overflow-hidden mb-2">
            <div
              class="h-full bg-guardyn-500 transition-all duration-300"
              style={{ width: `${props.uploadProgress ?? 0}%` }}
            />
          </div>
          <span class="text-white text-sm">{props.uploadProgress ?? 0}%</span>
        </div>
      </Show>
    </div>
  );
};

export default MediaPreview;
