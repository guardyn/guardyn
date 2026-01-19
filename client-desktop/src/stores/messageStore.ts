/**
 * Message Store
 * 
 * SolidJS store for managing chat messages and conversations.
 * Provides reactive state management for real-time messaging.
 */

import { createStore, produce } from 'solid-js/store';

// =============================================================================
// TYPES
// =============================================================================

export interface Message {
  id: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  content: string;
  timestamp: number;
  isOwn: boolean;
  status: 'sending' | 'sent' | 'delivered' | 'read' | 'failed';
  reactions?: { emoji: string; count: number; hasReacted: boolean }[];
}

export interface TypingUser {
  userId: string;
  userName: string;
  startedAt: number;
}

export interface ConversationState {
  messages: Message[];
  typingUsers: TypingUser[];
  unreadCount: number;
  lastReadAt: number;
}

export interface MessageStoreState {
  /** Messages grouped by conversation ID */
  conversations: Record<string, ConversationState>;
  /** Currently active conversation ID */
  activeConversationId: string | null;
  /** Current user ID */
  currentUserId: string;
}

// =============================================================================
// INITIAL STATE
// =============================================================================

const createInitialState = (): MessageStoreState => ({
  conversations: {},
  activeConversationId: null,
  currentUserId: 'self', // Will be set by auth
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
    setState('conversations', conversationId, {
      messages: [],
      typingUsers: [],
      unreadCount: 0,
      lastReadAt: 0,
    });
  }
}

// =============================================================================
// ACTIONS
// =============================================================================

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
      // Check for duplicate
      if (conv.messages.some(m => m.id === message.id)) return;
      
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
  updates: Partial<Pick<Message, 'content' | 'status' | 'reactions'>>
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

// =============================================================================
// EXPORTS
// =============================================================================

export { state as messageState };
