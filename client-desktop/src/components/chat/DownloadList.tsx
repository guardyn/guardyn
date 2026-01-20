import { Component, createEffect, createSignal, For, Show, type JSX } from 'solid-js';
import {
    cancelDownload,
    clearCompletedDownloads,
    getDownloads,
    openDownloadedFile,
    removeDownload,
    retryDownload,
    showInFolder,
    useDownloadUpdates,
    type DownloadItem,
    type DownloadStatus,
} from '../../services/downloadManager';

/**
 * DownloadList - Display and manage active/completed downloads
 */
export const DownloadList: Component = () => {
  const [downloads, setDownloads] = createSignal<DownloadItem[]>([]);
  const [isOpen, setIsOpen] = createSignal(false);
  const downloadUpdates = useDownloadUpdates();

  // Refresh downloads list when updates occur
  createEffect(() => {
    // Subscribe to download updates - access the signal to track it
    downloadUpdates();
    setDownloads(getDownloads());
  });

  // Format file size
  const formatSize = (bytes: number): string => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
  };

  // Get status icon
  const getStatusIcon = (status: DownloadStatus) => {
    switch (status) {
      case 'downloading':
        return (
          <svg class="w-4 h-4 animate-spin text-guardyn-500" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
          </svg>
        );
      case 'completed':
        return (
          <svg class="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        );
      case 'failed':
        return (
          <svg class="w-4 h-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        );
      case 'cancelled':
        return (
          <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
          </svg>
        );
      default:
        return (
          <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
    }
  };

  // Get active count for badge
  const activeCount = () => downloads().filter(d => d.status === 'downloading' || d.status === 'pending').length;

  return (
    <div class="relative">
      {/* Toggle Button */}
      <button
        onClick={() => setIsOpen(!isOpen())}
        class="relative p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
        title="Downloads"
      >
        <svg class="w-5 h-5 text-gray-600 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
        </svg>

        {/* Badge */}
        <Show when={activeCount() > 0}>
          <span class="absolute -top-1 -right-1 min-w-[18px] h-[18px] flex items-center justify-center text-xs font-medium text-white bg-guardyn-500 rounded-full px-1">
            {activeCount()}
          </span>
        </Show>
      </button>

      {/* Downloads Panel */}
      <Show when={isOpen()}>
        <div class="absolute right-0 mt-2 w-80 max-h-96 overflow-hidden rounded-xl shadow-lg bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 z-50">
          {/* Header */}
          <div class="flex items-center justify-between px-4 py-3 border-b border-gray-200 dark:border-gray-700">
            <h3 class="font-semibold text-gray-900 dark:text-white">Downloads</h3>
            <Show when={downloads().some(d => ['completed', 'failed', 'cancelled'].includes(d.status))}>
              <button
                onClick={() => clearCompletedDownloads()}
                class="text-xs text-guardyn-600 hover:text-guardyn-700 dark:text-guardyn-400"
              >
                Clear completed
              </button>
            </Show>
          </div>

          {/* Downloads List */}
          <div class="overflow-y-auto max-h-72">
            <Show when={downloads().length === 0}>
              <div class="py-8 text-center text-gray-500 dark:text-gray-400">
                <svg class="w-12 h-12 mx-auto mb-2 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10" />
                </svg>
                <p class="text-sm">No downloads</p>
              </div>
            </Show>

            <For each={downloads()}>
              {(download) => (
                <DownloadItemRow
                  download={download}
                  formatSize={formatSize}
                  getStatusIcon={getStatusIcon}
                />
              )}
            </For>
          </div>
        </div>
      </Show>

      {/* Click outside to close */}
      <Show when={isOpen()}>
        <div
          class="fixed inset-0 z-40"
          onClick={() => setIsOpen(false)}
        />
      </Show>
    </div>
  );
};

interface DownloadItemRowProps {
  download: DownloadItem;
  formatSize: (bytes: number) => string;
  getStatusIcon: (status: DownloadStatus) => JSX.Element;
}

const DownloadItemRow: Component<DownloadItemRowProps> = (props) => {
  const handleOpen = async () => {
    try {
      await openDownloadedFile(props.download.id);
    } catch {
      // Failed to open file
    }
  };

  const handleShowInFolder = async () => {
    try {
      await showInFolder(props.download.id);
    } catch {
      // Failed to show in folder
    }
  };

  return (
    <div class="px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-800/50 border-b border-gray-100 dark:border-gray-800 last:border-b-0">
      <div class="flex items-start gap-3">
        {/* Status Icon */}
        <div class="flex-shrink-0 mt-0.5">
          {props.getStatusIcon(props.download.status)}
        </div>

        {/* Content */}
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 dark:text-white truncate" title={props.download.fileName}>
            {props.download.fileName}
          </p>

          {/* Progress bar for downloading */}
          <Show when={props.download.status === 'downloading'}>
            <div class="mt-1">
              <div class="h-1.5 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div
                  class="h-full bg-guardyn-500 rounded-full transition-all duration-300"
                  style={{ width: `${props.download.progress}%` }}
                />
              </div>
              <div class="flex justify-between mt-1 text-xs text-gray-500">
                <span>{props.formatSize(props.download.bytesDownloaded)}</span>
                <span>{props.download.progress}%</span>
              </div>
            </div>
          </Show>

          {/* Size for completed */}
          <Show when={props.download.status === 'completed'}>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {props.formatSize(props.download.fileSize)}
            </p>
          </Show>

          {/* Error message */}
          <Show when={props.download.status === 'failed' && props.download.error}>
            <p class="text-xs text-red-500 truncate" title={props.download.error}>
              {props.download.error}
            </p>
          </Show>
        </div>

        {/* Actions */}
        <div class="flex-shrink-0 flex items-center gap-1">
          {/* Cancel button for downloading/pending */}
          <Show when={['downloading', 'pending'].includes(props.download.status)}>
            <button
              onClick={() => cancelDownload(props.download.id)}
              class="p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
              title="Cancel"
            >
              <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </Show>

          {/* Retry button for failed */}
          <Show when={props.download.status === 'failed'}>
            <button
              onClick={() => retryDownload(props.download.id)}
              class="p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
              title="Retry"
            >
              <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </button>
          </Show>

          {/* Open/Folder buttons for completed */}
          <Show when={props.download.status === 'completed'}>
            <button
              onClick={handleOpen}
              class="p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
              title="Open"
            >
              <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
              </svg>
            </button>
            <button
              onClick={handleShowInFolder}
              class="p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
              title="Show in folder"
            >
              <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
              </svg>
            </button>
          </Show>

          {/* Remove button */}
          <Show when={['completed', 'failed', 'cancelled'].includes(props.download.status)}>
            <button
              onClick={() => removeDownload(props.download.id)}
              class="p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
              title="Remove"
            >
              <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </Show>
        </div>
      </div>
    </div>
  );
};

export default DownloadList;
