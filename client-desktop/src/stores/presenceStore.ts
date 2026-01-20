/**
 * Presence Store
 *
 * Manages user presence status (online/offline/away/dnd), typing indicators,
 * and last seen timestamps for the desktop client.
 *
 * Features:
 * - Real-time presence updates via WebSocket
 * - Typing indicator tracking per conversation
 * - Last seen timestamp caching
 * - Automatic cleanup of stale typing indicators
 */

import { createStore, produce } from 'solid-js/store';
import { createMemo } from 'solid-js';
import type { PresenceStatus } from '../api/websocket.types';

// =============================================================================
// TYPES
// =============================================================================

/**
 * User presence information
 */
export interface UserPresence {
  /** User ID */
  userId: string;
  /** Current presence status */
  status: PresenceStatus;
  /** Last seen timestamp (ISO 8601) */
  lastSeen?: string;
  /** When this presence info was last updated */
  updatedAt: number;
}

/**
 * Typing indicator information
 */
export interface TypingIndicator {
  /** User ID who is typing */
  userId: string;
  /** User display name (for UI) */
  displayName?: string;
  /** When typing started (Unix ms) */
  startedAt: number;
  /** Auto-expire timeout ID */
  timeoutId?: ReturnType<typeof setTimeout>;
}

/**
 * Typing state for a conversation
 */
export interface ConversationTyping {
  /** Map of user ID to typing indicator */
  users: Record<string, TypingIndicator>;
}

/**
 * Presence store state
 */
export interface PresenceStoreState {
  /** Map of user ID to presence info */
  presences: Record<string, UserPresence>;
  /** Map of conversation ID to typing state */
  typing: Record<string, ConversationTyping>;
  /** Whether the current user's presence is being broadcast */
  isBroadcasting: boolean;
  /** Current user's status (for self-awareness) */
  myStatus: PresenceStatus;
  /** Error message if any */
  error: string | null;
}

/**
 * Presence event for listeners
 */
