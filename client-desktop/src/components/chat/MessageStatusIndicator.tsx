import { Component, Show } from 'solid-js';
import type { MessageStatus as MessageStatusType } from '../../stores/messageStore';

interface MessageStatusProps {
  status: MessageStatusType;
  class?: string;
}

/**
 * MessageStatus - Visual indicator for message delivery status
 * 
 * States:
 * - pending/sending: Animated spinner
 * - sent: Single gray check
 * - delivered: Single gray check
 * - read: Double blue checks
 * - failed: Red exclamation mark
 */
export const MessageStatusIndicator: Component<MessageStatusProps> = (props) => {
  const iconClass = () => props.class ?? 'w-4 h-4';
  
  return (
    <>
      <Show when={props.status === 'pending' || props.status === 'sending'}>
        {/* Sending spinner */}
        <svg 
          class={`${iconClass()} opacity-50 animate-spin`} 
          viewBox="0 0 24 24" 
          fill="none" 
          stroke="currentColor" 
          stroke-width="2"
        >
          <circle cx="12" cy="12" r="10" stroke-dasharray="60" stroke-dashoffset="20" />
        </svg>
      </Show>
      
      <Show when={props.status === 'sent' || props.status === 'delivered'}>
        {/* Single check - sent/delivered */}
        <svg 
          class={`${iconClass()} opacity-70`} 
          viewBox="0 0 24 24" 
          fill="none" 
          stroke="currentColor" 
          stroke-width="2" 
          stroke-linecap="round" 
          stroke-linejoin="round"
        >
          <polyline points="20 6 9 17 4 12" />
        </svg>
      </Show>
      
      <Show when={props.status === 'read'}>
        {/* Double check - read (blue) */}
        <svg 
          class={`${iconClass()} text-blue-500`} 
          viewBox="0 0 24 24" 
          fill="none" 
          stroke="currentColor" 
          stroke-width="2" 
          stroke-linecap="round" 
          stroke-linejoin="round"
        >
          <polyline points="18 6 7 17 2 12" />
          <polyline points="22 10 11 21 8 18" />
        </svg>
      </Show>
      
      <Show when={props.status === 'failed'}>
        {/* Failed - red exclamation */}
        <svg 
          class={`${iconClass()} text-red-500`} 
          viewBox="0 0 24 24" 
          fill="none" 
          stroke="currentColor" 
          stroke-width="2" 
          stroke-linecap="round" 
          stroke-linejoin="round"
        >
          <circle cx="12" cy="12" r="10" />
          <line x1="12" y1="8" x2="12" y2="12" />
          <line x1="12" y1="16" x2="12.01" y2="16" />
        </svg>
      </Show>
    </>
  );
};

export default MessageStatusIndicator;
