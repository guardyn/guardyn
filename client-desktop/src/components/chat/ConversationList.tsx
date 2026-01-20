/**
 * ConversationList Component
 * 
 * Displays a searchable, scrollable list of conversations.
 * Supports filtering and virtualization for performance.
 */

import { Component, createMemo, createSignal, For, Show } from 'solid-js';
import { ConversationItem, type PresenceStatus } from './ConversationItem';
import { VirtualList } from '../shared/VirtualList';

// =============================================================================
// TYPES
// =============================================================================

export interface Conversation {
  id: string;
  name: string;
  avatarUrl?: string;
  presence?: PresenceStatus;
  lastMessage?: string;
  lastMessageTime?: Date | string;
  unreadCount?: number;
}

export interface ConversationListProps {
  /** List of conversations */
  conversations: Conversation[];
  /** Currently selected conversation ID */
  selectedId?: string | null;
  /** Callback when conversation is selected */
  onSelect?: (id: string) => void;
  /** Whether to show search input */
  showSearch?: boolean;
  /** Loading state */
  loading?: boolean;
  /** Empty state message */
  emptyMessage?: string;
  /** Callback to create new conversation */
  onNewConversation?: () => void;
  /** Additional CSS classes */
  class?: string;
  /** Enable virtualization for large lists (default: true for 50+ items) */
  virtualize?: boolean;
  /** Height of each conversation item in pixels (for virtualization) */
  itemHeight?: number;
  /** Container height in pixels (for virtualization) */
  containerHeight?: number;
  /** Callback when scrolled to bottom (for pagination) */
  onScrollToBottom?: () => void;
}

// =============================================================================
// ICONS
// =============================================================================

const SearchIcon: Component<{ class?: string }> = (props) => (
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
    <circle cx="11" cy="11" r="8" />
    <path d="m21 21-4.35-4.35" />
  </svg>
);

const PlusIcon: Component<{ class?: string }> = (props) => (
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
    <path d="M12 5v14" />
    <path d="M5 12h14" />
  </svg>
);

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * ConversationList displays all conversations with search and filtering.
 * 
 * @example
 * ```tsx
 * <ConversationList
 *   conversations={conversations()}
 *   selectedId={selectedId()}
 *   onSelect={(id) => setSelectedId(id)}
 *   showSearch
 *   onNewConversation={() => setShowNewConversationModal(true)}
 * />
 * ```
 */
export const ConversationList: Component<ConversationListProps> = (props) => {
  const [searchQuery, setSearchQuery] = createSignal('');
  
  // Default item height for virtualization (72px = avatar 48px + padding)
  const itemHeight = () => props.itemHeight ?? 72;
  const containerHeight = () => props.containerHeight ?? 500;
  
  // Auto-enable virtualization for large lists
  const shouldVirtualize = () => {
    if (props.virtualize !== undefined) return props.virtualize;
    return filteredConversations().length >= 50;
  };

  const filteredConversations = createMemo(() => {
    const query = searchQuery().toLowerCase().trim();
    if (!query) return props.conversations;
    
    return props.conversations.filter((conv) =>
      conv.name.toLowerCase().includes(query) ||
      conv.lastMessage?.toLowerCase().includes(query)
    );
  });
  
  // Render a single conversation item
  const renderConversationItem = (conv: Conversation) => (
    <ConversationItem
      id={conv.id}
      name={conv.name}
      avatarUrl={conv.avatarUrl}
      presence={conv.presence}
      lastMessage={conv.lastMessage}
      lastMessageTime={conv.lastMessageTime}
      unreadCount={conv.unreadCount}
      isSelected={props.selectedId === conv.id}
      onClick={props.onSelect}
    />
  );

  return (
    <div class={`flex flex-col h-full ${props.class ?? ''}`}>
      {/* Header with search */}
      <div class="p-4 border-b border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between mb-3">
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
            Messages
          </h2>
          <Show when={props.onNewConversation}>
            <button
              onClick={() => props.onNewConversation?.()}
              aria-label="New conversation"
              class="p-2 text-gray-500 dark:text-gray-400 hover:text-guardyn-600 dark:hover:text-guardyn-500 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition"
            >
              <PlusIcon />
            </button>
          </Show>
        </div>
        
        {/* Search input */}
        <Show when={props.showSearch !== false}>
          <div class="relative">
            <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              value={searchQuery()}
              onInput={(e) => setSearchQuery(e.currentTarget.value)}
              placeholder="Search conversations..."
              class="w-full pl-10 pr-4 py-2 bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg text-sm text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition"
            />
          </div>
        </Show>
      </div>

      {/* Conversation list */}
      <div class="flex-1 overflow-y-auto">
        <Show
          when={!props.loading}
          fallback={
            <div class="p-4 space-y-3">
              <For each={[1, 2, 3]}>
                {() => (
                  <div class="flex items-center gap-3 animate-pulse">
                    <div class="w-12 h-12 rounded-full bg-gray-200 dark:bg-gray-700" />
                    <div class="flex-1 space-y-2">
                      <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4" />
                      <div class="h-3 bg-gray-200 dark:bg-gray-700 rounded w-1/2" />
                    </div>
                  </div>
                )}
              </For>
            </div>
          }
        >
          <Show
            when={filteredConversations().length > 0}
            fallback={
              <div class="p-8 text-center text-gray-500 dark:text-gray-400">
                <Show
                  when={searchQuery()}
                  fallback={
                    <div>
                      <svg class="w-12 h-12 mx-auto mb-3 text-gray-300 dark:text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                      </svg>
                      <p class="font-medium mb-1">{props.emptyMessage || 'No conversations yet'}</p>
                      <Show when={props.onNewConversation}>
                        <button
                          onClick={props.onNewConversation}
                          class="text-guardyn-500 hover:text-guardyn-400 text-sm"
                        >
                          Start a new chat
                        </button>
                      </Show>
                    </div>
                  }
                >
                  <p class="text-sm">No conversations found for "{searchQuery()}"</p>
                </Show>
              </div>
            }
          >
            {/* Use VirtualList for large lists, For for small lists */}
            <Show
              when={shouldVirtualize()}
              fallback={
                <For each={filteredConversations()}>
                  {(conv) => renderConversationItem(conv)}
                </For>
              }
            >
              <VirtualList
                items={() => filteredConversations()}
                itemHeight={itemHeight()}
                containerHeight={containerHeight()}
                overscan={3}
                onScrollToBottom={props.onScrollToBottom}
                class="h-full"
                renderItem={(conv) => renderConversationItem(conv)}
              />
            </Show>
          </Show>
        </Show>
      </div>
    </div>
  );
};

export default ConversationList;
