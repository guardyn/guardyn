/**
 * Download Manager Service
 * 
 * Manages background file downloads with progress tracking,
 * queue management, and native integration for opening files.
 */

import { invoke } from '@tauri-apps/api/core';
import { save } from '@tauri-apps/plugin-dialog';
import { createSignal } from 'solid-js';
import { createStore } from 'solid-js/store';

// ============================================================================
// Types
// ============================================================================

export type DownloadStatus = 
  | 'pending'     // Queued for download
  | 'downloading' // Currently downloading
  | 'completed'   // Successfully completed
  | 'failed'      // Download failed
  | 'cancelled';  // User cancelled

export interface DownloadItem {
  id: string;
  url: string;
  fileName: string;
  fileSize: number;
  mimeType?: string;
  status: DownloadStatus;
  progress: number;      // 0-100
  bytesDownloaded: number;
  localPath?: string;    // Path where file is saved
  error?: string;
  startedAt?: Date;
  completedAt?: Date;
}

export interface DownloadOptions {
  fileName?: string;
  destinationPath?: string;
  showSaveDialog?: boolean;
}

// ============================================================================
// Store
// ============================================================================

interface DownloadStore {
  downloads: Record<string, DownloadItem>;
  activeDownloads: number;
  maxConcurrent: number;
}

const [store, setStore] = createStore<DownloadStore>({
  downloads: {},
  activeDownloads: 0,
  maxConcurrent: 3,
});

// Signal for subscribers
const [downloadUpdates, setDownloadUpdates] = createSignal<string | null>(null);

// ============================================================================
// Utility Functions
// ============================================================================

