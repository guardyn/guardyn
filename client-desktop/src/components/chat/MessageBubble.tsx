/**
 * MessageBubble Component
 * 
 * Displays a single message in the chat with glassmorphism styling.
 * Supports sent and received message states, reactions, and read receipts.
 */

import { Component, Show, For } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface MessageReaction {
  emoji: string;
  count: number;
  hasReacted: boolean;
}

export interface MessageBubbleProps {
  /** Message content */
  content: string;
  /** Message timestamp */
  timestamp: Date | string;
  /** Whether this message was sent by the current user */
  isOwn: boolean;
  /** Sender name (for received messages) */
  senderName?: string;
  /** Sender avatar URL */
  senderAvatar?: string;
  /** Whether to show the avatar */
  showAvatar?: boolean;
  /** Message reactions */
  reactions?: MessageReaction[];
  /** Whether the message has been read */
  isRead?: boolean;
  /** Whether the message is being sent */
  isSending?: boolean;
  /** Callback when reaction is clicked */
  onReactionClick?: (emoji: string) => void;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// ICONS
// =============================================================================

const CheckIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-3 h-3'}
  >
    <polyline points="20 6 9 17 4 12" />
  </svg>
);

const DoubleCheckIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-3 h-3'}
  >
    <polyline points="18 6 7 17 2 12" />
    <polyline points="22 10 11 21 6 16" />
  </svg>
);

// =============================================================================
// HELPERS
// =============================================================================

function formatTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
}

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * MessageBubble displays a chat message with styling based on sender.
 * 
 * @example
 * ```tsx
 * // Own message
 * <MessageBubble
 *   content="Hello!"
 *   timestamp={new Date()}
 *   isOwn
 *   isRead
 * />
 * 
 * // Received message with avatar
 * <MessageBubble
 *   content="Hi there!"
 *   timestamp={new Date()}
 *   isOwn={false}
 *   senderName="Alice"
 *   showAvatar
 * />
 * ```
 */
export const MessageBubble: Component<MessageBubbleProps> = (props) => {
  const bubbleClass = () => {
    const base = 'message-bubble';
    const variant = props.isOwn ? 'message-bubble-sent' : 'message-bubble-received';
    const sending = props.isSending ? 'opacity-70' : '';
    return `${base} ${variant} ${sending} ${props.class ?? ''}`.trim();
  };

  return (
    <div
      class={`flex ${props.isOwn ? 'justify-end' : 'justify-start'} ${
        props.showAvatar ? 'items-end gap-2' : ''
      }`}
    >
      {/* Avatar for received messages */}
      <Show when={!props.isOwn && props.showAvatar}>
        <div class="flex-shrink-0 mb-1">
          <Show
            when={props.senderAvatar}
            fallback={
              <div class="w-8 h-8 rounded-full bg-gradient-to-br from-guardyn-400 to-guardyn-600 flex items-center justify-center text-white text-xs font-medium shadow-md">
                {getInitials(props.senderName || 'User')}
              </div>
            }
          >
            <img
              src={props.senderAvatar}
              alt={props.senderName}
              class="w-8 h-8 rounded-full object-cover shadow-md"
            />
          </Show>
        </div>
      </Show>

      <div class="max-w-[70%]">
        {/* Sender name for group chats */}
        <Show when={!props.isOwn && props.senderName && props.showAvatar}>
          <p class="text-xs text-gray-500 dark:text-gray-400 mb-1 ml-1">
            {props.senderName}
          </p>
        </Show>

        {/* Message bubble */}
        <div class={bubbleClass()}>
          <p class="whitespace-pre-wrap break-words">{props.content}</p>
          
          {/* Timestamp and read status */}
          <div class="flex items-center justify-end gap-1 mt-1">
            <span class="text-xs opacity-70">
              {formatTime(props.timestamp)}
            </span>
            <Show when={props.isOwn}>
              <Show
                when={props.isRead}
                fallback={<CheckIcon class="w-3 h-3 opacity-70" />}
              >
                <DoubleCheckIcon class="w-3 h-3 text-blue-400" />
              </Show>
            </Show>
          </div>
        </div>

        {/* Reactions */}
        <Show when={props.reactions && props.reactions.length > 0}>
          <div class="flex flex-wrap gap-1 mt-1">
            <For each={props.reactions}>
              {(reaction) => (
                <button
                  onClick={() => props.onReactionClick?.(reaction.emoji)}
                  class={`
                    inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs
                    transition-all duration-200
                    ${reaction.hasReacted
                      ? 'bg-guardyn-100 dark:bg-guardyn-900/30 border border-guardyn-300 dark:border-guardyn-700'
                      : 'bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600'
                    }
                    hover:scale-105 active:scale-95
                  `}
                >
                  <span>{reaction.emoji}</span>
                  <span class="text-gray-600 dark:text-gray-300">{reaction.count}</span>
                </button>
              )}
            </For>
          </div>
        </Show>
      </div>
    </div>
  );
};

export default MessageBubble;
