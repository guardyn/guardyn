/**
 * EmojiPicker Component
 * 
 * A compact emoji picker for message reactions.
 * Displays common reaction emojis with quick selection.
 */

import { Component, createSignal, For, Show } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface EmojiPickerProps {
  /** Callback when an emoji is selected */
  onSelect: (emoji: string) => void;
  /** Callback when picker is closed */
  onClose: () => void;
  /** Whether the picker is visible */
  isOpen: boolean;
  /** Position relative to the target element */
  position?: { x: number; y: number };
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

// Common reaction emojis - quick access row
const QUICK_REACTIONS = ['👍', '❤️', '😂', '😮', '😢', '😡'];

// Emoji categories for full picker
const EMOJI_CATEGORIES = {
  'Smileys': ['😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮', '🤧', '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '🥸', '😎', '🤓', '🧐'],
  'Gestures': ['👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞', '🤟', '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', '👍', '👎', '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🤲', '🤝', '🙏', '💪', '🦾', '🦿', '🦵', '🦶'],
  'Hearts': ['❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝', '💟'],
  'Objects': ['🎉', '🎊', '🎈', '🎁', '🏆', '🥇', '🥈', '🥉', '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🎮', '🎲', '🎯', '🎪', '🎭', '🎨', '🎬', '🎤', '🎧', '🎵', '🎶', '🎹', '🎸', '🎺', '🎻', '🪘'],
  'Symbols': ['💯', '✅', '❌', '❓', '❗', '💤', '💥', '💫', '💦', '💨', '🕳️', '💣', '💬', '👁️‍🗨️', '🗨️', '🗯️', '💭', '🔥', '⭐', '🌟', '✨', '⚡', '☀️', '🌈', '☁️', '❄️', '💧', '🌊'],
};

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * EmojiPicker provides a UI for selecting emojis for message reactions.
 * 
 * @example
 * ```tsx
 * <EmojiPicker
 *   isOpen={showPicker()}
 *   onSelect={(emoji) => addReaction(messageId, emoji)}
 *   onClose={() => setShowPicker(false)}
 *   position={{ x: 100, y: 200 }}
 * />
 * ```
 */
export const EmojiPicker: Component<EmojiPickerProps> = (props) => {
  const [activeCategory, setActiveCategory] = createSignal<keyof typeof EMOJI_CATEGORIES>('Smileys');
  const [showFullPicker, setShowFullPicker] = createSignal(false);

  const handleEmojiClick = (emoji: string) => {
    props.onSelect(emoji);
    props.onClose();
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      props.onClose();
    }
  };

  return (
    <Show when={props.isOpen}>
      {/* Backdrop */}
      <div 
        class="fixed inset-0 z-40"
        onClick={() => props.onClose()}
        onKeyDown={handleKeyDown}
      />
      
      {/* Picker container */}
      <div
        class={`
          fixed z-50 bg-white dark:bg-gray-800 rounded-xl shadow-lg
          border border-gray-200 dark:border-gray-700
          backdrop-blur-lg bg-opacity-95 dark:bg-opacity-95
          animate-in fade-in zoom-in-95 duration-150
          ${props.class ?? ''}
        `}
        style={{
          left: `${props.position?.x ?? 0}px`,
          top: `${props.position?.y ?? 0}px`,
          transform: 'translate(-50%, -100%)',
        }}
      >
        {/* Quick reactions row */}
        <div class="flex gap-1 p-2 border-b border-gray-200 dark:border-gray-700">
          <For each={QUICK_REACTIONS}>
            {(emoji) => (
              <button
                onClick={() => handleEmojiClick(emoji)}
                class="
                  w-10 h-10 flex items-center justify-center text-xl
                  rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
                  transition-all duration-150
                  hover:scale-110 active:scale-95
                "
                title={emoji}
              >
                {emoji}
              </button>
            )}
          </For>
          
          {/* Expand button */}
          <button
            onClick={() => setShowFullPicker(!showFullPicker())}
            class="
              w-10 h-10 flex items-center justify-center
              rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
              transition-all duration-150 text-gray-500 dark:text-gray-400
            "
            title={showFullPicker() ? 'Show less' : 'More emojis'}
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <Show
                when={showFullPicker()}
                fallback={
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                }
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" />
              </Show>
            </svg>
          </button>
        </div>

        {/* Full picker (expandable) */}
        <Show when={showFullPicker()}>
          <div class="max-h-64 overflow-hidden">
            {/* Category tabs */}
            <div class="flex gap-1 p-2 border-b border-gray-200 dark:border-gray-700 overflow-x-auto scrollbar-hide">
              <For each={Object.keys(EMOJI_CATEGORIES) as (keyof typeof EMOJI_CATEGORIES)[]}>
                {(category) => (
                  <button
                    onClick={() => setActiveCategory(category)}
                    class={`
                      px-3 py-1.5 text-xs font-medium rounded-lg whitespace-nowrap
                      transition-colors duration-150
                      ${activeCategory() === category
                        ? 'bg-guardyn-100 dark:bg-guardyn-900/30 text-guardyn-700 dark:text-guardyn-300'
                        : 'text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700'
                      }
                    `}
                  >
                    {category}
                  </button>
                )}
              </For>
            </div>

            {/* Emoji grid */}
            <div class="p-2 max-h-48 overflow-y-auto scrollbar-thin scrollbar-thumb-gray-300 dark:scrollbar-thumb-gray-600">
              <div class="grid grid-cols-8 gap-1">
                <For each={EMOJI_CATEGORIES[activeCategory()]}>
                  {(emoji) => (
                    <button
                      onClick={() => handleEmojiClick(emoji)}
                      class="
                        w-8 h-8 flex items-center justify-center text-lg
                        rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
                        transition-all duration-100
                        hover:scale-110 active:scale-95
                      "
                    >
                      {emoji}
                    </button>
                  )}
                </For>
              </div>
            </div>
          </div>
        </Show>
      </div>
    </Show>
  );
};

export default EmojiPicker;
