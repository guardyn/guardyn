/**
 * WebSocket Client
 *
 * Production-ready real-time communication layer for the Guardyn desktop client.
 * Features:
 * - Auto-reconnect with exponential backoff
 * - Heartbeat/ping-pong for connection health
 * - Message queue for offline resilience
 * - Connection state management
 * - Type-safe message handling
 *
 * @module websocket
 */

import {
    type AuthResponsePayload,
    type ConnectionState,
    DEFAULT_WS_CONFIG,
    type ErrorPayload,
    type MessagePayload,
    type MessageSentPayload,
    type PayloadFor,
    type PongPayload,
    type PresencePayload,
    type PresenceStatus,
    type QueuedMessage,
    type ReadReceiptPayload,
    type SubscriptionType,
    type TypingPayload,
    type WebSocketConfig,
    type WsEventCallback,
    type WsMessage,
    WsMessageType,
    createAuthMessage,
    createMarkReadMessage,
    createPingMessage,
    createPresenceMessage,
    createSendMessage,
    createSubscribeMessage,
    createTypingMessage,
    createUnsubscribeMessage,
    parseWsMessage,
    serializeWsMessage,
} from './websocket.types';

// Re-export types for convenience
export * from './websocket.types';

// =============================================================================
// EVENT EMITTER
// =============================================================================

type EventMap = {
  [K in WsMessageType]?: WsEventCallback<K>[];
};

class TypedEventEmitter {
  private events: EventMap = {};

  on<T extends WsMessageType>(
    type: T,
    callback: WsEventCallback<T>
  ): () => void {
    if (!this.events[type]) {
      this.events[type] = [];
    }
    (this.events[type] as WsEventCallback<T>[]).push(callback);

    // Return unsubscribe function
    return () => {
      const arr = this.events[type] as WsEventCallback<T>[] | undefined;
      if (arr) {
        const idx = arr.indexOf(callback);
        if (idx > -1) arr.splice(idx, 1);
      }
    };
  }

  emit<T extends WsMessageType>(type: T, payload: PayloadFor<T>): void {
    const callbacks = this.events[type] as WsEventCallback<T>[] | undefined;
    callbacks?.forEach((cb) => cb(payload));
  }

  off(type: WsMessageType): void {
    delete this.events[type];
  }

  removeAllListeners(): void {
    this.events = {};
  }
}

// =============================================================================
// WEBSOCKET CLIENT
// =============================================================================

export class WebSocketClient {
  private socket: WebSocket | null = null;
  private emitter = new TypedEventEmitter();
  private config: Required<WebSocketConfig>;

  // State management
  private _state: ConnectionState = 'disconnected';
  private _userId: string | null = null;
  private stateListeners: ((state: ConnectionState) => void)[] = [];

  // Reconnection
  private reconnectAttempts = 0;
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  private currentReconnectInterval: number;

  // Heartbeat
  private pingTimer: ReturnType<typeof setInterval> | null = null;
  private pongTimer: ReturnType<typeof setTimeout> | null = null;
  private _lastPingTime = 0;
  private _latency = 0;

  // Message queue for offline resilience
  private messageQueue: QueuedMessage[] = [];
  private processingQueue = false;

