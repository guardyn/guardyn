/**
 * MediaPicker Component
 *
 * File picker with native dialog integration for selecting media files.
 * Supports multiple file selection, drag-and-drop, and file type filtering.
 */

import { open } from '@tauri-apps/plugin-dialog';
import { Component, createSignal, JSX, Show } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type MediaPickerMode = 'all' | 'images' | 'videos' | 'documents' | 'audio';

export interface MediaPickerProps {
  /** Callback when files are selected */
  onSelect: (files: string[]) => void;
  /** Filter mode for file types */
  mode?: MediaPickerMode;
  /** Allow multiple file selection */
  multiple?: boolean;
  /** Whether picker is disabled */
  disabled?: boolean;
  /** Custom button content */
  children?: JSX.Element;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const FILE_FILTERS: Record<MediaPickerMode, { name: string; extensions: string[] }[]> = {
  all: [
    { name: 'Images', extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'] },
    { name: 'Videos', extensions: ['mp4', 'webm', 'mov', 'avi', 'mkv'] },
    { name: 'Audio', extensions: ['mp3', 'wav', 'ogg', 'flac', 'aac', 'm4a'] },
    { name: 'Documents', extensions: ['pdf', 'doc', 'docx', 'txt', 'rtf', 'xls', 'xlsx', 'ppt', 'pptx'] },
    { name: 'All Files', extensions: ['*'] },
  ],
  images: [
    { name: 'Images', extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'] },
  ],
  videos: [
    { name: 'Videos', extensions: ['mp4', 'webm', 'mov', 'avi', 'mkv'] },
  ],
  audio: [
    { name: 'Audio', extensions: ['mp3', 'wav', 'ogg', 'flac', 'aac', 'm4a'] },
  ],
  documents: [
    { name: 'Documents', extensions: ['pdf', 'doc', 'docx', 'txt', 'rtf', 'xls', 'xlsx', 'ppt', 'pptx'] },
  ],
};

// =============================================================================
// ICONS
// =============================================================================

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

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * MediaPicker provides a native file dialog for selecting media files.
 *
 * @example
 * ```tsx
 * // Basic usage
 * <MediaPicker onSelect={(files) => console.log('Selected:', files)} />
 *
 * // Images only
 * <MediaPicker mode="images" onSelect={handleSelect} />
 *
 * // Custom button
 * <MediaPicker onSelect={handleSelect}>
 *   <span>Upload Files</span>
 * </MediaPicker>
 * ```
 */
export const MediaPicker: Component<MediaPickerProps> = (props) => {
  const [isOpening, setIsOpening] = createSignal(false);

  const mode = () => props.mode ?? 'all';
  const multiple = () => props.multiple ?? true;

  const handleClick = async () => {
    if (props.disabled || isOpening()) return;

    setIsOpening(true);
    try {
      const result = await open({
        multiple: multiple(),
        filters: FILE_FILTERS[mode()],
        title: 'Select Files',
      });

      if (result) {
        const files = Array.isArray(result) ? result : [result];
        if (files.length > 0) {
          props.onSelect(files);
        }
      }
    } catch (error) {
      console.error('Failed to open file picker:', error);
    } finally {
      setIsOpening(false);
    }
  };

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={props.disabled || isOpening()}
      class={`
        p-2 rounded-lg transition-colors
        text-gray-500 dark:text-gray-400
        hover:bg-gray-100 dark:hover:bg-gray-700
        hover:text-gray-700 dark:hover:text-gray-300
        disabled:opacity-50 disabled:cursor-not-allowed
        ${props.class ?? ''}
      `}
      aria-label="Attach file"
    >
      <Show when={props.children} fallback={<AttachmentIcon />}>
        {props.children}
      </Show>
    </button>
  );
};

export default MediaPicker;
