/**
 * QuotedMessage Component
 * 
 * Displays a quoted/replied-to message preview.
 * Used in message bubbles and message input.
 */

import { Component, Show } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface QuotedMessageProps {
  /** Sender name of the original message */
  senderName: string;
  /** Preview text of the original message */
  preview: string;
  /** Whether the original message was sent by the current user */
  isOwnMessage?: boolean;
  /** Callback when the quote is clicked (to scroll to original) */
  onClick?: () => void;
  /** Callback when dismiss/close is clicked */
  onDismiss?: () => void;
  /** Variant: 'bubble' for in-message, 'input' for reply composer */
  variant?: 'bubble' | 'input';
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * QuotedMessage displays a preview of a replied-to message.
 * 
 * @example
 * ```tsx
 * // In message bubble
 * <QuotedMessage
 *   senderName="Alice"
 *   preview="Hey, did you see the..."
 *   onClick={() => scrollToMessage(replyToId)}
 *   variant="bubble"
 * />
 * 
 * // In reply composer
 * <QuotedMessage
 *   senderName="Bob"
 *   preview="I'll check it tomorrow"
 *   onDismiss={() => clearReply()}
 *   variant="input"
 * />
 * ```
 */
export const QuotedMessage: Component<QuotedMessageProps> = (props) => {
  const variant = () => props.variant ?? 'bubble';
  
  const containerClass = () => {
    const base = 'flex items-start gap-2 rounded-lg overflow-hidden transition-colors duration-150';
    
    if (variant() === 'input') {
      return `${base} bg-gray-100 dark:bg-gray-700 p-2 border-l-4 border-guardyn-500`;
    }
    
    // Bubble variant
    return `${base} bg-gray-50/50 dark:bg-gray-800/50 p-2 mb-2 border-l-2 border-guardyn-400 dark:border-guardyn-600 cursor-pointer hover:bg-gray-100/50 dark:hover:bg-gray-700/50`;
  };

  return (
    <div 
      class={`${containerClass()} ${props.class ?? ''}`}
      onClick={() => props.onClick?.()}
      role={props.onClick ? 'button' : undefined}
      tabIndex={props.onClick ? 0 : undefined}
    >
      {/* Quote indicator line is handled by border-l */}
      
      {/* Content */}
      <div class="flex-1 min-w-0">
        <p class={`text-xs font-medium truncate ${
          props.isOwnMessage 
            ? 'text-guardyn-600 dark:text-guardyn-400'
            : 'text-gray-600 dark:text-gray-400'
        }`}>
          {props.isOwnMessage ? 'You' : props.senderName}
        </p>
        <p class="text-sm text-gray-500 dark:text-gray-400 truncate">
          {props.preview}
        </p>
      </div>

      {/* Dismiss button (only for input variant) */}
      <Show when={variant() === 'input' && props.onDismiss}>
        <button
          onClick={(e) => {
            e.stopPropagation();
            props.onDismiss?.();
          }}
          class="
            flex-shrink-0 p-1 rounded-full
            text-gray-400 hover:text-gray-600
            dark:text-gray-500 dark:hover:text-gray-300
            hover:bg-gray-200 dark:hover:bg-gray-600
            transition-colors duration-150
          "
          title="Cancel reply"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </Show>
    </div>
  );
};

export default QuotedMessage;
