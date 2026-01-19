/**
 * WebSocket Mock Generator
 * 
 * Generates fake incoming messages for development/testing.
 * Simulates real-time events like messages, typing, and presence.
 */

import {
    MessageType,
    PresencePayload,
    TextMessagePayload,
    TypingPayload,
    type WebSocketClient
} from './websocket';

// =============================================================================
// MOCK DATA
// =============================================================================

const MOCK_USERS = [
  { id: 'user-alice', name: 'Alice Johnson' },
  { id: 'user-bob', name: 'Bob Smith' },
  { id: 'user-carol', name: 'Carol Williams' },
  { id: 'user-dave', name: 'Dave Brown' },
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
];

const MOCK_CONVERSATIONS = [
  'conv-1',
  'conv-2',
  'conv-3',
];

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
  /** Probability of typing indicator (0-1) */
  typingProbability?: number;
  /** Duration of typing indicator (ms) */
  typingDuration?: number;
  /** Probability of presence change (0-1) */
  presenceProbability?: number;
}

export class WebSocketMockGenerator {
  private client: WebSocketClient;
  private options: Required<MockGeneratorOptions>;
  private messageTimer: ReturnType<typeof setInterval> | null = null;
  private presenceTimer: ReturnType<typeof setInterval> | null = null;
  private typingTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();
  private isRunning = false;

  constructor(client: WebSocketClient, options: MockGeneratorOptions = {}) {
    this.client = client;
    this.options = {
      messageInterval: 5000,
      typingProbability: 0.3,
      typingDuration: 2000,
      presenceProbability: 0.1,
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
    }, 10000);
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
   * Generate a single mock message
   */
  emitMessage(conversationId?: string, senderId?: string): void {
    const sender = senderId 
      ? MOCK_USERS.find(u => u.id === senderId) ?? randomItem(MOCK_USERS)
      : randomItem(MOCK_USERS);
    
    const payload: TextMessagePayload = {
      conversationId: conversationId ?? randomItem(MOCK_CONVERSATIONS),
      senderId: sender.id,
      senderName: sender.name,
      content: randomItem(MOCK_MESSAGES),
      messageId: crypto.randomUUID(),
    };

    // First emit typing stop if was typing
    const typingKey = `${payload.conversationId}-${payload.senderId}`;
    if (this.typingTimers.has(typingKey)) {
      clearTimeout(this.typingTimers.get(typingKey));
      this.typingTimers.delete(typingKey);
      this.emitTypingStop(payload.conversationId, sender.id, sender.name);
    }

    // Emit the message
    (this.client as unknown as { emitter: { emit: (type: MessageType, payload: unknown) => void } })
      .emitter.emit(MessageType.TEXT_MESSAGE, payload);
  }

  /**
   * Start typing indicator for a user
   */
  emitTypingStart(conversationId: string, userId: string, userName: string): void {
    const payload: TypingPayload = {
      conversationId,
      userId,
      userName,
    };

    (this.client as unknown as { emitter: { emit: (type: MessageType, payload: unknown) => void } })
      .emitter.emit(MessageType.TYPING_START, payload);

    // Auto-stop typing after duration
    const key = `${conversationId}-${userId}`;
    if (this.typingTimers.has(key)) {
      clearTimeout(this.typingTimers.get(key));
    }

    this.typingTimers.set(key, setTimeout(() => {
      this.emitTypingStop(conversationId, userId, userName);
      this.typingTimers.delete(key);
    }, this.options.typingDuration));
  }

  /**
   * Stop typing indicator for a user
   */
  emitTypingStop(conversationId: string, userId: string, userName: string): void {
    const payload: TypingPayload = {
      conversationId,
      userId,
      userName,
    };

    (this.client as unknown as { emitter: { emit: (type: MessageType, payload: unknown) => void } })
      .emitter.emit(MessageType.TYPING_STOP, payload);
  }

  /**
   * Emit a presence change
   */
  emitPresenceChange(userId?: string): void {
    const user = userId 
      ? MOCK_USERS.find(u => u.id === userId) ?? randomItem(MOCK_USERS)
      : randomItem(MOCK_USERS);

    const statuses: PresencePayload['status'][] = ['online', 'offline', 'away', 'busy'];
    const payload: PresencePayload = {
      userId: user.id,
      status: randomItem(statuses),
      lastSeen: Date.now(),
    };

    (this.client as unknown as { emitter: { emit: (type: MessageType, payload: unknown) => void } })
      .emitter.emit(MessageType.PRESENCE_UPDATE, payload);
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
        
        this.emitTypingStart(convId, sender.id, sender.name);
        
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
}

// =============================================================================
// FACTORY
// =============================================================================

let mockGeneratorInstance: WebSocketMockGenerator | null = null;

export function startMockGenerator(client: WebSocketClient, options?: MockGeneratorOptions): WebSocketMockGenerator {
  if (mockGeneratorInstance) {
    mockGeneratorInstance.stop();
  }
  mockGeneratorInstance = new WebSocketMockGenerator(client, options);
  mockGeneratorInstance.start();
  return mockGeneratorInstance;
}

export function stopMockGenerator(): void {
  if (mockGeneratorInstance) {
    mockGeneratorInstance.stop();
    mockGeneratorInstance = null;
  }
}
