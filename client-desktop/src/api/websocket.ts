/**
 * WebSocket Client
 * 
 * Real-time communication layer for the Guardyn desktop client.
 * Supports both real WebSocket connections and stub mode for development.
 */

// =============================================================================
// TYPES
// =============================================================================

export type ConnectionState = 'disconnected' | 'connecting' | 'connected' | 'reconnecting';

export enum MessageType {
  // Chat messages
  TEXT_MESSAGE = 'text_message',
  MESSAGE_DELIVERED = 'message_delivered',
  MESSAGE_READ = 'message_read',
  MESSAGE_DELETED = 'message_deleted',
  MESSAGE_EDITED = 'message_edited',
  
  // Typing indicators
  TYPING_START = 'typing_start',
  TYPING_STOP = 'typing_stop',
  
  // Presence
  PRESENCE_UPDATE = 'presence_update',
  USER_ONLINE = 'user_online',
  USER_OFFLINE = 'user_offline',
  
  // Reactions
  REACTION_ADD = 'reaction_add',
  REACTION_REMOVE = 'reaction_remove',
  
  // System
  ACK = 'ack',
  ERROR = 'error',
  PING = 'ping',
  PONG = 'pong',
}

export interface WebSocketMessage<T = unknown> {
  id: string;
  type: MessageType;
  payload: T;
  timestamp: number;
}

export interface TextMessagePayload {
  conversationId: string;
  senderId: string;
  senderName: string;
  content: string;
  messageId: string;
}

export interface TypingPayload {
  conversationId: string;
  userId: string;
  userName: string;
}

export interface PresencePayload {
  userId: string;
  status: 'online' | 'offline' | 'away' | 'busy';
  lastSeen?: number;
}

export interface MessageReadPayload {
  conversationId: string;
  messageId: string;
  readBy: string;
  readAt: number;
}

type EventCallback<T = unknown> = (data: T) => void;
type EventMap = {
  [K in MessageType]?: EventCallback[];
};

// =============================================================================
// EVENT EMITTER
// =============================================================================

class EventEmitter {
  private events: EventMap = {};

  on<T>(event: MessageType, callback: EventCallback<T>): () => void {
    if (!this.events[event]) {
      this.events[event] = [];
    }
    this.events[event]!.push(callback as EventCallback);

    // Return unsubscribe function
    return () => {
      const idx = this.events[event]?.indexOf(callback as EventCallback);
      if (idx !== undefined && idx > -1) {
        this.events[event]?.splice(idx, 1);
      }
    };
  }

  emit<T>(event: MessageType, data: T): void {
    this.events[event]?.forEach((callback) => callback(data));
  }

  off(event: MessageType): void {
    delete this.events[event];
  }

  removeAllListeners(): void {
    this.events = {};
  }
}

// =============================================================================
// WEBSOCKET CLIENT
// =============================================================================

export interface WebSocketClientOptions {
  /** WebSocket server URL */
  url: string;
  /** Enable stub mode (mock data) */
  stubMode?: boolean;
  /** Auto-reconnect on disconnect */
  autoReconnect?: boolean;
  /** Reconnect interval in ms */
  reconnectInterval?: number;
  /** Maximum reconnect attempts */
  maxReconnectAttempts?: number;
  /** Ping interval in ms */
  pingInterval?: number;
}

export class WebSocketClient {
  private socket: WebSocket | null = null;
  private emitter = new EventEmitter();
  private options: Required<WebSocketClientOptions>;
  private reconnectAttempts = 0;
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  private pingTimer: ReturnType<typeof setInterval> | null = null;
  
  private _state: ConnectionState = 'disconnected';
  private stateListeners: ((state: ConnectionState) => void)[] = [];

