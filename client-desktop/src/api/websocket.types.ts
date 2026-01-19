/**
 * WebSocket Message Types
 *
 * Defines the JSON message format for WebSocket communication.
 * MUST match the backend protocol from messaging-service/src/websocket/messages.rs
 *
 * @module websocket.types
 */

// =============================================================================
// CONNECTION STATES
// =============================================================================

/**
 * WebSocket connection state
 */
export type ConnectionState =
  | 'disconnected'
  | 'connecting'
  | 'connected'
  | 'reconnecting'
  | 'authenticating';

/**
 * Presence status
 */
export type PresenceStatus = 'online' | 'offline' | 'away' | 'do_not_disturb';

/**
 * Subscription types for real-time updates
 */
export type SubscriptionType = 'conversation' | 'presence' | 'typing';

/**
 * Content type for messages
 */
export type ContentType = 'text' | 'image' | 'file' | 'audio' | 'video' | 'location';

// =============================================================================
// MESSAGE TYPE ENUM
// =============================================================================

/**
 * WebSocket message types - matches backend enum
 */
export enum WsMessageType {
  // Authentication
  AUTH = 'auth',
  AUTH_RESPONSE = 'auth_response',

  // Messaging
  SEND_MESSAGE = 'send_message',
  MESSAGE = 'message',
  MESSAGE_SENT = 'message_sent',

  // Typing indicators
  TYPING = 'typing',

  // Presence
  PRESENCE = 'presence',

  // Read receipts
  MARK_READ = 'mark_read',
  READ_RECEIPT = 'read_receipt',

  // Subscriptions
  SUBSCRIBE = 'subscribe',
  UNSUBSCRIBE = 'unsubscribe',

  // System
  PING = 'ping',
  PONG = 'pong',
  ERROR = 'error',
}

// =============================================================================
// PAYLOAD INTERFACES
// =============================================================================

/**
 * Authentication request payload (client → server)
 */
export interface AuthPayload {
  /** JWT token for authentication */
  token: string;
  /** Device ID for multi-device support */
  device_id?: string;
}

/**
 * Authentication response payload (server → client)
 */
export interface AuthResponsePayload {
  /** Whether authentication was successful */
  success: boolean;
  /** User ID if authenticated */
  user_id?: string;
  /** Error message if authentication failed */
  error?: string;
}

/**
 * Send message payload (client → server)
 */
export interface SendMessagePayload {
  /** Recipient user ID */
  recipient_id: string;
  /** Message content (plaintext or encrypted) */
  content: string;
  /** Whether content is E2EE encrypted */
  encrypted: boolean;
  /** Client-generated message ID for idempotency */
  client_message_id?: string;
  /** Content type (text, image, file, etc.) */
  content_type: ContentType;
}

/**
 * Received message payload (server → client)
 */
export interface MessagePayload {
  /** Server-generated message ID */
  message_id: string;
  /** Conversation ID (deterministic from sender+recipient for 1-on-1) */
  conversation_id?: string;
  /** Sender user ID */
  sender_id: string;
  /** Sender device ID (required for E2EE session lookup) */
  sender_device_id: string;
  /** Recipient user ID */
  recipient_id: string;
  /** Message content */
  content: string;
  /** Whether content is encrypted */
  encrypted: boolean;
  /** Content type */
  content_type: ContentType;
  /** Timestamp (ISO 8601) */
  timestamp: string;
  /** Client message ID if provided */
  client_message_id?: string;
  /** X3DH prekey data for first message in session (Base64 encoded) */
  x3dh_prekey?: string;
}

/**
 * Message sent confirmation (server → client)
 */
export interface MessageSentPayload {
  /** Server-generated message ID */
  message_id: string;
  /** Client message ID if provided */
  client_message_id?: string;
  /** Timestamp (ISO 8601) */
  timestamp: string;
}

/**
 * Typing indicator payload (bidirectional)
 */
export interface TypingPayload {
  /** User ID who is typing */
  user_id: string;
  /** Conversation ID (recipient for 1-on-1, group ID for groups) */
  conversation_id: string;
  /** Whether user is typing (true) or stopped typing (false) */
  is_typing: boolean;
}

/**
 * Presence update payload (bidirectional)
 */
export interface PresencePayload {
  /** User ID whose presence changed */
  user_id: string;
  /** Online status */
  status: PresenceStatus;
  /** Last seen timestamp (ISO 8601) for offline status */
  last_seen?: string;
}

/**
 * Mark messages as read payload (client → server)
 */
export interface MarkReadPayload {
  /** Conversation ID */
  conversation_id: string;
  /** Message IDs to mark as read */
  message_ids: string[];
}

/**
 * Read receipt payload (server → client)
 */
