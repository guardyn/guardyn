/**
 * MessageInput Component
 * 
 * Input field for composing and sending messages.
 * Includes emoji picker, attachment button, and neumorphic send button.
 */

import { Component, createSignal, Show, For } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface MessageInputProps {
  /** Callback when message is sent */
  onSend: (content: string) => void;
  /** Callback when user is typing */
  onTyping?: () => void;
  /** Whether input is disabled */
  disabled?: boolean;
  /** Placeholder text */
  placeholder?: string;
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

  // Common emojis for quick access
  const quickEmojis = ['😀', '😂', '❤️', '👍', '👎', '🎉', '🔥', '✨'];

  const handleSubmit = (e: Event) => {
    e.preventDefault();
    const message = content().trim();
    if (!message || props.disabled) return;
    
    props.onSend(message);
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

  return (
    <form
      onSubmit={handleSubmit}
      class={`relative ${props.class ?? ''}`}
    >
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
        {/* Attachment button with neumorphic style */}
        <button
          type="button"
          disabled={props.disabled}
          aria-label="Add attachment"
          class="neumorphic-icon-btn focus-ring text-gray-500 dark:text-gray-400 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <AttachmentIcon />
        </button>

        {/* Input field */}
        <div class="flex-1 relative">
          <textarea
            value={content()}
            onInput={(e) => handleInput(e.currentTarget.value)}
            onKeyDown={handleKeyDown}
            placeholder={props.placeholder ?? 'Type a message...'}
            disabled={props.disabled}
            rows={1}
            class="w-full px-4 py-3 pr-12 bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:ring-offset-1 focus:border-transparent resize-none disabled:opacity-50 transition-all"
            style={{ "max-height": "120px" }}
          />
          
          {/* Emoji button with hover effect */}
          <button
            type="button"
            onClick={() => setShowEmojiPicker(!showEmojiPicker())}
            disabled={props.disabled}
            aria-label="Add emoji"
            class="absolute right-3 top-1/2 -translate-y-1/2 p-1.5 rounded-full text-gray-500 dark:text-gray-400 hover:text-guardyn-600 dark:hover:text-guardyn-500 hover:bg-gray-200 dark:hover:bg-gray-600 focus-ring transition-all disabled:opacity-50"
          >
            <EmojiIcon />
          </button>
        </div>

        {/* Send button with neumorphic style */}
        <button
          type="submit"
          disabled={!content().trim() || props.disabled}
          aria-label="Send message"
          class={`
            p-3 rounded-xl text-white focus-ring
            transition-all duration-200
            ${content().trim() && !props.disabled
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