  constructor(options: WebSocketClientOptions) {
    this.options = {
      stubMode: false,
      autoReconnect: true,
      reconnectInterval: 3000,
      maxReconnectAttempts: 10,
      pingInterval: 30000,
      ...options,
    };
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API
  // ---------------------------------------------------------------------------

  get state(): ConnectionState {
    return this._state;
  }

  get isConnected(): boolean {
    return this._state === 'connected';
  }

  get isStubMode(): boolean {
    return this.options.stubMode;
  }

  /**
   * Connect to the WebSocket server
   */
  connect(): Promise<void> {
    if (this.options.stubMode) {
      return this.connectStub();
    }
    return this.connectReal();
  }

  /**
   * Disconnect from the WebSocket server
   */
  disconnect(): void {
    this.clearTimers();
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
    this.setState('disconnected');
    this.reconnectAttempts = 0;
  }

  /**
   * Send a message through the WebSocket
   */
  send<T>(type: MessageType, payload: T): void {
    const message: WebSocketMessage<T> = {
      id: crypto.randomUUID(),
      type,
      payload,
      timestamp: Date.now(),
    };

    if (this.options.stubMode) {
      // In stub mode, just emit locally
      console.log('[WS Stub] Sending:', message);
      return;
    }

    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      this.socket.send(JSON.stringify(message));
    } else {
      console.warn('[WS] Cannot send message, socket not connected');
    }
  }

  /**
   * Subscribe to a message type
   */
  on<T>(type: MessageType, callback: EventCallback<T>): () => void {
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
  // PRIVATE METHODS
  // ---------------------------------------------------------------------------

  private setState(state: ConnectionState): void {
    this._state = state;
    this.stateListeners.forEach((cb) => cb(state));
  }

  private async connectReal(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.setState('connecting');

      try {
        this.socket = new WebSocket(this.options.url);

        this.socket.onopen = () => {
          this.setState('connected');
          this.reconnectAttempts = 0;
          this.startPingInterval();
          resolve();
        };

        this.socket.onclose = () => {
          this.setState('disconnected');
          this.clearTimers();
          if (this.options.autoReconnect) {
            this.scheduleReconnect();
          }
        };

        this.socket.onerror = (error) => {
          console.error('[WS] Error:', error);
          reject(error);
        };

        this.socket.onmessage = (event) => {
          try {
            const message = JSON.parse(event.data) as WebSocketMessage;
            this.emitter.emit(message.type, message.payload);
          } catch (e) {
            console.error('[WS] Failed to parse message:', e);
          }
        };
      } catch (error) {
        reject(error);
      }
    });
  }

  private async connectStub(): Promise<void> {
    this.setState('connecting');
    
    // Simulate connection delay
    await new Promise((resolve) => setTimeout(resolve, 500));
    
    this.setState('connected');
    console.log('[WS Stub] Connected in stub mode');
    
    return Promise.resolve();
  }

  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= this.options.maxReconnectAttempts) {
      console.error('[WS] Max reconnect attempts reached');
      return;
    }

    this.setState('reconnecting');
    this.reconnectAttempts++;

    this.reconnectTimer = setTimeout(() => {
      console.log(`[WS] Reconnecting... (attempt ${this.reconnectAttempts})`);
      this.connect().catch(() => {
        // Will trigger scheduleReconnect again via onclose
      });
    }, this.options.reconnectInterval);
  }

  private startPingInterval(): void {
    this.pingTimer = setInterval(() => {
      this.send(MessageType.PING, {});
    }, this.options.pingInterval);
  }

  private clearTimers(): void {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
    if (this.pingTimer) {
      clearInterval(this.pingTimer);
      this.pingTimer = null;
    }
  }
}

// =============================================================================
// SINGLETON INSTANCE
// =============================================================================

let wsInstance: WebSocketClient | null = null;

export function getWebSocket(): WebSocketClient {
  if (!wsInstance) {
    throw new Error('WebSocket not initialized. Call initWebSocket first.');
  }
  return wsInstance;
}

export function initWebSocket(options: WebSocketClientOptions): WebSocketClient {
  if (wsInstance) {
    wsInstance.disconnect();
  }
  wsInstance = new WebSocketClient(options);
  return wsInstance;
}

export function destroyWebSocket(): void {
  if (wsInstance) {
    wsInstance.disconnect();
    wsInstance = null;
  }
}
