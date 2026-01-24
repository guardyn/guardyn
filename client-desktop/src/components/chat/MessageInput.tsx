/**
 * MessageInput Component
 * 
 * Input field for composing and sending messages.
 * Includes emoji picker, attachment button with media picker, and neumorphic send button.
 */

import { stat } from '@tauri-apps/plugin-fs';
import { Component, createSignal, For, Show } from 'solid-js';
import { mediaTypeFromMime, uploadMedia, type MediaType } from '../../api/media';
import { MediaPicker, UploadProgress, type UploadItem } from '../media';

// =============================================================================
// TYPES
// =============================================================================

export interface MessageInputProps {
  /** Callback when message is sent */
  onSend: (content: string, mediaId?: string) => void;
  /** Callback when user is typing */
  onTyping?: () => void;
  /** Whether input is disabled */
  disabled?: boolean;
  /** Placeholder text */
  placeholder?: string;
  /** Conversation ID for media uploads */
  conversationId?: string;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// ICONS
// =============================================================================

const SendIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-5 h-5'}
  >
    <path d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
  </svg>
);

const EmojiIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-5 h-5'}
  >
    <circle cx="12" cy="12" r="10" />
    <path d="M8 14s1.5 2 4 2 4-2 4-2" />
    <line x1="9" y1="9" x2="9.01" y2="9" />
    <line x1="15" y1="9" x2="15.01" y2="9" />
  </svg>
);

const AttachmentIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-5 h-5'}
  >
    <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48" />
  </svg>
);

const CloseIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-4 h-4'}
  >
    <line x1="18" y1="6" x2="6" y2="18" />
    <line x1="6" y1="6" x2="18" y2="18" />
  </svg>
);

// =============================================================================
// HELPERS
// =============================================================================

function getFilename(filePath: string): string {
  const parts = filePath.split(/[/\\]/);
  return parts[parts.length - 1] || 'file';
}

function getMimeType(filename: string): string {
  const ext = filename.split('.').pop()?.toLowerCase() ?? '';
  const mimeTypes: Record<string, string> = {
    // Images
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    png: 'image/png',
    gif: 'image/gif',
    webp: 'image/webp',
    bmp: 'image/bmp',
    svg: 'image/svg+xml',
    // Videos
    mp4: 'video/mp4',
    webm: 'video/webm',
    mov: 'video/quicktime',
    avi: 'video/x-msvideo',
    mkv: 'video/x-matroska',
    // Audio
    mp3: 'audio/mpeg',
    wav: 'audio/wav',
    ogg: 'audio/ogg',
    flac: 'audio/flac',
    aac: 'audio/aac',
    m4a: 'audio/mp4',
    // Documents
    pdf: 'application/pdf',
    doc: 'application/msword',
    docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    txt: 'text/plain',
    rtf: 'application/rtf',
    xls: 'application/vnd.ms-excel',
    xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ppt: 'application/vnd.ms-powerpoint',
    pptx: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  };
  return mimeTypes[ext] || 'application/octet-stream';
}

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * MessageInput provides a rich text input for composing messages.
 * 
 * @example
 * ```tsx
 * <MessageInput
 *   onSend={(content) => console.log('Send:', content)}
 *   onTyping={() => console.log('User is typing')}
 *   placeholder="Type a message..."
 * />
 * ```
 */
