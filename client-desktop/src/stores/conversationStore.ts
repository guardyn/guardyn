/**
 * Conversation Store
 * 
 * SolidJS store for managing conversation list, metadata, and navigation.
 * Handles conversation sorting, filtering, and unread counts.
 * 
 * @module stores/conversationStore
 */

import { createStore, produce } from 'solid-js/store';

// =============================================================================
// TYPES
// =============================================================================

export type ConversationType = 'direct' | 'group';

export type ConversationMuteStatus = 'none' | 'muted' | 'muted_until';

export interface ConversationParticipant {
  userId: string;
  displayName: string;
  avatarUrl?: string;
  role?: 'admin' | 'member';
  joinedAt: number;
}

export interface Conversation {
  id: string;
  type: ConversationType;
  /** Display name (contact name for DM, group name for groups) */
  name: string;
  /** Avatar URL */
  avatarUrl?: string;
  /** Participants in the conversation */
  participants: ConversationParticipant[];
  /** Last message preview */
  lastMessage?: {
    content: string;
    senderId: string;
    senderName: string;
    timestamp: number;
    /** Whether last message is from current user */
    isOwn: boolean;
  };
  /** Unread message count */
  unreadCount: number;
  /** Last activity timestamp (for sorting) */
  lastActivityAt: number;
  /** When the conversation was created */
  createdAt: number;
  /** Mute status */
  muteStatus: ConversationMuteStatus;
  /** Mute until timestamp (if muteStatus is 'muted_until') */
  mutedUntil?: number;
  /** Whether conversation is pinned */
  isPinned: boolean;
  /** Whether conversation is archived */
  isArchived: boolean;
  /** E2EE session state */
  encryptionStatus: 'none' | 'pending' | 'established' | 'error';
}

export type SortMode = 'recent' | 'unread' | 'alphabetical';

export interface ConversationFilter {
  /** Search query for name filtering */
  searchQuery: string;
  /** Show only unread conversations */
  unreadOnly: boolean;
  /** Show archived conversations */
  showArchived: boolean;
  /** Filter by conversation type */
  type: ConversationType | 'all';
}

export interface ConversationStoreState {
  /** All conversations indexed by ID */
  conversations: Record<string, Conversation>;
  /** Currently selected conversation ID */
  selectedId: string | null;
  /** Loading state */
  isLoading: boolean;
  /** Error message */
  error: string | null;
  /** Sort mode */
  sortMode: SortMode;
  /** Active filters */
  filter: ConversationFilter;
  /** Pagination cursor for loading more */
  cursor: string | null;
  /** Whether more conversations exist */
  hasMore: boolean;
}

// =============================================================================
// INITIAL STATE
// =============================================================================

const createInitialFilter = (): ConversationFilter => ({
  searchQuery: '',
  unreadOnly: false,
  showArchived: false,
  type: 'all',
});

const createInitialState = (): ConversationStoreState => ({
  conversations: {},
  selectedId: null,
  isLoading: false,
  error: null,
  sortMode: 'recent',
  filter: createInitialFilter(),
  cursor: null,
  hasMore: true,
});

// =============================================================================
// STORE
// =============================================================================

const [state, setState] = createStore<ConversationStoreState>(createInitialState());

// =============================================================================
// HELPERS
// =============================================================================

/**
 * Sort conversations based on current sort mode
 */
function sortConversations(conversations: Conversation[], sortMode: SortMode): Conversation[] {
  const sorted = [...conversations];
  
  switch (sortMode) {
    case 'recent':
      // Pinned first, then by last activity
      sorted.sort((a, b) => {
        if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
        return b.lastActivityAt - a.lastActivityAt;
      });
      break;
    case 'unread':
      // Unread first, then by last activity
      sorted.sort((a, b) => {
        if (a.unreadCount > 0 !== b.unreadCount > 0) {
          return a.unreadCount > 0 ? -1 : 1;
        }
        return b.lastActivityAt - a.lastActivityAt;
      });
      break;
    case 'alphabetical':
      sorted.sort((a, b) => a.name.localeCompare(b.name));
      break;
  }
  
  return sorted;
}

/**
 * Filter conversations based on current filter settings
 */