function generateId(): string {
  return `dl_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

function extractFileName(url: string, mimeType?: string): string {
  try {
    const urlObj = new URL(url);
    const pathname = urlObj.pathname;
    const fileName = pathname.split('/').pop() || 'download';
    
    // If no extension, try to guess from mime type
    if (!fileName.includes('.') && mimeType) {
      const ext = mimeType.split('/')[1];
      if (ext) return `${fileName}.${ext}`;
    }
    
    return fileName;
  } catch {
    return 'download';
  }
}

// ============================================================================
// Core Download Manager
// ============================================================================

/**
 * Start a new download
 */
export async function startDownload(
  url: string,
  options: DownloadOptions = {}
): Promise<string> {
  const id = generateId();
  const fileName = options.fileName || extractFileName(url);
  
  // Determine save path
  let destinationPath = options.destinationPath;
  
  if (options.showSaveDialog) {
    try {
      const selectedPath = await save({
        defaultPath: fileName,
        filters: [{
          name: 'All Files',
          extensions: ['*']
        }]
      });
      
      if (selectedPath) {
        destinationPath = selectedPath;
      } else {
        // User cancelled dialog
        return '';
      }
    } catch (err) {
      console.error('Save dialog error:', err);
      throw new Error('Failed to open save dialog');
    }
  }
  
  // Create download item
  const downloadItem: DownloadItem = {
    id,
    url,
    fileName,
    fileSize: 0,
    status: 'pending',
    progress: 0,
    bytesDownloaded: 0,
    localPath: destinationPath,
    startedAt: new Date(),
  };
  
  // Add to store
  setStore('downloads', id, downloadItem);
  setDownloadUpdates(id);
  
  // Start the download
  processDownload(id);
  
  return id;
}

/**
 * Process a download (internal)
 */
async function processDownload(id: string): Promise<void> {
  const download = store.downloads[id];
  if (!download) return;
  
  // Check concurrent limit
  if (store.activeDownloads >= store.maxConcurrent) {
    // Stay in pending state, will be processed when slot opens
    return;
  }
  
  // Update status
  setStore('activeDownloads', (n) => n + 1);
  setStore('downloads', id, 'status', 'downloading');
  setDownloadUpdates(id);
  
  try {
    // Use Tauri command for actual download
    const result = await invoke<DownloadResult>('download_file', {
      url: download.url,
      destinationPath: download.localPath,
      fileName: download.fileName,
    });
    
    // Update with result
    setStore('downloads', id, {
      status: 'completed',
      progress: 100,
      bytesDownloaded: result.fileSize,
      fileSize: result.fileSize,
      localPath: result.savedPath,
      completedAt: new Date(),
    });
    
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    
    setStore('downloads', id, {
      status: 'failed',
      error: errorMessage,
    });
  } finally {
    setStore('activeDownloads', (n) => Math.max(0, n - 1));
    setDownloadUpdates(id);
    
    // Process next pending download
    processNextPending();
  }
}

/**
 * Process the next pending download
 */
function processNextPending(): void {
  const pendingId = Object.keys(store.downloads).find(
    (id) => store.downloads[id].status === 'pending'
  );
  
  if (pendingId) {
    processDownload(pendingId);
  }
}

/**
 * Cancel a download
 */
export function cancelDownload(id: string): void {
  const download = store.downloads[id];
  if (!download) return;
  
  if (download.status === 'downloading') {
    // Try to cancel via Tauri
    invoke('cancel_download', { downloadId: id }).catch(console.error);
    setStore('activeDownloads', (n) => Math.max(0, n - 1));
  }
  
  setStore('downloads', id, 'status', 'cancelled');
  setDownloadUpdates(id);
  
  // Process next pending
  if (download.status === 'downloading') {
    processNextPending();
  }
}

/**
 * Retry a failed download
 */
export function retryDownload(id: string): void {
  const download = store.downloads[id];
  if (!download || download.status !== 'failed') return;
  
  setStore('downloads', id, {
    status: 'pending',
    progress: 0,
    bytesDownloaded: 0,
    error: undefined,
    startedAt: new Date(),
  });
  setDownloadUpdates(id);
  
  processDownload(id);
}

/**
 * Remove a download from the list
 */
export function removeDownload(id: string): void {
  const download = store.downloads[id];
  if (!download) return;
  
  // Cancel if still in progress
  if (download.status === 'downloading') {
    cancelDownload(id);
  }
  
  setStore('downloads', (downloads) => {
    const { [id]: _removed, ...rest } = downloads;
    void _removed; // Intentionally unused
    return rest;
  });
  setDownloadUpdates(id);
}

/**
 * Clear all completed/failed/cancelled downloads
 */
export function clearCompletedDownloads(): void {
  const toRemove = Object.keys(store.downloads).filter(
    (id) => ['completed', 'failed', 'cancelled'].includes(store.downloads[id].status)
  );
  
  toRemove.forEach((id) => {
    setStore('downloads', (downloads) => {
      const { [id]: _removed, ...rest } = downloads;
      void _removed; // Intentionally unused
      return rest;
    });
  });
  
  if (toRemove.length > 0) {
    setDownloadUpdates('clear');
  }
}

/**
 * Open a downloaded file with default application
 */
export async function openDownloadedFile(id: string): Promise<void> {
  const download = store.downloads[id];
  if (!download || download.status !== 'completed' || !download.localPath) {
    throw new Error('Download not available');
  }
  
  await invoke('open_file_with_default_app', {
    filePath: download.localPath,
  });
}

/**
 * Open the folder containing a downloaded file
 */
export async function showInFolder(id: string): Promise<void> {
  const download = store.downloads[id];
  if (!download || !download.localPath) {
    throw new Error('Download not available');
  }
  
  await invoke('show_in_folder', {
    filePath: download.localPath,
  });
}

// ============================================================================
// Getters
// ============================================================================

/**
 * Get all downloads
 */
export function getDownloads(): DownloadItem[] {
  return Object.values(store.downloads).sort((a, b) => {
    // Active downloads first, then by start time
    const statusOrder: Record<DownloadStatus, number> = {
      downloading: 0,
      pending: 1,
      completed: 2,
      failed: 3,
      cancelled: 4,
    };
    
    const statusDiff = statusOrder[a.status] - statusOrder[b.status];
    if (statusDiff !== 0) return statusDiff;
    
    return (b.startedAt?.getTime() || 0) - (a.startedAt?.getTime() || 0);
  });
}

/**
 * Get a specific download
 */
export function getDownload(id: string): DownloadItem | undefined {
  return store.downloads[id];
}

/**
 * Get active download count
 */
export function getActiveDownloadCount(): number {
  return store.activeDownloads;
}

/**
 * Subscribe to download updates
 */
export function useDownloadUpdates() {
  return downloadUpdates;
}

// ============================================================================
// Download Progress Listener (for Tauri events)
// ============================================================================

interface DownloadProgress {
  downloadId: string;
  bytesDownloaded: number;
  totalBytes: number;
}

interface DownloadResult {
  fileSize: number;
  savedPath: string;
}

// Store cleanup function reference
let unlistenProgress: (() => void) | null = null;

/**
 * Initialize download progress listener
 * Should be called once on app startup
 */
export async function initDownloadManager(): Promise<void> {
  try {
    const { listen } = await import('@tauri-apps/api/event');
    
    // Listen for download progress events from Tauri
    // This is an event handler, so reactive updates are intentional
    // eslint-disable-next-line solid/reactivity
    unlistenProgress = await listen<DownloadProgress>('download-progress', (event) => {
      const { downloadId, bytesDownloaded, totalBytes } = event.payload;
      
      if (store.downloads[downloadId]) {
        const progress = totalBytes > 0 
          ? Math.round((bytesDownloaded / totalBytes) * 100) 
          : 0;
        
        setStore('downloads', downloadId, {
          bytesDownloaded,
          fileSize: totalBytes,
          progress,
        });
        setDownloadUpdates(downloadId);
      }
    });
  } catch {
    // Download manager initialization failed - downloads will still work
    // but progress updates won't be received from Tauri backend
  }
}

/**
 * Cleanup download manager listeners
 */
export function cleanupDownloadManager(): void {
  if (unlistenProgress) {
    unlistenProgress();
    unlistenProgress = null;
  }
}

// ============================================================================
// Export store for reactive access
// ============================================================================

export { store as downloadStore };