export const MessageInput: Component<MessageInputProps> = (props) => {
  const [content, setContent] = createSignal('');
  const [showEmojiPicker, setShowEmojiPicker] = createSignal(false);
  const [pendingFiles, setPendingFiles] = createSignal<Array<{
    id: string;
    filePath: string;
    filename: string;
    mimeType: string;
    size: number;
    type: MediaType;
  }>>([]);
  const [uploadItems, setUploadItems] = createSignal<UploadItem[]>([]);
  const [isUploading, setIsUploading] = createSignal(false);

  // Common emojis for quick access
  const quickEmojis = ['😀', '😂', '❤️', '👍', '👎', '🎉', '🔥', '✨'];

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    const message = content().trim();
    const files = pendingFiles();
    
    if (!message && files.length === 0) return;
    if (props.disabled || isUploading()) return;
    
    // If there are files to upload, handle them first
    if (files.length > 0) {
      setIsUploading(true);
      
      try {
        for (const file of files) {
          // Update upload status to uploading
          setUploadItems((items) => items.map((item) =>
            item.id === file.id ? { ...item, status: 'uploading' as const, uploadedBytes: 0 } : item
          ));
          
          // Upload the file
          const mediaId = await uploadMedia(
            file.filePath,
            file.filename,
            file.mimeType,
            file.size,
            props.conversationId
          );
          
          // Update status to completed
          setUploadItems((items) => items.map((item) =>
            item.id === file.id ? { ...item, status: 'completed' as const, uploadedBytes: item.totalBytes } : item
          ));
          
          // Send message with media
          props.onSend(message || file.filename, mediaId);
        }
      } catch (error) {
        console.error('Failed to upload media:', error);
        setUploadItems((items) => items.map((item) => ({
          ...item,
          status: 'failed' as const,
          error: error instanceof Error ? error.message : 'Upload failed',
        })));
      } finally {
        setIsUploading(false);
        setPendingFiles([]);
        setUploadItems([]);
      }
    } else {
      // Just send text message
      props.onSend(message);
    }
    
    setContent('');
  };

  const handleInput = (value: string) => {
    setContent(value);
    props.onTyping?.();
  };

  const insertEmoji = (emoji: string) => {
    setContent((prev) => prev + emoji);
    setShowEmojiPicker(false);
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  const handleFilesSelected = async (files: string[]) => {
    const newFiles: typeof pendingFiles extends () => infer T ? T : never = [];
    const newUploadItems: UploadItem[] = [];
    
    for (const filePath of files) {
      const filename = getFilename(filePath);
      const mimeType = getMimeType(filename);
      const type = mediaTypeFromMime(mimeType);
      const id = crypto.randomUUID();
      
      // Get file size
      let size = 0;
      try {
        const fileStat = await stat(filePath);
        size = fileStat.size;
      } catch {
        size = 0;
      }
      
      newFiles.push({ id, filePath, filename, mimeType, size, type });
      newUploadItems.push({
        id,
        filename,
        totalBytes: size,
        uploadedBytes: 0,
        status: 'pending',
      });
    }
    
    setPendingFiles((prev) => [...prev, ...newFiles]);
    setUploadItems((prev) => [...prev, ...newUploadItems]);
  };

  const handleRemoveFile = (id: string) => {
    setPendingFiles((files) => files.filter((f) => f.id !== id));
    setUploadItems((items) => items.filter((i) => i.id !== id));
  };

  const handleCancelUpload = (id: string) => {
    // For now, just remove from the list
    handleRemoveFile(id);
  };

  const hasPendingContent = () => content().trim() !== '' || pendingFiles().length > 0;

  return (
    <form
      onSubmit={handleSubmit}
      class={`relative ${props.class ?? ''}`}
    >
      {/* Upload progress overlay */}
      <Show when={uploadItems().length > 0}>
        <div class="absolute bottom-full left-0 right-0 mb-2">
          <UploadProgress
            items={uploadItems()}
            onCancel={handleCancelUpload}
            onRetry={() => {}}
          />
        </div>
      </Show>

      {/* Pending files preview */}
      <Show when={pendingFiles().length > 0 && !isUploading()}>
        <div class="flex flex-wrap gap-2 mb-2 p-2 bg-gray-50 dark:bg-gray-800 rounded-lg">
          <For each={pendingFiles()}>
            {(file) => (
              <div class="flex items-center gap-2 px-3 py-1.5 bg-white dark:bg-gray-700 rounded-full border border-gray-200 dark:border-gray-600">
                <span class="text-sm text-gray-700 dark:text-gray-300 max-w-32 truncate">
                  {file.filename}
                </span>
                <button
                  type="button"
                  onClick={() => handleRemoveFile(file.id)}
                  class="p-0.5 rounded-full hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
                >
                  <CloseIcon class="w-3 h-3" />
                </button>
              </div>
            )}
          </For>
        </div>
      </Show>

      {/* Emoji picker popup */}
      <Show when={showEmojiPicker()}>
        <div class="absolute bottom-full left-0 mb-2 p-2 bg-white dark:bg-gray-800 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700 z-10">
          <div class="flex gap-2">
            <For each={quickEmojis}>
              {(emoji) => (
                <button
                  type="button"
                  onClick={() => insertEmoji(emoji)}
                  class="text-xl hover:scale-125 transition-transform p-1"
                >
                  {emoji}
                </button>
              )}
            </For>
          </div>
        </div>
      </Show>

      <div class="flex items-end gap-2">
        {/* Attachment button with MediaPicker */}
        <MediaPicker
          onSelect={handleFilesSelected}
          mode="all"
          multiple
          disabled={props.disabled || isUploading()}
          class="neumorphic-icon-btn focus-ring text-gray-500 dark:text-gray-400 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <AttachmentIcon />
        </MediaPicker>

        {/* Input field */}
        <div class="flex-1 relative">
          <textarea
            value={content()}
            onInput={(e) => handleInput(e.currentTarget.value)}
            onKeyDown={handleKeyDown}
            placeholder={props.placeholder ?? 'Type a message...'}
            disabled={props.disabled || isUploading()}
            rows={1}
            class="w-full px-4 py-3 pr-12 bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:ring-offset-1 focus:border-transparent resize-none disabled:opacity-50 transition-all"
            style={{ "max-height": "120px" }}
          />
          
          {/* Emoji button with hover effect */}
          <button
            type="button"
            onClick={() => setShowEmojiPicker(!showEmojiPicker())}
            disabled={props.disabled || isUploading()}
            aria-label="Add emoji"
            class="absolute right-3 top-1/2 -translate-y-1/2 p-1.5 rounded-full text-gray-500 dark:text-gray-400 hover:text-guardyn-600 dark:hover:text-guardyn-500 hover:bg-gray-200 dark:hover:bg-gray-600 focus-ring transition-all disabled:opacity-50"
          >
            <EmojiIcon />
          </button>
        </div>

        {/* Send button with neumorphic style */}
        <button
          type="submit"
          disabled={!hasPendingContent() || props.disabled || isUploading()}
          aria-label="Send message"
          class={`
            p-3 rounded-xl text-white focus-ring
            transition-all duration-200
            ${hasPendingContent() && !props.disabled && !isUploading()
              ? 'neumorphic-btn-primary cursor-pointer'
              : 'bg-gray-300 dark:bg-gray-600 cursor-not-allowed opacity-50'
            }
          `}
        >
          <SendIcon />
        </button>
      </div>
    </form>
  );
};

export default MessageInput;