function filterConversations(conversations: Conversation[], filter: ConversationFilter): Conversation[] {
  return conversations.filter(conv => {
    // Search query filter
    if (filter.searchQuery) {
      const query = filter.searchQuery.toLowerCase();
      const nameMatch = conv.name.toLowerCase().includes(query);
      const participantMatch = conv.participants.some(p => 
        p.displayName.toLowerCase().includes(query)
      );
      if (!nameMatch && !participantMatch) return false;
    }
    
    // Unread only filter
    if (filter.unreadOnly && conv.unreadCount === 0) return false;
    
    // Archived filter
    if (!filter.showArchived && conv.isArchived) return false;
    
    // Type filter
    if (filter.type !== 'all' && conv.type !== filter.type) return false;
    
    return true;
  });
}

// =============================================================================
// ACTIONS
// =============================================================================

// -----------------------------------------------------------------------------
// CRUD Operations
// -----------------------------------------------------------------------------

/**
 * Add or update a conversation
 */
export function upsertConversation(conversation: Conversation): void {
  setState('conversations', conversation.id, conversation);
}

/**
 * Add multiple conversations (batch operation)
 */
export function addConversations(conversations: Conversation[]): void {
  setState(
    'conversations',
    produce((convs: Record<string, Conversation>) => {
      for (const conv of conversations) {
        convs[conv.id] = conv;
      }
    })
  );
}

/**
 * Update conversation properties
 */
export function updateConversation(
  conversationId: string,
  updates: Partial<Omit<Conversation, 'id'>>
): void {
  if (!state.conversations[conversationId]) return;
  
  setState(
    'conversations',
    conversationId,
    produce((conv: Conversation) => {
      Object.assign(conv, updates);
    })
  );
}

/**
 * Remove a conversation
 */
export function removeConversation(conversationId: string): void {
  setState(
    'conversations',
    produce((convs: Record<string, Conversation>) => {
      delete convs[conversationId];
    })
  );
  
  // Clear selection if removed conversation was selected
  if (state.selectedId === conversationId) {
    setState('selectedId', null);
  }
}

// -----------------------------------------------------------------------------
// Last Message & Unread
// -----------------------------------------------------------------------------

/**
 * Update last message for a conversation
 */
export function updateLastMessage(
  conversationId: string,
  lastMessage: Conversation['lastMessage']
): void {
  if (!state.conversations[conversationId]) return;
  
  setState('conversations', conversationId, {
    lastMessage,
    lastActivityAt: lastMessage?.timestamp ?? Date.now(),
  });
}

/**
 * Increment unread count for a conversation
 */
export function incrementUnread(conversationId: string): void {
  if (!state.conversations[conversationId]) return;
  
  setState(
    'conversations',
    conversationId,
    'unreadCount',
    (count) => count + 1
  );
}

/**
 * Clear unread count for a conversation
 */
export function clearUnread(conversationId: string): void {
  if (!state.conversations[conversationId]) return;
  
  setState('conversations', conversationId, 'unreadCount', 0);
}

/**
 * Get total unread count across all conversations
 */
export function getTotalUnread(): number {
  return Object.values(state.conversations).reduce(
    (total, conv) => total + conv.unreadCount,
    0
  );
}

// -----------------------------------------------------------------------------
// Selection
// -----------------------------------------------------------------------------

/**
 * Select a conversation
 */
export function selectConversation(conversationId: string | null): void {
  setState('selectedId', conversationId);
  
  // Clear unread when selecting
  if (conversationId) {
    clearUnread(conversationId);
  }
}

/**
 * Get currently selected conversation
 */
export function getSelectedConversation(): Conversation | null {
  if (!state.selectedId) return null;
  return state.conversations[state.selectedId] ?? null;
}

// -----------------------------------------------------------------------------
// Filtering & Sorting
// -----------------------------------------------------------------------------

/**
 * Set search query
 */
export function setSearchQuery(query: string): void {
  setState('filter', 'searchQuery', query);
}

/**
 * Set unread only filter
 */
export function setUnreadOnly(unreadOnly: boolean): void {
  setState('filter', 'unreadOnly', unreadOnly);
}

/**
 * Set show archived filter
 */
export function setShowArchived(showArchived: boolean): void {
  setState('filter', 'showArchived', showArchived);
}

/**
 * Set type filter
 */
export function setTypeFilter(type: ConversationType | 'all'): void {
  setState('filter', 'type', type);
}

/**
 * Set sort mode
 */
export function setSortMode(mode: SortMode): void {
  setState('sortMode', mode);
}

/**
 * Reset all filters
 */