export interface ReadReceiptPayload {
  /** User who read the messages */
  user_id: string;
  /** Conversation ID */
  conversation_id: string;
  /** Message IDs that were read */
  message_ids: string[];
  /** Timestamp when messages were read */
  read_at: string;
}

/**
 * Subscribe to updates payload (client → server)
 */
export interface SubscribePayload {
  /** Subscription type: "conversation", "presence", "typing" */
  subscription_type: SubscriptionType;
  /** Target IDs (conversation IDs for messages, user IDs for presence) */
  target_ids: string[];
}

/**
 * Unsubscribe from updates payload (client → server)
 */
export interface UnsubscribePayload {
  /** Subscription type: "conversation", "presence", "typing" */
  subscription_type: SubscriptionType;
  /** Target IDs to unsubscribe from */
  target_ids: string[];
}

/**
 * Ping payload for heartbeat (bidirectional)
 */
export interface PingPayload {
  /** Timestamp for latency measurement (Unix ms) */
  timestamp: number;
}

/**
 * Pong payload for heartbeat response (bidirectional)
 */
export interface PongPayload {
  /** Echo of the ping timestamp */
  timestamp: number;
  /** Server timestamp */
  server_timestamp: number;
}

/**
 * Error payload (server → client)
 */
export interface ErrorPayload {
  /** Error code */
  code: string;
  /** Human-readable error message */
  message: string;
  /** Optional context (e.g., which message failed) */
  context?: string;
}

// =============================================================================
// MESSAGE WRAPPER
// =============================================================================

/**
 * Base WebSocket message structure
 * Uses tagged union pattern matching backend Rust enum
 */
export type WsMessage =
  | { type: WsMessageType.AUTH; payload: AuthPayload }
  | { type: WsMessageType.AUTH_RESPONSE; payload: AuthResponsePayload }
  | { type: WsMessageType.SEND_MESSAGE; payload: SendMessagePayload }
  | { type: WsMessageType.MESSAGE; payload: MessagePayload }
  | { type: WsMessageType.MESSAGE_SENT; payload: MessageSentPayload }
  | { type: WsMessageType.TYPING; payload: TypingPayload }
  | { type: WsMessageType.PRESENCE; payload: PresencePayload }
  | { type: WsMessageType.MARK_READ; payload: MarkReadPayload }
  | { type: WsMessageType.READ_RECEIPT; payload: ReadReceiptPayload }
  | { type: WsMessageType.SUBSCRIBE; payload: SubscribePayload }
  | { type: WsMessageType.UNSUBSCRIBE; payload: UnsubscribePayload }
  | { type: WsMessageType.PING; payload: PingPayload }
  | { type: WsMessageType.PONG; payload: PongPayload }
  | { type: WsMessageType.ERROR; payload: ErrorPayload };

// =============================================================================
// HELPER TYPES
// =============================================================================

/**
 * Extract payload type for a given message type
 */
export type PayloadFor<T extends WsMessageType> = Extract<
  WsMessage,
  { type: T }
>['payload'];

/**
 * Event callback type for WebSocket events
 */
export type WsEventCallback<T extends WsMessageType> = (
  payload: PayloadFor<T>
) => void;

/**
 * Offline message queue item
 */
export interface QueuedMessage {
  /** Unique queue ID */
  queueId: string;
  /** Message to send */
  message: WsMessage;
  /** Timestamp when queued */
  queuedAt: number;
  /** Number of retry attempts */
  retries: number;
  /** Maximum retries before dropping */
  maxRetries: number;
}

/**
 * WebSocket client configuration
 */
export interface WebSocketConfig {
  /** WebSocket server URL */
  url: string;
  /** Enable stub mode (mock data for development) */
  stubMode?: boolean;
  /** Auto-reconnect on disconnect */
  autoReconnect?: boolean;
  /** Initial reconnect interval in ms */
  reconnectInterval?: number;
  /** Maximum reconnect interval in ms (for exponential backoff) */
  maxReconnectInterval?: number;
  /** Maximum reconnect attempts (0 = infinite) */
  maxReconnectAttempts?: number;
  /** Heartbeat ping interval in ms */
  pingInterval?: number;
  /** Pong timeout in ms (disconnect if no pong received) */
  pongTimeout?: number;
  /** Maximum offline message queue size */
  maxQueueSize?: number;
  /** JWT token for authentication */
  token?: string;
  /** Device ID for multi-device support */
  deviceId?: string;
}

/**
 * Default WebSocket configuration
 */
export const DEFAULT_WS_CONFIG: Required<Omit<WebSocketConfig, 'url' | 'token' | 'deviceId'>> = {
  stubMode: false,
  autoReconnect: true,
  reconnectInterval: 1000,
  maxReconnectInterval: 30000,
  maxReconnectAttempts: 0, // Infinite
  pingInterval: 30000,
  pongTimeout: 10000,
  maxQueueSize: 100,
};

