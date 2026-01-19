/**
 * TypingIndicator Component
 * 
 * Shows animated dots to indicate that someone is typing.
 * Optionally displays names of users who are typing.
 */

import { Component, For, Show, createMemo } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface TypingIndicatorProps {
  /** Names of users who are typing */
  users?: string[];
  /** Whether to show the indicator */
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
 * @example
 * ```tsx
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
  const isVisible = () => props.isTyping || (props.users && props.users.length > 0);
  const size = () => props.size ?? 'md';

  const typingMessage = createMemo(() => {
    if (props.message) return props.message;
    if (!props.users || props.users.length === 0) return 'Someone is typing';
    
    if (props.users.length === 1) {
      return `${props.users[0]} is typing`;
    } else if (props.users.length === 2) {
      return `${props.users[0]} and ${props.users[1]} are typing`;
    } else {
      return `${props.users[0]} and ${props.users.length - 1} others are typing`;
    }
  });

  const dotSize = () => size() === 'sm' ? 'w-1.5 h-1.5' : 'w-2 h-2';
  const textSize = () => size() === 'sm' ? 'text-xs' : 'text-sm';

  return (
    <Show when={isVisible()}>
      <div
        class={`
          inline-flex items-center gap-2
          text-gray-500 dark:text-gray-400
          ${textSize()}
          ${props.class ?? ''}
        `}
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
                  "animation-delay": `${index * 0.15}s`,
                  "animation-duration": "0.6s",
                }}
              />
            )}
          </For>
        </div>

        {/* Typing message */}
        <span>{typingMessage()}</span>
      </div>
    </Show>
  );
};

export default TypingIndicator;
