/**
 * WebSocket Mock Generator
 *
 * Generates fake incoming messages for development/testing.
 * Simulates real-time events like messages, typing, and presence.
 *
 * @module websocket.mock
 */

import {
  type MessagePayload,
  type PresencePayload,
  type PresenceStatus,
  type TypingPayload,
  WsMessageType,
} from './websocket.types';
import type { WebSocketClient } from './websocket';

// =============================================================================
// MOCK DATA
// =============================================================================

const MOCK_USERS = [
  { id: 'user-alice', name: 'Alice Johnson', deviceId: 'device-alice-1' },
  { id: 'user-bob', name: 'Bob Smith', deviceId: 'device-bob-1' },
  { id: 'user-carol', name: 'Carol Williams', deviceId: 'device-carol-1' },
  { id: 'user-dave', name: 'Dave Brown', deviceId: 'device-dave-1' },
];

const MOCK_MESSAGES = [
  "Hey! How's it going?",
  "Just finished the new feature 🎉",
  "Can we schedule a call later?",
  "Thanks for the update!",
  "Looking good! Let me know if you need help.",
  "Did you see the latest commit?",
  "Perfect, I'll take a look",
  "The build passed ✅",
  "Let's discuss this tomorrow",
  "Great work on the PR!",
  "Working on the E2EE integration now",
  "Security audit scheduled for next week",
  "Can you review my PR when you get a chance?",
];

const MOCK_CONVERSATIONS = ['conv-1', 'conv-2', 'conv-3'];

// =============================================================================
// RANDOM HELPERS
// =============================================================================

function randomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomInt(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// =============================================================================
// MOCK GENERATOR
// =============================================================================

export interface MockGeneratorOptions {
  /** Interval for generating mock messages (ms) */
  messageInterval?: number;
  /** Probability of typing indicator before message (0-1) */
  typingProbability?: number;
  /** Duration of typing indicator (ms) */
  typingDuration?: number;
  /** Probability of presence change per interval (0-1) */
  presenceProbability?: number;
  /** Current user ID (to exclude from mock messages) */
  currentUserId?: string;
}

/**
 * Generates mock WebSocket events for development
 */
export class WebSocketMockGenerator {
  private client: WebSocketClient;
  private options: Required<MockGeneratorOptions>;
  private messageTimer: ReturnType<typeof setTimeout> | null = null;
  private presenceTimer: ReturnType<typeof setInterval> | null = null;
  private typingTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();
  private isRunning = false;

  constructor(client: WebSocketClient, options: MockGeneratorOptions = {}) {
    this.client = client;
    this.options = {
      messageInterval: 8000,
      typingProbability: 0.4,
      typingDuration: 2500,
      presenceProbability: 0.15,
      currentUserId: 'stub-user-id',
      ...options,
    };
  }

  /**
   * Start generating mock events
   */
  start(): void {
    if (this.isRunning) return;
    this.isRunning = true;

    // Generate messages at random intervals
    this.scheduleNextMessage();

    // Generate presence changes periodically
    this.presenceTimer = setInterval(() => {
      if (Math.random() < this.options.presenceProbability) {
        this.emitPresenceChange();
      }
    }, 12000);
  }

  /**
   * Stop generating mock events
   */
  stop(): void {
    this.isRunning = false;

    if (this.messageTimer) {
      clearTimeout(this.messageTimer);
      this.messageTimer = null;
    }

    if (this.presenceTimer) {
      clearInterval(this.presenceTimer);
      this.presenceTimer = null;
    }

    this.typingTimers.forEach((timer) => clearTimeout(timer));
    this.typingTimers.clear();
  }

  /**
   * Generate a single mock incoming message
   */
  emitMessage(conversationId?: string, senderId?: string): void {
    const sender = senderId
      ? (MOCK_USERS.find((u) => u.id === senderId) ?? randomItem(MOCK_USERS))
      : randomItem(MOCK_USERS);

    const convId = conversationId ?? randomItem(MOCK_CONVERSATIONS);

    const payload: MessagePayload = {
      message_id: crypto.randomUUID(),
      conversation_id: convId,
      sender_id: sender.id,
      sender_device_id: sender.deviceId,
      recipient_id: this.options.currentUserId,
      content: randomItem(MOCK_MESSAGES),
      encrypted: false,
      content_type: 'text',
      timestamp: new Date().toISOString(),
    };

    // First emit typing stop if was typing
    const typingKey = `${convId}-${sender.id}`;
    if (this.typingTimers.has(typingKey)) {
      clearTimeout(this.typingTimers.get(typingKey));
      this.typingTimers.delete(typingKey);
      this.emitTypingStop(convId, sender.id);
    }

    // Emit the message via the client's internal emitter
    this.emitToClient(WsMessageType.MESSAGE, payload);
  }

  /**
   * Start typing indicator for a user
   */
  emitTypingStart(conversationId: string, userId: string): void {
    const payload: TypingPayload = {
      user_id: userId,
      conversation_id: conversationId,
      is_typing: true,
    };

    this.emitToClient(WsMessageType.TYPING, payload);

    // Auto-stop typing after duration
    const key = `${conversationId}-${userId}`;
    if (this.typingTimers.has(key)) {
      clearTimeout(this.typingTimers.get(key));
    }

    this.typingTimers.set(
      key,
      setTimeout(() => {
        this.emitTypingStop(conversationId, userId);
        this.typingTimers.delete(key);
      }, this.options.typingDuration)
    );
  }

  /**
   * Stop typing indicator for a user
   */
  emitTypingStop(conversationId: string, userId: string): void {
    const payload: TypingPayload = {
      user_id: userId,
      conversation_id: conversationId,
      is_typing: false,
    };

    this.emitToClient(WsMessageType.TYPING, payload);
  }

  /**
   * Emit a presence change
   */
  emitPresenceChange(userId?: string): void {
    const user = userId
      ? (MOCK_USERS.find((u) => u.id === userId) ?? randomItem(MOCK_USERS))
      : randomItem(MOCK_USERS);

    const statuses: PresenceStatus[] = ['online', 'offline', 'away', 'do_not_disturb'];
    const status = randomItem(statuses);

    const payload: PresencePayload = {
      user_id: user.id,
      status,
      last_seen: status === 'offline' ? new Date().toISOString() : undefined,
    };

    this.emitToClient(WsMessageType.PRESENCE, payload);
  }

  // ---------------------------------------------------------------------------
  // PRIVATE METHODS
  // ---------------------------------------------------------------------------

  private scheduleNextMessage(): void {
    if (!this.isRunning) return;

    const interval = randomInt(
      this.options.messageInterval * 0.5,
      this.options.messageInterval * 1.5
    );

    this.messageTimer = setTimeout(() => {
      // Maybe show typing first
      if (Math.random() < this.options.typingProbability) {
        const sender = randomItem(MOCK_USERS);
        const convId = randomItem(MOCK_CONVERSATIONS);

        this.emitTypingStart(convId, sender.id);

        // Then send message after typing
        setTimeout(() => {
          this.emitMessage(convId, sender.id);
        }, this.options.typingDuration);
      } else {
        this.emitMessage();
      }

      this.scheduleNextMessage();
    }, interval);
  }

  /**
   * Emit a message through the client's internal event system
   */
  private emitToClient<T>(type: WsMessageType, payload: T): void {
    // Access the client's internal emitter
    // This is a workaround for the mock generator to emit events
    const clientAny = this.client as unknown as {
      emitter?: { emit: (type: WsMessageType, payload: unknown) => void };
    };

    if (clientAny.emitter && typeof clientAny.emitter.emit === 'function') {
      clientAny.emitter.emit(type, payload);
    }
  }
}

// =============================================================================
// FACTORY
// =============================================================================

let mockGeneratorInstance: WebSocketMockGenerator | null = null;

/**
 * Start the mock generator
 */
export function startMockGenerator(
  client: WebSocketClient,
  options?: MockGeneratorOptions
): WebSocketMockGenerator {
  if (mockGeneratorInstance) {
    mockGeneratorInstance.stop();
  }
  mockGeneratorInstance = new WebSocketMockGenerator(client, options);
  mockGeneratorInstance.start();
  return mockGeneratorInstance;
}

/**
 * Stop the mock generator
 */
export function stopMockGenerator(): void {
  if (mockGeneratorInstance) {
    mockGeneratorInstance.stop();
    mockGeneratorInstance = null;
  }
}

/**
 * Get the current mock generator instance
 */
export function getMockGenerator(): WebSocketMockGenerator | null {
  return mockGeneratorInstance;
}
