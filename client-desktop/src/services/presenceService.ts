/**
 * Presence Service
 *
 * Bridges WebSocket real-time events with the presence store.
 * Handles:
 * - Presence status updates (online/offline/away/dnd)
 * - Typing indicators with debouncing
 * - Subscription management for user presence
 * - Broadcasting current user's status
 *
 * @module services/presenceService
 */

import { WebSocketClient } from '../api/websocket';
import type { PresencePayload, PresenceStatus, TypingPayload } from '../api/websocket.types';
import {
    cleanupStalePresences,
    clearAllTyping,
    clearUserTyping,
    resetPresenceStore,
    setBroadcasting,
    setMyStatus,
    setUserTyping,
    updatePresence,
} from '../stores/presenceStore';

// =============================================================================
// TYPES
// =============================================================================

/**
 * Presence service configuration
 */
export interface PresenceServiceConfig {
  /** WebSocket client instance */
  wsClient: WebSocketClient;
  /** Current user ID */
  userId: string;
  /** User display name (for typing indicators) */
  displayName?: string;
  /** Debounce interval for typing events (ms) */
  typingDebounceMs?: number;
  /** Interval for broadcasting own presence (ms) */
  presenceBroadcastIntervalMs?: number;
  /** Interval for cleaning up stale presences (ms) */
  cleanupIntervalMs?: number;
}

/**
 * Typing state for debouncing
 */
interface TypingState {
  isTyping: boolean;
  lastSent: number;
  timeoutId: ReturnType<typeof setTimeout> | null;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const DEFAULT_TYPING_DEBOUNCE_MS = 3000;
const DEFAULT_PRESENCE_BROADCAST_MS = 30000;
const DEFAULT_CLEANUP_INTERVAL_MS = 60000;

// =============================================================================
// PRESENCE SERVICE
// =============================================================================

/**
 * Service for managing presence and typing indicators
 */
class PresenceService {
  private wsClient: WebSocketClient | null = null;
  private userId: string | null = null;
  private displayName: string = 'Unknown';
  private typingDebounceMs: number = DEFAULT_TYPING_DEBOUNCE_MS;
  private presenceBroadcastIntervalMs: number = DEFAULT_PRESENCE_BROADCAST_MS;
  private cleanupIntervalMs: number = DEFAULT_CLEANUP_INTERVAL_MS;

  // Typing debounce state per conversation
  private typingStates: Map<string, TypingState> = new Map();

  // Subscriptions
  private unsubscribers: Array<() => void> = [];

  // Intervals
  private broadcastIntervalId: ReturnType<typeof setInterval> | null = null;
  private cleanupIntervalId: ReturnType<typeof setInterval> | null = null;

  // Subscribed user IDs for presence
  private subscribedUsers: Set<string> = new Set();

  /**
   * Initialize the presence service
   */
  initialize(config: PresenceServiceConfig): void {
    this.cleanup();

    this.wsClient = config.wsClient;
    this.userId = config.userId;
    this.displayName = config.displayName ?? 'Unknown';
    this.typingDebounceMs = config.typingDebounceMs ?? DEFAULT_TYPING_DEBOUNCE_MS;
    this.presenceBroadcastIntervalMs = config.presenceBroadcastIntervalMs ?? DEFAULT_PRESENCE_BROADCAST_MS;
    this.cleanupIntervalMs = config.cleanupIntervalMs ?? DEFAULT_CLEANUP_INTERVAL_MS;

    this.setupEventListeners();
    this.startIntervals();

    // Set initial broadcasting state
    setBroadcasting(true);

    // eslint-disable-next-line no-console
    console.log('[PresenceService] Initialized for user:', this.userId);
  }

  /**
   * Clean up resources
   */
  cleanup(): void {
    // Unsubscribe from WebSocket events
    for (const unsub of this.unsubscribers) {
      unsub();
    }
    this.unsubscribers = [];

    // Clear all typing timeouts
    for (const state of this.typingStates.values()) {
      if (state.timeoutId) {
        clearTimeout(state.timeoutId);
      }
    }
    this.typingStates.clear();

    // Clear intervals
    if (this.broadcastIntervalId) {
      clearInterval(this.broadcastIntervalId);
      this.broadcastIntervalId = null;
    }
    if (this.cleanupIntervalId) {
      clearInterval(this.cleanupIntervalId);
      this.cleanupIntervalId = null;
    }

    // Clear store
    clearAllTyping();
    setBroadcasting(false);

    this.subscribedUsers.clear();
    this.wsClient = null;
    this.userId = null;
  }

