import { Component, createSignal, Show } from 'solid-js';

type AttachmentType = 'image' | 'video' | 'audio' | 'file';

interface MediaAttachmentProps {
  type: AttachmentType;
  url: string;
  fileName: string;
  fileSize: number;
  thumbnailUrl?: string;
  mimeType?: string;
  isUploading?: boolean;
  uploadProgress?: number;
  onPreview?: () => void;
  onDownload?: () => void;
  onCancelUpload?: () => void;
}

/**
 * MediaAttachment - Display media attachments in messages
 * 
 * Supports:
 * - Images with thumbnail and full-screen preview
 * - Videos with thumbnail and play button
 * - Audio files with player
 * - Generic files with icon and download
 * - Upload progress with cancel button
 */
export const MediaAttachment: Component<MediaAttachmentProps> = (props) => {
  const [isHovered, setIsHovered] = createSignal(false);
  
  // Format file size
  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
  };
  
  // Get file icon based on type
  const getFileIcon = () => {
    switch (props.type) {
      case 'image':
        return (
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
        );
      case 'video':
        return (
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
          </svg>
        );
      case 'audio':
        return (
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
          </svg>
        );
      default:
        return (
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
        );
    }
  };
  
  // Get file extension color
  const getExtensionColor = (fileName: string): string => {
    const ext = fileName.split('.').pop()?.toLowerCase();
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
      case 'zip':
      case 'rar':
      case '7z':
        return 'bg-yellow-500';
      default:
        return 'bg-gray-500';
    }
  };

  return (
    <div 
      class="relative rounded-lg overflow-hidden"
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Image/Video with thumbnail */}
      <Show when={props.type === 'image' || props.type === 'video'}>
        <div class="relative">
          <img
            src={props.thumbnailUrl || props.url}
            alt={props.fileName}
            class="max-w-[240px] max-h-[180px] rounded-lg object-cover cursor-pointer transition-transform hover:scale-[1.02]"
            onClick={() => props.onPreview?.()}
          />
          
          {/* Video play button overlay */}
          <Show when={props.type === 'video'}>
            <div class="absolute inset-0 flex items-center justify-center">
              <button
                onClick={() => props.onPreview?.()}
                class="w-12 h-12 rounded-full bg-black/60 flex items-center justify-center hover:bg-black/80 transition-colors"
              >
                <svg class="w-6 h-6 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 5v14l11-7z" />
                </svg>
              </button>
            </div>
          </Show>
          
          {/* Hover overlay with actions */}
          <Show when={isHovered() && !props.isUploading}>
            <div class="absolute inset-0 bg-black/40 flex items-center justify-center gap-2">
              <button
                onClick={() => props.onPreview?.()}
                class="p-2 rounded-full bg-white/20 hover:bg-white/30 transition-colors"
                aria-label="Preview"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
                </svg>
              </button>
              <button
                onClick={() => props.onDownload?.()}
                class="p-2 rounded-full bg-white/20 hover:bg-white/30 transition-colors"
                aria-label="Download"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
              </button>
            </div>
          </Show>
        </div>
      </Show>
      
      {/* Audio player */}
      <Show when={props.type === 'audio'}>
        <div class="flex items-center gap-3 p-3 bg-gray-100 dark:bg-gray-700 rounded-lg min-w-[200px]">
          <div class="w-10 h-10 rounded-full bg-guardyn-500 flex items-center justify-center text-white">
            {getFileIcon()}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
              {props.fileName}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {formatFileSize(props.fileSize)}
            </p>
          </div>
          <button
            onClick={() => props.onDownload?.()}
            class="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
            aria-label="Download"
          >
            <svg class="w-5 h-5 text-gray-500 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
          </button>
        </div>
      </Show>
      
      {/* Generic file */}
      <Show when={props.type === 'file'}>
        <div 
          class="flex items-center gap-3 p-3 bg-gray-100 dark:bg-gray-700 rounded-lg min-w-[200px] cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          onClick={() => props.onDownload?.()}
        >
          <div class={`w-10 h-10 rounded-lg ${getExtensionColor(props.fileName)} flex items-center justify-center text-white`}>
            {getFileIcon()}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
              {props.fileName}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {formatFileSize(props.fileSize)}
            </p>
          </div>
          <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
        </div>
      </Show>
      
      {/* Upload progress overlay */}
      <Show when={props.isUploading}>
        <div class="absolute inset-0 bg-black/60 flex flex-col items-center justify-center rounded-lg">
          {/* Progress bar */}
          <div class="w-3/4 h-1 bg-white/20 rounded-full overflow-hidden mb-2">
            <div 
              class="h-full bg-guardyn-500 transition-all duration-300"
              style={{ width: `${props.uploadProgress ?? 0}%` }}
            />
          </div>
          <span class="text-white text-sm">
            {props.uploadProgress ?? 0}%
          </span>
          
          {/* Cancel button */}
          <Show when={props.onCancelUpload}>
            <button
              onClick={() => props.onCancelUpload?.()}
              class="mt-2 text-white/70 hover:text-white text-xs underline"
            >
              Cancel
            </button>
          </Show>
        </div>
      </Show>
    </div>
  );
};

export default MediaAttachment;