export interface PresenceEvent {
  type: 'presence_changed' | 'typing_started' | 'typing_stopped';
  userId: string;
  conversationId?: string;
  status?: PresenceStatus;
  lastSeen?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

/** How long before a typing indicator auto-expires (ms) */
const TYPING_TIMEOUT_MS = 5000;

/** How long to cache presence data before considering it stale (ms) */
const PRESENCE_STALE_MS = 60000;

// =============================================================================
// STATE
// =============================================================================

const createInitialState = (): PresenceStoreState => ({
  presences: {},
  typing: {},
  isBroadcasting: false,
  myStatus: 'online',
  error: null,
});

const [state, setState] = createStore<PresenceStoreState>(createInitialState());

// =============================================================================
// EVENT LISTENERS
// =============================================================================

type PresenceEventHandler = (event: PresenceEvent) => void;
const eventListeners: Set<PresenceEventHandler> = new Set();

/**
 * Subscribe to presence events
 */
export function subscribeToPresenceEvents(handler: PresenceEventHandler): () => void {
  eventListeners.add(handler);
  return () => eventListeners.delete(handler);
}

/**
 * Emit a presence event to all listeners
 */
function emitPresenceEvent(event: PresenceEvent): void {
  eventListeners.forEach(handler => {
    try {
      handler(event);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('[PresenceStore] Error in event handler:', error);
    }
  });
}

// =============================================================================
// SELECTORS (Reactive Memos)
// =============================================================================

/**
 * Get presence for a specific user
 */
export function getPresence(userId: string): UserPresence | undefined {
  return state.presences[userId];
}

/**
 * Get the current status of a user
 */
export function getUserStatus(userId: string): PresenceStatus {
  return state.presences[userId]?.status ?? 'offline';
}

/**
 * Get last seen timestamp for a user
 */
export function getLastSeen(userId: string): string | undefined {
  return state.presences[userId]?.lastSeen;
}

/**
 * Check if a user is online (online or away, but not offline/dnd)
 */
export function isUserOnline(userId: string): boolean {
  const status = getUserStatus(userId);
  return status === 'online' || status === 'away';
}

/**
 * Get all users currently typing in a conversation
 */
export function getTypingUsers(conversationId: string): TypingIndicator[] {
  const conversationTyping = state.typing[conversationId];
  if (!conversationTyping) return [];
  return Object.values(conversationTyping.users);
}

/**
 * Get typing user display names for a conversation
 */
export function getTypingUserNames(conversationId: string): string[] {
  return getTypingUsers(conversationId)
    .map(t => t.displayName ?? t.userId)
    .filter(Boolean);
}

/**
 * Check if anyone is typing in a conversation
 */
export function isAnyoneTyping(conversationId: string): boolean {
  const conversationTyping = state.typing[conversationId];
  if (!conversationTyping) return false;
  return Object.keys(conversationTyping.users).length > 0;
}

/**
 * Get count of users currently typing in a conversation
 */
export function getTypingCount(conversationId: string): number {
  const conversationTyping = state.typing[conversationId];
  if (!conversationTyping) return 0;
  return Object.keys(conversationTyping.users).length;
}

/**
 * Get all online users
 */
export function getOnlineUsers(): UserPresence[] {
  return Object.values(state.presences).filter(p =>
    p.status === 'online' || p.status === 'away'
  );
}

/**
 * Get the current user's status
 */
export function getMyStatus(): PresenceStatus {
  return state.myStatus;
}

/**
 * Check if presence broadcasting is active
 */
export function isBroadcasting(): boolean {
  return state.isBroadcasting;
}

// =============================================================================
// ACTIONS - Presence Updates
// =============================================================================

/**
 * Update a user's presence status
 */
export function updatePresence(
  userId: string,
  status: PresenceStatus,
  lastSeen?: string
): void {
  const now = Date.now();

  setState(
    produce((s) => {
      s.presences[userId] = {
        userId,
        status,
        lastSeen: lastSeen ?? (status === 'offline' ? new Date().toISOString() : undefined),
        updatedAt: now,
      };
      s.error = null;
    })
  );

  emitPresenceEvent({
    type: 'presence_changed',
    userId,
    status,
    lastSeen,
  });
}

/**
 * Bulk update multiple user presences
 */
export function updatePresencesBulk(
  updates: Array<{ userId: string; status: PresenceStatus; lastSeen?: string }>
): void {
  const now = Date.now();

  setState(
    produce((s) => {
      for (const update of updates) {
        s.presences[update.userId] = {
          userId: update.userId,
          status: update.status,
          lastSeen:
            update.lastSeen ??
            (update.status === 'offline' ? new Date().toISOString() : undefined),
          updatedAt: now,
        };
      }
      s.error = null;
    })
  );

  // Emit events for each update
  for (const update of updates) {
    emitPresenceEvent({
      type: 'presence_changed',
      userId: update.userId,
      status: update.status,
      lastSeen: update.lastSeen,
    });
  }
}

/**
 * Remove a user's presence (cleanup)
 */
export function removePresence(userId: string): void {
  setState(
    produce((s) => {
      delete s.presences[userId];
    })
  );
}

/**
 * Set the current user's status
 */
export function setMyStatus(status: PresenceStatus): void {
  setState('myStatus', status);
}

/**
 * Set broadcasting state
 */
export function setBroadcasting(isBroadcasting: boolean): void {
  setState('isBroadcasting', isBroadcasting);
}

// =============================================================================
// ACTIONS - Typing Indicators
// =============================================================================

/**
 * Mark a user as typing in a conversation
 */
export function setUserTyping(
  conversationId: string,
  userId: string,
  displayName?: string
): void {
  const now = Date.now();

  setState(
    produce((s) => {
      // Initialize conversation typing state if needed
      if (!s.typing[conversationId]) {
        s.typing[conversationId] = { users: {} };
      }

      // Clear existing timeout if any
      const existing = s.typing[conversationId].users[userId];
      if (existing?.timeoutId) {
        clearTimeout(existing.timeoutId);
      }

      // Set up auto-expire timeout
      const timeoutId = setTimeout(() => {
        clearUserTyping(conversationId, userId);
      }, TYPING_TIMEOUT_MS);

      // Update typing state
      s.typing[conversationId].users[userId] = {
        userId,
        displayName,
        startedAt: existing?.startedAt ?? now,
        timeoutId,
      };

      s.error = null;
    })
  );

  emitPresenceEvent({
    type: 'typing_started',
    userId,
    conversationId,
  });
}

/**
 * Clear a user's typing indicator in a conversation
 */
export function clearUserTyping(conversationId: string, userId: string): void {
  setState(
    produce((s) => {
      const conversationTyping = s.typing[conversationId];
      if (!conversationTyping) return;

      const existing = conversationTyping.users[userId];
      if (existing?.timeoutId) {
        clearTimeout(existing.timeoutId);
      }

      delete conversationTyping.users[userId];

      // Clean up empty conversation typing state
      if (Object.keys(conversationTyping.users).length === 0) {
        delete s.typing[conversationId];
      }
    })
  );

  emitPresenceEvent({
    type: 'typing_stopped',
    userId,
    conversationId,
  });
}

/**
 * Clear all typing indicators for a conversation
 */
export function clearConversationTyping(conversationId: string): void {
  setState(
    produce((s) => {
      const conversationTyping = s.typing[conversationId];
      if (!conversationTyping) return;

      // Clear all timeouts
      for (const indicator of Object.values(conversationTyping.users)) {
        if (indicator.timeoutId) {
          clearTimeout(indicator.timeoutId);
        }
      }

      delete s.typing[conversationId];
    })
  );
}

/**
 * Clear all typing indicators
 */
export function clearAllTyping(): void {
  setState(
    produce((s) => {
      // Clear all timeouts
      for (const conversationTyping of Object.values(s.typing)) {
        for (const indicator of Object.values(conversationTyping.users)) {
          if (indicator.timeoutId) {
            clearTimeout(indicator.timeoutId);
          }
        }
      }

      s.typing = {};
    })
  );
}

// =============================================================================
// ACTIONS - Store Management
// =============================================================================

/**
 * Set error state
 */
export function setPresenceError(error: string | null): void {
  setState('error', error);
}

/**
 * Reset the store to initial state
 */
export function resetPresenceStore(): void {
  // Clear all typing timeouts first
  clearAllTyping();

  setState(createInitialState());
}

/**
 * Clean up stale presence data
 */
export function cleanupStalePresences(): void {
  const now = Date.now();
  const staleThreshold = now - PRESENCE_STALE_MS;

  setState(
    produce((s) => {
      for (const userId of Object.keys(s.presences)) {
        if (s.presences[userId].updatedAt < staleThreshold) {
          // Mark stale online users as offline
          if (s.presences[userId].status !== 'offline') {
            s.presences[userId].status = 'offline';
            s.presences[userId].lastSeen = new Date().toISOString();
            s.presences[userId].updatedAt = now;
          }
        }
      }
    })
  );
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/**
 * Format last seen timestamp for display
 */
export function formatLastSeen(lastSeen: string | undefined): string {
  if (!lastSeen) return 'Unknown';

  const date = new Date(lastSeen);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMinutes = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMinutes < 1) {
    return 'Just now';
  } else if (diffMinutes < 60) {
    return `${diffMinutes} minute${diffMinutes === 1 ? '' : 's'} ago`;
  } else if (diffHours < 24) {
    return `${diffHours} hour${diffHours === 1 ? '' : 's'} ago`;
  } else if (diffDays < 7) {
    return `${diffDays} day${diffDays === 1 ? '' : 's'} ago`;
  } else {
    return date.toLocaleDateString();
  }
}

/**
 * Get status display color
 */
export function getStatusColor(status: PresenceStatus): string {
  switch (status) {
    case 'online':
      return '#22c55e'; // green-500
    case 'away':
      return '#eab308'; // yellow-500
    case 'do_not_disturb':
      return '#ef4444'; // red-500
    case 'offline':
    default:
      return '#6b7280'; // gray-500
  }
}

/**
 * Get status display text
 */
export function getStatusText(status: PresenceStatus): string {
  switch (status) {
    case 'online':
      return 'Online';
    case 'away':
      return 'Away';
    case 'do_not_disturb':
      return 'Do Not Disturb';
    case 'offline':
    default:
      return 'Offline';
  }
}

/**
 * Format typing indicator text
 */
export function formatTypingText(conversationId: string): string {
  const typingNames = getTypingUserNames(conversationId);

  if (typingNames.length === 0) {
    return '';
  } else if (typingNames.length === 1) {
    return `${typingNames[0]} is typing...`;
  } else if (typingNames.length === 2) {
    return `${typingNames[0]} and ${typingNames[1]} are typing...`;
  } else {
    return `${typingNames[0]} and ${typingNames.length - 1} others are typing...`;
  }
}

// =============================================================================
// REACTIVE STORE (for use in components)
// =============================================================================

/**
 * Create a reactive memo for a user's presence
 * Usage: const presence = createPresenceMemo(userId);
 */
export function createPresenceMemo(userId: string | (() => string)) {
  return createMemo(() => {
    const id = typeof userId === 'function' ? userId() : userId;
    return state.presences[id];
  });
}

/**
 * Create a reactive memo for typing users in a conversation
 * Usage: const typingUsers = createTypingMemo(conversationId);
 */
export function createTypingMemo(conversationId: string | (() => string)) {
  return createMemo(() => {
    const id = typeof conversationId === 'function' ? conversationId() : conversationId;
    const conversationTyping = state.typing[id];
    if (!conversationTyping) return [];
    return Object.values(conversationTyping.users);
  });
}

// =============================================================================
// EXPORTS
// =============================================================================

/** Read-only access to presence store state */
export { state as presenceState };
