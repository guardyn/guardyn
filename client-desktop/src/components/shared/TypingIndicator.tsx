/**
 * TypingIndicator Component
 *
 * Shows animated dots to indicate that someone is typing.
 * Can display names of users who are typing.
 * Integrates with presenceStore for real-time typing data.
 */

import { Component, For, Show, createMemo } from 'solid-js';
import {
    createTypingMemo,
    formatTypingText,
    getTypingUserNames,
} from '../../stores/presenceStore';

// =============================================================================
// TYPES
// =============================================================================

export interface TypingIndicatorProps {
  /** Conversation ID to show typing for (reactive from store) */
  conversationId?: string;
  /** Names of users who are typing (manual override) */
  users?: string[];
  /** Whether to show the indicator (manual override) */
  isTyping?: boolean;
  /** Custom message instead of user names */
  message?: string;
  /** Size variant */
  size?: 'sm' | 'md';
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * TypingIndicator shows animated dots with optional user names.
 *
 * Can be used in two modes:
 * 1. With conversationId - automatically fetches typing users from store
 * 2. With users/isTyping - uses provided data directly
 *
 * @example
 * ```tsx
 * // From store (reactive)
 * <TypingIndicator conversationId="conv-123" />
 *
 * // Simple indicator
 * <TypingIndicator isTyping />
 *
 * // With user names
 * <TypingIndicator users={['Alice', 'Bob']} />
 *
 * // Custom message
 * <TypingIndicator isTyping message="Someone is typing..." />
 * ```
 */
export const TypingIndicator: Component<TypingIndicatorProps> = (props) => {
  // Create reactive typing memo if conversationId is provided
  const typingUsers = createMemo(() => {
    if (props.conversationId) {
      const typingMemo = createTypingMemo(props.conversationId);
      return typingMemo();
    }
    return [];
  });

  // Get user names from store or props
  const userNames = createMemo(() => {
    if (props.users && props.users.length > 0) {
      return props.users;
    }
    if (props.conversationId) {
      return getTypingUserNames(props.conversationId);
    }
    return [];
  });

  // Determine visibility
  const isVisible = createMemo(() => {
    if (props.isTyping !== undefined) {
      return props.isTyping;
    }
    if (props.users && props.users.length > 0) {
      return true;
    }
    if (props.conversationId) {
      return typingUsers().length > 0;
    }
    return false;
  });

  const size = () => props.size ?? 'md';

  const typingMessage = createMemo(() => {
    if (props.message) return props.message;

    // Use store's format function if conversationId is provided
    if (props.conversationId && !props.users) {
      const text = formatTypingText(props.conversationId);
      return text || 'Someone is typing...';
    }

    // Use provided users array
    const users = userNames();
    if (!users || users.length === 0) return 'Someone is typing...';

    if (users.length === 1) {
      return `${users[0]} is typing...`;
    } else if (users.length === 2) {
      return `${users[0]} and ${users[1]} are typing...`;
    } else {
      return `${users[0]} and ${users.length - 1} others are typing...`;
    }
  });

  const dotSize = () => (size() === 'sm' ? 'w-1.5 h-1.5' : 'w-2 h-2');
  const textSize = () => (size() === 'sm' ? 'text-xs' : 'text-sm');

  return (
    <Show when={isVisible()}>
      <div
        class={`
          inline-flex items-center gap-2
          text-gray-500 dark:text-gray-400
          ${textSize()}
          ${props.class ?? ''}
        `}
        role="status"
        aria-live="polite"
        aria-label={typingMessage()}
      >
        {/* Animated dots */}
        <div class="flex items-center gap-1">
          <For each={[0, 1, 2]}>
            {(index) => (
              <span
                class={`
                  ${dotSize()}
                  bg-gray-400 dark:bg-gray-500
                  rounded-full
                  animate-bounce
                `}
                style={{
                  'animation-delay': `${index * 0.15}s`,
                  'animation-duration': '0.6s',
                }}
              />
            )}
          </For>
        </div>

        {/* Typing message */}
        <span class="truncate max-w-[200px]">{typingMessage()}</span>
      </div>
    </Show>
  );
};

export default TypingIndicator;