// =============================================================================
// ERROR CODES
// =============================================================================

/**
 * Known WebSocket error codes from backend
 */
export const WsErrorCode = {
  // Authentication errors
  AUTH_REQUIRED: 'AUTH_REQUIRED',
  AUTH_FAILED: 'AUTH_FAILED',
  TOKEN_EXPIRED: 'TOKEN_EXPIRED',
  INVALID_TOKEN: 'INVALID_TOKEN',

  // Message errors
  INVALID_MESSAGE: 'INVALID_MESSAGE',
  MESSAGE_TOO_LARGE: 'MESSAGE_TOO_LARGE',
  RECIPIENT_NOT_FOUND: 'RECIPIENT_NOT_FOUND',
  CONVERSATION_NOT_FOUND: 'CONVERSATION_NOT_FOUND',

  // Rate limiting
  RATE_LIMITED: 'RATE_LIMITED',
  TOO_MANY_CONNECTIONS: 'TOO_MANY_CONNECTIONS',

  // Server errors
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
} as const;

export type WsErrorCodeType = (typeof WsErrorCode)[keyof typeof WsErrorCode];

// =============================================================================
// MESSAGE FACTORIES
// =============================================================================

/**
 * Create an auth message
 */
export function createAuthMessage(token: string, deviceId?: string): WsMessage {
  return {
    type: WsMessageType.AUTH,
    payload: { token, device_id: deviceId },
  };
}

/**
 * Create a send message
 */
export function createSendMessage(
  recipientId: string,
  content: string,
  options: {
    encrypted?: boolean;
    contentType?: ContentType;
    clientMessageId?: string;
  } = {}
): WsMessage {
  return {
    type: WsMessageType.SEND_MESSAGE,
    payload: {
      recipient_id: recipientId,
      content,
      encrypted: options.encrypted ?? false,
      content_type: options.contentType ?? 'text',
      client_message_id: options.clientMessageId ?? crypto.randomUUID(),
    },
  };
}

/**
 * Create a typing indicator message
 */
export function createTypingMessage(
  conversationId: string,
  userId: string,
  isTyping: boolean
): WsMessage {
  return {
    type: WsMessageType.TYPING,
    payload: {
      user_id: userId,
      conversation_id: conversationId,
      is_typing: isTyping,
    },
  };
}

/**
 * Create a mark read message
 */
export function createMarkReadMessage(
  conversationId: string,
  messageIds: string[]
): WsMessage {
  return {
    type: WsMessageType.MARK_READ,
    payload: {
      conversation_id: conversationId,
      message_ids: messageIds,
    },
  };
}

/**
 * Create a presence update message
 */
export function createPresenceMessage(
  userId: string,
  status: PresenceStatus
): WsMessage {
  return {
    type: WsMessageType.PRESENCE,
    payload: {
      user_id: userId,
      status,
    },
  };
}

/**
 * Create a subscribe message
 */
export function createSubscribeMessage(
  subscriptionType: SubscriptionType,
  targetIds: string[]
): WsMessage {
  return {
    type: WsMessageType.SUBSCRIBE,
    payload: {
      subscription_type: subscriptionType,
      target_ids: targetIds,
    },
  };
}

/**
 * Create an unsubscribe message
 */
export function createUnsubscribeMessage(
  subscriptionType: SubscriptionType,
  targetIds: string[]
): WsMessage {
  return {
    type: WsMessageType.UNSUBSCRIBE,
    payload: {
      subscription_type: subscriptionType,
      target_ids: targetIds,
    },
  };
}

/**
 * Create a ping message
 */
export function createPingMessage(): WsMessage {
  return {
    type: WsMessageType.PING,
    payload: {
      timestamp: Date.now(),
    },
  };
}

/**
 * Create a pong message
 */
export function createPongMessage(pingTimestamp: number): WsMessage {
  return {
    type: WsMessageType.PONG,
    payload: {
      timestamp: pingTimestamp,
      server_timestamp: Date.now(),
    },
  };
}

// =============================================================================
// TYPE GUARDS
// =============================================================================

/**
 * Type guard to check if a message is a specific type
 */
export function isMessageType<T extends WsMessageType>(
  message: WsMessage,
  type: T
): message is Extract<WsMessage, { type: T }> {
  return message.type === type;
}

/**
 * Parse a raw WebSocket message string
 */
export function parseWsMessage(data: string): WsMessage | null {
  try {
    const parsed = JSON.parse(data);
    if (typeof parsed === 'object' && parsed !== null && 'type' in parsed && 'payload' in parsed) {
      return parsed as WsMessage;
    }
    return null;
  } catch {
    return null;
  }
}

/**
 * Serialize a WebSocket message to JSON string
 */
export function serializeWsMessage(message: WsMessage): string {
  return JSON.stringify(message);
}