  /**
   * Reset the service and store
   */
  reset(): void {
    this.cleanup();
    resetPresenceStore();
  }

  /**
   * Get the current user's display name
   */
  getDisplayName(): string {
    return this.displayName;
  }

  /**
   * Get the current user's ID
   */
  getUserId(): string | null {
    return this.userId;
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API - Presence
  // ---------------------------------------------------------------------------

  /**
   * Set current user's presence status
   */
  setStatus(status: PresenceStatus): void {
    if (!this.wsClient || !this.userId) {
      // eslint-disable-next-line no-console
      console.warn('[PresenceService] Not initialized');
      return;
    }

    setMyStatus(status);
    this.wsClient.updatePresence(status);

    // eslint-disable-next-line no-console
    console.log('[PresenceService] Status updated to:', status);
  }

  /**
   * Subscribe to presence updates for a list of users
   */
  subscribeToUsers(userIds: string[]): void {
    if (!this.wsClient) return;

    // Filter out already subscribed users
    const newUserIds = userIds.filter(id => !this.subscribedUsers.has(id));
    if (newUserIds.length === 0) return;

    // Add to subscribed set
    for (const id of newUserIds) {
      this.subscribedUsers.add(id);
    }

    // Subscribe via WebSocket
    this.wsClient.subscribe('presence', newUserIds);

    // eslint-disable-next-line no-console
    console.log('[PresenceService] Subscribed to presence for:', newUserIds);
  }

  /**
   * Unsubscribe from presence updates for a list of users
   */
  unsubscribeFromUsers(userIds: string[]): void {
    if (!this.wsClient) return;

    // Filter to only subscribed users
    const toUnsubscribe = userIds.filter(id => this.subscribedUsers.has(id));
    if (toUnsubscribe.length === 0) return;

    // Remove from subscribed set
    for (const id of toUnsubscribe) {
      this.subscribedUsers.delete(id);
    }

    // Unsubscribe via WebSocket
    this.wsClient.unsubscribe('presence', toUnsubscribe);

    // eslint-disable-next-line no-console
    console.log('[PresenceService] Unsubscribed from presence for:', toUnsubscribe);
  }

  /**
   * Get list of currently subscribed user IDs
   */
  getSubscribedUsers(): string[] {
    return Array.from(this.subscribedUsers);
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API - Typing
  // ---------------------------------------------------------------------------

  /**
   * Notify that current user started typing in a conversation
   * Uses debouncing to avoid flooding the server
   */
  startTyping(conversationId: string): void {
    if (!this.wsClient || !this.userId) return;

    let state = this.typingStates.get(conversationId);
    const now = Date.now();

    // If not currently typing, or debounce interval passed, send update
    if (!state) {
      state = { isTyping: false, lastSent: 0, timeoutId: null };
      this.typingStates.set(conversationId, state);
    }

    // Clear existing stop timeout
    if (state.timeoutId) {
      clearTimeout(state.timeoutId);
      state.timeoutId = null;
    }

    // Send if not already typing or debounce interval passed
    if (!state.isTyping || now - state.lastSent > this.typingDebounceMs) {
      state.isTyping = true;
      state.lastSent = now;
      this.wsClient.sendTyping(conversationId, true);
    }

    // Set timeout to auto-stop typing
    state.timeoutId = setTimeout(() => {
      this.stopTypingInternal(conversationId, false);
    }, this.typingDebounceMs);
  }

  /**
   * Notify that current user stopped typing in a conversation
   */
  stopTyping(conversationId: string): void {
    this.stopTypingInternal(conversationId, true);
  }

  /**
   * Internal stop typing with option to send update
   */
  private stopTypingInternal(conversationId: string, sendUpdate: boolean): void {
    const state = this.typingStates.get(conversationId);
    if (!state) return;

    if (state.timeoutId) {
      clearTimeout(state.timeoutId);
      state.timeoutId = null;
    }

    if (state.isTyping && sendUpdate && this.wsClient) {
      this.wsClient.sendTyping(conversationId, false);
    }

    state.isTyping = false;
    this.typingStates.delete(conversationId);
  }

  /**
   * Subscribe to typing updates for a conversation
   */
  subscribeToTyping(conversationId: string): void {
    if (!this.wsClient) return;
    this.wsClient.subscribe('typing', [conversationId]);
  }

  /**
   * Unsubscribe from typing updates for a conversation
   */
  unsubscribeFromTyping(conversationId: string): void {
    if (!this.wsClient) return;
    this.wsClient.unsubscribe('typing', [conversationId]);

    // Clear typing state for this conversation when unsubscribing
    this.stopTypingInternal(conversationId, false);
  }

  // ---------------------------------------------------------------------------
  // PRIVATE - Event Handlers
  // ---------------------------------------------------------------------------

  private setupEventListeners(): void {
    if (!this.wsClient) return;

    // Handle presence updates
    const unsubPresence = this.wsClient.onPresence(this.handlePresenceUpdate.bind(this));
    this.unsubscribers.push(unsubPresence);

    // Handle typing updates
    const unsubTyping = this.wsClient.onTyping(this.handleTypingUpdate.bind(this));
    this.unsubscribers.push(unsubTyping);

    // Handle connection state changes
    const unsubState = this.wsClient.onStateChange(this.handleConnectionChange.bind(this));
    this.unsubscribers.push(unsubState);
  }

  private handlePresenceUpdate(payload: PresencePayload): void {
    // Don't process our own presence updates
    if (payload.user_id === this.userId) return;

    updatePresence(payload.user_id, payload.status, payload.last_seen);
  }

  private handleTypingUpdate(payload: TypingPayload): void {
    // Don't process our own typing updates
    if (payload.user_id === this.userId) return;

    if (payload.is_typing) {
      // Get display name from somewhere (could be enhanced with user lookup)
      setUserTyping(payload.conversation_id, payload.user_id);
    } else {
      clearUserTyping(payload.conversation_id, payload.user_id);
    }
  }

  private handleConnectionChange(state: string): void {
    if (state === 'connected') {
      // Re-subscribe to all previously subscribed users
      if (this.subscribedUsers.size > 0 && this.wsClient) {
        this.wsClient.subscribe('presence', Array.from(this.subscribedUsers));
      }

      // Broadcast our presence as online
      this.broadcastPresence();
    } else if (state === 'disconnected') {
      // Clear all typing indicators on disconnect
      clearAllTyping();
    }
  }

  // ---------------------------------------------------------------------------
  // PRIVATE - Intervals
  // ---------------------------------------------------------------------------

  private startIntervals(): void {
    // Periodic presence broadcast
    this.broadcastIntervalId = setInterval(() => {
      this.broadcastPresence();
    }, this.presenceBroadcastIntervalMs);

    // Periodic cleanup of stale presences
    this.cleanupIntervalId = setInterval(() => {
      cleanupStalePresences();
    }, this.cleanupIntervalMs);
  }

  private broadcastPresence(): void {
    if (!this.wsClient || !this.wsClient.isConnected) return;

    // Get current status from store
    const status = this.getMyStatus();
    this.wsClient.updatePresence(status);
  }

  private getMyStatus(): PresenceStatus {
    // Import dynamically to avoid circular dependency
    // In real implementation, this would come from the store
    return 'online';
  }
}

// =============================================================================
// SINGLETON EXPORT
// =============================================================================

export const presenceService = new PresenceService();

// =============================================================================
// CONVENIENCE FUNCTIONS
// =============================================================================

/**
 * Initialize the presence service with a WebSocket client
 */
export function initializePresenceService(config: PresenceServiceConfig): void {
  presenceService.initialize(config);
}

/**
 * Set the current user's presence status
 */
export function setPresenceStatus(status: PresenceStatus): void {
  presenceService.setStatus(status);
}

/**
 * Notify that the user started typing
 */
export function startTyping(conversationId: string): void {
  presenceService.startTyping(conversationId);
}

/**
 * Notify that the user stopped typing
 */
export function stopTyping(conversationId: string): void {
  presenceService.stopTyping(conversationId);
}

/**
 * Subscribe to presence updates for users
 */
export function subscribeToPresence(userIds: string[]): void {
  presenceService.subscribeToUsers(userIds);
}

/**
 * Unsubscribe from presence updates for users
 */
export function unsubscribeFromPresence(userIds: string[]): void {
  presenceService.unsubscribeFromUsers(userIds);
}

/**
 * Subscribe to typing updates for a conversation
 */
export function subscribeToTypingIndicators(conversationId: string): void {
  presenceService.subscribeToTyping(conversationId);
}

/**
 * Unsubscribe from typing updates for a conversation
 */
export function unsubscribeFromTypingIndicators(conversationId: string): void {
  presenceService.unsubscribeFromTyping(conversationId);
}

/**
 * Clean up the presence service
 */
export function cleanupPresenceService(): void {
  presenceService.cleanup();
}

/**
 * Reset the presence service and store
 */
export function resetPresenceService(): void {
  presenceService.reset();
}
