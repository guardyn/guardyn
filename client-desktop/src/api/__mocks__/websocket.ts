/**
 * Mock WebSocket module for tests
 * Prevents actual WebSocket connections during testing
 */

import { vi } from 'vitest';

export enum MessageType {
  TEXT_MESSAGE = 'TEXT_MESSAGE',
  TYPING_START = 'TYPING_START',
  TYPING_STOP = 'TYPING_STOP',
  PRESENCE_UPDATE = 'PRESENCE_UPDATE',
  READ_RECEIPT = 'READ_RECEIPT',
  DELIVERED_RECEIPT = 'DELIVERED_RECEIPT',
  MESSAGE_DELETED = 'MESSAGE_DELETED',
  MESSAGE_EDITED = 'MESSAGE_EDITED',
  REACTION_ADDED = 'REACTION_ADDED',
  REACTION_REMOVED = 'REACTION_REMOVED',
}

// Mock WebSocket client
const mockClient = {
  connect: vi.fn(),
  disconnect: vi.fn(),
  send: vi.fn(),
  on: vi.fn(),
  off: vi.fn(),
  isConnected: false,
};

export function initWebSocket(_url?: string, _stubMode?: boolean): void {
  // Mock - does nothing
}

export function getWebSocket() {
  return mockClient;
}

export function destroyWebSocket(): void {
  // Mock - does nothing
}
