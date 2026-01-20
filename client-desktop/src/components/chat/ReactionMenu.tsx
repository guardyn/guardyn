/**
 * ReactionMenu Component
 * 
 * Context menu for message actions including reactions, reply, forward, and delete.
 * Triggered on right-click or long-press on messages.
 */

import { Component, createSignal, For, Show } from 'solid-js';
import { EmojiPicker } from './EmojiPicker';

// =============================================================================
// TYPES
// =============================================================================

export interface MessageAction {
  id: string;
  label: string;
  icon: string;
  onClick: () => void;
  destructive?: boolean;
}

export interface ReactionMenuProps {
  /** Whether the menu is visible */
  isOpen: boolean;
  /** Position of the menu */
  position: { x: number; y: number };
  /** The message ID this menu is for */
  messageId: string;
  /** Whether the message is from the current user */
  isOwnMessage: boolean;
  /** Callback when a reaction is added */
  onReaction: (emoji: string) => void;
  /** Callback when reply is clicked */
  onReply?: () => void;
  /** Callback when forward is clicked */
  onForward?: () => void;
  /** Callback when copy is clicked */
  onCopy?: () => void;
  /** Callback when delete is clicked */
  onDelete?: () => void;
  /** Callback when menu is closed */
  onClose: () => void;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const QUICK_REACTIONS = ['👍', '❤️', '😂', '😮', '😢', '😡'];

// =============================================================================
// ICONS
// =============================================================================

const ReplyIcon = () => (
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6" />
  </svg>
);

const ForwardIcon = () => (
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 10h-10a8 8 0 00-8 8v2M21 10l-6 6m6-6l-6-6" />
  </svg>
);

const CopyIcon = () => (
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
  </svg>
);

const DeleteIcon = () => (
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
  </svg>
);

const PlusIcon = () => (
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
  </svg>
);

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * ReactionMenu provides a context menu for message actions.
 * 
 * @example
 * ```tsx
 * <ReactionMenu
 *   isOpen={showMenu()}
 *   position={{ x: mouseX, y: mouseY }}
 *   messageId="msg-123"
 *   isOwnMessage={true}
 *   onReaction={(emoji) => addReaction(messageId, emoji)}
 *   onReply={() => setReplyTo(messageId)}
 *   onCopy={() => copyToClipboard(messageContent)}
 *   onDelete={() => deleteMessage(messageId)}
 *   onClose={() => setShowMenu(false)}
 * />
 * ```
 */
export const ReactionMenu: Component<ReactionMenuProps> = (props) => {
  const [showEmojiPicker, setShowEmojiPicker] = createSignal(false);

  const handleReactionClick = (emoji: string) => {
    props.onReaction(emoji);
    props.onClose();
  };

  const handleAction = (action: (() => void) | undefined) => {
    if (action) {
      action();
    }
    props.onClose();
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      if (showEmojiPicker()) {
        setShowEmojiPicker(false);
      } else {
        props.onClose();
      }
    }
  };

  // Calculate menu position to keep it within viewport
  const getMenuStyle = () => {
    const menuWidth = 280;
    const menuHeight = 180;
    const padding = 16;
    
    let x = props.position.x;
    let y = props.position.y;
    
    // Adjust horizontal position
    if (x + menuWidth > window.innerWidth - padding) {
      x = window.innerWidth - menuWidth - padding;
    }
    if (x < padding) {
      x = padding;
    }
    
    // Adjust vertical position
    if (y + menuHeight > window.innerHeight - padding) {
      y = props.position.y - menuHeight;
    }
    if (y < padding) {
      y = padding;
    }
    
    return {
      left: `${x}px`,
      top: `${y}px`,
    };
  };

  return (
    <Show when={props.isOpen}>
      {/* Backdrop */}
      <div 
        class="fixed inset-0 z-40"
        onClick={() => props.onClose()}
        onKeyDown={handleKeyDown}
        tabIndex={-1}
      />
      
      {/* Menu container */}
      <div
        class="
          fixed z-50 min-w-[280px]
          bg-white dark:bg-gray-800 rounded-xl shadow-xl
          border border-gray-200 dark:border-gray-700
          backdrop-blur-lg bg-opacity-95 dark:bg-opacity-95
          animate-in fade-in zoom-in-95 duration-150
          overflow-hidden
        "
        style={getMenuStyle()}
        onKeyDown={handleKeyDown}
      >
        {/* Quick reactions row */}
        <div class="flex items-center gap-1 p-2 border-b border-gray-100 dark:border-gray-700">
          <For each={QUICK_REACTIONS}>
            {(emoji) => (
              <button
                onClick={() => handleReactionClick(emoji)}
                class="
                  w-9 h-9 flex items-center justify-center text-lg
                  rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
                  transition-all duration-150
                  hover:scale-110 active:scale-95
                "
                title={`React with ${emoji}`}
              >
                {emoji}
              </button>
            )}
          </For>
          
          {/* More emojis button */}
          <button
            onClick={() => setShowEmojiPicker(true)}
            class="
              w-9 h-9 flex items-center justify-center
              rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
              transition-all duration-150 text-gray-500 dark:text-gray-400
            "
            title="More reactions"
          >
            <PlusIcon />
          </button>
        </div>

        {/* Action buttons */}
        <div class="p-1">
          {/* Reply */}
          <Show when={props.onReply}>
            <button
              onClick={() => handleAction(props.onReply)}
              class="
                w-full flex items-center gap-3 px-3 py-2
                rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
                text-gray-700 dark:text-gray-300
                transition-colors duration-150
              "
            >
              <ReplyIcon />
              <span class="text-sm font-medium">Reply</span>
            </button>
          </Show>

          {/* Forward */}
          <Show when={props.onForward}>
            <button
              onClick={() => handleAction(props.onForward)}
              class="
                w-full flex items-center gap-3 px-3 py-2
                rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
                text-gray-700 dark:text-gray-300
                transition-colors duration-150
              "
            >
              <ForwardIcon />
              <span class="text-sm font-medium">Forward</span>
            </button>
          </Show>

          {/* Copy */}
          <Show when={props.onCopy}>
            <button
              onClick={() => handleAction(props.onCopy)}
              class="
                w-full flex items-center gap-3 px-3 py-2
                rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700
                text-gray-700 dark:text-gray-300
                transition-colors duration-150
              "
            >
              <CopyIcon />
              <span class="text-sm font-medium">Copy text</span>
            </button>
          </Show>

          {/* Delete (only for own messages) */}
          <Show when={props.isOwnMessage && props.onDelete}>
            <div class="border-t border-gray-100 dark:border-gray-700 mt-1 pt-1">
              <button
                onClick={() => handleAction(props.onDelete)}
                class="
                  w-full flex items-center gap-3 px-3 py-2
                  rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20
                  text-red-600 dark:text-red-400
                  transition-colors duration-150
                "
              >
                <DeleteIcon />
                <span class="text-sm font-medium">Delete</span>
              </button>
            </div>
          </Show>
        </div>
      </div>

      {/* Full emoji picker (shown when clicking +) */}
      <EmojiPicker
        isOpen={showEmojiPicker()}
        position={{ x: props.position.x, y: props.position.y - 60 }}
        onSelect={(emoji) => {
          handleReactionClick(emoji);
          setShowEmojiPicker(false);
        }}
        onClose={() => setShowEmojiPicker(false)}
      />
    </Show>
  );
};

export default ReactionMenu;