  constructor(options: WebSocketConfig) {
    this.config = {
      ...DEFAULT_WS_CONFIG,
      ...options,
    } as Required<WebSocketConfig>;

    this.currentReconnectInterval = this.config.reconnectInterval;
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API - Properties
  // ---------------------------------------------------------------------------

  get state(): ConnectionState {
    return this._state;
  }

  get userId(): string | null {
    return this._userId;
  }

  get isConnected(): boolean {
    return this._state === 'connected';
  }

  get isStubMode(): boolean {
    return this.config.stubMode;
  }

  get latency(): number {
    return this._latency;
  }

  get lastPingTime(): number {
    return this._lastPingTime;
  }

  get queueSize(): number {
    return this.messageQueue.length;
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API - Connection
  // ---------------------------------------------------------------------------

  /**
   * Connect to the WebSocket server
   */
  async connect(): Promise<void> {
    if (this._state === 'connected' || this._state === 'connecting') {
      console.warn('[WS] Already connected or connecting');
      return;
    }

    if (this.config.stubMode) {
      return this.connectStub();
    }
    return this.connectReal();
  }

  /**
   * Disconnect from the WebSocket server
   */
  disconnect(): void {
    this.clearTimers();
    this.reconnectAttempts = 0;
    this.currentReconnectInterval = this.config.reconnectInterval;

    if (this.socket) {
      this.socket.onclose = null; // Prevent reconnect
      this.socket.close(1000, 'Client disconnect');
      this.socket = null;
    }

    this._state = 'disconnected';
    this._userId = null;
    this.notifyStateChange();
  }

  /**
   * Update authentication token (e.g., after refresh)
   */
  setToken(token: string): void {
    this.config.token = token;
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API - Messaging
  // ---------------------------------------------------------------------------

  /**
   * Send a chat message
   */
  sendMessage(
    recipientId: string,
    content: string,
    options: {
      encrypted?: boolean;
      clientMessageId?: string;
      mediaId?: string;
    } = {}
  ): string {
    const clientMessageId = options.clientMessageId ?? crypto.randomUUID();
    const message = createSendMessage(recipientId, content, {
      ...options,
      clientMessageId,
    });

    this.sendOrQueue(message);
    return clientMessageId;
  }

  /**
   * Send typing indicator
   */
  sendTyping(conversationId: string, isTyping: boolean): void {
    if (!this._userId) return;
    const message = createTypingMessage(conversationId, this._userId, isTyping);
    this.sendDirect(message); // Don't queue typing indicators
  }

  /**
   * Mark messages as read
   */
  markRead(conversationId: string, messageIds: string[]): void {
    const message = createMarkReadMessage(conversationId, messageIds);
    this.sendOrQueue(message);
  }

  /**
   * Update presence status
   */
  updatePresence(status: PresenceStatus): void {
    if (!this._userId) return;
    const message = createPresenceMessage(this._userId, status);
    this.sendOrQueue(message);
  }

  /**
   * Subscribe to updates
   */
  subscribe(type: SubscriptionType, targetIds: string[]): void {
    const message = createSubscribeMessage(type, targetIds);
    this.sendOrQueue(message);
  }

  /**
   * Unsubscribe from updates
   */
  unsubscribe(type: SubscriptionType, targetIds: string[]): void {
    const message = createUnsubscribeMessage(type, targetIds);
    this.sendOrQueue(message);
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API - Event Subscription
  // ---------------------------------------------------------------------------

  /**
   * Subscribe to incoming messages
   */
  onMessage(callback: (payload: MessagePayload) => void): () => void {
    return this.emitter.on(WsMessageType.MESSAGE, callback);
  }

  /**
   * Subscribe to message sent confirmations
   */
  onMessageSent(callback: (payload: MessageSentPayload) => void): () => void {
    return this.emitter.on(WsMessageType.MESSAGE_SENT, callback);
  }

  /**
   * Subscribe to typing indicators
   */
  onTyping(callback: (payload: TypingPayload) => void): () => void {
    return this.emitter.on(WsMessageType.TYPING, callback);
  }

  /**
   * Subscribe to presence updates
   */
  onPresence(callback: (payload: PresencePayload) => void): () => void {
    return this.emitter.on(WsMessageType.PRESENCE, callback);
  }

  /**
   * Subscribe to read receipts
   */
  onReadReceipt(callback: (payload: ReadReceiptPayload) => void): () => void {
    return this.emitter.on(WsMessageType.READ_RECEIPT, callback);
  }

  /**
   * Subscribe to errors
   */
  onError(callback: (payload: ErrorPayload) => void): () => void {
    return this.emitter.on(WsMessageType.ERROR, callback);
  }

  /**
   * Subscribe to any message type
   */
  on<T extends WsMessageType>(
    type: T,
    callback: WsEventCallback<T>
  ): () => void {
    return this.emitter.on(type, callback);
  }

  /**
   * Subscribe to connection state changes
   */
  onStateChange(callback: (state: ConnectionState) => void): () => void {
    this.stateListeners.push(callback);
    return () => {
      const idx = this.stateListeners.indexOf(callback);
      if (idx > -1) this.stateListeners.splice(idx, 1);
    };
  }

  // ---------------------------------------------------------------------------
  // PRIVATE - Connection
  // ---------------------------------------------------------------------------

  private async connectReal(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.setState('connecting');

      try {
        this.socket = new WebSocket(this.config.url);

        this.socket.onopen = () => {
          console.log('[WS] Connected to', this.config.url);
          this.authenticate().then(resolve).catch(reject);
        };

        this.socket.onclose = (event) => {
          console.log('[WS] Connection closed:', event.code, event.reason);
          this.handleDisconnect();
        };

        this.socket.onerror = (error) => {
          console.error('[WS] Error:', error);
          if (this._state === 'connecting') {
            reject(new Error('WebSocket connection failed'));
          }
        };

        this.socket.onmessage = (event) => {
          this.handleMessage(event.data);
        };
      } catch (error) {
        this.setState('disconnected');
        reject(error);
      }
    });
  }

  private async connectStub(): Promise<void> {
    this.setState('connecting');

    // Simulate connection delay
    await new Promise((resolve) => setTimeout(resolve, 300));

    this._userId = 'stub-user-id';
    this.setState('connected');
    console.log('[WS Stub] Connected in stub mode');

    // Start simulating heartbeat for stub mode
    this.startPingInterval();

    return Promise.resolve();
  }

  private async authenticate(): Promise<void> {
    if (!this.config.token) {
      throw new Error('No authentication token provided');
    }

    this.setState('authenticating');

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error('Authentication timeout'));
      }, 10000);

