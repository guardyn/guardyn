/**
 * ConversationItem Component
 * 
 * Displays a single conversation in the conversation list.
 * Shows avatar, presence indicator, last message preview, and unread badge.
 */

import { Component, Show } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type PresenceStatus = 'online' | 'offline' | 'away' | 'busy';

export interface ConversationItemProps {
  /** Unique conversation ID */
  id: string;
  /** Conversation name */
  name: string;
  /** Avatar URL */
  avatarUrl?: string;
  /** Presence status */
  presence?: PresenceStatus;
  /** Last message content */
  lastMessage?: string;
  /** Last message timestamp */
  lastMessageTime?: Date | string;
  /** Number of unread messages */
  unreadCount?: number;
  /** Whether this conversation is selected */
  isSelected?: boolean;
  /** Click handler */
  onClick?: (id: string) => void;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// HELPERS
// =============================================================================

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
}

function formatMessageTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const diff = now.getTime() - d.getTime();
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));

  if (days === 0) {
    return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  } else if (days === 1) {
    return 'Yesterday';
  } else if (days < 7) {
    return d.toLocaleDateString([], { weekday: 'short' });
  } else {
    return d.toLocaleDateString([], { month: 'short', day: 'numeric' });
  }
}

function getPresenceColor(status: PresenceStatus): string {
  switch (status) {
    case 'online':
      return 'bg-green-500';
    case 'away':
      return 'bg-yellow-500';
    case 'busy':
      return 'bg-red-500';
    case 'offline':
    default:
      return 'bg-gray-400';
  }
}

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * ConversationItem displays a conversation preview in the list.
 * 
 * @example
 * ```tsx
 * <ConversationItem
 *   id="1"
 *   name="Alice Johnson"
 *   lastMessage="Hey, how are you?"
 *   lastMessageTime={new Date()}
 *   unreadCount={3}
 *   presence="online"
 *   isSelected={selectedId === "1"}
 *   onClick={(id) => setSelectedId(id)}
 * />
 * ```
 */
export const ConversationItem: Component<ConversationItemProps> = (props) => {
  const handleClick = () => {
    props.onClick?.(props.id);
  };

  return (
    <button
      onClick={handleClick}
      class={`
        w-full p-3 flex items-center gap-3
        transition-all duration-200
        hover:bg-gray-100 dark:hover:bg-gray-700
        ${props.isSelected 
          ? 'bg-gray-100 dark:bg-gray-700 border-l-4 border-guardyn-500' 
          : 'border-l-4 border-transparent'
        }
        ${props.class ?? ''}
      `}
    >
      {/* Avatar with presence indicator */}
      <div class="relative flex-shrink-0">
        <Show
          when={props.avatarUrl}
          fallback={
            <div class="w-12 h-12 rounded-full bg-gradient-to-br from-guardyn-400 to-guardyn-600 flex items-center justify-center text-white font-medium shadow-md">
              {getInitials(props.name)}
            </div>
          }
        >
          <img
            src={props.avatarUrl}
            alt={props.name}
            class="w-12 h-12 rounded-full object-cover shadow-md"
          />
        </Show>
        
        {/* Presence indicator */}
        <Show when={props.presence}>
          <div
            class={`
              absolute bottom-0 right-0 w-3.5 h-3.5 rounded-full border-2 border-white dark:border-gray-800
              ${getPresenceColor(props.presence!)}
            `}
          />
        </Show>
      </div>

      {/* Content */}
      <div class="flex-1 min-w-0 text-left">
        <div class="flex items-center justify-between gap-2">
          <p class={`
            text-sm font-medium truncate
            ${props.isSelected ? 'text-guardyn-700 dark:text-guardyn-400' : 'text-gray-900 dark:text-white'}
          `}>
            {props.name}
          </p>
          <Show when={props.lastMessageTime}>
            <span class="text-xs text-gray-500 dark:text-gray-400 flex-shrink-0">
              {formatMessageTime(props.lastMessageTime!)}
            </span>
          </Show>
        </div>
        
        <div class="flex items-center justify-between gap-2 mt-0.5">
          <p class="text-sm text-gray-500 dark:text-gray-400 truncate">
            {props.lastMessage || 'No messages yet'}
          </p>
          
          {/* Unread badge */}
          <Show when={props.unreadCount && props.unreadCount > 0}>
            <span class="flex-shrink-0 min-w-[1.25rem] h-5 px-1.5 rounded-full bg-guardyn-500 text-white text-xs font-medium flex items-center justify-center">
              {(props.unreadCount ?? 0) > 99 ? '99+' : props.unreadCount}
            </span>
          </Show>
        </div>
      </div>
    </button>
  );
};

export default ConversationItem;
