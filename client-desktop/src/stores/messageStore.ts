/**
 * Message Store
 * 
 * SolidJS store for managing chat messages with reactive updates.
 * Handles conversation grouping, typing indicators, read receipts,
 * pagination, optimistic updates, and error handling with retry.
 * 
 * @module stores/messageStore
 */

import { createStore, produce } from 'solid-js/store';

// =============================================================================
// TYPES
// =============================================================================

export type MessageStatus = 'pending' | 'sending' | 'sent' | 'delivered' | 'read' | 'failed';

export interface Message {
  id: string;
  /** Client-generated ID for optimistic updates */
  clientMessageId?: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  content: string;
  timestamp: number;
  isOwn: boolean;
  status: MessageStatus;
  /** Error message if status is 'failed' */
  errorMessage?: string;
  /** Number of retry attempts */
  retryCount?: number;
  reactions?: { emoji: string; count: number; hasReacted: boolean }[];
  /** Optional attachment metadata */
  attachments?: MessageAttachment[];
}

export interface MessageAttachment {
  id: string;
  type: 'image' | 'video' | 'audio' | 'file';
  fileName: string;
  fileSize: number;
  mimeType: string;
  url?: string;
  thumbnailUrl?: string;
  /** Upload progress 0-100 */
  uploadProgress?: number;
}

export interface TypingUser {
  userId: string;
  userName: string;
  startedAt: number;
}

export interface PaginationState {
  /** Cursor for fetching older messages */
  cursor: string | null;
  /** Whether more messages exist */
  hasMore: boolean;
  /** Loading state for pagination */
  isLoading: boolean;
  /** Total message count (if known) */
  totalCount?: number;
}

export interface ConversationState {
  messages: Message[];
  typingUsers: TypingUser[];
  unreadCount: number;
  lastReadAt: number;
  /** Pagination state for infinite scroll */
  pagination: PaginationState;
}

export interface MessageStoreState {
  /** Messages grouped by conversation ID */
  conversations: Record<string, ConversationState>;
  /** Currently active conversation ID */
  activeConversationId: string | null;
  /** Current user ID */
  currentUserId: string;
  /** Global loading state */
  isLoading: boolean;
  /** Global error message */
  error: string | null;
}

/** Maximum retry attempts for failed messages */
export const MAX_RETRY_ATTEMPTS = 3;

/** Default page size for message pagination */
export const DEFAULT_PAGE_SIZE = 50;

// =============================================================================
// INITIAL STATE
// =============================================================================

const createInitialState = (): MessageStoreState => ({
  conversations: {},
  activeConversationId: null,
  currentUserId: 'self', // Will be set by auth
  isLoading: false,
  error: null,
});

const createInitialConversationState = (): ConversationState => ({
  messages: [],
  typingUsers: [],
  unreadCount: 0,
  lastReadAt: 0,
  pagination: {
    cursor: null,
    hasMore: true,
    isLoading: false,
    totalCount: undefined,
  },
});

// =============================================================================
// STORE
// =============================================================================

const [state, setState] = createStore<MessageStoreState>(createInitialState());

// =============================================================================
// HELPERS
// =============================================================================

function ensureConversation(conversationId: string): void {
  if (!state.conversations[conversationId]) {
    setState('conversations', conversationId, createInitialConversationState());
  }
}

/**
 * Generate a client-side message ID for optimistic updates
 */