export function resetFilters(): void {
  setState('filter', createInitialFilter());
}

// -----------------------------------------------------------------------------
// Conversation Actions
// -----------------------------------------------------------------------------

/**
 * Pin/unpin a conversation
 */
export function togglePin(conversationId: string): void {
  if (!state.conversations[conversationId]) return;
  
  setState(
    'conversations',
    conversationId,
    'isPinned',
    (pinned) => !pinned
  );
}

/**
 * Archive a conversation
 */
export function archiveConversation(conversationId: string): void {
  if (!state.conversations[conversationId]) return;
  
  setState('conversations', conversationId, 'isArchived', true);
  
  // Clear selection if archived conversation was selected
  if (state.selectedId === conversationId) {
    setState('selectedId', null);
  }
}

/**
 * Unarchive a conversation
 */
export function unarchiveConversation(conversationId: string): void {
  if (!state.conversations[conversationId]) return;
  
  setState('conversations', conversationId, 'isArchived', false);
}

/**
 * Mute a conversation
 */
export function muteConversation(
  conversationId: string,
  until?: number // undefined = forever
): void {
  if (!state.conversations[conversationId]) return;
  
  if (until) {
    setState('conversations', conversationId, {
      muteStatus: 'muted_until',
      mutedUntil: until,
    });
  } else {
    setState('conversations', conversationId, {
      muteStatus: 'muted',
      mutedUntil: undefined,
    });
  }
}

/**
 * Unmute a conversation
 */
export function unmuteConversation(conversationId: string): void {
  if (!state.conversations[conversationId]) return;
  
  setState('conversations', conversationId, {
    muteStatus: 'none',
    mutedUntil: undefined,
  });
}

// -----------------------------------------------------------------------------
// Loading State
// -----------------------------------------------------------------------------

/**
 * Set loading state
 */
export function setLoading(isLoading: boolean): void {
  setState('isLoading', isLoading);
}

/**
 * Set error message
 */
export function setError(error: string | null): void {
  setState('error', error);
}

/**
 * Update pagination state
 */
export function updatePagination(cursor: string | null, hasMore: boolean): void {
  setState({ cursor, hasMore });
}

/**
 * Reset store to initial state
 */
export function resetConversationStore(): void {
  setState(createInitialState());
}

// =============================================================================
// SELECTORS
// =============================================================================

/**
 * Get all conversations as array
 */
export function getAllConversations(): Conversation[] {
  return Object.values(state.conversations);
}

/**
 * Get filtered and sorted conversations
 */
export function getFilteredConversations(): Conversation[] {
  const all = getAllConversations();
  const filtered = filterConversations(all, state.filter);
  return sortConversations(filtered, state.sortMode);
}

/**
 * Get conversation by ID
 */
export function getConversation(conversationId: string): Conversation | undefined {
  return state.conversations[conversationId];
}

/**
 * Get pinned conversations
 */
export function getPinnedConversations(): Conversation[] {
  return getAllConversations()
    .filter(c => c.isPinned && !c.isArchived)
    .sort((a, b) => b.lastActivityAt - a.lastActivityAt);
}

/**
 * Get archived conversations
 */
export function getArchivedConversations(): Conversation[] {
  return getAllConversations()
    .filter(c => c.isArchived)
    .sort((a, b) => b.lastActivityAt - a.lastActivityAt);
}

/**
 * Get conversations with unread messages
 */
export function getUnreadConversations(): Conversation[] {
  return getAllConversations()
    .filter(c => c.unreadCount > 0 && !c.isArchived)
    .sort((a, b) => b.lastActivityAt - a.lastActivityAt);
}

/**
 * Check if a conversation is muted
 */
export function isConversationMuted(conversationId: string): boolean {
  const conv = state.conversations[conversationId];
  if (!conv) return false;
  
  if (conv.muteStatus === 'muted') return true;
  if (conv.muteStatus === 'muted_until' && conv.mutedUntil) {
    return Date.now() < conv.mutedUntil;
  }
  return false;
}

/**
 * Get direct message conversations
 */
export function getDirectConversations(): Conversation[] {
  return getFilteredConversations().filter(c => c.type === 'direct');
}

/**
 * Get group conversations
 */
export function getGroupConversations(): Conversation[] {
  return getFilteredConversations().filter(c => c.type === 'group');
}

// =============================================================================
// EXPORTS
// =============================================================================

export { state as conversationState };