      // Listen for auth response
      const unsubscribe = this.emitter.on(
        WsMessageType.AUTH_RESPONSE,
        (payload: AuthResponsePayload) => {
          clearTimeout(timeout);
          unsubscribe();

          if (payload.success && payload.user_id) {
            this._userId = payload.user_id;
            this.setState('connected');
            this.resetReconnectState();
            this.startPingInterval();
            this.processQueue();
            console.log('[WS] Authenticated as', payload.user_id);
            resolve();
          } else {
            const error = new Error(payload.error || 'Authentication failed');
            this.disconnect();
            reject(error);
          }
        }
      );

      // Send auth message
      const authMessage = createAuthMessage(
        this.config.token,
        this.config.deviceId
      );
      this.sendDirect(authMessage);
    });
  }

  private handleDisconnect(): void {
    this.clearTimers();

    if (this._state === 'disconnected') {
      return; // Already intentionally disconnected
    }

    this.socket = null;
    this._userId = null;

    if (this.config.autoReconnect) {
      this.scheduleReconnect();
    } else {
      this.setState('disconnected');
    }
  }

  private scheduleReconnect(): void {
    if (
      this.config.maxReconnectAttempts > 0 &&
      this.reconnectAttempts >= this.config.maxReconnectAttempts
    ) {
      console.error('[WS] Max reconnect attempts reached');
      this.setState('disconnected');
      return;
    }

    this.setState('reconnecting');
    this.reconnectAttempts++;

    const delay = this.currentReconnectInterval;
    console.log(
      `[WS] Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`
    );

    this.reconnectTimer = setTimeout(async () => {
      try {
        await this.connect();
      } catch (error) {
        console.error('[WS] Reconnection failed:', error);
        // Exponential backoff
        this.currentReconnectInterval = Math.min(
          this.currentReconnectInterval * 2,
          this.config.maxReconnectInterval
        );
      }
    }, delay);
  }

  private resetReconnectState(): void {
    this.reconnectAttempts = 0;
    this.currentReconnectInterval = this.config.reconnectInterval;
  }

  // ---------------------------------------------------------------------------
  // PRIVATE - Message Handling
  // ---------------------------------------------------------------------------

  private handleMessage(data: string): void {
    const message = parseWsMessage(data);
    if (!message) {
      console.warn('[WS] Failed to parse message:', data);
      return;
    }

    // Handle pong for latency measurement
    if (message.type === WsMessageType.PONG) {
      this.handlePong(message.payload as PongPayload);
      return;
    }

    // Handle ping with pong response
    if (message.type === WsMessageType.PING) {
      this.sendPong((message.payload as { timestamp: number }).timestamp);
      return;
    }

    // Emit to subscribers
    this.emitter.emit(message.type, message.payload as PayloadFor<typeof message.type>);
  }

  private sendDirect(message: WsMessage): boolean {
    if (this.config.stubMode) {
      console.log('[WS Stub] Sending:', message);
      return true;
    }

    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      this.socket.send(serializeWsMessage(message));
      return true;
    }

    return false;
  }

  private sendOrQueue(message: WsMessage): void {
    if (!this.sendDirect(message)) {
      this.queueMessage(message);
    }
  }

  // ---------------------------------------------------------------------------
  // PRIVATE - Message Queue
  // ---------------------------------------------------------------------------

  private queueMessage(message: WsMessage): void {
    if (this.messageQueue.length >= this.config.maxQueueSize) {
      console.warn('[WS] Message queue full, dropping oldest message');
      this.messageQueue.shift();
    }

    const queuedMessage: QueuedMessage = {
      queueId: crypto.randomUUID(),
      message,
      queuedAt: Date.now(),
      retries: 0,
      maxRetries: 3,
    };

    this.messageQueue.push(queuedMessage);
    console.log('[WS] Message queued, queue size:', this.messageQueue.length);
  }

  private async processQueue(): Promise<void> {
    if (this.processingQueue || this.messageQueue.length === 0) {
      return;
    }

    this.processingQueue = true;

    while (this.messageQueue.length > 0 && this.isConnected) {
      const item = this.messageQueue[0];

      if (this.sendDirect(item.message)) {
        this.messageQueue.shift();
        console.log('[WS] Sent queued message, remaining:', this.messageQueue.length);
      } else {
        item.retries++;
        if (item.retries >= item.maxRetries) {
          this.messageQueue.shift();
          console.warn('[WS] Dropping message after max retries');
        } else {
          break; // Will retry on next processQueue call
        }
      }

      // Small delay between messages to avoid flooding
      await new Promise((resolve) => setTimeout(resolve, 50));
    }

    this.processingQueue = false;
  }

  // ---------------------------------------------------------------------------
  // PRIVATE - Heartbeat
  // ---------------------------------------------------------------------------

  private startPingInterval(): void {
    this.clearPingTimers();

    this.pingTimer = setInterval(() => {
      this.sendPing();
    }, this.config.pingInterval);
  }

  private sendPing(): void {
    this._lastPingTime = Date.now();
    const pingMessage = createPingMessage();

    if (this.sendDirect(pingMessage)) {
      // Set pong timeout
      this.pongTimer = setTimeout(() => {
        console.warn('[WS] Pong timeout, connection may be dead');
        if (this.socket) {
          this.socket.close(4000, 'Pong timeout');
        }
      }, this.config.pongTimeout);
    }
  }

  private sendPong(pingTimestamp: number): void {
    const pongMessage: WsMessage = {
      type: WsMessageType.PONG,
      payload: {
        timestamp: pingTimestamp,
        server_timestamp: Date.now(),
      },
    };
    this.sendDirect(pongMessage);
  }

  private handlePong(payload: PongPayload): void {
    if (this.pongTimer) {
      clearTimeout(this.pongTimer);
      this.pongTimer = null;
    }

    this._latency = Date.now() - payload.timestamp;
    // console.log('[WS] Latency:', this._latency, 'ms');
  }

  // ---------------------------------------------------------------------------
  // PRIVATE - State & Cleanup
  // ---------------------------------------------------------------------------

  private setState(state: ConnectionState): void {
    if (this._state !== state) {
      this._state = state;
      this.notifyStateChange();
    }
  }

  private notifyStateChange(): void {
    this.stateListeners.forEach((cb) => cb(this._state));
  }

  private clearTimers(): void {
    this.clearPingTimers();

    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
  }

  private clearPingTimers(): void {
    if (this.pingTimer) {
      clearInterval(this.pingTimer);
      this.pingTimer = null;
    }
    if (this.pongTimer) {
      clearTimeout(this.pongTimer);
      this.pongTimer = null;
    }
  }
}

// =============================================================================
// SINGLETON INSTANCE
// =============================================================================

let wsInstance: WebSocketClient | null = null;

/**
 * Get the WebSocket client instance
 * @throws Error if not initialized
 */
export function getWebSocket(): WebSocketClient {
  if (!wsInstance) {
    throw new Error('WebSocket not initialized. Call initWebSocket first.');
  }
  return wsInstance;
}

/**
 * Initialize the WebSocket client
 */
export function initWebSocket(options: WebSocketConfig): WebSocketClient {
  if (wsInstance) {
    wsInstance.disconnect();
  }
  wsInstance = new WebSocketClient(options);
  return wsInstance;
}

/**
 * Destroy the WebSocket client
 */
export function destroyWebSocket(): void {
  if (wsInstance) {
    wsInstance.disconnect();
    wsInstance = null;
  }
}

/**
 * Check if WebSocket is initialized
 */
export function hasWebSocket(): boolean {
  return wsInstance !== null;
}
