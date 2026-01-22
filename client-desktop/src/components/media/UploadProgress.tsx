/**
 * UploadProgress Component
 *
 * Displays upload progress for media files with cancel option.
 * Can be used standalone or as an overlay on previews.
 */

import { Component, For, Show } from 'solid-js';
import { formatFileSize } from '../../api/media';

// =============================================================================
// TYPES
// =============================================================================

export interface UploadItem {
  /** Unique identifier for the upload */
  id: string;
  /** File name being uploaded */
  filename: string;
  /** Total file size in bytes */
  totalBytes: number;
  /** Bytes uploaded so far */
  uploadedBytes: number;
  /** Upload status */
  status: 'pending' | 'uploading' | 'processing' | 'completed' | 'failed';
  /** Error message if failed */
  error?: string;
}

export interface UploadProgressProps {
  /** Single upload item */
  item?: UploadItem;
  /** Multiple upload items */
  items?: UploadItem[];
  /** Callback to cancel an upload */
  onCancel?: (id: string) => void;
  /** Callback to retry a failed upload */
  onRetry?: (id: string) => void;
  /** Whether to show as an overlay (compact mode) */
  overlay?: boolean;
  /** Additional CSS classes */
  class?: string;
}

export interface UploadProgressBarProps {
  /** Progress percentage (0-100) */
  progress: number;
  /** Whether upload is indeterminate (processing) */
  indeterminate?: boolean;
  /** Size variant */
  size?: 'sm' | 'md';
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

function getProgress(item: UploadItem): number {
  if (item.status === 'completed') return 100;
  if (item.status === 'pending') return 0;
  if (item.totalBytes === 0) return 0;
  return Math.round((item.uploadedBytes / item.totalBytes) * 100);
}

function getStatusText(item: UploadItem): string {
  switch (item.status) {
    case 'pending':
      return 'Waiting...';
    case 'uploading':
      return `${formatFileSize(item.uploadedBytes)} / ${formatFileSize(item.totalBytes)}`;
    case 'processing':
      return 'Processing...';
    case 'completed':
      return 'Completed';
    case 'failed':
      return item.error ?? 'Failed';
    default:
      return '';
  }
}

// =============================================================================
// SUB-COMPONENTS
// =============================================================================

/**
 * Progress bar with optional indeterminate state
 */
const ProgressBar: Component<UploadProgressBarProps> = (props) => {
  const size = () => (props.size === 'sm' ? 'h-1' : 'h-1.5');

  return (
    <div class={`w-full ${size()} bg-gray-200 dark:bg-gray-600 rounded-full overflow-hidden`}>
      <Show
        when={!props.indeterminate}
        fallback={
          <div class={`${size()} bg-guardyn-500 animate-indeterminate`} />
        }
      >
        <div
          class={`${size()} bg-guardyn-500 transition-all duration-300`}
          style={{ width: `${props.progress}%` }}
        />
      </Show>
    </div>
  );
};

/**
 * Single upload item row
 */
const UploadItemRow: Component<{
  item: UploadItem;
  onCancel?: () => void;
  onRetry?: () => void;
}> = (props) => {
  const isActive = () => props.item.status === 'uploading' || props.item.status === 'processing';
  const isFailed = () => props.item.status === 'failed';
  const isCompleted = () => props.item.status === 'completed';

  return (
    <div class="flex items-center gap-3 p-2 rounded-lg bg-gray-50 dark:bg-gray-800">
      {/* Status icon */}
      <div class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0">
        <Show when={isActive()}>
          <div class="w-5 h-5 border-2 border-guardyn-500 border-t-transparent rounded-full animate-spin" />
        </Show>
        <Show when={isCompleted()}>
          <svg class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </Show>
        <Show when={isFailed()}>
          <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </Show>
        <Show when={props.item.status === 'pending'}>
          <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </Show>
      </div>

      {/* File info and progress */}
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
          {props.item.filename}
        </p>
        <div class="flex items-center gap-2 mt-1">
          <div class="flex-1">
            <ProgressBar
              progress={getProgress(props.item)}
              indeterminate={props.item.status === 'processing'}
              size="sm"
            />
          </div>
          <span class={`text-xs flex-shrink-0 ${isFailed() ? 'text-red-500' : 'text-gray-500 dark:text-gray-400'}`}>
            {getStatusText(props.item)}
          </span>
        </div>
      </div>

      {/* Actions */}
      <div class="flex-shrink-0">
        <Show when={isActive() && props.onCancel}>
          <button
            onClick={() => props.onCancel?.()}
            class="p-1.5 rounded hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
            aria-label="Cancel upload"
          >
            <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </Show>
        <Show when={isFailed() && props.onRetry}>
          <button
            onClick={() => props.onRetry?.()}
            class="p-1.5 rounded hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
            aria-label="Retry upload"
          >
            <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
        </Show>
      </div>
    </div>
  );
};

// =============================================================================
// MAIN COMPONENT
// =============================================================================

/**
 * UploadProgress displays upload status for one or more files.
 *
 * @example
 * ```tsx
 * // Single item overlay
 * <UploadProgress
 *   item={{ id: '1', filename: 'photo.jpg', status: 'uploading', totalBytes: 1024, uploadedBytes: 512 }}
 *   overlay
 *   onCancel={handleCancel}
 * />
 *
 * // Multiple items list
 * <UploadProgress
 *   items={uploadQueue}
 *   onCancel={handleCancel}
 *   onRetry={handleRetry}
 * />
 * ```
 */
export const UploadProgress: Component<UploadProgressProps> = (props) => {
  const items = () => (props.items ?? (props.item ? [props.item] : []));
  const isOverlay = () => props.overlay && props.item;
  const overlayItem = () => props.item;

  return (
    <>
      {/* Overlay mode - compact single item display */}
      <Show when={isOverlay() && overlayItem()}>
        {(item) => {
          const progress = () => getProgress(item());
          return (
            <div class={`absolute inset-0 bg-black/60 flex flex-col items-center justify-center rounded-lg ${props.class ?? ''}`}>
              <ProgressBar progress={progress()} indeterminate={item().status === 'processing'} />
              <div class="flex items-center gap-2 mt-2">
                <span class="text-white text-sm">{progress()}%</span>
                <Show when={(item().status === 'uploading' || item().status === 'processing') && props.onCancel}>
                  <button
                    onClick={() => props.onCancel?.(item().id)}
                    class="text-white/70 hover:text-white text-xs underline"
                  >
                    Cancel
                  </button>
                </Show>
              </div>
              <Show when={item().status === 'failed'}>
                <div class="flex items-center gap-2 mt-1">
                  <span class="text-red-400 text-xs">{item().error ?? 'Upload failed'}</span>
                  <Show when={props.onRetry}>
                    <button
                      onClick={() => props.onRetry?.(item().id)}
                      class="text-white/70 hover:text-white text-xs underline"
                    >
                      Retry
                    </button>
                  </Show>
                </div>
              </Show>
            </div>
          );
        }}
      </Show>

      {/* List mode - multiple items */}
      <Show when={!isOverlay()}>
        <div class={`space-y-2 ${props.class ?? ''}`}>
          <For each={items()}>
            {(item) => (
              <UploadItemRow
                item={item}
                onCancel={props.onCancel ? () => props.onCancel!(item.id) : undefined}
                onRetry={props.onRetry ? () => props.onRetry!(item.id) : undefined}
              />
            )}
          </For>
        </div>
      </Show>
    </>
  );
};

export default UploadProgress;