export function generateClientMessageId(): string {
  return `client_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

// =============================================================================
// ACTIONS
// =============================================================================

// -----------------------------------------------------------------------------
// Optimistic Updates
// -----------------------------------------------------------------------------

/**
 * Add an optimistic message (pending server confirmation)
 * Returns the client message ID for tracking
 */
export function addOptimisticMessage(
  conversationId: string,
  content: string,
  senderName: string
): string {
  ensureConversation(conversationId);

  const clientMessageId = generateClientMessageId();
  const message: Message = {
    id: clientMessageId, // Temporary ID, will be replaced by server ID
    clientMessageId,
    conversationId,
    senderId: state.currentUserId,
    senderName,
    content,
    timestamp: Date.now(),
    isOwn: true,
    status: 'pending',
    retryCount: 0,
  };

  setState(
    'conversations',
    conversationId,
    produce((conv: ConversationState) => {
      conv.messages.push(message);
    })
  );

  return clientMessageId;
}

/**
 * Confirm an optimistic message after server acknowledgment
 * Updates the message with server-assigned ID and status
 */
export function confirmOptimisticMessage(
  conversationId: string,
  clientMessageId: string,
  serverId: string,
  timestamp?: number
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m =>
      m.clientMessageId === clientMessageId
        ? {
            ...m,
            id: serverId,
            status: 'sent' as MessageStatus,
            timestamp: timestamp ?? m.timestamp,
          }
        : m
    )
  );
}

/**
 * Mark an optimistic message as failed
 */
export function failOptimisticMessage(
  conversationId: string,
  clientMessageId: string,
  errorMessage: string
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m =>
      m.clientMessageId === clientMessageId
        ? {
            ...m,
            status: 'failed' as MessageStatus,
            errorMessage,
            retryCount: (m.retryCount ?? 0) + 1,
          }
        : m
    )
  );
}

/**
 * Retry sending a failed message
 */
export function retryMessage(
  conversationId: string,
  clientMessageId: string
): boolean {
  const conv = state.conversations[conversationId];
  if (!conv) return false;

  const message = conv.messages.find(m => m.clientMessageId === clientMessageId);
  if (!message || message.status !== 'failed') return false;

  if ((message.retryCount ?? 0) >= MAX_RETRY_ATTEMPTS) {
    return false; // Max retries exceeded
  }

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m =>
      m.clientMessageId === clientMessageId
        ? { ...m, status: 'pending' as MessageStatus, errorMessage: undefined }
        : m
    )
  );

  return true;
}

/**
 * Remove a failed message (user dismissed)
 */
export function removeFailedMessage(conversationId: string, clientMessageId: string): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.filter(m => m.clientMessageId !== clientMessageId)
  );
}

// -----------------------------------------------------------------------------
// Pagination
// -----------------------------------------------------------------------------

/**
 * Set pagination loading state
 */
export function setPaginationLoading(conversationId: string, isLoading: boolean): void {
  ensureConversation(conversationId);
  setState('conversations', conversationId, 'pagination', 'isLoading', isLoading);
}

/**
 * Prepend older messages (for pagination/infinite scroll)
 * Messages are added to the beginning of the array
 */
export function prependMessages(
  conversationId: string,
  messages: Omit<Message, 'isOwn'>[],
  cursor: string | null,
  hasMore: boolean
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    produce((conv: ConversationState) => {
      // Add messages that don't already exist
      const existingIds = new Set(conv.messages.map(m => m.id));
      const newMessages = messages
        .filter(m => !existingIds.has(m.id))
        .map(m => ({
          ...m,
          isOwn: m.senderId === state.currentUserId,
        }));

      conv.messages = [...newMessages, ...conv.messages];
      conv.messages.sort((a, b) => a.timestamp - b.timestamp);
      
      conv.pagination.cursor = cursor;
      conv.pagination.hasMore = hasMore;
      conv.pagination.isLoading = false;
    })
  );
}

/**
 * Get pagination state for a conversation
 */
export function getPaginationState(conversationId: string): PaginationState {
  return state.conversations[conversationId]?.pagination ?? {
    cursor: null,
    hasMore: true,
    isLoading: false,
  };
}

// -----------------------------------------------------------------------------
// Standard CRUD Operations
// -----------------------------------------------------------------------------

/**
 * Add a new message to a conversation
 */
export function addMessage(message: Omit<Message, 'isOwn'>): void {
  const { conversationId } = message;
  ensureConversation(conversationId);

  const isOwn = message.senderId === state.currentUserId;

  setState(
    'conversations',
    conversationId,
    produce((conv: ConversationState) => {
      // Check for duplicate by ID or clientMessageId
      const isDuplicate = conv.messages.some(m => 
        m.id === message.id || 
        (message.clientMessageId && m.clientMessageId === message.clientMessageId)
      );
      if (isDuplicate) return;
      
      conv.messages.push({
        ...message,
        isOwn,
      });

      // Sort by timestamp
      conv.messages.sort((a, b) => a.timestamp - b.timestamp);

      // Update unread count if not active and not own message
      if (state.activeConversationId !== conversationId && !isOwn) {
        conv.unreadCount++;
      }
    })
  );
}

/**
 * Update an existing message
 */
export function updateMessage(
  conversationId: string,
  messageId: string,
  updates: Partial<Pick<Message, 'content' | 'status' | 'reactions' | 'errorMessage'>>
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m => 
      m.id === messageId ? { ...m, ...updates } : m
    )
  );
}

/**
 * Update message status by ID or clientMessageId
 */
export function updateMessageStatus(
  conversationId: string,
  messageIdOrClientId: string,
  status: MessageStatus
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m =>
      (m.id === messageIdOrClientId || m.clientMessageId === messageIdOrClientId)
        ? { ...m, status }
        : m
    )
  );
}

/**
 * Delete a message
 */
export function deleteMessage(conversationId: string, messageId: string): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.filter(m => m.id !== messageId)
  );
}

// -----------------------------------------------------------------------------
// Global State
// -----------------------------------------------------------------------------

/**
 * Set global loading state
 */
export function setLoading(isLoading: boolean): void {
  setState('isLoading', isLoading);
}

/**
 * Set global error message
 */
export function setError(error: string | null): void {
  setState('error', error);
}

/**
 * Clear global error
 */
export function clearError(): void {
  setState('error', null);
}

/**
 * Set message status to read for all messages in a conversation
 */
export function markConversationAsRead(conversationId: string): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    produce((conv: ConversationState) => {
      conv.messages.forEach(m => {
        if (!m.isOwn && m.status !== 'read') {
          m.status = 'read';
        }
      });
      conv.unreadCount = 0;
      conv.lastReadAt = Date.now();
    })
  );
}

/**
 * Add a typing indicator
 */
export function addTypingUser(conversationId: string, userId: string, userName: string): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    produce((conv: ConversationState) => {
      // Don't add if already typing
      if (conv.typingUsers.some(u => u.userId === userId)) return;
      
      conv.typingUsers.push({
        userId,
        userName,
        startedAt: Date.now(),
      });
    })
  );
}

/**
 * Remove a typing indicator
 */
export function removeTypingUser(conversationId: string, userId: string): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'typingUsers',
    (users) => users.filter(u => u.userId !== userId)
  );
}

/**
 * Clear all typing users for a conversation
 */
export function clearTypingUsers(conversationId: string): void {
  ensureConversation(conversationId);

  setState('conversations', conversationId, 'typingUsers', []);
}

/**
 * Set the active conversation
 */
export function setActiveConversation(conversationId: string | null): void {
  setState('activeConversationId', conversationId);
  
  if (conversationId) {
    markConversationAsRead(conversationId);
  }
}

/**
 * Set current user ID
 */
export function setCurrentUserId(userId: string): void {
  setState('currentUserId', userId);
}

/**
 * Reset store to initial state
 */
export function resetMessageStore(): void {
  setState(createInitialState());
}

// -----------------------------------------------------------------------------
// Reactions
// -----------------------------------------------------------------------------

export interface MessageReaction {
  emoji: string;
  count: number;
  hasReacted: boolean;
}

/**
 * Toggle a reaction on a message
 * If the user has already reacted with this emoji, remove it
 * Otherwise, add the reaction
 */
export function toggleReaction(
  conversationId: string,
  messageId: string,
  emoji: string
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m => {
      if (m.id !== messageId) return m;

      const reactions = [...(m.reactions ?? [])];
      const existingIndex = reactions.findIndex(r => r.emoji === emoji);

      if (existingIndex !== -1) {
        const existing = reactions[existingIndex];
        if (existing.hasReacted) {
          // User has reacted - remove their reaction
          if (existing.count <= 1) {
            reactions.splice(existingIndex, 1);
          } else {
            reactions[existingIndex] = {
              ...existing,
              count: existing.count - 1,
              hasReacted: false,
            };
          }
        } else {
          // User hasn't reacted - add their reaction
          reactions[existingIndex] = {
            ...existing,
            count: existing.count + 1,
            hasReacted: true,
          };
        }
      } else {
        // New reaction
        reactions.push({
          emoji,
          count: 1,
          hasReacted: true,
        });
      }

      return { ...m, reactions };
    })
  );
}

/**
 * Add a reaction from another user (received via WebSocket)
 */
export function addExternalReaction(
  conversationId: string,
  messageId: string,
  emoji: string,
  userId: string
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m => {
      if (m.id !== messageId) return m;

      const reactions = [...(m.reactions ?? [])];
      const existingIndex = reactions.findIndex(r => r.emoji === emoji);

      if (existingIndex !== -1) {
        reactions[existingIndex] = {
          ...reactions[existingIndex],
          count: reactions[existingIndex].count + 1,
        };
      } else {
        reactions.push({
          emoji,
          count: 1,
          hasReacted: userId === state.currentUserId,
        });
      }

      return { ...m, reactions };
    })
  );
}

/**
 * Remove a reaction from another user (received via WebSocket)
 */
export function removeExternalReaction(
  conversationId: string,
  messageId: string,
  emoji: string,
  userId: string
): void {
  ensureConversation(conversationId);

  setState(
    'conversations',
    conversationId,
    'messages',
    (messages) => messages.map(m => {
      if (m.id !== messageId) return m;

      const reactions = [...(m.reactions ?? [])];
      const existingIndex = reactions.findIndex(r => r.emoji === emoji);

      if (existingIndex !== -1) {
        const existing = reactions[existingIndex];
        if (existing.count <= 1) {
          reactions.splice(existingIndex, 1);
        } else {
          reactions[existingIndex] = {
            ...existing,
            count: existing.count - 1,
            hasReacted: userId === state.currentUserId ? false : existing.hasReacted,
          };
        }
      }

      return { ...m, reactions };
    })
  );
}

/**
 * Get reactions for a specific message
 */
export function getMessageReactions(
  conversationId: string,
  messageId: string
): MessageReaction[] {
  const message = getMessage(conversationId, messageId);
  return message?.reactions ?? [];
}

// =============================================================================
// SELECTORS
// =============================================================================

/**
 * Get messages for a specific conversation
 */
export function getMessages(conversationId: string): Message[] {
  return state.conversations[conversationId]?.messages ?? [];
}

/**
 * Get pending messages for a conversation
 */
export function getPendingMessages(conversationId: string): Message[] {
  return getMessages(conversationId).filter(m => m.status === 'pending' || m.status === 'sending');
}

/**
 * Get failed messages for a conversation
 */
export function getFailedMessages(conversationId: string): Message[] {
  return getMessages(conversationId).filter(m => m.status === 'failed');
}

/**
 * Get a message by ID or clientMessageId
 */
export function getMessage(conversationId: string, messageIdOrClientId: string): Message | undefined {
  return getMessages(conversationId).find(
    m => m.id === messageIdOrClientId || m.clientMessageId === messageIdOrClientId
  );
}

/**
 * Check if a message can be retried
 */
export function canRetryMessage(conversationId: string, clientMessageId: string): boolean {
  const message = getMessage(conversationId, clientMessageId);
  if (!message) return false;
  return message.status === 'failed' && (message.retryCount ?? 0) < MAX_RETRY_ATTEMPTS;
}

/**
 * Get typing users for a specific conversation
 */
export function getTypingUsers(conversationId: string): TypingUser[] {
  return state.conversations[conversationId]?.typingUsers ?? [];
}

/**
 * Get unread count for a specific conversation
 */
export function getUnreadCount(conversationId: string): number {
  return state.conversations[conversationId]?.unreadCount ?? 0;
}

/**
 * Get total unread count across all conversations
 */
export function getTotalUnreadCount(): number {
  return Object.values(state.conversations).reduce(
    (total, conv) => total + conv.unreadCount,
    0
  );
}

/**
 * Get active conversation messages
 */
export function getActiveMessages(): Message[] {
  if (!state.activeConversationId) return [];
  return getMessages(state.activeConversationId);
}

/**
 * Get active conversation typing users
 */
export function getActiveTypingUsers(): TypingUser[] {
  if (!state.activeConversationId) return [];
  return getTypingUsers(state.activeConversationId);
}

/**
 * Check if store has a global error
 */
export function hasError(): boolean {
  return state.error !== null;
}

/**
 * Get global error message
 */
export function getError(): string | null {
  return state.error;
}

/**
 * Check if store is loading
 */
export function isStoreLoading(): boolean {
  return state.isLoading;
}

// =============================================================================
// EXPORTS
// =============================================================================

export { state as messageState };
